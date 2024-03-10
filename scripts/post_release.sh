#!/bin/bash
set -eu
# ---------------------
export TICK="✔"
export CROSS="✗"
export NOW="$( date +"%Y-%m-%d" )"
export NOW_TIME="$( date +"%Y-%m-%d %H:%M:%S" )"

BRANCH=devops
HOSTNAME=$( hostname -s )
DIST_ARCH=$( dpkg --print-architecture )
DIST_VERSION=$( lsb_release --release | cut -f2 )

GIT="git -C ${GIT_REPO_PATH}"
TXTRST='\033[;1m'
BLDRED='\033[1;31m'
BLDGRN='\033[1;32m'
BLDCYN='\033[1;36m'

printf "%b\n" "${BLDYLW}[  \"[${DIST_ARCH}]\"-\"${DIST_VERSION}\"- \"${NOW_TIME}\"  ]${TXTRST}\n"
InstanceId=$( curl \"http://169.254.169.254/latest/meta-data/instance-id\" )

printf "%b\n" "${BLDCYN}[ Checking out \"${BRANCH}\" branch the pulling the updates on instance id \"${HOSTNAME^^}\" \"${InstanceId}\" at ${NOW}]${TXTRST}"
"$GIT" status --porcelain --untracked-files=no
"$GIT" branch --show-current && "$GIT" checkout $BRANCH && "$GIT" pull
# shellcheck disable=SC2001
./scripts/bump-version.sh '' "$( date -d "$( echo "$CRAFT_NEW_VERSION" | sed -e 's/^\([0-9]\{2\}\)\.\([0-9]\{1,2\}\)\.[0-9]\+$/20\1-\2-1/') 1 month" +%y.%-m.0.dev0 )"
printf "%b\n" "${BLDCYN}[ Commiting changes on $BRANCH branch and pushing the updates to the remote ]${TXTRST}"
"$GIT" diff --quiet || "$GIT" commit -anm 'meta: Bump new development version' && "$GIT" pull --rebase && "$GIT" push -u origin "$BRANCH"
printf "%b\n" "${BLDYLW}[Success ✔ ${NOW_TIME}]${TXTRST}\n"
