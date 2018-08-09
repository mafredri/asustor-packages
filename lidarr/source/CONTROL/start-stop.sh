#!/bin/sh

. /usr/local/AppCentral/lidarr/CONTROL/env.sh

PID=${PKG_CONF}/${PKG_PID}
CHUID=${DAEMON_USER}
# Shadow mono, see bin/mono
DAEMON="$PKG_BIN_PATH/mono"
RADARR="${PKG_PATH}/Lidarr/Lidarr.exe"


start_daemon() {
	# Set umask to create files with world r/w
	umask 0

	start-stop-daemon -S --background --quiet --chuid "${CHUID}" --user "${USER}" --exec "$DAEMON" -- "$RADARR" /data="$PKG_CONF"
}

stop_daemon() {
	start-stop-daemon -K --quiet --user "${USER}" --pidfile "${PID}"

	wait_for_status 1 20

	if [ $? -eq 1 ]; then
		echo "Taking too long, killing ${NAME}..."
		start-stop-daemon -K --signal 9 --quiet --user "${USER}" --pidfile "${PID}"
	fi
}

daemon_status() {
	start-stop-daemon -K --quiet --test --user "${USER}" --pidfile "${PID}"
	RETVAL=$?
	[ ${RETVAL} -eq 0 ] || return 1
}

wait_for_status() {
	counter=$2
	while [ "$counter" -gt 0 ]; do
		daemon_status
		[ $? -eq "$1" ] && return
		counter=$(( counter - 1 ))
		sleep 1
	done
	return 1
}

case $1 in
	start)
		if daemon_status; then
			echo "${NAME} is already running"
		else
			echo "Starting ${NAME}..."
			start_daemon
		fi
		;;

	stop)
		if daemon_status; then
			echo "Stopping ${NAME}..."
			stop_daemon
		else
			echo "${NAME} is not running"
		fi
		;;
	restart)
		if daemon_status; then
			echo "Stopping ${NAME}..."
			stop_daemon
		fi
		echo "Starting ${NAME}..."
		start_daemon
		;;
	status)
		if daemon_status; then
			echo "${NAME} is running"
			exit 0
		else
			echo "${NAME} is not running"
			exit 1
		fi
		;;
	*)
		echo "usage: $0 {start|stop|restart|status}"
		exit 1
		;;
esac

exit 0
