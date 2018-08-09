#!/bin/sh

if [[ -z $APKG_PKG_DIR ]]; then
	PKG_DIR=/usr/local/AppCentral/docker-ce
else
	PKG_DIR=$APKG_PKG_DIR
fi

install_modules() {
	find "$PKG_DIR"/usr/src/linux -name "*.ko" -exec ln -s {} /lib/modules/$(uname -r) \;
}

case "${APKG_PKG_STATUS}" in
	install)
		install_modules
		;;
	upgrade)
		install_modules
		;;
	*)
		;;
esac

exit 0
