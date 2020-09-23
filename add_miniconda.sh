#!/usr/bin/with-contenv bash

VERSION=${MINICONDA_VERSION:=py38_4.8.3}

if [ ! -d "/opt/miniconda" ]
then
    echo "Adding Miniconda ${VERSION} to container"

    curl -fsSLO https://repo.anaconda.com/miniconda/Miniconda3-${VERSION}-Linux-x86_64.sh
    bash Miniconda3-${VERSION}-Linux-x86_64.sh -b -p /opt/miniconda
    rm -f Miniconda3-${VERSION}-Linux-x86_64.sh

    useradd -s /bin/bash miniconda
    chown -R miniconda:miniconda /opt/miniconda
    chmod -R go-wrX /opt/miniconda
    chmod -R g+rX /opt/miniconda

    # export PATH="${PATH}:/opt/miniconda/bin"
    # TODO: This line set the PATH for next init scripts, but does not affect the
    # system PATH. How to set permanently PATH in s6 init scripts?
    # printf "${PATH}" > /var/run/s6/container_environment/PATH

    # usermod -a -G miniconda test
    usermod -a -G miniconda rstudio

    echo "PATH is $PATH"

    # Create conda environment
    conda env create -f /tmp/conda/synapse.yaml
fi