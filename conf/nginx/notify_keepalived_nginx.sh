#!/bin/bash
VIP=$2
sendmail (){
        subject="${VIP}'s server keepalived state is translate"
        content="`date +'%F %T'`: `hostname`'s state change to master"
        echo $content | mail -s "$subject" yj@24k.com
}
case "$1" in
  master)
        Check_nginx=`netstat -lnput |grep nginx|grep 80|wc -l`
        if [ "${Check_nginx}" -eq 0 ];then
                /usr/local/nginx/sbin/nginx
        fi
        sendmail
  ;;
  backup)
        nginx_psr=`ps -C nginx --no-header | wc -l`
        if [ "${nginx_psr}" -ne 0 ];then
                /usr/local/nginx/sbin/nginx -s stop
        fi
  ;;
  *)
        echo "Usage:$0 master|backup VIP"
  ;;
esac

