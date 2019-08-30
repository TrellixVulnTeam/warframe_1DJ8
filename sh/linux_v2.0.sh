#!/bin/bash
#  centos 6,7 和 ubuntu 通用检测脚本
# fs.file-max 最大文件打开数
# fs.file-nr 系统设置:文件打开数峰值   空闲文件打开数     最大文件打开数
# kernel.hostname 主机名
# kernel.pid_max  进程pid的最大值
# kernel.version  内核版本
# kernel.threads-max  进程最大值
# fs.nr_open  进程能同时打开的文件句柄数

#命令列表
cmdlist=(
"/usr/bin/ps"
"/usr/sbin/ip"
"/usr/bin/grep"
"/usr/sbin/sysctl"
"/usr/bin/uname"
"/usr/bin/cat"
"/usr/bin/awk"
"/usr/bin/crontab"
"/usr/bin/systemctl"
"/usr/bin/cat"
"/usr/bin/netstat"
"/usr/bin/rpm"
"/usr/bin/lsattr"
"/usr/bin/chattr"
"/usr/bin/su"
"/usr/bin/sudo"
"/usr/bin/login"
"/usr/bin/passwd"
"/usr/sbin/iptables-save"
"/usr/bin/firewall-cmd"
"/usr/sbin/sestatus"
"/usr/sbin/ifconfig"
"/usr/sbin/chkconfig"
);

#路径列表
pathlist=(
"/etc/passwd"
"/etc/shadow"
"/etc/group"
"/etc/crontab"
"/etc/profile"
"/etc/sudoers"
"/etc/sysctl.conf"
"/etc/ssh/sshd_config"
"/etc/rsyslog.conf"
"/etc/resolv.conf"
"/etc/rsyncd.conf"
"/etc/rc.d/rc.local"
"/etc/nsswitch.conf"
"/etc/ld.so.conf"
"/etc/ld.so.conf.d"
"/etc/inittab"
"/etc/hosts.deny"
"/etc/hosts.allow"
"/etc/hosts"
"/etc/fstab"
"/etc/bashrc"
"/etc/dnsmasq.conf"
"/etc/default/grub"
"/etc/grub.d"
)

OSTYPE=`uname -n`

#检查命令的路径是否正确
if [ -x "/usr/bin/which" -a `which which` == "/usr/bin/which" ]
then
	echo "command which [OK]"
else
	echo "command which is `which which`[ERR]"
	exit
fi

if [ `which basename` == "/usr/bin/basename" ]
then
	echo "command basename is [OK]"
fi

for cmd in ${cmdlist[@]}
do
	cmdname=`basename $cmd`
	if [ "`which $cmdname`" == $cmd ]
	then
		echo "command $cmdname [OK]"
	else
		echo "command $cmdname is `which $cmdname`[ERR]"
	fi
done

echo "[>]path permission:"
for fpath in ${pathlist[@]}
do
	ls -al $fpath
done

#获取系统版本信息
echo "[>]system version:"
uname -a

#ip addr
echo "[>]IP ADDR:"
ip addr|grep inet|awk -F " " '{print $2}'

#获取系统变量配置
echo "[>]system variables:"
sysctl -a |grep -E "fs.file-max|fs.file-nr|kernel.hostname|kernel.pid_max|kernel.version|kernel.threads-max|fs.nr_open"

#获取资源限制配置
echo "[>]resource limits:"
cat /etc/security/limits.conf|grep -v "^\s*#"|grep -v "^$"

#获取账号列表
echo "[>]account list:"
cat /etc/passwd|grep -v "^\s*#"|grep -v "^$"|grep -v "/sbin/nologin\|/usr/bin/false"
#可登录账号列表
accountlist=`cat /etc/passwd|grep -v "^\s*#"|grep -v "^$"|grep -v  "/sbin/nologin\|/usr/bin/false"|awk -F ":" '{print $1}'`

#检查账号锁定情况
#检查密码加密算法
#检查空密码
#检查密码最大使用时间
echo "[>]account actual setting:"
for account in ${accountlist[@]}
do
	cat /etc/shadow|grep $account|awk -F ":" \
	'{
		if($2 == "*"){
			print $1" is Locked"
		}else if($2 ~ /^\$1\$/){
			print $1" password encrypt is md5[ERR]"
		}else if($2 == "!!"){
			print $1" password is empty or expired[ERR]"
		}
	};{
		if($5 >= 90 || $5 == 0){
			print $1" password expired is over 90 days[ERR]"
		}
	}'
done

echo "[>]account profile setting:"
for account in ${accountlist[@]}
do
	accounthome=`cat /etc/passwd|grep "^"$account|awk -F ":" '{print $6}'`
	echo $accounthome
	if [[ $accounthome != "" ]]
	then
		fpath="$accounthome/.bash_profile"
		if [ -e $fpath ]
		then
			echo "[>]bash profile > $fpath:"
			cat $fpath
		fi
		fpath="$accounthome/.bashrc"
		if [ -e $fpath ]
		then
			echo "[>]bash profile > $fpath:"
			cat $fpath
		fi
		fpath="$accounthome/.bash_logout"
		if [ -e $fpath ]
		then
			echo "[>]bash profile > $fpath:"
			cat $fpath
		fi
	fi
done


#检查sudo用户
echo "[>]sudo config:"
cat /etc/sudoers|grep -v "^\s*#"|grep -v "^$"

#检查定时计划
#里面的脚本需要关注读取、写入、执行权限
for account in ${accountlist[@]}
do
	echo "[>]crontab for $account:"
	crontab -u $account -l
done

cronlist=(
"/etc/crontab"
"/etc/cron.d"
"/etc/cron.daily"
"/etc/cron.deny"
"/etc/cron.hourly"
"/etc/cron.monthly"
"/etc/cron.weekly"
)
for cronitem in ${cronlist[@]}
do
	for item in `find  $cronitem -type f`
	do
		echo "[>]crontab file > $item:"
		cat $item
	done
done


#密码策略
echo "[>]password complex police:"
if [ $OSTYPE == "Ubuntu" ]
then
	cat /etc/pam.d/common-password|grep -v "^\s*#"|grep -v "^$"
else
	cat /etc/pam.d/password-auth-ac|grep -v "^\s*#"|grep -v "^$"
fi

#账号登录策略
echo "[>]system auth police:"
if [ $OSTYPE == "Ubuntu" ]
then
	cat /etc/pam.d/common-auth|grep -v "^\s*#"|grep -v "^$"
else 
	cat /etc/pam.d/system-auth-ac|grep -v "^\s*#"|grep -v "^$"
fi

#console登录策略
echo "[>]console login police:"
cat /etc/pam.d/login|grep -v "^\s*#"|grep -v "^$"


#ssh登录策略
echo "[>]sshd login police:"
cat /etc/pam.d/sshd|grep -v "^\s*#"|grep -v "^$"


#密码过期配置
echo "[>]password expired setting:"
cat /etc/login.defs|grep -v "^\s*#"|grep -v "^$"

#全局用户变量配置
echo "[>]bash global profile[/etc/profile]:"
cat /etc/profile|grep -v "^\s*#"|grep -v "^$"

echo "[>]bash global profile[/etc/bashrc]:"
cat /etc/bashrc|grep -v "^\s*#"|grep -v "^$"

#检查日志
if [ -e "/etc/rsyslog.conf" ]
then
	echo "[>]rsyslog config:"
	cat /etc/rsyslog.conf|grep -v "^\s*#"|grep -v "^$"
else
	echo "[>]syslog config:"
	cat /etc/syslog.conf|grep -v "^\s*#"|grep -v "^$"
fi

#检查审计
echo "[>]audit config:"
cat /etc/audit/auditd.conf|grep -v "^\s*#"|grep -v "^$"

#检查审计设置
echo "[>]audit rules:"
cat /etc/audit/audit.rules|grep -v "^\s*#"|grep -v "^$"

#检查host文件
echo "[>]hosts config:"
cat /etc/hosts|grep -v "^\s*#"|grep -v "^$"

#检查hosts.allow文件
echo "[>]hosts allow setting:"
cat /etc/hosts.allow|grep -v "^\s*#"|grep -v "^$"

#检查hosts.deny
echo "[>]hosts deny setting:"
cat /etc/hosts.deny|grep -v "^\s*#"|grep -v "^$"

#检查DNS设置
echo "[>]dns setting:"
cat /etc/resolv.conf|grep -v "^\s*#"|grep -v "^$"

#检查服务启动项
echo "[>]services:"
if [[ `which systemctl` != "" ]]
then 
	systemctl list-unit-files --type=service|grep -v "disabled$"
elif [[ `which chkconfig` != "" ]]
then
	chkconfig --list
elif [ $OSTYPE == "Ubuntu"  ]
then
	service --status-all 
fi

#检查启动项
echo "[>]startup items:"
cat /etc/rc.local|grep -v "^\s*#"|grep -v "^$"


#检查进程
echo "[>]running process:"
ps -ef

#检查网络连接
echo "[>]network connections:"
netstat -anlp

#检查安装的rpm
echo "[>]install packages:"
if [ `which rpm` != "" ]
then
	rpm -qa
else
	dpkg -l
fi

#检查文件完整性工具
echo "[>]file integrity:"
if [[ `which aide` != "" ]]
then
	echo "use aide"
	if [ `which aide` == "/usr/sbin/aide" -a -f /etc/aide.conf ]
	then
		cat /etc/aide.conf|grep -v "^\s*#"|grep -v "^$"
	else
		echo "aide config file is not default"
	fi
fi 

if [[ `which tripwire` != "" ]]
then
	echo "use tripwire"
fi

#检查SSH配置
echo "[>]ssh config:"
cat /etc/ssh/sshd_config |grep -v "^\s*#"|grep -v "^$"

#检查inittab
echo "[>]inittab check:"
cat /etc/inittab|grep -v "^\s*#"|grep -v "^$"


#检查防火墙配置
echo "[>]firewall setting:"
if [[ `which firewall-cmd` != "" ]]
then
	firewall-cmd --list-all
elif [[ `which iptables-save` != "" ]]
then
	iptables-save
elif [ $OSTYPE == "Ubuntu"  ]
then
	ufw status  verbose
fi



#检查特殊权限的文件
echo "[>]file special priv:"
find /  -path /proc -prune -o -type f \( -perm  -4000 -o -perm -2000 \) -print|xargs ls -l

#查找登录失败记录
echo "[>]user login fail log:"
find /var/log/secure -type f|xargs grep -i -E "(login|sshd).+(unknown|fail|invalid)"

#selinux状态
echo "[>]selinux status:"
sestatus -b -v
