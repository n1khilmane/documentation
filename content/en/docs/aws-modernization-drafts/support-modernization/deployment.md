---
date: 2024-02-13
title: "Biostar deployment dettails"
linkTitle: "Biostar Deployment"
draft: true
description: >
  Details on specific operational information for deploying biostar in the Bioconductor core environment.
---

# AWS Setup

## Sign in to the AWS Management Console
1. Open your web browser and navigate to the [AWS Management Console](https://console.aws.amazon.com/).
2. Sign in using your AWS account credentials.
3. In the search bar at the top, type "EC2". Select "EC2" from the dropdown options.
4. On the EC2 Dashboard, click on the "Launch Instance" button.
5. In the "Choose an Amazon Machine Image (AMI)" page, search for "Ubuntu 22.04".
6. Select the appropriate Ubuntu 22.04 AMI from the list.
7. Scroll through the available instance types and select "t3.medium".
8. Specify the size and type of the instance's root volume. 
9. Define the firewall rules for your instance. Ensure that at least SSH (port 22) and HTTP (port 80) access are enabled. Click on the "Review and Launch" button to proceed.
10. Choose an existing key pair or create a new one for securely connecting to your instance via SSH. Check the acknowledgment box and click on the "Launch Instances" button.


# Installation

## Hosts 

```
   Target Host = Public address of EC2 Instance 
   
```

**Note:** 
- There is no `hosts.ini` file (inventory file) as we have a single target, which can be replaced directly in the Ansible playbook.

- Add the target-host public IP address to all the ansile playbooks 


``` 
---
- hosts: 'Public-IP-Address of Target Machine'
  user: www

  tasks:
    - include_vars: variables.yml

    - name: Check if bash profile already exists
      stat:
        path: ~/.bash_profile
      register: profile_created
      ..
      ..
      ..

```

- Ensure you have an Ansible playbook prepared for deploying the application.


## Run Ansible Playbooks

- Use the following command to execute the Ansible playbook:
  
  ```bash
  ansible-playbook -i '<target-machine-ip>,' --private-key <path/to/private/key> <path/to/ansible-playbook.yml> --extra-vars "repo=https://github.com/ialbert/biostar-central.git username=ubuntu branch=master"

- Replace <target-machine-ip> with the public IP address of your EC2 instance.
- Replace <path/to/private/key> with the path to your SSH private key.
- Replace <path/to/ansible-playbook.yml> with the path to your Ansible playbook.
```

```

Example:

ansible-playbook -i '100.26.149.52,' --private-key ~/.ssh/key.pem ansible/server-setup.yml --extra-vars "repo=https://github.com/ialbert/biostar-central.git username=ubuntu branch=master"

```

