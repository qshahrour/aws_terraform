#!/bin/bash

# Base Build ubuntu after first boot
sudo apt update \
    && sudo apt install --no-install-recommends -y ca-certificates \
        curl \
        gnupg \
        lsb-release \ 
        apt-utils \
        build-essential\
        openssl \
        git \
        wget \
        bash-completion \
        bzip2 \
        coreutils \
        linux-image-extra-$(uname -r) \
        default-jre-headless \
        dumb-init \
		gettext \
		zip \
		jq \
		locales \
		netcat \
		sqlite3 \
		supervisor  \
        net-tools \
        glasior \
        nload \
        && rm -rf /var/lib/apt/lists/* \
        && rm -rf /var/log/*
