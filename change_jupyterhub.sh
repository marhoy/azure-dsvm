#!/bin/bash

SERVICE_FILE=/lib/systemd/system/jupyterhub.service
JUPYTER_CFG=/etc/jupyterhub
JUPYTERHUB_ENV=/data/miniconda/envs/jupyterhub

if [ -f $SERVICE_FILE ]; then
	echo "Changing systemd-file ${SERVICE_FILE}"
	sudo perl -pi -e 's#^ExecStart.*#ExecStart=/data/miniconda/envs/jupyterhub/bin/jupyterhub --log-file=/var/log/jupyterhub.log#' ${SERVICE_FILE}
else
	echo "File not found: ${SERVICE_FILE}"
fi

echo "Copying configuration files to $JUPYTER_CFG"
sudo cp jupyterhub_config.py $JUPYTER_CFG
sudo cp jupyter_notebook_config.py $JUPYTER_CFG

echo "Restarting Jupyter Hub"
sudo systemctl daemon-reload
sudo systemctl stop jupyterhub
sudo systemctl start jupyterhub
