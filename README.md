# azure-dsvm
Setting up an Azure Data Science Virtual Machine.

These are things you might want to do after spinning up a fresh DSVM:

## Upgrade all system packages to latest versions:
```bash
sudo apt-get update && sudo apt-get upgrade && sudo apt-get dist-upgrade
```

## Install your own Miniconda, JupyterHub and Anaconda
Use/run the script [anaconda_install.sh](anaconda_install.sh) to:
1. Download and install the latest version of Miniconda
1. Create a conda environment for running JupyterHub
1. Create a conda environment with the latest version of Anaconda plus some additional packages that are useful

## Replace the preinstalled JupyterHub
Use/run the script [change_jupyterhub.sh](change_jupyterhub.sh) to:
1. Replace the systemd unit file for jupyterhub, so it starts our newly installed server
1. Copy standard configuration files to ```/etc/jupyterhub```

NOTE: After a major upgrade of jupyterhub, it is sometimes necessary to do ```jupyterhub upgrade-db```. The output of jupyterhub is logged to syslog, use ```journalctl -fu jupyterhub``` to see output.


## Create an SSL certificate for JupyterHub
If you want to set up an [SSL certificate for the JupyterHub server, see this description](SSL_certificate_jupyterhub.md).


## Build and install aic-packages
Use/run the script [build_install_aictools.sh](build_install_aictools.sh) to build and install conda-packages of the aictools.
