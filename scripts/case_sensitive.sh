#!/usr/bin/env zsh

emulate -L zsh

cs_create() {
	local image=$1
	local name=$2
	local size=${3:-250m}
	[[ -f $image ]] && return
	hdiutil create -type SPARSE -fs 'Case-sensitive Journaled HFS+' -size $size -volname $name $image
}

cs_attach() {
	local image=$1
	local target=$2
	hdiutil attach -nobrowse -mountpoint $target $image
}

cs_detach() {
	local target=$1
	hdiutil detach -force $target
}

cs_compact() {
	local image=$1
	hdiutil compact $image -batteryallowed
}
