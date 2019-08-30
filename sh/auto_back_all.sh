#!/bin/bash
#注意脚本执行日期的时间点周日的话需要减一天date +%F-%w -d ”1day“
if [ $(date +%w) -eq 6 ]
	then
	Time="week_$(date +%F-%w -d "-1day")"
else
	Time=$(date +%F -d "-1day")
fi
############### 所有备份文件 均不带 / 根目录 并且 是 以根目录为起点的相对路径
############### 基础配置文件 通用####################
BAS=' var/spool/cron/root scripts/ etc/rc.local  etc/rc.d/rc.local   etc/salt/minion etc/zabbix/zabbix_agentd.conf  etc/ntp.conf  '
############### haproxy 数据文件 配置文件############
HAP=' etc/haproxy/haproxy.cfg etc/profile etc/sysconfig/keepalived etc/init.d/haproxy  etc/init.d/keepalived '
############### 负载均衡 nginx 配置文件 数据文件 
LBN=' usr/local/nginx/sbin/nginx   etc/init.d/keepalived  usr/local/nginx/conf/   '
############### mycat 读写分离数据库 备份文件########
MCT=' usr/local/mycat/conf/  '
############### web 层 备份 数据目录 容器环境########
WEB=' software/ home/hjkj/apps/ '
############### Zookeeper redis #####################
ZKPRDS=' usr/local/zookeeper/conf/ home/zookeeper/  usr/local/redis/redis_cluster/ usr/local/redis/data/  '
############### mysql data###########################
MSQ=' etc/my.cnf  home/mydata/data/ home/mydata/log-bin/ home/mydata/relay-bin/ etc/init.d/mysqld '
############### fastdfs #############################
FDS=' etc/fdfs/ home/fastdfs/tracker/  '
############### zabbix  #############################
ZBX=' etc/zabbix/ var/lib/mysql/zabbix/ var/lib/mysql/jumpserver/ etc/my.cnf home/jumpserver/jumpserver-master/jumpserver.conf  '
############### cobbler #############################
CBL=' etc/cobbler/ etc/httpd/ etc/cobbler/   etc/salt/  server/jumpserver-master/jumpserver.conf  '
#####################################################
BackPath=/backup
#####################################################
#out/in net ip
Ip=`/sbin/ifconfig eth0 |/bin/grep 192.168.6 |/bin/awk -F'[ :]+' '{print $4}'`
#####################################################
MAC=`/sbin/ifconfig eth0| /bin/grep HWaddr|/bin/awk '{print $5}'`
BAK=`/bin/cat /scripts/all_client_ip.txt |/bin/grep $MAC |/bin/awk '{print $13}'`
case $BAK in
HAP)
BAK=" $HAP "
;;
LBN)
BAK=" $LBN  "
;;
MCT)
BAK=" $MCT "
;;
WEB)
BAK=" $WEB "
;;
ZKPRDS)
BAK=" $ZKPRDS "
;;
MSQ)
BAK=" $MSQ "
;;
FDS)
BAK=" $FDS "
;;
ZBX)
BAK=" $ZBX "
;;
CBL)
BAK=" $CBL "
;;
*)
BAK=''
;;
esac
#mkdir
cd / 
###########注意是切换到 了 / 根目录##################
[ ! -d /$BackPath/${Ip} ] && /bin/mkdir -p /$BackPath/${Ip}
#####################################################
# backuhp conf iptables rc.local rsyncd.conf exports 
/bin/tar zcfh $BackPath/${Ip}/backup_$Time.tar.gz  $BAS  $BAK
/usr/bin/md5sum  $BackPath/${Ip}/backup_$Time.tar.gz >$BackPath/${Ip}/flag_$Time.log &&\
/usr/bin/rsync -az $BackPath/ rsync_backup@backup-02-6z04.24k.com::backup/ --password-file=/etc/rsync.password &&\
/usr/bin/rsync -az $BackPath/ rsync_backup@backup-01-6z02.24k.com::backup/ --password-file=/etc/rsync.password &&\
/bin/find $BackPath/ -type f -mtime +7 \( -name "*.log" -o -name "*.tar.gz" \) |xargs /bin/rm2 -f 
