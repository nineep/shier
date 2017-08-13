#!/bin/bash
#                  内核四项主要功能   
# 1.run time       文件系统/硬件设备管理
# 2.disk usage     硬件设备管理
# 3.memory usage   系统内存管理
# 4.zombie process 软件程序管理

#set variables
DATE=`date +%m%d%Y`
DISK_TO_MONITOR="/dev/sda1 /dev/sda2"
MAIL=`which mutt`
MAIL_TO=user
REPORT=/home/user/Documents/system_stats_$DATE.rpt

#create report file
exec 3>&1         #save file descriptor
exec 1> $REPORT   #output to rpt file
echo
echo -e "\t\tDaily system report"
echo

#date stamp the report
echo -e "Today is" `date +%m%d%Y`
echo

#1) gather system uptime statistics
echo -e "system has been \c"
uptime | sed -n '/,/s/,/ /gp' | awk ' { if ($4 == "days" || $4 == "day") {print $2,$3,$4,$5} else {print $2,$3}}'
#2) gather disk usage statistics
echo
for DISK in $DISKS_TO_MONITOR  #loop to check disk space
do
    echo -e "$DISK usage: \c"
    df -h $DISK | sed -n '/% \//p' | awk '{print $5}'
done
#3) gather memory usage statistics
echo 
echo -e "memory usage: \c"
free | sed -n '2p' | awk 'x = int(($3 / $2) *100) {print x}' | sed 's/$/%/'
#4) gather number of zombie processed
echo
ZOMBIE_CHECK=`ps -al | awk '{print $2,$4}' | grep Z`
if [ "$ZOMBIE_CHECK" = "" ]
then
    echo "no zombie process on system at this time"
else
    echo "current system zombie process"
    ps -al | awk '{print $2,$4}' | grep Z
fi
#restore file descriptor & mail report
exec 1>&3    #restore output to STDOUT
$MAIL -a $REPORT -s "System statistics report for $DATE"
-- $MAIL_TO < /dev/null
#clean up
rm -f $REPORT
