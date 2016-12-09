#!/bin/bash

chroot_dir=$1

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

# Bin basis
BIN_LIST=( 'bash' 'sh' 'ls' 'cp' 'mv' 'mkdir' 'touch' 'vi' 'cat' 'sed' 'date' 'bunzip2' 'bzip2' 'chmod' 'egrep' 'fgrep' 'grep' 'gunzip' 'gzip' 'ln' 'more' 'ping' 'rm' 'tar' 'uname' 'which' 'readlink' 'ps' )
USR_BIN_LIST=( 'xargs' 'find' 'tail' 'rsync' 'scp' 'tr' 'clear' 'perl' 'vi' 'curl' 'wget' 'basename' 'pager' 'git' 'git-receive-pack' 'git-shell' 'git-upload-archive' 'git-upload-pack' 'unzip' 'dirname' 'head' 'cut')
# Install required
UIDBASICS_REQUIRED=( 'proc/cpuinfo' 'lib/x86_64-linux-gnu/libnsl.so.1' 'lib/x86_64-linux-gnu/libnss*.so.2' 'etc/nsswitch.conf' 'etc/ld.so.*' 'lib/terminfo' 'etc/passwd' 'etc/group' )
NETBASICS_REQUIRED=( 'lib/x86_64-linux-gnu/libnss_dns.so.2' 'etc/resolv.conf' '/etc/protocols' '/etc/services' )
EDITORS_REQUIRED=( 'etc/vimrc' 'usr/share/vim' )
GIT_REQUIRED=( 'usr/lib/git-core*' 'usr/share/git*' 'usr/lib/x86_64-linux-gnu/libcurl*.so*' 'etc/ssl*' )
PERL_REQUIRED=( 'usr/lib/perl*' 'usr/share/perl*' )

FILES_REQUIRED=("${UIDBASICS_REQUIRED[@]}" "${NETBASICS_REQUIRED[@]}" "${EDITORS_REQUIRED[@]}" "${GIT_REQUIRED[@]}" "${PERL_REQUIRED[@]}")
INSTALL_FUNCTIONS=()

plugins=( $(find / -wholename "${CHROOT_INSTALL_DIR}/plugins/*.conf" -type f) )

# Copy hosts but don't override
if [ ! -f $chroot_dir/etc/hosts ]; then
	cp /etc/hosts $chroot_dir/etc/hosts
fi

# Complete with plugin
for plugin in "${plugins[@]}"
do
	echo "[plugin] load $plugin"
	source $plugin
	BIN_LIST=("${BIN_LIST[@]}" "${PLUGIN_BIN_LIST[@]}")
	USR_BIN_LIST=("${USR_BIN_LIST[@]}" "${PLUGIN_USR_BIN_LIST[@]}")
	FILES_REQUIRED=("${FILES_REQUIRED[@]}" "${PLUGIN_FILES_REQUIRED[@]}")
	INSTALL_FUNCTIONS=("${INSTALL_FUNCTIONS[@]}" "${PLUGIN_INSTALL_FUNCTIONS[@]}")
done

# Install bin
echo "Start install /bin program"
for bin in "${BIN_LIST[@]}"
do
	_install_bin "/bin/$bin" $chroot_dir
done

# Install usr/bin
echo "Start install /usr/bin program"
for bin in "${USR_BIN_LIST[@]}"
do
	_install_bin "/usr/bin/$bin" $chroot_dir
done

# Files required
for path in "${FILES_REQUIRED[@]}"
do
	find / -wholename "/$path" | while read file; do
		if [ -d $file ]; then
			mkdir -p $chroot_dir$file
		fi
		if [ -f $file ]; then
			cp -L $file $chroot_dir$file
		fi
	done
done

# Install script
for script in "${PLUGIN_INSTALL_FUNCTIONS[@]}"
do
	$script $chroot_dir
done
