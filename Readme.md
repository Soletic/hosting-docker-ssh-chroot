# Docker image to setup a chroot ssh

Docker image to create a container exposing a ssh service with chroot features.


**Example of usage**

Run a container mouting a docker host directory in the /home volume and create all users required in the container to give restrictive ssh and sftp access to their */home* subdirectory

**list of commands exposed**

bash sh, ls, cp, mv, mkdir, touch, vi, cat, sed, date, bunzip2, bzip2, chmod, egrep, fgrep, grep, gunzip, gzip, ln, more, ping, rm, tar, uname', rsync, scp, clear, perl, vi, curl, wget, basename, pager, git, git-receive-pack, git-shell, git-upload-archive, git-upload-pack

## Installation

### Run the container

Clone git docker images required :

```
$ sudo mkdir -p /home/docker/hosting/src
$ export DOCKER_HOSTING=/home/docker/hosting
$ sudo git clone https://github.com/Soletic/hosting-docker-sshd.git $DOCKER_HOSTING/src/sshd
$ sudo git clone https://github.com/Soletic/hosting-docker-ssh-chroot.git $DOCKER_HOSTING/src/ssh-chroot
```

Build images :

```
$ sudo docker build -t soletic/sshd:latest $DOCKER_HOSTING/src/sshd
$ sudo docker build -t soletic/chrootsshd:latest $DOCKER_HOSTING/src/ssh-chroot
``` 

Run the image as a container

```
$ sudo docker run -d -p 2222:22 -v /home/docker/hosting/src:/home --name sshd --privileged soletic/chrootsshd:latest
```

* option --privileged required to give mount permissions inside the container ([see here >](https://github.com/docker/docker/issues/5254))

### Add your first user

```
$ sudo docker exec -it sshd /bin/bash
bash@sshd $ /chroot.sh adduser -u soletic -id 10001
```

The command creates a user soletic and an isolated chroot environment :

* /chroot/soletic : his chroot environment
* /chroot/soletic/home : mounting point of /home/soletic
* /home/soletic/.ssh/authorized_keys created
* /chroot/soletic/credentials contains the password generated

#### Mount a subdirectory of the user home

If the real home directory of soletic user is for example /home/soletic/volumes/www, run the image setting up the environment variable CHROOT_USER_HOME_BASEPATH :

```
$ sudo docker run -d -p 2222:22 -v /home/docker/hosting/src:/home -e CHROOT_USER_HOME_BASEPATH=/volumes/www --name sshd --privileged soletic/chrootsshd:latest
```

And the command creating the user will mount /home/soletic/volumes/www in /chroot/soletic/home

### Remove the user

```
$ sudo docker exec -it sshd /bin/bash
bash@sshd $ /chroot.sh deluser -u soletic
```

## Extend the image

If you want to add others commandes like php or mysql or ruby, you can create a new image extending this image with a plugin mechanism to setup the chroot environment.

[See this repository for an example with php and mysql >](https://github.com/Soletic/hosting-docker-ssh-wbvps)

## References

Documentation used to create this docker image :

* [http://www.58bits.com/blog/2014/01/09/ssh-and-sftp-chroot-jail](http://www.58bits.com/blog/2014/01/09/ssh-and-sftp-chroot-jail)
* [Creating a Chroot Jail for SSH Access](http://allanfeid.com/content/creating-chroot-jail-ssh-access)
* [Command to populate dev/](http://www.linuxfromscratch.org/lfs/view/6.1/chapter06/devices.html)