---
title: "Bioconductor Mirrors and RSync Access"
linkTitle: "Mirros and RSync"
description: This document contains instructions for adding mirrors and rsync access.
---
Public Bioconductor Mirrors are listed at
[Mirrors](http://bioconductor.org/about/mirrors/) and a link provided on that
pages to set up a mirror [mirror
how-to](http://bioconductor.org/about/mirrors/mirror-how-to/).  In April 2021
Bioconductor no longer supported open rsync to master.bioconductor.org in
accordance with recommended practices from AWS Strides Well-Architected Review.

All rsync is now secure and requires both the IP address of the machine and a
ssh public key.

## Adding ssh key on master.bioconductor.org

1. Log onto master as ubuntu
2. switch to bioc-rsync user
3. Add ssh key provided to authorized keys. See other added keys for formatting.

## Adding IP address

1. Log into AWS and navigate to the Biconductor EC2 console.
2. In the left most panel under `Network & Security`, select `Security Groups`
3. Find `rsync-restrictive` and select the box
4. On the upper Right select `Actions` drop down, select `Edit Inbound Rules`
5. scroll to the bottom of the page and select `New rule`
6. follow the format as the other entries.  Be sure to use CIDR format. If
needed to convert a range or an IP address see
[cidrcalculation](https://account.arin.net/public/cidrCalculator).
7. Be sure to give it a detailed description preferrably location and rsync
maintainer.
8. Be sure to hit `Save rules` in the bottom right corner when done adding IP.

## Public Mirror adding to `chooseBioCmirror()`

1. Update to include the information on [mirror
webpage](http://bioconductor.org/about/mirrors/)
2. Add information to bioconductor.org  config.yaml for mirror 