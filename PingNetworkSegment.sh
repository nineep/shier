#!/bin/bash
#Yes 为可以ping通
#No  为不能ping通
 
#设置网段
net=10.70.248
 
#启始IP
ip=1
 
while [ $ip -le 254 ]
do
    ping $net.$ip -c 2 | grep -q "ttl=" && echo "$net.$ip Yes" || echo "$net.$ip No"
    ip=`expr $ip + 1`
done
