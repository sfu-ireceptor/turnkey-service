#!/bin/bash
# 
# A script to automating the setup process of the Turnkey project.
# https://github.com/sfu-ireceptor/turnkey-service
#


set -e

##### Configuration #####

# directory names
SERVICE="service-js-mongodb"
DATABASE="repository-mongodb"
DATALOADING="dataloading-mongo"

WAIT_TIME=10


##### Main #####
echo "Downloading git submodules..."
git submodule update --recursive --init
echo "Done (downloading git submodules)"

echo "Installing Docker..."
./scripts/installPackages.sh
echo "Done (installing Docker)"

# make sure to make the symbolic link before proceeding with the rest of the commands
sudo mkdir -p /opt/ireceptor
sudo ln -sf $PWD /opt/ireceptor/turnkey-service

echo -e "\n---setting up database accounts---\n"
echo "Running dbconfig.sh..."
./scripts/dbconfig.sh
echo "dbconfig.sh done"

# build the docker containers
sudo mkdir -p /opt/ireceptor/mongodb
sudo docker-compose -f run/docker-compose.yml build

echo -e "\n---initilializing database---\n"

cd $DATABASE

sudo docker run -d --rm -v /opt/ireceptor/mongodb:/data/db -v $PWD:/dbsetup --name irdn-mongo ireceptor/repository-mongo
sleep 3s # need to pause here to let database finish initializing itself 
sudo docker exec -it irdn-mongo mongo admin /dbsetup/dbsetup.js
sudo docker stop irdn-mongo

cd ..

echo -e "\nsetting up ireceptor systemd service...\n"
sudo cp host/systemd/ireceptor.service /etc/systemd/system/ireceptor.service
sudo systemctl daemon-reload
sudo systemctl enable docker
sudo systemctl enable ireceptor
sudo systemctl restart ireceptor

# need to pause here to wait for containers to finish setting up (note: tried with 5s and not long enough for docker to finish reloading the containers)
echo "waiting for docker containers to restart... (~${WAIT_TIME} secs)"
sleep ${WAIT_TIME}s

source export.sh

# load query plans 
# Note: restarting service will clear out the cache, so make sure to run this command after each time the service is restarted!
echo "Creating query plans"
./queryplan.sh

# setup configurations for dataloading-mongo
echo "Now setting up dataloading-mongo..."
${DATALOADING}/setup.sh

# load indexes
echo "Creating indexes"
${DATALOADING}/scripts/dataloader.py -v --build

echo -e "\n---setup completed---\n"
