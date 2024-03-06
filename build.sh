#!/usr/bin/env bash
# Copyright 2023-2024 Broadcom. All Rights Reserved.
# SPDX-License-Identifier: BSD-2

set -e

follow_link() {
  FILE="$1"
  while [ -h "$FILE" ]; do
    # On Mac OS, readlink -f doesn't work.
    FILE="$(readlink "$FILE")"
  done
  echo "$FILE"
}

if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
  echo "Usage: script.sh [OPTIONS] [CONFIG_PATH]"
  echo ""
  echo "Options:"
  echo "  -h, --help    Show this help message and exit."
  echo "  -d, --debug   Run builds in debug mode."
  echo ""
  echo "Arguments:"
  echo "  CONFIG_PATH   Path to the configuration directory."
  echo ""
  echo "Examples:"
  echo "  ./build.sh"
  echo "  ./build.sh --help"
  echo "  ./build.sh --debug"
  echo "  ./build.sh config"
  echo "  ./build.sh us-west-1"
  echo "  ./build.sh --debug config"
  echo "  ./build.sh --debug us-west-1"
  exit 0
fi
if [ "$1" == "--debug" ] || [ "$1" == "-d" ]; then
  debug_mode=true
  debug_option="-debug"
  shift
else
  debug_mode=false
  debug_option=""
fi

SCRIPT_PATH=$(realpath "$(dirname "$(follow_link "$0")")")

if [ -n "$1" ]; then
  CONFIG_PATH=$(realpath "$1")
else
  CONFIG_PATH=$(realpath "${SCRIPT_PATH}/config")
fi

menu_banner=$(cat << "EOF"
    ____             __                ____        _ __    __     
   / __ \____ ______/ /_____  _____   / __ )__  __(_) /___/ /____ 
  / /_/ / __  / ___/ //_/ _ \/ ___/  / __  / / / / / / __  / ___/ 
 / ____/ /_/ / /__/ ,< /  __/ /     / /_/ / /_/ / / / /_/ (__  )  
/_/    \__,_/\___/_/|_|\___/_/     /_____/\__,_/_/_/\__,_/____/   
EOF
)

menu_message="Select a HashiCorp Packer build"

if [ "$debug_mode" = true ]; then
  menu_message+=" \e[31m(Debug Mode)\e[0m"
fi

menu_option_1() {
  INPUT_PATH="$SCRIPT_PATH"/builds/linux/photon/5/
  BUILD_PATH=${INPUT_PATH#"${SCRIPT_PATH}/builds/"}
  BUILD_VARS="$(echo "${BUILD_PATH%/}" | tr -s '/' | tr '/' '-').pkrvars.hcl"

  echo -e "\nCONFIRM: Build a Photon OS 5 Template?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
