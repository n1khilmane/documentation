---
date: 2024-02-07
title: "Webstats Configuration Details"
linkTitle: "Webstats Config"
description: >
  Details on specific operational information for configuring webstats in the Bioconductor core environment.
---

{{% pageinfo color="warning" %}}
Webstat was deployed to production in January 2024. It is currently running on a small dedicated EC2 instance. 
Configureation improvements are likely as we learn more from our observation of initial production.

This document will also be expanded to provide more context for the parameters here defined.
{{% /pageinfo %}}
# Data Flow

![System Architecture](/webstats/bioc-webstats-architecture-v1.excalidraw.png)

# Installation

Installation of the application is planned to be from an Ansible playbook. Until that playbook is completed, the following instructions will deploy new versions of the application.

1. Prepare the target instance.

```bash
sudo apt upgrade
sudo apt update
sudo apt install -y wget python3 python3-pip python3-venv wheel wget
mkdir ~/bioc_webstats
```

2. Download the distribution `whl` file to the target machine. It will be in the form
`bioc_webstats-<VersionNumber>-py3-none-any.whl`. For example, version `0.1.2` will be `bioc_webstats-0.1.2-py3-none-any.whl`.

```bash
wget /dist/bioc_webstats-0.1.2-py3-none-
```


2. Create a new directory for the application and the virtual environment that supports it.

```bash
cd ~/bioc_webstats
python3 -m venv .venv
. .venv/bin/activate
```

3. Install the application and its dependencies.
```bash
pip install bio-web-stats/dist/bioc_webstats-0.1.2-py3-none-any.whl -t .
```

4. Define the location of the 
```bash
export FLASK_APP=./.venv/lib/python3.12/site-packages/bioc_webstats/app.py
```

- [ ]  TODO EDIT THIS DOWN TO SIZE
```bash
python3 -m venv .venv
. .venv/bin/activate
any.whl
python3 -m venv .venv
. .venv/bin/activate
pip install bioc_webstats-0.1.2-py3-none-any.whl -t .
```
# Components
## Flask Configuration Overview

The file `./bioc_webstats/settings.py` contains the code that produces the configuration variables. It also contains default values for all configuration variables. 

Values are first modified by the `.env` file. If there is no `.env` file in the  `./bioc_webstats` directory, successive parent directories are read until an `.env` file is found. If none are found we are done.

If the `.env` file contains a definition for `AWS_PARAMETER_PATH` then then the parameters below that path will be included as environment variables.
 
## IAM - Identity and Access Management
### Users, Groups and Roles
| G/R | Name | Policies Attached | Used By | Purpose |  |
| :--: | ---- | ---- | ---- | ---- | ---- |
| R | `bioc-webstats-webrunner` |  |  | Access to webstats summary database, servers data-dependent web pages |  |
| R | `bioc-webstats-etl` |  |  | Reads CloudFront Logs, Updates download and summary databases |  |
| R | `bioc-webstats-db` |  |  | Role for the `webstats` database |  |
| U | `webstats_runner` |  |  | Local IAM user to correspond to PSQL login name |  |
| G | `bioc-webstats-ug` |  |  | Group for user that has webrunner poliicies |  |
| G | `bioc-webstats-operator` |  |  | SysOps access to webstats application |  |
| G | `bioc-webstats-admin` |  |  | SysAdmin access to webstats resources |  |
|  |  |  |  |  |  |

For webrunner:
- Read params /bioc/websats/*
- Read secret /bioc/rdb/*/login/webstats_runner
- rdb: read/write access to instance
- 

- SysOps: functions: Inspect logs, special backup, start, stop, pause, restart application.
- SysAdmin: Modify parameters, change security settings, deploy software modifications.
### Policies

| Policy Name | Resource | Used By | Purpose |
| ---- | ---- | ---- | ---- |
| bioc-webstats-dbreader |  |  | Read access to the webstats database |
| bioc-webstats-dbwriter | rds database (user okay?) |  | Update access to the webstats database |
| bioc-webstats-dllog-reader |  |  | Read access to the s3 download logs |
| bioc-webstats-dbsecret-ro | /bioc/rdb/login/website_runner |  | Read access to the `webstats` database login login for user `postgres` |
| bioc-webstats-paramstore-ro | /bioc/webstats/* |  | Read access to the parameters |
| bioc-webstats-paramstore-rw | /bioc/webstats/* |  | Write access to the parameters |
| bioc-webstats-s3-ro | Access to the s3 bucket containing download bucket |  |  |
|  |  |  |  |

## Parameter Store

The SSM Parameter Store is lightweight and appropriate for most of the runtime parameters for the system,  including encrypted keys, except for those that require rotation, such as `RDS`. Parameter store keys are hierarchical. The Parameter Store keeps a time-stamped

Example. This parameter name holds the name of the production database for the `webstats` application.
```
/bioc/webstats/prod/db/dbname
```

The structure of the parameter store key is given in the table below. 

| Level | Key | Example | Description |
| ---- | ---- | ---- | ---- |
| 1 | scope | bioc | All parameters for Bioconductor Core maintained systems are identified by the top-level key `bioc` |
| 2 | application | webstats | The designated name for the application, maintained in the application table in coresops.bioconductor.org |
| 3 | envrionment | prod | A code indicating the functional use of this parameter set, such as prod (production) and dev (development). If the parameter is common across environments, the value at level 3 is  zero, "0"  |
| 4 | topic | db | The subsystem or other functional grouping of the parameters below. If the topic  |
| 5 | paramkey | dbname | The specific parameter value. |


Here are specific parameters for the `webstats` application.

| Topic | ParamKey | Type | Description |
| ---- | ---- | ---- | ---- |
| db | dbname | text | Postgres database name, default `webstats` |
| db | dbuser | text | PostgrSQL user name, default `webstats_runner` |
| db | server | text | The symbolic address of the endpoint for the Postgres server |
| db | port | text | Server endpoint port number |
| flask | secret_key | text | Secret key for activating web client flask debugging tools |
| flask | log_level | text | Standard log levels, default `INFO` |
| flask | flask_app | text | `autoapp.py` |
| flask | flask_debug | text | `False` Caution: Do not enable in production |
| gunicorn | bind_port | text | Default: `0.0.0.0:8000` |
| gunicorn | access_log | text | Default: `/var/log/bioc-webstats/access.log` |
| gunicorn | error_log | text | Default: `/var/log/bioc-webstats/error.log` |
| etl | s3_download_logs | text | TOTO FORMAT and NAME |
|  |  |  |  |
## Secrets Manager

| Key | Description |
| ---- | ---- |
| `/bioc/rdb/0/login/webstats_runner` | `{"username":"webstats_runner","password":"***********"}` |
| `/bioc/webstats/prod/flask/secret_key` | Key for activating web client flask debugging tools, called `secret_key` in Flask documentation |
| `bioc/rdb/0/login/postgres` |  |
## RDS - Relational Database Server

### 
| Parameter | Value |
| ---- | ---- |
| Cluster Name | bioc-psql |
| Database Name | webstats |
| User Name | webstats_runner |

## Glue - ETL

| Parameter | Name | Location | Key |
| ---- | ---- | ---- | ---- |
| ETL job | `web-to-download` |  |  |
| Data source | `bioc_web_logs` | `s3://bioc-cloudfront-logs` | aws/s3 |
| Data destination | `bioc_webstats_source` | `s3://bioc-webstats-download-logs` | `bioc/webstats/download-logs` |


## Athena - SQL for S3
# S3 - Object Storage

- Source bucket `s3://bioc-cloudfrount-logs`
- Destination bucket `s3://bioc-webstats-download-log` 




