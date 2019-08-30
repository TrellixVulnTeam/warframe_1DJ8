#!/bin/bash
Check_nginx=`netstat -lnput |grep nginx|grep 80|wc -l `
if [ "${Check_nginx}" -eq 0 ];then
	exit 10
fi
