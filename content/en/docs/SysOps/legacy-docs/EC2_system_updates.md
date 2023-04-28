---
title: "Updating and managing EC2 instances"
linkTitle: "EC2 server updates"
description: This document briefly describes the key services running on the EC2 instances and any special-case treatment necessary when performing system updates.
---
## Table of Contents

- [Overview](#overview)
- [Automated updates](#autoupdates)
- [Manual updates and reboot](#manualupdates)
- [Alarms and metrics for new instances](#alarms)
- [master.bioconductor.org](#master)
- [rabbitmq.bioconductor.org](#rabbitmq)
- [staging.bioconductor.org](#rabbitmq)
- [annotationhub.bioconductor.org](#rabbitmq)
- [delivery.bioconductor.org](#delivery)
- [issues.bioconductor.org](#issues)
- [support.bioconductor.org](#support)
- [stats.bioconductor.org](#stats)
- [git.bioconductor.org](#git)
- [Other](#other)

<a name="autoupdates"></a>
-------------------------------------
Automated updates
-------------------------------------

Automated system updates are performed on all EC2 instances using the
"unattended-upgrades" package. Implementation described here:

https://help.ubuntu.com/community/AutomaticSecurityUpdates

The unattended-upgrades package downloads and installs security upgrades
automatically and unattended, taking care to only install packages from the
configured APT source, and checking for dpkg prompts about configuration file
changes.

The package interface is flexible and can perform all update-related actions.
The current configuration takes a conservative approach by updating packages
only from default (trusted) sources, not clearing the cache or performing a
reboot.  The idea is to keep the machines "as current as possible" with respect
to known security patches and updates from known sources.  Occasionally updates
should be done manually with 'apt-get update' and 'apt-get upgrade'. This will
allow any outstanding issues (e.g., package from non-trusted source etc.) to be
resolved interactively by a human.

* Install

      sudo apt-get install unattended-upgrades

* Configure 

      sudo dpkg-reconfigure unattended-upgrades

Answer the interactive prompts:

      Automatically download and install stable updates? -> click 'yes'

      Origins-Pattern that packages must match to be upgraded:  -> click 'ok' to accept default

* Modify config files

- /etc/apt/apt.conf.d/50unattended-upgrades

  Defaults are fine. The allowed origins listed as of August 2017 are: 
 
  ['o=Ubuntu,a=xenial', 'o=Ubuntu,a=xenial-security', 'o=UbuntuESM,a=xenial']

- /etc/apt/apt.conf.d/20auto-upgrades

  Periodic updates are run from /etc/cron.daily/apt-compat via the
  /usr/lib/apt/apt.systemd.daily script. Below we modify the config file to
  update packages once a week. The upgrade step only runs when there are new
  packages to install so it also runs once a week.
 
  Edit /etc/apt/apt.conf.d/20auto-upgrades as sudo:

      sudo vim /etc/apt/apt.conf.d/20auto-upgrades
 
  Update and upgrade once a week:
 
      // Do "apt-get update" automatically every n-days (0 = disable)
      APT::Periodic::Update-Package-Lists "7";
      // Do "apt-get upgrade" automatically every n-days (0 = disable)
      APT::Periodic::Unattended-Upgrade "1";

- Apply configuration changes

      sudo dpkg-reconfigure unattended-upgrades

* Logrotate settings

  Logs are stored in /var/log/unattended-upgrades.

  Edit the logrotate file as sudo
 
      sudo vim /etc/logrotate.d/unattended-upgrades 
 
  to contain the following:
 
      /var/log/unattended-upgrades/unattended-upgrades.log
      /var/log/unattended-upgrades/unattended-upgrades-dpkg.log
      /var/log/unattended-upgrades/unattended-upgrades-shutdown.log
      { 
        rotate 4
        monthly
        compress
        missingok
        notifempty
      }

* Test

  Manually run

      sudo unattended-upgrade -d

  and confirm output was written logs in the /var/log/unattended-upgrades directory.

<a name="manualupdates"></a>
-------------------------------------
Manual updates and reboot
-------------------------------------

The goal of the automated updates is to prevent the machines from falling too
far behind with updates and security patches. The automation script does not
remove unused packages, purge the cache or reboot the machines. Manual updates
should be run ~ once a month to bring the machines up to the most current state.

1. Announce the outage on bioc-devel and devteam or slack 

2. Confirm a back-up exists

    Most EC2 instances have automated snapshots. The snapshot schedule is 
    specified in the instance tag with key 'scheduler:ebs-snapshot'. It's best
    to schedule an update soon after a recent snapshot is taken.

    If a recent snapshot does not exist manually create a snapshot or
    AMI from the running instance.

3. Update

    If the primary instance has been updated before with no problems and little
    down time it's safe to do updates directly on the primary.

    If the updates involve an OS upgrade or other substantial changes it's safer
    to create a secondary instance from the snapshot or AMI and perform the
    updates on the secondary.

        sudo apt list --installed > OldVersions.txt
        sudo apt-get update  (updates list of available packages)
        sudo apt-get upgrade (installs the newer versions)

4. Packages 'kept back'

    After running `apt-get upgrade` sometimes a number of packages will
    be marked as 'kept back' and not installed. This means dependencies 
    have changed on one or more of the installed packages so a new package 
    must be installed to perform the upgrade.

    Installing these 'kep back' packages should be approached with some 
    caution. In general `apt-get dist-upgrade` should be avoided. This
    post discusses some options:

    https://askubuntu.com/questions/601/the-following-packages-have-been-kept-back-why-and-how-do-i-solve-it

    Installing the packages one by one or as a list is usually a good option:

        sudo apt-get install <single-kept-back-package>
        sudo apt-get install <list-of-kept-back-packages>

5. Reboot

   From the AWS EC2 console select 
 
    'Actions' -> 'Instance State' -> 'Reboot'

6. Remove 'auto-removable' old packages

    The auto-updates do not remove old package versions. In the case
    of kernel updates these can be large and quickly use up disk space.
    It's a good idea to remove these after a reboot (not before) to 
    ensure that the machine does boot into the new kernel.
 
    Log back into the machine and remove old packages: 

        sudo apt list --installed|grep auto-removable
 
    If there is anything to remove:
 
        sudo apt-get autoremove

7. Replace primary with secondary instance

    If a secondary instance was used for updates it should be monitored for a
    few days to make sure all looks good. Updates can then be applied directly
    to the primary or the secondary instance could be used to replace the
    primary.  This scenario isn't appropriate for many of our core instances
    because the data on the secondary will be stale (several days behind the
    primary). 

    In cases where machine replacement is appropriate follow these steps.

    - Find the elastic IP associated with the primary instance in Route 53.
    - Disassociate the elastic IP from the primary instance and associate it
      with the new instance.
    - The secondary instance launched from the snapshot or AMI will have a
      different internal IP (the elastic IP will serve as the new public IP).
      This change in internal IP will cause a problem for the ssh keys on the
      machines that the primary instance communicated with.  Re-establish the ssh
      connections by sshing into each machine remove the line corresponding to
      the old internal IP from the known_hosts file. Depending on the machine
      this may need to be done as the same user that runs the cron jobs.

<a name="alarms"></a>
-------------------------------------
Alarms and metrics for new instances
-------------------------------------

* Alarms

  AWS provides a handful of metrics when a new instance is launched. Alarms can
  be configued for any metric but alarms do cost money. At the very least an
  alarm should be set up for 'status_check_failed'. See one of the existing
  instances for an example of how to set this up.

* Custom metrics on new instances

  Additional OS metrics can be collected by installing AWS scripts on a
  new instance. A cronjob runs every 5 minutes and sends the results back to 
  CloudWatch. The key metrics gained with these scripts are memory and disk 
  use. Following instuctions here to install the scripts:

  http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/mon-scripts.html#mon-scripts-getstarted

<a name="master"></a>
--------------------------
master.bioconductor.org
--------------------------

This instance hosts the website and serves packages available through 
biocLite(). The solr application is used for the website search.

Code:

  https://github.com/Bioconductor/bioconductor.org

* System updates

  Apply updates after the builds have finished. As of this writing a safe
  window is between 5am - 12:45 pm EST; check the crontabs on the master
  builders to confirm.
  - biocadmin on the master build machines
     software 12:45pm EST; experiment data 5:45 EST; annotation 9pm EST
  - biocadmin on staging 
     pushes many things - not sure we can find a window where nothing is done

For master.bioconductor.org: The only build machines that talk to master are the primary 
builders (normally linux builder for devel and release). And the only time they talk to master
is at the end of the propagation scripts. Important: The propagation scripts run from the 
biocadmin account, not from the biocbuild account. See biocadmin crontabs on malbec1 and malbec2 
for the exact times. Right now the times are 12:45pm every day of the week for the software builds, 
and 5:45pm on Mondays, Tuesdays, Thursdays, and Fridays for the other builds. As you can see, they 
always run in the afternoon. All this to say that mornings are safe. No propagation ever before lunch!


* Notes on solr installation

  Previously on boot, the init script started an incompletely configured
  instance of solr. The correctly configured instance had no way to start
  automatically. We had to manually kill the 'bad' solr process and start a
  process for the correctly configured service.

  The problem is that we have two solr installations, one in the correct
  location but incompletely configured (/opt/solr) and one in the wrong
  location but completely configured (/home/webadmin/solr-5.2.1).

  The following was done as a temporary fix:
  - Modify /etc/init.d/solr to (1) point to working install in 
    /home/webadmin/solr-5.2.1/ and not /opt/solr and (2)
    comment out SOLR_ENV; no need to use SOLR_INSTALL_DIR/bin/solr.in.sh,
    defaults are fine.
  - Change ownership on /home/webadmin/solr-5.2.1 to solr:solr
  - Remove this crontab that was doing nothing
    @reboot cd $HOME/solr-5.2.1 && bin/solr start -f > $HOME/solr.log 2>&1

  Current state of things:
  - pid files are written to /home/webadmin/solr-5.2.1/bin
  - log files are written to /home/webadmin/solr-5.2.1/server/logs 

  A more permanent solution would be to update to the current version of
  solr and make these changes:
  - Install software in /opt/solr and change-able data should be in /var/solr
    https://cwiki.apache.org/confluence/display/solr/Taking+Solr+to+Production
  - solr should not own the whole install, just /var/solr
  - Remove everything /home/webadmin/solr-5.2.1 and below
  - Logs and pid files should be written to /var/solr

  Troubleshooting:
  Restart the service
  ```
    sudo systemctl status solr
    sudo systemctl restart solr
  ```
  Stop / start the service on a specific port
  ```
    sudo ./solr stop -p 8983
    ps auxwww | grep solr
    sudo ./solr start -p 8983
  ```
  Logs 
    - /home/webadmin/solr-5.2.1/server/logs (not helpful AFAICT)
    - /var/log/auth.log and /var/log/syslog (more helpful)

<a name="rabbitmq"></a>
--------------------------
rabbitmq.bioconductor.org
--------------------------

Runs the RabbitMQ application used for message passing in the Single Package
Builder.

Code:
  https://github.com/Bioconductor/packagebuilder/blob/master/documentation/Troubleshooting.md

* System updates 

  Can be done at any time but a reboot requires a restart of the following:
  - RabbitMQ docker
  - worker scripts on all build machines
  - scripts on staging
  - might also be worth restarting the serve on issues.bioconductor.org for [issue_tracker_github](https://github.com/Bioconductor/issue_tracker_github/blob/master/NOTES.md)

<a name="staging"></a>
--------------------------
staging.bioconductor.org
--------------------------

Runs a Dijango web app for the SPB. System updates and reboot can happen
anytime. If the pkgbuild user is sending products during reboot the SPB job(s)
may need to be restarted.

Code:

  https://github.com/Bioconductor/bioconductor.org

<a name="annotationhub"></a>
--------------------------
annotationhub.bioconductor.org
--------------------------

Hosts AnnotationHub and ExperimentHub MYSQL production databases. Serves
AnnotationHub and ExperimentHub metadata via apache2. System updates and
reboot can occur at any time.

<a name="delivery"></a>
--------------------------
delivery.bioconductor.org
--------------------------

Manages mail for devteam@bioconductor.org, maintainer@bioconductor.org,
packages@bioconductor.org and "reply-only" message from the support site. Key
services are apache2, postfix and spamassassin.  System updates and reboot can
be done any time.

<a name="issues"></a>
--------------------------
issues.bioconductor.org
--------------------------

Hosts docker containers and github webhook for SPB. System updates and reboot
can be done any time.

Code:

  https://github.com/Bioconductor/issue_tracker_github

<a name="support"></a>
-------------------------------
support.bioconductor.org
-------------------------------

Hosts the support site. Key services are ngnix, postgresql and 
elasticsearch.

Code:

  https://github.com/Bioconductor/support.bioconductor.org

* System Updates:

  It is recommended for System updates to use a clone, test, 
  then roll out changes on the primary instance to minimize downtime
  of main user support forum.

* Create a EC2 clone for testing:

  - Create a recent snapshot if one is not created automatically
  - Create an AMI from the most recent snapshot.
  - Create an instance from the AMI.
  - Create an elastic IP to associate new instance with 
  
  - Edit nginx file located in /home/www/biostar-central/conf/run/site_nginx.conf (see below)
  - Edit settings located in /home/www/biostar-central/conf/run/site_secrets.py (see below)
  - Test that you can view support site on public/elastic IP address
  
 * Run updates with commands in above section 
 
  As a recap as ubuntu user:
```
        sudo apt list --installed > OldVersions.txt
        sudo apt-get update  (updates list of available packages)
        sudo apt-get upgrade (installs the newer versions)
```
 * Reboot instance and restart ngnix
 
   - Reboot the instance through the AWS interface
   - sudo apt-get autoremove
 
 * Editting nginx
 
   Open the nginx file in /home/www/biostar-central/conf/run/site_nginx.conf.
 
   Here  you need to do three things, you use `#` character to comment things out in nginx:
 
     - Locate all `support.bioconductor.org` and replace with the IP address of the instance.
     - Locate all lines containing the `# managed by Certbot` comment and comment them out. They look like:
     
                ssl_certificate /etc/letsencrypt/live/support.bioconductor.org/fullchain.pem; # managed by Certbot
                ssl_certificate_key /etc/letsencrypt/live/support.bioconductor.org/privkey.pem; # managed by Certbot
                include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
                ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
   
      - Locate the last server block starting with `server {` and comment it out.
 
    Run the following the ensure the nginx syntax is okay:
 
       `sudo nginx -t`
      
    Reload and restart nginx:
      
        # Reload
        sudo service nginx reload
      
        # Restart nginx
        sudo service nginx restart


  * Edit settings  
    
    Open the file in /home/www/biostar-central/conf/site_secrets.py
    
    Here you need to do three things:
    
       - Locate `SITE_DOMAIN` and change it to the IP address of the instace 
    
       - Locate these settings and comment them out using `#`:
    
             EMAIL_BACKEND = ...
             EMAIL_HOST = ...
             EMAIL_HOST_USER = ...
             EMAIL_HOST_PASSWORD = ...
      
      Restart the supervisor to apply the changed settings
      
            # Restart the uwsgi worker
            sudo supervisorctl restart engine
            

 * If all is successful repeat on live EC2 instance or if major updates replace with new instance 
  
 * Clean Up elastic ip, testing instance, and ami (if applicable)
 
   - disassociate elastic IP address
   - relesase elastic IP address
   - delete testing EC2 instance
   - delete testing AMI
  
  
  
  <b> Old instructions </b>
  
  - ssh to instance with public IP and stop apache:

         ssh ubuntu@publicIP
         sudo service apache2 stop

  - ubuntu crontab 
    - Disable entry that sends AWS metrics to CloudWatch
  - www-data crontab
    - Change the IP
    - Disable backups to S3
    - Disable file pruning
  - Change hostname and public IP

      The hostname should be changed from 'support' to something like
      'supporttest'. The public IP for the cloned instance can be found in the 
      AWS console after the instance starts up. Note the instance will be 
      assinged a new public IP each time the instance is stoped/re-started.
 
      Make these edits with sudo:
 
      i) Change hostname in these files:

        - /etc/hosts
        - /etc/hostname (replace private IP with hostname)
        - /etc/rc.local
        - /etc/apache2/sites-available/000-default.conf
        - /etc/apache2/sites-available/default-ssl.conf
        - (old) /home/www-data/biostar-central/biostar/settings/base.py
        - /home/www-data/biostar-central/org/bioconductor/bioc_settings.py
        - /home/www-data/biostar-central/live/deploy.env
        - NOTE: Not sure these 2 are necessary but just in case ...
        (old) /home/www-data/biostar-central/live/custom.env.mx
        (old) /home/www-data/biostar-central/live/custom.env.ses
        
 
      ii) Change public IP in these files:

        - /var/www-support-no-https/index.html 
            In this file the hostname must be replaced with the public IP,
        not the new hostname. DNS is not (usually) set up for the test instance
        so the name lookup won't work. If the public IP of the test instance
        is 34.207.62.169 the modified line should look like this
 
            http-equiv="refresh" content="0; url=https://34.207.62.169/"
 
        - /home/www-data/biostar-central/live/custom.env
 
      iii) Change both hostname and public IP in these files: 

        - /home/www-data/biostar-central/index.wsgi
 
  - Disable mail server

      Set a bogus mail host and password in
      /home/www-data/biostar-central/index.wsgi, e.g.,

      os.environ['EMAIL_HOST'] = 'nomail@junk.com'
      os.environ['EMAIL_HOST_PASSWORD'] = 'nopassword'
 
  - Recursively grep for support.bioconductor.org public IP from
     /home/www-data/ to make sure we caught everything. At the time of this
     writing, the public IP for support was 52.3.239.161. It's fine if the
     IP is in backup files or binaries.
 
      sudo grep -R 52.3.239.161 *
 
  - Reboot the instance via the AWS console
 
  - ssh into the instance and confirm apache2 and postgresql are running
 
        sudo service --status-all
 
      If the hostname does not persist after reboot, confirm the new hostname
      is in /etc/hostname and /etc/hosts then run this replacing 'newhostname'
      as appropriate:
 
          sudo hostname newhostname

  - Test http/s in browser
 
      http should redirect to https at which point you'll have to accept
      the certificate to view the web page.

<a name="stats"></a>
--------------------------
stats.bioconductor.org
--------------------------

This machine computes download stats. The stats scripts run every day of the week. 
Only day the stats instance does nothing is on Sunday. So Sundays are safe for reboot. 
You can reboot during the week, but then you must make sure it happens during a period 
of inactivity. There are long periods of inactivity almost every day. `ps -u biocadmin` 
and `ls -ltr ~/cron.log/stats` will tell you if the scripts are currently running. If 
they're not, you might still want to check the crontab to make sure that nothing is about
to start. A reboot takes about 2-4 min. so make sure you reboot at least 5 min. before 
the start of the next cron job
As of Aug 2021, the best window is between 1:15 and 1:55 on Wednesdays

<a name="git"></a>
--------------------------
git.bioconductor.org
--------------------------
This machine is our git repository for all packages and hosts the git 
credentials app. Should be able to update at any time. 


<a name="other"></a>
--------------------------
Other
--------------------------

<b> BiocAnnotationPipelineInstance </b>

This instance is used to generate the annotations during release time and when there
are new ensembl versions.  This machine is only up when needed. Updates can be done
whenever the machine is up.


<b> courses.bioconductor.org </b>

Hosts Ruby app for launching AMIs for Bioconductor courses. This machine
is only up when we have a course. Updates can be done whenever the machine
is up.

Code:

  https://github.com/Bioconductor/coursehelper
  https://github.com/Bioconductor/coursehelper_cookbook
