#!/bin/bash

SYSTEMD_DIR=/lib/systemd/system/
JUPYTER_CFG=/etc/jupyterhub
JUPYTERHUB_ENV=/data/miniconda/envs/jupyterhub

echo "Copying configuration files to $JUPYTER_CFG"
sudo cp jupyterhub_config.py $JUPYTER_CFG
sudo cp jupyter_notebook_config.py $JUPYTER_CFG

echo "Replacing systemd unit file"
sudo cp jupyterhub.service $SYSTEMD_DIR
sudo rm -f /var/log/jupyterhub.log

echo "Restarting Jupyter Hub"
sudo systemctl daemon-reload
sudo systemctl stop jupyterhub
sudo systemctl start jupyterhub
