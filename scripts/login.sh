#!/bin/bash
# 
# Use this script to log into the mongodb shell.
# The 'irdn-mongo' container should be running before using the following command.
# 
sudo docker exec -it irdn-mongo mongo --authenticationDatabase admin $MONGODB_DB -u $MONGODB_SERVICE_USER -p $MONGODB_SERVICE_SECRET
