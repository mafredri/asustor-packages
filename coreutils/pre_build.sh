#!/usr/bin/env zsh

emulate -L zsh

apk_path=$1

mkdir -p ${apk_path%/}/libexec/gnubin
for f in ${apk_path%/}/bin/g*; do
	fname=${f:t}
	ln -s ../../bin/${fname} ${apk_path%/}/libexec/gnubin/${fname#g}
done
