#!/usr/bin/env zsh
image=$1
name=${1:t:r}
path=${1:h}
img256=$path/${name}256.png
img90=$path/${name}90.png

/usr/local/bin/convert $image -geometry 1000x256 -crop 256x256-0-0! $img256
/usr/local/bin/convert -geometry 90x90 $img256 $img90
