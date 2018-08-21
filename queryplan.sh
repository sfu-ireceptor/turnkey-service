#!/bin/bash

EXPORT_SCRIPT="export.sh"
./${EXPORT_SCRIPT}
# make sure the irdn-mongo container is running before using the following command
sudo docker exec -it irdn-mongo mongo --authenticationDatabase $MONGODB_DB -u $MONGODB_SERVICE_USER -p $MONGODB_SERVICE_SECRET /dbsetup/queryplan.js