#!/bin/bash

###### Deploy frontend service ######

# Install web server - apache http server
yum install httpd php php-soap php-xml -y

# Install phpvitualbox - web-based vbox management tool
yum install wget unzip -y
wget https://github.com/phpvirtualbox/phpvirtualbox/archive/master.zip
unzip master.zip
mv phpvirtualbox-master /usr/share/phpvirtualbox

# Config apache http server
cp /usr/share/phpvirtualbox/phpvirtualbox.conf /etc/httpd/conf.d

# Start apche http server
systemctl start httpd
systemctl enable httpd

###### Deploy backend service ######

# Config vboxweb-service
