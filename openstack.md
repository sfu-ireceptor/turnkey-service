# Using OpenStack to provision a Turnkey system #

This document contains a set of very basic instructions for provisioning a basic VM using OpenStack. The iReceptor team uses Compute Canada's OpenStack platforms for deploying services, and we therefore have a basic recipe for provisioning a VM using OpenStack.

Very basic instructions follow:

## Creating an Instance

- In the Instances tab, click on the "Launch Instance" button.
-- In the details tab
--- Give your instance a name
--- Choose an instance flavour (e.g. on Compute Canada we use c4-15gb-83)
--- Choose a boot source (e.g. on Compute Cananda we "Boot from Image")
--- Choose an image (e.g. on Compute Canada we use Ubuntu so the image we use is something like "Ubuntu-16-04.2-Xenial-x64-2017-07")
-- In the Access and Security tab
--- Choose a key pair to use to log in to the Instace (see the OpenStack documentation on how to manage key pairs)
--- Choose a security group to use (see the OpenStack documentation on how to manage security groups)
---- Your security group will need to allow access on port 80 and port 8080.
-- Click "Launch"


