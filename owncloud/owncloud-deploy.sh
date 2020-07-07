#!/bin/bash
#set -xe
# CentOS 7.4

# Install owncloud
rpm --import https://download.owncloud.org/download/repositories/10.0/CentOS_7/repodata/repomd.xml.key
wget http://download.owncloud.org/download/repositories/10.0/CentOS_7/ce:10.0.repo -O /etc/yum.repos.d/ce:10.0.repo
yum clean all
yum -y install owncloud-files
ls /var/www/html

# Install apache httpd
yum install httpd -y
systemctl start httpd.service

# Install php
#rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm   
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm    
yum -y install php72w
yum -y install php72w-cli php72w-common php72w-devel php72w-mysql php72w-xml php72w-odbc php72w-gd php72w-mbstring php72w-intl

# Fix error: Can't write into config directory! 
chown apache:apache -Rf /var/www/html/owncloud/
chmod 770 -Rf /var/www/html/owncloud/
setsebool -P httpd_unified 1
setsebool -P httpd_execmem 1

# Config owncloud
cat > /etc/httpd/conf/httpd.conf << EOF
# owncloud config
PHPIniDir /etc/php.ini

Alias /owncloud "/var/www/html/owncloud/"

<Directory /var/www/html/owncloud/>
  Options +FollowSymlinks
  AllowOverride All

 <IfModule mod_dav.c>
  Dav off
 </IfModule>

 SetEnv HOME /var/www/html/owncloud
 SetEnv HTTP_HOME /var/www/html/owncloud

</Directory>
EOF

# Start owncloud
systemctl restart httpd
systemctl enable httpd

