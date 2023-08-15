---
title: "Builders: Bioc Servers at DFCI"
linkTitle: "Builders"
weight: 20
description: >
  Bioconductor Core Group servers located within the dfci.harvard.edu network (Builders) IAM procedures
---

## Introduction

The Builders are servers located within the DFCI network that run daily builds and related processes.
These operations are generally automatic.
Connection to the Builders is generally restricted to individuals with build-process operational responsibilites.

## Accessing the Builders

Either `ssh` or `scp` is used to access a Builder server from outside of the DFCI server network.
The Builders are only accessible from within the DFCI network, so users must first connect to a login server.
The login servers names are published by DNS and generally accessible on port 22 (SSH Protocl).

Users are authorized by SSH key.
To become an authorized user, provide your public SSH key to Jennifer Wokaty (TODO Name-by-role).
They will forward it to Nikos George at DFCI (TODO Name-by-role).
He will use this key to grant you access to the DFCI login servers as well as the builders.

If you are unfamiliar with SSH key, [this](https://sites.google.com/ds.dfci.harvard.edu/docs-ds/servers-hpc/server-access-ssh) page may be helpful.
{{% alert title="Warning" color="warning" %}}
Never disclose your SSH private key to anyone.{{% /alert %}}

Once your public key has been added to the DFCI network and your private key is on your system with mode 600, you may access the Builder with the following command 

```bash
ssh -A -J <User>@<JumpServer>.dfci.harvard.edu <BiocName>@<BuilderIp>
```

### Example

User `rfranklin` wishes to `ssh` to `nebbiolo1` with the local identity `biocbuild`.

```bash
ssh -A -J rfranklin@ada.dfci.harvard.edu biocbuild@155.52.47.135
```

### Builder Names and Addresses

| Type | Name | OS | IP Addr |
|------|------|----|---------|
| Builder | nebbiolo2 | Linux | 155.52.47.146 |
| Builder | nebbiolo1 | Linux | 155.52.47.135 |
| Builder | lconway | macOS | 155.52.47.207 |
| Jump Server | ada | Linux | - |
| Jump Server | noah | Linux | - |

### Builer Local User Names

| User | Purpose | Notes |
|------|---------|-------|
|biocbuild | TODO ||
|pkgbuild| TODO ||
|biocpush| TODO | nebbiolos* only |

### Revoking Builder User Access

An authorized Builder user's access should be revoked when they no longer require access to the Builders.
To effect this change, Jennifer Wokaty (TODO Role) will notify Nikos George (TODO Role) who will effect this change.

{{% alert title="Good Practice" %}}
The list of authorized Builder users should be periodically reviewed.
{{% /alert %}}
