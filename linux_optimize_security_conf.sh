#!/bin/bash

#selinux config
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config   #永久关闭selinux
grep SELINUX=disabled /etc.selinux/config  #查看修改是否成功

setenforce 1   #临时关闭linux
getenforce  #查看selinux当前状态

#runlevel config
runlevel


