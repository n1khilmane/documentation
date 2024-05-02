---
date: 2024-02-13
title: "Biostar local deployment details"
linkTitle: "Local Deployment"
draft: true
description: >
  Details on specific operational information for deploying biostar in the Bioconductor core environment.
---

# Installation

# Setting Up Virtual Environment and Cloning Repository

## 1. Install Miniconda
1. Download Miniconda from [here](https://docs.conda.io/en/latest/miniconda.html).
2. Run the following command (replace `installation_file.sh` with your installation file):
    ```
    $ bash installation_file.sh
    ```

## 2. Create Virtual Environment
1. Once Miniconda is installed, create a virtual environment named `engine`:
    ```
    $ conda create -n engine python=3.7
    ```

## 3. Activate Virtual Environment
1. Activate the virtual environment by running:
    ```
    $ conda activate engine
    ```

## 4. Clone or Pull Repository
1. Clone the repository by executing the following command:
    ```
    $ git clone https://github.com/ialbert/biostar-central.git  # Clone a new branch
    ```
    Or pull the most recent version of the repository if it already exists:
    ```
    $ git pull https://github.com/ialbert/biostar-central.git   # Pull into an existing
    ```


# Installing Dependencies

##  Activate Virtual Environment
1. Activate the `engine` virtual environment:
    ```
    $ conda activate engine
    ```

## Install Python Requirements
1. Navigate to the `biostar-central` directory.
2. Install Python requirements using pip:
    ```
    $ pip install -r conf/requirements.txt
    ```

## Add Conda Channels
1. Add the following Conda channels:
    ```
    $ conda config --add channels r
    $ conda config --add channels conda-forge
    $ conda config --add channels bioconda
    ```

## Install Conda Requirements
1. Install all Anaconda requirements using the following command:
    ```
    $ conda install --file conf/conda-packages.txt
    ```

## Database Migration and Static Files Collection
1. After installing dependencies, perform database migration and collect static files as necessary.



## 3. Migrations and Tests

### Activate Virtual Environment
1. Activate the `engine` virtual environment:
    ```
    $ conda activate engine
    ```

### Migrate Forum App
1. Migrate the forum app with the following command:
    ```
    $ python manage.py migrate --settings themes.bioconductor.settings
    ```

### Collect Static Files
1. Collect static files for the forum app:
    ```
    $ python manage.py collectstatic --noinput -v 0 --settings themes.bioconductor.settings
    ```

### Makefile Command (Optional)
1. Use the `Makefile` command to migrate and collect static files in one shot:
    ```
    $ make bioconductor init  
    ```

### Run Tests
1. To ensure installation and migration was successful, run tests:
    ```
    $ make bioconductor test  
    ```

## Loading Demo Data and Starting Local Server

### Activate Virtual Environment
1. Activate the `engine` virtual environment:
    ```
    $ conda activate engine
    ```

### Load Sample Data
1. Load sample data into the forum:
    ```
    $ make bioconductor startup  
    ```

### Start Local Server
1. Start a local server:
    ```
    $ make bioconductor serve    
    ```

### Load Data and Start Local Server (Alternative)
1. Load data and start a local server with one command:
    ```
    $ make bioconductor demo     
    ```

## Default User for Local Testing Site

### Admin Credentials
- **Username:** `admin@localhost`
- **Password:** `<Set by DEFAULT_ADMIN_PASSWORD attribute>`

## Customize Settings

### Creating Custom Settings File
1. Create a separate settings file, e.g., `my_settings.py`.
2. Import all default settings and override the fields you wish to customize.
    ```
    # Import all default settings.
    from themes.bioconductor.settings import *
    
    # Override the settings you wish to customize.
    ADMIN_PASSWORD = "foopass"
    ```

### Apply Custom Settings
1. Apply the settings file with the following command:
    ```
    $ python manage.py runserver --settings my_settings.py
    ```

## Deploying Local Changes to Remote Server

### Activate Virtual Environment
1. Activate the `engine` virtual environment:
    ```
    $ conda activate engine
    ```

### Deploy Changes to Remote Server
1. Ensure all changes have been committed to the GitHub repository.
2. Enter the following command to deploy local changes to the remote server:
    ```
    $ make bioconductor deploy REPO=<github_repo_url_to_deploy>  
    ```

## Changing the Top Banner

### Editing Top Banner Locally
1. To locally test and edit the top banner, edit `themes/bioconductor/templates/banners/top-banners.html`.

### Viewing Changes
1. Restart the server to see changes in `top-banners.html`:
    ```
    $ sudo supervisorctl restart forum
    ```


