#!/bin/bash
#################################### 基础服务说明 ######################################
#jdk使用oracle官网的rpm包安装
#jdk-8u121-linux-x64.rpm

#kafka,zookeeper 使用二进制包安装，安装在/root/services/目录下
#kafka_2.11-0.10.1.0，zookeeper-3.4.9

#rabbitmq-server使用rpm包安装（直接就可以使用systemd管理了）
#rabbitmq-server-3.6.9

#redis、mongodb、mysql配置yum.repo,使用yum install 安装，
#其中redis使用epel源，mongodb和mysql使用官方源
#redis-3.2.3, mongodb-org-3.4.4，mysql-community-server-5.7.18

#tomcat使用二进制包安装
#apache-tomcat-8.5.15.tar.gz
set -x
##################################### variable set ######################################
DEPLOY_PACKAGE=`find / -name deploy_package`
mkdir ~/services
SERVICES_DIR=~/services
INSTALL_DIR=/home/services
GROUP=services
USER=services
JDK=jdk-8u121-linux-x64.rpm
RABBITMQ=rabbitmq-server-3.6.9-1.el7.noarch.rpm
ZOOKEEPER=zookeeper-3.4.9.tar.gz
ZOOKEEPER_DIR=zookeeper-3.4.9
KAFKA=kafka_2.11-0.10.1.0.tgz
KAFKA_DIR=kafka_2.11-0.10.1.0
TOMCAT=apache-tomcat-8.5.15.tar.gz
TOMCAT_DIR=apache-tomcat-8.5.15
MAVEN=apache-maven-3.3.9-bin.tar.gz
MAVEN_DIR=apache-maven-3.3.9

#################################### base env installation ###############################
#check user and usergroup
#create group if not exists
grep $GROUP /etc/group
if [ $? -ne 0 ];then
        echo "add group"
        groupadd $GROUP
fi
#create user if not exists
grep $USER /etc/passwd
if [ $? -ne 0 ];then
        useradd -g $GROUP $USER
fi

#jdk installation
rpm -qa openjdk
if [ $? -eq 0 ];then
    echo "You have installed."
    echo "uninstall it,and install jdk"
    rpm -qa | grep openjdk | xargs -i yum -y remove {} && yum install $DEPLOY_PACKAGE/$JDK -y
    java -version
else
    echo "install jdk.." 
    yum install $DEPLOY_PACKAGE/$JDK -y
fi

#maven installation
tar -zxvf $DEPLOY_PACKAGE/$MAVEN -C $SERVICES_DIR
ln -s $SERVICES_DIR/$MAVEN_DIR $SERVICES_DIR/maven
echo "MAVEN_HOME=${SERVICES_DIR}/${MAVEN_DIR}" >> ./.bashrc
echo "export MAVEN_HOME" >> ./.bashrc
echo "export PATH=${MAVEN_HOME}/bin:${PATH}" >> ./.bashrc
source ~/.bashrc 
mvn -v

################################# base services installation #############################
#rabbitmq-server installation
#yum install erlang -y
cd $DEPLOY_PACKAGE && yum install $RABBITMQ -y

#zookeeper installation
tar -zxvf $DEPLOY_PACKAGE/$ZOOKEEPER -C $SERVICES_DIR
ln -s $SERVICES_DIR/$ZOOKEEPER_DIR $SERVICES_DIR/zookeeper

#kafka installation
tar -zxvf $DEPLOY_PACKAGE/$KAFKA -C $SERVICES_DIR
ln -s $SERVICES_DIR/$KAFKA_DIR $SERVICES_DIR/kafka


#tomcat installation
tar -zxvf $DEPLOY_PACKAGE/$TOMCAT -C $INSTALL_DIR
ln -s $INSTALL_DIR/$TOMCAT_DIR $INSTALL_DIR/tomcat
chown -R services:services $INSTALL_DIR
echo "jdk,maven,rabbitmq,kafka,zookeeper,tomcat have installed!!"
################################ databases installation ##################################
#mysql
#配置mysql官方源，yum安装
#安装mysql社区版本服务端
#yum install mysql-community-server -y

#redis
#yum install 安装，目前使用是3.2.3版本
#yum install redis -y

#mogondb
#配置了官方yum仓库，但是官方源下载较慢，可换成下载安装包，本地安装
#最新的稳定版本是3.4.4
#yum install mongodb-org-server -y

################################ services start&enable ####################################
###查看rabbitmq服务状态
#systemctl status rabbitmq-server
#查看zookeeper进程, 以后加入到systemd管理
#ps -ef | grep zookeeper.server
#查看kafka进程
#screen -ls | grep Detached | echo $?
#查看数据库的状态
#systemctl status redis
#systemctl status mysqld
#systemctl status mongod

#对于yum安装速度慢的问题，搭建一个本地仓库解决。
