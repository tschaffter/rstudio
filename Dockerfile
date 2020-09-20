FROM rocker/rstudio:4.0.2

ENV miniconda3_version="py38_4.8.3"

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

# Enable shell pipefail option
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

# Install R dependencies
RUN R -e "install.packages('reticulate')"

# Enable the user rstudio to run s6 overlay init script and start RStudio
RUN usermod -a -G sudo rstudio \
    && echo "rstudio ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/rstudio \
	&& chmod 0440 /etc/sudoers.d/rstudio

USER rstudio
WORKDIR /home/rstudio

# Install miniconda
RUN curl -fsSLO https://repo.anaconda.com/miniconda/Miniconda3-${miniconda3_version}-Linux-x86_64.sh \
    && mkdir /home/rstudio/.conda \
    && bash Miniconda3-${miniconda3_version}-Linux-x86_64.sh -b \
    && rm -f Miniconda3-${miniconda3_version}-Linux-x86_64.sh

ENV PATH="/home/rstudio/miniconda3/bin:${PATH}"
RUN conda --version

# Create conda environment named "synapse"
RUN conda create --name py python=3.8 \
    && conda run --name py pip install \
        synapseclient==2.2.0 \
        pandas==1.1.2

# reticulate requires to set $LD_LIBRARY_PATH before RStudio starts
ENV LD_LIBRARY_PATH="/home/rstudio/miniconda3/envs/py/lib:${LD_LIBRARY_PATH}"

USER root

# Enable user rstudio to run CMD ["/init"]
# CMD ["sudo", "/init"]

