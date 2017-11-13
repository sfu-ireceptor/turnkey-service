# Turnkey Package for an iReceptor Data Source Node #

iReceptor is a data management system and scientific gateway for mining “Next Generation” sequence data from immune responses. The iReceptor data management system is a distributed network of data source nodes complying with the [iReceptor public web service application programming interface (API) specification](https://github.com/sfu-ireceptor/api).  The iReceptor data management system is intended to be an AIRR-compliant data repository.

## What is this repository for? ##

This project is the source code of a "turnkey" package for the installation, configuration and data loading of a small to medium sized standalone iReceptor data source node. This turnkey configuration runs the API and simple database on a single node.

The design of this turnkey is deeply inspired and largely adapted from the excellent VDJServer iReceptor Node package developed by Scott Christley of the VDJServer project at the University of Texas Southwestern University.

##Dependencies

The 'turnkey-service' project is currently composed of 2 separate submodules and a set of docker compose directives:

 * [repository-mongodb](https://github.com/sfu-ireceptor/repository-mongodb): The Mongo database.
 * [service-js-mongodb](https://github.com/sfu-ireceptor/service-js-mongodb): iReceptor API service with JavaScript implementation for MongoDB repository.

## Version ## 

0.0.1

## Overview of Installation ##

The turnkey package is designed using a layered technology stack to facilitate deployment but also, provide some flexibility.

T.B.A.

##Configuration Procedure

All configuration procedures are the same for dockerized and non-dockerized versions of these apps.

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
docker run -v /disk/mongodb:/data/db -v $PWD:/dbsetup --name irdn-mongo ireceptor/repository-mongo

# Run setup script
docker exec -it irdn-mongo mongo admin /dbsetup/dbsetup.js

# Stop mongo and get rid of name
docker stop irdn-mongo
docker rm irdn-mongo

# Edit docker-compose.yml and put in mapping of mongo data directory
```

**Configuring service-js-mongodb**

There is one configuration file that needs to be set up to run the
API. It can be copied from its default template.

```
cd service-js-mongodb
cp .env.defaults .env
emacs .env
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

##Deployment Procedure

###SSL

The iReceptor-Repository does not handle SSL certificates directly, and is
currently configured to run HTTP internally on port 8080. It must be
deployed behind a reverse proxy in order to allow SSL connections.

###Dockerized instances (ir-dev, ir-staging, production)

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
stop instances manually and try it again, 
e.g. ( your container id's will differ...):

```
$ sudo docker ps
CONTAINER ID        IMAGE                        COMMAND                CREATED             STATUS              PORTS                                      NAMES
fdc7c3119366        ireceptorweb_nginx:latest    "/root/nginx-config-   32 minutes ago      Up 32 minutes       0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   irserverweb_nginx_1
adfecbce3e55        ireceptorweb_vdjapi:latest   "/bin/sh -c '/usr/bi   32 minutes ago      Up 32 minutes       8443/tcp                                   irserverweb_irapi_1

sudo docker-compose down ireceptor-repository
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
`

##How to run tests

T.B.A.

##Development Setup

You will need to clone down the parent project and all submodules in order to set up a local instance of ireceptor.

```
- Clone project
$ git clone git@github.com:sfu-ireceptor/turnkey-service.git ireceptor-turnkey-service

cd ireceptor-turnkey-service

- Clone submodules
$ git submodule update --init
$ git submodule foreach git checkout master
$ git submodule foreach git pull

- Follow configuration steps listed above in the "Configuration Procedure" section of this document
```

### Contribution guidelines ###

* Writing tests
* Code review
* Other guidelines

##Development Guidelines

**Code Style**

 * Code should roughly follow Google Javascript Style Guide conventions: <https://google-styleguide.googlecode.com/svn/trunk/javascriptguide.xml>.

 * A jscs.rc file (Javascript Code Style Checker) file has been provided in the project repo, and all developers are encouraged to use it.

 * A git pre-commit hook is available via the file pre-commit.sh. To use it, just symlink it as follows: ```ln -s ../../pre-commit.sh .git/hooks/pre-commit```

 * Spaces are preferred over tabs, and indentation is set at 4 spaces.

 *  Vimrc settings: ```set shiftwidth=4, softtabstop=4, expandtab```
 
**Git Structure and Versioning Process**

 * This project uses the Git Flow methodology for code management and development: <https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow>.

 * New development and features should be done on branches that are cloned from the **develop** branch, and then merged into this branch when completed. Likewise, new release candidates should be branched from **develop**, and then merged into **master** once they have been tested/verified. Once a release branch is ready for production, it should be merged into **master** and tagged appropriately. Every deployment onto production should be tagged following semantic versioning 2.0.0 standards: <http://semver.org/>.

### Who do I talk to? ###

* Maintainer of this project is Dr. Richard Bruskiewich (richard *AT* starinformatics *DOT* com), technical subcontractor to the iReceptor project hosted by Simon Fraser University.
* Principal Investigator of the iReceptor project is Dr. Felix Breden (breden *AT* sfu.ca) of Simon Fraser University 
* The iReceptor development team may also be contacted directly via ireceptor-team *AT* sfu.ca.

