#!/bin/bash

# Setup config ssh
if [ -f /etc/ssh/sshd_config_addons ]; then
	sed -ri -e "s~%CHROOT_DIR_BASE%~${CHROOT_DIR_USERS}~g" /etc/ssh/sshd_config
	sed -ri -e "s~%USER_CHROOT_INSTALL_DIR%~${USER_CHROOT_INSTALL_DIR}~g" /etc/ssh/sshd_config
	rm /etc/ssh/sshd_config_addons
fi

# Run the base
/run.sh