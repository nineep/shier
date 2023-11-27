#!/bin/bash

core_dump_file_path="/data/coredump"

# 开启process coredump
#echo  "ulimit -c unlimited" >> /etc/profile
ulimit -c 10240000
echo "*        soft    core            10240000" >>  /etc/security/limits.conf

# 配置coredump
echo "kernel.core_uses_pid=1" >> /etc/sysctl.conf
echo "kernel.core_pattern=|/usr/bin/coredump_helper.sh core_%e_%I_%p_sig_%s_time_%t.gz" >> /etc/sysctl.conf

cat > /usr/bin/coredump_helper.sh << EOF
#!/bin/sh

if [ ! -d  $core_dump_file_path ];then
    mkdir -p $core_dump_file_path
fi
gzip > "$core_dump_file_path/\$1"

EOF
chmod +x /usr/bin/coredump_helper.sh

sysctl -p -q -e