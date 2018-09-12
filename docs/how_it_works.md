# How it works

## Software stack
- Database: [MongoDB](https://www.mongodb.com/what-is-mongodb)
- Web server: [node.js](https://nodejs.org/en/about/)
- [Docker](https://www.docker.com/why-docker) to run the database and the web application in contained environments

## Docker
By using Docker, nothing is installed directly on your system, except for Docker itself and a system service to easily start/stop the Docker containers.

- The database runs in a Docker container. The database data is in a folder shared by the host and the Docker container, so the data is preserved when the container is stopped.
- The web service runs in another Docker container.

## Install script
What it did:
- downloaded Docker
- built two Docker images from a blank Ubuntu Docker image.
- started two Docker containers using the two Docker images.
- installed a system service to easily start/stop the two Docker containers.
- installed the required software to use the data loading script





