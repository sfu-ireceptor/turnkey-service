#!/bin/bash

###########################################################
# Configuration 

# directory names
SERVICE="service-js-mongodb"
DATABASE="repository-mongodb"
DATALOADING="dataloading-mongo"

# wait time
WAIT_TIME=10

###########################################################
# Main

# stop script immediately if a command exits with an error
set -e

echo "Downloading git submodules.."
git submodule update --recursive --init
echo "Done (downloading git submodules)"

echo
echo "Installing docker.."
./scripts/install_docker.sh
echo "Done (installing docker)"

echo
echo "Creating /opt/ireceptor"
sudo mkdir -p /opt/ireceptor
sudo mkdir -p /opt/ireceptor/mongodb
sudo ln -sf $PWD /opt/ireceptor/turnkey-service

echo
echo "Initialize database authentication information"
./scripts/init_db_auth.sh
echo "Done (initializing database authentication information)"

echo
echo "Building docker images"
sudo docker-compose -f run/docker-compose.yml build
echo "Done (building docker images)"

echo
echo "Starting docker container for database..."
cd $DATABASE
sudo docker run -d --rm -v /opt/ireceptor/mongodb:/data/db -v $PWD:/dbsetup --name irdn-mongo ireceptor/repository-mongo
# wait for database to start
sleep 3s 
echo "Done (starting docker container for database)"

echo
echo "Creating database users..."
sudo docker exec -it irdn-mongo mongo admin /dbsetup/dbsetup.js
echo "Done"

echo
echo "Stopping docker container for database..."
sudo docker stop irdn-mongo
echo "Done"
cd ..

echo
echo "Adding and starting 'ireceptor' system service which will run the docker containers..."
sudo cp ./host/systemd/ireceptor.service /etc/systemd/system/ireceptor.service
sudo systemctl daemon-reload
sudo systemctl enable docker
sudo systemctl enable ireceptor
sudo systemctl restart ireceptor

# need to pause here to wait for containers to finish setting up (note: tried with 5s and not long enough for docker to finish reloading the containers)
echo
echo "Waiting for the docker containers to start.. (~${WAIT_TIME} secs)"
sleep ${WAIT_TIME}s

# load query plans 
# note: needs to be done each time the service is restarted..
echo "Creating query plans.."
# get database auth info
source ./scripts/export.sh
sudo docker exec -it irdn-mongo mongo --authenticationDatabase admin $MONGODB_DB -u $MONGODB_SERVICE_USER -p $MONGODB_SERVICE_SECRET /dbsetup/queryplan.js
echo "Done (creating query plans)"

echo "Installing packages for data loading"
${DATALOADING}/setup.sh
echo "Done (installing packages for data loading)"

echo "Creating MongoDB indexes.."
${DATALOADING}/scripts/dataloader.py -v --build
echo "Done (creating MongoDB indexes)"

echo
echo "Installation was successful!"
echo
echo "Database ADMIN username: $MONGODB_SERVICE_USER"
echo "Database ADMIN password: $MONGODB_SERVICE_SECRET"
echo
