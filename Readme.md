# Docker image to setup a chroot ssh

Docker image to create a container exposing a ssh service with chroot features.

**Example of usage**

Run a container mouting a docker host directory in the /home volume and create all users required in the container to give restrictive ssh and sftp access to their */home* subdirectory

**list of commands exposed**

bash sh, ls, cp, mv, mkdir, touch, vi, cat, sed, date, bunzip2, bzip2, chmod, egrep, fgrep, grep, gunzip, gzip, ln, more, ping, rm, tar, uname', rsync, scp, clear, perl, vi, curl, wget, basename, pager, git, git-receive-pack, git-shell, git-upload-archive, git-upload-pack

## Install

```
$ git clone https://github.com/Soletic/hosting-docker-ubuntu.git ./ubuntu
$ git clone https://github.com/Soletic/hosting-docker-sshd.git ./sshd
$ git clone https://github.com/Soletic/hosting-docker-ssh-chroot.git ./ssh-chroot
$ docker build -t soletic/ubuntu ./ubuntu
$ docker build -t soletic/sshd ./sshd
$ docker build -t soletic/ssh-chroot ./ssh-chroot
```

## Run the container

Run the image as a container

```
$ docker run -d -p 2222:22 -v /path/host:/home --name sshd --privileged soletic/ssh-chroot
```

* option --privileged required to give mount permissions inside the container ([see here >](https://github.com/docker/docker/issues/5254))

### Add your first user

```
$ docker exec -it sshd /bin/bash
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
$ sudo docker run -d -p 2222:22 -v /path/host:/home -e CHROOT_USER_HOME_BASEPATH=/volumes/www --name sshd --privileged soletic/ssh-chroot:latest
```

And the command creating the user will mount /home/soletic/volumes/www in /chroot/soletic/home

### Remove the user

```
$ sudo docker exec -it sshd /bin/bash
bash@sshd $ /chroot.sh deluser -u soletic
```

## Stop and remove container without losing users created

The file .sshusers and stored inside the home indexes all users created. If you don't want to lose the list, mount the volume /home with a host directory and often backup it.

## Extend the image

If you want to add others commandes like php or mysql or ruby, you can create a new image extending this image with a plugin mechanism to setup the chroot environment.

[See this repository for an example with php and mysql >](https://github.com/Soletic/hosting-docker-ssh-wbvps)

## References

Documentation used to create this docker image :

* [http://www.58bits.com/blog/2014/01/09/ssh-and-sftp-chroot-jail](http://www.58bits.com/blog/2014/01/09/ssh-and-sftp-chroot-jail)
* [Creating a Chroot Jail for SSH Access](http://allanfeid.com/content/creating-chroot-jail-ssh-access)
* [Command to populate dev/](http://www.linuxfromscratch.org/lfs/view/6.1/chapter06/devices.html)