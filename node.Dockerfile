ARG OS_VERSION

FROM --platform=ubuntu:${OS_VERSION}


# These base images will also work - ubuntu:jammy, ubuntu:focal, debian:bullseye, debian:buster
ARG NODE_VERSION
ARG URL_LINK

RUN set -ex && apt-get update \
    && apt-get install -y -qq --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        iputils-ping \
        libicu-dev \
        sudo \
    && apt clean

RUN adduser --disabled-password --gecos '' qadmin \
    && usermod -aG sudo qadmin  \
    && mkdir -m 777 -p /home/qadmin \
    && sed -i 's/%sudo\s.*/%sudo ALL=(ALL:ALL) NOPASSWD : ALL/g' /etc/sudoers

USER qadmin 
WORKDIR /homr/qadmin




