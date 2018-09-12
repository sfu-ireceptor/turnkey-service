# iReceptor Service Turnkey 

Build your own AIRR-seq repository. Then we will add it to the [iReceptor gateway](https://gateway.ireceptor.org/).

## What is it?
An easy-to-install package containing:
- a database
- a web application exposing that database using the [iReceptor API](https://github.com/sfu-ireceptor/api)
- a script to load data into the database
- some test data


## Installation
Requires Ubuntu (tested on 16.04) and a user with sudo permissions. First, get the source code:

```
git clone https://github.com/sfu-ireceptor/turnkey-service.git
```

Then launch the installation (15 min):
```
cd turnkey-service
scripts/install.sh 
```


#### Check it's working
Query the web application for /v2/samples to get the list of samples:
```
curl -X POST -H "Content-Type: application/x-www-form-urlencoded" "http://localhost:8080/v2/samples"
```

This will return an empty array because the database is currently empty.
```
[]
```


## Loading data into the database

#### Procedure
1. load the "sample metadata" associated with a study that has generated sequence data.
2. load the available sequence annotations (from imgt, mixcr, etc).


#### Example: loading the test data
Load the samples:
```
dataloading-mongo/scripts/dataloader.py -v --sample -u admin -p admin -d ireceptor -f dataloading-mongo/data/test/imgt/imgt_sample.csv
```

Check it worked:
```
curl -X POST -H "Content-Type: application/x-www-form-urlencoded" "http://localhost:8080/v2/samples"
```

Add the sequence annotations (answer yes to the warning, it will then take a few minutes):
```
dataloading-mongo/scripts/dataloader.py -v --imgt -u admin -p admin -d ireceptor -f dataloading-mongo/data/test/imgt/imgt.zip
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


## Reference
- [iReceptor official page](http://ireceptor.org)
- [Future improvements](docs/future_improvements.md)
- [Credits](docs/credits.md)
