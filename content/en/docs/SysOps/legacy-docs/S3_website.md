---
title: "Bioconductor S3 Website "
linkTitle: "S3 website"
description: S3 Supplementary storage for www.bioconductor.org
---

The Bioconductor website is located on the master.bioconductor.org EC2
instance and served through CloudFront.

Each new BioC release requires about 100GB and this grows 5-10% with each
release.  This means at release time we need to expand the back-end of master
and then incur additional storage costs relative to the size to the expanded
volume.

The majority of space on master.bioconductor.org is taken up by the source
tarballs and binaries from past releases. These data are static and can be
stored in S3 at a much lower cost than the EBS back-end of an EC2 instance. For
example, at the time of this writing, SSD-backed EBS is $0.10 per GB-month
where are S3 storage costs are $0.023 per GB for the first 50 TB/month. For EBS
you pay for the full allocation regardless of how much is used; for S3 you pay
only for the GB stored.

As an initial pass, old(er) source tarballs and binaries have been moved from
the master.bioconductor.org EC2 instance to the archive.bioconductor.org S3
bucket. CloudFront will still serve these objects to the public but will
retrieve them from the S3 bucket instead of from master.bioconductor.org
directly.

No style files for the website pages were moved to S3. By storing only 
tarballs and binaries in S3 we avoid having a second copy of files that
play a part in generating dynamic content. All style and formatting is still
done on master.bioconductor.org. 

## Table of Contents

- [Configure S3 bucket](#s3bucket)
- [Transfer data from master to S3 bucket](#transferdata)
  - [Modify policy for bioc-website-backup user](#iamuser)
  - [Copy files](#copyfiles)
  - [Remove data from master](#removedata)
- [Modify .htaccess file](#htaccess)

<a name="s3bucket"></a>
## Configure S3 bucket

* Create an S3 bucket named archive.bioconductor.org
* Enable static web hosting in the 'Properties' tab
* In the S3 console, click on the archive.bioconductor.org bucket and go
  to the 'Permissions' tab -> 'Bucket Policy'. Add a policy that 
  allows "GetObject".
```
{
  "Version":"2012-10-17",
  "Statement":[{
      "Sid":"PublicReadGetObject",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::example.com/*"
      ]
    }
  ]
}
```

<a name="transferdata"></a>
## Transfer data from master to S3 bucket

<a name="iamuser"></a>
### Modify policy for bioc-website-backup user

The canonical website files are on master.bioconductor.org at /extra/www/bioc.
A full daily backup is stored in the S3 bucket, bioc-website-backup. The S3 
bucket appears to have some cruft from past years (nothing is ever deleted in 
the daily 'aws s3 sync') so transferring files from master to our
archive.bioconductor.org S3 bucket is cleaner than getting them from
the bioc-website-backup S3 bucket.

The webadmin user on master.bioconductor.org performs the daily backup to the
S3 bucket via cronjob. When the sync happens, the webadmin user uses the AWS
secret key in /home/webadmin/.aws/config and this key is associated with the
bioc-website-backup IAM user. So when the sync happens, webadmin assumes
whatever permissions bioc-website-backup has. Permissions for the
bioc-website-backup user are defined in a policy attached to the user; the
policy is also called bioc-website-backup and can be seen here:

https://console.aws.amazon.com/iam/home?region=us-east-1#/policies/arn:aws:iam::555219204010:policy/bioc-website-backup$jsonEditor

The policy was modified to allow the bioc-website-backup user access to 
write ('put') to the archive.biocondctor.org S3 bucket.

<a name="copyfiles"></a>
### Copy files with aws sync

  Log on to master.bioconductor.org and become webadmin: 

    sudo su - webadmin
    cd /extra/www/bioc

  Transfer BioC 1.8-2.6 (remove --dryrun):

    ## BioC 1.5-1.7 need special treatment because of the simlinks in
    src/contrib. For now we're leaving these on master.

    ## BioC 1.8 - 2.6
    ## This example is for 1.8; replace the 1.8 with each version number
    aws s3 sync /extra/www/bioc/packages/1.8/bioc/bin s3://archive.bioconductor.org/packages/1.8/bioc/bin --no-follow-symlinks --dryrun 
    aws s3 sync /extra/www/bioc/packages/1.8/bioc/src s3://archive.bioconductor.org/packages/1.8/bioc/src --no-follow-symlinks --dryrun 
    aws s3 sync /extra/www/bioc/packages/1.8/data/annotation/src s3://archive.bioconductor.org/packages/1.8/data/annotation/src --no-follow-symlinks --dryrun 
    aws s3 sync /extra/www/bioc/packages/1.8/data/annotation/bin s3://archive.bioconductor.org/packages/1.8/data/annotation/bin --no-follow-symlinks --dryrun 
    aws s3 sync /extra/www/bioc/packages/1.8/data/experiment/src s3://archive.bioconductor.org/packages/1.8/data/experiment/src --no-follow-symlinks --dryrun 
    aws s3 sync /extra/www/bioc/packages/1.8/data/experiment/bin s3://archive.bioconductor.org/packages/1.8/data/experiment/bin --no-follow-symlinks --dryrun 

    ## BioC 2.1 also have an extannotation directory
    aws s3 sync /extra/www/bioc/packages/2.1/data/extannotation/src s3://archive.bioconductor.org/packages/2.1/data/extannotation/src --no-follow-symlinks --dryrun 
    aws s3 sync /extra/www/bioc/packages/2.1/data/extannotation/bin s3://archive.bioconductor.org/packages/2.1/data/extannotation/bin --no-follow-symlinks --dryrun 

    ## BioC 2.13 started having workflows
    aws s3 sync /extra/www/bioc/packages/2.13/workflows/src s3://archive.bioconductor.org/packages/2.13/workflows/src --no-follow-symlinks --dryrun 
    aws s3 sync /extra/www/bioc/packages/2.13/workflows/bin s3://archive.bioconductor.org/packages/2.13/workflows/bin --no-follow-symlinks --dryrun 

    

<a name="removedata"></a>
### Remove data from master

  Once the data are transferred to S3, remove the data from
  master.bioconductor.org in the associated directories:

    /extra/www/bioc/packages/*/bioc/bin
    /extra/www/bioc/packages/*/bioc/src
    /extra/www/bioc/packages/*/data/annotation/bin
    /extra/www/bioc/packages/*/data/annotation/src
    /extra/www/bioc/packages/*/data/experiment/bin
    /extra/www/bioc/packages/*/data/expermient/src
    /extra/www/bioc/packages/*/data/extannotation/bin
    /extra/www/bioc/packages/*/data/extannotation/src
    /extra/www/bioc/packages/*/workflows/bin
    /extra/www/bioc/packages/*/workflows/src


* Note: To purge a bucket (if necessary):

    aws s3 rm s3://archive.bioconductor.org/packages/1.8/ --recursive --dryrun

<a name="htaccess"></a>
## Modify .htaccess file

Redirects from master.biocondcutor.org to the archive.bioconductor.org S3
bucket are handled in the .htaccess file. Location of this file is in git at

https://github.com/Bioconductor/bioconductor.org/blob/master/assets/.htaccess

Don't forget to push to both github AND git.bioconductor.org!

Add the following lines to .htaccess:

    # Redirect BioC versions 1.8-2.6 to static S3 website
    RedirectMatch 301 /packages/(1.[8-9]|2.[0-6])/bioc/src/(.*) http://archive.bioconductor.org.s3-website-us-east-1.amazonaws.com/packages/$1/bioc/src/$2
    RedirectMatch 301 /packages/(1.[8-9]|2.[0-6])/bioc/bin/(.*) http://archive.bioconductor.org.s3-website-us-east-1.amazonaws.com/packages/$1/bioc/bin/$2
    RedirectMatch 301 /packages/(1.[8-9]|2.[0-6])/data/annotation/src/(.*) http://archive.bioconductor.org.s3-website-us-east-1.amazonaws.com/packages/$1/data/annotation/src/$2
    RedirectMatch 301 /packages/(1.[8-9]|2.[0-6])/data/annotation/bin/(.*) http://archive.bioconductor.org.s3-website-us-east-1.amazonaws.com/packages/$1/data/annotation/bin/$2
    RedirectMatch 301 /packages/(1.[8-9]|2.[0-6])/data/experiment/src/(.*) http://archive.bioconductor.org.s3-website-us-east-1.amazonaws.com/packages/$1/data/experiment/src/$2
    RedirectMatch 301 /packages/(1.[8-9]|2.[0-6])/data/experiment/bin/(.*) http://archive.bioconductor.org.s3-website-us-east-1.amazonaws.com/packages/$1/data/experiment/bin/$2
    # BioC 2.1 has an additional extannotation/ directory
    RedirectMatch 301 /packages/2.1/data/extannotation/src/(.*) http://archive.bioconductor.org.s3-website-us-east-1.amazonaws.com/packages/2.1/data/extannotation/src/$1
    RedirectMatch 301 /packages/2.1/data/extannotation/bin/(.*) http://archive.bioconductor.org.s3-website-us-east-1.amazonaws.com/packages/2.1/data/extannotation/bin/$1

No apache restart is required for the changes in .htaccess to take place.
