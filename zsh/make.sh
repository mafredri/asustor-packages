#!/usr/bin/env zsh

emulate -L zsh

0=${(%):-%N}

# Change working directory
cd -q ${0:A:h}

source ../scripts/setup/general-setup.sh
source ../scripts/setup/parse-setup-yaml.sh ./config.yml config_

ssh_host=$config_ssh

dist_dir=dist
build_dir=build
build_apk=$build_dir/apk
build_files=$build_dir/files

mkdir -p $dist_dir
mkdir -p $build_files

# Clean up any .DS_Store files
find $build_dir -name .DS_Store -exec rm {} \;

build_arch() {
	local arch=$1
	local prefix=$2
	log() {
		printf "%8s: $@\n" $arch
	}

	log "Building $config_name $config_version for $arch"

	# Cleanup build directory
	[[ -d $build_apk/$arch ]] && rm -rf $build_apk/$arch
	mkdir -p $build_apk/$arch

	log "Copying APK skeleton"
	rsync -a source/ $build_apk/$arch

	typeset -a files

	(( ${#config_files} )) && files+=( $prefix$^config_files )

	print "$files"

	if (( ! ${#files} )); then
		log "No files found? Aborting..."
		continue
	fi

	write_pkgversions $ssh_host $prefix "$files" pkgversions/$arch.txt &

	log "Updating runpath on remote..."
	patched_files=$(update_runpath $ssh_host $prefix /usr/local/AppCentral/$config_package/lib "$files")
	log "Patched runpath for: $patched_files"

	log "Rsyncing files..."
	rsync -q -a --relative --delete --exclude '*.py[cdo]' \
		$ssh_host:"$files" $build_files/

	if (( $? )); then
		log "Failed fetching files for $arch"
		continue
	fi

	log "Copying $arch files to $build_apk/$arch..."
	rsync -a $build_files$prefix/usr/local/AppCentral/$config_package/ $build_apk/$arch/
	rsync -a $build_files$prefix/lib/ $build_apk/$arch/lib/

	config2json $arch > $build_apk/$arch/CONTROL/config.json
	cp CHANGELOG.md $build_apk/$arch/CONTROL/changelog.txt

	log "Building APK..."
	build_apk $build_apk/$arch $dist_dir

	log "Done!"

	wait
}

for arch prefix in ${(kv)adm_arch}; do
	build_arch $arch $prefix &
done

wait

print "\nThank you, come again!"
