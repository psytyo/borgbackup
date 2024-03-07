FROM alpine:latest

ENV S3_KEY=""
ENV S3_SECRET=""
ENV S3_URL=""
ENV BUCKET_NAME=""
ENV SSH_KEY=""

RUN apk add --no-cache s3fs-fuse borgbackup openssh
RUN mkdir /mnt/s3
RUN touch /root/s3
RUN chmod 600 /root/s3
RUN mkdir /root/.ssh
RUN chmod 700 /root/.ssh
RUN echo -e "HostKey /etc/ssh/ssh_host_rsa_key\nHostKey /etc/ssh/ssh_host_ed25519_key\nPermitRootLogin prohibit-password\nPubkeyAuthentication yes\nPasswordAuthentication no" >> /etc/ssh/sshd_config.d/borg.conf

ADD entrypoint.sh /entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]