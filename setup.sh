#!/bin/bash
# A script to help automating the setup process of the turnkey project

# Path to service-js submodule
SERVICE="service-js-mongodb"
# Path to database submodule
DATABASE="repository-mongodb"
# Path to dataloading submodule
DATALOADING="dataloading-mongo"
CURL="curl"
DOCKER="docker"
DOCKER_COMPOSE="docker-compose"
# Required packages
PACKAGES=($CURL $DOCKER $DOCKER_COMPOSE)
# Number of uninstalled packages
n=0
# ANSCI FG code for Bright Yellow
YELLOW="93"
WHITE="37"
# index used to store guest accountname in an array
GUEST_NAMEI=0
# index used to store guest password in an array
GUEST_SECRETI=1
# index used to store service accountname in an array
SERVICE_NAMEI=2
# index used to store service password in an array
SERVICE_SECRETI=3
# default value for database name 
DB_NAME="ireceptor"
# default value for database host name 
DB_HOST="irdn-mongo"

DB_NAME_PARA="name"
DB_HOST_PARA="host"


# Colors the rest of the parameter using the color given by the first parameter ($1)
color() {
    CODE=$1
    shift
    echo -e "\e[${CODE}m$@\e[0m"
}

# Underlines and bolds all of the parameters supplied to this function
underline() { 
    echo -e "\e[1m\e[4m$@\e[0m"
}

bold() {
    echo -e "\e[1m$@\e[0m"
}

# Keep promting the user if they would like to have the package installed. Set appropriate values into $INSTALL
readInstall() {
    while true; do
        read -p "Would you like to install the package now? ($(underline y)es/$(underline n)o) " INSTALL
        echo
        case $INSTALL in
            [yY]* ) INSTALL="yes"; break;;
            [nN]* ) INSTALL=""; break;;
        esac
    done
}

# Tries to install the given package
installPackage() {
    case $1 in
        $CURL) 
            sudo apt install -y $CURL
            ;;
        $DOCKER) #https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-repository
            # Set up the repository
            sudo apt-get update
            sudo apt-get install -y \
                apt-transport-https \
                ca-certificates \
                curl \
                software-properties-common
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
            sudo apt-key fingerprint 0EBFCD88
            # x86_64 / amd64
            sudo add-apt-repository \
                "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
                $(lsb_release -cs) \
                stable"
            
            # Install Docker CE
            sudo apt-get update
            sudo apt-get install docker-ce
            sudo docker run hello-world
            ;;
        $DOCKER_COMPOSE) #https://docs.docker.com/compose/install/#install-compose
            sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
            sudo chmod +x /usr/local/bin/docker-compose
            docker-compose --version
            ;;
    esac
}

# Checks if a package is installed or not
checkPackage() { 
    if ! [ -x "$(command -v $1)" ]; then
        echo -e "\n$(color $YELLOW $1) is not detected on your system. "
        readInstall
        if [ -n "$INSTALL" ]; then
            installPackage $1
        else
            NOT_INSTALLED[n]=$1
            n=`expr $n + 1` 
        fi
    fi
}

# checks if all the required packages are installed or not
checkAllPackages() {
    for i in "${PACKAGES[@]}"; do
        checkPackage $i
    done

    if [ $n -gt 0 ]; then
        echo "The following required package(s) are not installed:"
        for i in ${NOT_INSTALLED[@]}; do
            echo `color $YELLOW $i`
        done
        echo "Please install them before continuing."
        exit 1
    fi
}

readAccount() {
    # read accountname
    while true; do
        read -p "Please enter a $1 for the $(bold $2) account(you can change these later): " NAME
        # echo "Please enter a $1 for the $(bold $2) account(you can change these later): "
        # read NAME
        case $NAME in
            ?* ) break;;
        esac
    done

    # read password
    while true; do
        read -s -p "and a password: " SECRET
        # echo "and a password: "
        # read -s SECRET
        case $SECRET in
            ?* ) break;;
        esac
    done
    ACCOUNT[secretI]=$SECRET
    ACCOUNTS[$3]=$NAME
    ACCOUNTS[$4]=$SECRET
}

# read username and password from the user
readAccounts() {    
    readAccount "username" "guest" $GUEST_NAMEI $GUEST_SECRETI
    echo ""
    readAccount "username" "service" $SERVICE_NAMEI $SERVICE_SECRETI
    echo -e "\n"
}

promptDb() {
    while true; do
        read -p "Please enter a new value for the database $(color $WHITE $1): " DB_INPUT
        case $DB_INPUT in
            ?* ) break;;
        esac
    done
    if [ "$1" = $DB_NAME_PARA ]; then
        DB_NAME=$DB_INPUT
    elif [ "$1" = $DB_HOST_PARA ]; then
        DB_HOST=$DB_INPUT
    fi
}

readDb() {
    while true; do
        echo -n -e "The default value for the database $(color $WHITE $1) is \"$(color $WHITE $2)\", okay?($(underline y)es/$(underline n)o) "
        read INPUT
        case $INPUT in
            [yY]* ) break;;
            [nN]* ) promptDb $1; break;;
        esac
    done
}

readDbs() {
    readDb $DB_NAME_PARA $DB_NAME
    readDb $DB_HOST_PARA $DB_HOST
    # echo "dbname: $DB_NAME, dbhost: $DB_HOST"
}

# write configurations into the corresponding files
writeConfig() {
    # write to .env file
    ENV_FILE="${SERVICE}/.env"
    sed -i "s/MONGODB_HOST=[^\n]*$/MONGODB_HOST=${DB_HOST}/" $ENV_FILE
    sed -i "s/MONGODB_DB=[^\n]*$/MONGODB_DB=${DB_NAME}/" $ENV_FILE
    sed -i "s/MONGODB_GUEST_USER=[^\n]*$/MONGODB_GUEST_USER=${ACCOUNTS[GUEST_NAMEI]}/" $ENV_FILE
    sed -i "s/MONGODB_GUEST_SECRET=[^\n]*$/MONGODB_GUEST_SECRET=${ACCOUNTS[GUEST_SECRETI]}/" $ENV_FILE

    # write to dbsetup.js file
    SETUP_FILE="${DATABASE}/dbsetup.js"
    sed -i "s/serviceAccount = ''/serviceAccount = '${ACCOUNTS[SERVICE_NAMEI]}'/" $SETUP_FILE
    sed -i "s/serviceSecret = ''/serviceSecret = '${ACCOUNTS[SERVICE_SECRETI]}'/" $SETUP_FILE
    sed -i "s/guestAccount = ''/guestAccount = '${ACCOUNTS[GUEST_NAMEI]}'/" $SETUP_FILE
    sed -i "s/guestSecret = ''/guestSecret = '${ACCOUNTS[GUEST_SECRETI]}'/" $SETUP_FILE
    sed -i "s/guestSecret = ''/guestSecret = '${ACCOUNTS[GUEST_SECRETI]}'/" $SETUP_FILE
    sed -i "s/dbname = 'ireceptor'/dbname = '${DB_NAME}'/" $SETUP_FILE

    # write to export file
    EXPORT_FILE="export.sh"
    sed -i "s/MONGODB_DB=[^\n]*$/MONGODB_DB='${DB_NAME}'/" ./${EXPORT_FILE}
    sed -i "s/MONGODB_SERVICE_USER=[^\n]*$/MONGODB_SERVICE_USER='${ACCOUNTS[SERVICE_NAMEI]}'/" ./${EXPORT_FILE}
    sed -i "s/MONGODB_SERVICE_SECRET=[^\n]*$/MONGODB_SERVICE_SECRET='${ACCOUNTS[SERVICE_NAMEI]}'/" ./${EXPORT_FILE}
    chmod 755 ${EXPORT_FILE}
    ./${EXPORT_FILE}
}

setUpConfig() {
    readAccounts
    readDbs
    writeConfig
}

cdDb() {
    cd $DATABASE
}

cdBack() {
    cd ..
}

git submodule update --recursive --init

# --- Packages Checking ---
checkAllPackages
echo -e "\n---package checking completed---\n"

# --- Configuration files setup ---
echo "copying .env file..."
cp -u ${SERVICE}/.env.defaults ${SERVICE}/.env

echo "copying dbsetup.js file..."
cp -u ${DATABASE}/dbsetup.defaults ${DATABASE}/dbsetup.js

echo -e "\n---setting up database accounts---\n"
setUpConfig
echo -e "\n---database configurations saved---\n"

sudo mkdir -p /opt/ireceptor/mongodb

sudo docker-compose -f run/docker-compose.yml build

sudo ln -sf $PWD /opt/ireceptor

# --- initialize database ---
cdDb

echo -e "\n---initilializing database---\n"
sudo docker run -d --rm -v /opt/ireceptor/mongodb:/data/db -v $PWD:/dbsetup --name irdn-mongo ireceptor/repository-mongo
sleep 3s # need to pause here to let database finish initializing itself 
sudo docker exec -it irdn-mongo mongo admin /dbsetup/dbsetup.js
sudo docker stop irdn-mongo

cdBack

echo -e "\nsetting up ireceptor systemd service...\n"
sudo cp host/systemd/ireceptor.service /etc/systemd/system/ireceptor.service
sudo systemctl daemon-reload
sudo systemctl enable docker
sudo systemctl enable ireceptor
sudo systemctl restart ireceptor

 # need to pause here to wait for containers to finish setting up
sleep 5s

# load query plans (restarting service will clear out the cache, so make sure to run this command after each time the service is restarted!)
sudo chmod 755 ./queryplan.sh
./queryplan.sh

echo -e "\n---setup completed---\n"
