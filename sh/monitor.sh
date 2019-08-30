#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
. /etc/init.d/functions
#程序目的：检测网络中主机的状态；若网络不正常则触发短信告警或相应其他操作
#编写时间：2017-12-11
#部署策略：部署于网络中目标主机，每分钟执行
#
#系统要求，需要nc-1.80以上版本支持
#需要将nc配置在环境变量中
#目录需要执行者拥有读写和执行权限
NcTest=`rpm -qa nc|wc -l`
if [ ${NcTest} -eq 0 ]
  then
   yum install -y nc >/dev/null 2>&1
   if [ ! $? -eq 0 ]
    then
    exit
  fi
fi
LocalIp=`ip a | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" |grep -vE "127.0.0.1|*.255"|xargs echo`
########部署策略###########################
#1、部署修改参数workPath参数为当前脚本部署路径
#2、部署将当前环境的文件network_info.txt
#   文件格式为主机描述，ip地址，端口1，端口2
#   例如：localhost,10.87.13.46,8080,80
#3、设置定时任务为每分钟执行一次
###########################################
WorkPath=/root/monitor
#SmsNum=${WorkPath}/Sms_phone_number
#TempFile=${WorkPath}/TempFile
NetworkInfo=${WorkPath}/Network_Host.txt
#Time=`date +%Y.%m.%d_%H:%M:%S` 
#模块：检查目录是否存在，不存在就创建
function check_folder(){
    local folder=$1
    if [ ! -d $folder ] ;then 
        mkdir -p $folder
        echo "$folder had been make"
    else
        echo "$folder Already exists "
    fi
}
#模块：发送错误短信提醒
#@参数(parm):发送的消息内容
##function Send_Mail(){
# pkkkk=$1
#local Times=`date +%Y.%m.%d_%H:%M:%S`
# echo "告警主机：${pkkkk}
# 告警端口：$2  
# 告警时间：${Times}   "| mail -s "服务监控报警"  yj@24k.com
#}
function Send_Mail(){
 local Pkkkk=$1
 local Time=`date +%Y.%m.%d_%H:%M:%S`
 echo "${Time} ${Pkkkk}"| mail -s "服务监控报警"  yj@24k.com
# Send_Sms "${Time} ${Pkkkk}"
Send_wechat "${Time} ${Pkkkk}"
}
function Send_Sms(){
    local Number=18566662527
    local Time=`date +%Y.%m.%d_%H:%M:%S`
    local Info="$1"
    local Url="http://ws.montnets.com:7903/MWGate/wmgw.asmx/MongateCsSpSendSmsNew"
    /usr/bin/curl -d "userId=J21731&password=116123&pszMobis=${Number}&pszMsg=${Info}&iMobiCount=1&pszSubPort=\*"   ${Url}  >>/dev/null
}
function Send_wechat(){
	local Corpid="wwe0c2d77a28f790c7"
	local Corpsecret="GNx-afsJ29QQQhJL_-i1npOMm4O7CoHsgN0va0AXzW4"
	local Jna_Secret="GNx-afsJ29QQQhJL_-i1npOMm4O7CoHsgN0va0AXzW4"
	local Access_token_file="/tmp/access_token"

	local Gettoken_url="https://qyapi.weixin.qq.com/cgi-bin/gettoken"
	local Message_send_url="https://qyapi.weixin.qq.com/cgi-bin/message/send"

	if [ -f ${Access_token_file} ];then
		local	Access_token=`cat ${Access_token_file} |xargs echo |awk -F"[ ,:]"  '{print $6}'`
	else
		local Access_token=``
	fi
function Get_access_token(){
	/usr/bin/curl   ${Gettoken_url}?corpid=${Corpid}\&corpsecret=${Corpsecret} -o ${Access_token_file}
	echo `date +%s` >> ${Access_token_file}
	Access_token=`cat ${Access_token_file} |xargs echo |awk -F"[ ,:]"  '{print $6}'`
	echo ${Access_token}
}

function Check_access_token(){
	Access_token_time=`awk -F"[ ,:}]"  '{print $9}' ${Access_token_file}`
	local Now_time=`date +%s`
	if [ ${Access_token} == "" ] ;then
		Get_access_token
	fi
	if [  "${Access_token_time}"x != ""x ];then
		Check_time=$((${Now_time}-${Access_token_time}))
	fi
	if [ "${Access_token_time}"x == ""x ]; then
		Get_access_token
	fi
	if [ ! "${Check_time}"x == ""x ] ;then
		if [ ${Check_time} -ge 7200 ] ;then
			Get_access_token
		fi
	fi
}
	Check_access_token

Data="{\
\"touser\" : \"@all\",\
\"toparty\" : \"PartyID1|PartyID2\",\
\"totag\" : \"TagID1 | TagID2\",\
\"msgtype\" : \"text\",\
\"agentid\" : 1000004,\
\"text\" : {\
	\"content\" : \"$1\"},\
	\"safe\":0\
}"
	curl -H "Content-Type:application/json"  -X POST --data  "${Data}"  ${Message_send_url}?access_token=${Access_token}
}
#模块，探测ICMP ping包是否能到达目的主机
#@参数(parm):@1,被探测主机的IP地址
#@返回值(return): 
#网络完全正常：返回0
#网络完全不通：返回1
#网络出现丢包：返回2
function IfPingIsOk(){
 #执行ping命令，保存到目录里的临时文件
 local Ip=$1
 local TempFile=`mktemp ${WorkPath}/TempFile.XXXXX`
 ping -c 5 ${Ip} >  ${TempFile}
 #读tmp文件,如果ping的结果没有ttl值即可判断网络状态不通
 cat ${TempFile} | grep "ttl=[0-9]\+" > /dev/null
 local TmpSeg=$?
 #if ! cat $tempFile | grep "ttl=[0-9]\+" 
 if [ ! ${TmpSeg} -eq 0 ]
   then
   local Result=1
   else
  #读tmp文件,若结果出现的收到回包的比例不是100%，则可判断网络丢包
  LossPak=`grep loss ${TempFile} | awk -F% '{print $1}' | grep -o .$`
   if [ ${LossPak} -eq 0 ]
   then
    local Result=0
   else
    local Result=2
   fi
 fi
 rm -fr ${TempFile}
 return ${Result}
}
#模块，nc 端口探测 瑞士军刀网络监控命令，该命令针对网络的IP和端口进行嗅探
#@返回值(return): 
#端口存在：返回0
#端口故障：返回1
function ifPortIsOk(){
  local Ip=$1
  local Port=$2
  nc -z -w2 -n  ${Ip} ${Port} > /dev/null
  NcEcho=$?
  if [ ${NcEcho} -eq 0 ]
   then
   local Result=0
  else
   local Result=1
  fi
  return ${Result}
}
#####################以下部分为程序的主要部分############################

#每行读取网络信息文件
for Ip in `cat ${NetworkInfo} |grep -v ^1 | awk '{print $2}'`
do
#取出每行的内容，按逗号分割
#第一个字段是主机信息
#第二个字段是ip地址
#第三个字段到最后的字段均为主机的端口号
IfPingIsOk ${Ip}
if [ $? -eq 0 ];then
    for Port in `cat ${WorkPath}/${Ip} |awk '{print $1}'`
      do
        ifPortIsOk ${Ip} ${Port}
        if [ $?  -eq 1 ];then
          Send_Mail "CRASH: ${Ip}:${Port} is dead.from ${LocalIp} "
        fi
      done
  elif [ $? -eq 1 ];then
    Send_Mail "CRASH: ${Ip} Network down is dead from ${LocalIp}"
  elif [ $? -eq 2 ];then
    Send_Mail "CRASH: ${Ip} is not stable. Network lack of package.from ${LocalIp}"
fi
done
