# Docker image to setup a chroot ssh

Docker image to create a container exposing a ssh service with chroot features.

You can use this image to mount a host directory in the /home volume and after create users in the container to give restrictive ssh and sftp access to a */home* subdirectory.

Only basis commands have been installed in the chroot mode : bash, cp, ls, mv, mkdir

## Installation

```
$ sudo mkdir -p /home/docker/hosting/src
$ export DOCKER_HOSTING=/home/docker/hosting
$ sudo git clone https://github.com/Soletic/hosting-docker-sshd.git $DOCKER_HOSTING/src/sshd
$ sudo docker build -t soletic/sshd:latest $DOCKER_HOSTING/src/sshd
$ sudo git clone https://github.com/Soletic/hosting-docker-ssh-chroot.git $DOCKER_HOSTING/src/ssh-chroot
$ sudo docker build -t soletic/chrootssh:latest $DOCKER_HOSTING/src/ssh-chroot
``` 

Run the image as a container

```
$ sudo docker run -d -p 2222:22 -v /home/docker/hosting/src:/home --name sshd soletic/chrootssh
```

Example to add a user soletic with ssh access chrooted

```
$ sudo docker exec -it sshd /bin/bash
bash@sshd $ /chroot.sh adduser -u soletic -id 10001
```

The command creates a user soletic and an isolated chroot environment in /home/soletic with home in /home/soletic/home. You can add ssh key in /home/soletic/.ssh/authorized_keys

Example to create a user soletic and an isolated chroot environment in /home/soletic/volumes with home in /home/solidees/volumes/www :

```
$ sudo docker run -d -p 2222:22 -v /home/docker/hosting/src:/home -e USER_CHROOT_INSTALL_DIR=/volumes --name sshd soletic/chrootssh
$ sudo docker exec -it sshd /bin/bash
bash@sshd $ /chroot.sh adduser -u soletic -id 10001 -home www
```

Other solution :

```
$ sudo docker run -d -p 2222:22 -v /home/docker/hosting/src:/home --name sshd soletic/chrootssh
$ sudo docker exec -it sshd /bin/bash
bash@sshd $ /chroot.sh adduser -u soletic -id 10001 -home www -dir ${CHROOT_DIR_BASE}/soletic/volumes
```

## Extend to add command

Writing in progress

## References

Documentation used to create this docker image :

* [http://www.58bits.com/blog/2014/01/09/ssh-and-sftp-chroot-jail](http://www.58bits.com/blog/2014/01/09/ssh-and-sftp-chroot-jail)