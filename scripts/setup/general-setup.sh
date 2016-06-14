#!/usr/bin/env zsh

emulate -L zsh

if (( ! ${+commands[apkg-tools.py]})); then
	print "Error: could not find apkg-tools.py in path"
	exit 1
fi

print "Requesting sudo for build session..."
sudo echo -n

typeset -g -A adm_arch=(
	x86-64 	/cross/x86_64-asustor-linux-gnu
	i386 	/cross/i686-asustor-linux-gnu
	arm 	/cross/armv7a-hardfloat-linux-gnueabi
)

typeset -a modified_permissions
build_apk() {
	local from=$1
	local to=$2

	# Keep track of folders for cleanup
	modified_permissions+=( $from )

	# APKs require root privileges, make sure priviliges are correct
	sudo chown -R 0:0 $from
	sudo apkg-tools.py create $from --destination $to/
	sudo chown -R "$(whoami)" $to
	sudo chown -R "$(whoami)" $from
}

ssh_exec() {
	local remote=$1; shift
	ssh $remote 'zsh -s' <<<$@ 2>/dev/null
}

write_pkgversions() {
	local remote=$1
	local prefix=$2
	local -a files=( $3 )
	local target=$4

	remote_files=( ${(@n)$(ssh_exec $ssh_host ls -d $files)} )
	if (( ! ${#remote_files} )); then
		print "Error: pkgversions failed to expand files for $arch"
		return 1
	fi

	local versions
	versions="$(ssh_exec $remote ROOT=$prefix equery b ${remote_files#$prefix} | sort | uniq)"
	if (( $? )); then
		print "Failed writing $target"
		return 1
	fi

	print $versions > $target
	print "Wrote $target"
}

update_runpath() {
	local remote=$1
	local runpath=$3
	local -a files=( $4 )

	local -a output
	output=( $(
		# Patch all executables and descend into directories looking for *.so* files
		ssh_exec $remote for file in ${files}\; do find \$file -type f \\\( -executable -o -name "'*.so*'" \\\) -exec chrpath -r $runpath {} \\\; \; done \
			| egrep -o "([^/]*): new RUNPATH" | cut -d':' -f1
	) )

	print $output
}

cleanup() {
	# Kill child jobs
	for pid in ${${(v)jobstates##*:*:}%\=*}; do
		kill -TERM $pid
	done

	# Reset permissions on working directory
	for m in $modified_permissions; do
		print "Restoring permissions on $m"
		sudo chown -R "$(whoami)" $m
	done
	exit 1
}

trap cleanup INT TERM
