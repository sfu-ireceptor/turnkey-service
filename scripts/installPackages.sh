#!/bin/bash
# 
# A script that checks for required packages and prompts the user if they are not installed.
#

set -e

# Required packages to be installed
CURL="curl"
DOCKER="docker"
DOCKER_COMPOSE="docker-compose"
PACKAGES=($CURL $DOCKER $DOCKER_COMPOSE)

COLOR_YELLOW=3
N=0 # number of packages the user has skipped installing
reset="tput sgr 0" # reset display style

bold_underline() {
    echo $(tput bold)$(tput smul)$@$($reset)
}

# Install the given package
install() {
    case $1 in
        $CURL)
            # https://linuxhint.com/install-curl-on-ubuntu-18-04/
            sudo apt-get update
            sudo apt-get -y install $CURL
            ;;
        $DOCKER)
            # https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-repository
            # Set up the repository
            sudo apt-get update
            sudo apt-get -y install \
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
        $DOCKER_COMPOSE) 
            # https://docs.docker.com/compose/install/#install-compose
            sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
            sudo chmod +x /usr/local/bin/docker-compose
            docker-compose --version
            ;;
    esac
}

# Keep prompting the user and set appropriate values into $INSTALL
promptInstall() {
    while true; do
        read -p "Would you like to install the package now? ($(bold_underline y)es/$(bold_underline n)o) "  INSTALL
        echo
        case $INSTALL in
            [yY]* ) INSTALL=true; break;;
            [nN]* ) INSTALL=""; break;;
        esac
    done
}

# Check individual package
checkPackage() { 
    if ! [ -x "$(command -v $1)" ]; then
        echo "Installing $(tput setaf $COLOR_YELLOW)$1$($reset)..."
        install $1
    fi
}

# Check all required packages
checkAllPackages() {
    for i in "${PACKAGES[@]}"; do
        checkPackage $i
    done

    if [ $N -gt 0 ]; then
        echo "The following required package(s) are not installed:"
        for i in ${NOT_INSTALLED[@]}; do
            echo "$(tput setaf $COLOR_YELLOW)$i$($reset)"
        done
        echo "Please consider installing them before continuing."
        return 1
    fi
}


##### Main #####
checkAllPackages
