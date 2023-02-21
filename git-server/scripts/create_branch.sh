#!/bin/sh

BRANCH_NAME=$1
WORKSPACE=$2

dir=mnt/"${WORKSPACE}"/branches/"${BRANCH_NAME}"

mkdir -p "${dir}"

git clone git@bitbucket.org:persgroep/data-build-service.git "${dir}"
cd "${dir}" && git checkout -b "${BRANCH_NAME}" && git push origin "${BRANCH_NAME}" && cd ../../../..

bin/directory_tree.sh "${dir}"