# Turnkey Package for an iReceptor Data Source Node #

iReceptor is a distributed data management system and scientific gateway for mining “Next Generation” sequence data from immune responses.  

## What is this repository for? ##

* This project is the source code of a "turnkey" package for the installation, configuration and data loading of a small to medium sized iReceptor data source node.
* Version 1.0.0

## Overview of Installation ##

The turnkey package is designed using a layered technology stack to facilitate deployment but also, provide some flexibility.  This iReceptor data source node (as of June 2017) is a PHP REST web services application running on top of a relational (entity-relationship) data model implemented in a recent release of the MySQL relational database platform.  The node is designed to work within a Ubuntu (Debian) Linux server environment. To facilitate deployment on diverse host operating systems, a Vagrant virtual machine file configuration is provided; however, if you already have a server running Ubuntu directly, you can deploy directly there (without Vagrant).

## Step 1 - Configure the Web Server for your Node ##

### Option 1 - Using Vagrant ###

If you are wanting to host your iReceptor node on a non-Linux machine (e.g. Windows or Mac), then you'll have to do more work.

First, you'll need to install a '[virtualization provider](https://www.vagrantup.com/intro/getting-started/providers.html)' for Vagrant. Some of the options are:

* [Virtual Box](https://www.virtualbox.org/wiki/Downloads) - free VM platform for many operating systems
* [Parallels](http://www.parallels.com) or [VMWare Fusion](https://www.vmware.com/products/fusion/overview.html) - Apple Mac-based VM platforms
* [VMWare Workstation](https://www.vmware.com/products/workstation.html) - commercial VM platform available for both Microsoft Windows or Linux
* [Docker](https://www.docker.com/) - runs your server as a Docker container.

Second, you'll need to install [Download Vagrant](http://www.vagrantup.com/downloads.html) and follow its installation instructions. The latest version of Vagrant should be installed (version 1.8.6 or more better).

Third, you need to tell Vagrant about your provider. This generally requires that you [install and configure the appropriate Vagrant plug-in](https://www.vagrantup.com/docs/providers/).  Note that some Vagrant plug-ins (i.e. the VMWare version) must be purchased. 

Once installed, you can [specify set your chosen provider as the default one](https://www.vagrantup.com/docs/providers/default.html) using the VAGRANT_DEFAULT_PROVIDER environment variable (unless you are using VirtualBox, which is the out-of-the-box Vagrant default provider). To find out the names of your available providers, type

	vagrant plugin list

Generally remove the 'vagrant-' prefix to the plugin name and change the hyphen to an underscore, to get the name of the provider to use as the value of the VAGRANT_DEFAULT_PROVIDER variable. For example,
 
	vagrant-vmware-workstation
 
 becomes
	
	vmware_workstation
	
For Linux and Mac OSX, you will also need to install the vagrant-bindfs plugin by running the following command: 

	vagrant plugin install vagrant-bindfs

This is used for shared folder management using NFS under those Unix-like operating systems.

### Option 2 - Ubuntu Direct ###

Got a dedicated server or virtual machine already running a recent Ubuntu version? If so, kindly review the docs/CONFIGURATION_README.md file in this project - which documents how the configuration that was compiled for the Option 1 - Vagrant installation - for some indication how you need to configure the server. Please note that we don't provide a canned solution for direct server configuration (in contrast to Option 1) but if you have access to experienced systems administrative expertise, you should be able to figure the configuration out.

## Step 2 - Starting Up the Server ##

At this point, you need to start up a command line terminal with "administrative" privileges. 

Note that for Microsoft Windows, this generally means running the Windows PowerShell "as Administrator". Also (strangely enough, especially under Windows 10) you will likely need to give your local user account name, but your Windows "cloud" password, associated with your account, to the system during boot up (as prompted) so the guest system can mount shared folders.

Assuming that you've properly installed Vagrant with a suitable provider, and pointed Vagrant to your default provider, you can navigate into the project directory, then type:

	vagrant up

to start your server for the first time. You can log into the server using:

	vagrant ssh

Under Windows, you may not have Unix-like ssh. However, the vagrant ssh command will tell you what credentials to use, and you can plug these directly into a Windows ssh client like Putty, to access the image.

You should also now also see a default web page visible at http://localhost:9090. This instructs you to configure your virtual host...

### Configuring the Virtual Host ###

On OSX and Linux, this is configured at /etc/hosts, on Windows it is configured at C:\Windows\System32\drivers\etc\hosts.
 
Add a line with the IP address of this server and all vhosts you chose. For example, if the IP address is 192.168.56.113, and you chose vhost 'ireceptor_service.dev', you will want to enter the following:

	192.168.56.113 ireceptor_service.dev

If you forgot the IP address you chose, check the config file at puphpet/config.yaml. 

## Step 3 - Building the iReceptor Site ##

### Project Database ###

MySQL provisioned via vagrant is set up with a user 'root' with password '!mmun010gy'. This can be changed in the config.yaml file under the 'puphpet' project folder. 





* Configuration
* Dependencies: 
* Database configuration
* How to run tests
* Deployment instructions

### Contribution guidelines ###

* Writing tests
* Code review
* Other guidelines

### Who do I talk to? ###

* Principal Investigator of the iReceptor project is Dr. Felix Breden (breden *AT* sfu.ca) of Simon Fraser University 
* The iReceptor development team may also be contacted directly via ireceptor-team *AT* sfu.ca.