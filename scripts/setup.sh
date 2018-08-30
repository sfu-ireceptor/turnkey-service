#!/bin/bash
# 
# A script to automating the setup process of the Turnkey project.
# https://github.com/sfu-ireceptor/turnkey-service
#


set -e

# directory names
SERVICE="service-js-mongodb"
DATABASE="repository-mongodb"
DATALOADING="dataloading-mongo"


##### Main #####
# update submodules
# git submodule update --recursive --init

# check required packages and install them
./scripts/installPackages.sh

# make sure to make the symbolic link before proceeding with the rest of the commands
sudo ln -sf $PWD /opt/ireceptor

echo "copying .env file..."
cp ${SERVICE}/.env.defaults ${SERVICE}/.env

echo "copying dbsetup.js file..."
cp ${DATABASE}/dbsetup.defaults ${DATABASE}/dbsetup.js

echo -e "\n---setting up database accounts---\n"
./scripts/dbconfig.sh

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

# need to pause here to wait for containers to finish setting up
sleep 5s

# load query plans 
# Note: restarting service will clear out the cache, so make sure to run this command after each time the service is restarted!
./queryplan.sh

# ignore changes to export.sh
git update-index --skip-worktree export.sh

echo -e "\n---setup completed---\n"
