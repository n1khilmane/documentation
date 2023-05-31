---
date: 2017-06-01
title: "Bioc Apache setup"
linkTitle: "Apache setup"
description: This not a comprehensive guide but more of a top-level overview of how Apache can be installed and configured to support SSL. There are many good resources on the web with more detail.

---

## SSL Certificate

The Bioconductor project has a wildcard ssl certificate that can be applied to
any application on any of the *.bioconductor.org machines. All web servers that
support ssl let you set up certificates. Details on what files are needed and
where they should be put on the machine you are configuring can be found
in the `Credentials for Bioconductor Resources` Google Doc.

## Install Apache

    sudo apt-get install apache2 apache2-utils


## Configure Apache to Support SSL 

By default, Openssl is installed in Ubuntu >=14.04. This module provides SSL
support to Apache. It is disabled by default, so you need to enable the SSL
module first then restart apache.

    sudo a2enmod ssl
    sudo service apache2 restart


## Configure Apache to Use SSL Certificate

1. edit /etc/apache2/apache2.conf

   This is the main apache server config file. It contains configuration
   directives that give the server its instructions. See
   http://httpd.apache.org/docs/2.4/ for detailed information about the
   directives and /usr/share/doc/apache2/README.Debian about Debian specific
   hints.

2. edit /etc/apache2/sites-available/000-default.conf for http (port 80)

   This `000-default` file can contain all VirtualHost statements or they can
   be broken out into separate files. (An `Include` statement in
   /etc/apache2/apache2.conf specifies where confg files are read from). All
   files ending in .conf are loaded alphabetically.  To use this file as a
   simple http -> https redirect add a VirtualHost directive something like
   this:

        <VirtualHost *:80>
            ServerName server.bioconductor.org
            Redirect permanent / https://server.bioconductor.org/
        </VirtualHost>


3. add  /etc/apache2/sites-available/default-ssl.conf for https (port 443)

   If using an SSL certificate it's good practice to create a separate config
   file. In addition to the standard directives, the VirtualHost block should
   contain these SSL-specific statements:

        <VirtualHost _default_:443>
            DocumentRoot /srv/git/repository
            ServerName git.bioconductor.org
            ...
            SSLEngine On
            SSLCertificateFile /etc/ssl/certs/b85f7bc121b1e724.crt
            SSLCertificateKeyFile /etc/ssl/private/bioconductor.key
            SSLCertificateChainFile /etc/ssl/certs/n_gd_bundle-g2-g1.crt
        </VirtualHost>

4. enable the config files (creates simlinks in sites-enabled/ directory)

   Once the config files in /etc/apache2/sites-available are ready they need to
   be enabled with the `a2ensite` which creates simlinks in the
   /etc/apache2/sitest-enabled directory:

        sudo a2ensite 000-default.conf
        sudo a2ensite default-ssl.conf

   Restart apache:

        sudo service apache2 restart    ## could also use reload here
        
## Notes
Check if apache is running:

    sudo service apache2 status
