#!/bin/sh

if [[ -z $APKG_PKG_DIR ]]; then
	PKG_DIR=/usr/local/AppCentral/lidarr
else
	PKG_DIR="$APKG_PKG_DIR"
fi

# Source env variables
. "${PKG_DIR}/CONTROL/env.sh"

install_lidarr() {
	tar xzf "$PKG_DIR"/.release/*.tar.gz -C "$PKG_DIR/"
}

case "${APKG_PKG_STATUS}" in
	install)
		if [[ ! -f "$PKG_CONF/config.xml" ]]; then
			cp "$PKG_CONF/config_base.xml" "$PKG_CONF/config.xml"
		fi

		chown -R "$DAEMON_USER" "$PKG_CONF"

		install_lidarr
		;;
	upgrade)
		rsync -ra "$APKG_TEMP_DIR/config/" "$PKG_CONF/"

		# Restore application or extract included version
		if [[ -d "$APKG_TEMP_DIR/Lidarr" ]]; then
			cp -af "$APKG_TEMP_DIR/Lidarr" "$PKG_DIR/"
		else
			install_lidarr
		fi
		;;
	*)
		;;
esac

chown -R "$DAEMON_USER" "$PKG_DIR/Lidarr"

exit 0
