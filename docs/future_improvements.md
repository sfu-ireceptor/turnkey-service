# Future improvements

## Should be simple
- start ireceptor service on startup
- add doc to reset database
- add simpler command to load data (without having to manually load db user credentials)
- add number prefix to install scripts to make the install process clearer
- allow connection to MongoDB only from locally and the other Docker container. It's accessible from outside at the moment.. Should be achievable with custom MongoDB config file when creating Docker image. 
- fix install script so it can be run multiple times. At the moment it fails if Docker containers are already running. It probably should stop them, and rebuild the images.

## Less simple
- install dataloading packages in database Docker image
- add easy way to change database users credentials
- make it work on centos
- monitor containers and restart if any crashes (use supervisor?)
- remove git submodules, get dependencies explicitly
- have database credentials in only one file



