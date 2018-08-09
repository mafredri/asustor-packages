#!/usr/bin/env zsh

emulate -L zsh

apk_path=$1

(cd $apk_path;
	ln -s usr/bin bin
)
