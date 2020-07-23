#!/bin/bash

# Disable selinux
setenforce 0

# Install vsftpd
yum install -y vsftpd
systemctl start vsftpd

# Disable anonymous access
sed -i s/anonymous_enable=YES/anonymous_enable=NO/g /etc/vsftpd/vsftpd.conf

# Config vsftpd user
cat >> /etc/vsftpd/vsftpd.conf << EOF
# Enable user list /etc/vsftpd/user_list
userlist_deny=NO
# Lock the user into his or her own directory
chroot_local_user=YES
chroot_list_enable=YES
chroot_list_file=/etc/vsftpd/chroot_list
EOF
touch /etc/vsftpd/chroot_list

# Restart vsftpd
systemctl restart vsftpd
systemctl enable vsftpd

