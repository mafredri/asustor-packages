#!/bin/sh

if [[ -z $APKG_PKG_DIR ]]; then
    PKG_DIR=/usr/local/AppCentral/transmission
else
    PKG_DIR="${APKG_PKG_DIR}"
fi

. /lib/lsb/init-functions

NAME=transmission-daemon
DAEMON=transmission-daemon
DAEMON_ARGS=""
USER=admin
GROUP=administrators
PIDFILE=/var/run/${NAME}.pid

start_daemon() {
	"${PKG_DIR}/CONTROL/utp-fix.sh"

	# Allow transmission to manage the pidfile.
	touch $PIDFILE; chown admin $PIDFILE

	start-stop-daemon -S --quiet --chuid $USER:$GROUP --user $USER --exec $DAEMON -- \
		--pid-file $PIDFILE --config-dir "${PKG_DIR}"/config $DAEMON_ARGS
}

_stop_daemon() {
	start-stop-daemon -K --quiet --user $USER --exec $DAEMON --pidfile $PIDFILE $@
}

stop_daemon() {
	_stop_daemon

	if ! wait_for_status 1 10; then
		echo "Taking too long, killing ${NAME}..."
		_stop_daemon --signal 9
	fi
}

test_daemon() {
	_stop_daemon --test
}

reload_daemon() {
	_stop_daemon --signal 1
}

wait_for_status() {
	counter=$1
	while [[ $counter -lt $2 ]]; do
		if ! test_daemon; then
			return 0
		fi
		counter=$(( counter + 1 ))
		sleep 1
	done
	return 1
}

case "$1" in
	start)
		if ! test_daemon; then
			echo "Starting ${NAME}..."
			start_daemon
		else
			echo "${NAME} is already running"
		fi
		;;
	stop)
		if test_daemon; then
			echo "Stopping ${NAME}..."
			stop_daemon
		else
			echo "${NAME} is not running"
		fi
		;;
	restart)
		if test_daemon; then
			echo "Stopping ${NAME}..."
			stop_daemon
		fi
		echo "Starting ${NAME}..."
		start_daemon
		;;
	reload)
		if test_daemon; then
			echo "Reloading ${NAME}"
			reload_daemon
		else
			echo "${NAME} is not running"
		fi
		;;
	status)
		if test_daemon; then
			echo "${NAME} is running"
			exit 0
		else
			echo "${NAME} is not running"
			exit 1
		fi
		;;
	*)
		echo "usage: $0 {start|stop|restart|reload|status}"
		exit 1
		;;
esac


exit 0
