---
title: "Launching CloudLaunch on Azure Kubernetes Service"
linktitle: "AKS CloudLaunch"
author: Alexandru Mahmoud
date: 2023-08-30
description: "A practical guide to deploying CloudLaunch on Kubernetes on Azure for launching Kubernetes clusters in Bioconductor's Jetstream 2 allocation."
---

{{% pageinfo %}}
This document provides a practical step-by-step guide for getting started with the Azure Kubernetes Service.
{{% /pageinfo %}}


## General Context

This document was created while moving the CloudLaunch instance ([js2launch.bioconductor.org](https://js2launch.bioconductor.org)) to the Microsoft allocation on AKS, in hopes of having more long-term stability, and not having the tool to create new Jetstream clusters rely itself on a Jetstream cluster. That situation was particularly bad in the context of running clusters going down due to a Jetstream error, and losing the ability to launch a new cluster and redeploy the resources.

[CloudLaunch](https://github.com/galaxyproject/cloudlaunch/) is a Django-based API written in python, allowing deployment of a few applications, notably VMs, Docker images, and Ansible playbooks. CloudLaunch depends on the [CloudBridge](https://github.com/cloudve/cloudbridge) library, allowing a single code to communicate with various clouds via configuration changes.

## Prerequisites

This document assumes you have a running Kubernetes cluster, notably an Azure Kubernetes Service cluster, with some notes on running in other environments. You may follow one of the related documents for getting started with Kubernetes:
- [Getting started with the Azure Kubernetes Service](k8s-aks.md)

This document also assumes you have access to the Route 53 service in Bioconductor's Amazon Web Services, where routing subdomains will take place.

This document assumes that you have the Azure CLI installed, that you are logged in (`az login`), and that you have access to the `bioconductor` resource group. See [Microsoft's documentation on installing the Azure CLI for your operating system](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli).

You must also have `kubectl` installed, which might have already been installed by another software (eg: Azure, AWS, Docker). You may check with `kubectl --version`, and follow the [Kubernetes documentation](https://kubernetes.io/docs/tasks/tools/) to install `kubectl` on your Operating System (or re-install, which is recommended if your Client version is under 1.24).

Additionally, `helm` is required for installing groups of Kubernetes reources bundled as applications. You may follow the [Helm documentation](https://helm.sh/docs/intro/install/) to install, and use `helm version` to check.

## Route 53 Subdomain Route
When using an ingress and subdomain, CloudLaunch health checks expect the endpoint to properly route before marking the pods healthy, it is thus recommended to create the Route 53 record before starting the deployment.

First, head to the [AWS Console at console.aws.amazon.com](https://console.aws.amazon.com/) and login into the `bioconductor` account with your identity.

You can then head to the [Route 53 Hosted Zones](https://console.aws.amazon.com/route53/v2/hostedzones) where you should see the `bioconductor.org` domain like the screenshot below.

{{ $image := .Resources.GetMatch "k8s-images/route-53-zone.png" }}
<img src="{{ $image.RelPermalink }}" width="{{ $image.Width }}" height="{{ $image.Height }}" alt="Expected Route 53 overview page showing bioconductor.org Hosted Zone">

After clicking on the domain, you should see a list of subdomains and have the ability to create a record. For an AKS cluster, the subdomain must use a CNAME type record, pointing to the `cloudapp.azure.com` domain of the ingress controller. For an RKE Jetstream cluster, the subdomain must use an A record type, pointing to the IP address of the cluster head node. The below screenshots show an example of a record for a dev cloudlaunch instance on the existing AKS cluster.


{{ $image := .Resources.GetMatch "k8s-images/route-53-create-record.png" }}
<img src="{{ $image.RelPermalink }}" width="{{ $image.Width }}" height="{{ $image.Height }}" alt="Expected Route 53 page showing Create a Record button in the bioconductor.org Hosted Zone">
{{ $image := .Resources.GetMatch "k8s-images/route-53-record-details.png" }}
<img src="{{ $image.RelPermalink }}" width="{{ $image.Width }}" height="{{ $image.Height }}" alt="Example Route 53 record details for AKS cluster">


## Connecting to an AKS cluster
The below command assumes proper permissions to the Azure namespace. You may follow the rest of the tutorial with another context (eg: Jetstream RKE) with slight modifications notably to the `storageClass`, and using the cluster head node's IP for the subdomain routing.

```
RESOURCE_GROUP=bioconductor
CLUSTER_NAME=bioc-aug2023-aks
az aks get-credentials -g $RESOURCE_GROUP -n $CLUSTER_NAME
kubectl config use-context bioc-aug2023-aks
```

## Deploying CloudLaunch
<strong>THE CODE BELOW REQUIRES PASTING CONTENT FROM BITWARDEN.</strong> Take note of the admin password, as it will be needed in the next step.
CloudLaunch values include sensitive information, including database secrets. The [CloudLaunch Helm Chart](https://github.com/CloudVE/cloudlaunch-helm) is used, with `--version 0.6.0` as of Aug 2023.
You may note the values include a mention of js2launch.bioconductor.org at various points. You may `sed` them all for a new ingress to deploy a side server at a subdomain.

```
cat << "EOF" > js2launch.vals
[REPLACE WITH PASTED CONTENT]
EOF

helm repo add gxy https://github.com/cloudve/helm-charts/raw/devel
helm repo update

# sed 's/js2launch.bioconductor.org/js2launch.dev.bioconductor.org/g' js2launch.vals

helm upgrade --install --create-namespace -n cloudlaunch js2cloudlaunch gxy/cloudlaunch -f js2launch.vals

rm js2launch.vals
```

Deployment will take a few minutes, as a postgres database needs to first be deployed and created before the API and UI pods get started. After a few minutes, the CloudLaunch app should be available at the chosen subdomain.


## Configuration
After Cloudlaunch is up and running, you must add Cloud and Application configuration to make it usable. You can do so at the admin dashboard at the [`/cloudlaunch/admin`](https://js2launch.bioconductor.org/cloudlaunch/admin) path, where you can login with username `admin` and the password seen in the values copied from the Bitwarden vault.

You can then first head to the [Cloud section](https://js2launch.bioconductor.org/cloudlaunch/admin/djcloudbridge/cloud/) in the admin panel, and click on the Add Cloud button in the top right corner as shown in the screenshot below.

{{ $image := .Resources.GetMatch "k8s-images/cloudlaunch-add-cloud.png" }}
<img src="{{ $image.RelPermalink }}" width="{{ $image.Width }}" height="{{ $image.Height }}" alt="CloudLaunch Add Cloud button in admin panel">

Then choose an OpenStack cloud, and advance to the configuration. You may see the Jetstream 2 configuration as of August 2023 in the screenshot below.

{{ $image := .Resources.GetMatch "k8s-images/cloudlaunch-js2-cloud-details.png" }}
<img src="{{ $image.RelPermalink }}" width="{{ $image.Width }}" height="{{ $image.Height }}" alt="CloudLaunch JS2 Admin Panel Aug 2023">


You must then advance to the [User Profiles section](https://js2launch.bioconductor.org/cloudlaunch/admin/djcloudbridge/userprofile/) to add credentials for the newly added cloud. You may add credentials to the `admin` user which will be used by default in CloudLaunch. Make sure to add credentials under the OpenStack section.
These credentials can be generated from the [OpenStack Jetstream2 portal at js2.jetstream-cloud.org](https://js2.jetstream-cloud.org/) by going to the Application Credentials section under Identity tab, as shown in the screenshot below.

{{ $image := .Resources.GetMatch "k8s-images/js2-app-creds.png" }}
<img src="{{ $image.RelPermalink }}" width="{{ $image.Width }}" height="{{ $image.Height }}" alt="Jetstream2 creating application credentials">

After generating and adding the application credentials to the CloudLaunch user profile, the next step is to add an image for the Ubuntu20 VM image, currently used for the Jetstream2 RKE cluster. You may do so under the [Images section](https://js2launch.bioconductor.org/cloudlaunch/admin/cloudlaunch/image/) in the admin portal, and clicking on the Add Image button in the top right corner, as shown in the screenshot below.

{{ $image := .Resources.GetMatch "k8s-images/cloudlaunch-add-image.png" }}
<img src="{{ $image.RelPermalink }}" width="{{ $image.Width }}" height="{{ $image.Height }}" alt="CloudLaunch admin panel Add Image button">

An updated Image ID must be retrieved from the Jetstream2 OpenStack portal, which can be found under the Images section under the Compute tab, as shown in the screenshot below.

{{ $image := .Resources.GetMatch "k8s-images/js2-images.png" }}
<img src="{{ $image.RelPermalink }}" width="{{ $image.Width }}" height="{{ $image.Height }}" alt="Jetstream2 images page">

After clicking on the desired image name, the ID can be copied from the first field in the image details, as shown in the screenshot below.

{{ $image := .Resources.GetMatch "k8s-images/js2-image-id.png" }}
<img src="{{ $image.RelPermalink }}" width="{{ $image.Width }}" height="{{ $image.Height }}" alt="Jetstream2 image ID example">

After copying the image ID, head back the the Add Image page in CloudLaunch admin panel, and add the pasted ID along with the rest of the configuration as shown below.

{{ $image := .Resources.GetMatch "k8s-images/cloudlaunch-image-details.png" }}
<img src="{{ $image.RelPermalink }}" width="{{ $image.Width }}" height="{{ $image.Height }}" alt="CloudLaunch admin panel ubuntu details">

The final step is setting up CloudLaunch is creating the CloudMan Boot application which will launch the RKE clusters on Jetstream2. Luckily this configuration can be imported and does not need to be manually filled. However, a first application must be added before one can be imported, so start by heading the the [Applications section](https://js2launch.bioconductor.org/cloudlaunch/admin/cloudlaunch/application/) in the admin panel and click on Add Application button in the top right corner. You can then populate the name with a dummy value such as `test` and leave its configuration blank. You can then select the newly added application and choose to Import app data from a URL as shown in the screenshot below, and paste the following URL `https://gist.githubusercontent.com/almahmoud/a9de4094188ca66bf8fa4676eb48a253/raw/c78f8af184db1cf74109cd388a4ebd8c1b781ef2/app-registry.yaml` to import the Kubernetes app for Bioconductor.

{{ $image := .Resources.GetMatch "k8s-images/cloudlaunch-import-apps.png" }}
<img src="{{ $image.RelPermalink }}" width="{{ $image.Width }}" height="{{ $image.Height }}" alt="CloudLaunch import app page">

