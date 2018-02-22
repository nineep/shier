#!/bin/bash
cd `dirname $0`

ns1ip=10.30.101.201
ns2ip=10.30.101.202


## install openssl --------------------------------------
#tar zxvf openssl-0.9.8l.tar.gz
#cd openssl-0.9.8l
#
#echo -e "\n********** now go to config ..." && sleep 5
#
#./config
#
#confok=$?
#echo -e "\n********* config result is $confok"
#if [ $confok != 0 ]; then
#    echo -e "\n******** config failed" && exit 
#fi
#
#sleep 5
#
#make 
#
#makeok=$?
#echo -e "\n********* make result is $confok"
#if [ $makeok != 0 ]; then
#    echo -e "\n********* make failed" && exit
#fi
#
#sleep 5
#
#make install
#
#installok=$?
#echo -e "\n******** install result is $confok"
#if [ $installok != 0 ]; then
#    echo -e "\n******** install failed" && exit
#fi
#
#cd ..
#sleep 5
#
##exit

# install bind -----------------------------------------------
tar zxvf bind-9.7.4.tar.gz
cd bind-9.7.4
echo -e "\n********** now go to configure ..." && sleep 5

./configure --prefix=/opt/bind-9.7.4 \
  --sysconfdir=/etc \
  --enable-threads \
  --enable-epoll \
  --with-openssl=/usr

confok=$?
echo -e "\n********* configure result is $confok"
if [ $confok != 0 ]; then
    echo -e "\n******** configure failed" && exit
fi

sleep 5

make 

makeok=$?
echo -e "\n********* make result is $confok"
if [ $makeok != 0 ]; then
    echo -e "\n********* make failed" && exit
fi

sleep 5

make install

installok=$?
echo -e "\n******** install result is $confok"
if [ $installok != 0 ]; then
    echo -e "\n******** install failed" && exit
fi

cd ..
sleep 5


# configure bind ---------------------------------
useradd named
tail /etc/passwd

sleep 5

cd /opt/

if [ -d bind-9.7.4 ]; then
    ln -s bind-9.7.4 bind
else 
    echo "No bind directory" && exit
fi

ls -l

sleep 5

mkdir /opt/bind/var/log 
chown named:named /opt/bind/var/ -R

cd /opt/bind/sbin/
./rndc-confgen > /etc/rndc.conf
head -5 /etc/rndc.conf > /etc/rndc.key
cat /etc/rndc.key

sleep 5

#tail -10 /etc/rndc.conf | head -9 |sed 's/^# //g' > /etc/named.conf

cat > /etc/named.conf << _EOF_
include "/etc/rndc.key";

controls {
        inet 127.0.0.1 port 953
                allow { 127.0.0.1; } keys { "rndc-key"; };
};

options {
        directory "/etc/namedb/ucwebbox";
        datasize 512M;
        statistics-file "named.stats";
        allow-transfer { 127.0.0.1; };
        dump-file "named_dump.db";
        //interface-interval 0;
        interface-interval 1;
        //query-source address * port 53;
        recursion yes;
        allow-recursion { localhost; localnets; 10.0.0.0/8; };
        zone-statistics yes;
        version "Sun OS bind";
        listen-on-v6 { none; };
};

logging {
        channel warning
        { file "/opt/bind/var/log/named.log" versions 3 size 2048k;
          severity warning;
          print-category yes;
          print-severity yes;
          print-time yes;
        };
        channel query
        { file "/opt/bind/var/log/query.log" versions 10 size 20480k;
          //severity info;
          severity warning;
          print-category yes;
          print-severity yes;
          print-time yes;
        };
        category default { warning; };
        category queries { query; };
};

zone "." {
        type hint;
        file "/etc/namedb/ucwebbox/named.root";
};

   // RFC 1918
   zone "10.in-addr.arpa" { type master; file "db.empty"; };
   zone "16.172.in-addr.arpa" { type master; file "db.empty"; };
   zone "17.172.in-addr.arpa" { type master; file "db.empty"; };
   zone "18.172.in-addr.arpa" { type master; file "db.empty"; };
   zone "19.172.in-addr.arpa" { type master; file "db.empty"; };
   zone "20.172.in-addr.arpa" { type master; file "db.empty"; };
   zone "21.172.in-addr.arpa" { type master; file "db.empty"; };
   zone "22.172.in-addr.arpa" { type master; file "db.empty"; };
   zone "23.172.in-addr.arpa" { type master; file "db.empty"; };
   zone "24.172.in-addr.arpa" { type master; file "db.empty"; };
   zone "25.172.in-addr.arpa" { type master; file "db.empty"; };
   zone "26.172.in-addr.arpa" { type master; file "db.empty"; };
   zone "27.172.in-addr.arpa" { type master; file "db.empty"; };
   zone "28.172.in-addr.arpa" { type master; file "db.empty"; };
   zone "29.172.in-addr.arpa" { type master; file "db.empty"; };
   zone "30.172.in-addr.arpa" { type master; file "db.empty"; };
   zone "31.172.in-addr.arpa" { type master; file "db.empty"; };
   zone "168.192.in-addr.arpa" { type master; file "db.empty"; };

zone "uc.local" {
        type master;
        file "/etc/namedb/ucwebbox/hosts/all-uc.local.hosts";
};

zone "ucapp.local" {
        type master;
        file "/etc/namedb/ucwebbox/hosts/all-ucapp.local.hosts";
};

zone "mw.ucweb.com" {
        type master;
        file "/etc/namedb/ucwebbox/hosts/all-mw.ucweb.com.hosts";
};

zone "hap1.ucweb.com.cn" {
        type master;
        file "/etc/namedb/ucwebbox/hosts/all-hap1.ucweb.com.cn.hosts";
};

_EOF_

cat /etc/named.conf 

sleep 5

#------- make named.root ---------------------
mkdir /etc/namedb/
chown named. /etc/namedb/ 
chown named. /etc/named.conf 

su - named -c "mkdir /etc/namedb/ucwebbox"
su - named -c "mkdir /etc/namedb/ucwebbox/hosts"
su - named -c "cd /etc/namedb/ucwebbox/; wget ftp://ftp.internic.net/domain/named.root"

cat /etc/namedb/ucwebbox/named.root

#-------- make db.empty ---------------------
cat > /etc/namedb/ucwebbox/db.empty << _EOF_
@ 10800 IN SOA ns1.uc.local. root.uc.local. (
        1 3600 1200 604800 10800 )

@ 10800 IN NS ns1.uc.local.
@ 10800 IN NS ns2.uc.local.
_EOF_

cat /etc/namedb/ucwebbox/db.empty

#-------- make hosts file -------------------
cat > /etc/namedb/ucwebbox/hosts/all-hap1.ucweb.com.cn.hosts << _EOF_
\$TTL 3600
@       36000   IN      SOA     ns1.uc.local. root.uc.local. (
                                 2010032003     ; Serial,Increment by one after every change
                                  3600          ; Refresh
                                  1200          ; Retry
                                 36000          ; Expire
                                 3600 )         ; Negative Cache TTL
;

;------- NS Record area --------- 

@       3600    IN      NS      ns1.uc.local.
@       3600    IN      NS      ns2.uc.local.

;------- MX Record area ---------

;@       3600    IN      MX      10      mail

;------- A Record area ---------

@       1200     IN      A       113.142.17.15

_EOF_

cat /etc/namedb/ucwebbox/hosts/all-hap1.ucweb.com.cn.hosts

cp /etc/namedb/ucwebbox/hosts/all-hap1.ucweb.com.cn.hosts  /etc/namedb/ucwebbox/hosts/all-mw.ucweb.com.hosts 
cp /etc/namedb/ucwebbox/hosts/all-hap1.ucweb.com.cn.hosts  /etc/namedb/ucwebbox/hosts/all-ucapp.local.hosts

#-----------------------
cat > /etc/namedb/ucwebbox/hosts/all-uc.local.hosts << _EOF_
\$TTL 3600
@       36000   IN      SOA     ns1.uc.local. root.uc.local. (
                                 2010050703     ; Serial,Increment by one after every change
                                  3600          ; Refresh
                                  1200          ; Retry
                                 36000          ; Expire
                                 3600 )         ; Negative Cache TTL
;

;------- NS Record area --------- 

ns1     3600     IN      A       $ns1ip
ns2     3600     IN      A       $ns2ip

@       3600    IN      NS      ns1.uc.local.
@       3600    IN      NS      ns2.uc.local.

;------- MX Record area ---------

;@       3600    IN      MX      10      mail

;------- A Record area ---------

@        1200     IN      A       125.91.253.156

_EOF_

cat  /etc/namedb/ucwebbox/hosts/all-uc.local.hosts

chown named. /etc/namedb/ucwebbox/hosts/*


