#!/bin/bash
#!/bin/sh


#程序目的：检测网络中主机的状态；若网络不正常则触发短信告警或相应其他操作
#编写时间：2015-11-12  
#部署策略：部署于网络中目标主机，每分钟执行


#系统要求，需要nc-1.80以上版本支持
#需要将nc配置在环境变量中
#目录需要执行者拥有读写和执行权限


########部署策略###########################
#1、部署修改参数workPath参数为当前脚本部署路径
#2、部署将当前环境的文件network_info.txt
#   文件格式为主机描述，ip地址，端口1，端口2
#   例如：localhost,10.87.13.46,8080,80
#3、设置定时任务为每分钟执行一次
###########################################
workPath=/home/monitor/telnet
smsNum=$workPath/sms_phone_number
tempFile=$workPath/tempFile
networkInfo=$workPath/network-info.txt
time=`date +%Y.%m.%d_%H:%M:%S` 


. /etc/profile
#模块：发送错误短信提醒
#@参数(parm):发送的消息内容
send_msg()
{
#PHONE=/home/monitor/sms_phone_number
PHONE=/home/monitor/lion.sms
       for number in `cat $PHONE`
               do
               java -cp /home/monitor/com.jar:/home/monitor SendShortMsg $number $1
               done
}


#模块，探测ICMP ping包是否能到达目的主机
#@参数(parm):@1,被探测主机的IP地址
#@返回值(return): 网络完全不通：返回0
#网络完全正常：返回1
#网络出现丢包：返回2
ifPingIsOk()
{
#执行ping命令，保存到目录里的临时文件
ipAdd=$1
ping -c 5 $ipAdd >  $tempFile


#读tmp文件,如果ping的结果没有ttl值即可判断网络状态不通
cat $tempFile | grep "ttl=[0-9]\+" > /dev/null
tmpSeg=$?
#if ! cat $tempFile | grep "ttl=[0-9]\+" 
if [ ! $tmpSeg -eq 0 ]
then
result=0
else
#读tmp文件,若结果出现的收到回包的比例不是100%，则可判断网络丢包
lossPak=`grep loss $tempFile | awk -F% '{print $1}' | grep -o .$`
if [ $lossPak -eq 0 ]
then
result=1
else
result=2
fi
fi
return $result
}


#####################以下部分为程序的主要部分############################
fileLine=`cat $networkInfo | wc -l`

#每行读取网络信息文件
for((i=1;i<=$fileLine;i++))
do

#取出每行的内容，按逗号分割
#第一个字段是主机信息
#第二个字段是ip地址
#第三个字段到最后的字段均为主机的端口号
segmentCount=`sed -n ${i}p $networkInfo | awk -v RS=',' 'END {print --NR}'`




#取出每一行中的主机信息
hostname=`sed -n ${i}p $networkInfo | awk -F, '{print $1}'`
#取出每一行中的主机IP地址
ip=`sed -n ${i}p $networkInfo | awk -F, '{print $2}'`


if [ segmentCount -eq 1 ]
then 
ifPingIsOk $ip
if [ $? -eq 1 ]
then
msgIP="$time OK: $hostname $ip is alive."
echo $msgIP
elif [ $? -eq 0 ]
then 
msgIP="$time CRASH: $hostname $ip is dead. Network down."
echo $msgIP
elif [ $? -eq 2 ]
then
msgIP="$time CRASH: $hostname $ip is not stable. Network lack of package."
echo $msgIP
fi

else 
#按每行中主机含端口数开始循环
#序列：1、先判断主机的各项应用端口是否打开正常
   正常：返回echo信息并结束
   异常：2、判断主机的IP是否网络正常：
      正常：返回错误信息网络正常，应用端口失败；应用故障
      断网：返回错误信息网络断网，优先处理网络故障
      丢包：返回错误信息网络丢包，造成应用端口失败；需要同时监控网络和应用
      
for((j=3;j<=$segmentCount+1;j++))
do
port=`sed -n ${i}p $networkInfo | awk -F, '{print $'$j'}'`


#瑞士军刀网络监控命令，该命令针对网络的IP和端口进行嗅探
  nc -z -w2 $ip $port > /dev/null
ncEcho=$?
  if [ $ncEcho -eq 0 ]
  then
  #若端口正常，说明应用层端口存在
  echo "$time OK: $hostname $ip port $port is alive."
  else
  ifPingIsOk $ip
  if [ $? -eq 0 ]
  then
  #若网络未收到回包，说明网络故障
  #send_msg为发送告警短信模块
  msgIP="$time CRASH:$hostname $ip is dead. Network dead!"
  echo $msgIP
  #send_msg msgIP
  elif [ $? -eq 1 ]
  then
  
  #若网络正常，说明应用守护进程故障
  #send_msg为发送告警短信模块
  msgIP="$time PORT CRASH:$hostname $ip is alive. but port $port is dead"
  echo $msgIP
  #send_msg msgIP
  elif [ $? -eq 2 ]
  then
  
  #若网络有丢包现象，网络故障，需要同时保修网络和监控应用
  #send_msg为发送告警短信模块
  msgIP="$time ERROR:$hostname $ip is lack of package. Network error! port $port is dead"
  echo $msgIP
#Send_msg msgIP
  else
  #send_msg msgIP
echo helo
  fi
  fi
       done
 fi

done
