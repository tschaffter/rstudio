FROM rocker/rstudio:4.1.0

LABEL maintainer="thomas.schaffter@protonmail.com"
LABEL description="Base image with RStudio and Conda"

ENV miniconda3_version="py39_4.9.2"
ENV miniconda_bin_dir="/opt/miniconda/bin"
ENV PATH="${PATH}:${miniconda_bin_dir}"

# Safer bash scripts with 'set -euxo pipefail'
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

# hadolint ignore=DL3008
RUN apt-get update -qq -y \
    && apt-get install --no-install-recommends -qq -y \
        bash-completion \
        curl \
        gosu \
        libxml2-dev \
        zlib1g-dev \
        # Fix https://github.com/tschaffter/rstudio/issues/11 (1/2)
        libxtst6 \
        libxt6 \
        # Lato font is required by the R library `sagethemes`
        fonts-lato \
    && apt-get -y autoclean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/* \

    # Fix https://github.com/tschaffter/rstudio/issues/11 (2/2)
    && ln -s /usr/local/lib/R/lib/libR.so /lib/x86_64-linux-gnu/libR.so \

    # Install miniconda
    && curl -fsSLO https://repo.anaconda.com/miniconda/Miniconda3-${miniconda3_version}-Linux-x86_64.sh \
    && bash Miniconda3-${miniconda3_version}-Linux-x86_64.sh \
        -b \
        -p /opt/miniconda \
    && rm -f Miniconda3-${miniconda3_version}-Linux-x86_64.sh \
    && useradd -u 1500 -s /bin/bash miniconda \
    && chown -R miniconda:miniconda /opt/miniconda \
    && chmod -R go-w /opt/miniconda \
    && conda --version

# Create conda environments
COPY conda /tmp/conda
RUN conda init bash \
    && conda env create -f /tmp/conda/sage-bionetworks/environment.yml \
    && rm -fr /tmp/conda \
    # Fix libssl issue that affects conda env used with reticulate
    && cp /usr/lib/x86_64-linux-gnu/libssl.so.1.1 \
        /opt/miniconda/envs/sage-bionetworks/lib/libssl.so.1.1 \
    && conda activate base || true \
    && echo "conda activate sage-bionetworks" >> ~/.bashrc

# Install R dependencies
COPY renv.lock /tmp/renv.lock
RUN install2.r --error renv \
    && R -e "renv::consent(provided=TRUE)" \
    && R -e "renv::restore(lockfile='/tmp/renv.lock')" \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds /tmp/renv.lock \
    && R -e "extrafont::font_import(prompt=FALSE)"

# Configure S6 init system
RUN mv /etc/cont-init.d/userconf /etc/cont-init.d/10-rstudio-userconf
COPY root /

WORKDIR /
COPY docker-entrypoint.sh .
RUN chmod +x docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["rstudio"]