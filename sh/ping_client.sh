#!/bin/bash
. /etc/init.d/functions
a_sub() {
      	ip=$i
		ping -c 2 $ip >/dev/null 2>&1
                if [ $? -eq 0 ]
                        then
                        action "$ip" /bin/true
                else
                        action "$ip" /bin/false
                        fi
}
tmp_fifofile="/tmp/$.fifo"
mkfifo $tmp_fifofile      # 新建一个fifo类型的文件
exec 6<>$tmp_fifofile      # 将fd6指向fifo类型
rm $tmp_fifofile
thread=20 # 此处定义线程数
for ((a=0;a<$thread;a++));do
echo
done >&6 # 事实上就是在fd6中放置了$thread个回车符
for i in `cat  /scripts/all_client_ip.txt|grep -v ^#|awk '{print $3}'`
do # 50次循环，可以理解为50个主机，或其他
read -u6
{
 a_sub
 echo   >&6 # 当进程结束以后，再向fd6中加上一个回车符，即补上了read -u6减去的那个
} &

done
wait # 等待所有的后台子进程结束
exec 6>&- # 关闭df6
exit 0
