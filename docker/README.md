# Docker Community Edition for ADM

This package ports [Docker CE](https://www.docker.com/community-edition) to ASUSTOR ADM.

## About

Docker Community Edition (CE) is ideal for developers and small teams looking to get started with Docker and experimenting with container-based apps. Available for many popular infrastructure platforms like desktop, cloud and open source operating systems, Docker CE provides an installer for a simple and quick install so you can start developing immediately. Docker CE is integrated and optimized to the infrastructure so you can maintain a native app experience while getting started with Docker. Build the first container, share with team members and automate the dev pipeline, all with Docker Community Edition.

groupadd docker

/volume1/.@plugins/AppCentral/docker-ce/sbin/modprobe overlay
modprobe: module 'overlay' not found
insmod: can't read '/lib/modules/4.4.24/overlay.ko': No such file or directory
/volume1/.@plugins/AppCentral/docker-ce/sbin/modprobe -va bridge br_netfilter
insmod: can't read '/lib/modules/4.4.24/br_netfilter.ko': No such file or directory
/volume1/.@plugins/AppCentral/docker-ce/sbin/modprobe -va nf_nat
/volume1/.@plugins/AppCentral/docker-ce/sbin/modprobe -va xt_conntrack
/volume1/.@plugins/AppCentral/docker-ce/sbin/modprobe -va xfrm_user
/volume1/.@plugins/AppCentral/docker-ce/sbin/modprobe -va xfrm_algo
/volume1/.@plugins/AppCentral/docker-ce/sbin/modprobe -va nf_conntrack
/volume1/.@plugins/AppCentral/docker-ce/sbin/modprobe -va nf_conntrack_netlink
modprobe: module 'nf_conntrack_netlink' not found
insmod: can't read '/lib/modules/4.4.24/nf_conntrack_netlink.ko': No such file or directory

ip link del docker0
