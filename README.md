# Deprecated - This repository is no longer used

Please refer to the new Turnkey repository: https://github.com/sfu-ireceptor/turnkey-service-php

# iReceptor Service Turnkey 

A quick and easy way to build your own AIRR-seq repository.

## What is it?
- a database
- a web application exposing that database through the [iReceptor API](https://github.com/sfu-ireceptor/api)
- a script to load data into the database
- some test data


## Installation
Requires Ubuntu (tested on 16.04) and a user with sudo rights. First, get the source code:

```
git clone https://github.com/sfu-ireceptor/turnkey-service.git
```

Then launch the installation, which will take 15 min:
```
cd turnkey-service
scripts/install.sh 
```


#### Check it's working
Query the web application with a POST request at `/v2/samples` to get the list of samples:
```
curl -X POST -H "Content-Type: application/x-www-form-urlencoded" "http://localhost:8080/v2/samples"
```

An empty array is returned because the database is empty.
```
[]
```


## Loading data

#### General procedure
1. load the "sample metadata" associated with a study that has generated sequence data.
2. load the available sequence annotations (from imgt, mixcr, etc).


#### Example: loading the test data

Load the database admin user credentials:
```
source scripts/export.sh
```

Load the samples:
```
dataloading-mongo/scripts/dataloader.py -v --sample -d $MONGODB_DB -u $MONGODB_SERVICE_USER -p $MONGODB_SERVICE_SECRET -f dataloading-mongo/data/test/imgt/imgt_sample.csv
```

Check it worked:
```
curl -X POST -H "Content-Type: application/x-www-form-urlencoded" "http://localhost:8080/v2/samples"
```

Add the sequence annotations (answer yes to the warning, it will then take a few minutes):
```
dataloading-mongo/scripts/dataloader.py -v --imgt -d $MONGODB_DB -u $MONGODB_SERVICE_USER -p $MONGODB_SERVICE_SECRET -f dataloading-mongo/data/test/imgt/imgt.zip
```

Check it worked:
```
curl -X POST -H "Content-Type: application/x-www-form-urlencoded" "http://localhost:8080/v2/sequences_summary"
```

To see all dataloading options:
```
dataloading-mongo/scripts/dataloader.py -h
```


## More information
- [How it works](docs/how_it_works.md)
- [Troubleshooting](docs/troubleshooting.md)

Contact: <support@ireceptor.org>

## Reference
- <http://ireceptor.org>
- [Future improvements](docs/future_improvements.md)
- [Credits](docs/credits.md)
