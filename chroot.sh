#!/bin/bash

sshusers_file=${CHROOT_USERS_HOME_DIR}/.sshusers
# Directory target to mount user data
TARGET_USER_DIR=/var/www

function _index_user_information {
	local user=$1
	local user_id=$2
	local password=$3
	local chroot_dir=$4
	local user_home_dir=$5

	# remove if exist
	_remove_user_from_index $user

	if [ ! -f $sshusers_file ]; then
		touch $sshusers_file
		# only root can read
		chmod og-rxw $sshusers_file
	fi
	echo "$user:$user_id:$password:$chroot_dir:$user_home_dir" >> $sshusers_file
}
function _remove_user_from_index {
	user=$1
	if [ ! -f $sshusers_file ]; then
		return
	fi
	sed -ri -e "/^$user:/d" $sshusers_file
}

function _setup_user {

	local chroot_dir=$1
	local user=$2
	local user_id=$3
	local user_home_dir=$4
	local user_password=$5

	rm -Rf $chroot_dir/{dev,etc,lib,lib64,usr,bin,tmp,proc}
	mkdir -p $chroot_dir/{dev,etc,lib,lib64,usr,bin,tmp,proc}
	mkdir -p $chroot_dir/usr/bin
	mkdir -p $chroot_dir/usr/share
	if [ ! -d ${chroot_dir}${TARGET_USER_DIR} ]; then
		mkdir -p ${chroot_dir}${TARGET_USER_DIR}
	fi
	chown root:root $chroot_dir
	chmod 777 $chroot_dir/tmp
	chmod go-w $chroot_dir
	mknod -m 666 $chroot_dir/dev/tty c 5 0
	mknod -m 666 $chroot_dir/dev/null c 1 3
	mknod -m 444 $chroot_dir/dev/random c 1 8
	mknod -m 444 $chroot_dir/dev/urandom c 1 9
	chown root:tty $chroot_dir/dev/tty
	
	/install_bin.sh $chroot_dir
	# Copy passwd
	cp -f /etc/passwd.origin $chroot_dir/etc/passwd
	cp -f /etc/group.origin $chroot_dir/etc/group
	echo "${user}:x:${user_id}:${user_id}::${TARGET_USER_DIR}:/bin/bash" >> $chroot_dir/etc/passwd
	echo "${user}:x:${user_id}:" >> $chroot_dir/etc/group
	
	if id -u "$user" >/dev/null 2>&1; then
		:
	else
		if [ "$user_password" = "" ]; then
			USER_PASSWORD=$(pwgen -s 12 1)
		else
			USER_PASSWORD=$user_password
		fi
		useradd -s /bin/bash -u $user_id --home-dir=${TARGET_USER_DIR} --no-create-home --user-group -G sshusers $user; echo $user:$USER_PASSWORD | chpasswd
		# backup password
		echo "========================================================================"
		echo "	Password for $user : $USER_PASSWORD"
		echo "========================================================================"
		echo "$user:$USER_PASSWORD" > $chroot_dir/credentials

		# backup information
		_index_user_information "$user" "$user_id" "$USER_PASSWORD" "${chroot_dir}${TARGET_USER_DIR}" "$user_home_dir"
	fi

	if [ ! -d $user_home_dir ]; then
		mkdir -p $user_home_dir
	fi

	# ssh keys
	if [ ! -d $user_home_dir/.ssh ]; then
		mkdir $user_home_dir/.ssh
		touch $user_home_dir/.ssh/authorized_keys
	fi
	chown $user:$user $user_home_dir/.ssh $user_home_dir/.ssh/authorized_keys

	# mount home
	chown $user:$user ${chroot_dir}${TARGET_USER_DIR}
	mount --bind -o bind $user_home_dir ${chroot_dir}${TARGET_USER_DIR}	
}

case "$1" in
	adduser)
		# Usage : adduser --user|-u soletic -id 10001 -dir|--chroot-dir /chroot/soletic -home|--user-home-dir /home/soletic
		while [[ $# > 1 ]] 
		do
			key="$1"
			case $key in
				-u|--user)
					user="$2"
					shift # past argument
					;;
				-id)
					user_id="$2"
					shift # past argument
					;;
				-dir|--chroot-dir)
					chroot_dir="$2"
					shift # past argument
					;;
				-home|--user-home-dir)
					user_home_dir="$2"
					shift # past argument
					;;
				-p|--password)
					user_password="$2"
					shift # past argument
					;;
				*)
					# unknown option
					shift
					;;
			esac
		done
		if [ -z "$user" ] || [ -z "$user_id" ]; then
			>&2 echo "[adduser] argument missing. Usage : $0 $1 --user|-u <username> -id <userid> -p <password> -dir|--chroot-dir <absolute path> -home|--user-home-dir <absolute path>"
			>&2 echo "[adduser] -dir (default : ${CHROOT_INSTALL_DIR}/<username>) : directory installation of the chroot user environment"
			>&2 echo "[adduser] -home (default : ${CHROOT_USERS_HOME_DIR}/<username>${CHROOT_USER_HOME_BASEPATH}) : dir path of the user data and mounted as the home dir of the chroot environment"
			exit 1
		fi
		if [ -z "$user_home_dir" ]; then
			user_home_dir=${CHROOT_USERS_HOME_DIR}/$user${CHROOT_USER_HOME_BASEPATH}
		fi
		if [ -z "$chroot_dir" ]; then
			chroot_dir=${CHROOT_INSTALL_DIR}/$user
		fi
		if [ ! -d $chroot_dir ]; then
			mkdir -p $chroot_dir
		fi
		_setup_user $chroot_dir $user $user_id $user_home_dir $user_password
		;;
	binupgrade)
		# Load users
		sshusers_file=${CHROOT_USERS_HOME_DIR}/.sshusers
		IFS=$'\r\n' GLOBIGNORE='*' :; users=($(cat $sshusers_file))
		for userline in "${users[@]}"
		do
			echo " Load ${user_data[0]}"
			IFS=':' read -r -a user_data <<< "$userline"
			# Check user exist
			if id -u "${user_data[0]}" >/dev/null 2>&1; then
				echo "Upgrade $chroot_dir"
				/install_bin.sh ${CHROOT_INSTALL_DIR}/${user_data[0]}
			fi
		done
		;;
	deluser)
		while [[ $# > 1 ]] 
		do
			key="$1"
			case $key in
				-u|--user)
					user="$2"
					shift # past argument
					;;
				-dir|--chroot-dir)
					chroot_dir="$2"
					shift # past argument
					;;
				*)
					# unknown option
					shift
					;;
			esac
		done
		if [ -z "$user" ]; then
			>&2 echo "[deluser] argument missing. Usage : $0 deluser --user|-u <username>"
			>&2 echo "[deluser] -dir (default : ${CHROOT_INSTALL_DIR}/<username>) : directory installation of the chroot user environment"
			exit 1
		fi
		if [ -z "$chroot_dir" ]; then
			chroot_dir=${CHROOT_INSTALL_DIR}/$user
		fi
		# Check user exist
		if id -u "$user" >/dev/null 2>&1; then
			userdel $user
		else
			>&2 echo "[deluser] $user doesn't exist"
		fi
		# Umount home
		if [ -d ${chroot_dir}${TARGET_USER_DIR} ]; then
			# Force kill process being able to prevent umount
			fuser -ks ${chroot_dir}${TARGET_USER_DIR}
			# Umount
			eval "$( (umount ${chroot_dir}${TARGET_USER_DIR} && exitcode=$? >&2 ) 2> >(errorlog=$(cat); typeset -p errorlog) > >(stdoutlog=$(cat); typeset -p stdoutlog); exitcode=$?; typeset -p exitcode )"
		fi
		# Remove chroot only if umount was a success
		if [ -d $chroot_dir ] && [ $exitcode -eq 0 ]; then
			rm -Rf $chroot_dir
		else
			echo "[deluser] ${chroot_dir} can't be deleted because it's impossible to unmount ${chroot_dir}${TARGET_USER_DIR} and you could be lost data mounted"
		fi
		_remove_user_from_index $user
		;;
	*)
		>&2 echo "Command $1 not found. Usage : chroot.sh <command> <options>"
		exit 1
esac
