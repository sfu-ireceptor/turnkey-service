# Troubleshooting


Note: the database data folder and the import tools were installed in /opt/ireceptor







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