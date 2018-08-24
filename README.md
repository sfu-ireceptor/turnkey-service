# Turnkey Package for an iReceptor Data Source Node

[iReceptor](http://ireceptor.org) is a data management system and scientific gateway for mining newly available Next Generation sequence data of Acquired Immunity Receptor Repertoires (AIRR). The iReceptor data management system is designed to be a distributed network of data source nodes implementing a [common iRecgithub markdown headereptor data node Application Programming Interface (API) specificatigithub markdown headeron](https://github.com/sfu-ireceptor/api/tree/master).  Thegithub markdown header iReceptor data management system is expected to become one public reference implementation of a AIRR-compliant data repository.

This repository contains the software package of a "turnkey" package for the installation, configuration and data loading of a small to medium sized iReceptor data source node running a simple database within a single node.

The design of this turnkey is deeply inspired and largely adapted from the excellent VDJServer iReceptor Node package developed by **Scott Christley** of the **VDJServer** project at the **University of Texas Southwestern University**.

Here we give an overview of iReceptor node configuration and operation. It is assumed that you type in these commands and run them within a Linux terminal (the '$' designates the command line prompt... yours may look different!).

## Version

0.0.2

## First Decision: Where and how will you run the iReceptor node?

The following installation instructions assume a Linux operating system as the target operating environment for the iReceptor turnkey. Beyond that, core configuration instructions are applicable for any suitable recent-release Linux system. There are several options for running the turnkey.

The first decision you need to make is where (on what Linux server) to run the application. Your choices generally are:

1) Directly on a Linux "bare metal" server

2) Within a suitably configured Linux Virtual Machine (e.g. VMWare, Parallels, VirtualBox, Amazon Web Services, OpenStack etc.)

    - We use OpenStack internally to provision services (using Compute Canada's OpenStack service). Our internal documentation on setting up an Ubuntu VM within Compute Canada's OpenStack environment is available as [a baseline example](openstack.md) on how to set up a VM. The process will likely vary based on the VM provider and technology you use.

Your choice of Linux operating system is not too critical except that the specific details on how to configure the system may differ between Linux flavors. For the moment, as of November 2017, we are working here with a recent 'latest' release (i.e. 16.04) of Ubuntu server.

## Getting the Software

You will need to git clone this project and all submodules onto your Linux machine in order to set up a local instance of an ireceptor data source node. You need to decide where to clone it. A convenient recommended location for hosting your turnkey code and database is the folder location **/opt/ireceptor** (if you decide otherwise, modify the configuration instructions below to suit your needs).

To start, you need to create your hosting folder location and properly set its access permissions to your user account, i.e.

```
$ sudo mkdir -p /opt/ireceptor

# Substitute your actual Linux group and username for mygroup and myusername below
$ sudo chown mygroup:myusername /opt/ireceptor
```

Next, ensure that you have a recent version of git installed.

```
$ git --version
The program 'git' is currently not installed. You can install it by typing:
sudo apt install git
```

Oops! Better install git first!
```
$ sudo apt install git  # note: some Linux flavors use 'yum' not 'apt' to install software
```

For git cloning of the code, you have two Github access options (see the github doc links provided for configuration details):

1. [Configure, connect and clone the project using SSH](https://help.github.com/articles/connecting-to-github-with-ssh/)
2. [Configure, connect and clone the project using HTTPS](https://help.github.com/articles/cloning-a-repository/)

Once you have configured your selected access option, then you do the following:

```
# First, set your directory to your hosting folder location
cd /opt/ireceptor

# Then, either clone project using SSH or...
$ git clone git@github.com:sfu-ireceptor/turnkey-service.git

# ... clone the projecdt with HTTPS
$ git clone https://github.com/sfu-ireceptor/turnkey-service.git

```

## Configuring the Software

Once you've downloaded the software to your system (using `git clone`), you are now ready to configure it. For this, you have two options:

- ### Configuring using setup.sh

The *setup.sh* script is located in the root directory of the project.

First, change directory into the root and make sure that the script is executable:

```
$ cd turnkey-service
$ chmod 755 setup.sh
```

Next, simply run it and make configuration decisions as requested:

```
$ ./setup.sh
```

It is that simple (we hope)!

- ### Configuring manually

Follow the [classical manual recipe for turnkey configuration instructions](./MANUAL_CONFIGURATION.md).

## Don't Worry... Be Happy

When using a cloud instance, you *may* see a funny error crop up as the first line of output, every time you execute a terminal command, something like:

```
sudo: unable to resolve host <your-local-host-name>
```

This nuisance error of cloud instance misconfiguration may be safely ignored as harmless to the task at hand...

Otherwise, if you want to [resolve this issue](https://askubuntu.com/questions/811098/when-i-run-a-sudo-command-it-says-unable-to-resolve-host), you must find (or set) your `hostname` and insert next line into `/etc/host`:

```
127.0.1.1    <your-hostname>
```
You can find your `hostname` using the following command:

```
cat /etc/hostname
```

## Testing the Turnkey Repository

### Testing Database Access in the Node

Check to see if you have a Mongo container already running:

```
$ sudo docker ps | grep irdn-mongo
ff26aab34970        ireceptor/repository-mongo     "docker-entrypoint..."   28 minutes ago      Up 28 minutes       0.0.0.0:27017->27017/tcp   irdn-mongo
```

- If not, try to **restart** the service as follow:

```
$ sudo systemctl restart ireceptor
```

- To **stop** the service, use:

```
$ sudo systemctl stop ireceptor
```

You can then test access to the Mongo repository using the following command:

```
$ sudo docker exec -it irdn-mongo mongo --authenticationDatabase admin <dbname> -u <serviceAccount> -p <serviceSecret>
```

Where the values for `dbname`, `serviceAccount`, and `serviceSecret` are as you have set them during the previous setup step (e.g. the default value for `dbname` is 'ireceptor').

- In case of doubt, you can always double-check the *dbsetup.js* file inside the *repository-mongodb* directory to confirm what you have configured previously. For example, you can display the contents of that file in the terminal by typing the following in the top-level directory of the project:

```
$ less repository-mongodb/dbsetup.js
```

After successfully accessing the Mongo database, you can then try simple commands like

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

### Testing the iReceptor Web Service

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

This only gives back an empty array `[]` as a result, you say?  

Don't fret. That's because we haven't loaded any data yet!

## Loading Data into the Node

This project directly links into a [dataloader-mongo](https://github.com/sfu-ireceptor/dataloading-mongo) submodule
which is currently under active development and has a README providing details documenting available data loading scripts.

Generally speaking, there is a strict ordering to how data should be loaded:

1. Always first load the 'sample metadata' associated with a study that has generated sequence data, then
2. Load the available sequence annotation. You may load available annotation (of any format, i.e. --imgt, --mixcr  etc) in any order you wish, as long as the associated sample metadata is already loaded first.

Note again that the data loading is a "service" operation hence you should specify the Mongo database credentials of
 the "service" user account - username plus secret - as is specified in dbsetup.js (above).

 Note that the environment variables "MONGODB_SERVICE_USER" and "MONGODB_SERVICE_SECRET" may also be used to set to these values
for convenience in data loading (these are the default credentials read from the environment).

Once you have loaded some 'sample' metadata, you can retry the above curl command to see it. If you continue to load the associated
sequence annotation data, then the full iReceptor application programming interface (API) may be used to query it, for example:

```
$ curl -H 'Content-Type:application/x-www-form-urlencoded'  --data-urlencode 'ir_project_sample_id_list=1' http://localhost:8080/v2/sequences_summary
```

## Managing the software environment

### Docker Compose Files

There are two docker-compose files: one for general use ("docker-compose.yml"), and one that has been adjusted for use in a production environment ("docker-compose.prod-override.yml"). These files are meant to be overlayed and used together in a production environment: https://docs.docker.com/compose/extends/#different-environments

Using the production config will send all log information to syslog.

Example of using the production overlayed config (run from the root project directory):

```
docker-compose -f run/docker-compose.yml -f docker-compose.prod-override.yml build
docker-compose -f run/ocker-compose.yml -f run/docker-compose.prod-override.yml up
```

### Testing

At the moment, aside from the above basic tests noted in the section *Testing the Turnkey Repository* above,
we don't yet have a single formal test suite for testing your node. Your best option for the moment is to review the API docs and compose suitable API calls using your browser. We to plan to review this issue and develop a formal testing protocol for the turnkey, as time and resources permit.

### Updating the project database or service submodules to a specified Git branch

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
git submodule update --recursive
```

The *git pull* command changes the git *commit* to which their submodule directory points.

The *git submodule update --recursive* actually updates all the submodules (recursively in this case) 
with the most up-to-date submodule code branches that the project uses.

Note that after you complete the update of the code tree, you'll need to rebuild your Docker images 
and restart any Docker containers you have running, that is (run from the root project directory):

```
$ sudo docker-compose -f run/docker-compose.yml build
$ sudo systemctl restart ireceptor
```

or the equivalent build with any overlay docker-compose configuration files (see above)

## Contribution guidelines

This project generally follows the 'Git Workflow" in which a 'master' branch and 'develop' branch are formally
maintained but that all all contributions to the project generally need to be offered as pull requests to 'develop'.

Further project guidelies will be presented here as 

- Writing tests - TBA
- Code review - TBA
- Other guidelines - TBA

## Development Guidelines

### Code Style

- Code should roughly follow Google Javascript Style Guide conventions: <https://google-styleguide.googlecode.com/svn/trunk/javascriptguide.xml>.

- A jscs.rc file (Javascript Code Style Checker) file has been provided in the project repo, and all developers are encouraged to use it.

- A git pre-commit hook is available via the file pre-commit.sh. To use it, just symlink it as follows: ```ln -s ../../pre-commit.sh .git/hooks/pre-commit```

- Spaces are preferred over tabs, and indentation is set at 4 spaces.

- Vimrc settings: ```set shiftwidth=4, softtabstop=4, expandtab```

### Git Structure and Versioning Process

- This project uses the Git Flow methodology for code management and development: <https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow>.

- New development and features should be done on branches that are cloned from the **develop** branch, and then merged into this branch when completed. Likewise, new release candidates should be branched from **develop**, and then merged into **master** once they have been tested/verified. Once a release branch is ready for production, it should be merged into **master** and tagged appropriately. Every deployment onto production should be tagged following semantic versioning 2.0.0 standards: <http://semver.org/>.

## Who do I talk to?

- Maintainer of this project is Dr. Richard Bruskiewich (richard *AT* starinformatics *DOT* com), technical subcontractor to the iReceptor project hosted by Simon Fraser University.
- Principal Investigator of the iReceptor project is Dr. Felix Breden (breden *AT* sfu.ca) of Simon Fraser University
- The iReceptor development team may also be contacted directly via support *AT* ireceptor.org.
