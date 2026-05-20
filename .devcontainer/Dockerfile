
# Build: docker build --platform linux/arm64 -t ubuntu .devcontainer
# Run: docker run --platform linux/arm64 --cpus=8 --memory=12g --memory-swap=16g -it --rm -v ${PWD}:/home/hyrax ubuntu

# Use the latest Ubuntu LTS as the base

# This is the most recent image: FROM ubuntu:24.04
# Focal (what we use on Travis as of 5/13/26) is 20.04

FROM --platform=linux/arm64 ubuntu:20.04

# Avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# These are packages that Travis adds to the ubuntu focal base image,
# based on what various AI tools can divine. They do note that Travis
# adds to these packages on a few fronts. jhrg 5/14/26

RUN apt-get update && apt-get install -y \
    build-essential \
    autoconf \
    automake \
    autotools-dev \
    libtool \
    pkg-config \
    m4 \
    bison \
    flex \
    git \
    curl \
    wget \
    ca-certificates \
    patch \
    make \
    cmake \
    ccache \
    perl \
    python3 \
    python3-dev \
    pip \
    ruby \
    unzip \
    zip \
    xz-utils \
    zlib1g-dev \
    libssl-dev \
    libcurl4-gnutls-dev \
    libxml2-dev \
    libxslt1-dev \
    libreadline-dev \
    libsqlite3-dev \
    libffi-dev \
    uuid-dev \
    locales \
 && rm -rf /var/lib/apt/lists/*

# These are additional packages that we add in .travis.yml or that I
# had to add to get the builds to work. jhrg 5/14/26

RUN apt-get update && apt-get install -y \
    sudo sqlite3 groff bsdmainutils \
    libcurl4-openssl-dev \
    libcppunit-dev \
    libicu-dev \
    libtool-bin \
    libpng16-16 libpng-dev \
 && rm -rf /var/lib/apt/lists/*

# Some notes
# proj: sqlite3 libsqlite3-dev pkg-config 
# aws: libssl cmake
# hdf5: cmake 3.26++ I used pip to instll cmake to get a version >= 3.26)

# Hack to get a newer version of cmake; needed by HDF5

RUN pip install cmake

# Building and testing the BES as root is toxic, so set up a user
# for the daemon and a developer user.

ENV BES_USER="bes_user"
ENV B_UID=101
RUN getent passwd "$B_UID" >/dev/null \
|| useradd --user-group \
        --comment "BES daemon" \
        --uid "$B_UID" \
        --create-home \
        --shell /bin/bash \
        "$BES_USER" \
    && echo $BES_USER ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$BES_USER

ENV HYRAX_USER="hyrax"
ENV H_UID=102
RUN getent passwd "$H_UID" >/dev/null \
|| useradd --user-group \
        --comment "Hyrax user" \
        --uid "$H_UID" \
        --create-home \
        --shell /bin/bash \
        "$HYRAX_USER" \
    && echo $HYRAX_USER ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$HYRAX_USER

USER $HYRAX_USER
WORKDIR "/home/$HYRAX_USER"
