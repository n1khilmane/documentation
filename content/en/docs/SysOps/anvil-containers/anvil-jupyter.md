---
title: "Updating BiocAnVIL Jupyter container"
linkTitle: "BiocAnVIL Jupyter SOP"
date: 2023-08-23
description: "Instructions from shared SOP with Broad Institute, on needed process to update BiocAnVIL Jupyter container"
---

{{% pageinfo %}}
This document provides instructions for the Bioconductor side, and links to the SOP agreed upon with the Broad Institute for updating the BiocAnVIL Jupyter container
{{% /pageinfo %}}


## General Guidelines and Context

The original Bioconductor-Terra SOP can be found in this [Google Doc](https://docs.google.com/document/d/1-TVfD9GisifdgB9rjM5Q2ieCri1NPEC8cgHZTy8fWeo/edit?usp=sharing). The shared SOP was first created by Nitesh on the Bioconductor side and Qi on the Terra/Broad side, and has not been formally updated with the exception of changes coming up during Slack conversations on the #bioconductor channel in the AnVIL Slack.

I will attempt to extract all instructions for the Bioconductor side into this document and keep it up to date going forward.

The BiocAnVIL Jupyter container is "owned" by Bioconductor, as worded in the shared SOP doc. However, the container is built as part of the Broad's [DataBiosphere/terra-docker](https://github.com/DataBiosphere/terra-docker) repository, and relies on Broad folks to approve and propagate changes. The built container is also hosted within a [Broad-owned bucket](https://console.cloud.google.com/gcr/images/broad-dsp-gcr-public/US/terra-jupyter-bioconductor). 

While the user-facing container is [terra-jupyter-bioconductor](https://github.com/DataBiosphere/terra-docker/blob/master/terra-jupyter-bioconductor/), the entirety of the relevant code is in [terra-jupyter-r](https://github.com/DataBiosphere/terra-docker/blob/master/terra-jupyter-r), as the former's [Dockerfile](https://github.com/DataBiosphere/terra-docker/blob/master/terra-jupyter-bioconductor/Dockerfile) inherits and renames the R container. I believe this is due to the fact that the R container historically only included base R while the Bioconductor container added `BiocManager` and `AnVIL` packages. The Bioconductor additions have since been merged into the R container.

## Updating the Dockerfile

Most if not all changes to the Jupyter container are done by modifying this [Dockerfile](https://github.com/DataBiosphere/terra-docker/blob/master/terra-jupyter-r/Dockerfile).




