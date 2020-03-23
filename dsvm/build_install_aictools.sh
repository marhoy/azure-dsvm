#!/bin/bash

git clone dnvgl-one@vs-ssh.visualstudio.com:v3/dnvgl-one/Digital%20Technology%20Centre/aictools

source /data/miniconda/etc/profile.d/conda.sh
conda activate anac_2019.07

conda build -c defaults -c conda-forge aictools/conda-recipes/aictools-core
conda build -c defaults -c conda-forge aictools/conda-recipes/aictools-veracity
conda build purge

conda install -c ${CONDA_PREFIX}/conda-bld aictools-core
conda install -c ${CONDA_PREFIX}/conda-bld -c defaults -c conda-forge aictools-veracity
