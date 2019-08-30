#!/bin/bash
Ip=`/bin/cat /etc/sysconfig/network-scripts/ifcfg-eth0 |/bin/grep -i ipaddr|/bin/awk -F"=" '{print $2}'`
BackPath=/software
/usr/bin/rsync -az $BackPath/ rsync_backup@backup-02-6z04.24k.com::software/${Ip}/ --password-file=/etc/rsync.password &&\
/usr/bin/rsync -az $BackPath/ rsync_backup@backup-01-6z02.24k.com::software/${Ip}/ --password-file=/etc/rsync.password
################# web 层备份 #######################
CHECK_WEB=`/bin/echo $HOSTNAME |/bin/grep tom|/usr/bin/wc -l`
[ $CHECK_WEB -eq 1 ]&& /usr/bin/rsync -az /home/hjkj/apps/ rsync_backup@backup-02-6z04.24k.com::software/app/${Ip}/ --password-file=/etc/rsync.password &&/usr/bin/rsync -az /home/hjkj/apps/ rsync_backup@backup-01-6z02.24k.com::software/app/${Ip}/ --password-file=/etc/rsync.password
################# fastdfs 备份 #####################
CHECK_FAST=`/bin/echo $HOSTNAME |/bin/grep fastdfs|/usr/bin/wc -l`
[ $CHECK_FAST -eq 1 ]&& /usr/bin/rsync -az /home/fastdfs/ rsync_backup@backup-02-6z04.24k.com::software/fastdfs/${Ip}/ --password-file=/etc/rsync.password &&/usr/bin/rsync -az /home/fastdfs/ rsync_backup@backup-01-6z02.24k.com::software/fastdfs/${Ip}/ --password-file=/etc/rsync.password
################# mysql backup #####################
CHECK_MSQ=`/bin/echo $HOSTNAME |/bin/grep maria|/usr/bin/wc -l`
[ $CHECK_MSQ -eq 1 ]&& /usr/bin/rsync -az /home/mydata/  rsync_backup@backup-02-6z04.24k.com::software/mysql/${Ip}/ --password-file=/etc/rsync.password &&/usr/bin/rsync -az /home/mydata/ rsync_backup@backup-01-6z02.24k.com::software/mysql/${Ip}/ --password-file=/etc/rsync.password
