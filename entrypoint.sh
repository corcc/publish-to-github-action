#!/bin/sh

# check values
if [ -z "${GITHUB_TOKEN}" ]; then
    echo "error: not found GITHUB_TOKEN"
    exit 1
fi

if [ -z "${BRANCH_NAME}" ]; then
   echo "NO BRANCH SELECTED"
   BRANCH_NAME="$(git rev-parse --abbrev-ref HEAD)"
   readonly BRANCH_NAME
   echo "set \$BRANCH_NAME to current branch : $BRANCH_NAME"
else
   echo "set \$BRANCH_NAME to current branch : $BRANCH_NAME"
fi
# initialize git
remote_repo="https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
git config http.sslVerify false
git config user.name "Automated Publisher"
git config user.email "actions@users.noreply.github.com"
git remote add publisher "${remote_repo}"
git show-ref # useful for debugging
git branch --verbose

# install lfs hooks
git lfs install

# publish any new files
git checkout "${BRANCH_NAME}"
git add -A
TZPATH=$(find /usr/share/zoneinfo | grep "zoneinfo/${TIMEZONE}")
ln -s "$TZPATH" /etc/localtime
ls -la /etc/localtime
timestamp=$(date)
git commit -m "${TASK_NAME} ${timestamp} ${GITHUB_SHA}" || exit 0
git pull --rebase publisher "${BRANCH_NAME}"
git push publisher "${BRANCH_NAME}"
