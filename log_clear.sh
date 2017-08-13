#/bin/bash

log_path="/OAFS/WEAVER/ecology/log"    #此处定义你的日志及数据文件夹路径
expried_time=7       #此处定义你的日志过期时间，如7天
function deleteLogs(){
# 获取系统时间，所有时间格式都是秒
local currentDate=`date +%s`
echo "current date: " $currentDate
for file in `find $1 -name "ecology_*.log"` #此处定义文件名格式，避免误删
do
    local name=$file
    local modifyDate=$(stat -c %Y $file)
    #对比时间，算出日志存在时间，距离最近一次修改
    local logExistTime=$(($currentDate - $modifyDate))
    logExistTime=$(($logExistTime/86400))
    if [ $logExistTime -gt $expried_time ]; then
        echo "File: " $name "Modify Date: " $modifyDate + "Exist Time: " $logExistTime + "Delete: yes"
        rm -f $file
    else
        echo "File: " $name "Modify Date: " $modifyDate + "Exist Time: " $logExistTime + "Delete: no"
    fi
done
}
deleteLogs $log_path
