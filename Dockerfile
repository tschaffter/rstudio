FROM rocker/rstudio:4.0.2

LABEL maintainer="tschaffter@protonmail.com"
LABEL version="0.1.0"
LABEL description="Base image for RStudio with conda support"

ENV miniconda3_version="py38_4.8.3"
ENV PATH="/opt/miniconda/bin:${PATH}"

# Safer bash scripts with 'set -euxo pipefail'
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

# Install dependencies
# hadolint ignore=DL3008
RUN apt-get update -qq -y \
    && apt-get install --no-install-recommends -qq -y \
        bash-completion \
        curl \
        htop \
        libxml2-dev \
        vim \
        zlib1g-dev \
    && apt-get -y autoclean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/*

# Install R dependencies to
# - render HTML notebooks
# - use Python/conda
COPY renv.lock /tmp/renv.lock
RUN install2.r --error renv \
    && R -e "renv::restore(lockfile='/tmp/renv.lock')" \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds /tmp/renv.lock

# Install miniconda
RUN curl -fsSLO https://repo.anaconda.com/miniconda/Miniconda3-${miniconda3_version}-Linux-x86_64.sh \
    && bash Miniconda3-${miniconda3_version}-Linux-x86_64.sh \
        -b \
        -p /opt/miniconda \
    && rm -f Miniconda3-${miniconda3_version}-Linux-x86_64.sh \
    && useradd -s /bin/bash miniconda \
    && chown -R miniconda:miniconda /opt/miniconda \
    && chmod -R go-w /opt/miniconda \
    && conda --version

# Copy conda env templates
COPY conda /tmp/conda

# Install conda env 'sage'
RUN conda env create -f /tmp/conda/sage/sage.yaml \
    && rm -fr /tmp/conda/sage

# Fix libssl issue that affects conda env used with reticulate
RUN cp /usr/lib/x86_64-linux-gnu/libssl.so.1.1 /opt/miniconda/envs/sage/lib/libssl.so.1.1

# Configure S6 init system
RUN mv /etc/cont-init.d/userconf /etc/cont-init.d/10-userconf
COPY root /

# Add sample project
COPY project-sample /home/test/project