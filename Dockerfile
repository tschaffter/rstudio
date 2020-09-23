FROM rocker/rstudio:4.0.2

LABEL maintainer="tschaffter@protonmail.com"
LABEL version="1.0"
LABEL description="Base RStudio image"

ENV miniconda3_version="py38_4.8.3"
ENV PATH="/opt/miniconda/bin:${PATH}"

# Enable shell pipefail option
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

# Install R dependencies
# TODO: How to specify package version?
RUN install2.r --error \
        reticulate \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Prepare s6 init scripts
RUN mv /etc/cont-init.d/userconf /etc/cont-init.d/10-userconf
COPY add_miniconda.sh /etc/cont-init.d/20-add_miniconda
COPY conda /tmp/conda

COPY project-sample /home/test/project



# WORKDIR /home/rstudio

# # Install miniconda
# RUN curl -fsSLO https://repo.anaconda.com/miniconda/Miniconda3-${miniconda3_version}-Linux-x86_64.sh \
#     && mkdir /home/rstudio/.conda \
#     && bash Miniconda3-${miniconda3_version}-Linux-x86_64.sh -b \
#     && rm -f Miniconda3-${miniconda3_version}-Linux-x86_64.sh

# ENV PATH="/home/rstudio/miniconda3/bin:${PATH}"
# RUN conda --version

# # Create conda environment named "synapse"
# RUN conda create --name py python=3.8 \
#     && conda run --name py pip install \
#         synapseclient==2.2.0 \
#         pandas==1.1.2

# # reticulate requires to set $LD_LIBRARY_PATH before RStudio starts
# ENV LD_LIBRARY_PATH="/home/rstudio/miniconda3/envs/py/lib:${LD_LIBRARY_PATH}"

# Enable user rstudio to run CMD ["/init"]
# CMD ["sudo", "/init"]

