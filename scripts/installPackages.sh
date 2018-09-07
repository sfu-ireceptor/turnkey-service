#!/bin/bash
# install required packages

echo "Updating package info.."
sudo apt-get update

echo "Installing curl.."
sudo apt-get -y install curl

echo "Adding docker apt repository"
# https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-repository
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update

echo "Installing docker-ce.."
sudo apt-get -y install docker-ce

echo "Verifying docker-ce was installed correctly.."
sudo docker run hello-world

echo "Installing docker-comopose.."
# https://docs.docker.com/compose/install/#install-compose
sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
