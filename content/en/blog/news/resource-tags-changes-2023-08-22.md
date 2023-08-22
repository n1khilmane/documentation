---
title: "Resource Tags Changes"
date: 2023-08-22T05:51:53-04:00
draft: false
author: Robert Shear
description: >
    Changes to resource tags to support configuration management
---

As part of our AWS modernization effort, we have added the [resource tag](/docs/governance/resource-tags) `bioc:managed-by`. Where the resource is created by a configuration management process, it indicates the name of the technology that created the resource. The two permissible values at this time are `cloudformation` and `terraform`.

In conjunction with this change, we have replaced the `roles` resource tag topic with the topic `configuration`.