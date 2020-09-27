# RStudio

[![GitHub Stars](https://img.shields.io/github/stars/tschaffter/rstudio.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github)](https://github.com/tschaffter/rstudio)
[![GitHub Release](https://img.shields.io/github/release/tschaffter/rstudio.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github)](https://github.com/tschaffter/rstudio/releases)
[![Docker Pulls](https://img.shields.io/docker/pulls/tschaffter/rstudio.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=pulls&logo=docker)](https://hub.docker.com/r/tschaffter/rstudio)
[![GitHub CI](https://img.shields.io/github/workflow/status/tschaffter/rstudio/ci.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github)](https://github.com/tschaffter/rstudio)
[![GitHub License](https://img.shields.io/github/license/tschaffter/rstudio.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github)](https://github.com/tschaffter/rstudio)

RStudio with conda support and useful packages.

## Motivation

TBA

## Specifications

- Extends the Docker image [rocker/rstudio]

## Quickstart

    docker run --rm -p 8787:8787 -e PASSWORD=yourpassword tschaffter/rstudio

## Change the default username

The default username set by [rocker/rstudio] is `rstudio`. It is recommended to
use a different username for better security. This is achieved by setting the
environment variable `USER`

    docker run --rm -p 8787:8787 \
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

<!-- Definitions -->

[rocker/rstudio]: https://hub.docker.com/r/rocker/rstudio