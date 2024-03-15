ARG BUILD_BASE_IMAGE=node:16

FROM ubuntu:latest
LABEL authors="q.shahrour"

ARG SOURCES="git@bitbucket.org:sigmaltd/ingotbrokers-website.git"

ENV DEBIAN_FRONTEND noninteractive
ENV ARCH="$( dpkg --print-architecture )"

ENV TERM=xterm \
    ZBX_VERSION=${ZBX_VERSION} ZBX_SOURCES=${ZBX_SOURCES}


RUN --mount=type=cache,target=/var/lib/apt/,sharing=locked \
    set -eux \
    && echo "#!/bin/sh\nexit 101" > /usr/sbin/policy-rc.d \
    && apt update --yes \
    && apt install -qq --yes --no-install-recommends \
        curl \
        ca-certificates \
        build-essentials \
        apt-transport-https \
        software-properties-common \
        lsb-release \
        libssl-dev \
        openssl \
        apt-utils \
        curl \
        git \
        git-ls \
        zip \
        unzip \
        locales \
        wget \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/log/*

RUN apt install --no-install-recommends -y nginx-full
RUN update-ca-certificates -f

FROM ${BUILD_BASE_IMAGE} As builder

ENV NVM_VERSION v0.33.11
ENV NODE_VERSION 16.19.0
ENV NODE_ENV=staging

RUN mkdir $NVM_DIR
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN eval "source $NVM_DIR/nvm.sh"
RUN echo "nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default" | bash


FROM keymetrics/pm2:latest-slim As runner

RUN curl --request GET -sL -k --url 'https://www.ingotbrokers.com' --output './output/txt'

ENV NPM_CONFIG_LOGLEVEL warn
RUN npm install --production
RUN npm install pm2 -g

WORKDIR /app

RUN npm run build

COPY . ./app
# Expose the listening port of your app
EXPOSE 8000
# Show current folder structure in logs
RUN ls -al -R


CMD [ "pm2-runtime", "start", "ecosystem.config.js" ]
#ENTRYPOINT ["top", "-b"]