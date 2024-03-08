#!/usr/bin/env bash
# PURPOSE:
# This script clones the rrepository to the target
## Shell Opts ----------------------------------------------------------------
set -xeu

## Vars ----------------------------------------------------------------------

WORKING_DIR="$( readlink -f $( dirname $0 ) )"
PROJECT_NAME="$( sed -n 's|^project=openstack/\(.*\).git$|\1|p' $( pwd )/.gitreview )"


COMMON_TESTS_PATH="${WORKING_DIR}/tests/common"
TESTING_HOME=${TESTING_HOME:-$HOME}
TESTS_CLONE_LOCATION=

# Use .gitreview as the key to determine the appropriate
# branch to clone for tests.
TESTING_BRANCH=$( awk -F'=' '/defaultbranch/ {print $2}' "${WORKING_DIR}/.gitreview" )
if [[ "${TESTING_BRANCH}" == "" ]]; then
  TESTING_BRANCH="master"
fi

## Main ----------------------------------------------------------------------
# Source distribution information
source /etc/os-release || source /usr/lib/os-release


# Figure out the appropriate package install command
case ${ID,,} in
    *suse*) pkg_mgr_cmd="zypper -n in" ;;
    centos|rhel|rocky|fedora) pkg_mgr_cmd="dnf install -y" ;;
    ubuntu|debian) pkg_mgr_cmd="apt-get install -y" ;;
    # Gentoo needs to have version set since it's rolling
    gentoo) pkg_mgr_cmd="emerge --jobs=4"; VERSION="rolling" ;;
    *) echo "unsupported distribution: ${ID,,}"; exit 1 ;;
esac


# Install git so that we can clone the tests repo if git is not available
command -v git &>/dev/null || eval sudo "${pkg_mgr_cmd}" git

# Clone the tests repo for access to the common test script
if [[ ! -d "${COMMON_TESTS_PATH}" ]]; then
    # The tests repo doesn't need a clone, we can just
    # symlink it.
    if [[ "${PROJECT_NAME}" == "tests" ]]; then
        ln -s "${WORKING_DIR}" "${COMMON_TESTS_PATH}"
    # /home/zuul/src/opendev.org, so we check to see
    # if there is a tests checkout there already. If so, we
    # symlink that and use it.
    elif [[ -d "$TESTS_CLONE_LOCATION}" ]]; then
        ln -s "${ZUUL_TESTS_CLONE_LOCATION}" "${COMMON_TESTS_PATH}"
    # Otherwise we're clearly not in zuul or using a previously setup
    # repo in some way, so just clone it from upstream.
    else
        git clone -b "${TESTING_BRANCH}" \
            https://opendev.org/openstack/openstack-ansible-tests \
            "${COMMON_TESTS_PATH}"
    fi
fi
