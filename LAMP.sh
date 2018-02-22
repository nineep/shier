#!/bin/bash

dir='/opt'

nginx='http://nginx.org/download/nginx-1.1.8.tar.gz'
php='http://cn2.php.net/distributions/php-5.3.8.tar.bz2'
mysql='http://mirror.trouble-free.net/mysql_mirror/Downloads/MySQL-5.5/mysql-5.5.18.tar.gz'
libiconv='http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.13.1.tar.gz'
libmcrypt='http://nchc.dl.sourceforge.net/project/mcrypt/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz'
mcrypt='http://nchc.dl.sourceforge.net/project/mcrypt/MCrypt/2.6.8/mcrypt-2.6.8.tar.gz'
memcache='http://pecl.php.net/get/memcache-2.2.5.tgz'
mhash='http://nchc.dl.sourceforge.net/project/mhash/mhash/0.9.9.9/mhash-0.9.9.9.tar.gz'
pcre='http://nchc.dl.sourceforge.net/project/pcre/pcre/8.20/pcre-8.20.zip'
eaccelerator='http://nchc.dl.sourceforge.net/project/eaccelerator/eaccelerator/eAccelerator%200.9.6.1/eaccelerator-0.9.6.1.tar.bz2'
PDO_MYSQL='http://pecl.php.net/get/PDO_MYSQL-1.0.2.tgz'
ImageMagick='http://blog.s135.com/soft/linux/nginx_php/imagick/ImageMagick.tar.gz'
imagick='http://pecl.php.net/get/imagick-2.3.0.tgz'
cmake='http://www.cmake.org/files/v2.8/cmake-2.8.6.tar.gz'
memcached='http://memcached.googlecode.com/files/memcached-1.4.5.tar.gz'
libevent='http://monkey.org/~provos/libevent-2.0.11-stable.tar.gz'

function f_check(){
	if [ $? -ne 0 ]
	then
		echo -e "\033[0;33;1m########################################################\033[0m"
		echo -e "\033[0;31;1mInstall error!~~~\033[0m"
		echo -e "\033[0;31;1mInput '1' to Try Agin,while you fixed the error.\033[0m"
		echo -e "\033[0;31;1mInput '2' to exit.\033[0m"
		echo -e "\033[0;31;1mor press 'enter' to continue\033[0m"
		echo -e "\033[0;33;1m########################################################\033[0m"
		read -p "Select:" a
		case $a in
			1)
			$1
			;;
			2)
			exit 2;
			;;
			*)
			continue
			;;
		esac
	fi
}

function f_cutname(){
	cd $dir
	filename=`basename $1`
	foldername=`echo $filename | sed 's/\.tar\.gz//' | sed 's/\.tar\.bz2//' | sed 's/\.tgz//' | sed 's/\.zip//'` 
	type=`echo $filename | awk -F . '{printf $NF}'`
	if [ -f $filename ]
	then
		rm -rf $filename
	fi
	if [ -d $foldername ]
	then
		rm -rf $foldername
	fi
	wget $1
	case $type in
		gz|tgz)
		tar zxvf $filename
		;;
		bz2)
		tar jxvf $filename
		;;
		zip)
		unzip $filename
		;;
		*)
		echo $filename Type error!
		exit
		;;
	esac
	cd $foldername
	echo $foldername
}

function f_yum_lib(){
/usr/bin/yum clean all
/usr/bin/yum -y install gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers
}

function f_libiconv_install(){
        f_cutname $libiconv
        ./configure --prefix=/usr/local
        f_check  $FUNCNAME
        make;make install
        f_check  $FUNCNAME
}

function f_libmcrypt_install(){
	f_cutname $libmcrypt
	./configure
	make;make install
	/sbin/ldconfig
	cd libltdl
	./configure --enable-ltdl-install
        f_check  $FUNCNAME
	make;make install
        f_check  $FUNCNAME
	cd /usr/local/lib/
	for i in `ls libmcrypt.*`
	do
		ln -sv /usr/local/lib/"$i" /usr/lib/"$i" 
	done
	ln -sv /usr/local/bin/libmcrypt-config /usr/bin/libmcrypt-config
}

function f_mhash_install(){
        f_cutname $mhash
	./configure
        f_check  $FUNCNAME
	make;make install
        f_check  $FUNCNAME
	cd /usr/local/lib/
	for i in `ls libmhash.*`
	do
		ln -sv /usr/local/lib/"$i" /usr/lib/"$i"
	done
}

function f_mcrypt_install(){
	f_cutname $mcrypt
	/sbin/ldconfig
	./configure
        f_check  $FUNCNAME
	make;make install
        f_check  $FUNCNAME
}

function f_cmake_install(){
	f_cutname $cmake
	./bootstrap
        f_check  $FUNCNAME
	gmake;make install
        f_check  $FUNCNAME
}

function f_mysql_install(){
	/usr/sbin/groupadd mysql
	/usr/sbin/useradd -g mysql mysql
	f_cutname $mysql
	cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_DATADIR=/data/mysql -DWITH_MYISAM_STORAGE_ENGINE=1 \
		-DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
		-DENABLED_LOCAL_INFILE=1 -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci  -DEXTRA_CHARSETS=all \
		-DMYSQL_TCP_PORT=3306 -DWITH_DEBUG=OFF -DWITH_READLINE=1 -DMYSQL_UNIX_ADDR=/tmp/mysql.sock
        f_check  $FUNCNAME
	make;make install
        f_check  $FUNCNAME
	ln -s /usr/local/mysql/lib/libmysqlclient.so.18 /usr/lib/libmysqlclient.so.18
	if [ -d /usr/lib64 ];then
		ln -s /usr/local/mysql/lib/libmysqlclient.so.18 /usr/lib64/libmysqlclient.so.18
	fi
}

function f_mysql_management(){
cat > /etc/my.cnf << "EOF"
[client]
port    = 3306
socket  = /tmp/mysql.sock

[mysqld]
character-set-server = utf8
replicate-ignore-db = mysql
replicate-ignore-db = test
replicate-ignore-db = information_schema
user    = mysql
port    = 3306
socket  = /tmp/mysql.sock
basedir = /usr/local/mysql
datadir = /data/mysql
log-error = /data/mysql/mysql_error.log
pid-file = /data/mysql/mysql.pid
open_files_limit    = 10240
back_log = 600
max_connections = 5000
max_connect_errors = 6000
table_cache = 614
external-locking = FALSE
max_allowed_packet = 32M
sort_buffer_size = 1M
join_buffer_size = 1M
thread_cache_size = 300
#thread_concurrency = 8
query_cache_size = 512M
query_cache_limit = 2M
query_cache_min_res_unit = 2k
default-storage-engine = MyISAM
thread_stack = 192K
transaction_isolation = READ-COMMITTED
tmp_table_size = 246M
max_heap_table_size = 246M
long_query_time = 3
log-slave-updates
#log-bin = /usr/local/mysql/data/binlog
#binlog_cache_size = 4M
#binlog_format = MIXED
#max_binlog_cache_size = 8M
#max_binlog_size = 1G
relay-log-index = /data/mysql/relaylog
relay-log-info-file = /data/mysql/relaylog
relay-log = /data/mysql/relaylog
expire_logs_days = 30
key_buffer_size = 256M
read_buffer_size = 1M
read_rnd_buffer_size = 16M
bulk_insert_buffer_size = 64M
myisam_sort_buffer_size = 128M
myisam_max_sort_file_size = 10G
myisam_repair_threads = 1
myisam_recover

interactive_timeout = 120
wait_timeout = 120

skip-name-resolve
#master-connect-retry = 10
slave-skip-errors = 1032,1062,126,1114,1146,1048,1396

#master-host     =   192.168.1.2
#master-user     =   username
#master-password =   password
#master-port     =  3306

server-id = 1

innodb_additional_mem_pool_size = 16M
innodb_buffer_pool_size = 512M
innodb_data_file_path = ibdata1:256M:autoextend
innodb_file_io_threads = 4
innodb_thread_concurrency = 8
innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 16M
innodb_log_file_size = 128M
innodb_log_files_in_group = 3
innodb_max_dirty_pages_pct = 90
innodb_lock_wait_timeout = 120
innodb_file_per_table = 0

#log-slow-queries = /data/mysql/slow.log
#long_query_time = 10

[mysqldump]
quick
max_allowed_packet = 32M
EOF
	chmod 755 scripts/mysql_install_db
	scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql --datadir=/data/mysql
	cp support-files/mysql.server /etc/init.d/mysql
	chmod 755 /etc/init.d/mysql
	chkconfig mysql on
	service mysql start
	/usr/local/mysql/bin/mysqladmin -u root password 'lihuipeng'
}

function f_php_install(){
	f_cutname $php
	./configure 	--prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-mysql=/usr/local/mysql \
		--with-mysqli=/usr/local/mysql/bin/mysql_config --with-iconv-dir=/usr/local --with-freetype-dir \
		--with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath \
		--enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization \
		--with-curl --with-curlwrappers --enable-mbregex --enable-fpm --enable-mbstring --with-mcrypt \
		--with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets \
		--with-ldap --with-ldap-sasl --with-xmlrpc --enable-zip --enable-soap
        f_check  $FUNCNAME
	make ZEND_EXTRA_LIBS='-liconv';make install
        f_check  $FUNCNAME
	cp php.ini-production /usr/local/php/etc/php.ini
	sed -i 's@; output_buffering@output_buffering=on@' /usr/local/php/etc/php.ini
	sed -i 's@;cgi.fix_pathinfo=1@cgi.fix_pathinfo=0@' /usr/local/php/etc/php.ini
	sed -i 's@; extension_dir = "./"@extension_dir = "/usr/local/php/lib/php/extensions/no-debug-non-zts-20090626"@' /usr/local/php/etc/php.ini
cat >> /usr/local/php/etc/php-fpm.conf << "EOF"
;;;;;;;;;;;;;;;;;;;;;
; FPM Configuration ;
;;;;;;;;;;;;;;;;;;;;;

; All relative paths in this configuration file are relative to PHP's install
; prefix (/usr/local/php). This prefix can be dynamicaly changed by using the
; '-p' argument from the command line.

; Include one or more files. If glob(3) exists, it is used to include a bunch of
; files from a glob(3) pattern. This directive can be used everywhere in the
; file.
; Relative path can also be used. They will be prefixed by:
;  - the global prefix if it's been set (-p arguement)
;  - /usr/local/php otherwise
;include=etc/fpm.d/*.conf

;;;;;;;;;;;;;;;;;;
; Global Options ;
;;;;;;;;;;;;;;;;;;

[global]
; Pid file
; Note: the default prefix is /usr/local/php/var
; Default Value: none
;pid = run/php-fpm.pid

; Error log file
; Note: the default prefix is /usr/local/php/var
; Default Value: log/php-fpm.log
;error_log = log/php-fpm.log

; Log level
; Possible Values: alert, error, warning, notice, debug
; Default Value: notice
;log_level = notice

; If this number of child processes exit with SIGSEGV or SIGBUS within the time
; interval set by emergency_restart_interval then FPM will restart. A value
; of '0' means 'Off'.
; Default Value: 0
emergency_restart_threshold = 10

; Interval of time used by emergency_restart_interval to determine when 
; a graceful restart will be initiated.  This can be useful to work around
; accidental corruptions in an accelerator's shared memory.
; Available Units: s(econds), m(inutes), h(ours), or d(ays)
; Default Unit: seconds
; Default Value: 0
emergency_restart_interval = 1m

; Time limit for child processes to wait for a reaction on signals from master.
; Available units: s(econds), m(inutes), h(ours), or d(ays)
; Default Unit: seconds
; Default Value: 0
process_control_timeout = 5s

; Send FPM to background. Set to 'no' to keep FPM in foreground for debugging.
; Default Value: yes
daemonize = yes
 
; Set open file descriptor rlimit for the master process.
; Default Value: system defined value
;rlimit_files = 1024
 
; Set max core size rlimit for the master process.
; Possible Values: 'unlimited' or an integer greater or equal to 0
; Default Value: system defined value
;rlimit_core = 0

;;;;;;;;;;;;;;;;;;;;
; Pool Definitions ; 
;;;;;;;;;;;;;;;;;;;;

; Multiple pools of child processes may be started with different listening
; ports and different management options.  The name of the pool will be
; used in logs and stats. There is no limitation on the number of pools which
; FPM can handle. Your system will tell you anyway :)

; Start a new pool named 'www'.
; the variable $pool can we used in any directive and will be replaced by the
; pool name ('www' here)
[www]

; Per pool prefix
; It only applies on the following directives:
; - 'slowlog'
; - 'listen' (unixsocket)
; - 'chroot'
; - 'chdir'
; - 'php_values'
; - 'php_admin_values'
; When not set, the global prefix (or /usr/local/php) applies instead.
; Note: This directive can also be relative to the global prefix.
; Default Value: none
;prefix = /path/to/pools/$pool

; The address on which to accept FastCGI requests.
; Valid syntaxes are:
;   'ip.add.re.ss:port'    - to listen on a TCP socket to a specific address on
;                            a specific port;
;   'port'                 - to listen on a TCP socket to all addresses on a
;                            specific port;
;   '/path/to/unix/socket' - to listen on a unix socket.
; Note: This value is mandatory.
listen = 127.0.0.1:9000

; Set listen(2) backlog. A value of '-1' means unlimited.
; Default Value: 128 (-1 on FreeBSD and OpenBSD)
listen.backlog = -1
 
; List of ipv4 addresses of FastCGI clients which are allowed to connect.
; Equivalent to the FCGI_WEB_SERVER_ADDRS environment variable in the original
; PHP FCGI (5.2.2+). Makes sense only with a tcp listening socket. Each address
; must be separated by a comma. If this value is left blank, connections will be
; accepted from any ip address.
; Default Value: any
listen.allowed_clients = 127.0.0.1

; Set permissions for unix socket, if one is used. In Linux, read/write
; permissions must be set in order to allow connections from a web server. Many
; BSD-derived systems allow connections regardless of permissions. 
; Default Values: user and group are set as the running user
;                 mode is set to 0666
;listen.owner = nobody
;listen.group = nobody
;listen.mode = 0666

; Unix user/group of processes
; Note: The user is mandatory. If the group is not set, the default user's group
;       will be used.
user = www
group = www

; Choose how the process manager will control the number of child processes.
; Possible Values:
;   static  - a fixed number (pm.max_children) of child processes;
;   dynamic - the number of child processes are set dynamically based on the
;             following directives:
;             pm.max_children      - the maximum number of children that can
;                                    be alive at the same time.
;             pm.start_servers     - the number of children created on startup.
;             pm.min_spare_servers - the minimum number of children in 'idle'
;                                    state (waiting to process). If the number
;                                    of 'idle' processes is less than this
;                                    number then some children will be created.
;             pm.max_spare_servers - the maximum number of children in 'idle'
;                                    state (waiting to process). If the number
;                                    of 'idle' processes is greater than this
;                                    number then some children will be killed.
; Note: This value is mandatory.
pm = static

; The number of child processes to be created when pm is set to 'static' and the
; maximum number of child processes to be created when pm is set to 'dynamic'.
; This value sets the limit on the number of simultaneous requests that will be
; served. Equivalent to the ApacheMaxClients directive with mpm_prefork.
; Equivalent to the PHP_FCGI_CHILDREN environment variable in the original PHP
; CGI.
; Note: Used when pm is set to either 'static' or 'dynamic'
; Note: This value is mandatory.
pm.max_children = 128

; The number of child processes created on startup.
; Note: Used only when pm is set to 'dynamic'
; Default Value: min_spare_servers + (max_spare_servers - min_spare_servers) / 2
pm.start_servers = 20

; The desired minimum number of idle server processes.
; Note: Used only when pm is set to 'dynamic'
; Note: Mandatory when pm is set to 'dynamic'
pm.min_spare_servers = 5

; The desired maximum number of idle server processes.
; Note: Used only when pm is set to 'dynamic'
; Note: Mandatory when pm is set to 'dynamic'
pm.max_spare_servers = 35
 
; The number of requests each child process should execute before respawning.
; This can be useful to work around memory leaks in 3rd party libraries. For
; endless request processing specify '0'. Equivalent to PHP_FCGI_MAX_REQUESTS.
; Default Value: 0
pm.max_requests = 1024

; The URI to view the FPM status page. If this value is not set, no URI will be
; recognized as a status page. By default, the status page shows the following
; information:
;   accepted conn        - the number of request accepted by the pool;
;   pool                 - the name of the pool;
;   process manager      - static or dynamic;
;   idle processes       - the number of idle processes;
;   active processes     - the number of active processes;
;   total processes      - the number of idle + active processes.
;   max children reached - number of times, the process limit has been reached,
;                          when pm tries to start more children (works only for
;                          pm 'dynamic')
; The values of 'idle processes', 'active processes' and 'total processes' are
; updated each second. The value of 'accepted conn' is updated in real time.
; Example output:
;   accepted conn:        12073
;   pool:                 www
;   process manager:      static
;   idle processes:       35
;   active processes:     65
;   total processes:      100
;   max children reached: 1
; By default the status page output is formatted as text/plain. Passing either
; 'html', 'xml' or 'json' as a query string will return the corresponding output
; syntax. Example:
;   http://www.foo.bar/status
;   http://www.foo.bar/status?json
;   http://www.foo.bar/status?html
;   http://www.foo.bar/status?xml
; Note: The value must start with a leading slash (/). The value can be
;       anything, but it may not be a good idea to use the .php extension or it
;       may conflict with a real PHP file.
; Default Value: not set 
pm.status_path = /status
 
; The ping URI to call the monitoring page of FPM. If this value is not set, no
; URI will be recognized as a ping page. This could be used to test from outside
; that FPM is alive and responding, or to
; - create a graph of FPM availability (rrd or such);
; - remove a server from a group if it is not responding (load balancing);
; - trigger alerts for the operating team (24/7).
; Note: The value must start with a leading slash (/). The value can be
;       anything, but it may not be a good idea to use the .php extension or it
;       may conflict with a real PHP file.
; Default Value: not set
ping.path = /ping

; This directive may be used to customize the response of a ping request. The
; response is formatted as text/plain with a 200 response code.
; Default Value: pong
ping.response = pong

; The access log file
; Default: not set
;access.log = log/$pool.access.log

; The access log format.
; The following syntax is allowed
;  %%: the '%' character
;  %C: %CPU used by the request
;      it can accept the following format:
;      - %{user}C for user CPU only
;      - %{system}C for system CPU only
;      - %{total}C  for user + system CPU (default)
;  %d: time taken to serve the request
;      it can accept the following format:
;      - %{seconds}d (default)
;      - %{miliseconds}d
;      - %{mili}d
;      - %{microseconds}d
;      - %{micro}d
;  %e: an environment variable (same as $_ENV or $_SERVER)
;      it must be associated with embraces to specify the name of the env
;      variable. Some exemples:
;      - server specifics like: %{REQUEST_METHOD}e or %{SERVER_PROTOCOL}e
;      - HTTP headers like: %{HTTP_HOST}e or %{HTTP_USER_AGENT}e
;  %f: script filename
;  %l: content-length of the request (for POST request only)
;  %m: request method
;  %M: peak of memory allocated by PHP
;      it can accept the following format:
;      - %{bytes}M (default)
;      - %{kilobytes}M
;      - %{kilo}M
;      - %{megabytes}M
;      - %{mega}M
;  %n: pool name
;  %o: ouput header
;      it must be associated with embraces to specify the name of the header:
;      - %{Content-Type}o
;      - %{X-Powered-By}o
;      - %{Transfert-Encoding}o
;      - ....
;  %p: PID of the child that serviced the request
;  %P: PID of the parent of the child that serviced the request
;  %q: the query string 
;  %Q: the '?' character if query string exists
;  %r: the request URI (without the query string, see %q and %Q)
;  %R: remote IP address
;  %s: status (response code)
;  %t: server time the request was received
;      it can accept a strftime(3) format:
;      %d/%b/%Y:%H:%M:%S %z (default)
;  %T: time the log has been written (the request has finished)
;      it can accept a strftime(3) format:
;      %d/%b/%Y:%H:%M:%S %z (default)
;  %u: remote user
;
; Default: "%R - %u %t \"%m %r\" %s"
;access.format = %R - %u %t "%m %r%Q%q" %s %f %{mili}d %{kilo}M %C%%
 
; The timeout for serving a single request after which the worker process will
; be killed. This option should be used when the 'max_execution_time' ini option
; does not stop script execution for some reason. A value of '0' means 'off'.
; Available units: s(econds)(default), m(inutes), h(ours), or d(ays)
; Default Value: 0
;request_terminate_timeout = 0
 
; The timeout for serving a single request after which a PHP backtrace will be
; dumped to the 'slowlog' file. A value of '0s' means 'off'.
; Available units: s(econds)(default), m(inutes), h(ours), or d(ays)
; Default Value: 0
request_slowlog_timeout = 10
 
; The log file for slow requests
; Default Value: not set
; Note: slowlog is mandatory if request_slowlog_timeout is set
slowlog = /usr/local/php/var/log/slow.log
 
; Set open file descriptor rlimit.
; Default Value: system defined value
rlimit_files = 65535
 
; Set max core size rlimit.
; Possible Values: 'unlimited' or an integer greater or equal to 0
; Default Value: system defined value
rlimit_core = 0
 
; Chroot to this directory at the start. This value must be defined as an
; absolute path. When this value is not set, chroot is not used.
; Note: you can prefix with '$prefix' to chroot to the pool prefix or one
; of its subdirectories. If the pool prefix is not set, the global prefix
; will be used instead.
; Note: chrooting is a great security feature and should be used whenever 
;       possible. However, all PHP paths will be relative to the chroot
;       (error_log, sessions.save_path, ...).
; Default Value: not set
;chroot = 
 
; Chdir to this directory at the start.
; Note: relative path can be used.
; Default Value: current directory or / when chroot
;chdir = /var/www
 
; Redirect worker stdout and stderr into main error log. If not set, stdout and
; stderr will be redirected to /dev/null according to FastCGI specs.
; Note: on highloaded environement, this can cause some delay in the page
; process time (several ms).
; Default Value: no
catch_workers_output = yes
 
; Pass environment variables like LD_LIBRARY_PATH. All $VARIABLEs are taken from
; the current environment.
; Default Value: clean env
;env[HOSTNAME] = $HOSTNAME
;env[PATH] = /usr/local/bin:/usr/bin:/bin
;env[TMP] = /tmp
;env[TMPDIR] = /tmp
;env[TEMP] = /tmp

; Additional php.ini defines, specific to this pool of workers. These settings
; overwrite the values previously defined in the php.ini. The directives are the
; same as the PHP SAPI:
;   php_value/php_flag             - you can set classic ini defines which can
;                                    be overwritten from PHP call 'ini_set'. 
;   php_admin_value/php_admin_flag - these directives won't be overwritten by
;                                     PHP call 'ini_set'
; For php_*flag, valid values are on, off, 1, 0, true, false, yes or no.

; Defining 'extension' will load the corresponding shared extension from
; extension_dir. Defining 'disable_functions' or 'disable_classes' will not
; overwrite previously defined php.ini values, but will append the new value
; instead.

; Note: path INI options can be relative and will be expanded with the prefix
; (pool, global or /usr/local/php)

; Default Value: nothing is defined by default except the values in php.ini and
;                specified at startup with the -d argument
;php_admin_value[sendmail_path] = /usr/sbin/sendmail -t -i -f www@my.domain.com
;php_flag[display_errors] = off
;php_admin_value[error_log] = /var/log/fpm-php.www.log
;php_admin_flag[log_errors] = on
;php_admin_value[memory_limit] = 32M

EOF
echo "/usr/local/php/sbin/php-fpm" >> /etc/rc.local
}

function f_memcache_install(){
	f_cutname $memcache
	/usr/local/php/bin/phpize
	./configure --with-php-config=/usr/local/php/bin/php-config
        f_check  $FUNCNAME
	make;make install
        f_check  $FUNCNAME
	sed -i '810aextension = "memcache.so"' /usr/local/php/etc/php.ini
}

function f_eaccelerator_install(){
	f_cutname $eaccelerator
	/usr/local/php/bin/phpize
	./configure --enable-eaccelerator=shared --with-php-config=/usr/local/php/bin/php-config
        f_check  $FUNCNAME
	make;make install
        f_check  $FUNCNAME
	mkdir -p /usr/local/eaccelerator_cache
	sed -i '810aextension = "pdo_mysql.so"' /usr/local/php/etc/php.ini
cat >> /usr/local/php/etc/php.ini << "EOF"
[eaccelerator]
zend_extension="/usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/eaccelerator.so"
eaccelerator.shm_size="64"
eaccelerator.cache_dir="/usr/local/eaccelerator_cache"
eaccelerator.enable="1"
eaccelerator.optimizer="1"
eaccelerator.check_mtime="1"
eaccelerator.debug="0"
eaccelerator.filter=""
eaccelerator.shm_max="0"
eaccelerator.shm_ttl="3600"
eaccelerator.shm_prune_period="3600"
eaccelerator.shm_only="0"
eaccelerator.compress="1"
eaccelerator.compress_level="9"
EOF
}

function f_PDO_MYSQL_install(){
	f_cutname $PDO_MYSQL
	/usr/local/php/bin/phpize
	./configure --with-php-config=/usr/local/php/bin/php-config --with-pdo-mysql=/usr/local/mysql
        f_check  $FUNCNAME
	make;make install
        f_check  $FUNCNAME
	sed -i '810aextension = "imagick.so"' /usr/local/php/etc/php.ini
}

function f_ImageMagick_install(){
	cd $dir
	wget $ImageMagick
	tar zxvf ImageMagick.tar.gz
	cd ImageMagick-6.5.1-2
	./configure
        f_check  $FUNCNAME
	make;make install
        f_check  $FUNCNAME
}

function f_imagick_install(){
	f_cutname $imagick
	/usr/local/php/bin/phpize
	./configure --with-php-config=/usr/local/php/bin/php-config
        f_check  $FUNCNAME
	make;make install
        f_check  $FUNCNAME
}

function f_pcre_install(){
	f_cutname $pcre
	./configure
        f_check  $FUNCNAME
	make;make install
        f_check  $FUNCNAME
}

function f_nginx_install(){
	mkdir -p /data/www/logs
	f_cutname $nginx
	/usr/sbin/groupadd www
	/usr/sbin/useradd -m www -g www -s /sbin/nologin -d /usr/local/nginx
	chown -R www:www /data/www
	./configure  --prefix=/usr/local/nginx  --with-http_stub_status_module --with-http_ssl_module \
		--user=www --group=www --with-http_realip_module --with-http_flv_module --with-http_gzip_static_module
        f_check  $FUNCNAME
	make;make install
        f_check  $FUNCNAME
	mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.bak
cat > /usr/local/nginx/conf/nginx.conf << "EOF"
user www www;

worker_processes 8;
worker_cpu_affinity 0001 0010 0100 1000 0001 0010 0100 1000;

error_log  /data/www/logs/error.log  notice;

pid        /data/www/logs/nginx.pid;

worker_rlimit_nofile 65535;

events {
	use epoll;
	worker_connections 65535;
}

http {
    
	include       mime.types;   
  	default_type  application/octet-stream;     

	log_format  main  	'$remote_addr - $remote_user [$time_local] "$request" '
				'$status $body_bytes_sent "$http_referer" '
				'"$http_user_agent" $http_x_forwarded_for';

  	#charset  gb2312;  
  	server_names_hash_bucket_size 128;   
  	client_header_buffer_size 32k;  
  	large_client_header_buffers 4 32k;  
  	client_max_body_size 30m; 
  	sendfile on;  
  	tcp_nopush     on;   
  	keepalive_timeout 60; 
  	tcp_nodelay on; 
  	server_tokens off;
  	client_body_buffer_size 512k;
 
  	#proxy_connect_timeout   5; 
  	#proxy_send_timeout      60; 
  	#proxy_read_timeout      5; 
  	#proxy_buffer_size       16k; 
  	#proxy_buffers           4 64k; 
  	#proxy_busy_buffers_size 128k; 
  	#proxy_temp_file_write_size 128k; 

  	fastcgi_connect_timeout 300; 
  	fastcgi_send_timeout 300; 
  	fastcgi_read_timeout 300; 
  	fastcgi_buffer_size 64k; 
  	fastcgi_buffers 4 64k; 
  	fastcgi_busy_buffers_size 128k; 
  	fastcgi_temp_file_write_size 128k;   

  	gzip on; 
  	gzip_min_length  1k; 
  	gzip_buffers     4 16k; 
  	gzip_http_version 1.1; 
  	gzip_comp_level 2; 
  	gzip_types       text/plain application/x-javascript text/css application/xml; 
  	gzip_vary on; 
  
  	#limit_zone  crawler  $binary_remote_addr  10m; server

	server{
		listen       80;
		server_name localhost;
		index index.html index.php index.htm;
		root  /data/www;
		access_log  /data/www/logs/access_localhost.log main;
			
		if (-d $request_filename){
			rewrite ^/(.*)([^/])$ http://$host/$1$2/ permanent;
		}
	    
		error_page   500 502 503 504 404 403 http://localhost;
	    
		location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$ {
			expires 30d;
		}

		location ~ .*\.(js|css)?$ {
			expires 6h;
		}

		location ~ .*\.(log|txt)$
		{
			deny all;
		}

		location ~ ^/(status|ping)$ {
			fastcgi_pass  127.0.0.1:9000;
                        fastcgi_index index.php;
                        include fcgi.conf;
		}

		location ~ .*\.(php)?$
		{
			fastcgi_pass  127.0.0.1:9000;
			fastcgi_index index.php;
			include fcgi.conf;
		}
	}
}
EOF

cat > /usr/local/nginx/conf/fcgi.conf << "EOF"
fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
fastcgi_param  SERVER_SOFTWARE    nginx;

fastcgi_param  QUERY_STRING       $query_string;
fastcgi_param  REQUEST_METHOD     $request_method;
fastcgi_param  CONTENT_TYPE       $content_type;
fastcgi_param  CONTENT_LENGTH     $content_length;

fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;
fastcgi_param  SCRIPT_NAME        $fastcgi_script_name;
fastcgi_param  REQUEST_URI        $request_uri;
fastcgi_param  DOCUMENT_URI       $document_uri;
fastcgi_param  DOCUMENT_ROOT      $document_root;
fastcgi_param  SERVER_PROTOCOL    $server_protocol;

fastcgi_param  REMOTE_ADDR        $remote_addr;
fastcgi_param  REMOTE_PORT        $remote_port;
fastcgi_param  SERVER_ADDR        $server_addr;
fastcgi_param  SERVER_PORT        $server_port;
fastcgi_param  SERVER_NAME        $server_name;

# PHP only, required if PHP was built with --enable-force-cgi-redirect
fastcgi_param  REDIRECT_STATUS    200;
EOF
echo "ulimit -SHn 65535" >> /etc/rc.local
echo "/usr/local/nginx/sbin/nginx" >> /etc/rc.local
}

function f_libevent_install(){
	f_cutname $libevent
	./configure
	f_check  $FUNCNAME
	make;make install
	f_check  $FUNCNAME
	ln -sv /usr/local/lib/libevent-2.0.so.5 /usr/lib/
	if [ -d /usr/lib64 ];then
		ln -sv /usr/local/lib/libevent-2.0.so.5 /usr/lib64/
	fi
}


function f_memcached_install(){
	f_cutname $memcached
	./configure --prefix=/usr/local/memcached --with-libevent=/usr
	f_check  $FUNCNAME
	make;make install
	f_check  $FUNCNAME
	echo "/usr/local/memcached/bin/memcached -d -m 64 -p 11211 -u www -l localhost" >> /etc/rc.local
}

cat << EOF
 +--------------------------------------------------------------+
 |         === Welcome to LNMP init ===     	                |
 |Default information:                                          |
 |mysqldatadir:/data/mysql                                      |
 |mysqlsocket:/tmp/                                             |
 |mysqlpasswd:lihuipeng                                         |
 |nginxdatadir:/data/www                                        |
 |nginxlogdir:/data/www/logs                                    |
 |installdir:/usr/local                                         |
 |srcdir:/opt                                                   |
 +--------------------------------------------------------------+
 |						Johnny compose                          |
 |Please select your option:                                    |
 |0:exit                                                        |
 |1:Only install Mysql-5.5                                      |
 |2:Only install Nginx                                          |
 |3:Install Nginx + PHP-5.3                                     |
 |4:Install Nginx + PHP-5.3 + Memcached                         |
 |5:Install Nginx + Mysql-5.5 + PHP-5.3                         |
 |6:INstall Nginx + Mysql-5.5 + PHP-5.3 + Memcached             |
 +----------------------by lihuipeng----------------------------+
EOF
read -p "Please input your option:{0|1|2|3|4|5|6}:" line

case $line in
	0)
	exit 0
	;;
	1)
	f_cmake_install
	f_mysql_install
	f_mysql_management
	;;
	2)
	f_pcre_install
	f_nginx_install
	/usr/local/nginx/sbin/nginx
	;;
	3)
	f_yum_lib
	f_libiconv_install
	f_libmcrypt_install
	f_mhash_install
	f_mcrypt_install
	f_cmake_install
	f_mysql_install
	f_php_install
	f_memcache_install
	f_eaccelerator_install
	f_PDO_MYSQL_install
	f_ImageMagick_install
	f_imagick_install
	f_pcre_install
	f_nginx_install	
	/usr/local/php/sbin/php-fpm
	/usr/local/nginx/sbin/nginx
	;;
	4)
	f_yum_lib
	f_libiconv_install
	f_libmcrypt_install
	f_mhash_install
	f_mcrypt_install
	f_cmake_install
	f_mysql_install
	f_php_install
	f_memcache_install
	f_eaccelerator_install
	f_PDO_MYSQL_install
	f_ImageMagick_install
	f_imagick_install
	f_pcre_install
	f_nginx_install
	f_libevent_install
	f_memcached_install
        /usr/local/php/sbin/php-fpm
        /usr/local/nginx/sbin/nginx
	/usr/local/memcached/bin/memcached -d -m 64 -p 11211 -u www -l localhost
	;;
	5)
  	f_yum_lib
  	f_libiconv_install
  	f_libmcrypt_install
  	f_mhash_install
  	f_mcrypt_install
  	f_cmake_install
  	f_mysql_install
	f_mysql_management
  	f_php_install
  	f_memcache_install
  	f_eaccelerator_install
  	f_PDO_MYSQL_install
  	f_ImageMagick_install
  	f_imagick_install
  	f_pcre_install
  	f_nginx_install
        /usr/local/php/sbin/php-fpm
        /usr/local/nginx/sbin/nginx
	;;
	6)
  	f_yum_lib
  	f_libiconv_install
  	f_libmcrypt_install
  	f_mhash_install
  	f_mcrypt_install
  	f_cmake_install
  	f_mysql_install
  	f_mysql_management
	f_php_install
  	f_memcache_install
  	f_eaccelerator_install
  	f_PDO_MYSQL_install
  	f_ImageMagick_install
  	f_imagick_install
  	f_pcre_install
  	f_nginx_install
  	f_libevent_install
  	f_memcached_install
        /usr/local/php/sbin/php-fpm
        /usr/local/nginx/sbin/nginx
	/usr/local/memcached/bin/memcached -d -m 64 -p 11211 -u www -l localhost
	;;
	*)
	echo "Usage: `basename $0` {0|1|2|3|4|5|6}" >&2
	exit 3
	;;
esac
