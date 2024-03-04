FROM alpine:latest

ENV WASABI_KEY=""
ENV WASABI_SECRET=""
ENV WASABI_URL=""
ENV BUCKET_NAME=""
ENV SSH_KEY=""

RUN apk add --no-cache s3fs-fuse borgbackup openssh
RUN mkdir /mnt/wasabi
RUN touch /root/wasabi
RUN chmod 600 /root/wasabi
RUN mkdir /root/.ssh
RUN chmod 700 /root/.ssh
RUN echo -e "PermitRootLogin prohibit-password\nPubkeyAuthentication yes" >> /etc/ssh/sshd_config

ADD entrypoint.sh /entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]