#!/bin/bash
DATE=`date '+%Y-%m-%d-%H:%M:%S'`
{
set -xe
DATE=`date '+%Y-%m-%d-%H:%M:%S'`
SOURCE_CODE_DIR=/root/vwvo_server/vwvo
SOURCE_CONFIG_DIR=/root/vwvo_server/vwvo/config
SOURCE_LIB_DIR=/root/vwvo_server/vwvo/lib
SOURCE_EXTEMSIONS_DIR=/root/vwvo_server/vwvo/extensions
INSTALL_DIR=/home/services/vwvo
INSTALL_CONFIG_DIR=/home/services/vwvo/config
INSTALL_LIB_DIR=/home/services/vwvo/lib
INSTALL_EXTENSIONS_DIR=/home/services/vwvo/extensions
#this value can read from command line, ex:$1. now set value "stable_0.7"
GIT_BRANCH=stable_0.7
GROUP=services
USER=services

#set -e
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

#use services user exec
#su services
#set -e
#1. git clone source code to localhost
#all source code are 500M+, after compile and pack they are 3G+.
echo "#################################"
echo "clone source code & switch branch"
echo "#################################"
rpm -qi git maven
if [ $? -ne 0 ];then
    yum install git maven -y
else
    echo "already install."
fi

if [ -d ~/vwvo_server ];then
    rm -rf ~/vwvo_server
fi
cd ~ && git clone http://lujiuyang:1@192.168.1.129:82/vwvo_server.git
cd $SOURCE_CODE_DIR && git checkout $GIT_BRANCH

#2. build lifecycle
#laofu,why not set goal to deploy?
echo "########################"
echo "starting build lifecycle"
echo "########################"
cd $SOURCE_CODE_DIR 
mvn -e -Dmaven.test.skip=true clean install

#3. copy code to specify directory
#backup
if [ -d $INSTALL_DIR ];then
    mkdir /tmp/vwvo-backup-$DATE/ && mv  $INSTALL_DIR/* /tmp/vwvo-backup-$DATE/
fi
#about config files
cp -avrf $SOURCE_CONFIG_DIR $INSTALL_DIR
#about extensions files
cp -avf $SOURCE_EXTEMSIONS_DIR $INSTALL_DIR
##about lib files
#about third party jar (*.jar)
cp -avf $SOURCE_LIB_DIR $INSTALL_DIR
#about own *SNAPSHOT.jar
find $SOURCE_CODE_DIR -name '*SNAPSHOT.jar' | xargs -i cp -avf {} $INSTALL_LIB_DIR
#about own *vwvo-executable.jar
find $SOURCE_CODE_DIR -name '*runnable*executable.jar' | xargs -i cp -avf {} $INSTALL_DIR
find $SOURCE_CODE_DIR -name '*node-keeper*executable.jar' | xargs -i cp -avf {} $INSTALL_DIR
#about own *SNAPSHOT.war
find $SOURCE_CODE_DIR -name '*SNAPSHOT.war' | xargs -i cp -avf {} $INSTALL_DIR
chown -R services:services $INSTALL_DIR

#4. use nodekeeper start services
echo "###########################################################"
echo "starting nodekeeper...                                     "
echo "it will start other services if you set auto_deploy daemon."
echo "###########################################################"
nodekeeper_start() {
    nohup java -jar $INSTALL_DIR/vwvo-node-keeper-0.0.1-SNAPSHOT-vwvo-executable.jar  --cluster=test162 --config=162 2>&1 & 
}
NK_PROCESS=`ps -ef | grep vwvo-node-keeper | grep -v grep | awk '{ print $2}'`
if [ -n NK_PROCESS ];then
    echo "nodekeeper process has exsistd ! restart it."
    kill $NK_PROCESS
    nodekeeper_start
else
    nodekeeper_start
#    echo "nodekeeper started!"
#    echo "nodekeeper begin to start other services..."
fi
    echo "nodekeeper started!"
    echo "nodekeeper begin to start other services..."

} | tee deploy_${DATE}.log
