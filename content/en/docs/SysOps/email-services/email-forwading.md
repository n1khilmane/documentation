---
title: "Email forwarding service"
linkTitle: "Email forwarding"
weight: 20
description: >
  Forwardemmail.net processes email messages sent to bioconductor.org. For defined aliases, the mail is forwarded to a static list of interested parties.
---




### Email forwarding sevice

The purpose of Biconductor's email forwarding service is to send email to a static list of interested users. There are currently 16 aliases, each covering an affinity group suich as `education@bioconductor.org` or a team, such as `devteam-bioc@bioconductor.org` or `cab@bioconductor.org` (Community Advisory Board).

Messages are accepted from any source. They are rejected if they 
- originate at a blacklisted email address or IP source adress
- Have "adult-related" content
- Contain malware, domain swapping or IDM homographic attack characterists or other phishing traits
- Contain potentially malicous executable file tpes, extensions, names, headers or "magic numbers"
- Fail ClamAV scan for trojancs, viruses malware or other malicious threats.
#### Implementation

External service https://forwardemail.net/

Strong, up-to-date spam protection
 Alias Page
 Fowrdemail log

TODO: pull logs / health checks

