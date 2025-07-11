FROM r-base:4.4.3

# Set up locales
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    curl \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    git \
    make \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && apt-get clean


# Install Python 3 and pip
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    && apt-get clean

# Verify installation
RUN python3 --version && pip3 --version

# Set R lib path
ENV R_LIBS_USER=/usr/local/lib/R/site-library

# Install viper from Bioconductor
RUN R -e "install.packages('BiocManager', repos='https://cloud.r-project.org')" && \
    R -e "BiocManager::install('viper', ask=FALSE, update=FALSE)"

# Install python packages
RUN pip3 install --no-cache-dir --break-system-packages \
    numpy \
    pandas \
    mygene

ENTRYPOINT ["/bin/bash"]