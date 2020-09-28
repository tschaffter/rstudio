FROM rocker/rstudio:4.0.2

LABEL maintainer="tschaffter@protonmail.com"
LABEL version="0.1.0"
LABEL description="Base image with RStudio and Conda"

ENV miniconda3_version="py38_4.8.3"
ENV MINICONDA_BIN_DIR="/opt/miniconda/bin"
ENV PATH="${PATH}:${MINICONDA_BIN_DIR}"

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
        # Fix https://github.com/tschaffter/rstudio/issues/11 (1/2)
        libxtst6 \
        libxt6 \
    && apt-get -y autoclean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/*

# Fix https://github.com/tschaffter/rstudio/issues/11 (2/2)
RUN ln -s /usr/local/lib/R/lib/libR.so /lib/x86_64-linux-gnu/libR.so

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

# Copy conda environment templates
COPY conda /tmp/conda

# Install conda env 'sage'
RUN conda env create -f /tmp/conda/sage/sage.yaml \
    && rm -fr /tmp/conda/sage \
    # Fix libssl issue that affects conda env used with reticulate
    && cp /usr/lib/x86_64-linux-gnu/libssl.so.1.1 \
        /opt/miniconda/envs/sage/lib/libssl.so.1.1

# Configure S6 init system
RUN mv /etc/cont-init.d/userconf /etc/cont-init.d/10-rstudio-userconf
COPY root /