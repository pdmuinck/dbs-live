#!/bin/sh

WORKSPACE=$1

BRANCHES=$(ls mnt/"${WORKSPACE}"/branches)

jq --raw-output --null-input \
  --arg workspace "$WORKSPACE" \
  --arg branches "$BRANCHES" \
  '{"workspace": $workspace, "branches": $branches}' \
  | jq --raw-output 'try(.branches |= split("\n") )'



