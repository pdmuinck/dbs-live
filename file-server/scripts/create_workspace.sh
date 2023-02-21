#!/bin/sh

WORKSPACE=$1
REQUEST_BODY=$2

mkdir -p mnt/"${WORKSPACE}"/branches
echo $REQUEST_BODY > mnt/"${WORKSPACE}"/git_config.json

bin/directory_tree.sh mnt/"${WORKSPACE}"



