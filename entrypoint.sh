#!/bin/bash

export BORG_REPO=/mnt/s3/borg
export S3_API_FILE=/root/s3

# Clean up old ssh host keys and create new ones
# rm -f /etc/ssh/ssh_host*
# ssh-keygen -t ed25519 -N "" -f /etc/ssh/ssh_host_ed25519_key
# ssh-keygen -t rsa -N "" -f /etc/ssh/ssh_host_rsa_key
for keytype in ed25519 rsa ; do
	if [ ! -f "/etc/ssh/ssh_host_${keytype}_key" ] ; then
		echo "  ** Creating SSH Hostkey [${keytype}]..."
		ssh-keygen -q -f "/etc/ssh/ssh_host_${keytype}_key" -N '' -t ${keytype}
	fi
done

echo $S3_KEY:$S3_SECRET > $S3_API_FILE
s3fs $BUCKET_NAME /mnt/s3 -o passwd_file=$S3_API_FILE -o url=$S3_URL
[ -d "$BORG_REPO" ] || mkdir -p $BORG_REPO
borg init --encryption=repokey $BORG_REPO
echo 'command="borg serve --restrict-to-path '$BORG_REPO'",restrict '$SSH_KEY'' >> /root/.ssh/authorized_keys

/usr/sbin/sshd -D -e
