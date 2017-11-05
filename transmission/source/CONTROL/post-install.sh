#!/bin/sh

if [[ -z $APKG_PKG_DIR ]]; then
	PKG_DIR=/usr/local/AppCentral/transmission
else
	PKG_DIR="${APKG_PKG_DIR}"
fi

CONFIG="${PKG_DIR}/config"

case "${APKG_PKG_STATUS}" in
	install)
		;;
	upgrade)
		# Restore configuration
		if [[ ! -d $CONFIG ]]; then
			mkdir "${CONFIG}"
		fi
		cp -af "${APKG_TEMP_DIR}"/* "${CONFIG}/"
		;;
	*)
		;;
esac

chown -R admin:administrators "${CONFIG}"

"${PKG_DIR}/CONTROL/utp-fix.sh"

exit 0
