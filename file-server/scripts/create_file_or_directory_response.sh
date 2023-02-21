#!/bin/sh

root=$(echo "$1" | cut -d'/' -f 1-4)
bin/directory_tree.sh "${root}"



