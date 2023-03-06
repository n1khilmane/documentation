
# coresops.bioconductor.org

This is a site internal to the Bioconductor Core Group. 
It contains information on the group's compuiting infrastructure.

The offical reposititory is located at `https://github.com/Bioconductor/bioc-core-sops.git`.

## Platform

The site is created using [Hugo](https://gohugo.io/) and Google's [docsy](https://docsy.dev) theme.

It is surfaced in Azure as a [Static Web App](https://learn.microsoft.com/en-us/azure/static-web-apps/).

## Adding Content

Most content on this site is markdown but [other formats are supported](https://gohugo.io/content-management/formats/). 
Metadata about the page is stored with the page as [Front Matter](https://gohugo.io/content-management/front-matter/).

These pages are organized accoording  to (`docsy` conventions)[https://www.docsy.dev/docs/adding-content/content/].
Where images or other resources are needed to support a page, they page and its supporting files are organied in a [leaf bundle](https://gohugo.io/content-management/page-bundles/#leaf-bundles).

The site uses the Hugo [data folder](https://gohugo.io/templates/data-templates/#the-data-folder) to support support data sources for tables and lists that are subject to change.
Specifically table of members of the core group, which is stored at `data/members.json`.

### Installation

You can run the site locally using the Azure SWA emulator. The emulator will automatically recognize all content that has been created, deleted, or changed while it is running.

#### Docker Desktop

Install and start [Docker Desktop](https://docs.docker.com/desktop/).

#### Hugo

Install Hugo, by following the [Hugo Installation Instructions](https://gohugo.io/installation/). 

This requires prequisites `npm` and go `golang`. In addition, the following shell code must be run once from the project rooot directory.

```
git submodule update --init --recursive && npm install -D --save autoprefixer && npm install -D --save postcss-cli
```

The simplest installation of `hugo` For macOS is `homebrew`.
```
brew install hugo
```

#### Azure Static Web Apps (SWA) Command Line Tools

Install the Azure command line tool for Static Web Apps.
```
npm install -g @azure/static-web-apps-cli
```
Alternatively, follow the instructions at [SWA Installation ](https://azure.github.io/static-web-apps-cli/).

#### Clone Bioconductor/bioc-core-sops
Next, clone the repo. Then run the one-line script to install prerequeisites.
```
cd <parent-directory-for-local-project>
git clone https://github.com/Bioconductor/bioc-core-sops.git
cd bioconductor
. admin-scripts/load-prerequisites.sh
```

### Running the Site Locally

To run the site locally, from the project's root directory, run this command.
```
swa start
```

This will compile the site and start running it. 
If there are any syntax errors in the content they will be displayed on the console.
The site is available at http://localhost:1313.

A version of the site that emulates authentication is simultaeously available at http://localhost:3000.
If you use the authentication emulator, you will land on the login page.
When you choose your login provider, you will then be presented with a page from the emulator.
Select any user name. Add the role `verified` to the User's roles text box.

## Acknowledgements

The following components are incorporated into this repository. See the Repo links in the caption below for authorship and license information.

| Component | Repo |
|-----------|------|
| hugo | https://github.com/gohugoio/hugo |
| docsy | https://github.com/google/docsy/ |
