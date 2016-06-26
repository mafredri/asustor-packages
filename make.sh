#!/usr/bin/env zsh

emulate -L zsh

0=${(%):-%N}

# Change working directory
cd -q ${0:A:h}

source scripts/setup/general-setup.sh
source scripts/setup/python-site-packages.sh

if ! [[ -d $1 ]] && [[ $1 != all ]]; then
	print -u2 "please provide make target"
	exit 1
fi

make_package() {
	cd -q $1

	if [[ -f pre_setup.sh ]]; then
		source pre_setup.sh
	fi

	source ../scripts/setup/parse-setup-yaml.sh ./config.yml config_

	ssh_host=$config_ssh

	dist_dir=dist
	build_dir=build
	mkdir -p $dist_dir $build_dir

	if [[ $config_case_sensitive == True ]]; then
		source ../scripts/case_sensitive.sh
		cs_create build.dmg.sparseimage ${config_package}_build
		cs_attach build.dmg.sparseimage $build_dir
	fi

	build_apk=$build_dir/apk
	build_files=$build_dir/files
	mkdir -p $build_apk $build_files

	# Clean up any .DS_Store files
	find $build_dir -name .DS_Store -exec rm {} \;

	build_arch() {
		local arch=$1
		local prefix=$2
		log() {
			local len=$(( ${#config_package} + 8 + 2))
			printf "%${len}s: $@\n" "${arch}(${config_package})"
		}

		log "Building $config_name $config_version for $arch"

		# Cleanup build directory
		[[ -d $build_apk/$arch ]] && rm -rf $build_apk/$arch
		mkdir -p $build_apk/$arch

		log "Copying APK skeleton"
		rsync -a source/ $build_apk/$arch

		typeset -a files exclude

		(( ${#config_files} )) && files+=( $prefix$^config_files )
		(( ${#config_site_packages} )) && {
			python_site_packages=( $(get_site_packages $ssh_host $prefix "$config_site_packages") )
			files+=( $prefix$^python_site_packages )
		}

		if (( ! ${#files} )); then
			log "No files found? Aborting..."
			continue
		fi

		(( ${#config_exclude} )) && exclude+=( "--exclude "$^config_exclude )

		write_pkgversions $ssh_host $prefix "$files" pkgversions/$arch.txt &

		if (( ${#config_runpath} > 5 )) ; then # ignore null / false
			log "Updating runpath on remote..."
			patched_files=$(update_runpath $ssh_host $prefix $config_runpath "$files")
			log "Patched runpath for: $patched_files"
		fi

		log "Rsyncing files..."
		rsync -q -a --relative --delete ${(s. .)exclude} \
			$ssh_host:"$files" $build_files/

		if (( $? )); then
			log "Failed fetching files for $arch"
			continue
		fi

		log "Copying $arch files to $build_apk/$arch..."
		rsync -a $build_files$prefix${config_root%/}/ $build_apk/$arch/

		# Run pre-build script
		if [[ -f pre_build.sh ]]; then
			source pre_build.sh $build_apk/$arch
		fi

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

	if [[ $config_case_sensitive == True ]]; then
		cs_detach $build_dir
		cs_compact build.dmg.sparseimage
	fi
}

if [[ $1 == all ]]; then
	for i in */config.yml; do
		make_package ${i:h} &
	done
	wait
else
	make_package $1
fi

print "\nThank you, come again!"
