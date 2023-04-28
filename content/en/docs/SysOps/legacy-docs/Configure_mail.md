---
title: "Bioconductor mail delivery"
linkTitle: "bioc mail"
description: This document describes the configuration and set-up for the `delivery.bioconductor.org` EC2 instance. 
---
# Bioconductor mail delivery


## Table of Contents
- [Overview](#overview)
- [Postfix](#postfix)
  - [Configure](#configure_postfix)
  - [Forward mail sent to standard lists](#mail_forwarding)
  - [bioc-devel mailing list](#bioc_devel)
  - [Forward 'reply-to' messages from Support Site](#support_site)
- [SpamAssassin](#spamassassin)
  - [Configure](#configure_spamassassin)
  - [Create Rules](#rules_spamassassin)
- [Postfix and SpamAssassin](#postfix_spamassassin)
  - [Route messages through SpamAssassin](#route_spam)
  - [Manage messages marked as SPAM](#manage_spam)
- [Other](#other)

<a name="overview"></a>
## Overview 

`delivery.bioconductor.org` is an AWS EC2 instance responsible for routing
mail sent to the `*.bioconductor.org` domain. This includes addresses such
as maintainer@bioconductor.org, devteam-bioc@bioconductor.org, etc. 
(complete list in /etc/postfix/virtual) as well as "reply-to" messages
sent from the Support Site.

Mail sent to `*@bioconductor.org` is routed through 
`delivery.bioconductor.org` as specified in the AWS Route 53 DNS lookup
(type = "MX"):

    https://console.aws.amazon.com/route53/home?region=us-east-1#resource-record-sets:Z2LMJH3A2CQNZZ

`delivery.bioconductor.org` runs Postfix and SpamAssassin. When this document 
was written the EC2 instance was a t2.micro with a 100GB root drive.

<a name="postfix"></a>
## Postfix

Postfix is a free, open-source mail transfer agent (MTA) that routes and
delivers electronic mail. It is released under the IBM Public License 1.0 
which is a free software license.

<a name="configure_postfix"></a>
### Configure

Download and install:

    sudo apt-get install postfix

Test connecting to Postfix server:

    telnet localhost 25

Instructions for basic configuration:

There are 2 primary configuration files for Postfix: main.cf and master.cf.
The master.cf configuration file defines how a client program connects to a 
service, and what daemon program runs when a service is requested. 

The Postfix main.cf configuration file specifies a very small subset of all
parameters that control the operation of the Postfix mail system. Parameters
not explicitly specified are left at their default values.

main.cf sets the default values used by all services defined in master.cf; -o
options in master.cf can override these on a per-service basis.  After changing
these files, "postfix reload" must be run to reload the configuration.

See these sites for more detail:

    http://www.postfix.org/BASIC_CONFIGURATION_README.html#myorigin
    https://www.linux.com/learn/install-and-configure-postfix-mail-server

<a name="mail_forwarding"></a>
### Forward mail sent to standard lists

The /etc/postfix/virtual file is a plain text file containing the
address of incoming email and the one or more recipients the mail
should be forwarded to. 

* Forward email from specific user

  Open the `/etc/postfix/virtual` file (create one if it does not
  exist).
 
      sudo vim /etc/postfix/virtual
 
   Add the emails you want to forward along with the
  destination emails, e.g., 

      postfixtest@bioconductor.org gregory.wargula@roswellpark.org
      biostar@bioconductor.org lori.shepherd@roswellpark.org

  The first email is the address on which postfix shall receive emails, and the
  second is the address where postfix would forward the emails.

  Mail can be forwarded to multiple destinations (group), e.g.,

      contact@bioconductor.org myself@gmail.com mystaff@gmail.com

* Forward email from a domain

  To catch and forward emails to any address for a given domain, use the 
  following notation:

      @bioconductor.org myself@gmail.com mystaff@gmail.com

  We do not implement this universal catch on `delivery.bioconductor.org`. This
  directive would accept mail addressed to any `*.bioconductor.org`. Specifying
  the incoming email addresses in "virtual" acts as a preliminary filter. For
  example, an address such as "foo.bioconductor.org" is not accepted because it
  is not defined in "virtual".

* Modify /etc/postfix/main.cf

  Once /etc/postfix/virtual has been modified we need to tell 
  postfix where to look for these mappings; the appropriate configuration
  directive is in the /etc/postfix/main.cf configuration file.
 
  The "virtual_alias_domains" variable indicates domains from which postfix 
  will accept emails. In our case this is just `bioconductor.org`. Multiple 
  domains could be added, separated by a space.
 
  The "virtual_alias_maps" variable specifies the path to 
  the file that contains the mappings for the "virtual_alias_domains".
  The hash directive in the line below tells postfix to use the db-format 
  (hash) version of the virtual mappings. 

  Add the following lines to the end of /etc/postfix/main.cf:

        virtual_alias_domains = bioconductor.org
        virtual_alias_maps = hash:/etc/postfix/virtual

* Regenerate the virtual.db table:

  Whenever a change is made to /etc/postfix/virtual we need to 
  run the postmap command which generated a new /etc/postfix/virtual.db 
  and loads the aliases into postfix.

        sudo postmap /etc/postfix/virtual

* Reload postfix configuration:

        sudo service postfix reload 

<a name="bioc_devel"></a>
### bioc-devel mailing list

The `bioc-devel@bioconductor.org` mailing list is not managed by
`deliver.bioconductor.org` but by bioc-devel-owner@r-project.org.

https://stat.ethz.ch/mailman/listinfo/bioc-devel

<a name="support_site"></a>
### Forward 'reply-to' messages from Support Site

In the previous section mail forwarding rules for lists such as
`devteam-bioc@bioconductor.org` and `maintainer@bioconductor.org` were
specified in /etc/postfix/virtual. delivery.bioconductor.org manages all
incoming and outgoing mail for the lists defined in the 'virtual' file.

`devlivery.bioconductor.org` also redirects "reply-to" emails from the Support
Site (https://support.bioconductor.org/). These "reply-to" messages originate
when a user replies via email or through the web interface. The message has a
'reply' embedded in the return address, for example,

    Reply-To: <reply+f59930f8+code@bioconductor.org>

All incoming messages are searched by regex and those with
`'reply*'@bioconductor.org` are forwarded to the biostar user at
biostar@localhost.org. All messages sent to the biostar
user are uploaded to support.biocondcutor.org with a curl command.

1. Create user biostar

    This is a login user with a password; ssh is not configured. See the 
    Google Credentials doc for the password that was assigned to the biostar 
    user 
    (https://docs.google.com/document/d/1ieGzOsb0NrUqi8fArBr6pcuNK5x0Dp9Cw8g4OCHghi8/edit).

        sudo useradd -m -s /bin/bash biostar

2. Edit the alias table

    Add a line to the aliases file that uploads biostar's mail to
    `support.bioconductor.org`.

        sudo vim /etc/aliases

    Add the following line:

        biostar: "| curl -k -F key='abc' -F body='<-' https://support.bioconductor.org/local/email/"

    Make the changes take effect:

        sudo newaliases
        sudo service postfix reload

3. Identify incoming mail from the Support Site

  * Add a line in /etc/postix/virtualregexp that identifies mail from
    the Support Site and forwards it to the biostar user.

        cd /etc/postfix
        sudo vim virtualregexp
 
      Add this line:

        /(reply.*)@bioconductor.org/ biostar@localhost

      All mail forwarded to the biostar user is uploaded to
      `support.bioconductor.org` because of the alias created in /etc/aliases.

  * Modify /etc/postfix/main.cf

        cd /etc/postfix
        sudo vim main.cf 
 
      Modify 'virtual_alias_maps' in main.cf to include a regexp directive
      pointing to the virtualregexp file (the hash directive was added in a
      previous step):
 
        virtual_alias_maps = regexp:/etc/postfix/virtualregexp, hash:/etc/postfix/virtual

  * Update virtualregexp database and reload postfix config files

        cd /etc/postfix
        sudo postmap virtualregexp
        sudo service postfix reload

<a name="spamassassin"></a>
## SpamAssassin

Apache SpamAssassin is an open source mail filter written in Perl. It examines
messages and assigns a score indicating the likelihood that the mail is spam.
An external program (such as Postfix) must then examine this score and do any
routing the user wants done. 

<a name="configure_spamassassin"></a>
### Configure

* Download and install

        sudo apt-get install spamassassin spamc

* Add spamd user

  Add the group spamd:

        sudo groupadd spamd

  Add the user spamd with home directory /var/log/spamassassin:

        sudo useradd -g spamd -s /bin/false -d /var/log/spamassassin spamd

  Create the directory /var/log/spamassassin and change ownership to spamd:

        sudo mkdir /var/log/spamassassin
        sudo chown spamd:spamd /var/log/spamassassin

* Configure SpamAssassin

  Open the /etc/default/spamassassin config file: 

        sudo vi /etc/default/spamassassin

  Find the following line:

        OPTIONS="--create-prefs --max-children 5 --helper-home-dir"

  Specify the user that SpamAssassin should run as and the name/location
of the log file.

        OPTIONS="--create-prefs --max-children 5 --helper-home-dir --username spamd -s /var/log/spamassassin/spamd.log"

  Enable SpamAssassin by changing ENABLED from 0 to 1:

        ENABLED=1

  Enable the cron job to automatically update SpamAssassin rules on a nightly 
basis by changing CRON from 0 to 1:

        CRON=1

  Save and close the file. Start the Spamassassin daemon:

        sudo systemctl start spamassassin.service

  Confirm the daemon is running:

        sudo systemctl status spamassassin.service
 
  Enable automatic starting after reboot:
  
        sudo systemctl enable spamassasin.service

  Enable logrotate (or similar) for /var/log/spamassassin/spamd.log.

<a name="rules_spamassassin"></a>
### Create Rules

Many rules can be enabled in /etc/spamassassin/local.cf. For this 
installation, the score was changed from 5.0 (no filtering) to
4.0 and a SPAM score was added to message header.

    sudo vim /etc/spamassassin/local.cf

  Uncomment and modify the 'rewrite_header' and 'required_score' lines:

    rewrite_header Subject ***** SPAM _SCORE_ *****
    required_score 4.0

  Restart spamassassin:

      sudo service spamassassin restart

<a name="postfix_spamassassin"></a>
## Postfix and SpamAssassin

<a name="route_spam"></a>
### Route messages through SpamAssassin

Open the Postifx master process configuration file:

    sudo vim /etc/postfix/master.cf

* Route emails through SpamAssassin:

    These modifications enable Postfix to route messages through
    SpamAssassin after they have been queued. After passing through
    SpamAssassin the messages are returned to Postfix for routing.

    Find this line

        smtp inet  n       -       -       -       -       smtpd

    and add this flag to the end of the line:

        -o content_filter=spamassassin

    Add the following line to the end of the file: 

        spamassassin unix -     n       n       -       -       pipe user=spamd argv=/usr/bin/spamc -f -e /usr/sbin/sendmail -oi -f ${sender} ${recipient}

* Restart postfix:

        sudo service postfix restart

<a name="manage_spam"></a>
### Manage messages marked as SPAM

At this point, Postfix has been configured to route messages through
SpamAssassin where the message is scored and a spam flag is added to the
header. Messages tagged as SPAM are not dropped but are forwarded on to their
final destination. It is up to client-side filtering to decide whether or not
the message should be dropped. To hold, tag or remove messages
marked as SPAM instead of forwarding them on, use Postfix's header
checks.

* Create the file /etc/postfix/header_checks:

        sudo touch /etc/postfix/header_checks

  There are a number of actions that can be taken on messages identified as
  SPAM. See http://www.postfix.org/header_checks.5.html for a complete list. 

  To drop messages add this line to the header_checks file:

        /^X-Spam-Flag:.YES/ DISCARD spam

  Or move messages to a holding queue for moderation by adding this line:

        /^X-Spam-Flag:.YES/ HOLD spam

* Add a line to /etc/postfix/main.cf that points to the header_checks file:

        header_checks = regexp:/etc/postfix/header_checks

* Restart postfix:

        sudo service postfix reload

<a name="other"></a>
##  Other 

### Checks for new EC2 instance if machine goes down

- Security on new instance must include 
  ports ssh 22 and standard unencrypted mail 25 
  (as of April 2017 not yet supporting encrypted mail: 587, 465)
- View incoming: tail /var/log/mail.log
- Confirm DNS association: nslookup delivery.bioconductor.org
- telnet to mail port 25, confirm postfix was listening 
- Check lookup:

        ~ >nslookup
        > set q=MX
        > bioconductor.org
        Server:		8.8.8.8
        Address:	8.8.8.8#53
 
        Non-authoritative answer:
        bioconductor.org	mail exchanger = 10 delivery.bioconductor.org.

### Manage hold queue

Queues are located in /var/spool/postfix.

As root:

List of queued mail, deferred and pending:

    postqueue -p
 
Create a file to grep / parse:

    postqueue -p > mailqueue_YYYYMMDD.txt

View message with id XYZ:

    postcat -vq XYZ

Find specific term in messages:

    find . -type f  -exec grep -l searchterm {} \;
 
Delete all messages in hold queue:

    sudo postsuper -d ALL hold
 
Other references:
    https://easyengine.io/tutorials/mail/postfix-queue/
    
