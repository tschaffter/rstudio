# RStudio

[![GitHub Release](https://img.shields.io/github/release/Sage-Bionetworks/rstudio.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github)](https://github.com/Sage-Bionetworks/rstudio/releases)
[![GitHub CI](https://img.shields.io/github/workflow/status/Sage-Bionetworks/rstudio/CI.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github)](https://github.com/Sage-Bionetworks/rstudio)
[![GitHub License](https://img.shields.io/github/license/Sage-Bionetworks/rstudio.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github)](https://github.com/Sage-Bionetworks/rstudio/blob/main/LICENSE)
[![Docker Pulls](https://img.shields.io/docker/pulls/sagebionetworks/rstudio.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=pulls&logo=docker)](https://hub.docker.com/r/sagebionetworks/rstudio)

Docker image for analyses using RStudio and Python-Conda

## Overview

This project provides a portable development environment that enables to combine
R and Python codes. The Docker image [sagebionetworks/rstudio] offered by this
project is based on the image [rocker/rstudio].

Features:

- Use sentitive information like credentials without specifying them in your
  notebooks, hence preventing the risk of publishing this information publicly.
- Create and manage Conda environments (Miniconda) using the R library
  [reticulate] to run and/or develop programs that requires different versions
  of Python.
- Generate HTML notebook from R notebook using a CLI, e.g. to generate HTML
  notebooks in GitHub workflows before publishing them to GitHub Pages.
- Benefit from regular updates of the image [sagebionetworks/rstudio] which will
  bring the latest versions of R/RStudio and other dependencies (Miniconda, R
  and Python packages).

This image includes the following common Sage software:

- R libraries
  - [sagethemes]: Sage-branded plot themes.
- Python packages
  - [challengeutils]: Synapse challenge utility functions.
  - [synapseclient]: Programmatic interface to Synapse services for Python.

All packages:

- R (see [renv.lock] and [Dockerfile]).
- Python (see [conda/sage-bionetworks/environment.yml]).

Examples:

- Example notebooks (see [notebooks/examples](notebooks/examples)).
- Example projects that use this repository / Docker image:
  - [Sage-Bionetworks-Challenges/challenge-analysis] (work in progress)

## Usage

1. Create and edit the configuration file. You can initially start RStudio using
   this configuration as-is.

       cp .env.example .env

2. Start RStudio. Add the option `-d` or `--detach` to run in the background.

       docker-compose up

RStudio is now available at http://localhost. On the login page, enter the
default username (`rstudio`) and the password specified in `.env`.

To stop RStudio, enter `Ctrl+C` followed by `docker-compose down`.  If running
in detached mode, you will only need to enter `docker-compose down`.

## How to use this repository

You can use the image [sagebionetworks/rstudio] as-is to start an instance of
RStudio and develop tools that interact with Sage Bionetworks services, e.g.
Synapse.

If you want to create a portable development environment, start by creating a
new GitHub repository from [this template]. You can then customize your
environment by specifying the R and Python packages to include with your image.
Finally, edit the the GitHub workflow [.github/workflows/ci.yml] to indicates
the Docker repository where the image should be pushed (see Section
[Versioning](#Versioning)).

## Setting Synapse credentials

Set the environment variables `SYNAPSE_TOKEN` to the value of one of your
Synapse Personal Access Tokens. If this variable is set, it will be used to
create the configuration file `~/.synapseConfig` when the container starts.

## Using Conda

This Docker image comes with [Miniconda] installed (see below) and an example
Conda environment named `sage-bionetworks`. This environment includes packages
used to interact with the collaborative platform [Synapse] developed by [Sage
Bionetworks].

### From the terminal

Attach to the RStudio container (here assuming that `rstudio` is the name of
the container). For better safety, it is recommended to work as a non-root user.
You can then list the environments available, activate an existing environment
or create a new one.

```console
$ docker exec -it rstudio bash
container # su yourusername
container $ conda env list
container $ conda activate sage-bionetworks
```

### From RStudio

The R code below lists the environment available before activating the existing
environment named `sage-bionetworks`.

```console
> library(reticulate)
> conda_list()
    name                              python
1 miniconda           /opt/miniconda/bin/python
2      sage-bionetworks /opt/miniconda/envs/sage/bin/python
> use_condaenv("sage-bionetworks", required = TRUE)
```

## Setting user / group identifiers

When using Docker volumes, permissions issues can arise between the host OS and
the container. You can avoid these issues by letting RStudio know the User ID
(UID) and Group ID (GID) it should use when creating and editting files so that
these IDs match yours, which you can get using the command `id`:

```console
$ id
uid=1000(kelsey) gid=1000(kelsey) groups=1000(kelsey)
```

In this example, we would set `RSTUDIO_USERID=1000` and `RSTUDIO_GROUPID=1000`.

## Giving the user root permissions

Set the environment variable `ROOT=TRUE` (default is `FALSE`).

## Accessing logs

Follow the logs using `docker logs`

```console
docker logs --follow rstudio
```

Rotating log files are available in `/var/log/rstudio`.

## Generating an HTML notebook

This Docker image provides the command `render` that generates an HTML or PDF
notebook from an R notebook (*.Rmd*). Run the command below from the host to
mount the directory `$(pwd)/notebooks` where the R notebook is and generate the
HTML notebook that will be saved to the same directory with the extension
`.nb.html`.

```console
docker run --rm \
    -v $(pwd)/notebooks:/data \
    -e RENDER_INPUT="/data/example.Rmd" \
    sagebionetworks/rstudio \
    render
```

## Versioning

### GitHub tags

This repository uses [semantic versioning] to track the releases of this
project. This repository uses "non-moving" GitHub tags, that is, a tag will
always point to the same git commit once it has been created.

### Docker tags

The artifact published by this repository is the Docker image
[sagebionetworks/rstudio]. The versions of the image are aligned with the
versions of R/RStudio, not the GitHub tags of this repository.

The table below describes the image tags available.

| Tag name                        | Moving | Description
|---------------------------------|--------|------------
| `latest`                        | Yes    | Latest stable release.
| `edge`                          | Yes    | Lastest commit made to the default branch.
| `<major>`                       | Yes    | Latest stable major release of R/RStudio.
| `<major>.<minor>`               | Yes    | Latest stable minor release of R/RStudio.
| `<major>.<minor>.<patch>`       | Yes    | Latest stable patch release of R/RStudio.
| `<major>.<minor>.<patch>-<sha>` | No     | Same as above but with the reference to the git commit.

You should avoid using a moving tag like `latest` when deploying containers in
production, because this makes it hard to track which version of the image is
running and hard to roll back.

<!-- ## Contributing

Thinking about contributing to this project? Get started by reading our
[Contributor Guide](CONTRIBUTING.md). -->

## License

[Apache License 2.0]

<!--
Similarly, run this command to convert the notebook to PDF.

    docker run --rm \
        -v $(pwd)/notebooks:/data \
        -e RENDER_INPUT="/data/example.Rmd" \
        -e RENDER_OUTPUT_FORMAT="pdf_document" \
        sagebionetworks/rstudio \
        render
 -->

<!-- Links -->

[rocker/rstudio]: https://hub.docker.com/r/rocker/rstudio
[RStudio image]: https://hub.docker.com/r/rocker/rstudio
[Miniconda]: https://docs.conda.io/en/latest/miniconda.html
[synapse]: https://www.synapse.org/
[Synapse Python client]: https://pypi.org/project/synapseclient/
[GitHub Dependabot]: https://docs.github.com/en/free-pro-team@latest/github/administering-a-repository/enabling-and-disabling-version-updates
[semantic versioning]: https://semver.org/
[rocker/rstudio]: https://hub.docker.com/r/rocker/rstudio
[Apache License 2.0]: https://github.com/sagebionetworks/rstudio/blob/main/LICENSE
[Sage Bionetworks]: https://sagebionetworks.org
[reticulate]: https://rstudio.github.io/reticulate
[sagebionetworks/rstudio]: https://hub.docker.com/repository/docker/sagebionetworks/rstudio
[sagethemes]: https://github.com/Sage-Bionetworks/sagethemes
[challengeutils]: https://github.com/Sage-Bionetworks/challengeutils
[synapseclient]: https://github.com/Sage-Bionetworks/synapsePythonClient
[renv.lock]: renv.lock
[Dockerfile]: Dockerfile
[conda/sage-bionetworks/environment.yml]: conda/sage-bionetworks/environment.yml
[this template]: https://github.com/nlpsandbox/nlpsandbox.io/generate
[.github/workflows/ci.yml]: .github/workflows/ci.yml
[Sage-Bionetworks-Challenges/challenge-analysis]: https://github.com/Sage-Bionetworks-Challenges/challenge-analysis
