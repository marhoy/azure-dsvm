#!/bin/bash

INSTALL_PATH=/data/miniconda
ANACONDA_VERSION=2019.07

# Download and install the latest version of Miniconda
curl -o Miniconda.sh -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda.sh -b -f -p $INSTALL_PATH
rm Miniconda.sh

# Activate base environment and update conda
source ${INSTALL_PATH}/etc/profile.d/conda.sh
conda activate base
conda update -y conda

# Update global conda.sh
sudo ln -sf ${INSTALL_PATH}/etc/profile.d/conda.sh /etc/profile.d/conda.sh

# Create environment for running jupyterhub
conda create -y -n jupyterhub -c defaults -c conda-forge \
	jupyterhub \
	sudospawner \
	jupyter_contrib_nbextensions \
	ipywidgets \
	ipyleaflet \
	nbdime \
	rise \
	git \
	notebook=5.7.8

# Create environment for running Data Science projects
conda create -y -n anac_${ANACONDA_VERSION} -c defaults -c conda-forge \
	anaconda=${ANACONDA_VERSION} \
	keras \
	tensorflow-gpu \
	lightgbm \
	xgboost \
	plotly \
	dash \
	ipyleaflet \
	folium \
	gmaps \
	tqdm \
	conda-build \
	setuptools_scm \
	pypandoc \
	docopt \
	git \
	cookiecutter \
	connexion \
	geopy \
	python-geohash \
	gdal \
	pyshp \
	shapely \

# Add the kernel from the above environment to the Jupyter list
echo "Adding new kernel to JupyterHub"
KERNEL_DIR=${INSTALL_PATH}/envs/anac_${ANACONDA_VERSION}/share/jupyter/kernels/python3
TMP_KERNEL=`mktemp`
jq --arg name "Anaconda ${ANACONDA_VERSION}" '
        .display_name |= $name
' ${KERNEL_DIR}/kernel.json > ${TMP_KERNEL} && mv ${TMP_KERNEL} ${KERNEL_DIR}/kernel.json

conda activate jupyterhub
jupyter-kernelspec install ${KERNEL_DIR} --name "anac_${ANACONDA_VERSION}" --prefix ${INSTALL_PATH}/envs/jupyterhub/


