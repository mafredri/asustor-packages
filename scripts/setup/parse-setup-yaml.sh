#!/usr/bin/env zsh

emulate -L zsh

conf_yaml=$1
conf_prefix=$2

yaml() { shyaml $1 $2 <$conf_yaml }

if (( ! ${+commands[shyaml]} )); then
	print "shyaml required:"
	print "  pip install shyaml"
	exit 1
fi

if (( ! ${+commands[yaml2json]} )); then
	print "yamljs required:"
	print "  npm install -g yamljs"
	exit 1
fi

# Parse configuration into global vars
for key in $(yaml keys); do
	if [[ $key =~ [-] ]]; then
		print "Found unsafe config key: $key, exiting..."
		exit 1
	fi

	case $(yaml get-type $key) in
		NoneType)
			;;  # Not set
		bool)
			typeset -g "$conf_prefix$key"
			local val=$(yaml get-value $key)
			if [[ $val = True ]]; then
				val=1
			else
				val=0
			fi
			typeset "$conf_prefix$key"="$val"
			;;
		sequence)
			typeset -g -a "$conf_prefix$key"
			eval "$conf_prefix$key=( \$(yaml get-values \$key) )"
			;;
		*)
			typeset -g "$conf_prefix$key"
			typeset "$conf_prefix$key"="$(yaml get-value $key)"
			;;
	esac
done

config2json() {
	local arch=$1
	typeset ${conf_prefix}architecture=$arch

	# Update dynamic variables in configuration file
	dynamic_conf_vars=( package name version architecture firmware )
	config=${conf_prefix}config
	config=${(P)config}
	for key in $dynamic_conf_vars; do
		real_key="$conf_prefix$key"
		config=${config/${(U)key}/${(P)real_key}}
	done

	# Convert config to JSON
	yaml2json --pretty --indentation 2 - <<<$config
}
