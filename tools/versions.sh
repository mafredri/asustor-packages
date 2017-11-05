#!/usr/bin/env zsh

for i in */*.yml; do ver=($(grep "^version:" $i)); print ${i:h}: $ver[2]; done
