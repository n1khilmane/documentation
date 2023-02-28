---
title: "Core SOPs Website SysOps"
linkTitle: "Core SOPs site"
weight: 10
description: "System Documentation for coresops.bioconductor.org"
---

## Quick Reference

### Parameters

| Service | Parameter | Value |
|---------|-----------|-------|
| Github | repo | bioconductor/bioconductor |
| Azure  | Subscription ID | 50e86e60-67ad-4bac-88aa-5eb26018eb1d |
|| Subscription Name | MPN-B-eb1d |
|| TenantI d | 95d4a3cd-3fb8-40c8-bdea-2e2b47e9a82f
| Azure Static Web App (SWA) | appName | bioc-core-sops |
|| resourceGroup | bioc-core-sops | bioc-core-sops |
|| Internal domain | zealous-pond-0187fb310.2.azurestaticapps.net |
|| External domain | coresops.bioconductor.org |
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
