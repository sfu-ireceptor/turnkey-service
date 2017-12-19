# Turnkey Package for an iReceptor Data Source Node #

[iReceptor](http://ireceptor.org) is a data management system and scientific gateway for mining newly available Next Generation sequence data of Acquired Immunity Receptor Repertoires (AIRR). The iReceptor data management system is designed to be a distributed network of data source nodes implementing a common data access Application Programming Interface (API) specification.  The iReceptor data management system is expected to become one public reference implementation of a AIRR-compliant data repository. 

This repository contains the software package of a "turnkey" package for the installation, configuration and data loading of a small to medium sized iReceptor data source node running a simple database within a single node. With respect to the iReceptor API, the turnkey package specifically implements the ["AIRR Compliance" branch of the iReceptor public web service API](https://github.com/sfu-ireceptor/api/tree/AIRR-compliance).

The design of this turnkey is deeply inspired and largely adapted from the excellent VDJServer iReceptor Node package developed by **Scott Christley** of the **VDJServer** project at the **University of Texas Southwestern University**.

Here we give an overview of iReceptor node configuration and operation. It is assumed that you type in these commands and run them within a Linux terminal (the '$' designates the command line prompt... yours may look different!).

## Dependencies ##

The 'turnkey-service' project is currently composed of three separate submodules and a set of docker compose directives:

 * [repository-mongodb](https://github.com/sfu-ireceptor/repository-mongodb): The Mongo database.
 * [service-js-mongodb](https://github.com/sfu-ireceptor/service-js-mongodb): iReceptor API service with JavaScript implementation for MongoDB repository. You may wish to confirm which branch of this project contains the implementation of the iReceptor data source API you wish to use (normally 'master' is the default release, although 'develop' may contain the latest implementation. As of mid-November 2017, we are have pointed the 'docker-turnkey' branch repository to the 'develop' branch)
 * [dataloading-mongodb](https://github.com/sfu-ireceptor/dataloading-mongodb): A submodule with scripts, some test data and documented procedures for iReceptor node data loading.

## Version ## 

0.0.1

## First Decision: Where and how will you run the iReceptor node? ##

The following installation instructions assume a Linux operating system as the target operating environment for the iReceptor turnkey. Beyond that, core configuration instructions are applicable for any suitable recent-release Linux system. There are several options for running the turnkey.

The first decision you need to make is where (on what Linux server) to run the application. Your choices generally are:

1) Directly on a Linux "bare metal" server
 
2) Within a suitably configured Linux Virtual Machine (e.g. VMWare, Parallels, VirtualBox, Amazon Web Services, OpenStack etc.)
	- We use OpenStack internally to provision services (using Compute Canada's OpenStack service). Our internal documentation on setting up an Ubuntu VM within Compute Canada's OpenStack environment is available as [a baseline example](openstack.md) on how to set up a VM. The process will likely vary based on the VM provider and technology you use.

Your choice of Linux operating system is not too critical except that the specific details on how to configure the system may differ between Linux flavors. For the moment, as of November 2017, we are working here with a recent 'latest' release (i.e. 16.04) of Ubuntu server.

Your second decision is *how* to run the software.

1) Running the application directly in the operating system or 

2) (recommended) running within a Docker container. 

Both approaches have advantages and disadvantages. For the uninitiated, Docker is a light weight virtualization and provisioning technology for robustly running applications in relative isolation from one another. See [the Docker website](https://www.docker.com/) for further details. The main advantage of Docker is that we ensure that all the execution dependencies for the application are properly configured for you with a Docker Compose configuration we provide here (details below).  

One possible disadvantage is that some organizations discourage the use of Docker because of peculiar security issues (see also the Deployment Procedure section below). In such cases, you should perhaps contact your institution's IT department for appropriate guidance. Here, we give you the formula for using Docker to run the application. 

However, note that all configuration procedures are the same for dockerized and non-dockerized versions of the application and its submodules.

## Configuration Procedure ##

**Code Setup**

You will need to clone down this project and all submodules onto your Linux machine in order to set up a local instance of an ireceptor data source node.

```
# Clone the project.

# Clone project using SSH...
$ git clone git@github.com:sfu-ireceptor/turnkey-service.git

# ...OR clone with HTTPS
$ git clone https://github.com/sfu-ireceptor/turnkey-service.git 

cd turnkey-service

# Initialize the submodules. This command should also checkout the current relevant code for each submodule
$ git submodule update --recursive --init
```
then follow remaining configuration steps listed here below.

**Installation of Docker**

If you choose to run the dockerized versions of the applications, you'll obviously need to [install Docker first](https://docs.docker.com/engine/installation/) in your target Linux operating environment (bare metal server or virtual machine running Linux).

For our installations, we typically use Ubuntu Linux, for which there is an [Ubuntu-specific docker installation using the repository](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#install-using-the-repository).
Note that you should have 'curl' installed first before installing Docker:

```
$ sudo apt-get install curl
```

For other installations, please find instructions specific to your choice of Linux variant, on the Docker site.

**Testing Docker**

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

**Installing Docker Compose**

You will then also need to [install Docker Compose](https://docs.docker.com/compose/install/) alongside Docker on your target Linux operating environment.

Note that under Ubuntu, you need to run docker (and docker-compose) as 'sudo'. 

**Testing Docker Compose**

In order to ensure Docker Compose is working correctly, issue the following command:
```
$ docker-compose --version
docker-compose version 1.17.0, build ac53b73
```

**Configuring the iReceptor Turnkey system**

From this point onward, it is assumed that you are logged an active command shell session within whichever Linux server environment you are running, and have your Docker engine installed, so you can further configure the application components on your server (as specified below) and run the Docker Compose to fire up the system.

**Configuring service-js-mongodb**

There is one '.env' configuration file that needs to be set up before the Docker image can be built. 

```
cd service-js-mongodb
cp .env.defaults .env
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

**Configuring repository-mongodb**

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

**Configuring and Building your Docker Containers**

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

**Initializing the repository-mongodb Docker instance**

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
contain an initialized Mongo database, ready for use by your system.

**Configuring systemd**

You will need to set up the 'ireceptor' systemd service file
on your Linux machine running Docker, in order to have the infrastructure automatically
restart when the machine reboots. Note that the *ireceptor.service*
file assumes that the turnkey code is located under /opt/ireceptor/turnkey-service. 
You should fix this path or make a symbolic link to the real location of the code on your system.

```
# symbolic link (if necessary) to your local git clone directory for the turnkey-service code
cd /opt/ireceptor
sudo ln -s /path/to/your/turnkey-service .
cd turnkey-service
sudo cp host/systemd/ireceptor.service /etc/systemd/system/ireceptor.service
sudo systemctl daemon-reload
sudo systemctl enable docker
sudo systemctl enable ireceptor
```

**SSL**

The iReceptor-Repository does not handle SSL certificates directly, and is
currently configured to run HTTP internally on port 8080. It must be
deployed behind a reverse proxy in order to allow SSL connections.

We don't (yet) tell you how to do this (here). 
For now, please consult with your local system administrator or
suitable documentation about your web server platform of choice (e.g. Apache, NGINX, etc).

## Deployment Procedure ##

**Managing dockerized instances**

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

**Changing the configuration and using a new codebase**

It is also important to note that the systemd ireceptor
command will not rebuild new container instances. 
If you have followed this turnkey recipe, you should already have
a set of docker containers to use. However, if you change your 
codebase, deployment configuration, etc. and therefore, need to
build/rebuild a new set of containers, then (once again) you will need 
to run the build command manually from within the project subdirectory, as follows:

```
 $ sudo docker-compose -f run/docker-compose.yml build
```

After your build has completed, you can then use systemd to deploy it:

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

# Testing the Turnkey Repository #

**Testing Database Access in the Node**

Assuming that you have (re)started the containers that manage the database, you should have a Mongo container running.

```
$ sudo docker ps | grep irdn-mongo
ff26aab34970        ireceptor/repository-mongo     "docker-entrypoint..."   28 minutes ago      Up 28 minutes       0.0.0.0:27017->27017/tcp   irdn-mongo
```

You can test access to the Mongo repository using the following command:

```
$ sudo docker exec -it irdn-mongo mongo --authenticationDatabase admin dbname -u serviceAccount -p serviceSecret
```
 
Where the *dbname*, *serviceAccount* and *serviceSecret* are as you set them above in the *dbsetup.js* configuration file (e.g. dbname is probably 'ireceptor').

That will give you a command line access to mongo. Assuming this succeeds, you can then try simple commands like

```
> db.getName()
ireceptor
> db.stats()
{
        "db" : "ireceptor",
        "collections" : 0,
        "views" : 0,
        "objects" : 0,
        "avgObjSize" : 0,
        "dataSize" : 0,
        "storageSize" : 0,
        "numExtents" : 0,
        "indexes" : 0,
        "indexSize" : 0,
        "fileSize" : 0,
        "fsUsedSize" : 0,
        "fsTotalSize" : 0,
        "ok" : 1
}
> exit
```

**Testing the iReceptor Web Service**

You should also have a docker container running the iReceptor web service. 

```
$ sudo docker ps | grep irdn-api
sudo: unable to resolve host ireceptor-turnkey-test-2
c4f87f0749a5        ireceptor/service-js-mongodb   "node --harmony /s..."   30 minutes ago      Up 30 minutes       0.0.0.0:8080->8080/tcp     irdn-api
```

In order to confirm that the iReceptor Repository Service is running, issue the following command:

```
$ curl -X POST -H "accept: application/json" -H "Content-Type: application/x-www-form-urlencoded" "http://localhost:8080/v2/samples"
```

# Loading Data into the Node #

This project links into a ['dataloader' submodule](https://github.com/sfu-ireceptor/dataloading-mongo)
which is currently under active development and has a README providing details about available data loading scripts.

Note that data loading is a "service" user operation hence you should use the "service" user plus secret set in dbsetup.js (above).
Note that the environment variables "MONGODB_SERVICE_USER" and "MONGODB_SERVICE_SECRET" may be set to these values
for convenience in data loading (these are the default credentials read from the environment).

# Managing the software environment #

**Docker Compose Files**

There are two docker-compose files: one for general use ("docker-compose.yml"), and one that has been adjusted for use in a production environment ("docker-compose.prod-override.yml"). These files are meant to be overlayed and used together in a production environment: https://docs.docker.com/compose/extends/#different-environments

Using the production config will send all log information to syslog.

Example of using the production overlayed config (run from the root project directory):

```
docker-compose -f run/docker-compose.yml -f docker-compose.prod-override.yml build
docker-compose -f run/ocker-compose.yml -f run/docker-compose.prod-override.yml up
```

**How to run tests**

At the moment, we don't yet have a formal test suite for testing your node. Your best option
for now is to review the API docs and compose suitable API calls using your browser.


**Updating the project database or service submodules to a specified Git branch**

If you want to move the repository-mongodb or service-js-mongodb submodules to a particular new branch or tag:

```
cd submodule_directory # e.g. service-js-mongodb
git checkout new_branch_or_tag
cd ..
git add submodule_directory
git commit -m "moved submodule to new_branch_or_tag"
git push
```

Then, another developer who wants to have submodule_directory changed to that tag, does this:

```
git pull
git submodule update

```
git pull changes which commit their submodule directory points to.  git submodule update actually merges in the new code.

Note that after you complete the update of the code tree, you'll need to rebuild your Docker images 
and restart any Docker containers you have running, that is (run from the root project directory):

```
$ sudo docker-compose -f run/docker-compose.yml build
$ sudo systemctl restart ireceptor

```

or the equivalent build with any overlay docker-compose configuration files (see above)

# Contribution guidelines #

* Writing tests
* Code review
* Other guidelines

## Development Guidelines ##

**Code Style**

 * Code should roughly follow Google Javascript Style Guide conventions: <https://google-styleguide.googlecode.com/svn/trunk/javascriptguide.xml>.

 * A jscs.rc file (Javascript Code Style Checker) file has been provided in the project repo, and all developers are encouraged to use it.

 * A git pre-commit hook is available via the file pre-commit.sh. To use it, just symlink it as follows: ```ln -s ../../pre-commit.sh .git/hooks/pre-commit```

 * Spaces are preferred over tabs, and indentation is set at 4 spaces.

 *  Vimrc settings: ```set shiftwidth=4, softtabstop=4, expandtab```
 
**Git Structure and Versioning Process**

 * This project uses the Git Flow methodology for code management and development: <https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow>.

 * New development and features should be done on branches that are cloned from the **develop** branch, and then merged into this branch when completed. Likewise, new release candidates should be branched from **develop**, and then merged into **master** once they have been tested/verified. Once a release branch is ready for production, it should be merged into **master** and tagged appropriately. Every deployment onto production should be tagged following semantic versioning 2.0.0 standards: <http://semver.org/>.

# Who do I talk to? #

* Maintainer of this project is Dr. Richard Bruskiewich (richard *AT* starinformatics *DOT* com), technical subcontractor to the iReceptor project hosted by Simon Fraser University.
* Principal Investigator of the iReceptor project is Dr. Felix Breden (breden *AT* sfu.ca) of Simon Fraser University 
* The iReceptor development team may also be contacted directly via support *AT* ireceptor.org.

