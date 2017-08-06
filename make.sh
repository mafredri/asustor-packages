#!/usr/bin/env zsh

emulate -L zsh

0=${(%):-%N}

# Change working directory
cd -q ${0:A:h}

source .environment
source scripts/setup/general-setup.sh
source scripts/setup/python-site-packages.sh

typeset -a ARCH

typeset -a arch
zparseopts -E -D \
	a+:=arch arch+:=arch -arch+:=arch

for key val in $arch; do
	ARCH+=($val)
done
unset arch

typeset -A SSH_HOSTS=(
	x86-64	ascross
	i386	ascross
	arm	ascross-arm
)

if ! [[ -d $1 ]] && [[ $1 != all ]] && [[ $1 != upload ]]; then
	print -u2 "please provide make target"
	exit 1
fi

if [[ $1 == upload ]]; then
	shift
	apks=()
	for pkg in $@; do
		source scripts/setup/parse-setup-yaml.sh $pkg/config.yml config_
		apks+=($pkg/dist/*${config_version}*)
	done
	print "Uploading packages: $apks"
	args=("-apk "${^apks})
	asdev ${=args}
	exit $?
fi

make_package() {
	cd -q $1

	if [[ -f pre_setup.sh ]]; then
		source pre_setup.sh
	fi

	source ../scripts/setup/parse-setup-yaml.sh ./config.yml config_

	dist_dir=dist
	build_dir=build
	mkdir -p $dist_dir $build_dir

	if [[ $config_case_sensitive == 1 ]]; then
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
		local ssh_host=$SSH_HOSTS[$arch]
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

		if (( ${#config_files} )) || (( ${#config_site_packages} )); then
			(( ${#config_files} )) && files+=( $prefix$^config_files )
			(( ${#config_site_packages} )) && {
				python_site_packages=( $(get_site_packages $ssh_host $prefix "$config_site_packages") )
				files+=( $prefix$^python_site_packages )
			}

			if [[ $config_updated_libstdcpp == 1 ]] && [[ $arch != arm ]]; then
				# App requires an updated version of libstdc++ so we pull it in as
				# an extra. The ARM already supports libstdc++ from GCC 4.8 so we
				# skip it.
				gcc_path=/usr/lib/gcc/${prefix:t}/4.9.3
				files+=( "$prefix$gcc_path/libstdc++.so*" )

				config_runpath=$config_runpath:/usr/local/AppCentral/$config_package${gcc_path#$config_root}
			fi

			if (( ! ${#files} )); then
				log "No files found? Aborting..."
				continue
			fi

			(( ${#config_exclude} )) && exclude+=( "--exclude "$^config_exclude )

			write_pkgversions $ssh_host $prefix "$files" pkgversions/$arch.txt $config_eprefix &

			if (( ${#config_runpath} > 1 )) ; then # ignore null / false
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
			rsync -a $build_files/${prefix#\/}${config_root%/}/ $build_apk/$arch/
		fi

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

	if (( $#config_architecture > 1 )); then
		build_arch $config_architecture $adm_arch[$config_architecture]
	elif (( $#ARCH )); then
		for arch in $ARCH; do
			build_arch $arch $adm_arch[$arch]
		done
	else
		for arch prefix in ${(kv)adm_arch}; do
			build_arch $arch $prefix &
		done
	fi

	wait

	if [[ $config_case_sensitive == 1 ]]; then
		cs_detach $build_dir
		cs_compact build.dmg.sparseimage
	fi
}

print "Requesting sudo for build session..."
sudo echo -n

if [[ $1 == all ]]; then
	for i in */config.yml; do
		make_package ${i:h} &
	done
	wait
else
	for pkg in $@; do
		make_package $pkg &
	done
	wait
fi

print "\nThank you, come again!"

