---
title: "Getting started with the Azure Kubernetes Service"
linktitle: "K8S AKS"
date: 2023-08-23
description: "A practical guide to getting started with Kubernetes on Azure for Bioconductor."
---

{{% pageinfo %}}
This document provides a practical step-by-step guide for getting started with the Azure Kubernetes Service.
{{% /pageinfo %}}


## General Context

This document was created in the context of exploring usage of AKS within the Microsoft allocation available on August 2023.

## Prerequisites

This document assumes that you have the Azure CLI installed, that you are logged in (`az login`), and that you have access to the `bioconductor` resource group. See [Microsoft's documentation on installing the Azure CLI for your operating system](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli).

## Connecting to an AKS cluster

### Creating a cluster (not often needed)
See the [Azure documentation](https://learn.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-create) for a full list of options.
```
RESOURCE_GROUP=bioconductor
CLUSTER_NAME=bioc-aug2023-aks
az aks create -g $RESOURCE_GROUP -n $CLUSTER_NAME --node-vm-size Standard_B2s --node-count 2
```

### Connecting to a cluster / Kubeconfig basics
This command needs to be run at least once, to get the kubeconfig from the AKS cluster, and rerun any time `~/.kube/config` is overwritten (eg: copying a Jetstream RKE Kubeconfig).
```
RESOURCE_GROUP=bioconductor
CLUSTER_NAME=bioc-aug2023-aks
az aks get-credentials -g $RESOURCE_GROUP -n $CLUSTER_NAME
```

#### Switing contexts
The above command merges and AKS kubeconfig into your kubeconfig context. You can switch back and forth between it, docker-desktop cluster, and an RKE Jetstream cluster (generally named `local`) by switching contexts. See the [cheat sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/#kubectl-context-and-configuration) for more helpful config commands.

Notably, you can see contexts with `kubectl config get-contexts` and switch contexts with
```
# Switch to AKS
kubectl config use-context bioc-aug2023-aks
# Switch to Jetstream RKE
kubectl config use-context local
# Switch to docker-desktop
kubectl config use-context docker-desktop
```

### Using the MS Azure Web Portal
You may access the portal by going to [portal.azure.com](portal.azure.com). You may need to change your active directory if your institution uses a Microsoft identity. You may do so by clicking on your account in the top right corner, then "[Switch Directory](https://ms.portal.azure.com/#settings/directory)". The [AKS cluster as of Aug 2023](https://ms.portal.azure.com/#@microsoft.onmicrosoft.com/resource/subscriptions/b169b46b-07a3-47dd-9e01-4dd36f2b6c3b/resourceGroups/bioconductor/providers/Microsoft.ContainerService/managedClusters/bioc-aug2023-aks/workloads) is in the Microsoft directory.

Before you can see Kubernetes resources in the portal, you must assign yourself the appropriate roles in the cluster. The may use your email or Object ID, which will generally also be printed in the error message when resources cannot be accessed in the portal. The below code will give Cluster Admin role. See the [Kubernetes documentation on RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) to further customize roles.

```
MS_USER_ID=amahmoud2@bwh.harvard.edu
cat << EOF > clusterrolebinding-admin.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: aks-cluster-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: "$MS_USER_ID"
EOF

kubectl apply -f clusterrolebinding-admin.yaml
```

#### Storage Classes (optional)
[Storage classes](https://kubernetes.io/docs/concepts/storage/storage-classes/) are needed in a Kubernetes cluster to provision [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) out of Persistent Volume Claims defined in application charts. The two main storage class types often used are `ReadWriteMany` (eg: Network File System) which can be accessed by multiple nodes simultaneously, and `ReadWriteOnce` which may only be accessed by a node at a time. AKS comes preloaded with a few storage classes. Below is an example of a custom NFS storage class using the Azure Files service, which notably allows adding custom NFS mount options.

```
cat << "EOF" > storageclass-azure-files-nfs.yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: nfs
provisioner: file.csi.azure.com # replace with "kubernetes.io/azure-file" if aks version is less than 1.21
allowVolumeExpansion: true
mountOptions:
 - dir_mode=0777
 - file_mode=0777
 - uid=0
 - gid=0
 - mfsymlinks
 - cache=strict
 - actimeo=30
parameters:
  skuName: Standard_LRS
EOF

kubectl apply -f storageclass-azure-files-nfs.yaml
```

### Useful charts for any cluster
Some charts are useful for any Kubernetes cluster. Since AKS already has an Azure Files storage class for a managed NFS service, the two remaining charts are `cert-manager` for automatic certificates creation and rotation, and an `ingress-controller` to manage ingress resources in the cluster.

```
kubectl create ns cert-manager

helm repo add jetstack https://charts.jetstack.io

helm repo update

cat << "EOF" > cert-manager.vals
ingressShim:
  defaultIssuerKind: ClusterIssuer
  defaultIssuerName: letsencrypt-prod
webhook:
  enabled: false
EOF


helm upgrade cert-manager jetstack/cert-manager --install --create-namespace --wait --namespace cert-manager --set installCRDs=true -f cert-manager.vals
```

In order to be able to generate wildcard certificates, an authenticated Cluster Issuer is needed. THE CODE BELOW REQUIRES PASTING SOME CONTENT FROM BITWARDEN.

```
cat << "EOF" > cert-manager-secrets.yaml
[REPLACE WITH PASTED CONTENT]
EOF

kubectl apply -n cert-manager -f cert-manager-secrets.yaml

rm cert-manager-secrets.yaml

cat << "EOF" > cert-manager-clusterissuer-ssl-wildcard.yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ssl-wildcard
spec:
  acme:
    externalAccountBinding:
      keyAlgorithm: HS256
      keyID: m0VEE6v-DQRRVV246ybWKA
      keySecretRef:
        key: secret
        name: zero-sll-eabsecret
    privateKeySecretRef:
      name: zerossl-wildcard
    server: https://acme.zerossl.com/v2/DV90
    solvers:
    - dns01:
        route53:
          accessKeyID: AKIAYCRNEW6VNPTIC7E7
          region: us-east-1
          secretAccessKeySecretRef:
            key: AWS_SECRET_KEY_ID
            name: cert-manager-k8s-aws
EOF

kubectl apply -n cert-manager -f cert-manager-clusterissuer-ssl-wildcard.yaml
```

An NGINX ingress controller will allow a variety of subdomains to easily be routed to the same cluster address, load balanced across all cluster nodes, and then routed to the appropriate application based on ingress resources defined in the cluster. Along with `cert-manager`, this will allow for out-of-the box definition of any ingress endpoint in seconds!

```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

UNIQUE_DNS_PREFIX=biocingresscontroller

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --create-namespace \
  --namespace ingress-basic \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-dns-label-name"=$UNIQUE_DNS_PREFIX \
  --set controller.kind="DaemonSet" \
  --set controller.hostNetwork=true \
  --set controller.hostPort.enabled=true \
  --set controller.service.type="LoadBalancer" \
  --set controller.ingressClassResource.default=true \
  --set controller.watchIngressWithoutClass=true \
  --set controller.config.use-forwarded-headers=true
```

The above will create a loadbalancer that exposes the ingress controller for the cluster at a randomly assigned ip as well as $UNIQUE_DNS_PREFIX.$LOCATION.cloudapp.azure.com in this case biocingresscontroller.eastus.cloudapp.azure.com


All apps launched in the cluster at a xxx.bioconductor.org subdomain will need a record in Route53 for that  subdomain, specifically routing the subdomain to biocingresscontroller.eastus.cloudapps.azure.com with a Simple Routing CNAME route rule.


