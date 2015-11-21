#!/bin/bash

function _setup_user {

	chroot_dir=$1
	user=$2
	user_id=$3
	user_home_dir=$4

	mkdir -p $chroot_dir/{dev,etc,lib,lib64,usr,bin,home}
	mkdir -p $chroot_dir/$user_dir
	mkdir -p $chroot_dir/usr/bin
	chown root:root $chroot_dir
	chmod go-w $chroot_dir

	# Base command
	cd $chroot_dir/bin
	cp /bin/bash .
	cp /bin/sh .
	cp /bin/ls .
	cp /bin/cp .
	cp /bin/mv .
	cp /bin/mkdir .

	/l2chroot.sh $chroot_dir /bin/bash
	/l2chroot.sh $chroot_dir /bin/sh
	/l2chroot.sh $chroot_dir /bin/ls
	/l2chroot.sh $chroot_dir /bin/cp
	/l2chroot.sh $chroot_dir /bin/mv
	/l2chroot.sh $chroot_dir /bin/mkdir

	cd $chroot_dir/usr/bin
	cp /usr/bin/clear .
	/l2chroot.sh $chroot_dir /usr/bin/clear
	cd $chroot_dir/lib
	cp -r /lib/terminfo .
	
	USER_PASSWORD=$(pwgen -s 12 1)
	useradd -s /bin/bash -u $user_id --home-dir=$user_home_dir --no-create-home --user-group -G sshusers $user; echo $user:$USER_PASSWORD | chpasswd
	mkdir $chroot_dir/.ssh
	touch $chroot_dir/.ssh/authorized_keys
	chown $user:$user $chroot_dir$user_home_dir $chroot_dir/.ssh $chroot_dir/.ssh/authorized_keys

	echo "========================================================================"
	echo "	Password for $user : $USER_PASSWORD"
	echo "========================================================================"
}

case "$1" in
	adduser)
		# Usage : adduser --user|-u soletic -id 10001 -dir|--chroot-dir /home/soletic -home|--user-home-dir /home
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
				*)
					# unknown option
					shift
					;;
			esac
		done
		if [ -z "$user" ] || [ -z "$user_id" ]; then
			>&2 echo "[adduser] argument missing. Usage : $0 adduser --user|-u <username> -id <userid> -dir|--chroot-dir <absolute path> -home|--user-home-dir <absolute path>"
			>&2 echo "[adduser] -dir (default : ${CHROOT_DIR_BASE}/<username>${USER_CHROOT_INSTALL_DIR}) : path to chroot user directory. Exemple : /home/soletic"
			>&2 echo "[adduser] -home (default : /home) : absolute path from chroot_dir to setup the user home dir in his chroot environment. Example : /home"
			exit 1
		fi
		if [ -z "$user_home_dir" ]; then
			user_home_dir="/home"
		fi
		if [ -z "$chroot_dir" ]; then
			chroot_dir=${CHROOT_DIR_BASE}/$user${USER_CHROOT_INSTALL_DIR}
		fi
		if [ ! -d $chroot_dir ]; then
			mkdir -p $chroot_dir
			exit
		fi
		_setup_user $chroot_dir $user $user_id $user_home_dir
		;;
	*)
		>&2 echo "Command $1 not found. Usage : chroot.sh <command> <options>"
		exit 1
esac
