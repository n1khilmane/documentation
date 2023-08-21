---
date: 2023-05-31
title: "Bioconductor Email Services"
linkTitle: "Email Services"
weight: 10
description: >
  Bioconductor.org does not host its own email servers, but forwards certain inbound mail to specific distribution lists and processes outbound mail.
---
The are no full-featured mail servers assocaited with the `bioconductor.org` domain. However, we provide two limited-purpose services:
- Email forwarding from bioconductor aliases
- Message delivery from internal services, including BBS and `support.bioconductor.org`.

Our mail forwarding servers have been designed have a high level of availability and reliabiliy without human intervention. Nonetheless, their healthy operation requires survenlance.

Protecting the "reputation" of our domain is crucial to our ability to delivery mail. If our reputation is impaired our messages could be marked as spam or our domain could be blacklisted, preventing us with commuicating by email.