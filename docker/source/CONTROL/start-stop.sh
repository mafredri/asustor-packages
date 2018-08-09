#!/bin/sh

NAME="Docker CE"
PACKAGE="docker-ce"

if [[ -z $APKG_PKG_DIR ]]; then
	PKG_DIR=/usr/local/AppCentral/${PACKAGE}
else
	PKG_DIR="$APKG_PKG_DIR"
fi

cgroupfs_mount() {
	# See https://github.com/tianon/cgroupfs-mount/blob/master/cgroupfs-mount
	if grep -v '^#' /etc/fstab | grep -q cgroup || [ ! -e /proc/cgroups ] || [ ! -d /sys/fs/cgroup ]; then
		return
	fi
	if ! mountpoint -q /sys/fs/cgroup; then
		mount -t tmpfs -o uid=0,gid=0,mode=0755 cgroup /sys/fs/cgroup
	fi
	(
		cd /sys/fs/cgroup
		for sys in $(awk '!/^#/ { if ($4 == 1) print $1 }' /proc/cgroups); do
			mkdir -p $sys
			if ! mountpoint -q $sys; then
				if ! mount -n -t cgroup -o $sys cgroup $sys; then
					rmdir $sys || true
				fi
			fi
		done
	)
}

die() {
	echo "ERROR: $@"
	exit 1
}

case "$1" in
	start)
		cgroupfs_mount
		touch "$DOCKER_LOGFILE"
		chgrp docker "$DOCKER_LOGFILE"
		;;
	stop)
		echo "Stopping ${NAME}..."
		;;
	restart)
		;;
	status)
		;;
	*)
		echo "usage: $0 {start|stop|restart|status}"
		exit 1
		;;
esac

exit 0
