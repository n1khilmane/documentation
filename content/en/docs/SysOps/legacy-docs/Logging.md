---
date: 2018-08-07
title: "Logging in AWS"
linkTitle: "Logging"
description: This document describes logging procedures for key applications running on our EC2 instances and a few other AWS services. This is a work in progress ...

---

## Table of Contents
- [AnnotationHub](#annotationhub)
  - [Server code](#ahservercode)
  - [S3 bucket: annotationhub-logging](#ahs3logging)
  - [RDS instance: bioc-mysql-instance](#ahrdslogging)
- [ExperimentHub](#experimenthub)
  - [Server code](#ehservercode)
  - [S3 bucket: experimenthub-logging](#ehs3logging)
  - [RDS instance: bioc-mysql-instance](#ehrdslogging)
- [CloudFront](#cloudfront)
- [CloudWatch](#cloudwatch)
<a name="annotationhub"></a>
## AnnotationHub

When AnnotationHub first started all resources were stored in S3 buckets.  When
a new bucket is created, AWS provides the option to create another bucket that
logs all access to it. This made sense for the original set-up and is why and
S3 log bucket was created. Eventually resources were hosted outside S3 on
public web sites and requests are now redirected to a number of places. These
non-S3 requests could not be captured via the S3 logging mechanism so an AWS
RDS db instance was created. This is how we ended up with logs in two
places, both in S3 buckets and the RDS database.

<a name="ahservercode"></a>
### Server code

Code that runs on annotationhub.bioconductor.org and defines AnnotationHub
server behavior:

https://github.com/Bioconductor/AnnotationHubServer3.0

<a name="ahs3logging"></a>
### S3 bucket: annotationhub-logging

https://s3.console.aws.amazon.com/s3/buckets/annotationhub-logging/?region=us-east-1&tab=overview

Logs in the annotationhub-logging S3 bucket record all requests for the
resources stored in the annotationhub S3 bucket (GET, PUT, DELETE, etc.).
There is no expiration lifecycle rule on this bucket and there shouldn't be. We
want the ability to process all logs since inception to get an idea of use
over time.

<a name="ahrdslogging"></a>
### RDS instance: bioc-mysql-instance

AWS RDS is a service that provides databases. You can't ssh to these, only
use them as a database.

AnnotationHub uses a database called "ahs_logging" on the bioc-mysql-instance:

https://console.aws.amazon.com/rds/home?region=us-east-1#dbinstances:

If the endpoint of this RDS instance changes, it must be updated in the 
config file of the AnnotationHubServe3.0 code on 
annotationhub.bioconductor.org:

    ssh ubuntu@annotationhub.bioconductor.org
    cd AnnotationHubServer3.0
    vim config.yml

### Viewing the logs

The read_s3_logs.rb script digests logs in the annotationhub-logging S3
bucket and puts the information in the ahs_logging database on
the bioc-mysql-instance. After running the script, all log data should be
in a single place, in the database on the RDS instance.

Invoke the script
- Log on annotationhub.bioconductor.org as user ubuntu
- Invoke the log processing script:

    /home/ubuntu/AnnotationHubServer3.0/read_s3_logs.rb

  You'll see this output as the script processes the logs:

      ubuntu@ip-10-114-230-116:~/AnnotationHubServer3.0$ ruby read_s3_logs.rb 
      0
      100
      200
      300
      400
      ...

  This script does not run regularly (via cron) so it should be run
  before you analyze the logs. It is safe to run the script
  multiple times as it keeps track of which log files it
  has digested and which it has not.

- Connect to the database

      mysql -p -u ahs_logging_user -h bioc-mysql-instance.c3dvjslgzl5u.us-east-1.rds.amazonaws.com ahs_logging


  This will prompt you for a password which is contained in the file

      /home/ubuntu/AnnotationHubServer3.0/config.yml

  in the line 'logging_url' between the : and the @ .

  Now you can see the mysql database:

      mysql> show tables;
      +-----------------------+
      | Tables_in_ahs_logging |
      +-----------------------+
      | log_entries           |
      | s3_log_files          |
      +-----------------------+
      2 rows in set (0.00 sec)

  Look at the log_entries table:

      mysql> describe log_entries;
      +------------------+--------------+------+-----+---------+----------------+
      | Field            | Type         | Null | Key | Default | Extra          |
      +------------------+--------------+------+-----+---------+----------------+
      | id               | int(11)      | NO   | PRI | NULL    | auto_increment |
      | timestamp        | datetime     | YES  |     | NULL    |                |
      | remote_ip        | varchar(255) | YES  |     | NULL    |                |
      | url              | varchar(255) | YES  |     | NULL    |                |
      | request_uri      | varchar(255) | YES  |     | NULL    |                |
      | http_status      | varchar(255) | YES  |     | NULL    |                |
      | s3_error_code    | varchar(255) | YES  |     | NULL    |                |
      | is_s3            | tinyint(1)   | NO   |     | NULL    |                |
      | bytes_sent       | int(11)      | YES  |     | NULL    |                |
      | object_size      | int(11)      | YES  |     | NULL    |                |
      | total_time       | int(11)      | YES  |     | NULL    |                |
      | turn_around_time | int(11)      | YES  |     | NULL    |                |
      | referrer         | varchar(255) | YES  |     | NULL    |                |
      | user_agent       | varchar(255) | YES  |     | NULL    |                |
      | s3_version_id    | varchar(255) | YES  |     | NULL    |                |
      | s3_log_file_id   | int(11)      | YES  |     | NULL    |                |
      | id_fetched       | int(11)      | YES  |     | NULL    |                |
      | resource_fetched | int(11)      | YES  |     | NULL    |                |
      +------------------+--------------+------+-----+---------+----------------+
      18 rows in set (0.00 sec)
 
  Look at the most recent record:
 
      mysql> select * from log_entries order by timestamp desc limit 1\G
      *************************** 1. row ***************************
                    id: 223759
             timestamp: 2017-07-20 20:40:38
             remote_ip: 138.26.50.122
                   url: http://egg2.wustl.edu/roadmap/data/byFileType/peaks/consolidated/narrowPeak/E003-H3K27me3.narrowPeak.gz
           request_uri: NULL
           http_status: NULL
         s3_error_code: NULL
                 is_s3: 0
            bytes_sent: NULL
           object_size: NULL
            total_time: NULL
      turn_around_time: NULL
              referrer: NULL
            user_agent: libcurl/7.53.1 r-curl/2.7 httr/1.2.1
         s3_version_id: NULL
        s3_log_file_id: NULL
            id_fetched: 35332
      resource_fetched: 29892
      1 row in set (0.16 sec)

  The url tells you which file was served, resource_fetched is the AH resource 
  ID, and id_fetched is the rdatapath within that resource.

  You could come up with a sql query to find the most common resource_fetched,
  or sort by the most common.

<a name="experimenthub"></a>
## ExperimentHub

As of this writing, all ExperimentHub resources live in S3. This database
only serves as a landing point for processed S3 logs - not as a place to
record non-S3 access as is done for AnnotationHub.

<a name="ehservercode"></a>
### Server code

Code that runs on annotationhub.bioconductor.org and defines ExperimentHub
server behavior:

https://github.com/Bioconductor/HubServer

<a name="ehs3logging"></a>
### S3 bucket: experimenthub-logging

https://s3.console.aws.amazon.com/s3/buckets/experimenthub-logging/?region=us-east-1&tab=overview

Logs in the experimenthub-logging S3 bucket record all requests for the
resources stored in the experimenthub S3 bucket (GET, PUT, DELETE, etc.).
There is no expiration lifecycle rule on this bucket and there shouldn't be. We
want the ability to process all logs since inception to get an idea of use
over time.

<a name="ehrdslogging"></a>
### RDS db: bioc-mysql-instance

ExperimentHub uses the same RDS instance as AnnotationHub but the
database is called "ehs_logging":

https://console.aws.amazon.com/rds/home?region=us-east-1#dbinstances:

If the endpoint of this RDS instance changes, it must be updated in the config file 
of the HubServer code on annotationhub.bioconductor.org:

    ssh ubuntu@annotationhub.bioconductor.org
    cd HubServer
    vim config.yml

### Viewing the logs

Similar to AnnotationHub, a script called read_s3_logs.rb digests the logs in 
the experimenthub-logging S3 bucket and puts the information in the
ehs_logging database on the bioc-mysql-instance RDS instance.

- Log on annotationhub.bioconductor.org as user ubuntu
- Invoke the log processing script:

      /home/ubuntu/HubServer/read_s3_logs.rb

  You'll see this output as the script processes the logs:

      ubuntu@ip-10-114-230-116:~/HubServer$ ruby read_s3_logs.rb 
      0
      100
      200
      300
      400
      500
      ...

  This script does not run regularly (via cron) so it should be run
  before you analyze the logs.

- Connect to the database:

  We use the "ahs_logging_user" because this user has access to both 
  ahs_logging and ehs_logging databases on the RDS instance.

      mysql -p -u ahs_logging_user -h bioc-mysql-instance.c3dvjslgzl5u.us-east-1.rds.amazonaws.com ehs_logging

  This will prompt you for a password which is contained in the file

      /home/ubuntu/HubServer/config.yml

  in the line 'logging_url' between the : and the @ .

  You should now have access to see the mysql database, perform 
  queries, etc. as shown in the AnnotationHub section.

<a name="cloudfront"></a>
## CloudFront

TODO

<a name="cloudwatch"></a>
## CloudWatch

TODO
