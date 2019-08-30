#!/bin/bash
function installvm(){
        NetWorkIp=$1
        sruuid=`xe sr-list |grep -v Local storage 1 |grep -C 1 "Local"|head -3|grep uuid|awk -F': ' '{print $2}'`
        #初始化一个空的VM
        File=/scripts/all_client_ip.txt
        VmName=`hostname`
        #VmName=`hostname |awk -F - '{print $2}'`
        XVmHostnm=`cat $File|grep -i $VmName | grep $NetWorkIp| awk '{print $4}'`
        XVmCpu=`cat $File|grep -i $VmName | grep $NetWorkIp| awk '{print $5}'`
        XVmMem1=`cat $File|grep -i $VmName | grep $NetWorkIp| awk '{print $6}'`
        #XVmMem1==`cat all_client_ip.txt|grep -i fw01 | grep 192.168.6.111|awk '{print  $6}'`
        XVmHard=`cat $File|grep -i $VmName | grep $NetWorkIp| awk '{print $7}'`
        XVmName=`cat $File|grep -i $VmName | grep $NetWorkIp| awk '{print $8}'`
        XVmMac1=`cat $File|grep -i $VmName | grep $NetWorkIp| awk '{print $9}'`
        XVmMac2=`cat $File|grep -i $VmName | grep $NetWorkIp| awk '{print $10}'`
        XVmMac3=`cat $File|grep -i $VmName | grep $NetWorkIp| awk '{print $11}'`
        XVmMac4=`cat $File|grep -i $VmName | grep $NetWorkIp| awk '{print $12}'`
        uuid=`xe vm-install new-name-label=$XVmHostnm sr-uuid=$sruuid template=Other\ install\ media`
        #KsName=`echo $XVmName` 
        #KsName=`echo $XVmName|awk -F_ '{print $3}'`
        #设置VM的CPU，内存
        xe vm-param-set VCPUs-max=$XVmCpu uuid=$uuid
        xe vm-param-set VCPUs-at-startup=$XVmCpu uuid=$uuid
        let  XVmMem2=$XVmMem1*1024*1024*1024
        xe vm-param-set         memory-static-max=$XVmMem2 uuid=$uuid
        xe vm-param-set         memory-dynamic-max=$XVmMem2 uuid=$uuid
        xe vm-param-set         memory-dynamic-min=$XVmMem2 uuid=$uuid
        xe vm-param-set         memory-static-min=$XVmMem2 uuid=$uuid
        #xe vm-param-set memory-dynamic-max=906MiB uuid=$uuid
        #xe vm-param-set memory-static-max=1024MiB uuid=$uuid
        #xe vm-param-set memory-dynamic-min=812MiB uuid=$uuid
        #xe vm-param-set memory-static-min=512MiB uuid=$uuid

        #为自动化安装VM设置bootloader，httprepo，kickstart
        xe vm-param-set HVM-boot-policy="BIOS\ order" uuid=$uuid
        xe vm-param-set HVM-boot-params:order="cnd" uuid=$uuid
        #xe vm-param-set PV-bootloader="eliloader" uuid=$uuid
        #xe vm-param-set other-config:install-repository="http://192.168.6.11/cobbler/ks_mirror/centos6.9-x86-64/" uuid=$uuid
        #xe vm-param-set PV-args="ip=$NetWorkIp netmask=255.255.255.0 gateway=192.168.6.1 dns=114.114.114.114  ks=http://192.168.6.192/cobbler/$XVmName.24k.com.ks ksdevice=eth0" uuid=$uuid

        #为VM添加一块虚拟硬盘
        xe vm-disk-add uuid=$uuid sr-uuid=$sruuid device=0 disk-size=${XVmHard}GiB

        #设置虚拟硬盘为bootable
        uuid1=`xe vbd-list vm-uuid=$uuid userdevice=0 params=uuid --minimal`

        xe vbd-param-set bootable=true uuid=$uuid1

        #为VM创建网络
        Networkid1=`xe network-list bridge=xenbr0 --minimal`
        Networkid2=`xe network-list bridge=xenbr1 --minimal`
        Networkid3=`xe network-list bridge=xenbr2 --minimal`
        Networkid4=`xe network-list bridge=xenbr3 --minimal`
        Networkuuid1=`xe vif-create vm-uuid=$uuid network-uuid=$Networkid1 mac=${XVmMac1} device=0`
        Networkuuid2=`xe vif-create vm-uuid=$uuid network-uuid=$Networkid2 mac=${XVmMac2} device=1`
        Networkuuid3=`xe vif-create vm-uuid=$uuid network-uuid=$Networkid3 mac=${XVmMac3} device=2`
        Networkuuid4=`xe vif-create vm-uuid=$uuid network-uuid=$Networkid4 mac=${XVmMac4} device=3`
        #启动VM，接下来，VM将自动化安装好所有的基础软件包，并启动SSH服务
        xe vm-start uuid=$uuid
echo " $uuid $VmName $$NetWorkIp $XVmHostnm $XVmCpu $XVmMem1  $XVmMem2 $XVmHard $XVmName $sruuid $uuid $XVmMac1 $XVmMac2 $XVmMac3 $XVmMac4 $Networkid1 $Networkid2 $Networkid3 $Networkid4 $Networkuuid1 $Networkuuid2 $Networkuuid3 $Networkuuid4" >/scripts/info/$XVmHostnm.info
}
Hoost=`hostname`
for Iiip in `cat /scripts/all_client_ip.txt | grep -i $Hoost |grep -v ^# |awk  '{print $3}'`
do
installvm $Iiip
sleep 10
done