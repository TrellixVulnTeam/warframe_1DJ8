#!/bin/bash
#by : Dendy
#date 2017-10-19
#QQ : 2257752828
for Name in `cat /scripts/all_client_ip.txt |grep -v ^# | awk '{print $2}'`
do
Ip=`cat /scripts/all_client_ip.txt |grep   $Name | awk '{print $3}'`
HostName=`cat /scripts/all_client_ip.txt |grep   $Name | awk '{print $8}'`
XVmMac1=`cat /scripts/all_client_ip.txt|grep  $Name | awk '{print $9}'`
XVmMem1=`cat /scripts/all_client_ip.txt|grep  $Name | awk '{print $6}'`
#Swap=`cat /scripts/all_client_ip.txt |grep  $Name | awk  '{print $4}'`
KsPath=/var/lib/cobbler/kickstarts/
rm -f $KsPath$HostName.ks
cat >>$KsPath$HostName.ks<<EOP
install
keyboard 'us'
rootpw --iscrypted \$1$\werwqerw\$VZwu4WrGTA2f8iv1UPOIL1
url --url="http://192.168.6.11/cobbler/ks_mirror/centos6.9"
lang en_US
firewall --disabled
auth  --useshadow  --passalgo=sha512
text
firstboot --disable
selinux --disabled

network  --bootproto=static --device=eth0 --ip=$Ip --netmask=255.255.255.0 --gateway=192.168.6.1 --nameserver=114.114.114.114 --hostname=$HostName
reboot
timezone Asia/Shanghai
bootloader --location=mbr
zerombr
#autopart
clearpart --all --initlabel
part /boot --asprimary --fstype="ext4" --size=500
part swap --asprimary --fstype="swap" --size=${XVmMem1}000
part / --asprimary --fstype="ext4" --grow --size=1

%post
mkdir -p /software
wget -O /scripts/all_client_ip.txt   http://192.168.6.11/scripts/all_client_ip.txt
wget -O /etc/hosts http://192.168.6.11/scripts/hosts
wget -O /scripts/system_init.sh  http://192.168.6.11/scripts/system_init.sh
chmod 755  system_init.sh
echo "bash /scripts/system_init.sh" >> /etc/rc.local
bash /scripts/system_init.sh
%end

%packages
@base
@development
@core
@chinese-support
sysstat
ntp
dos2unix
rsync
lrzsz
%end
EOP
cobbler profile add --name=$HostName --distro=centos6.9-x86_64 --kickstart=$KsPath$HostName.ks
cobbler system add --name=$HostName --hostname=$HostName --mac=$XVmMac1 --interface=eth0 --ip-address=$Ip --subnet=255.255.255.0 --gateway=192.168.6.10 --static=1 --profile=$HostName --name-servers=114.114.114.114
done
cobbler sync
