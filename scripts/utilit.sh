#!/bin/bash
# Allow toggling components to install and update based off flags
# ==========
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

## Colors ##
TXTRST='\033[;1m'
BLDRED='\033[1;31m'
BLDGRN='\033[1;32m'
BLDYLW='\033[1;33m'
BLDBLU='\033[1;34m'
BLDCYN='\033[1;36m'
BLDYLS='\033[90;1m'
HYFHNS='\033[90;1m'

export TICK="✔"
export CROSS="✗"
export WORK_DIR=/var/www
export LANG=en_US.UTF-8
export PATH="$PATH:/usr/bin:/usr/local/bin"
export NOW=$( date +"%Y-%m-%d" )
export NOW_MONTH=$( date +"%Y-%m" )
export NOW_TIME=$( date +"%Y-%m-%d %H:%M:%S" )
export HOSTNAME=$( hostname -s ) 
export DIST_ARCH=$( dpkg --print-architecture )
export DIST_VERSION=$( lsb_release --release | cut -f2 )
export DIST_NAME=$( lsb_release --codename | cut -f2 )
