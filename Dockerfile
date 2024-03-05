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
RUN echo -e "PermitRootLogin prohibit-password\nPubkeyAuthentication yes" >> /etc/ssh/sshd_config

ADD entrypoint.sh /entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]