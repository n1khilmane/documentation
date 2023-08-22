---
title: "Resource Tag Taxonomy"
date: 2023-03-22
linkTitle: "Tags"
weight: 20
description: >
  The Bioconductor Core standardized scheme for describing the characteristics of cloud resources used by the Bioconductor Core Team. 
---


{{% pageinfo %}}
2023-08-22: `bioc:managed-by` added, topic `roles` changed to `configuration`.

The resource tags are stored as a json file located in the [bioc-core-sops repo](https://github.com/Bioconductor/bioc-core-sops/blob/main/data/resource_tags.json).
{{% /pageinfo %}}

The Bioconductor Core standardized scheme for describing the characteristics of cloud resources used by the Bioconductor Core Team.
This document is an incomplete discussion draft. Comments and suggestions are welcome.
This document describes a standardized scheme for describing the characteristics of cloud resources used by the Bioconductor Core Team. These characteristics are in the form of key-value pairs. And a set of these key-value-pairs may be attached to a resource or an artifact associated with the Bioc infrastructure. The keys are known as tags in AWS and Azure. In GCP, they are called labels. We will refer to them as tags in this document.

## Scope

The scope of this specification is limited to the infrastructure that supports Bioconductor Core Team activities. Software lifecycle activities associated with the Bioconductor code base and user communities are outside this specification's scope. For example, git.bioconductor.com is not a development server but a production server that supports the development activities of our team. Therefore, the tags that relate to the operation of the server that runs git.bioconductor.com will conform to this standard. At the same time, none of the repos that make up the Bioconductor code base need to be aware of this taxonomy.

## Format

The tags are hierarchical, and so this schema is a taxonomy. A tag comprises two or more tag identifiers separated by colons (:). The identifier `bioc` is the single root term in this taxonomy. This identifier serves as a namespace sentinel, protecting against conflicts with tags reserved by the cloud vendor or by environments provided to us by others. For example, a tag identifying the resource's owner is written `bioc:owner`.
All identifiers must be lowercase and comprise one or more English language words or commonly recognized abbreviations. Hyphens must separate multiple words. The maximum length of a tag is 32 characters. These restrictions will facilitate the use of common tags across cloud environments.


Dates and time intervals will conform to ISO 8601. 


### Configuration

Configuration tags specify characteristics of the the genesis, management, and lifecycle management of the resource. Where the configuration is managed by a configuration management tool, the `bioc:managed-by` tag indicates the tool source.

#### Roles

The tags `bioc:managed-by` and `bioc:created-by` identify security principals (usually users) that have a specific current relationship with the resource to which the tag is attached.
For AWS resources, users with established IAM accounts within the Bioconductor AWS account (555219204010) will be identified as `iam-user-name@biocondcutor`.
Example: `lori.shepherd@bioconductor`.
For cross-account users, the user will be identified by their Amazon Resource Name. Example. User Luke_Skywalker who has cross-account permissions from account 999999997, will be identified as `arn:aws:iam::999999997:user/Luke_Skywalker`.

### Workloads

These tags associate the resource with specific applications or mode of use.

### Processing 

Processing tags provide specific characterization for the operation of the tagged resource. 
Examples include retention date, relative importance, and recovery time objective.

## All Tags

{{< tags-table >}}
