#!/bin/bash

export INSTALL_PATH=/data/miniconda
export ANACONDA_VERSION=2019.10
export VIRTUALENV_NAME=anac_${ANACONDA_VERSION}

# Create INSTALL_PATH if needed
sudo mkdir -p $INSTALL_PATH
sudo chown root.sudo $INSTALL_PATH
sudo chmod 2775 $INSTALL_PATH

# Download and install the latest version of Miniconda
curl -o Miniconda.sh -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda.sh -b -f -p $INSTALL_PATH
rm Miniconda.sh

# Activate base environment and update conda
source ${INSTALL_PATH}/etc/profile.d/conda.sh
conda activate base
conda update -y --all

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
	notebook

# Create environment for running Data Science projects
conda create -y -n ${VIRTUALENV_NAME} -c defaults -c conda-forge \
	anaconda=${ANACONDA_VERSION} \
	tensorflow-gpu \
	pydot \
	lightgbm \
	xgboost \
	catboost \
	plotly \
	dash \
	ipyleaflet \
	folium \
	gmaps \
	conda-build \
	conda-verify \
	ripgrep \
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
	spacy \
	gensim \


# Add the kernel from the above environment to the Jupyter list
echo "Adding new kernel to JupyterHub"
export KERNEL_DIR=${INSTALL_PATH}/envs/${VIRTUALENV_NAME}/share/jupyter/kernels/python3
export TMP_KERNEL=${KERNEL_DIR}/kernel.json.new
jq --arg name "Anaconda ${ANACONDA_VERSION}" '
        .display_name |= $name
' ${KERNEL_DIR}/kernel.json > ${TMP_KERNEL} && mv ${TMP_KERNEL} ${KERNEL_DIR}/kernel.json

conda activate jupyterhub
jupyter-kernelspec install ${KERNEL_DIR} --name "${VIRTUALENV_NAME}" --prefix ${INSTALL_PATH}/envs/jupyterhub/
