---
title: "Bitwarden Overview"
linkTitle: "Bitwarden Overview"
weight: 20
tags: []
categories: []
---

[Bitwarden](https://bitwarden.com/) is a widely used open-source password management service.
It allows users to safely and conveniently maintain and use strong passwords.
It has a range of valuable features, including 
  - Single sign-on (SSO)
  - Cross-platform, including mobile
  - Autofill web site credentials
  - Password generation
  - Multifactor authentication
  - Biometic authenticaton
  - Password history
  - Secure sharing of passwords between users
  - Zero-knowledge end-to-end encryption

## Zero-knowledge Secrets Management

Your passwords and other secrets are stored in a _vault_. 
The vault is encrypted using a _master password_ known is only known to you.
This decryption only takes place when you need access to a vault item.
The contents of the vault are never elsewhere decrpted.
As long as your master password is not discovered your vault contents will never be decrypted.
For more details click [here](https://bitwarden.com/help/bitwarden-security-white-paper/#overview-of-the-master-password-hashing,-key-derivation,-and-encryption-process).
Bitwarden is based on a "zero-knowledge" architecure. Secrets stored in your Bitwarden 

## Supported Platforms

  - Desktop
    - Windows
    - macOS
    - Linux (most distributions)
  - Mobile
    - Apple
      - iPhone
      - iPad
      - Apple Watch
    - Droid
      - Google Play
      - F-Droid
  - Web Browser
    - Chrome
    - Safari
    - Firefox
    - MSFT Edge
    - DuckDuckGo for Mac
    - Others

## Further Reading

- [Bitwarden Security Whitepaper](https://bitwarden.com/help/bitwarden-security-white-paper/)
- [Onboarding and Succession](https://bitwarden.com/help/onboarding-and-succession)
- [About Collections](https://bitwarden.com/help/about-collections/)
- [About Groups](https://bitwarden.com/help/about-groups)
- [Sharing](https://bitwarden.com/help/sharing/)
