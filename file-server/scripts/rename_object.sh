#!/bin/sh

WORKSPACE=$1
BRANCH=$2
REQUEST_BODY=$3

dir=mnt/"${WORKSPACE}"/branches/"${BRANCH_NAME}"

OLD=$(echo $REQUEST_BODY | jq --raw-output '.old')
NEW=$(echo $REQUEST_BODY | jq --raw-output '.new')

mv "${OLD}" "${NEW}"

bin/directory_tree.sh "${dir}"