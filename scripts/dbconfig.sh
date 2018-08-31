#!/bin/bash
# 
# A script that prompts the user and saves account parameters for the database.
#

set -e


DB_NAME="ireceptor"
DB_HOST="irdn-mongo"

# directory names
ROOT="/opt/ireceptor/turnkey-service"
SCRIPTS=$ROOT/scripts
SERVICE=$ROOT/service-js-mongodb
DATABASE=$ROOT/repository-mongodb

# index used to store account info
GUEST_NAME_I=0
GUEST_SECRET_I=1
SERVICE_NAME_I=2
SERVICE_SECRET_I=3

bold=`tput bold`
underline=`tput smul`
colored=`tput setaf 7`
reset=`tput sgr 0`

# writes configurations into the corresponding files
writeConfig() {
    # write to .env file
    ENV_FILE="${SERVICE}/.env"
    cp ${SERVICE}/.env.defaults ${SERVICE}/.env
    sed -i "s/MONGODB_HOST=[^\n]*$/MONGODB_HOST=${DB_HOST}/" $ENV_FILE
    sed -i "s/MONGODB_DB=[^\n]*$/MONGODB_DB=${DB_NAME}/" $ENV_FILE
    sed -i "s/MONGODB_GUEST_USER=[^\n]*$/MONGODB_GUEST_USER=${ACCOUNTS[GUEST_NAME_I]}/" $ENV_FILE
    sed -i "s/MONGODB_GUEST_SECRET=[^\n]*$/MONGODB_GUEST_SECRET=${ACCOUNTS[GUEST_SECRET_I]}/" $ENV_FILE

    # write to dbsetup.js file
    SETUP_FILE="${DATABASE}/dbsetup.js"
    cp ${DATABASE}/dbsetup.defaults $SETUP_FILE
    sed -i "s/guestAccount[[:space:]]*=[^\n]*;/guestAccount = '${ACCOUNTS[GUEST_NAME_I]}';/" $SETUP_FILE
    sed -i "s/guestSecret[[:space:]]*=[^\n]*;/guestSecret = '${ACCOUNTS[GUEST_SECRET_I]}';/" $SETUP_FILE
    sed -i "s/serviceAccount[[:space:]]*=[^\n]*;/serviceAccount = '${ACCOUNTS[SERVICE_NAME_I]}';/" $SETUP_FILE
    sed -i "s/serviceSecret[[:space:]]*=[^\n]*;/serviceSecret = '${ACCOUNTS[SERVICE_SECRET_I]}';/" $SETUP_FILE
    sed -i "s/dbname[[:space:]]*=[^\n]*;/dbname = '${DB_NAME}';/" $SETUP_FILE

    # write to export file
    EXPORT_FILE="$SCRIPTS/export.sh"
    cp $SCRIPTS/export.defaults $EXPORT_FILE
    sed -i "s/MONGODB_DB=[^\n]*$/MONGODB_DB='${DB_NAME}'/" ${EXPORT_FILE}
    sed -i "s/MONGODB_SERVICE_USER=[^\n]*$/MONGODB_SERVICE_USER='${ACCOUNTS[SERVICE_NAME_I]}'/" ${EXPORT_FILE}
    sed -i "s/MONGODB_SERVICE_SECRET=[^\n]*$/MONGODB_SERVICE_SECRET='${ACCOUNTS[SERVICE_SECRET_I]}'/" ${EXPORT_FILE}
}

# asks the user to enter new values for MONGODB_HOST and MONGODB_DB
promptDb() {
    while true; do
        read -p "Please enter a new value for the database ${colored}$1${reset}: " DB_INPUT
        case $DB_INPUT in
            ?* ) break;;
        esac
    done
    if [ "$1" = "name" ]; then
        DB_NAME=$DB_INPUT
    elif [ "$1" = "host" ]; then
        DB_HOST=$DB_INPUT
    fi
}

readDb() {
    while true; do
        echo -n -e "The default value for the database ${colored}$1${reset} is '${colored}$2${reset}', okay? (${underline}${bold}y${reset}es/${underline}${bold}n${reset}o) "
        read INPUT
        case $INPUT in
            [yY]* ) break;;
            [nN]* ) promptDb $1; break;;
        esac
    done
}

readAllDbs() {
    readDb "name" $DB_NAME
    readDb "host" $DB_HOST
}

# prompts the user to enter account info and saves them into variables
readAccount() {
    # read accountName
    while true; do
        read -p "Please enter a $1 for the ${bold}$2${reset} account (can be changed later): " NAME
        case $NAME in
            ?* ) break;;
        esac
    done

    # read password
    while true; do
        read -s -p "and a password: " SECRET
        case $SECRET in
            ?* ) break;;
        esac
    done

    ACCOUNTS[$3]=$NAME
    ACCOUNTS[$4]=$SECRET
}

# read username and password from the user
readAllAccounts() {    
    readAccount "username" "guest" $GUEST_NAME_I $GUEST_SECRET_I
    echo 
    readAccount "username" "service" $SERVICE_NAME_I $SERVICE_SECRET_I
    echo
}

setUpConfig() {
    readAllAccounts
    # printf '%s\n' "${ACCOUNTS[@]}"  
    readAllDbs
    # printf 'host: %s, dbname: %s\n' "$DB_HOST" "$DB_NAME"
    writeConfig
}


##### Main #####
setUpConfig
echo -e "\n---database configurations saved---\n"
