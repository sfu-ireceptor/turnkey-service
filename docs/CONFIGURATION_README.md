## iReceptor Server Configuration ##

The Vagrant configuration here used in this project was facilitated by an online tool called [PuPuppet](https://puphpet.com/). 

If you choose to manually configure your server (not using Vagrant), you can be guided by this PuPuppet/Vagrant recipe.

Here are the recommended parameters for the configuration using PuPuppet (web site accessed June 26, 2017).

##Deploy to Local Host##

* **Provider:** pick your chosen provider from the list: VirtualBox, VMWare Fusion, VMWare Workstation or Parallels
* **Distro:** pick your distro of Ubuntu (we like and assume here: Ubuntu Xenial 16.04 LTS x64)
* **Hostname:** ireceptorservice
* **IP Address:** 192.168.56.113 (or whatever you wish to have as IP)
* **Memory:** 512 (probably okay for now)
* **CPUs:** 1 (probably okay for now)
* **Add a forwarded port:** 9090-> 80
* **Shared Folders:** set to a platform-appropriate version, i.e. NFS for Linux or OSX; SMB (CIFS) for Windows, etc.

Note that for SMB/CIFS, you probably need to provide your "local" system user name but the Windows ("Cloud") account password associated with your account, for the mounting of shared hard drives to properly work.

##System Packages##

	vim, htop, subversion 
	
##Users and Groups##

Leave empty(?)

##Locale/Timezone##

Ignore (or change to suit).

##Firewall Rules##

Ignore (or change to suit).

##Resolve##

Ignore (or change to suit your site).

##CronJobs##

Ignore.

##Custom Files##

Ignore.

##Web Server → Install NGINX##

Uncheck the checkbox (to disable) unless you wish to use NGINX instead of Apache (on your own...but use the Apache settings noted below)

##Web Server → Apache##

* Check "Install Apache"
* **Server Name:** ireceptor-service.dev (server aliases blank or optionally set to something)
* **Document Root:** /var/www/ireceptor_service/public

###Virtual host directories###

* **Path:** /var/www/ireceptor_service/public
Everything else left to default values

##Let's Encrypt##

Ignore.

##PHP##

* Install Composer
* **PHP Modules:** add mysqlnd and curl

##Ruby##

Ignore.

##Python##

Ignore.

##Node.js##

Ignore (checkbox unchecked)

##MariaDb Database##

Uncheck "Install MariaDb" (or use it instead of MySQL?)

##Databases → MySQL##

Check "Install MySQL", then set the following:

* Set a root password as desired (remember it!)
* Name and set a path to your database; add parameters as desired, e.g. database name and path)

##PostgreSQL Database##

Uncheck "Install PostgreSQL" (or use it instead of MySQL?)

##MongoDB Database##

Uncheck "Install MongoDb" (or use it instead of MySQL?)

##Redis Database##

Uncheck "Install Redis" (or use it instead of MySQL?)

##SQLlite Database##

Uncheck "Install SQLlite" (or use it instead of MySQL?)

##Mailog Database##

Leave blank.

##Beanstalkd##

Uncheck "Install Beanstalkd" 

##RabbitMQ##

Uncheck "Install RabbitMQ" 

##ElasticSearch##

Uncheck "Install ElasticSearch" 

##Apache SOLR##

Uncheck "Install Apache SOLR" 

##Download the Custom Configuration##

With the above PuPuppet configuration complete, we downloaded and extracted the PuPuppet.zip file archive. The archive actually has a strangely named subdirectory which contains the VagrantFile. We copied the contents (VagrantFile, .git* and pupuppet folder) of the subdirectory into the root folder of the project, merging the contents of the .gitignore file along the way.
