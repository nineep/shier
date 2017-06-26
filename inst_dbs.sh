#!/bin/bash
#init databases of mysql,mongodb,redis
#allinone env install
set -x
#config key connect
if [ -f ~/.ssh/id_rsa ];then
    echo "already exist id_rsa"
else
    echo "generate ssh keypair"
    ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
fi
yum install -y sshpass
sshpass -p vwvo1234QWE ssh-copy-id -i ~/.ssh/id_rsa.pub root@192.168.1.153

#config yum repo
mv /etc/yum.repos.d /etc/yum.repos.d.backup
    #will push repo config file to git repo,than use "git clone" to localhost
scp -o  StrictHostKeyChecking=no -r root@192.168.1.153:/etc/yum.repos.d/yum.repos.d /etc/
yum clean all

#install
#latest version:
    #mysql-community-server-5.7.18
    #redis-3.2.3
    #mongodb-org-3.4.4
yum install  mysql mysql-community-server redis mongodb-org -y

#config databases config_file
mv /etc/my.cnf /etc/my.cnf.backup
mv /etc/redis/redis.conf /etc/redis.conf.backup
mv /etc/mongod.conf /etc/mongod.conf.backup
scp -o  StrictHostKeyChecking=no root@192.168.1.153:/etc/my.cnf /etc/my.cnf
scp -o  StrictHostKeyChecking=no root@192.168.1.153:/etc/redis.conf /etc/redis.conf
scp -o  StrictHostKeyChecking=no root@192.168.1.153:/etc/mongod.conf /etc/mongod.conf
systemctl start mysqld redis mongod
systemctl enable mysqld redis mongod

#config databases
#mysqldump -d --add-drop-table vwvo > vwvo.sql
#mysqldump -d --add-drop-table vwvo_moni_manager > vwvo_moni_manager.sql

#mysql config
mysql -e "CREATE DATABASE IF NOT EXISTS vwvo default charset utf8 COLLATE utf8_general_ci;"
mysql -e "CREATE DATABASE IF NOT EXISTS vwvo_moni_manager default charset utf8 COLLATE utf8_general_ci;"
scp -o StrictHostKeyChecking=no  -r root@192.168.1.153:/root/lujiuyang/databases_sql_file /tmp 
cd /tmp/databases_sql_file && ls
mysql vwvo < vwvo.sql
mysql vwvo_moni_manager < vwvo_moni_manager.sql

#mongodb config
mongo --eval "use vwvo"
mongo --eval "db.createCollection('test')"
mongo --eval "use vwvo-log"
mongo --eval "db.createCollection('test')"
