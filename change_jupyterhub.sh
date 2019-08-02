#!/bin/bash

SERVICE_FILE=/lib/systemd/system/jupyterhub.service

if [ -f $SERVICE_FILE ]; then
        echo "Changing systemd-file ${SERVICE_FILE}"
        sudo perl -pi -e 's#^ExecStart.*#ExecStart=/data/miniconda/envs/jupyterhub/bin/jupyterhub --log-file=/var/log/jupyterhub.log#' ${SERVICE_FILE}
else
        echo "File not found: ${SERVICE_FILE}"
fi
