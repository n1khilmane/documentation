---
title: "EC2 Backups"
linkTitle: "EC2 Backups"
description: This document describes the backup schedule and procedure for the the Bioconductor productio EC2 instances in AWS region `us-east-1`
---

## Table of Contents
- [Overview and Costs of EBS Automated Snapshot Scheduler](#overview)
- [Implementing EBS Automated Snapshot Scheduler](#implement)
- [Backup Schedule](#backup)
- [TODO](#todo)

<a name="overview"></a>
## Overview and Costs of EBS Automated Snapshot Scheduler 

* Overview of snapshot process:
http://docs.aws.amazon.com/solutions/latest/ebs-snapshot-scheduler/architecture.html

* Cost of running EBS Automated Snapshot Scheduler

    http://docs.aws.amazon.com/solutions/latest/ebs-snapshot-scheduler/overview.html

* Cost of storing incremental snapshots in S3

    https://forums.aws.amazon.com/thread.jspa?threadID=169566

<a name="implement"></a>
## Implementing the EBS Automated Snapshot Scheduler 

* Create a stack: 

  A stack is a collection of resources managed as
  a single unit. Resources in a stack are defined by a CloudFormation template.
  The template we use for the Automated Snapshot Scheduler (as of April
  2017) is called ebs-snapshot-scheduler.template. The default configuration
  deploys AWS Lambda functions, an Amazon DynamoDB table, and an Amazon 
  CloudWatch event.

  When a stack is launched with this template, the EBS Snapshot Scheduler is
  deployed in AWS Lambda and related components are configured. AWS Lambda
  is a service that runs code in response to events.

* Create service role and add role to stack: (optional)
    TBD: Not currently doing this

* Add tags to EC2 instances:

  Enable snapshots on an EC2 instance by adding a tag with the same
  name as 'Custom Name' in the stack.


<a name="backup"></a>
## Backup Schedule 

Things to keep in mind:
- Incremental backups of rapidly changing data are costly
- No need to back up large data that can be easily regenerated
- The current version of the EBS Snapshot Scheduler allows weekly schedules
  but not biweekly or monthly intervals. Such frequent snapshots aren't
  necessary for machines that aren't up 24-7 or those that change only
  at release time. For those we'll do a manual backup, either AMI
  or snapshot, after the release. AMIs are better for windows instances
  because (currently) an AMI can't be made from a snapshot of a windows
  volume.
 
  The format of snapshot column is 
 
  _time taken_;_days retained_;_time zone_;_day of the week_.


EC2 instance    | Size (GiB) | Incremental snapshots | Manual backup (post-release)
--------------- | ---------- | -------------------------------------- | ----------------------------
master          | 2500 | 2330;15;US/Eastern;fri                 | none 
staging         | 70 | 2330;15;US/Eastern;fri                 | none 
git             | 500 | 2330;15;US/Eastern;all                 | none 
annotationhub   | 20 | 2330;15;US/Eastern;all                 | none 
support         | 30 | 2330;15;US/Eastern;fri                 | none
delivery        | 100 | 2330;15;US/Eastern;fri         | none
stats           | 200 | 2330;15;US/Eastern;fri         | none
issues          | 20 | 2330;8;US/Eastern;mon,wed,fri                 | none 
rabbitmq        | 8 | 2330;15;US/Eastern;fri                  | none
val_annotations | 220 | none                                   | snapshot
courses         | 8 | none                                   | snapshot


<a name="todo"></a>
## TODO

We have some form of back-ups in these S3 buckets. Most are redundant with the
automated snapshots and should probably be removed.

* annotationhub-database-backups:
  Daily dump of annotationhub metadata sqlite file. Bucket has 180 day
  expiration lifecycle rule.

* experimenthub-database-backups:
  Daily dump of annotationhub metadata sqlite file. Bucket has 180 day
  expiration lifecycle rule.

* bioc-support-site-backups:
  Daily dump of biostars. Bucket has 180 day expiration lifecycle rule.

* bioc-web-site-backups:
  Daily sync of all data in /extra/www/bioc.
