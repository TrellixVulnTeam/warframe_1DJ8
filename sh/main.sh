#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
. /etc/init.d/functions
######################################################################
#锁文件
LOCK_FILE="auto_install.lock"
LOCK_DIR="/var/lock/auto_install"
#日志文件
LOG_DIR="/var/log"
LOG_FILE="auto_install.log"
# 同步时间
function sync_date(){
    md5sum_check /etc/localtime  /usr/share/zoneinfo/Asia/Shanghai
    if [ ! "$?" -eq "0" ];then
        rm -f /etc/localtime >/dev/null 2>&1
        ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime >/dev/null 2>&1
        Msg "timezone Shanghai completed ! " >/dev/null 2>&1
    else
            log_info "timezone Shanghai completed ! (old)"  >/dev/null 2>&1
    fi
    if [ $(rpm -qa ntp |wc -l) -eq 0 ] ;then
        /usr/bin/yum -y install ntp >/dev/null 2>&1
        Msg "ntp installed completed ! "  >/dev/null 2>&1
    else 
        log_info "ntp installed  ! " >/dev/null 2>&1
    fi
    ntpdate  0.cn.pool.ntp.org >/dev/null 2>&1
    clear
}
# 判断是否可以上网####################################################
function test_ping(){
    if [ ! -f /etc/selinux/_test_ping ];then
        ping -c 2 baidu.com >/dev/null
        if [ $? -eq 0 ];then
            echo  "1" >/etc/selinux/_test_ping
        else
            Msg "networking  not  configured- exiting"
            shell_unlock
            exit 1
        fi
    fi
}
function get_clients_ip(){
    https://download.24k.com/software/all_client_ip.txt
    local _hosts_file=all_client_ip.txt.$(date +%F)
    local _conf_url="https://download.24k.com/software/"
    download_conf ${_hosts_file} all_client_ip.txt
    check_file ${_hosts_file} ${DIR}/all_client_ip.txt
}
# Lock################################################################
function shell_lock(){
    check_folder ${LOCK_DIR}  >/dev/null 2>&1
    touch ${LOCK_DIR}/${LOCK_FILE}
}
# 查看是否上锁########################################################
function check_lock(){
    if [ -f "${LOCK_DIR}/${LOCK_FILE}" ];then
        echo " error !  this scripts is  running"
        kill -9 $ROTATE_PID
        exit 1
    fi
}
# unlock##############################################################
function  shell_unlock(){
    rm -f ${LOCK_DIR}/${LOCK_FILE}
    echo '' >> /dev/null
}
# 记录日志############################################################
function log(){
    datetime=`date +"%F %H:%M:%S"`
    message=$1
    if [ -z "$2" ];then
        loglevel="INFO"
    else
        loglevel=$2
    fi
    outdir="${LOG_DIR}"
    if [ ! -d "$outdir" ]; then
        mkdir "$outdir"
    fi
    logname="${LOG_FILE}"
    echo "$datetime [$0] [$(pwd)][$loglevel] :: $message" | tee -a "$outdir/$logname"
}
function log_error(){
        log "$1" "ERROR"
}
function log_info(){
        log "$1" "INFO"
}
function lv_se(){
    local F1=$1
    echo "\[\e[32;1m\]$F1\[\e[0m\]"
}
function Msg(){
    if [ $? -eq 0 ];then
        log_info "$1"
    else
        log_error "$1"
    fi
}
##### Close SElinux 关闭SElinux ##################################### 
function selinux(){
    if [ ! -f /etc/selinux/_check_selinux ];then
        if [ "`grep 'SELINUX=disabled' /etc/selinux/config |wc -l `" -eq 0 ];then
            sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
            setenforce 0 >>/dev/null 2>&1
            echo "1" > /etc/selinux/_check_selinux
            Msg "Close SElinux"
        fi
    else
        log_info " selinux is disabled "
    fi
}
#关闭防火墙##########################################################
function close_iptables(){
    /etc/init.d/iptables stop >>/dev/null
    chkconfig iptables off >>/dev/null
}
##### Hide Version 擦除登陆提示信息系统版本信息######################
function HideVersion(){
    [ -f "/etc/issue" ] && > /etc/issue
    [ -f "/etc/issue.net" ] && >/etc/issue.net
    Msg "Hide sys Version info"
}
##### Safe sshd   优化 sshd 服务#####################################
function Safesshd(){
    sshd_file=/etc/sshd/sshd_config
    if [ `grep "52112" $sshd_file|wc -l` -eq 0 ];then
        sed -ir "13 iPort 52112\nPermitRootLogin on\nPermitEmptyPasswords no\nUseDNS no\nGSSAPIAuthenticaton no" $sshd_file
        sed -i 's/#ListenAddress 0.0.0.0/ListenAddress '${IP}':52112/g' $sshd_file
    /etc/init.d/sshd restart >/dev/null 2>&1
    Msg "sshd config"
    fi
}
##### Open file   修改文件描述符65534 ###############################
function Openfile(){
    if [ `cat /etc/security/limits.conf|grep 65535|grep -v grep |wc -l ` -lt 1 ];then
        /bin/cp /etc/security/limits.conf  /etc/security/limits.conf.$(date +%U%T)
        sed -i '/#\ End\ of\ file/ i\*\t\t-\tnofile\t\t65535' /etc/security/limits.conf
    fi
    ulimit -HSn 65535
    Msg "open file........ok"
}
##### hosts        同步hosts 文件 主机名#############################
function hosts(){
    local _hosts_file=hosts.$(date +%F)
    local _conf_url="https://download.24k.com/scripts/"
    download_conf ${_hosts_file} hosts
    check_file /tmp/${_hosts_file} /etc/hosts
}
##### 开机启动项精简 ################################################
function boot(){
    if [ ! -f /etc/selinux/_check_boot ];then
        export LANG=en
        for i in `chkconfig --list |grep 3:on|awk '{print $1}'`;do chkconfig  $i off ;done
            for i in  crond ntpd network rsyslog sshd;do chkconfig  $i on ;done
        Msg "BOOT config"
        echo "1" >/etc/selinux/_check_boot
    else
        Msg "boot  is  configed"
    fi
}
##### 定时同步时间  #################################################
function time_ntp(){
    if [ `grep $DateSeverIp /var/spool/cron/root|grep -v grep |wc -l ` -lt 1 ];then
        echo "*/5 * * * * root /usr/sbin/ntpdate $DateSeverIp >/dev/null 2>&1 " >> /var/spool/cron/root
    fi
    Msg "crontab time config"
}
#####进度
function rotate(){
 INTERVAL=0.5
 RCOUNT="0"
 echo -n '脚本初始化中（ scripts initialization）.........'
 while :
 do
     ((RCOUNT = RCOUNT + 1))
     case $RCOUNT in
         1)echo -e '-\b\c'
             sleep $INTERVAL
             ;;
         2)echo -e '\\\b\c'
             sleep $INTERVAL
             ;;
         3)echo -e '|\b\c'
             sleep $INTERVAL
             ;;
         4)echo -e '/\b\c'
             sleep $INTERVAL
             ;;
         *) RCOUNT=0
             ;;
     esac
 done
}
##### 修改 命令行颜色################################################
 #echo 'export PS1='\[\e[32;1m\][\u@\h\[\e[0m\]\[\e[31m\]:$PWD]# >\[\e[0m\]'' >>/root/.bashrc
 #echo 'export PS1='\[\e[32;1m\][\u@\h\[\e[0m\]\[\e[31m\]:$PWD]$ >\[\e[0m\]'' >>/~/.bashrc
 # function use_age2(){
 #     if [ $# -ne 2 ]
 #     then
 #         echo "$0 '$1' '$2' "
 #         shell_unlock
 #         exit 1
 #     fi
# }
function get_base_path(){
 #获取相对路径/get path
 SOURCE="$0"
 while [ -h "$SOURCE"  ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /*  ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
 done
 DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"
}
# 路径 path 软件名 software name#####################################
# 基础信息
function base_info(){
 #eth0 网卡ip/ eth0 ip
 Eth0_Ip=`/sbin/ifconfig eth0 |awk -F"[ :]+" 'NR==2{print $4}'`
 #内网时间服务器 ip /local time server ip
 DateSeverIp=`cat  ${DIR}/all_client_ip.txt|grep zabbix |awk -F"[\t ]+" '{print $3}'`
 #本机所需软件分类/local  class
 BAK=`/bin/cat ${DIR}/all_client_ip.txt |/bin/grep ${Eth0_Ip} |/bin/awk '{print $13}'`
 #软件下载路径 / download software path 
 Software_Path="/software"
 #软件解压地址/software untar path
 Tar_Path="/usr/src"
 bakIP="192.168.6.129"
 #mysqlbasedir 
 Datalocation="/home/mydata"
 #DBpassword root
 DBrootpwd="hjzx.24k.1234566"
 #缺省值为空
 # Install time state
 StartDate=''
 #############
 StartDateSecond=''
 # PHP disable fileinfo
 PHPDisable=''
 # Software Version
 Nginx_Version='nginx-1.9.15'  
 #nginx-1.9.15.tar.gz
 Openssl_Version='openssl-1.0.2l'
 #openssl-1.0.2l.tar.gz 
 MariaDB_Version='mariadb-10.1.13'
 #mariadb-10.1.13.tar.gz 
 Gcc_Version='gcc-5.2.0'
 #gcc-5.2.0.tar.bz2
 Redis_Version='redis-3.0.7'
 #redis-3.0.7.tar.gz
 Zookeeper_Version='zookeeper-3.4.8'
 #zookeeper-3.4.8.tar.gz
 Tomcat_Version='apache-tomcat-9.0.0.M20'
 #apache-tomcat-9.0.0.M20.tar.gz
 Haproxy_Version='haproxy-1.6.5'
 #haproxy-1.6.5.tar.gz
 JDK_Version='jdk-8u45-linux-x64'
 #jdk-8u45-linux-x64.tar.gz
 Ruby_Version='ruby-2.3.5'
 #ruby-2.3.5.tar.gz
 Keepalived_Version='keepalived-1.2.20'
 #keepalived-1.2.20.tar.gz
 Mycat_Version='Mycat-server-1.5.1-RELEASE-20160509173344-linux'
 #Mycat-server-1.5.1-RELEASE-20160509173344-linux.tar.gz
 Fastdfs_Version='fastdfs-5.11'
 #fastdfs-5.11.tar.gz
 Fastdfs_nginx_module_master_Version='fastdfs-nginx-module-master'
 #fastdfs-nginx-module-master.zip
 Nginx2_Version='nginx-1.10.1'
 #nginx-1.10.1.tar.gz
 Libfastcommon_Version='libfastcommon-1.0.36'
 #libfastcommon-1.0.36.tar.gz
 Dockerimages_Version='tomcat9-mini01'
 #tomcat9-mini01.tar
 Jumpserver_Version='jumpserver-master'
 #jumpserver-master.zip
 Ttf_Version='ttf-arphic-ukai_0.2.20080216.1.orig'
 #ttf-arphic-ukai_0.2.20080216.1.orig.tar.gz
 #3.6貌似是
 Mpfr_Version='mpfr-2.4.2'
 #mpfr-2.4.2.tar.bz2
 Gmp_Version='gmp-4.3.2'
 #gmp-4.3.2.tar.bz2
 Mpc_Version='mpc-0.8.1'
 #mpc-0.8.1.tar.gz
 Isl_Version='isl-0.14'
 #isl-0.14.tar.bz2 
 #jumpserver-master.zip
 #re2cVersion='re2c-0.13.6'
 #pcreVersion='pcre-8.37'
 #libeditVersion='libedit-20150325-3.1'
 #imapVersion='imap-2007f'
 # Current folder
 # 现在的目录路径
 cur_dir=`pwd`
 # CPU Number
 # CPU核数 4
 Cpunum=`cat /proc/cpuinfo | grep 'processor' | wc -l`
}
# Get public IP
# # 取外网ip 忽略 内网 10. 127.0   192.168 172.1 ####################
function getIP(){
    IP=`ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\." | head -n 1`
    if [[ "$IP" = "" ]]; then
        IP=`wget -qO- -t1 -T2 ipv4.icanhazip.com`
    fi
}
# is 64bit or not
# # 判断是否为 64位
function is_64bit(){
    if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
        return 0
    else
        return 1
    fi        
}
# Get version
# # 取 精确 linux 版本 6.9
function getversion(){
    if [[ -s /etc/redhat-release ]];then
        grep -oE  "[0-9.]+" /etc/redhat-release
    else    
        grep -oE  "[0-9.]+" /etc/issue
    fi    
}
# CentOS version
function centosversion(){
    local code=$1
    local version="`getversion`"
    #取 version 小数点之前的数  6.9 → 6
    local main_ver=${version%%.*}
    if [ $main_ver == $code ];then
        return 0
    else
        return 1
    fi        
}
# Make sure only root can run our script
# # 判断是否为root用户执行该脚本
function rootness(){
    if [[ $EUID -ne 0 ]]; then
       log_error "Error:This script must be run as root!" 1>&2
       kill -9 $ROTATE_PID
       exit 1
    fi
}
# check file md5#检查两个文件是否内容一致
function md5sum_check(){
    local Frist=$1
    local Sencond=$2
    local Mrist=$(/usr/bin/md5sum $1|awk '{print $1}')
    local Srist=$(/usr/bin/md5sum $2|awk '{print $1}')
    if [ $Mrist == $Srist ];then 
	   return 0
    else 
	   return 1
    fi
}
# check soft download or un tar
function check_soft(){
    local file=$1
    local soft=`cat ${DIR}/$(basename $0) |grep $file|grep '#'|awk -F"#" '{print $2}'`
    if [ ! -d "${Tar_Path}/$file" ];then
        log_error "${Tar_Path}/$file not  found!!!........."
        check_folder ${Software_Path}
        cd ${Software_Path}
        download_file $soft
        untar_file $soft
    else
        log_info "${Tar_Path}/$file  [found]"
    fi
}
# 解压文件到指定的目录
function untar_file(){
    local UNtarfile=$1
        tar xf ${UNtarfile} -C  ${Tar_Path}/ >/dev/null 2>&1
        if [ "$?" -eq 0 ] ;then
            Msg "tar  ${UNtarfile} -C ${Tar_Path}/  ........."
        else
            Msg "tar  ${UNtarfile} -C ${Tar_Path}/ error !!!!!"
        fi
}
# 检查目录是否存在，不存在就创建
function check_folder(){
    local folder=$1
    if [ ! -d $folder ] ;then 
        mkdir -p $folder
        Msg "$folder had been make"
    else
        log_info "$folder Already exists "
    fi
}
# 检查 链接文件是否存在
function check_link(){
    local Link_file1=$1
    local Link_file2=$2
    if [ ! -L "${Link_file2}" ] ;then
        ln -s  ${Link_file1}  ${Link_file2}
    fi
}
# 检查对比文件内容是否一致
function check_file(){
    local Test_file_dow=$1
    local Test_file_local=$2
    if [ -f "${Test_file_local}" ];then
        md5sum_check  ${Test_file_dow}  ${Test_file_local}
        if [ ! $? -eq 0 ];then
            mv ${Test_file_local}{,.bak.$(date +%F)}
            mv ${Test_file_dow}  ${Test_file_local}
        fi
    else
        mv ${Test_file_dow}  ${Test_file_local}
    fi
}
# Check system infomation
# 获取系统信息
function check_sys(){
    #是否 为红帽系linux 
    [[ ! -f /etc/redhat-release ]] && Msg 'Error: This script not support your OS, please change to CentOS/RedHat/Fedora and retry!' && exit 1
    #CPU型号 速率 Intel(R) Xeon(R) CPU E5-2630 v3 @ 2.40GHz
    cname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
    #CPU核数 4 
    cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
    #CPU 赫兹  2400.042
    freq=$( awk -F: '/cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
    #物理内存  7901MB
    tram=$( free -m | awk '/Mem/ {print $2}' )
    #虚拟内存  3999MB
    swap=$( free -m | awk '/Swap/ {print $2}' )
    #启动时间 14days, 19:17:55
    up=$( awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60;d=$1%60} {printf("%ddays, %d:%d:%d\n",a,b,c,d)}' /proc/uptime )
    #系统版本 CentOS 6.9
    opsy=$( awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release )
    #   系统位数 x86_64
    arch=$( uname -m )
    #系统位数  64
    lbit=$( getconf LONG_BIT )
    #系统主机名  cobbler6-9.24k.com
    host=$( hostname )
    #内核版本 2.6.32-696.el6.x86_64
    kern=$( uname -r )
    #物理内存 加 虚拟内存 总大小 7902 + 4999 = 13G
    RamSum=`expr $tram + $swap`
    if [ $RamSum -lt 480 ]; then
        log_error "Error: Not enough memory to install LAMP. The system needs memory: ${tram}MB*RAM + ${swap}MB*Swap > 480MB"
        exit 1
    fi
    [ $RamSum -lt 600 ] && PHPDisable='--disable-fileinfo';
}
# Pre-installation settings
function pre_installation_settings(){
    StartDate=$(date);
    #开始秒数
    StartDateSecond=$(date +%s);
    Msg "Start time: ${StartDate}"; 
    clear
    Msg "time sync completed "
    Msg ""
    Msg "#############################################################"
    Msg "#  Auto Install Script for CentOS / RedHat / Fedora     "
    Msg "#  Intro: http://caojie.top                                    "
    Msg "#  Author: dendi                        "
    Msg "#############################################################"
    Msg ""
    # Display System information
    # 显示系统信息
    Msg "System information is below"
    Msg ""
    Msg "CPU model            : $cname"
    Msg "Number of cores      : $cores"
    Msg "CPU frequency        : $freq MHz"
    Msg "Total amount of ram  : $tram MB"
    Msg "Total amount of swap : $swap MB"
    Msg "System uptime        : $up"
    Msg "OS                   : $opsy"
    Msg "Arch                 : $arch ($lbit Bit)"
    Msg "Kernel               : $kern"
    Msg "公网/waiwang address : $IP"
    Msg "eth0 address         : $Eth0_Ip"
    Msg "#############################################################"
    Msg " "
    Msg "wait ... to start...or Press Ctrl+C to cancel"
    #char=`get_char`
    #Remove Packages
    cd ~
}
# download Centos-Base.repo
function config_yum(){
    Repo_ali_base=CentOS-Base.repo.$(date +%F)
    Repo_ali_epel=epel.repo.$(date +%F)
    Lin_Path=/tmp
    if ! wget -O ${Lin_Path}/${Repo_ali_base} http://mirrors.aliyun.com/repo/Centos-6.repo >/dev/null 2>&1 ; then
	   log_error "please config network "
       shell_unlock
	   exit 1
    fi
    #对比本地 Centos-Base.repo 与下载的MD5值是否相等
    Yum_Path='/etc/yum.repos.d'
    Repo_Base='CentOS-Base.repo'
    Repo_epel='epel.repo'
    if [  -s ${Yum_Path}/${Repo_Base} ]; then
	   md5sum_check ${Lin_Path}/${Repo_ali_base}  ${Yum_Path}/${Repo_Base}
	   if [ $? -eq 0 ] ;then 
	       log_info "ali yum source  completed ! "
	   else 
	       mv ${Yum_Path}/${Repo_Base}{,.$(date +%F)}
	       mv ${Lin_Path}/${Repo_ali_base} ${Yum_Path}/${Repo_Base}
	   fi
    else
	   mv ${Yum_Path}/${Repo_Base}{,.$(date +%F)}
	   mv ${Lin_Path}/${Repo_ali_base} ${Yum_Path}/${Repo_Base}
        Msg "ali yum CentOS-Base.repo source  completed ! "
    fi
    if ! wget -O ${Lin_Path}/${Repo_ali_epel} http://mirrors.aliyun.com/repo/epel-6.repo >/dev/null 2>&1 ; then
	   log_error "please config network "
       shell_unlock
	   exit 1
    fi
    if [  -s ${Yum_Path}/${Repo_epel} ]; then
	   md5sum_check ${Lin_Path}/${Repo_ali_epel}  ${Yum_Path}/${Repo_epel}
	   if [ $? -eq 0 ];then
	       log_info "ali yum epel source  completed ! "
	   else
	       mv ${Yum_Path}/${Repo_epel}{,.$(date +%F)}
	       mv ${Lin_Path}/${Repo_ali_epel} ${Yum_Path}/${Repo_epel}
	   fi
    else
	   mv ${Lin_Path}/${Repo_ali_epel} ${Yum_Path}/${Repo_epel}
	   Msg "ali yum epel source  completed ! "
    fi
    Check_zabbix_rekease=`rpm -qa zabbix-release |/bin/grep zabbix-release |wc -l`
    if [ ${Check_zabbix_rekease} -eq 0 ] ;then 
	   rpm -ivh https://download.24k.com/software/zabbix-release-2.4-1.el6.noarch.rpm  >/dev/null 2>&1
	   log_info "zabbix source completed"
    else
	   if  [ ${Check_zabbix_rekease} -eq 1 ];then 
	       log_info "zabbix source completed"
	   fi
    fi
    if [ ! -f  /etc/yum.repo.d/test ];then 
        yum clean all  >/dev/null 2>&1 && echo "1" > /etc/yum.repos.d/test
        Msg "yum is  completed! "
    fi
    SOFT=""
    for soft in  zabbix-agent lrzsz dos2unix ntp gcc rsync 
    do
        if [ "`rpm -qa $soft |wc -l`"  -eq 0 ] ;then
            SOFT=" $SOFT $soft "
        fi
    done
    if [[ ! $SOFT == ""  ]] ;then 
        yum install  $SOFT  -y >/dev/null 2>&1
        Msg "$SOFT installed"
    fi
}
# Download all files# 判断软件版本
function choose_version(){
 HAP=" ${Openssl_Version}.tar.gz ${Keepalived_Version}.tar.gz ${Haproxy_Version}.tar.gz "
 LBN=" ${Openssl_Version}.tar.gz ${Keepalived_Version}.tar.gz  ${Nginx_Version}.tar.gz  ${Haproxy_Version}.tar.gz "
 ZKPRDS=" ${Redis_Version}.tar.gz ${Zookeeper_Version}.tar.gz ${JDK_Version}.tar.gz "
 WEB=" ${Dockerimages_Version}.tar "
 ZBX=" ${Jumpserver_Version}.zip  ${Ttf_Version}.tar.gz "
 MCT=" ${JDK_Version}.tar.gz ${Mycat_Version}.tar.gz "
 FDS=" ${Fastdfs_nginx_module_master_Version}.zip ${Nginx2_Version}.tar.gz ${Fastdfs_Version}.tar.gz ${Libfastcommon_Version}.tar.gz "
 MSQ=" ${Gcc_Version}.tar.bz2  ${MariaDB_Version}.tar.gz  ${Mpfr_Version}.tar.bz2  ${Gmp_Version}.tar.bz2  ${Mpc_Version}.tar.gz  ${Isl_Version}.tar.bz2 "
 case $BAK in
 HAP)
    BAK=" $HAP "
    _Modle='HAP'
 ;;
 LBN)
    BAK=" $LBN  "
    _Modle='LBN'
 ;;
 MCT)
    BAK=" $MCT "
    _Modle='MCT'
 ;;
 WEB)
    BAK=" $WEB "
    _Modle='WEB'
 ;;
 ZKPRDS)
    BAK=" $ZKPRDS "
    _Modle='ZKPRDS'
 ;;
 MSQ)
    BAK=" $MSQ "
    _Modle='MSQ'
    Ser_id=`/bin/cat ${DIR}/all_client_ip.txt |/bin/grep ${Eth0_Ip} |/bin/awk '{print $14}'`
 ;;
 FDS)
    BAK=" $FDS "
    _Modle='FDS'
 ;;
 ZBX)
    BAK=" $ZBX "
    _Modle='ZBX'
 ;;
 *)
 BAK=''
    Msg "\$BAK don't exists!"
    shell_unlock
    exit 1
 ;;
 esac
 check_folder ${Software_Path}
}
# download all file
function download_all_files(){
   [ ! -d ${Software_Path} ] && mkdir -p ${Software_Path}
   cd  ${Software_Path}
   Msg "cd  ${Software_Path} download........ "
   for i in $BAK;do  download_file $i ;done
}
# Download file
function download_file(){
    if [ -s $1 ]; then
        Msg "$1 [found]"
    else
        Msg "$1 not found!!!download now......"
    # 下载软件  地址可以修改
        if ! wget -c https://download.24k.com/software/$1 >/dev/null 2>&1;then
            Msg "Failed to download $1, please download it to "$cur_dir" directory manually and try again."
            exit 1
        fi
    fi
}
# Untar all files# 解压文件
function untar_all_files(){
    Msg "Untar all files, please wait a moment..."
    for file in `ls *.tar.gz  2>/dev/null `;
    do
    if [ ! -d "${Tar_Path}/`echo ${file} |awk -F".tar.gz" '{print $1}'`" ];then
        tar -xf ${file} -C ${Tar_Path}/ >/dev/null 2>&1
        Msg "Untar ${file} completed!"
    else
    	Msg " ${file} had been Untared!"
    fi
    done
    for files in `ls *.zip 2>/dev/null `;
    do
	if [ ! -d "${Tar_Path}/`echo ${files} |awk -F".zip" '{print $1}'`" ];then
    	unzip  $files -d  ${Tar_Path}/ >/dev/null 2>&1
    	Msg "Unzip  ${files} completed!"
    else
    	Msg " ${files} had been Untared!"
    fi
    done
    for Bz2 in `ls *.tar.bz2 2>/dev/null `;
    do
    if [ ! -d "${Tar_Path}/`echo ${Bz2} |awk -F".tar.bz2" '{print $1}'`" ];then
    	tar xf ${Bz2} -C ${Tar_Path}/ >/dev/null 2>&1
    	Msg "Untar ${Bz2} completed!"
    else
    	Msg " ${Bz2} had been Untared!"
    fi
    done
}
# Install openssl
function install_openssl(){
    check_soft ${Openssl_Version}
    if [ ! -d /usr/local/ssl/bin ];then
        #Install Apache
        Msg "Start Installing....... ${Openssl_Version}"
        cd ${Tar_Path}/${Openssl_Version}
        ./config >/dev/null 2>&1
        Msg "./config....... ${Openssl_Version}"
        ./config -t >/dev/null 2>&1
        Msg "./config -t....... ${Openssl_Version}"
        make -j $Cpunum >>/dev/null 2>&1
        Msg "make && maek install.......  ${Openssl_Version}"
        make install -j $Cpunum >>/dev/null 2>&1
        if [ $? -ne 0 ]; then
            log_error "Installing ${Openssl_Version} failed, Please contact."
            exit 1
        fi
        if [ -s "/etc/ld.so.conf.d/openssl_nginx.conf" ];then 
        	if [ "`cat /etc/ld.so.conf.d/openssl_nginx.conf |/bin/grep  /usr/local/ssl/lib |wc -l`" -eq 0 ];then
        		echo "/usr/local/ssl/lib" >> /etc/ld.so.conf.d/openssl_nginx.conf
        		ldconfig >>/dev/null
        	else
        		rm -fr /etc/ld.so.conf.d/openssl_nginx.conf
        		echo "/usr/local/ssl/lib" >> /etc/ld.so.conf.d/openssl_nginx.conf
        		ldconfig >>/dev/null
        	fi
        else
        	echo "/usr/local/ssl/lib" >> /etc/ld.so.conf.d/openssl_nginx.conf
        	ldconfig >>/dev/null
        fi
        if [ "`/bin/grep 'export OPENSSL=/usr/local/ssl/bin' /etc/profile|wc -l`" -eq 0 ];then
        	echo "export OPENSSL=/usr/local/ssl/bin" >>/etc/profile
        fi
        if [ "`/bin/grep 'export PATH=$OPENSSL:$PATH:$HOME/bin' /etc/profile|wc -l`" -eq 0 ];then
        	echo 'export PATH=$OPENSSL:$PATH:$HOME/bin' >>/etc/profile
        fi
        . /etc/profile
        Msg "${Openssl_Version} env completed!"
        ldd /usr/local/ssl/bin/openssl  >/dev/null 2>&1
        Msg "which openssl   :$(which openssl)"
        Msg "openssl version :$(openssl version)"
        yum install openssl-de* -y >/dev/null 2>&1
        Msg "${Openssl_Version} installed completed!"
    else
        Msg "${Openssl_Version} had been installed!"
    fi
    cd ~
}
# install keepalived
function install_keepalived(){
    check_soft ${Keepalived_Version}
    if [ ! -d "/usr/local/${Keepalived_Version}/etc" ];then
		Msg "Start Installing.......${Keepalived_Version}"
		cd ${Tar_Path}/${Keepalived_Version}
		./configure \
		--prefix=/usr/local/${Keepalived_Version} >/dev/null 2>&1
		Msg "./configure.........."
		make -j $Cpunum >>/dev/null 2>&1
        Msg "make && maek install.......  ${Keepalived_Version}"
        make install -j $Cpunum >>/dev/null 2>&1
        if [ $? -ne 0 ]; then
            log_error "Installing ${Keepalived_Version} failed, Please contact."
            exit 1
        fi
        check_link /usr/local/${Keepalived_Version}  /usr/local/keepalived
        check_link /usr/local/keepalived/sbin/keepalived /usr/local/bin/keepalived
        if [ -s  /etc/sysconfig/keepalived ];then
			md5sum_check /usr/local/keepalived/etc/sysconfig/keepalived /etc/sysconfig/keepalived
			if [ ! "$?" -eq 0 ];then
			mv /etc/sysconfig/keepalived{,.bak.$(date +%F)}
			cp -r /usr/local/keepalived/etc/sysconfig/keepalived /etc/sysconfig/keepalived
		fi
	    else
			cp -r /usr/local/keepalived/etc/sysconfig/keepalived /etc/sysconfig/keepalived
		fi
		if [ -s  /etc/init.d/keepalived ];then
			md5sum_check /usr/local/keepalived/etc/rc.d/init.d/keepalived /etc/init.d/keepalived
			if [ ! "$?" -eq 0 ];then
			mv /etc/init.d/keepalived{,.bak.$(date +%F)}
			cp -r /usr/local/keepalived/etc/rc.d/init.d/keepalived /etc/init.d/keepalived
            chmod +x /etc/init.d/keepalived
            fi
	    else
			cp -r /usr/local/keepalived/etc/rc.d/init.d/keepalived /etc/init.d/keepalived
            chmod +x /etc/init.d/keepalived
		fi
		chmod +x /etc/init.d/keepalived
		check_folder  /etc/keepalived
		if [ -s  /etc/keepalived/keepalived.conf ];then
			md5sum_check /usr/local/keepalived/etc/keepalived/keepalived.conf  /etc/keepalived/keepalived.conf
			if [ ! "$?" -eq 0 ];then
			mv   /etc/keepalived/keepalived.conf{,.bak}
			cp -r /usr/local/keepalived/etc/keepalived/keepalived.conf  /etc/keepalived/keepalived.conf
		fi
	    else
			cp -r /usr/local/keepalived/etc/keepalived/keepalived.conf  /etc/keepalived/keepalived.conf
		fi
		if [ "`/bin/grep '/etc/init.d/keepalived start'  /etc/rc.d/rc.local |wc -l`" -eq 0 ];then
        	echo '/etc/init.d/keepalived start' >> /etc/rc.d/rc.local
        	Msg "chkconfig keepalived on"
        fi
        log_info "${Keepalived_Version} install completed!"
    else
    	Msg "${Keepalived_Version} had been installed!"
    fi
    cd ~
}
function set_keepalived_conf(){
    local Conf_file=keepalived.conf.$(date +%F)
    if [ "`cat ${DIR}/all_client_ip.txt |grep -v '#'| grep $Eth0_Ip|awk '{print $13}'`" == "LBN" ];then
        OPP=LBN
    elif [ "`cat ${DIR}/all_client_ip.txt |grep -v '#'| grep $Eth0_Ip|awk '{print $13}'`" == "HAP" ];then
        OPP=HAP
    fi
        if ! wget -O /tmp/${Conf_file} https://download.24k.com/software/conf/keepalived/$OPP.conf >>/dev/null 2>&1;then
            Msg "keepalived.conf conf download error"
            exit 1
        fi
        if [  -f /etc/keepalived/keepalived.conf ];then 
        md5sum_check /tmp/${Conf_file} /etc/keepalived/keepalived.conf
            if [ $? -eq 0 ] ;then
                if [ "`cat ${DIR}/all_client_ip.txt |grep -v '#'| grep $Eth0_Ip|awk '{print $14}'`" -eq 1 ];then
                    log_info "keepalived.conf configuration  completed a master! "
                fi
                if [ "`cat ${DIR}/all_client_ip.txt |grep -v '#'| grep $Eth0_Ip|awk '{print $14}'`" -eq 2 ];then
                    sed -i 's/priority 100/priority 80/' /etc/keepalived/keepalived.conf 
                    sed -i 's/MASTER/BACKUP/' /etc/keepalived/keepalived.conf
                    Msg "keepalived.conf configuration  completed a backup!"
                fi
            else
                mv /etc/keepalived/keepalived.conf{,.bak.$(date +%F)}
                mv /tmp/${Conf_file} /etc/keepalived/keepalived.conf
                if [ "`cat ${DIR}/all_client_ip.txt |grep -v '#'| grep $Eth0_Ip|awk '{print $14}'`" -eq 1 ];then
                    log_info "keepalived.conf configuration  completed b  master! "
                fi
                if [ "`cat ${DIR}/all_client_ip.txt |grep -v '#'| grep $Eth0_Ip|awk '{print $14}'`" -eq 2 ];then
                    sed -i 's/priority 100/priority 80/' /etc/keepalived/keepalived.conf 
                    sed -i 's/MASTER/BACKUP/' /etc/keepalived/keepalived.conf
                    Msg "keepalived.conf configuration  completed b  backup!"
                fi
            fi
        else
            mv /etc/keepalived/keepalived.conf{,.bak.$(date +%F)}
            mv /tmp/${Conf_file} /etc/keepalived/keepalived.conf
            if [ "`cat ${DIR}/all_client_ip.txt |grep -v '#'| grep $Eth0_Ip|awk '{print $14}'`" -eq 1 ];then
                log_info "keepalived.conf configuration  completed c  master! "
            fi
            if [ "`cat ${DIR}/all_client_ip.txt |grep -v '#'| grep $Eth0_Ip|awk '{print $14}'`" -eq 2 ];then
                sed -i 's/priority 100/priority 80/' /etc/keepalived/keepalived.conf 
                sed -i 's/MASTER/BACKUP/' /etc/keepalived/keepalived.conf
                Msg "keepalived.conf configuration  completed c  backup!"
            fi
        fi
        /etc/init.d/keepalived restart
        Msg "keepalived.conf configuration completed!"
        cd ~
}
# install haproxy
function install_haproxy(){
    check_soft ${Haproxy_Version}
        if [ ! -d "/usr/local/${Haproxy_Version}/sbin" ];then
            Msg "Start Installing.......${Haproxy_Version}"
            cd ${Tar_Path}/${Haproxy_Version}
            make target=linux`uname -r |awk -F'[.-]'  '{print $1$2$3}'` \
            CPU=`uname -m` PREFIX=/usr/local/${Haproxy_Version} install >/dev/null 2>&1
            Msg "make && maek install.......  ${Haproxy_Version}"
            if [ $? -ne 0 ]; then
                Msg "Installing ${Haproxy_Version} failed, Please contact."
                exit 1
            fi
            check_link  /usr/local/${Haproxy_Version}  /usr/local/haproxy
            check_link  /usr/local/haproxy/sbin/haproxy /usr/sbin/haproxy
            if [ -f  /etc/init.d/haproxy ];then
                md5sum_check /usr/src/${Haproxy_Version}/examples/haproxy.init  /etc/init.d/haproxy
                if [ ! "$?" -eq 0 ];then
                    mv /etc/haproxy/haproxy.cfg{,.bak.$(date +%F)}
                    cp -r /usr/src/${Haproxy_Version}/examples/haproxy.init  /etc/init.d/haproxy
                    chmod +x /etc/init.d/haproxy
                fi
            else
                cp -r /usr/src/${Haproxy_Version}/examples/haproxy.init  /etc/init.d/haproxy
                chmod +x /etc/init.d/haproxy
            fi
            check_folder  /etc/haproxy
            if [ -f  /etc/haproxy/errorfiles ];then
                md5sum_check /usr/src/${Haproxy_Version}/examples/errorfiles /etc/haproxy/errorfiles
                if [ ! "$?" -eq 0 ];then
                    mv   /etc/haproxy/errorfiles{,.bak.$(date +%F)}
                    cp -r /usr/src/${Haproxy_Version}/examples/errorfiles /etc/haproxy/errorfiles
                fi
            else
                cp -r /usr/src/${Haproxy_Version}/examples/errorfiles /etc/haproxy/errorfiles
            fi
            chmod +x /etc/init.d/haproxy
            if [ -f  /etc/haproxy/haproxy.cfg ];then
                md5sum_check /usr/src/${Haproxy_Version}/examples/option-http_proxy.cfg /etc/haproxy/haproxy.cfg
                if [ ! "$?" -eq 0 ];then
                    mv /etc/haproxy/haproxy.cfg{,.bak.$(date +%F)}
                    cp -r /usr/src/${Haproxy_Version}/examples/option-http_proxy.cfg /etc/haproxy/haproxy.cfg
                fi
            else
                cp -r /usr/src/${Haproxy_Version}/examples/option-http_proxy.cfg /etc/haproxy/haproxy.cfg
            fi
            if [ "`/bin/grep '/etc/init.d/haproxy start'  /etc/rc.d/rc.local |wc -l`" -eq 0 ];then
        	   echo '/etc/init.d/haproxy start' >> /etc/rc.d/rc.local
        	   Msg "chkconfig haproxy on "
            fi
            if [ ! "`/bin/grep 'net.ipv4.ip_forward\ =\ 1'  /etc/sysctl.conf |wc -l`" -eq 1 ];then
                sed -i 's/net.ipv4.ip_forward\ =\ 0/net.ipv4.ip_forward\ =\ 1/' /etc/sysctl.conf &&sysctl -p  >/dev/null 2>&1
            Msg "net.ipv4.ip_forward = 1"
            fi
            log_info "${Haproxy_Version} install completed!"
        else
    	   Msg "${Haproxy_Version} had been installed!"
        fi
        cd ~
}
# set keepalived conf
function set_haproxy_conf(){
    local HConf_file=haproxy.cfg.$(date +%F)
    if ! wget -O /tmp/${HConf_file} https://download.24k.com/software/conf/haproxy/haproxy.cfg >>/dev/null 2>&1;then
            Msg "haproxy.conf conf download error"
            exit 1
    fi
    check_file /tmp/${HConf_file} /etc/haproxy/haproxy.cfg
    /etc/init.d/haproxy restart >/dev/null 2>&1
    Msg "haproxy.cfg   configuration completed!"
    cd ~
}
# install gcc-5.0
function install_gcc(){
        check_soft ${Gcc_Version}
        check_soft ${Mpfr_Version}
        check_soft ${Gmp_Version}
        check_soft ${Mpc_Version}
        check_soft ${Isl_Version}
		if [ ! -d "/usr/local/${Gcc_Version}/bin" ];then
			Msg "Start Installing.......${Gcc_Version}"
            cd ${Tar_Path}/${Gcc_Version}
            mv ${Tar_Path}/${Mpfr_Version}  . &&\
            ln -sf ${Mpfr_Version} mpfr
            mv ${Tar_Path}/${Gmp_Version}  . &&\
            ln -sf ${Gmp_Version} gmp
            mv ${Tar_Path}/${Mpc_Version}  . &&\
            ln -sf ${Mpc_Version} mpc
            mv ${Tar_Path}/${Isl_Version}  . &&\
            ln -sf ${Isl_Version} isl
			yum install -y  gcc-c++  glibc-static gcc >>/dev/null 2>&1
			./configure \
			--prefix=/usr/local/gcc-5.2.0  \
			--enable-bootstrap  \
			--enable-checking=release \
			--enable-languages=c,c++ \
			--disable-multilib  >/dev/null 2>&1
			Msg "./configure.........."
			make -j $Cpunum >>/dev/null 2>&1
        	Msg "make && maek install.......  ${Gcc_Version}"
        	make install -j $Cpunum >>/dev/null 2>&1
        	if [ $? -ne 0 ]; then
            	Msg "Installing ${Gcc_Version} failed, Please contact."
            	exit 1
        	fi
        	if [ ! -L "/usr/local/gcc" ] ;then
        		ln -s /usr/local/${Gcc_Version}  /usr/local/gcc
        	fi
        	if [ "`/bin/grep 'export PATH=/usr/local/gcc/bin:$PATH' /etc/profile|wc -l`" -eq 0 ];then
        		echo "export PATH=/usr/local/gcc/bin:\$PATH" >> /etc/profile
        	fi
        	. /etc/profile
        	Msg "gcc version    : $(gcc --version |grep gcc)"
        	if [ ! -L "/usr/include/gcc" ] ;then
        		ln -s /usr/local/gcc/include/ /usr/include/gcc
        	fi
        	if [ -f "/etc/ld.so.conf.d/gcc.conf" ];then 
        		if [ "`cat /etc/ld.so.conf.d/gcc.conf |/bin/grep  /usr/local/gcc/lib64 |wc -l`" -eq 0 ];then
        			echo "/usr/local/gcc/lib64" >> /etc/ld.so.conf.d/gcc.conf
        		else
        			rm -fr /etc/ld.so.conf.d/gcc.conf
        			echo "/usr/local/gcc/lib64" >> /etc/ld.so.conf.d/gcc.conf
        		fi
        	else
        		echo "/usr/local/gcc/lib64" >> /etc/ld.so.conf.d/gcc.conf
        	fi
        	if [ -f  /usr/local/gcc/lib64/libstdc++.so.6.0.21-gdb.py ];then
        		rm -f /usr/local/gcc/lib64/libstdc++.so.6.0.21-gdb.py
        	fi
        	ldconfig >>/dev/null
        	log_info "${Gcc_Version} install completed!"
        else
    	   Msg "${Gcc_Version} had been installed!"
        fi
        cd ~
}
# quc install gcc
function quc_install_gcc(){
 if [ ! -d "${Tar_Path}/${Gcc_Version}" ];then
        check_folder ${Software_Path}
        cd ${Software_Path}
        if [ -s ${Gcc_Version}.tar ]; then
            Msg "${Gcc_Version}.tar [found]"
        else
            Msg "${Gcc_Version}.tar not found!!!download now......"
            if ! wget -c http://$bakIP/software/${Gcc_Version}.tar >/dev/null 2>&1;then
                Msg "Failed to download ${Gcc_Version}.tar, please download it to "$cur_dir" directory manually and try again."
                exit 1
            fi
        fi
        tar xf ${Gcc_Version}.tar -C  ${Tar_Path}/ >/dev/null 2>&1
        fi
        if [ ! -d "/usr/local/${Gcc_Version}/bin" ];then
            Msg "Start Installing.......${Gcc_Version}"
            cd ${Tar_Path}/${Gcc_Version}
            yum install -y  gcc-c++  glibc-static gcc >>/dev/null 2>&1
            Msg "make && maek install.......  ${Gcc_Version}"
            make install -j $Cpunum >>/dev/null 2>&1
            if [ $? -ne 0 ]; then
                Msg "Installing ${Gcc_Version} failed, Please contact."
                exit 1
            fi
            if [ ! -L "/usr/local/gcc" ] ;then
                ln -s /usr/local/${Gcc_Version}  /usr/local/gcc
            fi
            if [ "`/bin/grep 'export PATH=/usr/local/gcc/bin:$PATH' /etc/profile|wc -l`" -eq 0 ];then
                echo "export PATH=/usr/local/gcc/bin:\$PATH" >> /etc/profile
            fi
            . /etc/profile
            Msg "gcc version    : $(gcc --version |grep gcc)"
            if [ ! -L "/usr/include/gcc" ] ;then
                ln -s /usr/local/gcc/include/ /usr/include/gcc
            fi
            if [ -f "/etc/ld.so.conf.d/gcc.conf" ];then 
                if [ "`cat /etc/ld.so.conf.d/gcc.conf |/bin/grep  /usr/local/gcc/lib64 |wc -l`" -eq 0 ];then
                    echo "/usr/local/gcc/lib64" >> /etc/ld.so.conf.d/gcc.conf
                else
                    rm -fr /etc/ld.so.conf.d/gcc.conf
                    echo "/usr/local/gcc/lib64" >> /etc/ld.so.conf.d/gcc.conf
                fi
            else
                echo "/usr/local/gcc/lib64" >> /etc/ld.so.conf.d/gcc.conf
            fi
            if [ -f  /usr/local/gcc/lib64/libstdc++.so.6.0.21-gdb.py ];then
                rm -f /usr/local/gcc/lib64/libstdc++.so.6.0.21-gdb.py
            fi
            ldconfig >>/dev/null
            log_info "${Gcc_Version} install completed!"
        else
           Msg "${Gcc_Version} had been installed!"
        fi
}
# install nginx 
function install_nginx(){
    check_soft ${Nginx_Version}
    if [ ! -d "/usr/local/${Nginx_Version}/sbin" ];then
        Msg "Start Installing.......${Nginx_Version}"
        yum install  pcre pcre-devel  zlib-devel  -y  >/dev/null 2>&1
        cd ${Tar_Path}/${Nginx_Version}
        if [ ! "`/usr/bin/id nginx >/dev/null 2>&1 ;echo $?`" -eq 0 ] ;then 
            useradd -r -d /dev/null -s /sbin/nologin nginx >/dev/null 2>&1
            Msg "useradd nginx..."
        else
            log_error "user nginx had been exist..."
        fi
		./configure  \
		--prefix=/usr/local/${Nginx_Version} \
		--with-http_ssl_module \
		--user=nginx \
		--group=nginx \
		--with-openssl=/usr/src/${Openssl_Version} \
		--with-http_flv_module \
		--with-http_stub_status_module \
		--with-http_gzip_static_module \
		--with-pcre \
		--with-http_realip_module >/dev/null 2>&1
		  Msg "./configure.........."
            make -j $Cpunum >>/dev/null 2>&1
            Msg "make && maek install.......  ${Nginx_Version}"
            make install -j $Cpunum >>/dev/null 2>&1
            if [ $? -ne 0 ]; then
                Msg "Installing ${Nginx_Version} failed, Please contact."
                exit 1
            fi
            if [ ! -L "/usr/local/nginx" ] ;then
        	   ln -s /usr/local/nginx-1.9.15  /usr/local/nginx
            fi
            if [ ! -L "/usr/sbin/nginx" ] ;then
                ln -s  /usr/local/nginx/sbin/nginx  /usr/sbin/nginx
            fi
            bin_grep "/usr/local/nginx/sbin/nginx" "/etc/rc.d/rc.local"
            bin_grep "/usr/local/nginx/sbin/nginx" "/etc/rc.local"
            log_info "${Nginx_Version} install completed && start!"
        else
            Msg "${Nginx_Version} had been installed!"
        fi
        cd ~
}
# Set configuration file(just new)
function set_nginx_conf(){
        Conf_file=conf.tar.$(date +%F)
        if ! wget -O /tmp/${Conf_file} https://download.24k.com/software/conf/nginx/conf.tar >>/dev/null 2>&1;then
            Msg "nginx cong download error"
            exit 1
        fi
        cp -pr /usr/local/nginx/conf /usr/local/nginx/conf.bak.$(date +%F)
        rm -fr /usr/local/nginx/conf
        tar xf /tmp/${Conf_file} -C /usr/local/nginx/
        check_folder  /usr/local/nginx/scrkey/24k.com
        cd  /usr/local/nginx/scrkey/
        if ! wget -c https://download.24k.com/software/conf/nginx/scrkey/24k.tar  >>/dev/null 2>&1 ;then 
            Msg "nginx ssl download error"
            exit 1
        fi
        tar xf  24k.tar >>/dev/null 2>&1
        /usr/local/nginx/sbin/nginx
        Msg "nginx is start ..success"
        cd ~
}
# Install mariadb database
function install_mariadb(){
	check_soft ${MariaDB_Version}
    if [ ! -d "/usr/local/${MariaDB_Version}/bin" ];then
            cd ${Tar_Path}/${MariaDB_Version}
            yum install -y cmake ncurses-devel openssl-devel openssl gcc-c++ cmake libxml2 libxml2-devel ncurses  libaio-devel  >/dev/null 2>&1
            if [ ! "`/usr/bin/groups mysql >/dev/null 2>&1 ;echo $?`" -eq 0 ] ;then 
			 /usr/sbin/groupadd mysql  >/dev/null 2>&1
			 Msg "groupadd mysql..."
             else
                log_error "groups mysql had been exist..."
            fi
            if [ ! "`/usr/bin/id mysql >/dev/null 2>&1 ;echo $?`" -eq 0 ] ;then
                /usr/sbin/useradd -s /sbin/nologin -M -g mysql mysql >/dev/null 2>&1
                Msg "useradd mysql..."
            else
                    log_error "user mysql had been exist..."
            fi
            if [ ! -d ${Datalocation} ]; then
                mkdir -p ${Datalocation}
            fi
            mkdir ${Datalocation}/{data,ibdata,log-bin,pid,relay-bin,sock}
            chown -R mysql:mysql ${Datalocation}
            # Compile MariaDB
            cmake . \
         -DCMAKE_INSTALL_PREFIX=/usr/local/${MariaDB_Version} \
         -DDEFAULT_CHARSET=utf8 \
         -DMYSQL_UNIX_ADDR=${Datalocation}/mysql.sock \
         -DMYSQL_DATADIR=${Datalocation}/data/ \
         -DDEFAULT_COLLATION=utf8_general_ci \
         -DWITH_EXTRA_CHARSETS=gbk,gb2312 \
         -DENABLED_LOCAL_INFILE=ON \
         -DWITH_INNOBASE_STORAGE_ENGINE=1 \
         -DWITH_ARCHIVE_STPRAGE_ENGINE=1 \
         -DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
         -DWITH_FEDERATED_STPRAGE_ENGINE=1 \
         -DWITHOUT_EXAMPLE_STORAGE_ENGINE=1 \
         -DWITHOUT_PARTITION_STORAGE_ENGINE=1 \
         -DWITH_FAST_MUTEXES=1 \
         -DWITH_ZLIB=bundled \
         -DENABLED_LOCAL_INFILE=1 \
         -DWITH_READLINE=1 \
         -DWITH_EMBEDDED_SERVER=1 \
         -DWITH_DEBUG=0 \
         -DWITH_LOBWRAP=0 \
         -DWITH_SSL=system >/dev/null 2>&1
            Msg "Cmake.........."
            make -j $Cpunum >>/dev/null 2>&1
            Msg "make && make install ..........${MariaDB_Version}"
            make -j $Cpunum install >>/dev/null 2>&1
            if [ $? -ne 0 ]; then
                Msg "Installing ${MariaDB_Version} failed, Please check and contact."
                exit 1
            fi
            if [ ! -L "/usr/local/mysql" ] ;then
                ln -s /usr/local/${MariaDB_Version}  /usr/local/mysql
            fi
            if [ "`/bin/grep 'export PATH=/usr/local/mysql/bin:$PATH' /etc/profile|wc -l`" -eq 0 ];then
                echo 'export PATH=/usr/local/mysql/bin:$PATH' >>/etc/profile
            fi
            . /etc/profile
            if [ ! -L "/usr/local/include/mysql" ] ;then
                ln -s /usr/local/mysql/include/ /usr/local/include/mysql
            fi
            #cp -f $cur_dir/conf/my.cnf /etc/my.cnf
            # Set MariaDB configuration file
            #set_database_conf
            if [ ! -f /etc/init.d/mysqld ];then
                cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
                sed -i "s:^datadir=.*:datadir=${Datalocation}:g" /etc/init.d/mysqld
                chmod +x /etc/init.d/mysqld
            fi
            if [ "`/bin/grep '/etc/init.d/mysqld'  /etc/rc.d/rc.local |wc -l`" -eq 0 ];then
                echo '/etc/init.d/mysqld start' >> /etc/rc.d/rc.local
            fi
            if [ ! -f /etc/ld.so.conf.d/mysql.conf ];then
                echo '/usr/local/mysql/lib' >>/etc/ld.so.conf.d/mysql.conf
                echo '/usr/local/lib' >> /etc/ld.so.conf.d/mysql.conf
            else
                if [ "`/bin/grep '/usr/local/mysql/lib' /etc/ld.so.conf.d/mysql.conf |wc -l`" -eq 0 ];then
                    echo '/usr/local/mysql/lib' >>/etc/ld.so.conf.d/mysql.conf
                fi
                if [ "`/bin/grep '/usr/local/lib'  /etc/ld.so.conf.d/mysql.conf |wc -l`" -eq 0 ];then
                    echo '/usr/local/lib' >> /etc/ld.so.conf.d/mysql.conf
                fi
            fi
            rm -fr  /usr/local/gcc/lib64/libstdc++.so.6.0.21-gdb.py
            ldconfig >>/dev/null
            log_info "${MariaDB_Version} install completed!"
        else
            Msg "${MariaDB_Version} had been installed!"
        fi
        cd ~
}
function quc_install_mariadb(){
    if [ ! -d "${Tar_Path}/${MariaDB_Version}" ];then
        if [ -s ${MariaDB_Version}.tar ]; then
            Msg "${MariaDB_Version}.tar [found]"
        else
            Msg "${MariaDB_Version}.tar not found!!!download now......"
            if ! wget -c http://$bakIP/software/${MariaDB_Version}.tar >/dev/null 2>&1;then
                Msg "Failed to download ${MariaDB_Version}.tar, please download it to "$cur_dir" directory manually and try again."
                exit 1
            fi
        fi
        tar xf ${MariaDB_Version}.tar -C  ${Tar_Path}/ >/dev/null 2>&1
    fi
    if [ ! -d "/usr/local/${MariaDB_Version}/bin" ];then
            cd ${Tar_Path}/${MariaDB_Version}
            yum install -y cmake ncurses-devel openssl-devel openssl gcc-c++ cmake libxml2 libxml2-devel ncurses  libaio-devel  >/dev/null 2>&1
            if [ ! "`/usr/bin/groups mysql >/dev/null 2>&1 ;echo $?`" -eq 0 ] ;then 
             /usr/sbin/groupadd mysql  >/dev/null 2>&1
             Msg "groupadd mysql..."
             else
                log_error "groups mysql had been exist..."
            fi
            if [ ! "`/usr/bin/id mysql >/dev/null 2>&1 ;echo $?`" -eq 0 ] ;then
                /usr/sbin/useradd -s /sbin/nologin -M -g mysql mysql >/dev/null 2>&1
                Msg "useradd mysql..."
            else
                    log_error "user mysql had been exist..."
            fi
            if [ ! -d ${Datalocation} ]; then
                mkdir -p ${Datalocation}
            fi
            mkdir ${Datalocation}/{data,ibdata,log-bin,pid,relay-bin,sock}
            chown -R mysql:mysql ${Datalocation}
            # Compile MariaDB
           make -j $Cpunum install >>/dev/null 2>&1
            if [ $? -ne 0 ]; then
                Msg "quc Installing ${MariaDB_Version} failed, Please check and contact."
                exit 1
            fi
            if [ ! -L "/usr/local/mysql" ] ;then
                ln -s /usr/local/${MariaDB_Version}  /usr/local/mysql
            fi
            if [ "`/bin/grep 'export PATH=/usr/local/mysql/bin:$PATH' /etc/profile|wc -l`" -eq 0 ];then
                echo 'export PATH=/usr/local/mysql/bin:$PATH' >>/etc/profile
            fi
            . /etc/profile
            if [ ! -L "/usr/local/include/mysql" ] ;then
                ln -s /usr/local/mysql/include/ /usr/local/include/mysql
            fi
            #cp -f $cur_dir/conf/my.cnf /etc/my.cnf
            # Set MariaDB configuration file
            #set_database_conf
            if [ ! -f /etc/init.d/mysqld ];then
                cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
                sed -i "s:^datadir=.*:datadir=${Datalocation}:g" /etc/init.d/mysqld
                chmod +x /etc/init.d/mysqld
            fi
            if [ "`/bin/grep '/etc/init.d/mysqld'  /etc/rc.d/rc.local |wc -l`" -eq 0 ];then
                echo '/etc/init.d/mysqld start' >> /etc/rc.d/rc.local
            fi
            if [ ! -f /etc/ld.so.conf.d/mysql.conf ];then
                echo '/usr/local/mysql/lib' >>/etc/ld.so.conf.d/mysql.conf
                echo '/usr/local/lib' >> /etc/ld.so.conf.d/mysql.conf
            else
                if [ "`/bin/grep '/usr/local/mysql/lib' /etc/ld.so.conf.d/mysql.conf |wc -l`" -eq 0 ];then
                    echo '/usr/local/mysql/lib' >>/etc/ld.so.conf.d/mysql.conf
                fi
                if [ "`/bin/grep '/usr/local/lib'  /etc/ld.so.conf.d/mysql.conf |wc -l`" -eq 0 ];then
                    echo '/usr/local/lib' >> /etc/ld.so.conf.d/mysql.conf
                fi
            fi
            rm -fr  /usr/local/gcc/lib64/libstdc++.so.6.0.21-gdb.py
            ldconfig >>/dev/null
            log_info "${MariaDB_Version} install completed!"
        else
            Msg "${MariaDB_Version} had been installed!"
        fi
        cd ~
}
# Set mariadb configuration file
function set_mariadb_conf(){
    My_cnf=my.cnf.$(date +%F)
        if ! wget -O /tmp/${My_cnf} https://download.24k.com/software/conf/mysql/my.cnf >/dev/null 2>&1 ; then
            log_error "download my.cnf  error !"
            exit 1
        fi
        if [  -f /etc/my.cnf ];then 
        md5sum_check /tmp/${My_cnf} /etc/my.cnf
            if [ $? -eq 0 ] ;then
                sed -i "s/server-id = 1/server-id = ${Ser_id}/" /etc/my.cnf
                log_info "my.cnf configuration  completed a! "
            else
                mv /etc/my.cnf{,.bak.$(date +%F)}
                mv /tmp/${My_cnf} /etc/my.cnf
                sed -i "s/server-id = 1/server-id = ${Ser_id}/" /etc/my.cnf
                Msg "my.cnf configuration  completed d!"
            fi
        else
            mv /etc/my.cnf{,.bak.$(date +%F)}
            mv /tmp/${My_cnf} /etc/my.cnf
            sed -i "s/server-id = 1/server-id = ${Ser_id}/" /etc/my.cnf
            Msg "my.cnf configuration  completed s!"
        fi
        /usr/local/mysql/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=/usr/local/mysql --datadir=${Datalocation}/data --user=mysql >>/var/log/auto_install.log 2>&1
        /etc/init.d/mysqld start >>/dev/null 2>&1
        Msg "${MariaDB_Version} start!"
        /usr/local/mysql/bin/mysqladmin password ${DBrootpwd}
        /usr/local/mysql/bin/mysql -uroot -p${DBrootpwd} -e "drop database if exists test;"
        /usr/local/mysql/bin/mysql -uroot -p${DBrootpwd} -e "delete from mysql.user where user='';"
        /usr/local/mysql/bin/mysql -uroot -p${DBrootpwd} -e "update mysql.user set password=password('$DBrootpwd') where user='root';"
        /usr/local/mysql/bin/mysql -uroot -p${DBrootpwd} -e "delete from mysql.user where not (user='root') ;"
        /usr/local/mysql/bin/mysql -uroot -p${DBrootpwd} -e "grant all privileges on *.* to root@'192.168.6.%' identified by 'hjzx.24k.1234566';"
        /usr/local/mysql/bin/mysql -uroot -p${DBrootpwd} -e "grant replication slave on *.* to 'jack_rep'@'192.168.6.%' identified by 'hjkj.24k.com' ;"
        /usr/local/mysql/bin/mysql -uroot -p${DBrootpwd} -e "flush privileges;"
 # Stop mysqld service
        /etc/init.d/mysqld restart >>/dev/null 2>&1
        Msg "${MariaDB_Version} restart!"
        cd ~
}
# Set mariadb databases file
function set_database_conf(){
    if [ $RamSum -gt 1500 -a $RamSum -le 2500 ]; then
        sed -i 's@^key_buffer_size.*@key_buffer_size = 32M@' /etc/my.cnf
        sed -i 's@^table_open_cache.*@table_open_cache = 128@' /etc/my.cnf
        sed -i 's@^sort_buffer_size.*@sort_buffer_size = 1M@' /etc/my.cnf
        sed -i 's@^read_buffer_size.*@read_buffer_size = 512K@' /etc/my.cnf
        sed -i 's@^read_rnd_buffer_size.*@read_rnd_buffer_size = 1M@' /etc/my.cnf
        sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 16M@' /etc/my.cnf
        sed -i 's@^max_connections.*@max_connections = 512@' /etc/my.cnf
    elif [ $RamSum -gt 2500 -a $RamSum -le 3500 ]; then
        sed -i 's@^key_buffer_size.*@key_buffer_size = 64M@' /etc/my.cnf
        sed -i 's@^table_open_cache.*@table_open_cache = 256@' /etc/my.cnf
        sed -i 's@^sort_buffer_size.*@sort_buffer_size = 2M@' /etc/my.cnf
        sed -i 's@^read_buffer_size.*@read_buffer_size = 1M@' /etc/my.cnf
        sed -i 's@^read_rnd_buffer_size.*@read_rnd_buffer_size = 2M@' /etc/my.cnf
        sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 32M@' /etc/my.cnf
        sed -i 's@^max_connections.*@max_connections = 1024@' /etc/my.cnf
    elif [ $RamSum -gt 3500 ]; then
        sed -i 's@^key_buffer_size.*@key_buffer_size = 128M@' /etc/my.cnf
        sed -i 's@^table_open_cache.*@table_open_cache = 512@' /etc/my.cnf
        sed -i 's@^sort_buffer_size.*@sort_buffer_size = 4M@' /etc/my.cnf
        sed -i 's@^read_buffer_size.*@read_buffer_size = 2M@' /etc/my.cnf
        sed -i 's@^read_rnd_buffer_size.*@read_rnd_buffer_size = 4M@' /etc/my.cnf
        sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 64M@' /etc/my.cnf
        sed -i 's@^max_connections.*@max_connections = 2048@' /etc/my.cnf
    fi
    cd ~
}
# Install mysql database set_mariadb_conf install_jdk install_docker-io
function install_jdk(){
    check_soft ${JDK_Version}
    if [ ! -d /usr/local/java/bin/ ];then
        mv ${Tar_Path}/`echo ${JDK_Version}  |awk -F'[-u]' '{print $1"1."$2".0_"$3}'` /usr/local/java
        if [ "`/bin/grep 'JAVA_HOME=/usr/local/java' /etc/profile |wc -l`" -eq 0 ];then
            sed -i  '$a\ JAVA_HOME=/usr/local/java\nJRE_HOME=/usr/local/java/jre\nPATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH\nCLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib\nexport JAVA_HOME JRE_HOME PATH CLASSPATH\n'   /etc/profile
        fi
         .  /etc/profile
        Msg "${JDK_Version} Install completed!"
    else
        Msg "${JDK_Version} had been installed!"
    fi
    cd ~
}
# install zookeeper
function install_zookeeper(){
    check_soft ${Zookeeper_Version}
    if [ ! -d /usr/local/${Zookeeper_Version}/bin ];then
        mv ${Tar_Path}/${Zookeeper_Version} /usr/local/
        if [ ! -L "/usr/local/zookeeper" ] ;then
            ln -s /usr/local/${Zookeeper_Version}  /usr/local/zookeeper
        fi
        for comd in `ls /usr/local/zookeeper/bin|grep -v README.txt`;
        do 
            if [ ! -L "/usr/local/bin/${comd}" ] ;then
            ln -s /usr/local/zookeeper/bin/${comd} /usr/local/bin/${comd}
            fi
        done
        if [ "`/bin/grep '/usr/local/zookeeper/bin/zkServer.sh'  /etc/rc.d/rc.local |wc -l`" -eq 0 ];then
               echo '/usr/local/zookeeper/bin/zkServer.sh' >>/etc/rc.d/rc.local
        fi
        Msg "${Zookeeper_Version} Install completed!"
    else
        Msg "${Zookeeper_Version} had been installed!"
    fi
}
# config zookeeper conf 
function set_zookeeper_conf(){
    local Conf_file=zoo.cfg.$(date +%F)
    local Log_file=log4j.properties.$(date +%F)
    local ZKenv=zkEnv.sh.$(date +%F)
    check_folder /home/zookeeper/data
    check_folder /home/zookeeper/logs
    My_id=`cat ${DIR}/all_client_ip.txt |grep -v '#'| grep $Eth0_Ip|awk '{print $14}'`
    echo "$My_id" >/home/zookeeper/data/myid
    if ! wget -O /tmp/${Conf_file} https://download.24k.com/software/conf/zookeeper/zoo.cfg >>/dev/null 2>&1;then
        Msg "zoo.cfg conf download error"
        exit 1
    fi
    if ! wget -O /tmp/${Log_file} https://download.24k.com/software/conf/zookeeper/log4j.properties >>/dev/null 2>&1;then
        Msg "log4j.properties conf download error"
        exit 1
    fi
    if ! wget -O /tmp/${ZKenv} https://download.24k.com/software/conf/zookeeper/zkEnv.sh >>/dev/null 2>&1;then
        Msg "ZKenv conf download error"
        exit 1
    fi
    if [ -f /usr/local/zookeeper/conf/zoo.cfg ];then 
        mv /usr/local/zookeeper/conf/zoo.cfg{,.bak.$(date +%F)}
    fi
    if [ -f /usr/local/zookeeper/conf/log4j.properties ];then 
        mv /usr/local/zookeeper/conf/log4j.properties{,.bak.$(date +%F)}
    fi
    if [ -f /usr/local/zookeeper/conf/zkEnv.sh ];then 
        mv /usr/local/zookeeper/conf/zkEnv.sh{,.bak.$(date +%F)}
    fi
        mv /tmp/${Conf_file} /usr/local/zookeeper/conf/zoo.cfg
        mv /tmp/${Log_file} /usr/local/zookeeper/conf/log4j.properties
        mv /tmp/${ZKenv} /usr/local/zookeeper/bin/zkEnv.sh
        chmod +x  /usr/local/zookeeper/bin/zkEnv.sh
        /usr/local/zookeeper/bin/zkServer.sh restart >/dev/null 2>&1
        Msg "zookeeper zoo.cfg configuration completed!"
        cd ~
}
# install redis cluster
function install_redis(){
    check_soft ${Redis_Version}
    if [ ! -d /usr/local/${Redis_Version}/src ];then
        Msg "Start Installing.......${Redis_Version}"
        mv /usr/src/${Redis_Version} /usr/local/ &&\
        cd /usr/local/${Redis_Version}
        make -j $Cpunum >>/dev/null 2>&1
        Msg "make && make install ..........${Redis_Version}"
        make -j $Cpunum install >>/dev/null 2>&1
        if [ $? -ne 0 ]; then
            Msg "Installing ${Redis_Version} failed, Please check and contact."
            exit 1
        fi
        if [ ! -L "/usr/local/redis" ] ;then
                ln -s /usr/local/${Redis_Version} /usr/local/redis
        fi
        if [ ! -L "/usr/local/bin/redis-trib.rb" ] ;then
                ln -s /usr/local/redis/src/redis-trib.rb  /usr/local/bin/redis-trib.rb
        fi
        check_folder /usr/local/redis/redis_cluster
        check_folder /usr/local/redis/data
        check_folder /usr/local/redis/log
        Msg "${Redis_Version} Install completed!"
    else
        Msg "${Redis_Version} had been installed!"
    fi
}
# install ruby gem install redis
function install_ruby(){
    check_soft  ${Ruby_Version}
    if [ ! -d  /usr/local/${Ruby_Version}/bin/ ];then
        Msg "Start Installing.......${Ruby_Version}"
        cd ${Tar_Path}/${Ruby_Version}
        ./configure --prefix=/usr/local/${Ruby_Version} --disable-install-rdoc >>/dev/null 2>&1
        Msg "./configure.........."
        make -j $Cpunum >>/dev/null 2>&1
        Msg "make && maek install.......  ${Ruby_Version}"
        make install -j $Cpunum >>/dev/null 2>&1
        if [ $? -ne 0 ]; then
            log_error "Installing ${Ruby_Version} failed, Please contact."
            exit 1
        fi
        if [ ! -L "/usr/local/ruby" ] ;then
                ln -s  /usr/local/${Ruby_Version}   /usr/local/ruby
        fi
        if [ ! -L "/usr/sbin/ruby" ] ;then
                ln -s  /usr/local/ruby/bin/ruby   /usr/sbin/ruby
        fi
        if [ ! -L "/usr/sbin/gem" ] ;then
                ln -s  /usr/local/ruby/bin/gem   /usr/sbin/gem
        fi
        cd ${Tar_Path}/${Ruby_Version}/ext/zlib/ >>/dev/null 2>&1 
        yum install -y openssl-de* >>/dev/null 2>&1
        ruby ./extconf.rb  >>/dev/null 2>&1
        make  >>/dev/null 2>&1
        make install  >>/dev/null 2>&1 
        cd ${Tar_Path}/${Ruby_Version}/ext/openssl/ >>/dev/null 2>&1
        ruby ./extconf.rb >>/dev/null 2>&1 
        sed -i 's#$(top_srcdir)#../..#g'  /usr/src/${Ruby_Version}/ext/openssl/Makefile  >>/dev/null 2>&1 
        make >>/dev/null 2>&1 
        make install >>/dev/null 2>&1 
        gem sources --remove https://rubygems.org/ >>/dev/null 2>&1 
        gem sources -a https://ruby.taobao.org/ >>/dev/null 2>&1
        Msg " ${Ruby_Version} installed completed! "
        gem install redis >>/dev/null 2>&1
        Msg " gem  install redis  completed! "
    else
        Msg " ${Ruby_Version} had been installed !"
    fi
}
function config_redis_conf(){
    local POrt=$1
    check_folder /usr/local/redis/redis_cluster/${POrt}
    if [  -f "/usr/local/redis/redis_cluster/${POrt}/redis.conf" ];then
        md5sum_check /usr/local/redis/redis.conf /usr/local/redis/redis_cluster/${POrt}/redis.conf
        if [ ! "$?" -eq 0 ];then
            cp  /usr/local/redis/redis.conf /usr/local/redis/redis_cluster/${POrt}/redis.conf
        fi
    else
        cp  /usr/local/redis/redis.conf /usr/local/redis/redis_cluster/${POrt}/redis.conf
    fi
    echo \######################################1 >>/var/loa/auto_install.log 2>$1
    sed -i 's/daemonize no/daemonize yes/'  /usr/local/redis/redis_cluster/${POrt}/redis.conf
     echo \######################################2 >>/var/loa/auto_install.log 2>$1
    sed -i "s#pidfile /var/run/redis.pid#pidfile /var/run/redis_${POrt}.pid#"  /usr/local/redis/redis_cluster/${POrt}/redis.conf
    echo \######################################3 >>/var/loa/auto_install.log 2>$1
    sed -i "s/port 6379/port ${POrt}/"  /usr/local/redis/redis_cluster/${POrt}/redis.conf
    echo \######################################4 >>/var/loa/auto_install.log 2>$1
    sed -i "s/# bind 127.0.0.1/bind ${Eth0_Ip}/"  /usr/local/redis/redis_cluster/${POrt}/redis.conf
    echo \######################################5 >>/var/loa/auto_install.log 2>$1
    sed -i "s#logfile \"\"#logfile \"/usr/local/redis/log/${POrt}.log\"#"  /usr/local/redis/redis_cluster/${POrt}/redis.conf
    echo \######################################6 >>/var/loa/auto_install.log 2>$1 
    sed -i "s/dbfilename dump.rdb/dbfilename dump_${POrt}.rdb/"   /usr/local/redis/redis_cluster/${POrt}/redis.conf
    echo \######################################7 >>/var/loa/auto_install.log 2>$1
    sed -i "s#dir ./#dir /usr/local/redis/data/#"   /usr/local/redis/redis_cluster/${POrt}/redis.conf
    echo \######################################8 >>/var/loa/auto_install.log 2>$1
    sed -i 's/appendonly no/appendonly yes/'  /usr/local/redis/redis_cluster/${POrt}/redis.conf
    echo \######################################9 >>/var/loa/auto_install.log 2>$1
    sed -i "s#appendfilename \"appendonly.aof\"#appendfilename \"appendonly_6381.aof\"#"    /usr/local/redis/redis_cluster/${POrt}/redis.conf
    echo \######################################10 >>/var/loa/auto_install.log 2>$1
    sed -i 's/# cluster-enabled yes/cluster-enabled yes/'    /usr/local/redis/redis_cluster/${POrt}/redis.conf
    echo \######################################11 >>/var/loa/auto_install.log 2>$1
    sed -i "s/# cluster-config-file nodes-6379.conf/# cluster-config-file nodes-${POrt}.conf/"   /usr/local/redis/redis_cluster/${POrt}/redis.conf
    echo \######################################12 >>/var/loa/auto_install.log 2>$1
    sed -i 's/# cluster-node-timeout 15000/cluster-node-timeout 15000/'   /usr/local/redis/redis_cluster/${POrt}/redis.conf
    bin_grep  '/usr/local/bin/redis-server  /usr/local/redis/redis_cluster/${POrt}/redis.conf' /etc/rc.local
    bin_grep  '/usr/local/bin/redis-server  /usr/local/redis/redis_cluster/${POrt}/redis.conf' /etc/rc.d/rc.local
    bin_grep  'echo never > /sys/kernel/mm/transparent_hugepage/enabled' /etc/rc.local
    bin_grep  'echo never > /sys/kernel/mm/transparent_hugepage/enabled' /etc/rc.d/rc.local
    bin_grep  'echo 511 > /proc/sys/net/core/somaxconn' /etc/rc.local
    bin_grep  'echo 511 > /proc/sys/net/core/somaxconn' /etc/rc.d/rc.local
    bin_grep  'vm.overcommit_memory=1' /etc/sysctl.conf
    sysctl -p >>/var/loa/auto_install.log 2>$1
    /usr/local/bin/redis-server  /usr/local/redis/redis_cluster/${POrt}/redis.conf
}
function set_redis_conf(){
    local My_id=`cat ${DIR}/all_client_ip.txt |grep -v '#'| grep $Eth0_Ip|awk '{print $14}'`
    if [ "$My_id" -eq "1" ] ;then
        for P in 5381 5382 5383 
        do 
        config_redis_conf $P
        done
    elif [ "$My_id" -eq "2" ] ;then
        for O in 6381 6382 6383 
        do 
        config_redis_conf $O
        done
    elif [ "$My_id" -eq "3" ] ;then
        for R in 7381 7382 8383 
        do 
        config_redis_conf $R
        done
    fi
}
function set_rsync_master(){
    if [ ! "`/usr/bin/id nginx >/dev/null 2>&1 ;echo $?`" -eq 0 ] ;then 
            useradd -r -d /dev/null -s /sbin/nologin rsync >/dev/null 2>&1
            Msg "useradd rsync..."
    else
            log_error "user rsync had been exist..."
    fi
    local Conf_file=rsyncd.conf.$(date +%F)
    local  _conf_url="https://download.24k.com/software/conf/mycat/"
    download_conf ${Conf_file} rsyncd.conf
    check_file /tmp/${Conf_file} /etc/rsyncd.conf
    if [ -f /etc/rsync.password ] ;then
        echo "rsync_backup:123456" >/etc/rsync.password
    else
        echo "rsync_backup:123456" >/etc/rsync.password
    fi
    local Rs_file=rsync.$(date +%F)
    download_conf ${Rs_file} rsync
    check_file /tmp/${Rs_file} /etc/init.d/rsync
    chmod +x /etc/init.d/rsync
    chmod 600 /etc/rsync.password
    check_folder /backup
    check_folder /software
    chown -R rsync.rsync /backup
    chown -R rsync.rsync /software
    if [ "`/bin/grep "/etc/init.d/rsync start"  /etc/rc.d/rc.local |wc -l`" -eq 0 ];then
        echo '/etc/init.d/rsync start'  >>/etc/rc.d/rc.local
    fi
    if [ "`/bin/grep "/etc/init.d/rsync start"  /etc/rc.local |wc -l`" -eq 0 ];then
        echo '/etc/init.d/rsync start'  >>/etc/rc.local
    fi
    /etc/init.d/rsync restart >/dev/null 2>&1
    Msg "rsync  configuration completed!"
    cd ~
}
function bin_grep(){
    local string1=$1
    local string2=$2
    if [ "`/bin/grep "/${string1}"  ${string2} |wc -l`" -eq 0 ];then
        echo " ${string2} "  >> ${string2}
    fi
}
# install mycat
function install_mycat(){
    check_soft ${Mycat_Version}
    if [ ! -f "/usr/local/mycat/bin/" ];then
        mv $Tar_Path/mycat /usr/local/mycat
        if [ ! "`/usr/bin/id mycat >/dev/null 2>&1 ;echo $?`" -eq 0 ] ;then
            useradd mycat && echo “mycat123456” |passwd --stdin mycat >/dev/null 2>&1
            Msg "useradd mycat..."
        else
            log_error "user mycat had been exist..."
        fi
        bin_grep  '/usr/local/mycat/bin/mycat start' /etc/rc.local
        bin_grep  '/usr/local/mycat/bin/mycat start' /etc/rc.d/rc.local
    else
        Msg "${Mycat_Version} had been installed ! "
    fi
}
function set_mycat_conf(){
    local  RULE=rule.xml.$(date +%F)
    local  SCHEMA=schema.xml.$(date +%F)
    local  SERVER=server.xml.$(date +%F)
    local  WRAPPER=wrapper.conf.$(date +%F)
    local  _conf_url="https://download.24k.com/software/conf/mycat/"
    download_conf ${WRAPPER} wrapper.conf
    download_conf ${SERVER} server.xml
    download_conf ${SCHEMA} schema.xml
    download_conf ${RULE} rule.xml
    check_file  /tmp/${WRAPPER}  /usr/local/mycat/conf/wrapper.conf
    check_file  /tmp/${SERVER}  /usr/local/mycat/conf/server.xml
    check_file  /tmp/${SCHEMA}  /usr/local/mycat/conf/schema.xml
    check_file  /tmp/${RULE}    /usr/local/mycat/conf/rule.xml
}
# download cong file       ${_conf_url}      ${_conf_file1}    ${_conf_file2} 
function download_conf(){
    local _conf_file1=$1
    local _conf_file2=$2
    if ! wget -O /tmp/${_conf_file1} ${_conf_url}${_conf_file2} >>/dev/null 2>&1;then
        Msg "${_conf_file2} conf download error"
        shell_unlock
        exit 1
    fi
}
function install_libfatscommon(){
    check_soft ${Libfastcommon_Version}
    if [ ! -f  "/usr/lib64/libfastcommon.so" ];then
        cd $Tar_Path/${Libfastcommon_Version}
        sh make.sh >>/dev/null 2>&1
        sh make.sh install >>/dev/null 2>&1
        check_link  /usr/lib64/libfastcommon.so  /usr/local/lib/libfastcommon.so
        check_link  /usr/lib64/libfdfsclient.so /usr/local/lib/libfdfsclient.so
        check_link  /usr/lib64/libfdfsclient.so /usr/lib/libfdfsclient.so
        Msg "${Libfastcommon_Version}   installed  completed !  "
    else
        Msg "${Libfastcommon_Version} had been installed !"
    fi
}
function isntall_fastdfs(){
    check_soft ${Fastdfs_Version}
    if [ ! -f "/etc/init.d/fdfs_storaged" ];then
        cd ${Tar_Path}/${Fastdfs_Version}
        sh make.sh >>/dev/null 2>&1
        Msg "sh make.sh   ........   "
        sh make.sh install >>/dev/null 2>&1
        if [ -f  /etc/fdfs/tracker.conf ];then
            md5sum_check /etc/fdfs/tracker.conf.sample /etc/fdfs/tracker.conf
            if [ ! "$?" -eq 0 ];then
                mv /etc/fdfs/tracker.conf{,.bak.$(date +%F)}
                cp -r /etc/fdfs/tracker.conf.sample /etc/fdfs/tracker.conf
            fi
        else
            cp -r /etc/fdfs/tracker.conf.sample /etc/fdfs/tracker.conf
        fi
        if [ -f  /etc/fdfs/storage.conf ];then
            md5sum_check /etc/fdfs/storage.conf.sample /etc/fdfs/storage.conf
            if [ ! "$?" -eq 0 ];then
                mv /etc/fdfs/storage.conf{,.bak.$(date +%F)}
                cp -r /etc/fdfs/storage.conf.sample /etc/fdfs/storage.conf
            fi
        else
            cp -r /etc/fdfs/storage.conf.sample /etc/fdfs/storage.conf
        fi
        if [ -f  /etc/fdfs/client.conf ];then
            md5sum_check /etc/fdfs/client.conf.sample /etc/fdfs/client.conf
            if [ ! "$?" -eq 0 ];then
                mv /etc/fdfs/client.conf{,.bak.$(date +%F)}
                cp -r /etc/fdfs/client.conf.sample /etc/fdfs/client.conf
            fi
        else
            cp -r /etc/fdfs/client.conf.sample /etc/fdfs/client.conf
        fi
        Msg "${Fastdfs_Version} installed .......completed ! "
    else
        Msg "${Fastdfs_Version} had been installed !"
    fi
}
function set_fast_tarcker(){
    check_folder  /home/fastdfs/tracker
    local tracker_conf=tracker.conf.$(date +%F)
    local _conf_url="https://download.24k.com/software/conf/fastdfs/"
    download_conf ${tracker_conf} tracker.conf
    check_file  /tmp/${tracker_conf} /etc/fdfs/tracker.conf
    sed -i "s/bind_addr=/bind_addr=${Eth0_Ip}/"  /etc/fdfs/tracker.conf
    bin_grep '/etc/init.d/fdfs_trackerd start' /etc/rc.d/rc.local
    bin_grep '/etc/init.d/fdfs_trackerd start' /etc/rc.local
    /etc/init.d/fdfs_trackerd start
}
function set_fast_storage(){
    check_folder  /home/fastdfs/storage
    local storage_conf=storage.conf.$(date +%F)
    local _conf_url="https://download.24k.com/software/conf/fastdfs/"
    download_conf ${storage_conf} storage.conf
    check_file  /tmp/${storage_conf} /etc/fdfs/storage.conf
 #    sed -i "s#tore_group=group2#tore_group=v2#"  /etc/fdfs/storage.conf
    sed -i "s/bind_addr=/bind_addr=${Eth0_Ip}/"  /etc/fdfs/storage.conf
 #    sed -i "s#base_path=/home/yuqing/fastdfs#base_path=/home/fastdfs/storage#"  /etc/fdfs/storage.conf
 #    sed -i 's/store_path_count=1/store_path_count=2/' /etc/fdfs/storage.conf
 #    sed -i 's#store_path0=/home/yuqing/fastdfs#store_path0=/home/fastdfs/storage#' /etc/fdfs/storage.conf
    local fastdfs_ip1=`cat ${DIR}/all_client_ip.txt |grep -v '#'| grep fastdfs |awk '{print $3}'|head -n 1`
    local fadtdfs_ip2=`cat ${DIR}/all_client_ip.txt |grep -v '#'| grep fastdfs |awk '{print $3}'|tail -n 1`
    sed -i  "/tracker_server=192.168.209.121:22122/a\tracker_server=${fastdfs_ip1}" /etc/fdfs/storage.conf
    sed -i  "/tracker_server=192.168.209.121:22122/a\tracker_server=${fastdfs_ip2}" /etc/fdfs/storage.conf
    sed -i  "s/tracker_server=192.168.209.121:22122/#tracker_server=192.168.209.121:22122/" /etc/fdfs/storage.conf
}
function set_fast_client(){
 if [ -f  /etc/fdfs/client.conf ];then
        md5sum_check /etc/fdfs/client.conf.sample /etc/fdfs/client.conf
        if [ ! "$?" -eq 0 ];then
            mv /etc/fdfs/client.conf{,.bak.$(date +%F)}
            cp -r /etc/fdfs/client.conf.sample /etc/fdfs/client.conf
        fi
    else
        cp -r /etc/fdfs/client.conf.sample /etc/fdfs/client.conf
    fi
}
function set_ntpd_conf(){
    TEST_file=test.$(date +%F)
    if [ ! "`grep 'root /usr/sbin/ntpdate ' /var/spool/cron/root|wc -l `" -eq 0 ];then
        grep -v 'root /usr/sbin/ntpdate ' /var/spool/cron/root >>/tmp/${TEST_file}
        >/var/spool/cron/root
        cat /tmp/${TEST_file} >>/var/spool/cron/root
    fi
    Ntp_cnf=ntp.conf.$(date +%F)
    if ! wget -O /tmp/${Ntp_cnf} https://download.24k.com/software/conf/ntp/ntp.conf >/dev/null 2>&1 ; then
            log_error "download ntp.conf  error !"
            exit 1
    fi
    if [  -s /etc/ntp.conf ];then 
        md5sum_check /tmp/${Ntp_cnf} /etc/ntp.conf
            if [ $? -eq 0 ] ;then
                log_info "ntp.cnf configuration  completed a! "
            else
                mv /etc/ntp.conf{,.bak.$(date +%F)}
                mv /tmp/${Ntp_cnf} /etc/ntp.conf
                Msg "ntp.cnf configuration  completed d!"
            fi
     else
        mv /etc/ntp.conf{,.bak.$(date +%F)}
        mv /tmp/${Ntp_cnf} /etc/ntp.conf
        Msg "ntp.cnf configuration  completed s!"
     fi
     
     if [ "`/bin/grep '/etc/init.d/ntpd'  /etc/rc.d/rc.local |wc -l`" -eq 0 ];then
        echo '/etc/init.d/ntpd start' >> /etc/rc.d/rc.local
    fi
    service ntpd restart >>/dev/null 2>&1
    Msg "ntp server configuration and start  !"
    cd ~
}
function install_docker_io(){
    config_yum
    yum install -y docker-io >>/dev/null 2>&1
    Msg "install docker-io ..."
    cd ~
}
#function get_dockerfile(){
#    
#}
function auto_config_mail_yj(){
 MFile=/etc/mail.rc
 [ -f $MFile ] && cp $MFile{,.$(date +%F)}
 if [  "`grep 'set from=yj@24k.com' $MFile|wc -l `" -eq 0 ];then
        echo "set from=yj@24k.com" >>$MFile
 fi
 if [  "`grep 'set smtp="smtps://smtp.exmail.qq.com:465"' $MFile|wc -l `" -eq 0 ];then
        echo "set smtp="smtps://smtp.exmail.qq.com:465"" >>$MFile
 fi
 if [  "`grep 'set smtp-auth-user=yj@24k.com' $MFile|wc -l `" -eq 0 ];then
        echo "set smtp-auth-user=yj@24k.com" >>$MFile
 fi
 if [  "`grep 'set smtp-auth-password=Asd1234566' $MFile|wc -l `" -eq 0 ];then
        echo "set smtp-auth-password=Asd1234566" >>$MFile
 fi
 if [  "`grep 'set smtp-auth=login' $MFile|wc -l `" -eq 0 ];then
        echo "set smtp-auth=login" >>$MFile
 fi
 if [  "`grep 'set nss-config-dir=/etc/pki/nssdb' $MFile|wc -l `" -eq 0 ];then
        echo "set nss-config-dir=/etc/pki/nssdb" >>$MFile
 fi
 if [  "`grep 'set ssl-verify=ignore' $MFile|wc -l `" -eq 0 ];then
        echo "set ssl-verify=ignore" >>$MFile
 fi
 Msg "mail.rc configuration completed"
 cd ~
}
#系统初始化
function system_init(){
    check_folder /scripts
    check_folder /software
    check_folder /backup
    selinux
    close_iptables
    HideVersion
    #Safesshd
    Openfile
    hosts
    boot
    time_ntp
    config_yum
}
function install_hap(){
    install_openssl
    install_haproxy
    install_keepalived
}
function config_hap(){
    set_haproxy_conf
    set_keepalived_conf
    auto_config_mail_yj
}
function install_lbn(){
    install_openssl
    install_nginx
    install_keepalived
    auto_config_mail_yj
}
function config_lbn(){
    set_nginx_conf
    set_keepalived_conf
}
function install_msq(){
    install_gcc
    install_mariadb
    auto_config_mail_yj
}
function config_msq(){
    set_mariadb_conf
    set_database_conf
}
function install_web(){
    install_docker_io
    auto_config_mail_yj
}
########################
#function config_web(){}
function install_zk(){
    install_jdk
    install_zookeeper
    auto_config_mail_yj
}
function config_zk(){
    set_zookeeper_conf 
}
function install_rds(){
    install_redis
    install_ruby
    auto_config_mail_yj
}
function config_rds(){
    set_redis_conf
}
function quc_install_msq(){
    echo "内网网络测试，不是内网请按 Ctrl + C 退出 "
    quc_install_gcc
    quc_install_mariadb
    set_mariadb_conf
    set_database_conf
    auto_config_mail_yj
}
function auto_install(){
 # 查询安装模块
    choose_version
 # 下载模块软件
    download_all_files
 # 解压缩文件
    untar_all_files
    case ${_Modle} in
        HAP)
            install_hap
            config_hap
        ;;
        LBN)
            install_lbn
            config_lbn
        ;;
        MCT)
            install_jdk
            install_mycat
            set_mycat_conf
        ;;
        WEB)
            install_web
        ;;
        ZKPRDS)
            install_zk
            config_zk
            install_rds
            config_rds
        ;;
        MSQ)
            install_msq
            config_msq
        ;;
        FDS)
           install_libfatscommon
           isntall_fastdfs
           set_fast_tarcker
           set_fast_storage
           set_fast_client
        ;;
        ZBX)
           echo "install zbix"
        ;;
        *)
           Msg "\${_Modle} don't exists!"
           shell_unlock
           exit 1
        ;;
    esac
}
function main(){
 action=$1
 [  -z $1 ] && action="-h"
 #进度条
 rotate & 
 ROTATE_PID=$!
 trap "kill -9 ${ROTATE_PID}" INT KILL
 # root 启动
    rootness 
 # 检查锁文件
    check_lock
 # 上锁
    shell_lock
 # 同步时间
    sync_date
 # 获取所在目录
    get_base_path
 # 获取ip
    getIP
 # 基础信息
    base_info
 # 系统信息
    check_sys
 # Do the job here
 kill -9 $ROTATE_PID
 # 打印信息
 # Initialization setup
 case "$action" in
    auto)
        pre_installation_settings
        system_init
        auto_install
        ;;
    system_init)
        pre_installation_setting
        system_init
        ;;
    install_hap)
        install_hap
        ;;
    config_hap)
        config_hap
        ;;
    install_haproxy)
        install_haproxy
        ;;
    install_openssl)
        install_openssl
        ;;
    install_keepalived)
        install_openssl
        install_keepalived
        ;;
    set_keepalived_conf)
        set_keepalived_conf
        ;;
    install_lbn)
        install_lbn
        ;;
    config_lbn)
        config_lbn
        ;;
    install_nginx)
        install_openssl
        install_nginx
        ;;
    set_nginx_conf)
        set_nginx_conf
        ;;
    install_jdk)
        install_jdk
        ;;
    install_mycat)
        install_jdk
        install_mycat
        ;;
    set_mycat_conf)
        set_mycat_conf
        ;;
    install_docker_io)
        install_docker_io
        ;;
    install_zk)
        install_zk
        ;;
    config_zk)
        config_zk
        ;;
    install_redis)
        install_redis
        ;;
    set_redis_conf)
        set_redis_conf
        ;;
    install_gcc)
        install_gcc
        ;;
    install_mariadb)
        install_gcc
        install_mariadb
        ;;
    set_mariadb_conf)
        set_mariadb_conf
        set_database_conf
        ;;
    isntall_fastdfs)
        install_libfatscommon
        isntall_fastdfs
        ;;
    set_fast_tarcker)
        set_fast_tarcker
        ;;
    set_fast_tarcker)
        set_fast_tarcker
        ;;
    set_fast_client)
        set_fast_client
        ;;
    zabbix)
        echo "install zbix"
        ;;
    set_ntpd_conf)
        set_ntpd_conf
        ;;
    *)
        echo " Usage:  `basename $0`  auto"
        echo " Usage:  `basename $0`  install_hap"
        echo " Usage:  `basename $0`  config_hap"
        echo " Usage:  `basename $0`  install_haproxy"
        echo " Usage:  `basename $0`  install_openssl"
        echo " Usage:  `basename $0`  install_keepalived"
        echo " Usage:  `basename $0`  set_keepalived_conf"
        echo " Usage:  `basename $0`  install_lbn"
        echo " Usage:  `basename $0`  config_lbn"
        echo " Usage:  `basename $0`  install_nginx"
        echo " Usage:  `basename $0`  set_nginx_conf"
        echo " Usage:  `basename $0`  install_jdk"
        echo " Usage:  `basename $0`  install_mycat"
        echo " Usage:  `basename $0`  set_mycat_conf"
        echo " Usage:  `basename $0`  install_docker_io"
        echo " Usage:  `basename $0`  install_zk"
        echo " Usage:  `basename $0`  config_zk"
        echo " Usage:  `basename $0`  install_redis"
        echo " Usage:  `basename $0`  set_redis_conf"
        echo " Usage:  `basename $0`  install_gcc"
        echo " Usage:  `basename $0`  install_mariadb"
        echo " Usage:  `basename $0`  set_mariadb_conf"
        echo " Usage:  `basename $0`  isntall_fastdfs"
        echo " Usage:  `basename $0`  set_fast_tarcker"
        echo " Usage:  `basename $0`  set_fast_tarcker"
        echo " Usage:  `basename $0`  set_fast_client"
        echo " Usage:  `basename $0`  set_ntpd_conf"
        shell_unlock
        exit 1
        ;;
 esac
 shell_unlock
}
main $1 $2
