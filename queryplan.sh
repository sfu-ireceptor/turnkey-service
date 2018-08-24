#!/bin/bash
# Use this script to load the iReceptor query plans into the mongodb
# the irdn-mongo container should be running before the following command
sudo docker exec -it irdn-mongo mongo --authenticationDatabase admin $MONGODB_DB -u $MONGODB_SERVICE_USER -p $MONGODB_SERVICE_SECRET /dbsetup/queryplan.js