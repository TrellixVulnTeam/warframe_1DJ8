#!/bin/bash
############################
############################
#set env
export PATH=$PATH:/bin:/sbin:/usr/sbin
############################
##just root run this script
if [[ "$(whoami)" != "root" ]];then
    echo "pls run this sript as root" >&2
    exit 1
fi
#wget -O /script/all_client_ip.txt   http://192.168.6.11/cobbler/images/centos-x86_64/all_client_ip.txt
#wget -O /etc/hosts http://192.168.6.11/cobbler/images/centos-x86_64/hosts
############################
##define cmd var 
DateSeverIp=`cat  /scripts/all_client_ip.txt|grep zabbix |awk -F"[\t ]+" '{print $3}'`
############################
##Source function library
. /etc/init.d/functions
############################
##config yum repo
#Config_yum(){
    #echo "config yum centos"
    #cd  /etc/yum.repos.d/
    #\cp CentOS-Base.repo CentOS-Base.repo.$(date +%F)
    #ping -c 2 baidu.com >/dev/null
    #[ ! $? -eq 0 ] && echo "networking  not  configured- exiting" && exit 1
    #wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo 
    #wget -O /etc/yum.repos.d/CentOS-Base.repo http://114.119.116.178:11111/scripts/CentOS-Base.repo
    #wget -O /etc/yum.repos.d/epel.repo http://114.119.116.178:11111/scripts/epel.repo
   # yum clean all&&yum list  >/dev/null 
#}
############################
##Install init Packages
InstallTool(){
    echo "sysstat ntp   rsync"
    yum -y install  sysstat ntp  epel* rsync >/dev/null &&\
    yum clean all&&yum list >/dev/null
}
############################
##zifuji
#initI18n(){
#   echo " set LANG="zh_cn.gb18030""
#   \cp /etc/sysconfig/i18n /etc/sysconfig/i18n.$(date +%F)
#   sed -i 's#LANG="en_US.UTF8"#LANG="zh_CN.gb18030"#' /etc/sysconfig/i18n
#   source /etc/sysconfig/i18n
#   grep LANG  /etc/sysconfig/i18n
#   sleep 1
#}
############################
#close selinux and iptables
InitFirewall(){
    echo "#close iptables and selinux"
    \cp /etc/selinux/config /etc/selinux/config.$(date +%F)
    /etc/init.d/iptables stop
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    setenforce 0
    chkconfig iptables off
    /etc/init.d/iptables status
  echo '#grep SELINUX=disabled /etc/selinux/config '
  grep SELINUX=disabled /etc/selinux/config
  echo '#getenforce '
  getenforce 
action "close selinux and iptables" /bin/true
sleep 1
}
#ConfigHosname(){
#\cp /etc/hosts /etc/hosts.$(date +%U%T)
#sed -i "s/$HOSTNAME/$hostNameTmp/" /etc/hosts
#\cp /etc/sysconfig/network  /etc/sysconfig/network.$(date +%U%T)
#sed -i  "s/$HOSTNAME/$hostNameTmp/" /etc/sysconfig/network
#hostname $hostNameTmp
#}
SyncSystemTime() {
    if [ `grep $DateSeverIp /var/spool/cron/root|grep -v grep |wc -l ` -lt 1 ]
        then
        echo "*/5 * * * * root /usr/sbin/ntpdate $DateSeverIp >/dev/null 2>&1 " >> /var/spool/cron/root
    fi
}
Openfile(){
    \cp /etc/security/limits.conf  /etc/security/limits.conf.$(date +%U%T)
    
    if [ `cat /etc/security/limits.conf|grep 65535|grep -v grep |wc -l ` -lt 1 ]
        then
        sed -i '/#\ End\ of\ file/ i\*\t\t-\tnofile\t\t65535' /etc/security/limits.conf
    fi
    ulimit -HSn 65535
    sleep 1
}
Initsevice(){
    for i in `chkconfig --list |grep 3:on|awk '{print $1}'`;do chkconfig  $i off ;done
    for i in  crond ntpd network rsyslog sshd;do chkconfig  $i on ;done
    sleep 1
}

Check_all(){
hostname
chkconfig --list |grep 3:on 
getenforce
grep "SELINUX="  /etc/selinux/config |tail -1
cat /etc/sysconfig/network
cat /etc/sysconfig/network-scripts/ifcfg-eth*
cat  /etc/hosts
cat /var/spool/cron/root
#etwork  --bootproto=static --device=eth0#--ip=192.168.6.99 --netmask=255.255.255.0 --gateway=192.168.6.10 --nameserver=114.114.114.114 --hostname=test.24k.com
#sed -i 's/bash\ /scripts/system_init.sh/#bash\ /scripts/system_init.sh/g' /etc/rc.local
}
#Config_yum
#InstallTool
#InitFirewall
#ConfigHosname
SyncSystemTime
#Openfile
#Initsevice
Check_all>>/tmp/init_`hostname`.info
