#!/bin/bash
for Name in `cat /scripts/all_client_ip.txt |grep -v ^# | awk '{print $2}'`
do
HostName=`cat /scripts/all_client_ip.txt |grep   $Name | awk '{print $8}'`
cobbler system remove --name=$HostName &&\
cobbler profile remove --name=$HostName
done
rm -f /var/lib/cobbler/kickstarts/*24k.com.ks
cobbler sync
