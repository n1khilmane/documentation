
# coresops.bioconductor.org

This is a site internal to the Bioconductor Core Group. 
It contains information on the group's compuiting infrastructure.

The offical reposititory is located at `https://github.com/Bioconductor/bioc-core-sops.git`.

## Platform

The site is created using [Hugo](https://gohugo.io/) and Google's [docsy](https://docsy.dev) theme.

It is surfaced in Azure as a [Static Web App](https://learn.microsoft.com/en-us/azure/static-web-apps/).

## Adding Content

TODO

### Installation

You can run the site locally using the Azure SWA emulator. The emulator will automatically recognize all content that has been created, deleted, or changed while it is running.

#### Docker Desktop

Install and start [Docker Desktop](https://docs.docker.com/desktop/).

#### Hugo

Install Hugo, by following the [Hugo Installation Instructions](https://gohugo.io/installation/). For macOS,
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

TODO - Fill in and add screen shot.
Select any user name. Add the role `verified` to the User's roles text box.

## Acknowledgements

| Component | Repo |
|-----------|------|
| hugo | https://github.com/gohugoio/hugo |
| docsy | https://github.com/google/docsy/ |
| hugo-pdf shortcode | https://github.com/sytranvn/hugo-pdf |
