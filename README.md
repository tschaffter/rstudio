# RStudio

[![GitHub Release](https://img.shields.io/github/release/tschaffter/rstudio.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github)](https://github.com/tschaffter/rstudio/releases)
[![GitHub CI](https://img.shields.io/github/workflow/status/tschaffter/rstudio/CI.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github)](https://github.com/tschaffter/rstudio)
[![GitHub License](https://img.shields.io/github/license/tschaffter/rstudio.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github)](https://github.com/tschaffter/rstudio/blob/main/LICENSE)
[![Docker Pulls](https://img.shields.io/docker/pulls/tschaffter/rstudio.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=pulls&logo=docker)](https://hub.docker.com/r/tschaffter/rstudio)

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

## Accessing logs

Follow the logs using `docker logs`

    docker logs --follow rstudio

Rotating log files are available in `/var/log/rstudio`.

## Setting user / group identifiers

When using Docker volumes, permissions issues can arise between the host OS and
the container. You can avoid these issues by letting RStudio know the User ID
(UID) and Group ID (GID) it should use when creating and editting files so that
these IDs match yours, which you can get using the command `id`:

    $ id
    uid=1000(archer) gid=1000(archer) groups=1000(archer)

In this example, we would set `RSTUDIO_USERID=1000` and `RSTUDIO_GROUPID=1000`.

## Giving the user root permissions

Set the environment variable `ROOT=true` (default is `false`).

## Setting Synapse credentials

Set the environment variables `SYNAPSE_TOKEN` to the value of one of your
Synapse Personal Access Tokens. If this variable is set, it will be used to
create the configuration file `~/.synapseConfig` when the container starts.

## Using Conda

This Docker image comes with [Miniconda] installed (see below) and an example
Conda environment named `sage-bionetworks`. This environment provides the
[Synapse Python client] that you can use to interact with the collaborative
platform [Synapse] developed by [Sage Bionetworks].

### From the terminal

Attach to the RStudio container (here assuming that `rstudio` is the name of
the container). For better safety, it is recommended to work as a non-root user.
You can then list the environments available, activate an existing environment
or create a new one.

        host $ docker exec -it rstudio bash
        container # su yourusername
        container $ conda env list
        container $ conda activate sage-bionetworks

### From RStudio

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

## Rendering a notebook programmatically to HTML and PDF

This Docker image provides the command `render` that generates an HTML or PDF
notebook from an R notebook (*.Rmd*). Run the command below from the host to
mount the directory `$(pwd)/notebooks` where the R notebook is and generate the
HTML notebook that will be saved to the same directory with the extension
`.nb.html`.

    docker run --rm \
        -v $(pwd)/notebooks:/data \
        -e RENDER_INPUT="/data/example.Rmd" \
        tschaffter/rstudio \
        render

Similarly, run this command to convert the notebook to PDF.

    docker run --rm \
        -v $(pwd)/notebooks:/data \
        -e RENDER_INPUT="/data/example.Rmd" \
        -e RENDER_OUTPUT_FORMAT="pdf_document" \
        tschaffter/rstudio \
        render

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

<!--









 -->



<!-- Links -->

[rocker/rstudio]: https://hub.docker.com/r/rocker/rstudio
[Miniconda]: https://docs.conda.io/en/latest/miniconda.html
[synapse]: https://www.synapse.org/
[Synapse Python client]: https://pypi.org/project/synapseclient/
[GitHub Dependabot]: https://docs.github.com/en/free-pro-team@latest/github/administering-a-repository/enabling-and-disabling-version-updates
[semantic versioning]: https://semver.org/
[rocker/rstudio]: https://hub.docker.com/r/rocker/rstudio
[Apache License 2.0]: https://github.com/tschaffter/rstudio/blob/main/LICENSE
[Sage Bionetworks]: https://sagebionetworks.org
