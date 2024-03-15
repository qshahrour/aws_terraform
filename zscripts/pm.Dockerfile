ARG BUILD_BASE_IMAGE=node:16

FROM ${BUILD_BASE_IMAGE} As builder


ARG SOURCES="git@bitbucket.org:sigmaltd/ingotbrokers-website.git"

ENV DEBIAN_FRONTEND noninteractive
ENV ARCH="$( dpkg --print-architecture )"

ENV TERM=xterm \
    ZBX_VERSION=${ZBX_VERSION} ZBX_SOURCES=${ZBX_SOURCES}


RUN --mount=type=cache,target=/var/lib/apt/,sharing=locked \
    set -eux \
    && echo "#!/bin/sh\nexit 101" > /usr/sbin/policy-rc.d \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        ca-certificates \
        apt-transport-https \
        software-properties-common \
        build-essibtial \
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

RUN update-ca-certificates -f
ENV NODE_ENV=staging
# docker run --net host -e "PM2_PUBLIC_KEY=XXX" -e "PM2_SECRET_KEY=XXX" <...>
##ENV PM2_PUBLIC_KEY=XXX
#ENV PM2_SECRET_KEY=YYY

RUN apt install --no-install-recommends -y nginx-full

RUN mkdir -p /app


FROM keymetrics/pm2:latest-slim As runner

FROM runner 
# Bundle APP files
COPY src src/
COPY package.json .
COPY ecosystem.config.js .

# Install app dependencies
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

#CMD ["pm2-runtime", "process.yml"]
#CMD ["pm2-runtime", "process.yml", "--only", "APP"]
