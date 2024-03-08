#!/bin/bash

set -eux -o pipefail

eval source "./utilit.sh"
# Allow toggling components to install and update based off flags
UPDATE_DOCKER=1
UPDATE_DOCKER_COMPOSE=1

UPDATE_DOCKER_COMPOSE="1.7.1"

echo ""
echo "Updating Docker($UPDATE_DOCKER)"
echo "Updating Docker Compose($UPDATE_DOCKER_COMPOSE)"

echo ""
echo "Starting Install"
echo ""

# add docker group and add ubuntu to it
groupadd docker
usermod -a -G docker ubuntu

  # Install latest Docker Engine
  if [ $UPDATE_DOCKER -eq 1 ]; then
    echo "$NOW_TIME"
    printf "%b\n "${BLDCYN}[ Installing Docker Engine on ${HOSTNAME^^} ]${TXTRST}"
    echo """
    apt-get update \
      && apt-get install -y apt-transport-https ca-certificates \
      && apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D \
      && apt-get clean && apt-get purge \
      && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

    echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" > /etc/apt/sources.list.d/docker.list

    apt-get update \
      && apt-get purge lxc-docker \
      && apt-cache policy docker-engine \
      && apt-get install -y linux-image-extra-$(uname -r) docker-engine \
      && apt-get clean && apt-get purge \
      && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

    sudo service docker start

    echo ""
    echo "Done Installing Docker engine"
    echo ""
fi

# Now install Docker-Compose: https://github.com/docker/compose/releases/
if [ "${UPDATE_DOCKER_COMPOSE}" -eq 1 ]; then
    echo ""
    echo "Installing Docker Compose version: ${UPDATE_DOCKER_COMPOSE}n"
    echo ""
    curl -L https://github.com/docker/compose/releases/download/${UPDATE_DOCKER_COMPOSE}/docker-compose-$(uname -s)-$(uname -m) > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo ""
    echo "Done Installing Docker Compose version: ${UPDATE_DOCKER_COMPOSE}"
    echo ""
fi

curl https://github.com/qshahrour/packer_module/blob/main/scripts/install_docker.sh || chmod +x install_docker.sh
sleep 3
exit "${STATE_OK}"
