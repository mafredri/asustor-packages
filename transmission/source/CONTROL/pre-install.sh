#!/bin/sh

if [[ -z $APKG_PKG_DIR ]]; then
	PKG_DIR=/usr/local/AppCentral/transmission
else
	PKG_DIR="${APKG_PKG_DIR}"
fi

CONFIG="${PKG_DIR}/config"

case "$APKG_PKG_STATUS" in
	install)
		;;
	upgrade)
		if [[ -d $CONFIG ]]; then
			cp -af "${CONFIG}"/* "${APKG_TEMP_DIR}/"
		else
			cp -af "${PKG_DIR}"/* "${APKG_TEMP_DIR}/"
			# Clean up old directories from app root
			rm -rf "${APKG_TEMP_DIR}/CONTROL"
			rm -rf "${APKG_TEMP_DIR}/bin"
			rm -rf "${APKG_TEMP_DIR}/lib"
			rm -rf "${APKG_TEMP_DIR}/web"
		fi
		;;
	*)
		;;
esac

exit 0
