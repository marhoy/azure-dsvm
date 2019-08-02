#!/bin/bash

SERVICE_FILE=/lib/systemd/system/jupyterhub.service
JUPYTER_CFG=/etc/jupyterhub/jupyterhub_config.py
JUPYTERHUB_ENV=/data/miniconda/envs/jupyterhub

if [ -f $SERVICE_FILE ]; then
	echo "Changing systemd-file ${SERVICE_FILE}"
	sudo perl -pi -e 's#^ExecStart.*#ExecStart=/data/miniconda/envs/jupyterhub/bin/jupyterhub --log-file=/var/log/jupyterhub.log#' ${SERVICE_FILE}
else
	echo "File not found: ${SERVICE_FILE}"
fi

TMP_FILE=`mktemp`
${JUPYTERHUB_ENV}/bin/jupyterhub --generate-config -f $TMP_FILE

cat <<EOT >> ${TMP_FILE}

# listen on all IP addresses to bypass name resolution. This fixes
# an issue on Azure where, at first boot, the hostname needs to be updated
# by waagent; if JupyterHub tries to resolve its hostname before then,
# the service will fail to start
c.JupyterHub.ip = '0.0.0.0'

# Path to SSL key file for the public facing interface of the proxy
#
c.JupyterHub.ssl_key = '/etc/jupyterhub/srv/server.key'
c.JupyterHub.ssl_cert = '/etc/jupyterhub/srv/server.crt'

# Extra arguments to be passed to the single-user server
#c.Spawner.args = ['--config=/etc/jupyterhub/default_jupyter_config.py']

# The command used for starting notebooks.
c.Spawner.cmd = ['${JUPYTERHUB_ENV}/bin/jupyterhub-singleuser']
EOT

echo "Moving $TMP_FILE to $JUPYTER_CFG"
sudo mv $TMP_FILE $JUPYTER_CFG



echo "Restarting Jupyter Hub"
sudo systemctl daemon-reload
sudo systemctl stop jupyterhub
sudo systemctl start jupyterhub
