---
title: "Resizing EC2 instances"
linkTitle: "Resizing instances"
description: This document describes the steps in resizing an EC2 instance.
---
## Table of Contents
- [Overview](#overview)
- [Change Instance Type](#changeinstance)
- [Change Root or Attached Volume](#changevolume)

<a name="overview"></a>
## Overview 

There are two aspects to keep in mind when considering an EC2 instance resize:
instance type and back-end storage. The instance type defines the available CPU
and RAM while disk space is defined by the back-end storage.

Through the CloudWatch interface you can view usage graphs for CPI, memory
and disk space (and much more). 

<a name="changeinstance"></a>
## Change Instance Type

AWS instances exactly double (or half) as you move up (or down)
within a family. For example, a t2.small has half the cpu and memory
of a t2.medium, the t2.medium has half of what a t2.large has and
so on. Before you shrink an instance make sure the current memory
use is less than 50%. CPU usage can be above 50% as taxing this will
slow down a process but (in general) should not crash the machine.

Changing the instance type does not affect the back-end storage. If you
want to reduce the root or attached volume size that needs to be done
in a separate step.

- Confirm you have a current snapshot or AMI of the instance to be
  modified.
- Announce downtime.
- Follow instructions at 

http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-resize.html
- Monitor the CloudWatch metrics to confirm the new CPU and memory
  allocations are appropriate.

<a name="changevolume"></a>
## Change Root or Attached Volume 

The following documentation from AWS can be helpful

  - [Modify Volume](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-modify-volume.html)
  
The most common operation will be  Modifying an EBS Volume Using Elastic Volumes (Console) 
to increase the volume size. You can always create an image from the current EC2 instance, 
create an AMI, and then relaunch choosing additional storage space. This can get messy and has
intermediates that need to be cleaned up so it is not ideal.  The follow based off the link
above modifies the existing EC2 instance directly. 

  - Always create a snapshot before modifying the image 
      * Under elastic block store, go to the snapshot console
      * choose `Create snapshot`
      * Select the volumn that is going to be changed and give a good description
      * wait for that to complete before proceeding with changes
  - Modify the volumn as described [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/requesting-ebs-volume-modifications.html#elastic-volumes-limitations)
      * Choose Volumes under elastic block store, select the volume to modify, and then choose Actions, Modify Volume
      * Monitor the volume update, the status will be optimizing (the docs say it can take up to 24 hours to optimize)
      * After the update is done, the status should switch base to in-use/complete
   - After the change, the EC2 instance still needs to [recognize the extended volume](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/recognize-expanded-volume-linux.html)
      * The following code chunk is what we have run before.  Please do similar based on needs or refer to above documentation if a different storage type

This was an example of expanding from 30G to 60G 
```
df -h         # only 30 Gb partition
sudo file -s /dev/xvda*  # partition 1 is 'ext4'
lsblk                                 # partition 1 is 30G
sudo growpart /dev/xvda 1  # grow entire mount point (/dev/xvda) partition 1
lsblk              # yay, 60G partition
df -h              # but only 30G available the file system
sudo resize2fs /dev/xvda1 # resize partition
df -h              # yay, 60G available to the file system
```
