---
title: "Bioconductor AWS Snapshots"
linkTitle: "Snapshots"
date: 2024-05-01
weight: 5
description: >
  All of Bioconductor's AWS Snapshots . 
---

{{% pageinfo %}}
This document is preliminary.
The Bioconductor Core Team's adoption of AWS Snapshots is in the Proof of Concept Stage.
{{% /pageinfo %}}

## AWS Snapshot Modernization Documentation

### Introduction

This document outlines the process of modernizing AWS snapshots for improved cost optimization and data management using the AWS EBS Snapshots Archive feature. By implementing a well-defined strategy, we can:

* Reduce storage costs associated with underutilized snapshots.
* Enhance data organization for easier retrieval and management.
* Ensure compliance with data retention policies.

### Snapshot Categorization

The first step involves classifying snapshots based on their creation method and purpose:

* **Automated Backups:** Created using predefined policies (e.g., daily, weekly, monthly).
* **Auto-created using CreateImage() API:** Typically backups generated during instance image creation.
* **Others:** One-time snapshots for specific purposes (e.g., testing, workbenches).

### Lifecycle Management

**3.1. Automated Backups**

These snapshots benefit from existing lifecycle policies that govern their retention. We will:

* **Review existing policies:** Analyze current retention periods (e.g., daily policy retaining 14 snapshots) and update them based on access frequency and business needs.
* **CloudTrail integration:** Implement CloudTrail to track snapshot access patterns and ensure retention policies align with actual usage.

**3.2. CreateImage() API Snapshots**

These snapshots often lack automated management. We will:

* **Identify inactive snapshots:** Analyze creation dates and usage metrics to determine which snapshots are no longer needed.
* **Action selection:** Decide on retention, deletion, or archiving based on the snapshot's content and potential future use.

**3.3. Other Snapshots**

These require individual evaluation based on their creation date and purpose:

* **Active snapshots:** Retain in the standard tier for frequent access.
* **Inactive snapshots:** Decide on retention (older releases, workshops), deletion (obsolete data), or archive to the AWS EBS Snapshots Archive (rarely accessed data with lower retrieval priority).

**3.4. Scripting Automation**

We will leverage bash or Python scripts to automate snapshot lifecycle management tasks, improving efficiency and consistency.

### AWS EBS Snapshots Archive

The AWS EBS Snapshots Archive is a cost-effective storage tier designed for long-term retention of infrequently accessed snapshots.  Here are some key benefits:

* **Reduced Costs:** Up to 75% lower storage costs compared to the standard tier ([https://docs.aws.amazon.com/ebs/latest/userguide/snapshot-archive.html](https://docs.aws.amazon.com/ebs/latest/userguide/snapshot-archive.html))
* **Long-term Retention:** Archive snapshots for compliance or future use.
* **Easy Retrieval:** Restore archived snapshots to the standard tier for access when needed.

**Official Documentation:**

* [https://docs.aws.amazon.com/ebs/latest/userguide/snapshot-archive.html](https://docs.aws.amazon.com/ebs/latest/userguide/snapshot-archive.html)

### Implementation Steps

1. **Review existing policies** for automated backups.
2. **Set up CloudTrail** to track snapshot access.
3. **Identify inactive CreateImage() API snapshots.**
4. **Classify "Other" snapshots** based on purpose and activity level.
5. **Develop scripts** to automate lifecycle management tasks, including archiving to the AWS EBS Snapshots Archive.
6. **Iteratively apply** the strategy to different snapshot categories.

### Conclusion

By implementing a structured approach to AWS snapshot modernization with the AWS EBS Snapshots Archive, we can achieve significant cost savings, enhance data organization, and streamline snapshot management.





