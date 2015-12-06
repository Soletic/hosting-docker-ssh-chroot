#!/bin/bash

# Setup config ssh
if [ -f /etc/ssh/sshd_config_addons ]; then
	sed -ri -e "s~%CHROOT_INSTALL_DIR%~${CHROOT_INSTALL_DIR}~g" /etc/ssh/sshd_config
	rm /etc/ssh/sshd_config_addons
fi

# Plugins setup
plugins=( $(find / -wholename "${CHROOT_INSTALL_DIR}/plugins/*/setup.sh" -type f) )
for plugin in "${plugins[@]}"
do
	echo "[plugin] setup with $plugin"
	$plugin
done

if [ ! -f /etc/passwd.origin ]; then
	cp /etc/passwd /etc/passwd.origin
	cp /etc/group /etc/group.origin
fi

# Load users
sshusers_file=${CHROOT_USERS_HOME_DIR}/.sshusers
IFS=$'\r\n' GLOBIGNORE='*' :; users=($(cat $sshusers_file))
for userline in "${users[@]}"
do
	echo " Load ${user_data[0]}"
	IFS=':' read -r -a user_data <<< "$userline"
	# Check user exist
	if id -u "${user_data[0]}" >/dev/null 2>&1; then
		# mount data in chrooted home
		mount --bind -o bind "${user_data[4]}" "${user_data[3]}"
	else
		# create
		/chroot.sh adduser -u "${user_data[0]}" -id "${user_data[1]}" -p "${user_data[2]}"
	fi
done