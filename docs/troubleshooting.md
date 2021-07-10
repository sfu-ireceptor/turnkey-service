# Troubleshooting

## Starting and stopping the ireceptor system service
```
sudo systemctl start ireceptor
sudo systemctl stop ireceptor
```

## Checking if the Docker containers are running
```
sudo docker ps
```
will return:
```
CONTAINER ID        IMAGE                          COMMAND                  CREATED             STATUS              PORTS                      NAMES
7bd5da46b2a6        ireceptor/repository-mongo     "docker-entrypoint.s…"   59 seconds ago      Up 59 seconds       0.0.0.0:27017->27017/tcp   irdn-mongo
469743631ac3        ireceptor/service-js-mongodb   "node --harmony /ser…"   59 seconds ago      Up 58 seconds       0.0.0.0:8080->8080/tcp     irdn-api
```

`irdn-mongo` is the Docker container for the database, `irdn-api` is the one for the web application.

## Logging into the Docker containers

```
# log as root into the database container
sudo docker exec -t -i irdn-mongo /bin/bash

# log as root into the web application container
sudo docker exec -t -i irdn-api /bin/bash
```
More generally, `docker exec -t -i <container name> <command>` executes a given command in the given container.

## Logging into the MongoDB database as an admin user

```
# load the admin user credentials
source scripts/export.sh

# launch a mongo client using these credentials
sudo docker exec -it irdn-mongo mongo --authenticationDatabase admin $MONGODB_DB -u $MONGODB_SERVICE_USER -p $MONGODB_SERVICE_SECRET
```

You can then execute standard MongoDB commands:
```
// switch to the "ireceptor" database
use ireceptor

// show sampless
db.sample.find()

// show sequence annotations
db.sequence.find()
```

For more, see the [MongoDB documentation](https://docs.mongodb.com/manual/tutorial/query-documents/)

## View the database log
MongoDB logs to the standard output of the Docker container, which can be accessed with:
```
sudo docker logs irdn-mongo
```

## View the web application log
node.js logs to the standard output of the Docker container, which can be accessed with:
```
sudo docker logs irdn-api
```

## Other useful information
- the database data folder and the import tools were installed in `/opt/ireceptor`







