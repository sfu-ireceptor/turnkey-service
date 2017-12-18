# Using OpenStack to provision a base VM for a Turnkey system #

This document contains a set of very basic instructions for provisioning a basic VM using OpenStack. The iReceptor team uses Compute Canada's OpenStack platforms for deploying services, and we therefore have a basic recipe for provisioning a VM using OpenStack.

Very basic instructions follow:

## Creating an Instance

- In the Instances tab, click on the "Launch Instance" button.
	- In the Details tab
		- Give your instance a name
		- Choose an instance flavour (e.g. on Compute Canada we use c4-15gb-83)
		- Choose a boot source (e.g. on Compute Cananda we "Boot from Image")
		- Choose an image (e.g. on Compute Canada we use Ubuntu so the image we use is something like "Ubuntu-16-04.2-Xenial-x64-2017-07")
	- In the Access and Security tab
		- Choose a key pair to use to log in to the Instace (see the OpenStack documentation on how to manage key pairs)
		- Choose a security group to use (see the OpenStack documentation on how to manage security groups)
			- Your security group will need to allow access on port 80 and port 8080.
	- Click "Launch"

Your instance should now be running.

## Associate an IP

Your VM instance will need a public IP for the outside world to contact your Turnkey iReceptor service.

- For the instance you just created (in the Instances tab of the OpenStack UI), under "Actions", choose "Associate Floating IP". This process may differ depending on your OpenStack provider and how they manage their IPs.
	- Choose a floating IP to assign. If there are no floating IPs available, then you do not have permissions to map floating IPs. Contact your OpenStack administrator to get access to floating IPs.
- In the "Instances Tab" you should now see a Floating IP assigned to your instance (you may have to refresh the page to see the assigned instance).

## Log into your VM

In order to log in to your VM, you will need to configure your SSH client with the SSH key you used to configure your VM instance. By default, the Compute Canada Ubuntu instances create a user account called "ubuntu" that is configured to use the SSH key pair you provided when creating the instance.

Assuming the private key you used for the key pair is called mykey.pem, and the IP number associated with your instance is xxx.xxx.xxx.xxx, the following command would allow you to SSH to your VM instance.

```
ssh -i mykey.pem ubuntu@xxx.xxx.xxx.xxx
```

If your key was created with a passphrase (recommended) then you will be prompted for the passphrase.

## Continue configuring your Turnkey system

At this point, you have a basic VM running Ubuntu for which you can continue the installation process for the Turnkey system.
