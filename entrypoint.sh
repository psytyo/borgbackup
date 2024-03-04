#!/bin/bash

export BORG_REPO=/mnt/wasabi/borg
export WASABI_API_FILE=/root/wasabi

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

echo $WASABI_KEY:$WASABI_SECRET > $WASABI_API_FILE
s3fs $BUCKET_NAME /mnt/wasabi -o passwd_file=$WASABI_API_FILE -o url=$WASABI_URL
[ -d "$BORG_REPO" ] || mkdir -p $BORG_REPO
borg init --encryption=repokey $BORG_REPO
echo 'command="borg serve --restrict-to-path '$BORG_REPO'",restrict '$SSH_KEY'' >> /root/.ssh/authorized_keys

/usr/sbin/sshd -D -e
