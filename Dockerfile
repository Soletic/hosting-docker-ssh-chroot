FROM soletic/sshd
MAINTAINER Sol&TIC <serveur@soletic.org>

# Path to directory where user directories are
ENV CHROOT_DIR_USERS /home
# Relative path in a user directory where chroot will be deployed
ENV USER_CHROOT_INSTALL_DIR ""

ADD sshd_config_addons /etc/ssh/sshd_config_addons
RUN groupadd sshusers
RUN cat /etc/ssh/sshd_config_addons >> /etc/ssh/sshd_config

ADD l2chroot.sh /l2chroot.sh
ADD chroot.sh /chroot.sh
ADD start.sh /start.sh

RUN chmod 755 /*.sh

CMD ["/start.sh"]