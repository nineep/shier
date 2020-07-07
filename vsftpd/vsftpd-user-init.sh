#!/bin/bash

# Create vsftpd group and user
GROUP=ftpgroup
USER=ftp
PASSWD=ftpassw0rd233

groupadd $GROUP
useradd $USER -g $GROUP; echo $PASSWD | passwd --stdin $USER

echo $USER >> /etc/vsftpd/chroot_list
echo $USER >> /etc/vsftpd/user_list

