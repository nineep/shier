#!/bin/bash

set -xe
echo "change socket max link num"
echo ""
echo "a process can open max files number."
ulimit -n   #a process can open max files number.

echo "change linux system user open files num soft and hard limit.(value:soft<=hard)"
echo '* soft nofile 10240' >> /etc/security/limits.conf
echo '* hard nofile 10240' >> /etc/security/limits.conf 

echo "change pam_limits.so modules"
echo 'session required pam_limits.so' >> /etc/pam.d/login

echo "check linux system class max link limit"
cat /proc/sys/fs/file-max

##################
echo "change port range"
echo "1024 65000" > /proc/sys/net/ipv4/ip_local_port_range
echo ""
echo "check"
cat /proc/sys/net/ipv4/ip_local_port_range
sysctl -p


