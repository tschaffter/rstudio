# RStudio

[![GitHub Stars](https://img.shields.io/github/stars/tschaffter/rstudio.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github)](https://github.com/tschaffter/rstudio)
[![GitHub Release](https://img.shields.io/github/release/tschaffter/rstudio.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github)](https://github.com/tschaffter/rstudio/releases)
[![Docker Pulls](https://img.shields.io/docker/pulls/tschaffter/rstudio.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=pulls&logo=docker)](https://hub.docker.com/r/tschaffter/rstudio)
[![GitHub CI](https://img.shields.io/github/workflow/status/tschaffter/rstudio/ci.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github)](https://github.com/tschaffter/rstudio)
[![GitHub License](https://img.shields.io/github/license/tschaffter/rstudio.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github)](https://github.com/tschaffter/rstudio)

Base image with RStudio and Conda.

## Specifications

- Extends the Docker image [rocker/rstudio]
- Includes R packages required to
  - render HTML notebooks
  - use Python/conda (`reticulate`)
- Includes [Miniconda]

## Quickstart

    docker run --rm -p 8787:8787 -e PASSWORD=yourpassword tschaffter/rstudio

## Change the default username

The default username set by [rocker/rstudio] is `rstudio`. It is recommended to
use a different username for better security. This is achieved by setting the
environment variable `USER`

    docker run --rm -p 8787:8787 \
        --name rstudio \
        -e USER=yourusername \
        -e PASSWORD=yourpassword \
        tschaffter/rstudio

## Set user / group identifiers

When using volumes (`-v` flags) permissions issues can arise between the host OS
and the container, [rocker/rstudio] avoid this issue by allowing you to specify
the user `USERID` and group `GROUPID`.

Ensure any volume directories on the host are owned by the same user you specify
and any permissions issues will vanish like magic.

In this instance `USERID=1000` and `GROUPID=1000`, to find yours use id user as
below:

    $ id username
    uid=1000(abc) gid=1000(abc) groups=1000(abc)

## Give the user root permissions

Set the environment variable `ROOT=true` (default is `false`).

## Set Synapse credentials

Set the environment variables `SYNAPSE_USERNAME` and `SYNAPSE_API_KEY`. If both
variables are set, they will be used to create the configuration file
`~/.synapseConfig`.

This Docker image comes with [Miniconda] installed (see below) and a conda
environment named `sage`. This environment provides the [Synapse Python client]
that you can use to interact with the collaborative platform [Synapse].

## Start RStudio with docker-compose

This repository provides a `docker-compose.yml` to enable you to store your
configuration variables to file and start RStudio with a single command.

1. Copy *rstudio-variables.env.sample* to *rstudio-variables.env*
2. Update the configuration in *rstudio-variables.env*
3. Start RStudio

        docker-compose up -d

## Access logs

Follow the logs using `docker logs`

    docker logs --follow rstudio

Rotating log files are available in `/var/log/rstudio`.

## Using Conda

### From the terminal

1. Attach to the RStudio container

        docker exec -it rstudio bash

2. List conda environments

        conda env list

3. Activate an environment (e.g. `sage`)

        conda activate sage

> Note: Use `conda config --set auto_activate_base false` to prevent conda from
automatically activating the default environment after logging in.

### Using R

Run the following code in RStudio to activate the conda environment `sage` that
comes pre-installed with this Docker image.

    > library(reticulate)
    > conda_list()
        name                              python
    1 miniconda           /opt/miniconda/bin/python
    2      sage /opt/miniconda/envs/sage/bin/python
    > use_condaenv("sage", required = TRUE)

If you have specified the environment variables `SYNAPSE_USERNAME` and `SYNAPSE_API_KEY`, run the code below to import the [Synapse Python client] and
login to Synapse.

    > synapseclient <- reticulate::import('synapseclient')
    > syn <- synapseclient$Synapse()
    > syn$login()
    Welcome, Thomas Schaffter!

<!-- Definitions -->

[rocker/rstudio]: https://hub.docker.com/r/rocker/rstudio
[Miniconda]: https://docs.conda.io/en/latest/miniconda.html
[synapse]: https://www.synapse.org/
[Synapse Python client]: https://pypi.org/project/synapseclient/