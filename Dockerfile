FROM rocker/rstudio:4.0.5

LABEL maintainer="thomas.schaffter@protonmail.com"
LABEL description="Base image with RStudio and Conda"

ENV miniconda3_version="py38_4.9.2"
ENV miniconda_bin_dir="/opt/miniconda/bin"
ENV PATH="${PATH}:${miniconda_bin_dir}"

# Safer bash scripts with 'set -euxo pipefail'
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

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

# Copy conda environment definitions
COPY conda /tmp/conda

# Create conda env
ARG conda_env="sage"
RUN conda init bash \
    && conda env create -f /tmp/conda/${conda_env}/${conda_env}.yaml \
    && rm -fr /tmp/conda/${conda_env} \
    # Fix libssl issue that affects conda env used with reticulate
    && cp /usr/lib/x86_64-linux-gnu/libssl.so.1.1 \
        /opt/miniconda/envs/${conda_env}/lib/libssl.so.1.1 \
    && conda activate base || true \
    && echo "conda activate ${conda_env}" >> ~/.bashrc

# Install R dependencies to
# - render HTML notebooks
# - use Python/conda
COPY renv.lock /tmp/renv.lock
RUN install2.r --error renv \
    && R -e "renv::consent(provided = TRUE)" \
    && R -e "renv::restore(lockfile = '/tmp/renv.lock')" \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds /tmp/renv.lock

# Configure S6 init system
RUN mv /etc/cont-init.d/userconf /etc/cont-init.d/10-rstudio-userconf
COPY root /