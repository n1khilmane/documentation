---
title: "Bioconductor hosted AMIs"
linkTitle: "Bioc AMIs"
description: Creating Bioconductor AMIs
---

The new AMIs should be generated immediately following a Bioconductor release.
This ensures the maximum number of packages pass build and check and can be
installed without problem.

## Table of Contents

- [Building the new AMI](#buildAMI)
  - [Set up Chef environment](#setup)
  - [Checkout AMI_cookbook (optional)](#cookbook)
  - [Launch EC2 instance](#ec2)
  - [Run Chef recipe](#run)
  - [Testing](#run)
  - [Security Measures](#security)
  - [Create AMI](#createAMI)
- [Update the web site](#postAMI)

<a name="buildAMI"></a>
## Building the new AMI

<a name="setup"></a>
### Set up Chef environment
In the code below the term 'chefTest' refers to the node to be configured.

- Set up the Chef environment on your local machine (workstation) by going 
  through the 'Learn the Basics' and 'Manage a Node' tutorials at 
  https://learn.chef.io/tutorials/.
  NOTE: In the 'Manage a Node' tutorial, choose 'Hosted Chef' for the Chef
  Server Enviornment.
- The url for our hosted chef server is "https://api.chef.io/organizations/bioconductor".
- A few commands to try once you're set up:
```
knife node list
knife node show chefTest
```

<a name="cookbook"></a>
### Checkout AMI_cookbook (optional)
- Check out a local copy of the cookbook from
  https://github.com/Bioconductor/AMI_cookbook
- The cookbook already exists on the hosted chef server:
```
knife cookbook list
```

  Check the versions and urls in AMI_cookbook/attributes/default.rb.
  If you need to make changes do so locally, bump the version in metadata.rb
  and upload the cookbook to the server:
```
knife cookbook upload AMI_cookbook  ## assumes path
knife cookbook upload AMI_cookbook -o path/to/cookbook ## explicit path
```
  If the changes are permanent, push the updated code to git.


<a name="ec2"></a>
### Launch EC2 instance
Go to the AWS EC2 dashboard: 
  https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#
- Launch a m4.xlarge AWS EC2 instance (4 cores, 16 GB RAM).
- Increase the disk storage to 40 GB. As a baseline, running the recipe
  in version 0.1.11 of the AWS_cookbook requires 19GB of disk space.
  Depending on your application you may want to increase / decrease this value.
- Tag the instance with name: bioc-3.x-ubuntu-18.04-40GB-2019mmdd
- Add security group 'courses' if the instance will be used for
  a course and 'http/s' and 'ssh-open' if it's for general use or testing.
- Select a key pair you have access to.
- Keep the defaults for other configuration options.

<a name="run"></a>
### Run Chef recipe
The AWS EC2 instance (aka node) must first be configured to talk to the chef
server. We need to install the chef client on the node and specify how
the server will connect via ssh (password or key pair). This first 
initialization of the node is called 'bootstrapping'.

In the command below you could add a run list which specifies which recipes
to run. I prefer to do a clean connect first with no run list to ensure a
clean connection between node and server. You need to provide the public IP
of the instance and the key location (syntax is slightly different
when using a password).
```
knife bootstrap 34.207.237.236 --ssh-user ubuntu --sudo --identity-file /home/lori/Documents/lori.pem --node-name chefTest 
```
Confirm the node was associated with the server:
```
knife node list
knife node show chefTest 
```
Add the run list:
```
knife node run_list add chefTest 'recipe[AMI_cookbook::default],role[AMI_devel_linux]'
```
Confirm the run list was added:
```
knife node show chefTest
```

The run list involves a "role". There are several ways to handle 'special
cases' and using roles is one of them. We have roles for release and devel -
each set a variable value on the node which can then be accessed by the
cookbook recipe during run time. Use 'role list' and 'role show' to see the
roles defined on the server. 
```
knife role list
knife role show AMI_devel_linux
```

NOTE: When configuring a release AMI, the run list should specify the
AMI_release_linux role:
```
knife node run_list add chefTest 'recipe[AMI_cookbook::default],role[AMI_release_linux]'
```

Now we are ready to run the recipe on the node. The chef-client executable was
installed on the node during the bootstrap stage and invoking it forces 
execution of the run list.
```
knife ssh 'name:chefTest' 'sudo chef-client' --ssh-user ubuntu --identity-file /home/lori/Documents/lori.pem --attribute cloud.public_ipv4
```
NOTE: With an update to Chef-Client 14.1.1 the `--identify-file` flag
changed to `--ssh-identity-file`. It maybe useful to add the `--verbose` flag
when debugging.

With AMI_cookbook version 0.1.34 running the full recipe takes about two
hours.

<a name="testing"></a>
### Testing / Troubleshooting

- Test RStudio by pasting the IP address in a browser. Login as ubuntu with
  password bioc.

- As of AMI_cookbook version 0.1.34, log files are written to /tmp for
  the installation of software, data experiment and annotation packages.
  These files are temporary but can be useful to troubleshoot the package
  installation procedure when the recipe does not complete successfully.

<a name="security"></a>
### Security Measures 

The AMIs we create will be made public. To avoid exposing sensitive data we 
need to take a few precautions. 

- Remove SSH host key pairs

Remove the existing SSH host key pairs located in /etc/ssh. This forces 
SSH to generate new unique SSH key pairs when a new instances is launched.

We want to remove these key files if present:
```
ssh_host_dsa_key
ssh_host_dsa_key.pub
ssh_host_key
ssh_host_key.pub
ssh_host_rsa_key
ssh_host_rsa_key.pub
ssh_host_ecdsa_key
ssh_host_ecdsa_key.pub
ssh_host_ed25519_key
ssh_host_ed25519_key.pub
```

Remove them by running the following command:

```
sudo shred -u /etc/ssh/*_key /etc/ssh/*_key.pub
```

- Remove root and user SSH keys 

Exclude all user-owned SSH public/private key pairs and SSH authorized_keys 
files. The Amazon AMIs store these in /root/.ssh for the root account, and
/home/user_name/.ssh/ for regular user accounts.

Assuming there is just the one `ubuntu` user on the machine and
all configuration has been done as this user.

As the `ubuntu` user:
```
rm /home/ubuntu/.ssh/authorized_keys
```

Become root and delete keys:
```
sudo su -
rm /home/root/.ssh/authorized_keys
exit
```

- Delete shell history

This should be the last command executed before logging out and
creating the AMI.

```
shred -u ~/.*history
```

<a name="createAMI"></a>
### Create the AMI

Go to the AWS EC2 dashboard:
https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:sort=instanceId
- Select the instance by clicking on the box to the left of the list.

- Under the 'Actions' drop-down go to 'Image' -> 'Create Image'.

- Give the AMI a descriptive name, e.g., bioc-3.x-ubuntu-18.04-40GB-2019mmdd
  and brief description.

- Modify the image permissions to make the AMI public.

AMIs are a regional resource. Making an AMI public (aka sharing) makes 
it available only in that region. To make the AMI available in a different 
region, copy the AMI to the region and then share it. For more information
see

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/CopyingAMIs.html

- Once the AMI is created go to 
  https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:sort=name
  There are 2 name fields, 'Name' and 'AMI Name'. The 'Name' field is usually
  blank - name it something compatible with the other AMIs, e.g., bioc-3.3.

- Terminate the EC2 instance used to make the AMI. 

- Give the snapshot created a useful name 
      We no longer make public for security measure (allows for copying to other regions). 
      If requested look at granting individual access 


<a name="postAMI"></a>
## Posting to the web
Modify the website code:
```
git clone git@github.com:Bioconductor/bioconductor.org.git
cd bioconductor.org
git remote add upstream git@git.bioconductor.org:admin/bioconductor.org
```
- Add the image id to config.yaml
- If a new release, update content/help/bioconductor-cloud-ami.md
