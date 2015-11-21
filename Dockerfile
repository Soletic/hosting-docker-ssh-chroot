FROM soletic:sshd
MAINTAINER Sol&TIC <serveur@soletic.org>

ENV CHROOT_DIR_BASE /home

ADD l2chroot.sh /l2chroot.sh
ADD chroot.sh /chroot.sh
ADD sshd_config_addons /etc/ssh/sshd_config_addons
RUN chmod 755 /*.sh

RUN groupadd sshusers
RUN cat /etc/ssh/sshd_config_addons >> /etc/ssh/sshd_config

CMD ["/start.sh"]