a=`ip a |grep 192.168|awk -F'[ /]+' '{print $3}'`
b=`cat /scripts/all_client_ip.txt |grep $a|awk '{print $8}'`
sed -i "s/$HOSTNAME/$b/" /etc/sysconfig/network
hostname $b
hostname
cat /etc/sysconfig/network
