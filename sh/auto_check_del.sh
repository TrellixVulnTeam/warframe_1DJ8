#!/bin/bash
Path=/backup
if [ $(date +%w) -eq 6 ]
	then
	Time="week_$(date +%F-%w -d "-1day")"
else
	Time=$(date +%F -d "-1day")
fi
[ ! -d /tmp$Path/${Ip} ] && mkdir -p /tmp$Path/${Ip}
[ -d /tmp$Path/${Time}_result.log ] && mv /tmp$Path/${Time}_result.log{,.$(date +%F)}
find $Path/ -type f -name "*${Time}*.log" | xargs  md5sum -c     >>/tmp$Path/${Time}_result.log 2>&1
cat   /tmp$Path/${Time}_result.log |sort |cat -n|mail -s "$Time back resoult " yj@24k.com >/dev/null 2>&1
find $Path/ -type f -mtime +180 ! -name "*week*_6*" | xargs rm -f
