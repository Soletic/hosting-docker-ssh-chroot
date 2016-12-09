#!/bin/bash

########################
# Add a bin to chroot users
########################

chroot_dir=$1
bin_file=$2

if [ -z $chroot_dir ]; then
	>&2 echo "Please precise chroot dir target. Usage : $0 <chroot_dir>"
	exit 1
fi

function _install_bin {
	bin_path=$1
	chroot_dir=$2
	if [ -f $bin_path ]; then
		echo "# $bin_path > $chroot_dir$bin_path"
		local dir_bin=$(dirname $bin_path)
		if [ -d $dir_bin ]; then
			mkdir -p $dir_bin
		fi
		cp -L $bin_path $chroot_dir$bin_path
		/l2chroot.sh $chroot_dir "$bin_path"
	fi
}

_install_bin $bin_file $chroot_dir