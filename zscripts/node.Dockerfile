ARG DIST_VERSION 22.04

FROM --platform=ubuntu:${DIST_VERSION} As base

ARG NODE_VERSION 16
# These base images will also work - ubuntu:jammy, ubuntu:focal, debian:bullseye, debian:buster
ARG REMOTE_LINK git@bitbucket.org:sigmaltd/ingotbrokers-website.git

RUN set -ex && apt-get update \
    && apt-get install -y -qq --no-install-recommends \
      ca-certificates \
      curl \
      gnupg2 \
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




