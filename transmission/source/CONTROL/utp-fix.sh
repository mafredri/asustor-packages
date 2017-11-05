#!/bin/sh

. /etc/script/lib/command.sh

# Since µTP is enabled by default, transmission
# needs large kernel buffers for the UDP socket.
$AS_SYSCTL -w net.core.rmem_max=4194304 >/dev/null
$AS_SYSCTL -w net.core.wmem_max=1048576 >/dev/null
