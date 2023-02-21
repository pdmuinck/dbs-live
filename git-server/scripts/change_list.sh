#!/bin/sh

WORKSPACE=$1
BRANCH=$2


cd mnt/"${WORKSPACE}"/branches/"${BRANCH}"
files=$( git status --porcelain=v1 | sed ' s/ D/D/; s/A /A/; s/??/A/; s/ M/M/')
cd ../../../..

jq --raw-output --null-input \
--arg files "$files" \
'$files | split("\n") | map(. | split(" ") | {"status": .[0], "fileName": .[1]})'

