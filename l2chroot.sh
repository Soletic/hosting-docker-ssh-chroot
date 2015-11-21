#!/bin/bash
# Use this script to copy shared (libs) files to Apache/Lighttpd chrooted 
# jail server.
# ----------------------------------------------------------------------------
# Written by nixCraft <http://www.cyberciti.biz/tips/>
# (c) 2006 nixCraft under GNU GPL v2.0+
# + Added ld-linux support
# + Added error checking support
# ------------------------------------------------------------------------------
# See url for usage:
# http://www.cyberciti.biz/tips/howto-setup-lighttpd-php-mysql-chrooted-jail.html
# -------------------------------------------------------------------------------

# Path to chroot directory where create a chroot environment
CHROOT_DIR=$1
BIN_PATH=$2

if [ ! -d $CHROOT_DIR ]; then
	>&2 echo "$CHROOT_DIR doesn't exist"
	exit 1
fi

if [ $# -eq 0 ]; then
  echo "Syntax : $0 /path/to/executable"
  echo "Example: $0 /usr/bin/php5-cgi"
  exit 1
fi

# iggy ld-linux* file as it is not shared one
FILES="$(ldd $BIN_PATH | awk '{ print $3 }' |egrep -v ^'\(')"

echo "Copying shared files/libs to $CHROOT_DIR..."
for i in $FILES
do
  d="$(dirname $i)"
  [ ! -d $CHROOT_DIR$d ] && mkdir -p $CHROOT_DIR$d || :
  /bin/cp $i $CHROOT_DIR$d
done

# copy /lib/ld-linux* or /lib64/ld-linux* to $CHROOT_DIR/$sldlsubdir
# get ld-linux full file location 
sldl="$(ldd $1 | grep 'ld-linux' | awk '{ print $1}')"
# now get sub-dir
sldlsubdir="$(dirname $sldl)"

if [ ! -f $CHROOT_DIR$sldl ];
then
  echo "Copying $sldl $CHROOT_DIR$sldlsubdir..."
  /bin/cp $sldl $CHROOT_DIR$sldlsubdir
else
  :
fi