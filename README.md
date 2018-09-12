# iReceptor Service Turnkey 

## What is it?
An easy-to-install package containing:
- a database
- a web application exposing that database to the world using the [iReceptor API](https://github.com/sfu-ireceptor/api)
- some command line tools to load data into the database
- some test data


## Installation
Requirements: Ubuntu (tested on 16.04) and a user with sudo permissions.

###
```
# get the source code
git clone https://github.com/sfu-ireceptor/turnkey-service.git

# launch the installation (15 min)
cd turnkey-service
scripts/install.sh 
```


## Check it's working
Query the /v2/samples API entry point to get the list of samples in the database:
```
curl -X POST -H "accept: application/json" -H "Content-Type: application/x-www-form-urlencoded" "http://localhost:8080/v2/samples"
```
This will return an empty array because the database is still empty.
```
[]
```

## Loading data into the database

First load the 'sample metadata' associated with a study that has generated sequence data, then load the available sequence annotation (from imgt, mixcr, etc).

### Example: loading the test data (samples + sequence annotations)
Add some samples:
```
dataloading-mongo/scripts/dataloader.py -v --sample -u admin -p admin -d ireceptor -f dataloading-mongo/data/test/imgt/imgt_sample.csv
```

Check it worked:
```
curl -X POST -H "accept: application/json" -H "Content-Type: application/x-www-form-urlencoded" "http://localhost:8080/v2/samples"
```

Add some sequence annotations (answer yes to the warning, it will then take a few minutes):
```
dataloading-mongo/scripts/dataloader.py -v --imgt -u admin -p admin -d ireceptor -f dataloading-mongo/data/test/imgt/imgt.zip
```

Check it worked:
```
curl -X POST -H "accept: application/json" -H "Content-Type: application/x-www-form-urlencoded" "http://localhost:8080/v2/sequences_summary"
```

### More dataloading options:
```
dataloading-mongo/scripts/dataloader.py  -h
```

## Advanced commands








...





## Software used 
- a [node.js](https://nodejs.org/en/about/) web application reading from a [MongoDB](https://www.mongodb.com/what-is-mongodb) database.
- [Docker](https://www.docker.com/why-docker) containers: nothing will be installed directly on your system, except for Docker itself and a system service to easily start/stop the Docker containers. 
Note: the database data folder and the import tools were installed in /opt/ireceptor




The design of this turnkey is deeply inspired and largely adapted from the excellent VDJServer iReceptor Node package developed by **Scott Christley** of the **VDJServer** project at the **University of Texas Southwestern University**.


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


The design of this turnkey is deeply inspired and largely adapted from the excellent VDJServer iReceptor Node package developed by **Scott Christley** of the **VDJServer** project at the **University of Texas Southwestern University**.
