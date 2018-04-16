# Manual Configuration of an iReceptor Turnkey Data Node

If you decide not to simply run the **setup.sh** configuration script (or want to better understand the configuration process) then this document outlines the manual configuration steps which may be followed.

## Don't Worry... Be Happy... ##

When using a cloud instance, you *may* see a funny error crop up as the first line of output, every time you execute a terminal command, something like:

```
sudo: unable to resolve host <your-local-host-name> 
```

This nuisance error of cloud instance misconfiguration may be safely ignored as harmless to the task at hand...

## Dependencies ##

The 'turnkey-service' project is currently composed of [this root project](https://github.com/sfu-ireceptor/turnkey-service) containing some top level resources, three separate submodules, and a set of [Docker](https://www.docker.com) container 'compose' directives. The separate submodules are as follows:

 * [repository-mongodb](https://github.com/sfu-ireceptor/repository-mongodb): The Mongo database.
  * [dataloading-mongo](https://github.com/sfu-ireceptor/dataloading-mongo): A submodule with scripts, some test data and documented procedures for iReceptor node data loading.
 * [service-js-mongodb](https://github.com/sfu-ireceptor/service-js-mongodb): iReceptor API service with JavaScript implementation for MongoDB repository. You may wish to confirm which branch of this project contains the implementation of the iReceptor data source API you wish to use (normally 'master' is the default release, although 'develop' may contain the latest implementation. As of mid-November 2017, we are have pointed the 'docker-turnkey' branch repository to the 'develop' branch). *Note that this submodule itself includes another embedded submodule, [the AIRR-compliance branch of the iReceptor data node API](https://github.com/sfu-ireceptor/api/tree/AIRR-compliance), the pertinent release for which needs to be be proactively recursively synchronized with the turnkey project after git pull updates of the main code base (i.e. usually by **git submodule update --recursive** command invoked from the root project directory).*

After git cloning the code base (i.e. into **/opt/ireceptor/turnkey**), you need to ensure that the submodules are initialized as well, as follows:

```
$ cd /opt/ireceptor/turnkey-service

# Initialize the submodules. This command should also checkout the current relevant code for each submodule
$ git submodule update --recursive --init
```

## Decide how to run the System

A key decision is *how* to you want to run the software. There are two basic options:

1) Running the application directly within the operating system, or 

2) (Recommended) running within a Docker container. 

Both approaches have advantages and disadvantages. For the uninitiated, Docker is a light weight virtualization and provisioning technology for robustly running applications in relative isolation from one another. See [the Docker website](https://www.docker.com/) for further details. The main advantage of Docker is that we ensure that all the execution dependencies for the application are properly configured for you with a Docker Compose configuration we provide here (details below).  

One possible disadvantage is that some organizations discourage the use of Docker because of peculiar security issues (see also the Deployment Procedure section below). In such cases, you should perhaps contact your institution's IT department for appropriate guidance. Here, we give you the formula for using Docker to run the application. 

However, note that all configuration procedures are the same for dockerized and non-dockerized versions of the application and its submodules.

## Installation of Docker

If you choose to run the dockerized versions of the applications, you'll obviously need to [install Docker first](https://docs.docker.com/engine/installation/) in your target Linux operating environment (bare metal server or virtual machine running Linux).

For our installations, we typically use Ubuntu Linux, for which there is an [Ubuntu-specific docker installation using the repository](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#install-using-the-repository).
Note that you should have 'curl' installed first before installing Docker:

```
$ sudo apt-get install curl
```

For other installations, please find instructions specific to your choice of Linux variant, on the Docker site.

## Testing Docker

In order to ensure that docker is working correctly, run the following command:

```
$ sudo docker run hello-world
```

This should result in the following output:
```
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
ca4f61b1923c: Pull complete
Digest: sha256:be0cd392e45be79ffeffa6b05338b98ebb16c87b255f48e297ec7f98e123905c
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://cloud.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/engine/userguide/
```

## Installing Docker Compose

You will then also need to [install Docker Compose](https://docs.docker.com/compose/install/) alongside Docker on your target Linux operating environment.

Note that under Ubuntu, you need to run docker (and docker-compose) as 'sudo'. 

## Testing Docker Compose

In order to ensure Docker Compose is working correctly, issue the following command:
```
$ docker-compose --version
docker-compose version 1.18.0, build 8dd22a9
```
Note that your particular version and build number may be different than what is shown here. We don't currently expect that docker-compose version differences should have a significant impact on the build, but if in doubt, refer to the release notes of the docker-compose site for advice.

# Configuring the iReceptor Turnkey system

From this point onward, it is assumed that you are logged an active command shell session within whichever Linux server environment you are running, and have your Docker engine installed, so you can further configure the application components on your server (as specified below) and run the Docker Compose to fire up the system.

## Configuring service-js-mongodb

There is one '.env' configuration file that needs to be set up before the Docker image can be built. 

```
cd service-js-mongodb
cp .env.defaults .env
# Use emacs or your favorite file editor (note: may need to be installed by apt-get in a new image...)
emacs .env
```

Note the parameters you set here will be propagated to the *dbsetup.js* file in the next section, as
noted by the inline comments in  the *.env.defaults* file.

```
# if your docker-compose build specifies a network, 
# then the HOST here can simply be your MongoDb docker 
# container name (as defined in the docker-compose.yml 
# file for the repository-mongodb build, i.e. 'irdn-mongo')
MONGODB_HOST= 

# Pick your database name, same as the 'dbname' in the 
# dbsetup.js file in your repository-mongodb submodule
MONGODB_DB=

# These values should be set to the 'guestAccount' and
# 'guestSecret' values respectively, as defined in the 
# dbsetup.js file in your repository-mongodb submodule
MONGODB_GUEST_USER=
MONGODB_GUEST_SECRET=
```

## Configuring repository-mongodb

The default docker-compose setup starts mongo with authentication on,
and no users exists in the default image. To setup the database, need
to decide:

* Where mongo will store its files on host disk. (e.g. /opt/ireceptor/mongodb)

* Name of database in mongo where collections will be stored. As noted
  above, this should be set to the same value as MONGODB_DB.

* Name and password for mongo service account. This account will have
  admin privileges for managing mongo.

* Name and password for guest account. This account will only have
  read access on the database for performing queries. As noted above
  these should be set to the same values at MONGODB_GUEST_USER and MONGODB_GUEST_SECRET.

```
# Modify dbsetup.js with appropriate settings
cd ../repository-mongodb
cp dbsetup.defaults dbsetup.js
emacs dbsetup.js
```

Make sure not to accidently commit the dbsetup file with usernames and
passwords into the git repository (Note that *dbsetup.js* is included
in the .gitignore to protect against this...).

## Configuring and Building your Docker Containers

Simply cloning the project,  installing Docker and applying the above 
configuration detailsdoes not automatically build Docker images to run. 
Rather, you need to explicitly create them using a suitable docker-compose.yml 
specification.  A default file is provided in the 'run' subdirectory. 
However, note that this file assumes that you've already created a directory 
for your MongoDb database in the following manner (and location):

```
$ sudo mkdir -p /opt/ireceptor/mongodb
```

Assuming that you have done this, then you can run the following command

```
 $ cd ..  # make sure you are back in the root project directory
 $ sudo docker-compose -f run/docker-compose.yml build
```

This command make take some time to execute, as it is downloading and build your docker containers.

If you wish to customize your docker images, then you can create an overlay
docker-compose-mysite.yml file and use it to override the default 
configuration file during the build, as follows:

```
 $ sudo docker-compose -f run/docker-compose.yml -f /path/to/my/docker-compose-mysite.yml build
```

For example, you can change the location of your MongoDb database by putting the following into your docker-compose-mysite.yml file:

```
version: '2'

services:
    irdn-mongo:
        volumes:
            - /path/to/my/ireceptor/mongodb:/data/db
```

Note that should (re-)build your Docker images whenever the underlying submodule code or environment 
(*.env*) parameters change, or you wish to make docker-compose level changes to their configuration.

## Initializing the repository-mongodb Docker instance

After building your Docker images, you can proceed to initialize your Mongodb database.
Making sure that you are back in the repository-mongo submodule folder
Start up temporary mongo service (run as a docker background process).
Note the mapping of mongo data directory and dbsetup.  You may set the 
/opt/ireceptor/mongodb to suit your needs, but it should be the same 
value as recorded in the docker-compose.yml file used to make the image.

```
$ cd repository-mongodb
$ sudo docker run -d --rm -v /opt/ireceptor/mongodb:/data/db -v $PWD:/dbsetup --name irdn-mongo ireceptor/repository-mongo

# Run setup script

$ sudo docker exec -it irdn-mongo mongo admin /dbsetup/dbsetup.js

# Stop the temporary mongo service daemon (note: --rm flag above ensures that the container is also removed)
$ sudo docker stop irdn-mongo

```

The /opt/ireceptor/mongodb (or your specified) database directory should now 
contain an initialized Mongo database, ready for use by your system. The contents of the directory should be something like the following.

```
$ ls /opt/ireceptor/mongodb/
collection-0-8341968993270290234.wt  diagnostic.data                 index-6-8341968993270290234.wt  _mdb_catalog.wt  WiredTiger         WiredTiger.wt
collection-2-8341968993270290234.wt  index-1-8341968993270290234.wt  index-8-8341968993270290234.wt  mongod.lock      WiredTigerLAS.wt
collection-4-8341968993270290234.wt  index-3-8341968993270290234.wt  index-9-8341968993270290234.wt  sizeStorer.wt    WiredTiger.lock
collection-7-8341968993270290234.wt  index-5-8341968993270290234.wt  journal                         storage.bson     WiredTiger.turtle
```

## Configuring systemd

You will need to set up the 'ireceptor' systemd service file
on your Linux machine running Docker, in order to have the infrastructure automatically
restart when the machine reboots. Note that the *ireceptor.service*
file assumes that the turnkey code is located under /opt/ireceptor/turnkey-service. 
You should fix this path or make a symbolic link to the real location of the code on your system.

```
# symbolic link (if necessary) to your local git clone directory for the turnkey-service code
cd /opt/ireceptor
# The following assumes that your GIT clone of the turnkey-service repository
# is in ~ubuntu/turnkey-service. If not, replace ~ubuntu/turnkey-service with 
# the path where you cloned the turnkey-service repository.
sudo ln -s ~ubuntu/turnkey-service .
cd turnkey-service
sudo cp host/systemd/ireceptor.service /etc/systemd/system/ireceptor.service
sudo systemctl daemon-reload
sudo systemctl enable docker
sudo systemctl enable ireceptor
```

## SSL

The iReceptor-Repository does not handle SSL certificates directly, and is
currently configured to run HTTP internally on port 8080. It must be
deployed behind a reverse proxy in order to allow SSL connections.

We don't (yet) tell you how to do this (here). 
For now, please consult with your local system administrator or
suitable documentation about your web server platform of choice (e.g. Apache, NGINX, etc).

# Deployment Procedure

## Managing dockerized instances

Dockerized instances may be started/stopped/restarted using the
supplied systemd script *host/systemd/ireceptor.service*.
It can be accessed as follows:

```
$ sudo systemctl <ACTION> ireceptor
# <ACTION> can be either: stop, start, or restart
```

In most cases, a simple restart command is sufficient to bring up
ireceptor.

```
$ sudo systemctl restart ireceptor
```

To confirm that this worked and the docker containers are indeed running,
you can run the following command:

```
$ sudo docker ps
CONTAINER ID        IMAGE                          COMMAND                  CREATED             STATUS              PORTS                      NAMES
c4f87f0749a5        ireceptor/service-js-mongodb   "node --harmony /s..."   5 minutes ago       Up 5 minutes        0.0.0.0:8080->8080/tcp     irdn-api
ff26aab34970        ireceptor/repository-mongo     "docker-entrypoint..."   5 minutes ago       Up 5 minutes        0.0.0.0:27017->27017/tcp   irdn-mongo
```

The restart command will attempt to stop all
running docker-compose instances, and it is generally
successful. However, if it encounters any problems then you can just
stop instances manually and try it again. Use the docker process listing
command to find out the name of your running docker processes
then turn them off, i.e.

```
$ sudo docker ps
...

$ sudo docker-compose down irdn-api
$ sudo docker-compose down irdn-mongo
```

## Changing the configuration and using a new codebase

If you have followed this turnkey recipe, you should already have 
a set of docker containers to use.  However, if you change your codebase, 
deployment configuration, etc. it is important to note that the ireceptor systemd
command will not automatically rebuild new container instances. 
You'll have to do this yourself, as the need arises, that is
build/rebuild a new set of containers, then (once again) run the 
build command manually from within the project subdirectory, as follows:

```
 $ sudo docker-compose -f run/docker-compose.yml build
```

After your build has completed, you can then use systemd to re-deploy it:

```
$ sudo systemctl restart ireceptor
```

Systemd will only restart a running service if the "restart" command is used; 
remember that using the "start" command twice will not redeploy any containers.

Once again, after restarting the service, you should see a set of docker containers 
running in your Linux environment, by running the docker process viewing command:

```
$ sudo docker ps
```

