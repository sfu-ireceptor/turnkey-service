

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