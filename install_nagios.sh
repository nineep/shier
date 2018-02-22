#!/bin/bash
# 自动安装UCMON_NAGIOS
# 标准化安装.修改.配置
# 1.检查系统版本和平台,监控机都采用统一系统版本和平台[rhel5.4 x64]
# 2.安装Nagios版本为3.5.0版本[已支持UTF8中文编码]
# 3.安装jre,perl,python,php,apache


#提示,建议使用yum安装以下Group
echo '-----------------------提示:请确认是否已经安装以下Packages-----------------------
yum groupinstall "Administration Tools" "Authoring and Publishing" "SNMP Support"  "Development Tools"  "Dialup Networking Support"  "Editors"  "Legacy Network Server"  "Legacy Software Development"  "Legacy Software Support"  "Mail Server"  "MySQL Database"  "Network Servers"  "Server Configuration Tools"  "System Tools"  "Text-based Internet"  "X Software Development"   "SNMP Support"
---------------------------------------------------------------------------------
';
while true; do
    read -p "请确认是否已经使用root运行上面yum命令,请输入yes/no?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "请输入Yes或No.";;
    esac
done

# 判断lsb_release是否存在
if [ ! -x "/usr/bin/lsb_release" ];then
    echo "不存在lsb_release命令,请使用[yum install redhat-lsb]安装";
    exit 2;
else
    sys_ver=`/usr/bin/lsb_release -r|awk '{print $NF}'`;
fi

sys_plat=`/bin/uname -i`;
ver="6.3";
plat="x86_64";

# 判断系统版本和平台[必须为5.4和x86_64]
if [ $sys_ver != $ver ];then
    echo "系统版本:$sys_ver/$ver,版本不符合,拒绝下一步安装!";
    exit 2;
elif [ $sys_plat != $plat ];then
    echo "系统平台:$sys_plat/$plat,平台不符合,拒绝下一步安装!";
    exit 2;
fi

CUR_USER=`whoami`;
# 检测用户是否为root
if [ `id -u` == '0' ];then
    echo "当前用户为root,请切换至nagios用户";
    exit 2;
fi

if [ $CUR_USER != 'nagios' ];then
    echo "当前用户非$INS_USER,请切换至$INS_USER";
    exit 2;
fi

# define var
NAGIOS_TAR_URL="http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-3.5.0.tar.gz";
NAGIOS_FILE="nagios-3.5.0.tar.gz";
INS_USER="nagios";
PKGS="$HOME/pkgs";
LOCAL="$HOME/local";
# 检查PKGS目录是否存在
if [ ! -d $PKGS ];then
    echo "安装包下载路径不存在,开始创建";
    mkdir $PKGS;
    if [ $? -eq 0 ];then
        echo "创建$PKGS成功";
    fi
        
fi
# 检查local目录是否存在
if [ ! -d $LOCAL ];then
    echo "安装路径不存在,开始创建";
    mkdir $LOCAL;
    if [ $? -eq 0 ];then
        echo "创建$LOCAL成功";
    fi
        
fi

# 检查是否在本地安装了APACHE
HTTPD_BIN="$HOME/local/httpd/bin/httpd";
HTTPD_TAR_URL="http://mirror.bjtu.edu.cn/apache//httpd/httpd-2.2.24.tar.gz"
HTTPD_FILE="httpd-2.2.24.tar.gz"
cd $PKGS;
if [ -f $HTTPD_BIN ];then
    echo "HTTPD已经安装:$HTTPD_BIN";
else
    echo "HTTPD未安装:$HTTPD_BIN,现在开始下载安装[Timeout:300 Seconds]";
    wget -T 300 -4 $HTTPD_TAR_URL -O "$PKGS/$HTTPD_FILE";
    if [ $? -eq 0 ];then
        echo "下载HTTPD安装包成功";
    else
        echo "下载HTTPD安装包失败";
    fi
    # 开始安装HTTPD
    if [ -d "$HOME/local/httpd" ];then
        rm -rf "$HOME/local/httpd";
    fi
    rm -rf httpd-2.2.24 \
    && tar xzvf "$PKGS/$HTTPD_FILE" -C ./ \
    && cd httpd-2.2.24 \
    && ./configure --prefix=$HOME/local/httpd \
       --enable-modules=most \
       --enable-mods-shared=most \
       --enable-so \
       --with-mpm=worker \
       --enable-cache \
       --enable-disk-cache \
       --enable-mem-cache \
       --enable-file-cache \
       --enable-nonportable-atomics \
       --enable-rewrite=shared \
    && make -j 10 \
    && make install;
    if [ $? -ne 0 ];then
        echo "安装HTTPD失败:$?";
        exit 2;
    else
        echo "安装HTTPD成功";
    fi
    # 定制HTTPD的配置文件
    sed -i 's/^Listen 80/Listen 8080/g' $HOME/local/httpd/conf/httpd.conf
    sed -i 's/^#ServerName.*/ServerName www.example.com:80/g' $HOME/local/httpd/conf/httpd.conf
fi

# 检查是否在本地安装了LIBMCRYPT
LIBMCRYPT_BIN="$HOME/local/libmcrypt/bin/libmcrypt-config";
LIBMCRYPT_TAR_URL="http://vps.googlecode.com/files/libmcrypt-2.5.8.tar.gz"
LIBMCRYPT_FILE="libmcrypt-2.5.8.tar.gz"
cd $PKGS;
if [ -f $LIBMCRYPT_BIN ];then
    echo "LIBMCRYPT已经安装:$LIBMCRYPT_BIN";
else
    echo "LIBMCRYPT未安装:$LIBMCRYPT_BIN,现在开始下载安装[Timeout:300 Seconds]";
    wget -T 300 -4 $LIBMCRYPT_TAR_URL -O "$PKGS/$LIBMCRYPT_FILE";
    if [ $? -eq 0 ];then
        echo "下载LIBMCRYPT安装包成功";
    else
        echo "下载LIBMCRYPT安装包失败";
    fi
    # 开始安装LIBMCRYPT
    if [ -d "$HOME/local/libmcrypt" ];then
        rm -rf "$HOME/local/libmcrypt";
    fi
    rm -rf libmcrypt-2.5.8 \
    && tar xzvf "$PKGS/$LIBMCRYPT_FILE" -C ./ \
    && cd libmcrypt-2.5.8 \
    && ./configure --prefix=$HOME/local/libmcrypt \
    && make -j 10 \
    && make install;
    if [ $? -ne 0 ];then
        echo "安装LIBMCRYPT失败:$?";
        exit 2;
    else
        echo "安装LIBMCRYPT成功";
    fi
    # 定制LIBMCRYPT的环境变量
    export LD_LIBRARY_PATH=$HOME/local/libmcrypt/lib
    sed -i '/^LD_LIBRARY_PATH=.*/d' $HOME/.bash_profile
    sed -i 's/^export PATH/export PATH\nLD_LIBRARY_PATH=$HOME\/local\/libmcrypt/lib/g' $HOME/.bash_profile
fi

# 检查是否在本地安装了PHP
PHP_BIN="$HOME/local/php/bin/php";
PHP_TAR_URL="http://us2.php.net/get/php-5.4.13.tar.gz/from/cn2.php.net/mirror"
PHP_FILE="php-5.4.13.tar.gz"
cd $PKGS;
if [ -f $PHP_BIN ];then
    echo "PHP已经安装:$PHP_BIN";
else
    echo "PHP未安装:$PHP_BIN,现在开始下载安装[Timeout:300 Seconds]";
    wget -T 300 -4 $PHP_TAR_URL -O "$PKGS/$PHP_FILE";
    if [ $? -eq 0 ];then
        echo "下载PHP安装包成功";
    else
        echo "下载PHP安装包失败";
    fi
    # 开始安装PHP
    if [ -d "$HOME/local/php" ];then
        rm -rf "$HOME/local/php";
    fi
    rm -rf php-5.4.13 \
    && tar xzvf "$PKGS/$PHP_FILE" -C ./ \
    && cd php-5.4.13 \
    && ./configure --prefix=$HOME/local/php \
       --with-apxs2=$HOME/local/httpd/bin/apxs \
       --with-mysql \
       --with-gd \
       --with-freetype-dir \
       --with-png-dir \
       --with-jpeg-dir \
       --with-zlib \
       --enable-gd-jis-conv \
       --enable-xml \
       --enable-sockets \
       --with-mcrypt=$HOME/local/libmcrypt \
       --with-mhash \
       --enable-mbstring \
    && make -j 10 \
    && make install;
    if [ $? -ne 0 ];then
        echo "安装PHP失败:$?";
        exit 2;
    else
        echo "安装PHP成功";
    fi
    # 定制PHP的配置文件
    cp $PKGS/php-5.4.13/php.ini-production $HOME/local/php/lib/php.ini
    sed -i 's/AddType application\/x-gzip .gz .tgz/AddType application\/x-gzip .gz .tgz\n    AddType application\/x-httpd-php .php\n    AddType image\/x-icon .ico\n/g' $HOME/local/httpd/conf/httpd.conf
    sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php index.html/g' $HOME/local/httpd/conf/httpd.conf
    sed -i 's/#Include conf/extra/httpd-mpm.conf/Include conf/extra/httpd-mpm.conf/g' $HOME/local/httpd/conf/httpd.conf
    # 修改HTTP的子配置文件
    sed -i '/StartServers.*/d' $HOME/local/httpd/conf/extra/httpd-mpm.conf
    sed -i '/MaxClients.*/d' $HOME/local/httpd/conf/extra/httpd-mpm.conf
    sed -i '/MinSpareThreads.*/d' $HOME/local/httpd/conf/extra/httpd-mpm.conf
    sed -i '/MaxSpareThreads.*/d' $HOME/local/httpd/conf/extra/httpd-mpm.conf
    sed -i '/ThreadsPerChild.*/d' $HOME/local/httpd/conf/extra/httpd-mpm.conf
    sed -i '/MaxRequestsPerChild.*/d' $HOME/local/httpd/conf/extra/httpd-mpm.conf
    # 修改HTTP的子配置文件
    sed -i 's/<IfModule mpm_worker_module>/<IfModule mpm_worker_module>\n    ThreadLimit         200\n    ServerLimit          35\n    StartServers         15\n    MaxClients         3000\n    MinSpareThreads      50\n    MaxSpareThreads     150\n    ThreadsPerChild     150\n    MaxRequestsPerChild   10000/g' $HOME/local/httpd/conf/extra/httpd-mpm.conf
    
fi

# 检查是否在本地安装了JRE
JRE_BIN="$HOME/local/jre/bin/java";
JRE_TAR_URL="http://javadl.sun.com/webapps/download/AutoDL?BundleId=76853"
JRE_FILE="jre-7u21-linux-x64.tar.gz"
cd $PKGS;
if [ -f $JRE_BIN ];then
    echo "JRE已经安装:$JRE_BIN";
else
    echo "JRE未安装:$JRE_BIN,现在开始下载安装[Timeout:300 Seconds]";
    wget -T 300 -4 $JRE_TAR_URL -O "$PKGS/$JRE_FILE";
    if [ $? -eq 0 ];then
        echo "下载JRE安装包成功";
    else
        echo "下载JRE安装包失败";
    fi
    # 开始安装JRE
    if [ -d "$HOME/local/jre" ];then
        rm -rf "$HOME/local/jre";
    fi
    tar xzvf "$PKGS/$JRE_FILE" -C $HOME/local/
    ln -s $HOME/local/jre1.7.0_21 $HOME/local/jre
    if [ $? -ne 0 ];then
        echo "安装JRE失败:$?";
        exit 2;
    else
        echo "安装JRE成功";
    fi
fi

# 检查是否在本地安装了Perl
PERL_BIN="$HOME/local/perl/bin/perl";
PERL_TAR_URL="http://mirrors.163.com/cpan/src/5.0/perl-5.16.3.tar.gz"
PERL_FILE="perl-5.16.3.tar.gz"
cd $PKGS;
if [ -f $PERL_BIN ];then
    echo "PERL已经安装:$PERL_BIN";
else
    echo "PERL未安装:$PERL_BIN,现在开始下载安装[Timeout:300]";
    wget -T 300 -4 $PERL_TAR_URL -O "$PKGS/$PERL_FILE";
    if [ $? -eq 0 ];then
        echo "下载PERL安装包成功";
    else
        echo "下载PERL安装包失败";
    fi
    # 开始安装PERL
    if [ -d "$PKGS/perl-5.16.3" ];then
        rm -rf "$PKGS/perl-5.16.3";
    fi
    tar xzvf "$PKGS/$PERL_FILE" -C ./
    cd "$PKGS/perl-5.16.3";
    ./Configure -des -Dprefix=$HOME/local/perl -Dusethreads \
    && make -j 10\
    && make install
    if [ $? -ne 0 ];then
        echo "安装PERL失败:$?";
        exit 2;
    else
        echo "安装PERL成功";
    fi
fi

# 检查是否在本地安装了Python
PYTHON_BIN="$HOME/local/python/bin/python";
PYTHON_TAR_URL="http://www.python.org/ftp/python/2.7.3/Python-2.7.3.tgz"
PYTHON_FILE="Python-2.7.3.tgz"
cd $PKGS;
if [ -f $PYTHON_BIN ];then
    echo "Python已经安装:$PYTHON_BIN";
else
    echo "Python未安装:$PYTHON_BIN,现在开始下载安装[Timeout:300 Seconds]";
    wget -T 300 -4 $PYTHON_TAR_URL -O "$PKGS/$PYTHON_FILE";
    if [ $? -eq 0 ];then
        echo "下载Python安装包成功";
    else
        echo "下载Python安装包失败";
    fi
    # 开始安装Python
    if [ -d "$PKGS/Python-2.7.3" ];then
        rm -rf "$PKGS/Python-2.7.3";
    fi
    tar xzvf "$PKGS/$PYTHON_FILE" -C ./
    cd "$PKGS/Python-2.7.3";
    ./configure --disable-ipv6 --with-threads --prefix=$HOME/local/python \
    && make -j 10\
    && make install
    if [ $? -ne 0 ];then
        echo "安装Python失败:$?";
        exit 2;
    else
        echo "安装Python成功";
    fi
fi

# 检查所安装的程序,配置./bash_profile
if [ -d $HOME/local/jre -o -d $HOME/local/perl -o -d $HOME/local/python -o -d $HOME/local/php ];then
    export PATH=$HOME/local/jre/bin:$HOME/local/perl/bin:$HOME/local/python/bin:$HOME/local/php:$PATH
    sed -i 's/^PATH=.*/PATH=$HOME\/local\/jre\/bin:$HOME\/local\/python\/bin:$HOME\/local\/perl\/bin:$HOME\/local\/php\/bin:\$PATH\:\$HOME\/bin/g' $HOME/.bash_profile 
elif [ -d $HOME/local/jre -o -d $HOME/local/perl ];then
    export PATH=$HOME/local/jre/bin:$HOME/local/perl/bin:$PATH
    sed -i 's/^PATH=.*/PATH=$HOME\/local\/jre\/bin:$HOME\/local\/perl\/bin:\$PATH\:\$HOME\/bin/g' $HOME/.bash_profile 
elif [ -d $HOME/local/jre -o -d $HOME/local/python ];then
    export PATH=$HOME/local/jre/bin:$HOME/local/python/bin:$PATH
    sed -i 's/^PATH=.*/PATH=$HOME\/local\/jre\/bin:$HOME\/local\/python\/bin:\$PATH\:\$HOME\/bin/g' $HOME/.bash_profile 
elif [ -d $HOME/local/jre -o -d $HOME/local/php ];then
    export PATH=$HOME/local/jre/bin:$HOME/local/php/bin:$PATH
    sed -i 's/^PATH=.*/PATH=$HOME\/local\/jre\/bin:$HOME\/local\/php\/bin:\$PATH\:\$HOME\/bin/g' $HOME/.bash_profile 
elif [ -d $HOME/local/perl -o -d $HOME/local/python ];then
    export PATH=$HOME/local/perl/bin:$HOME/local/python/bin:$PATH
    sed -i 's/^PATH=.*/PATH=$HOME\/local\/perl\/bin:$HOME\/local\/python\/bin:\$PATH\:\$HOME\/bin/g' $HOME/.bash_profile 
elif [ -d $HOME/local/perl -o -d $HOME/local/php ];then
    export PATH=$HOME/local/perl/bin:$HOME/local/php/bin:$PATH
    sed -i 's/^PATH=.*/PATH=$HOME\/local\/perl\/bin:$HOME\/local\/php\/bin:\$PATH\:\$HOME\/bin/g' $HOME/.bash_profile 
elif [ -d $HOME/local/python -o -d $HOME/local/php ];then
    export PATH=$HOME/local/python/bin:$HOME/local/php/bin:$PATH
    sed -i 's/^PATH=.*/PATH=$HOME\/local\/python\/bin:$HOME\/local\/php\/bin:\$PATH\:\$HOME\/bin/g' $HOME/.bash_profile 
elif [ -d $HOME/local/jre ];then
    export PATH=$HOME/local/jre/bin:$PATH
    sed -i 's/^PATH=.*/PATH=$HOME\/local\/jre\/bin:\$PATH\:\$HOME\/bin/g' $HOME/.bash_profile 
elif [ -d $HOME/local/perl ];then
    export PATH=$HOME/local/perl/bin:$PATH
    sed -i 's/^PATH=.*/PATH=$HOME\/local\/perl\/bin:\$PATH\:\$HOME\/bin/g' $HOME/.bash_profile 
elif [ -d $HOME/local/python ];then
    export PATH=$HOME/local/python/bin:$PATH
    sed -i 's/^PATH=.*/PATH=$HOME\/local\/python\/bin:\$PATH\:\$HOME\/bin/g' $HOME/.bash_profile 
elif [ -d $HOME/local/php ];then
    export PATH=$HOME/local/php/bin:$PATH
    sed -i 's/^PATH=.*/PATH=$HOME\/local\/php\/bin:\$PATH\:\$HOME\/bin/g' $HOME/.bash_profile 
fi

# 检查nagios是否已经安装
if [ -f "$HOME/nagios/bin/nagios" ];then
    echo "Nagios已经存在,退出安装程序";
    exit 0;
fi


# 检测安装包是否存在,并下载
if [ ! -f "$PKGS/$NAGIOS_FILE" ];then
    echo "Nagios安装包不存在,开始下载[Timeout:300 Seconds]";
    wget -T 300 -4 $NAGIOS_TAR_URL -O "$PKGS/$NAGIOS_FILE" > /dev/null 2>&1;
    if [ $? -eq 0 ];then
        echo "下载Nagios安装包成功";
    else
        echo "下载Nagios安装包失败";
    fi
fi

# 开始安装
if [ -d "$PKGS/nagios" ];then
    rm -rf "$PKGS/nagios";
fi
tar xzvf "$PKGS/$NAGIOS_FILE" -C $PKGS;
cd "$PKGS/nagios";
./configure --prefix=$HOME/$INS_USER --with-nagios-user=$INS_USER --with-nagios-group=$INS_USER --with-perlcache --enable-embedded-perl \
&& make all \
&& make install \
&& make install-exfoliation \
&& make install-config

if [ $? -ne 0 ];then
    echo "安装Nagios失败:$?";
    exit 2;
else
    echo "安装Nagios成功";
fi

# 创建启动脚本
cp $PKGS/nagios/daemon-init $HOME/$INS_USER/bin/
sed -i 's/su - $NagiosUser -c.*/touch $NagiosVarDir\/nagios.log $NagiosRetentionFile/g' $HOME/nagios/bin/daemon-init
sed -i 's/NagiosLockDir=.*/NagiosLockDir=${prefix}\/var\/subsys/g' $HOME/nagios/bin/daemon-init
chmod 755 $HOME/$INS_USER/bin/daemon-init

# 清理默认的配置文件
rm -rf $HOME/nagios/etc/objects/*.cfg*

# 创建必须的目录
if [ ! -d "$HOME/nagios/var/nagios_sniffer/data/cfg/" ];then
    mkdir -p $HOME/nagios/var/nagios_sniffer/data/cfg/
fi
if [ ! -d "$HOME/nagios/var/rw" ];then
    mkdir $HOME/nagios/var/rw
fi

# 修改Nagios配置
sed -i '/cfg_file=\/home\/nagios\/nagios\/etc\/objects\/commands.cfg/d' $HOME/nagios/etc/nagios.cfg
sed -i '/cfg_file=\/home\/nagios\/nagios\/etc\/objects\/timeperiods.cfg/d' $HOME/nagios/etc/nagios.cfg
sed -i '/cfg_file=\/home\/nagios\/nagios\/etc\/objects\/templates.cfg/d' $HOME/nagios/etc/nagios.cfg
sed -i '/cfg_file=\/home\/nagios\/nagios\/etc\/objects\/contacts.cfg/d' $HOME/nagios/etc/nagios.cfg
sed -i 's/^cfg_file=\/home\/nagios\/nagios\/etc\/objects\/localhost.cfg/cfg_file=\/home\/nagios\/nagios\/etc\/objects\/uc_nagios_config.cfg/g' $HOME/nagios/etc/nagios.cfg

sed -i 's/^process_performance_data=0/process_performance_data=1/g' $HOME/nagios/etc/nagios.cfg
sed -i 's/^#host_perfdata_command=process-host-perfdata/host_perfdata_command=process-host-perfdata/g' $HOME/nagios/etc/nagios.cfg
sed -i 's/^#service_perfdata_command=process-service-perfdata/service_perfdata_command=process-service-perfdata/g' $HOME/nagios/etc/nagios.cfg
sed -i 's/^#host_perfdata_file=.*/host_perfdata_file=\/home\/nagios\/nagios\/var\/host-perfdata/g' $HOME/nagios/etc/nagios.cfg
sed -i 's/^#service_perfdata_file=.*/service_perfdata_file=\/home\/nagios\/nagios\/var\/service-perfdata/g' $HOME/nagios/etc/nagios.cfg
sed -i 's/^#service_perfdata_file_template=.*/service_perfdata_file_template=DATATYPE::SERVICEPERFDATA\tTIME::$SHORTDATETIME$\tHOSTNAME::$HOSTNAME$\tSERVICEDESC::$SERVICEDESC$\tSERVICEPERFDATA::$SERVICEPERFDATA$\tSERVICECHECKCOMMAND::$SERVICECHECKCOMMAND$\tHOSTSTATE::$HOSTSTATE$\tHOSTSTATETYPE::$HOSTSTATETYPE$\tSERVICESTATE::$SERVICESTATE$\tSERVICESTATETYPE::$SERVICESTATETYPE$\tASSET_SERIAL::$_HOSTHOST_ID$\tSERVICE_ID::$_SERVICESERVICE_ID$\tBUSINESS::$_SERVICEBUSINESS_ID$\tDOWNTIME::$SERVICEDOWNTIME$\tDATE::$DATE$\tENABLE_AVAILABLE_CALC::$_SERVICEENABLE_AVAILABLE_CALC/g' $HOME/nagios/etc/nagios.cfg

sed -i 's/^#host_perfdata_file_mode=a/host_perfdata_file_mode=a/g' $HOME/nagios/etc/nagios.cfg
sed -i 's/^#service_perfdata_file_mode=a/service_perfdata_file_mode=a/g' $HOME/nagios/etc/nagios.cfg
sed -i 's/^#host_perfdata_file_processing_interval=.*/host_perfdata_file_processing_interval=30/g' $HOME/nagios/etc/nagios.cfg
sed -i 's/^#service_perfdata_file_processing_interval=.*/service_perfdata_file_processing_interval=30/g' $HOME/nagios/etc/nagios.cfg
sed -i 's/^#host_perfdata_file_processing_command=.*/host_perfdata_file_processing_command=process-host-perfdata-file/g' $HOME/nagios/etc/nagios.cfg
sed -i 's/^#service_perfdata_file_processing_command=.*/service_perfdata_file_processing_command=process-service-perfdata-file/g' $HOME/nagios/etc/nagios.cfg
sed -i 's/^enable_flap_detection=1/enable_flap_detection=0/g' $HOME/nagios/etc/nagios.cfg
sed -i 's/^date_format=.*/date_format=iso8601/g' $HOME/nagios/etc/nagios.cfg
sed -i 's/^max_debug_file_size=.*/max_debug_file_size=100000000/g' $HOME/nagios/etc/nagios.cfg

# 生成Nagios检测和重启脚本
cat << END >> $HOME/nagios/etc/objects/check_nagios_cfg.sh
#!/bin/sh

~/nagios/bin/nagios -v ~/nagios/etc/nagios.cfg
END

cat << END >> $HOME/nagios/etc/objects/reload_naigos_cfg.sh
#!/bin/sh

if [ -f $HOME/nagios/init/daemon-init ];then
$HOME/nagios/init/daemon-init reload
elif [ -f $HOME/nagios/bin/daemon-init ];then
$HOME/nagios/bin/daemon-init reload
elif [ -f $HOME/nagios/sbin/daemon-init ];then
$HOME/nagios/sbin/daemon-init reload
else
echo "Not find daemon-init,now exit"
fi

END
chmod 755 $HOME/nagios/etc/objects/*.sh;

# 修改Nagios的libexe路径[适应UCMON]
sed -i 's/$USER1$=\/home\/nagios\/nagios\/libexec/$USER1$=\/home\/nagios\/ucmon_nrpe\/libexec/g' $HOME/nagios/etc/resource.cfg

# 修改Nagios的TITLE为集群标识,添加中文标识
sed -i 's/<title>.*<\/title>/<title>[请改名]集群--UCMON<\/title>\n<meta http-equiv="Content-Type" content="text\/html; charset=utf-8">/g' $HOME/nagios/share/index.php

# 添加Nagios配置
cat $PKGS/nagios/sample-config/httpd.conf >> $HOME/local/httpd/conf/httpd.conf

# 生成认证密码文件
cat << END >> $HOME/nagios/etc/htpasswd.users
nagiosadmin:yDop9lDQWcovQ
monitor:\$apr1\$0Fcqj/LX\$7oTHDlQErvqYBhjlmH33D0
ucweb:yDop9lDQWcovQ
END

chmod 400 $HOME/nagios/etc/htpasswd.users
# 启动apache服务
netstat -ntl|grep 8080 > /dev/null 2>&1
if [ $? != '0' ];then
    echo "Apache服务不存在,现在开始启动"
    $HOME/local/httpd/bin/apachectl start &
    if [ $? -eq '0' ];then
        echo "Apache服务启动成功"
        sleep 3;
    else
        echo "Apache服务启动失败:$?"
        exit 2;
    fi
else
    echo "Apache服务已经启动"
fi


# 检查Nagios
$HOME/nagios/etc/objects/check_nagios_cfg.sh

if [ $? != '0' ];then
    echo "检测Nagios配置错误,请手动检查";
    exit 2;
fi

# 启动Nagios


