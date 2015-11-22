FROM soletic/sshd
MAINTAINER Sol&TIC <serveur@soletic.org>

ENV CHROOT_INSTALL_DIR /chroot
# Path to directory where user directories are stored
ENV CHROOT_USERS_HOME_DIR /home
# Absolute dir path from a home user dir that will be mounted as home dir in the chroot environment
ENV CHROOT_USER_HOME_BASEPATH ""

ADD sshd_config_addons /etc/ssh/sshd_config_addons
RUN groupadd sshusers
RUN sed -ri -e 's/^Subsystem sftp.*/Subsystem sftp internal-sftp/' /etc/ssh/sshd_config
RUN cat /etc/ssh/sshd_config_addons >> /etc/ssh/sshd_config

ADD l2chroot.sh /l2chroot.sh
ADD chroot.sh /chroot.sh
ADD start.sh /start.sh
ADD install_bin.sh /install_bin.sh

RUN mkdir -p /chroot/plugins
RUN chmod 755 /*.sh

CMD ["/start.sh"]