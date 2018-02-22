#!/bin/bash
#Script:Allserver-Console
#Version:1.0
#Writer:Liky
#Time:2014-08-19

prod_hub='1.1.1.1'    ###这里根据自己的需要填写服务器的主机名和IP地址
prod_redis_master=''
prod_search_master=''
prod_webapp_master=''
prod_worker_master=''
prod_all_slave=''
staging_mongoDB=''
staging_redis=''
staging_webapp=''
staging_search=''
staging_worker=''
staging_hub=''
staging_slave=''

function_ssh()
{
USER=`whoami`
echo "The current user is $USER"
echo "=========================="
sleep 1
ssh $USER@$1 -p 2312
}


function_login()
{
read -p "Please Enter The Serial number:" number

case $number in
0)
exit
;;
1)
function_ssh $prod_hub
;;
2)
function_ssh $prod_redis_master
;;
3)
function_ssh $prod_search_master
;;
4)
function_ssh $prod_webapp_master
;;
5)
function_ssh $prod_worker_master
;;
6)
function_ssh $prod_all_slave
;;
7)
function_ssh $staging_hub
;;
8)
function_ssh $staging_redis
;;
9)
function_ssh $staging_search
;;
10)
function_ssh $staging_webapp
;;
11)
function_ssh $staging_worker
;;
12)
function_ssh $staging_slave
;;
13)
function_ssh $staging_mongoDB
;;
*)
echo ""
function_login
esac
}

echo "Wellcome to Allserver-Console...
=============================================
prod_hub IP地址 ==> 1
prod_redis_master IP地址  ==> 2
prod_search_master IP地址  ==> 3
prod_webapp_master IP地址  ==> 4
prod_worker_master IP地址  ==> 5
prod_all_slave IP地址  ==> 6
=============================================
staging_hub IP地址  ==> 7
staging_redis IP地址 ==> 8
staging_search IP地址 ==> 9
staging_webapp IP地址 ==> 10
staging_worker IP地址 ==> 11
staging_slave IP地址 ==> 12
staging_mongoDB IP地址 ==> 13
"

function_login