---
date: 2019-05-14
title: "Troubleshooting"
linkTitle: "Troubleshooting"
description: This document is to keep track of general trouble shooting for any AWS related project or service. 
---

## Table of Contents
- [SupportSite](#supportsite)
    * [CPU alert](#cpualert)
    * [Disk space alert](#diskalert)

- [Website](#website)
    * [Bad ips](#badips)


<a name="supportsite"></a>

## Support Site

<a name="cpualert"></a>

#### CPU utilization alarm 

Start receiving CPU alarm status. CPU usage was high or maxing out because of
high volume of activity. This stayed constant and was determined to be because
of a suspecious IP range of activity. The following describes the discovery
process: 

The alarm and alarm activity can be viewed from [AWS alarms](https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#alarm:alarmFilter=ANY)


Log into support.bioconductor.org as ubuntu and navigate to apache logs

```
ssh ubuntu@support.bioconductor.org 
cd /var/log/apache2
```

The file of interest is `other_vhosts_access.log`. This file can be actively
monitored with `tail -f` to see current activity. Retrieve an arbitrary amount
of lines and retrieve the IP address to see if there is activity from a certain
range of addresses with `tail -n 10000 other_vhosts_access.log | cut -d ' ' -f
2|sort |uniq -c`. Check the entries in the log to see what activity is being
performed by any suspecious account. If deemed inappropriate proceed with
blocking the IPs through AWS. In the AWS management console, under `Network &
Content Delivery` choose `VPC` and then choose under `Security`:  `Network
ACLs`.  From here the `Inbound Rules` can be viewed and edited. Add a new Rule
to DENY access, `Rule #` are applied in numerical order until Access is
allowed.  The IP collected from apache logs will need to be converted to CIDR
when entered as a Rule source.  See [CIDR conversion tool](https://www.ipaddressguide.com/cidr).  


<a name="diskalert"></a>

#### Disk Space Alarm

When the EC2 instance runs out of space it needs to be expanded.
See the following documentation [Change root or attached volume](https://github.com/Bioconductor/AWS_management/blob/master/docs/EC2_resize.md#change-root-or-attached-volume)


<a name="website"></a>

## Bioconductor.org

<a name="badips"></a>

#### Suspecious frequent IP 

In the AWS management console, under `Security, Identity, & Compliance` choose
`WAF & Shield`.  There is an item `Bad_IP` which has Rules that can be
set. There is already a Rule started for blocking IPs so add the rouge IP
there. 