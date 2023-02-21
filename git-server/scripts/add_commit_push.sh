#!/bin/sh

WORKSPACE=$1
BRANCH=$2
REQUEST_BODY=$3
MESSAGE=$(echo ${REQUEST_BODY} | jq '.message')
FILES=$(echo ${REQUEST_BODY} | jq --raw-output '.files')

dir=mnt/"${WORKSPACE}"/branches/"${BRANCH}"

USER_NAME=$(jq --raw-output '.userName' mnt/"${WORKSPACE}"/git_config.json)
EMAIL=$(jq --raw-output '.email' mnt/"${WORKSPACE}"/git_config.json)


cd $dir > /dev/null 2>&1
git config user.name "${USER_NAME}" > /dev/null 2>&1
git config user.email "${EMAIL}" > /dev/null 2>&1
git add $FILES > /dev/null 2>&1
git commit -m "${MESSAGE}" > /dev/null 2>&1
commit_success=$?
git push --set-upstream origin $BRANCH > git_push_output 2>&1
pull_request_link=$(grep 'https' git_push_output | rev | xargs | cut -d' ' -f 1 | rev)
push_success=$?
rm git_push_output

cd ../../../..

change_list=$(bin/change_list.sh "${WORKSPACE}" "${BRANCH}")

jq --raw-output --null-input \
--arg commit_success "$commit_success" \
--arg push_success "$push_success" \
--arg change_list "$change_list" \
--arg pull_request_link "$pull_request_link" \
'{"commitSuccess": $commit_success, "pushSuccess": $push_success, "changeList": $change_list, "pullRequestLink": $pull_request_link}'



