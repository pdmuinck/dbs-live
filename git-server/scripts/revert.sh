#!/bin/sh

WORKSPACE=$1
BRANCH=$2
REQUEST_BODY=$3

EXISTING_FILES=$(echo ${REQUEST_BODY} | jq --raw-output '.existingFiles')
NEW_FILES=$(echo ${REQUEST_BODY} | jq --raw-output '.newFiles')


cd mnt/"${WORKSPACE}"/branches/"${BRANCH}"
git checkout HEAD -- $EXISTING_FILES > /dev/null 2>&1
git clean -f $NEW_FILES > /dev/null 2>&1
cd ../../../..

bin/change_list.sh "${WORKSPACE}" "${BRANCH}"


