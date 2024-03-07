#!/bin/bash
set -eu
# ---------------------
git checkout devops && git pull
# shellcheck disable=SC2001
./scripts/bump-version.sh '' "$( date -d "$( echo "$CRAFT_NEW_VERSION" | sed -e 's/^\([0-9]\{2\}\)\.\([0-9]\{1,2\}\)\.[0-9]\+$/20\1-\2-1/') 1 month" +%y.%-m.0.dev0 )"
git diff --quiet || git commit -anm 'meta: Bump new development version' && git pull --rebase && git push


git config --get commit.template [36ms]
2024-03-07 22:05:37.253 [info] > git for-each-ref --format=%(refname)%00%(upstream:short)%00%(objectname)%00%(upstream:track)%00%(upstream:remotename)%00%(upstream:remoteref) --ignore-case refs/heads/devops refs/remotes/devops [36ms]
2024-03-07 22:05:37.290 [info] > git status -z -uall [35ms]
2024-03-07 22:05:38.898 [info] > git ls-files --stage -- C:\repo_path\packer_module\packer_module\resources.pkr.hcl [49ms]
2024-03-07 22:05:38.953 [info] > git cat-file -s 3b4cc0f28226b3836fccdb27b0ccf099bd2a2ec6 [51ms]
2024-03-07 22:05:38.990 [info] > git show --textconv :resources.pkr.hcl [34ms]
2024-03-07 22:05:55.585 [info] > git ls-files --stage -- C:\repo_path\packer_module\packer_module\provision\main.pkr.hcl [34ms]
2024-03-07 22:05:55.589 [info] > git show --textconv :provision/main.pkr.hcl [40ms]
2024-03-07 22:05:55.626 [info] > git cat-file -s 63cf11f499b9bbe979867ded3d6acfe07a62c0e5 [37ms]
2024-03-07 22:05:56.089 [info] > git ls-files --stage -- C:\repo_path\packer_module\packer_module\provision\providers.pkr.hcl [31ms]
2024-03-07 22:05:56.093 [info] > git show --textconv :provision/providers.pkr.hcl [37ms]
2024-03-07 22:05:56.124 [info] > git cat-file -s 5940e835ba98a6db50fcbed38824ce09140c2a7e [32ms]
