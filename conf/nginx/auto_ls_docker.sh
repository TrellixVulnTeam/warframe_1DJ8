#!/bin/bash
Ser_ip=`ip a  |grep 192.168.6|awk -F"[ /]+" '{print $3 }'`
touch /tmp/info$Ser_ip.txt
echo qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq >> /tmp/info$Ser_ip.txt
echo $(date) >> /tmp/info$Ser_ip.txt
 for i in  `ls /scripts/software/ |grep -v tomcat9-mini01.tar`
  do
  	Ser_port1=`echo $i|awk -F"-" '{print $3}'`
  	Ser_port3=`echo $i`
  	Ser_port2=`cat /scripts/software/$i/server.xml |egrep "port=\"[0-9][0-9][0-9][0-9][0-9]\""|grep Connector|awk -F\" '{print $2}'`
  for a in `ls /scripts/software/$i |grep -Ev "Dockerfile|server.xml|creatandrun.sh|buildimage.sh|imagebuild|context.xml"`
   do 
   		Ser_path1=`cat /scripts/software/$i/$a | awk -F"path=" '{print $2}'|awk -F \" '{print $2}' |grep -v ^$`
echo "$Ser_port3 $Ser_ip $a $Ser_path1  $Ser_port1 $Ser_port2"  >> /tmp/info$Ser_ip.txt
done
done

