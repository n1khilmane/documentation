---
title: "Core SOPs Website SysOps"
date: 2023-02-28
linkTitle: "Core SOPs site"
weight: 10
description: "System Documentation for coresops.bioconductor.org"
---

## Quick Reference

### Parameters

| Service | Parameter | Value |
|---------|-----------|-------|
| Github | repo | bioconductor/bioconductor |
| Azure  | Subscription ID | 25f05b47-1212-4dc5-b131-ddbe8c7b8c60 |
|| TenantId | e7fd2785-fa44-406f-8121-14a07ecb0e42 |
| Azure Static Web App (SWA) | appName | bioc-core-sops |
|| resourceGroup | bioc-core-sops | bioc-core-sops |
|| Internal domain | victorious-wave-0b018b710.4.azurestaticapps.net |
|| External domain | core-sops.bioconductor.org |
|| ARM template | ./swa_arm_template.json |

### Command Line Tools

| Tool | Purpose |
|------|---------|
| az staticwebapp | Azure Static Web Site CLI |
|| Manage SWA configuration and users from command line. Superset of web console. |
| hugo | Hugo web site generator and management |
| swa | SWA deployment and emulator |


## Overview

TODO 

## Architecture

TODO 

## Content Management

TODO 

## Operations

#### Set default subscription

```
az configure --defaults group="MPN B-eb1d" 
```

#### List All Users

```
az staticwebapp users list -n bioc-core-sops
```

#### Invite a User

```
az staticwebapp users invite -n bioc-core-sops --authentication-provider GitHub --user-details JohnDoe --role verified --domain coresops.bioconductor.org --invitation-expiration-in-hours 120
```



### User Management

TODO 

### Configuration

TODO 

### Disaster Recovery

TODO 
