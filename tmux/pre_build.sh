#!/usr/bin/env zsh

emulate -L zsh

apk_path=$1

(cd $apk_path && rsync -a usr/ ./ && rm -r usr)
