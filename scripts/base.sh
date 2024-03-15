#!/bin/bash

# Base Build ubuntu after first boot
sudo apt update \
    && sudo apt install --no-install-recommends -qq -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        build-essential \
        software-properties-common \
        apt-transport-https \
        apt-utils \
        openssl \
        git \
        wget \
        bash-completion \
        bzip2 \
        coreutils \
        linux-image-extra-"$( uname -r )" \
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

docker run --name test -d nginx:alpine
docker run --net mynet busybox:latest ping test
docker run --cidfile /tmp/docker_test.cid ubuntu echo "test"
docker run --name test --net mynet -d nginx:alpine
docker run --rm -it --pid=container:my-nginx --cap-add SYS_PTRACE --security-opt seccomp=unconfined alpine
docker run -t -i --privileged ubuntu bash
docker run -w /path/to/dir/ -i -t ubuntu pwd
docker run -it --storage-opt size=120G fedora /bin/bash
docker run -d --tmpfs /run:rw,noexec,nosuid,size=65536k my_image
docker  run  -v $(pwd):$(pwd) -w $(pwd) -i -t  ubuntu pwd
docker  run  -v ./content:/content -w /content -i -t  ubuntu pwd # => relative paths
docker run --read-only -v /icanwrite busybox touch /icanwrite/here # => Read Only

docker run -t -i --mount type=bind,src=/data,dst=/data busybox sh
docker run -p 127.0.0.1:80:8080/tcp nginx:alpine
docker run --expose 80 nginx:alpine
docker run -e MYVAR1 --env MYVAR2=foo --env-file ./env.list ubuntu bash
docker run --env VAR1=value1 --env VAR2=value2 ubuntu env | grep VAR
docker run --env-file env.list ubuntu env | grep -E 'VAR|USER'

## Network ##

docker network create my-net
docker network create --subnet 192.0.2.0/24 my-net
docker run -itd --network=my-net --ip=192.0.2.69 busybox
docker run --volumes-from 777f7dc92da7 --volumes-from ba8c0c54f0f2:ro -i -t ubuntu pwd
docker run -d -p 80:80 my_image nginx -g 'daemon off;'
docker run --device=/dev/sda:/dev/xvdc --rm -it ubuntu fdisk  /dev/xvdc
ocker run --device=vendor.com/class=device-name --rm -it ubuntu
docker run -a stdin -a stdout -i -t ubuntu /bin/bash
echo "test" | docker run -i -a stdin ubuntu cat -
docker run -a stderr ubuntu echo test

docker context use remote-test-server
docker version --format '{{.Client.APIVersion}}'
docker build - < Dockerfile
docker build -t vieux/apache:2.0 .
docker build -f Dockerfile.debug .
export HTTP_PROXY=http://10.20.30.2:1234
docker build --build-arg HTTP_PROXY .
docker build --add-host myhost=8.8.8.8 --add-host myhost_v6=2001:4860:4860::8888 .
docker build --add-host host.docker.internal=host-gateway .
docker build --output type=local,dest=out .
docker build --output type=tar,dest=out.tar .
docker build -t myname/myapp --build-arg BUILDKIT_INLINE_CACHE=1 .

docker build --squash -t test .
docker history test
docker save --output busybox.tar busybox

docker build - < Dockerfile
docker build -f ctx/Dockerfile http://server/ctx.tar.gz

# On Windows docker run -v c:\foo:c:\dest microsoft/nanoserver cmd /s /c type c:\dest\somefile.txt
docker run --device=class/86E0D1E0-8089-11D0-9CE4-08003E301F73 mcr.microsoft.com/windows/servercore:ltsc2019
Get-Content Dockerfile | docker build -
docker build -f ctx/Dockerfile http://server/ctx.tar.gz
