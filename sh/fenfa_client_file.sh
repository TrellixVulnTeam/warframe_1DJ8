#!/bin/bash
. /etc/init.d/functions
if [ $# -ne 2 ]
	then
	echo "$0 file dir"
	exit 1
fi
filename=`basename $1`
for i in  `cat  /scripts/all_client_ip.txt|grep -v ^#|awk '{print $3}'`
do
	#ip=`echo $i|awk -F@ '{print $1}'`
	ip=$i
	rsync -avzP $1 -e 'ssh -t -p 22 ' root@$ip:$2
	#ssh -t -p 22 root@$ip sudo rsync ~/$filename $2
	if [ $? -eq 0 ]
		then
		action "$ip" /bin/true
	else
		action  "$ip" /bin/false
	fi
done
