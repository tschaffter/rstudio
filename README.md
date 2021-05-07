# RStudio

[![GitHub Release](https://img.shields.io/github/release/Sage-Bionetworks/rstudio.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github)](https://github.com/Sage-Bionetworks/rstudio/releases)
[![GitHub CI](https://img.shields.io/github/workflow/status/Sage-Bionetworks/rstudio/CI.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github)](https://github.com/Sage-Bionetworks/rstudio)
[![GitHub License](https://img.shields.io/github/license/Sage-Bionetworks/rstudio.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github)](https://github.com/Sage-Bionetworks/rstudio/blob/main/LICENSE)
[![Docker Pulls](https://img.shields.io/docker/pulls/sagebionetworks/rstudio.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=pulls&logo=docker)](https://hub.docker.com/r/sagebionetworks/rstudio)

Docker image for analyses using RStudio and Python-Conda

## Motivations

- Provides a versionized development environment (R, Python)
- Renders R notebooks to HTML and PDF programmatically (GH Action, etc.)

## Specification

- Extends the Docker image [rocker/rstudio]
- Behaves the same as [rocker/rstudio] and offer extra features (see below)
- Includes R packages to render HTML notebooks and use Python/conda (`reticulate`)
- Renders HTML and PDF notebooks from .Rmd files programmatically
- Comes with [Miniconda] installed
- Specifies the version of the R packages installed using `renv`
- Uses [GitHub Dependabot] to check Docker and pip dependencies

## Usage

1. Create and edit the file that contains the future environment variables. You
   can initially start RStudio using this configuration as-is.

       cp .env.example .env

2. Start RStudio. Add the option `-d` or `--detach` to run in the background.

       docker-compose up

RStudio is now available at http://localhost. On the login page, enter the
default username (`rstudio`) and the password specified in `.env`.

To stop the API service, enter `Ctrl+C` followed by `docker-compose down`.  If
running in detached mode, you will only need to enter `docker-compose down`.

## Versioning

### GitHub tags

This repository uses [semantic versioning] to track the releases of this
project. This repository uses "non-moving" GitHub tags, that is, a tag will
always point to the same git commit once it has been created.

### Docker tags

The artifact published by this repository is a Docker image. The versions of the
image are aligned with the versions of [rocker/rstudio], not the versions of
Stubby or the GitHub tags of this repository.

The table below describes the image tags available.

| Tag name                        | Moving | Description
|---------------------------------|--------|------------
| `latest`                        | Yes    | Latest stable release.
| `edge`                          | Yes    | Lastest commit made to the default branch.
| `<major>`                       | Yes    | Latest stable release for RStudio version `<major>`.
| `<major>.<minor>`               | Yes    | Latest stable release for RStudio version `<major>.<minor>`.
| `<major>.<minor>.<patch>`       | Yes    | Latest stable release for RStudio version `<major>.<minor>.<patch>`.
| `<major>.<minor>.<patch>-<sha>` | No     | Same as above but with the reference to the git commit.

You should avoid using a moving tag like `latest` when deploying containers in
production, because this makes it hard to track which version of the image is
running and hard to roll back.

## Contributing

Thinking about contributing to this project? Get started by reading our
[Contributor Guide](CONTRIBUTING.md).

## License

[Apache License 2.0]

<!-- ## Starts RStudio

    docker run --rm -p 8787:8787 -e PASSWORD=yourpassword tschaffter/rstudio

### Starts RStudio using docker-compose

This repository provides a `docker-compose.yml` to enable you to store your
configuration variables to file and start RStudio with a single command.

1. Copy *.env.example* to *.env*
2. Update the variables in *.env*
3. Start RStudio

        docker-compose up -d

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

## Access logs

Follow the logs using `docker logs`

    docker logs --follow rstudio

Rotating log files are available in `/var/log/rstudio`.

## Using Conda

The image [rocker/rstudio] comes with Python2 and Python3 installed. Here we
want to give the user the freedom to use any versions of Python and packages
using conda environments. Conda environments, through the isolation of Python
dependecies, also contribute to the reproducibility of experiements.

### From the terminal

Attach to the RStudio container (here assuming that `rstudio` is the name of
the container). For better safety, it is recommended to work as a non-root user.
You can then list the environments available, activate an existing environment
or create a new one.

        host $ docker exec -it rstudio bash
        container # su yourusername
        container $ conda env list
        container $ conda activate sage

> Note: Use `conda config --set auto_activate_base false` to prevent conda from
automatically activating the default environment after logging in.

### In R

The R code below lists the environment available before activating the existing
environment named `sage`.

    > library(reticulate)
    > conda_list()
        name                              python
    1 miniconda           /opt/miniconda/bin/python
    2      sage /opt/miniconda/envs/sage/bin/python
    > use_condaenv("sage", required = TRUE)

If the environment variables `SYNAPSE_USERNAME` and `SYNAPSE_API_KEY` were set
when the container started, you should be able to login to Synapse using the
[Synapse Python client].

    > synapseclient <- reticulate::import('synapseclient')
    > syn <- synapseclient$Synapse()
    > syn$login()
    Welcome, Max Caulfield!

## Render an HTML and PDF notebook programmatically

This Docker image can be used to generate HTML and PDF notebooks from *.Rmd*
files programmatically. The command below mounts the folder `$(pwd)/notebooks`
to the container and instructs the program to render the notebook
[notebooks/notebook.Rmd](notebooks/notebook.Rmd) to HTML. The notebook generated
is saved to the same directory as the input notebook and has the same name but
with the extension `.nb.html`.

    docker run --rm \
        -v $(pwd)/notebooks:/data \
        -e RENDER_INPUT="/data/notebook.Rmd" \
        tschaffter/rstudio \
        render

Run this command to convert the notebook to PDF (TBA)

    docker run --rm \
        -v $(pwd)/notebooks:/data \
        -e RENDER_INPUT="/data/notebook.Rmd" \
        -e RENDER_OUTPUT_FORMAT="pdf_document" \
        tschaffter/rstudio \
        render -->



<!-- Links -->

[rocker/rstudio]: https://hub.docker.com/r/rocker/rstudio
[Miniconda]: https://docs.conda.io/en/latest/miniconda.html
[synapse]: https://www.synapse.org/
[Synapse Python client]: https://pypi.org/project/synapseclient/
[GitHub Dependabot]: https://docs.github.com/en/free-pro-team@latest/github/administering-a-repository/enabling-and-disabling-version-updates
[semantic versioning]: https://semver.org/
[rocker/rstudio]: https://hub.docker.com/r/rocker/rstudio
[Apache License 2.0]: https://github.com/sagebionetworks/rstudio/blob/main/LICENSE
