# Turnkey Package for an iReceptor Data Source Node #

iReceptor is a data management system and scientific gateway for mining “Next Generation” sequence data from immune responses. The iReceptor data management system is a distributed network of data source nodes complying with the [iReceptor public web service application programming interface (API) specification](https://github.com/sfu-ireceptor/api).  The iReceptor data management system is intended to be an AIRR-compliant data repository.

## What is this repository for? ##

This project is the source code of a "turnkey" package for the installation, configuration and data loading of a small to medium sized standalone iReceptor data source node. This turnkey configuration runs the API and simple database on a single node.

The design of this turnkey is deeply inspired and largely adapted from the excellent VDJServer iReceptor Node package developed by **Scott Christley** of the **VDJServer** project at the **University of Texas Southwestern University**.

## Dependencies ##

The 'turnkey-service' project is currently composed of 2 separate submodules and a set of docker compose directives:

 * [repository-mongodb](https://github.com/sfu-ireceptor/repository-mongodb): The Mongo database.
 * [service-js-mongodb](https://github.com/sfu-ireceptor/service-js-mongodb): iReceptor API service with JavaScript implementation for MongoDB repository. You may wish to confirm which branch of this project contains the implementation of the iReceptor data source API you wish to use (normally 'master' is the default release, although 'develop' may contain the latest implementation. As of mid-November 2017, we are have pointed the 'docker-turnkey' branch repository to the 'develop' branch)

## Version ## 

0.0.1

## Overview of Installation ##

The following installation instructions assume a Linux operating system as the target operating environment for the iReceptor turnkey. Beyond that, core configuration instructions are applicable for any suitable recent-release Linux system. There are several options for running the turnkey.

The first decision you need to make is where (on what Linux server) to run the application. Your choices generally are:

1) Directly on a Linux "bare metal" server
 
2) Within a suitably configured Linux Virtual Machine (e.g. VMWare, Parallels, VirtualBox, Amazon Web Services, etc.)

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
# Clone the project. Note that as of mid-November, the Docker version of 
# the Turnkey is in the docker-turnkey branch (may soon revert the 'master')

# Clone project using SSH...
$ git clone --branch docker-turnkey git@github.com:sfu-ireceptor/turnkey-service.git

# ...OR clone with HTTPS
$ git clone --branch docker-turnkey https://github.com/sfu-ireceptor/turnkey-service.git 

cd turnkey-service

# Initialize the submodules. This command should also checkout the current relevant code for each submodule
$ git submodule update --init
```
then follow remaining configuration steps listed here below.

**Installation of Docker**

If you choose to run the dockerized versions of the applications, you'll obviously need to [install Docker first](https://docs.docker.com/engine/installation/) in your target operating environment (bare metal server or virtual machine running Linux).  

From this point onward, it is assumed that you are logged an active command shell session within whichever Linux server environment you are running, and have your Docker engine installed, so you can further configure the application components on your server (as specified below) and run the Docker Compose to fire up the system.

**Configuring service-js-mongodb**

There is one '.env' configuration file that needs to be set up before the Docker image can be built. 

```
cd service-js-mongodb
cp .env.defaults .env
emacs .env
```

**Configuring and Building your Docker Containers**

Simply cloning the project and installing Docker does not automatically build Docker images to run. Rather, you
need to explicitly create them using a suitable docker-compose.yml specification.  A default file is provided in the 'run' subdirectory. However, note that this file assumes that you've already created a directory for your MongoDb database in the following manner (and location):

```
$ mkdir -p /opt/ireceptor/mongodb
```

Assuming that you have done this, then you can run the following command:

```
 $ sudo docker-compose -f run/docker-compose.yml build
```

If you wish to customize your docker images, then you can create a docker-compose-mysite.yml file 
and instead use it to overlay the default configuration file, as follows:

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

Note that should (re-)build your Docker images whenever the underlying submodule code or environment (.ENV) parameters change, or you wish to make docker-compose level changes to their configuration.

**Configuring repository-mongodb**

The default docker-compose setup starts mongo with authentication on,
and no users exists in the default image. To setup the database, need
to decide:

* Where mongo will store its files on host disk. (e.g. /disk/mongodb)

* Name of database in mongo where collections will be stored.

* Name and password for mongo service account. This account will have
  admin privileges for managing mongo.

* Name and password for guest account. This account will only have
  read access on the database for performing queries.

Make sure not to accidently commit the dbsetup file with usernames and
passwords into the git repository.

```
# Modify dbsetup.js with appropriate settings
cd repository-mongodb
cp dbsetup.defaults dbsetup.js
emacs dbsetup.js

# Start up temporary mongo service, note mapping of mongo data directory and dbsetup
# Set the /disk/mongodb to suit your needs 
docker run -v /disk/mongodb:/data/db -v $PWD:/dbsetup --name irdn-mongo ireceptor/repository-mongo

# Run setup script 
docker exec -it irdn-mongo mongo admin /dbsetup/dbsetup.js

# Stop mongo and get rid of name 
docker stop irdn-mongo
docker rm irdn-mongo

# Edit docker-compose.yml and put in mapping of mongo data directory
```

**Configuring systemd**

You will need to set up the 'ireceptor-repository' systemd service file
on your host machine in order to have the infrastructure automatically
restart when the host machine reboots. Note that the ireceptor-repository.service
file assumes that the turnkey code is located under /opt/ireceptor-repository. 
You should fix this path to the real location of the code on your system.

```
sudo cp host/systemd/ireceptor-repository.service /etc/systemd/systems/ireceptor-repository.service

sudo systemctl daemon-reload

sudo systemctl enable docker

sudo systemctl enable ireceptor-repository
```

**Deployment Procedure**

***SSL***

The iReceptor-Repository does not handle SSL certificates directly, and is
currently configured to run HTTP internally on port 8080. It must be
deployed behind a reverse proxy in order to allow SSL connections.

**Dockerized instances (ir-dev, ir-staging, production)**

Dockerized instances may be started/stopped/restarted using the
supplied systemd script: host/systemd/ireceptor-repository.service.
It can be accessed as follows:

```
$ sudo systemctl <ACTION> ireceptor-repository
# <ACTION> can be either: stop, start, or restart
```

In most cases, a simple restart command is sufficient to bring up
ireceptor-repository. The restart command will attempt to stop all
running docker-compose instances, and it is generally
successful. However, if it encounters any problems then you can just
stop instances manually and try it again. Use the docker process listing
comand to find out the name of your running docker processes
then turn them off, i.e.

```
$ sudo docker ps
...

sudo docker-compose down irdn-api
sudo docker-compose down irdn-mongo
```

It is also important to note that the systemd ireceptor-repository
command will not rebuild new container instances. If you need to
build/rebuild a new set of containers, then you will need to start the
command manually as follows:

```
 $ sudo docker-compose build
```

After your build has completed, you can then use systemd to deploy it:

```
$ sudo systemctl restart ireceptor-repository
```

Systemd will only restart a running service if the "restart" command is used; remember that using the "start" command twice will not redeploy any containers.


**Docker Compose Files**

There are two docker-compose files: one for general use ("docker-compose.yml"), and one that has been adjusted for use in a production environment ("docker-compose.prod-override.yml"). These files are meant to be overlayed and used together in a production environment: https://docs.docker.com/compose/extends/#different-environments

Using the production config will send all log information to syslog.

Example of using the production overlayed config:

```
docker-compose -f docker-compose.yml -f docker-compose.prod-override.yml build

docker-compose -f docker-compose.yml -f docker-compose.prod-override.yml up
```

**How to run tests**

T.B.A.

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
* The iReceptor development team may also be contacted directly via ireceptor-team *AT* sfu.ca.

