#!/bin/bash
# 
# A script that prompts the user and saves account parameters for the database.
#

set -e

##### Configuration #####

# config
DB_HOST="irdn-mongo"

DB_NAME="ireceptor"

DB_GUEST_USERNAME=guest
DB_GUEST_PASSWORD=guest

DB_ADMIN_USERNAME=admin
DB_ADMIN_PASSWORD=admin

# directory names
ROOT="/opt/ireceptor/turnkey-service"
SCRIPTS=$ROOT/scripts
SERVICE=$ROOT/service-js-mongodb
DATABASE=$ROOT/repository-mongodb

##### Main #####

# for web service: .env
ENV_FILE="${SERVICE}/.env"
cp ${SERVICE}/.env.defaults ${SERVICE}/.env
sed -i "s/MONGODB_HOST=[^\n]*$/MONGODB_HOST=${DB_HOST}/" $ENV_FILE
sed -i "s/MONGODB_DB=[^\n]*$/MONGODB_DB=${DB_NAME}/" $ENV_FILE
sed -i "s/MONGODB_GUEST_USER=[^\n]*$/MONGODB_GUEST_USER=${DB_GUEST_USERNAME}/" $ENV_FILE
sed -i "s/MONGODB_GUEST_SECRET=[^\n]*$/MONGODB_GUEST_SECRET=${DB_GUEST_PASSWORD}/" $ENV_FILE

# for mongodb initialization: dbsetup.js
SETUP_FILE="${DATABASE}/dbsetup.js"
cp ${DATABASE}/dbsetup.defaults $SETUP_FILE
sed -i "s/guestAccount[[:space:]]*=[^\n]*;/guestAccount = '${DB_GUEST_USERNAME}';/" $SETUP_FILE
sed -i "s/guestSecret[[:space:]]*=[^\n]*;/guestSecret = '${DB_GUEST_PASSWORD}';/" $SETUP_FILE
sed -i "s/serviceAccount[[:space:]]*=[^\n]*;/serviceAccount = '${DB_ADMIN_USERNAME}';/" $SETUP_FILE
sed -i "s/serviceSecret[[:space:]]*=[^\n]*;/serviceSecret = '${DB_ADMIN_PASSWORD}';/" $SETUP_FILE
sed -i "s/dbname[[:space:]]*=[^\n]*;/dbname = '${DB_NAME}';/" $SETUP_FILE

# for bash scripts: export.sh
EXPORT_FILE="$SCRIPTS/export.sh"
cp $SCRIPTS/export.defaults $EXPORT_FILE
sed -i "s/MONGODB_DB=[^\n]*$/MONGODB_DB='${DB_NAME}'/" ${EXPORT_FILE}
sed -i "s/MONGODB_SERVICE_USER=[^\n]*$/MONGODB_SERVICE_USER='${DB_ADMIN_USERNAME}'/" ${EXPORT_FILE}
sed -i "s/MONGODB_SERVICE_SECRET=[^\n]*$/MONGODB_SERVICE_SECRET='${DB_ADMIN_PASSWORD}'/" ${EXPORT_FILE}