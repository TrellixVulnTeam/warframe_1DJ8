#!/bin/bash
#. /etc/init.d/functions
#if [ $# -ne 2 ]
#	then
#	echo "$0 file dir"
#	exit 1
#fi
#filename=`basename $1`
#for Fiip in  `cat  /scripts/all_fw_ip.txt|grep -v ^#|awk '{print $1}'`
#do
#	#ip=`echo $i|awk -F@ '{print $1}'`
#	scp /scripts/all_client_ip.txt $Fiip:/scripts/
#	scp /scripts/install_vm.sh $Fiip:/scripts/
#	if [ $? -eq 0 ]
#		then
#		action "$Fiip" /bin/true
#	else
#		action  "$Fiip" /bin/false
#	fi
#done
#!/bin/bash
if [ $# -ne 2 ]
        then
        echo "$0 file dir"
        exit 1
fi
Msg(){
        if [ $? -eq 0 ]
                then
                action "$1" /bin/true
        else
                action  "$1" /bin/false
        fi
}
. /etc/init.d/functions
scp root@192.168.6.11:$1 root@$i:$2
for i in `cat  /scripts/all_fw_ip.txt|grep -v ^#|awk '{print $1}'`
do # 50次循环，可以理解为50个主机，或其他
scp $1 root@$i:$2
Msg "scp $1 root@$i:$2"
done
