---
title: "Identity and Access Directory Selection Design Brief"
date: 2023-08-29
draft: false
author: Robert Shear
description: >
    This note describe the rationale for selecting AwS Identity Center directory as the identity source for the AWS Modeernization Project (AMP23)
---

# Summary
As part of the AWS Modernization Project 2023 (AMP23), we have considered the alternatives for identity and access management and concluded that we will manage our AWS user identities within the AWS IAM service. This document memorializes our investigation and conclusions.
## Background
As part of AMP23, we have chosen to adopt the AWS Organizations. (AWS-org). This allows multiple AWS accounts to be provisioned and managed by the Bioconductor Core Team, which in turn enables the isolation of production, testing, and development environments. As a consequence, certain users will have access to more than one AWS account.

## AWS IAM Identity Center
To maintain a single identity for each user while allowing certain users to access multiple AWS accounts, we are adopting the service known as "AWS IAM Identity Center (Successor to AWS Single Sign-On)," a/k/a "Identity Center."

While we can create and manage our Identity Center users within the AWS IAM service, it is also possible to use other identity sources, including Microsoft Active Directory (AD), Azure AD, Okta, Ping Identity, and Google Workspace. 

## AWS Control Tower
The AWS Control Tower service provides operational and governance features for multi-account environments. While some of these features are only useful in the context of a large user base, others will help us adopt important best practices around security and reliability.

Some AWS Control tower high-level documentation suggested the desirability of using an external identity provider, particularly AD. We find that those benefits are related to large-scale organizations and are not relevant to AMP23.
# Alternatives
We briefly surveyed the vendors identified as "Leaders" in Gartner's November, 2022 Access Management Magic Quadrant:
	- Microsoft
	- Okta
	- ForgeRock
	- Ping Identity

There are two simple identity managers that might have been attractive but were not compatible with IAM Identity Center SSO requirements: AWS Cloud Directory (based on open-source SAMBA) and Okta's AUTH0 (no-charge) service.

AD and possibly Okta had pricing that was compatible with our needs. Only "AWS Directory Service for Managed Microsoft Active Directory (previously AWS Managed Microsoft AD)" could be provisioned conveniently with the AWS environment.

There are two simple identity managers that might have been attractive but were not compatible with IAM Identity Center SSO requirements: AWS Cloud Directory (based on open-source SAMBA) and Okta's AUTH0 (no-charge) service.

## AWS Directory Service for Microsoft AD Evaluation
The service is managed by AWS. Nonetheless, each of the two DS servers is simply a WIndows Server 2019 instance. Ad hoc administrative activities are performed through the Windows "Active Directory Users and Computers" Administrative Tools snap-in. While this is surely a convenience for Windows-based environments it would be a significant training and support burden in our environment. MFA support requires the creation of a separate RADIUS server, not managed as part of the AWS DS managed service.

## IAM Identity Center
Using the native Identity Center User  provides all the features necessary to support our IAM AMP23 use cases, including multifactor authentication and SAML 2.0 federation.

In summary, it will give us what we need at no additonal cost and minimum operational and design burden.

