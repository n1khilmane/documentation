---
date: 2021-02-23
title: "Amazon SNS, SQS and SES"
linkTitle: "SNS, SQS, SES"
description: This document describes the Amazon Simple Notification Service (SNS), Simple Queue Service (SQS) and Simple Email Service (SES) used in our account as of March 2018.
---


## Table of Contents
- [Overview](#overview)
- [Simple Notification Service (SNS)](#sns)
  - [Active Topics](#sns-active)
- [Simple Email Service (SES)](#ses)
  - [Active Domains](#ses-active)
  - [Monitoring](#ses-monitoring)
- [Simple Queue Service (SQS)](#sqs)
  - [Active Queues](#sqs-active)

<a name="overview"></a>
## Overview

Amazon SNS and SQS are both messaging services within AWS. SNS allows
applications to send messages to multiple subscribers through a "push"
mechanism which eliminates the need to check or "poll" for updates.
SQS is a message queue service used by distributed applications to exchange
messages through a polling model. SQS provides flexibility for distributed
components of applications to send and receive messages without requiring each
component to be concurrently available.

Amazon SES is an email platform that allows the sending and receiving of
email using our own email addresses and domains. 

<a name="sns"></a>
## Simple Notification Service

https://console.aws.amazon.com/sns/v2/home?region=us-east-1#/topics

<a name="sns-active"></a>
### Active Topics 

* Cloud Watch alarms

  We use the following topics to send notification emails when the EC2
  instances enter alarm state. It's not required to create an SNS topic
  to send alarm messages but it is a convenient way to group team members
  for notification purposes.

  - machine-status
  - machine-status-* 

* Mail sent from SES domain `bioconductor.org`

  These topics are used to monitor mail sent from the `bioconductor.org`
  domain in SES (aka 'subscribed' to the SES domain).

  - bioc-delivery
  - bioc-org-bounces

  Sending statistics for these topics can be monitored via the console:

  https://console.aws.amazon.com/ses/home?region=us-east-1#dashboard:

  By default, these topics do not have an endpoint (i.e., specific email or
  http/s). When there is a need to monitor individual messages an endpoint 
  can be configured at which point all messages are sent to the endpoint. 
  Because of the large volume of messages this should be done with caution
  and for a short period of time.

  Endpoints can be configured here:

  https://console.aws.amazon.com/sns/v2/home?region=us-east-1#/topics

* New workflow projects

  When a new workflow project is created a message is published to this
  topic by docbuilder.bioconductor.org.

  - docbuilder-notifications

  Code that puts a message in the queue is in app.rb here:

  https://hedgehog.fhcrc.org/bioconductor/trunk/bioC/admin/build/docbuilder/app/

  The code logs into AWS as the 
  The IAM user `docbuildernotifier` has an inline policy that gives it
  access to the queue.

<a name="ses"></a>
## Simple Email Service

https://console.aws.amazon.com/ses/home?region=us-east-1#verified-senders-domain:

<a name="ses-active"></a>
### Active Domains 

  AWS SES is configured to send mail from the `bioconductor.org` domain. This
  service is used by staging.bioconductor.org, git.bioconductor.org,
  docbuilder.bioconductor.org, issues.bioconductor.org and the malbec 
  (Linux master build) machines. There may be others I'm currently unaware 
  of ...
 
  Different credentials are required depending on how the service interacts
  with AWS SES. AWS access keys are used when email is sent using the SES API
  and SMTP credentials are used when sending email using the SES SMTP interface. 
  While all users are listed in the IAM interface, the SMTP interface requires a 
  special reset as authentication is not controlled by access keys (even tho the
  authentication appears in the console as access keys). If rotating authentication, 
  a new user will be created (the old should be deleted) with new authentication 
  credentials by going to the following: 
  https://console.aws.amazon.com/ses/home?region=us-east-1#smtp-settings:
  
  The current users that is set this way with authentication credentials is 
  ses-smtp-email-sender
 
  https://console.aws.amazon.com/iam/home?region=us-east-1#/users/ses-smtp-email-sender

* `biostars` on `support.bioconductor.org`

  biostars sends messages to your email from `noreply@bioconductor.org`.
  Configuration for AWS SES can be seen by logging into support.bioconductor.org
  and changing to the www-data user. Details are in site_secrets.py located at
 
  (biostarsenv)www@support:~/biostar-central (master)$ 
 
  The IAM user associated with the smtp credentials is currently ses-smtp-email-sender
 
  https://console.aws.amazon.com/iam/home?region=us-east-1#/users/ses-smtp-email-sender

  If updated the support site server will need to be restarted. You can test the email 
  authentication is correct before going live by 
  1. update the credentials in biostars/run/conf
  2. activate the engine `conda activate engine`
  3. run `python manage.py test_email --to lori.shepherd@roswellpark.org --settings conf.run.site_settings`
  4. If successful, restart server `sudo supervisorctl restart engine`

* `gitapp` on `git.bioconductor.org`

  The gitapp django webapp running as the gitadmin user sends mail from
  maintainer@bioconductor.org when a user authenticates
  for the first time. See the
  `git_credentials` repo for mail configuration details:
 
  https://github.com/Bioconductor/git_credentials

  One is found in the gitadmin user account at `gitapp/settings`. 
  This is not linked to the credentials on AWS.  
  
  However the credentials for postfix email do use ses-smtp-email-sender. 
  See above for how to reset this authentication key

  https://console.aws.amazon.com/iam/home?region=us-east-1#/users/ses-smtp-email-sender

  It is found at `/etc/postfix/`
  You will need to regenerate the db with `sudo postmap /etc/postfix/sasl_passwd`

* malbec*.bioconductor.org Linux builders

  Every week we send notifications from maintainer@bioconductor.org
  to maintainers of broken packages in release.
 
  Configuration details are directly on the builders in a hidden top level directory.

  The IAM user associated with the smtp credentials is currently ses-smtp-email-sender. 
  See above for how to reset this authentication key

  https://console.aws.amazon.com/iam/home?region=us-east-1#/users/ses-smtp-email-sender


* issues.bioconductor.org

  Email is sent from bioc-github-noreply@bioconductor.org to communicate
  package status (accepted, declined, etc.). 

  https://github.com/Bioconductor/issue_tracker_github/blob/d7c1eaaedfd191165d124da585fc527a18597380/core.rb

  The credentials for mail are controlled through the data bag and are associated with the IAM user `sdk-email`.    
  
  https://github.com/Bioconductor/issue_tracker_github/blob/master/NOTES.md#updating-data-bags   
  https://console.aws.amazon.com/iam/home?region=us-east-1#/users/sdk-email
  
  Note: this user uses a different protocol than the stmp user. It cannot be consolidated. 
  This user uses access key and secret access key rather the stmp authentication keys. 
  
<a name="ses-monitoring"></a>
### Monitoring

  The AWS SES is configured to send bounce and delivery notifications to the
  SNS topics 'bioc-org-bounces' and 'bioc-delivery'. Messages sent through 
  SES are tallied and monitored on the 'Sending Statistics' SES page:
 
  https://console.aws.amazon.com/ses/home?region=us-east-1#dashboard:
 
  At present, these SNS topics do not have endpoints so the messages are not
  sent anywhere.  To inspect individual messages in the 'bioc-org-bounces' or
  'bioc-delivery' topics you can subscribe these to an endpoint (i.e., your
  email). 
 
  Go to 
 
  https://console.aws.amazon.com/sns/v2/home?region=us-east-1#/topics
 
  and configure the topics to send to an endpoint where you can monitor them.  A
  large volume of messages pass through these topics so you'll only want to
  enable these endpoints for a short period of time.


<a name="sqs"></a>
## Simple Queue Service

https://console.aws.amazon.com/sqs/home?region=us-east-1

<a name="sqs-active"></a>
### Active Queues 

* Single Package Builder

  The following queues are part of the spb_queuers policy but I'm not
  sure the policy is in use.

  - builderevents
  - builderevents_dev
  - buildjobs
  - buildjobs_dev

* Workflow builder

  This queue stores messages for completed workflow builds:

  - buildcomplete

  Details are in the notify-build-complete.rb script. A message is put
  in the queue as the IAM user `docbuildernotifier` 
  when a workflow builds successfully.

  https://hedgehog.fhcrc.org/bioconductor/trunk/bioC/admin/build/docbuilder/builder-scripts/notify-build-complete.rb

  The bioconductor.org/scripts/check-workflow-updates.rb script runs on
  staging.bioconductor.org and polls the queue for new messages.

* Dead queue?

  Not sure this queue is used anymore ...

  - packagesubmitted
