# Docker image to setup a chroot ssh

This docker image is a based image to create vps image as many times as necessary. Soletic uses it to deploy multiples VPS on its physical servers.

## Installation

```
$ sudo mkdir -p /home/docker/hosting/src
$ export DOCKER_HOSTING=/home/docker/hosting
$ sudo git clone https://github.com/Soletic/hosting-docker-sshd.git $DOCKER_HOSTING/src/sshd
$ sudo docker build -t soletic/sshd:latest $DOCKER_HOSTING/src/sshd
$ sudo git clone https://github.com/Soletic/hosting-docker-sshd.git $DOCKER_HOSTING/src/sshd
``` 

### Basic example

```
$ docker run -d --name=example_org -e HOST_NAME=example -e HOST_DOMAIN_NAME=example.org -p 80:80 solidees/webvps
```

* HOST_NAME : a name without spaces and used to setup account for mysql
* HOST_DOMAIN_NAME : default domain name used to setup apache

## Running options

The image define many environment variables to configure the image running :

* MYSQL_MAX_QUERIES_PER_HOUR (default 10000000)
* MYSQL_MAX_UPDATES_PER_HOUR (default 1000000)
* MYSQL_MAX_CONNECTIONS_PER_HOUR (default 5000)
* MYSQL_MAX_USER_CONNECTIONS (default 50)
* PHP_TIME_ZONE (default  "Europe/Paris"
* PHP_UPLOAD_MAX_FILESIZE (default 10M)
* PHP_POST_MAX_SIZE (default 10M)
* PHP_MEMORY_LIMIT (default  256M)
* WORKER_UID : system user id used to set the user id of www-data, the owner of /var/www.