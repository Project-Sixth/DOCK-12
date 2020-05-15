FROM centos:7

ARG USER_ID=14
ARG GROUP_ID=50

ENV FTP_USER **String**
ENV FTP_PASS **Random**
ENV FTP_OWN NO

ENV PASV_ENABLE YES
ENV PASV_ADDRESS **IPv4**
ENV PASV_MIN_PORT 65100
ENV PASV_MAX_PORT 65110
ENV PASV_ADDR_RESOLVE NO

ENV XFERLOG_STD_FORMAT NO
ENV FILE_OPEN_MODE 0777
ENV LOCAL_UMASK 000

RUN yum -y update && yum clean all
RUN yum install -y \
        vsftpd \
        db4-utils \
        db4 && yum clean all

RUN usermod -u ${USER_ID} ftp
RUN groupmod -g ${GROUP_ID} ftp

COPY ./root/vsftpd.conf /etc/vsftpd/
COPY ./root/vsftpd.virtual /etc/pam.d/
COPY ./root/docker-entrypoint.sh /

RUN chmod +x /docker-entrypoint.sh
RUN chown -R ftp:ftp /mnt

VOLUME /mnt

EXPOSE 20 21

CMD ["/docker-entrypoint.sh"]

