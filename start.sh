#!/bin/bash

# Setup config ssh
if [ -f /etc/ssh/sshd_config_addons ]; then
	sed -i "s/%CHROOT_DIR_BASE%/${CHROOT_DIR_BASE}/g" /etc/ssh/sshd_config
	rm /etc/ssh/sshd_config_addons
fi

# Run the base
/run.sh