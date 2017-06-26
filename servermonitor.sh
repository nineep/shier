
ad average,当超过规定数值时发电邮通知管理员 
  
# *** config start *** 
  
# 当前目录路径 
ROOT=$(cd "$(dirname "$0")"; pwd) 
  
# 当前服务器名 
HOST=$(hostname) 
  
# log 文件路径 
CPU_LOG="${ROOT}/logs/cpu.log"
MEM_LOG="${ROOT}/logs/mem.log"
LOAD_LOG="${ROOT}/logs/load.log"
  
# 通知电邮列表 
NOTICE_EMAIL='admin@admin.com'
  
# cpu,memory,load average 记录上一次发送通知电邮时间 
CPU_REMARK='/tmp/servermonitor_cpu.remark'
MEM_REMARK='/tmp/servermonitor_mem.remark'
LOAD_REMARK='/tmp/servermonitor_loadaverage.remark'
  
# 发通知电邮间隔时间 
REMARK_EXPIRE=3600 
NOW=$(date +%s) 
  
# *** config end *** 
  
  
# *** function start *** 
  
# 获取CPU占用 
function GetCpu() { 
  cpufree=$(vmstat 1 5 |sed -n '3,$p' |awk '{x = x + $15} END {print x/5}' |awk -F. '{print $1}') 
  cpuused=$((100 - $cpufree)) 
  echo $cpuused 
  
  local remark 
  remark=$(GetRemark ${CPU_REMARK}) 
  
# 检查CPU占用是否超过90% 
if [ "$remark" = "" ] && [ "$cpuused" -gt 90 ]; then
   echo "Subject: ${HOST} CPU uses more than 90% $(date +%Y-%m-%d' '%H:%M:%S)" | sendmail ${NOTICE_EMAIL} 
   echo "$(date +%s)" > "$CPU_REMARK"
fi
} 
  
# 获取内存使用情况 
function GetMem() { 
  mem=$(free -m | sed -n '3,3p') 
  used=$(echo $mem | awk -F ' ' '{print $3}') 
  free=$(echo $mem | awk -F ' ' '{print $4}') 
  total=$(($used + $free)) 
  limit=$(($total/10)) 
  echo "${total} ${used} ${free}"
  
  local remark 
  remark=$(GetRemark ${MEM_REMARK}) 
  
  # 检查内存占用是否超过90% 
  if [ "$remark" = "" ] && [ "$limit" -gt "$free" ]; then
    echo "Subject: ${HOST} Memory uses more than 90% $(date +%Y-%m-%d' '%H:%M:%S)" | sendmail ${NOTICE_EMAIL} 
    echo "$(date +%s)" > "$MEM_REMARK"
  fi
} 
  
# 获取load average 
function GetLoad() { 
  load=$(uptime | awk -F 'load average: ' '{print $2}') 
  m1=$(echo $load | awk -F ', ' '{print $1}') 
  m5=$(echo $load | awk -F ', ' '{print $2}') 
  m15=$(echo $load | awk -F ', ' '{print $3}') 
  echo "${m1} ${m5} ${m15}"
  
  m1u=$(echo $m1 | awk -F '.' '{print $1}') 
  
  local remark 
  remark=$(GetRemark ${LOAD_REMARK}) 
  
  # 检查是否负载是否有压力 
  if [ "$remark" = "" ] && [ "$m1u" -gt "2" ]; then
    echo "Subject: ${HOST} Load Average more than 2 $(date +%Y-%m-%d' '%H:%M:%S)" | sendmail ${NOTICE_EMAIL} 
    echo "$(date +%s)" > "$LOAD_REMARK"
  fi
} 
  
# 获取上一次发送电邮时间 
function GetRemark() { 
  local remark 
  
  if [ -f "$1" ] && [ -s "$1" ]; then
    remark=$(cat $1) 
  
    if [ $(( $NOW - $remark )) -gt "$REMARK_EXPIRE" ]; then
      rm -f $1 
      remark=""
    fi
  else
    remark=""
  fi
  
  echo $remark 
} 
  
  
# *** function end *** 
  
cpuinfo=$(GetCpu) 
meminfo=$(GetMem) 
loadinfo=$(GetLoad) 
  
echo "cpu: ${cpuinfo}" >> "${CPU_LOG}"
echo "mem: ${meminfo}" >> "${MEM_LOG}"
echo "load: ${loadinfo}" >> "${LOAD_LOG}"
  
exit 0 
