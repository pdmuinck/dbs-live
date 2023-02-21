#!/bin/sh

ROOT=$1

tree "${ROOT}" -J -f --noreport | sed 's/"contents"/"children"/g; s/"name"/"path"/g' | jq --raw-output '.[0]'