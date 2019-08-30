#!/bin/bash
#by : Dendy
#date 2017-10-19 11:25:11
#QQ : 2257752828
cd /scripts/software &&\
wget   http://192.168.6.11/scripts/software/keepalived-1.2.20.tar.gz &&\
cd /scripts/software &&\
tar xf keepalived-1.2.20.tar.gz  -C /usr/src/ &&\
cd /usr/src/keepalived-1.2.20/ &&\
./configure --prefix=/usr/local/keepalived-1.2.20 &&\
make -j$(($(cat /proc/cpuinfo |grep processor |wc -l)*2)) &&\
make install -j$(($(cat /proc/cpuinfo |grep processor |wc -l)*2)) &&\
#### config keepalived
ln -s /usr/local/keepalived-1.2.20 /usr/local/keepalived &&\
ln -s /usr/local/keepalived/sbin/keepalived /usr/sbin/ &&\
cp  /usr/local/keepalived/etc/sysconfig/keepalived /etc/sysconfig/ &&\
cp /usr/local/keepalived/etc/rc.d/init.d/keepalived  /etc/init.d/ &&\
chmod +x /etc/rc.d/init.d/keepalived &&\
mkdir -p /etc/keepalived &&\
cp /usr/local/keepalived/etc/keepalived/keepalived.conf  /etc/keepalived/keepalived.conf&&\
echo '/etc/init.d/keepalived start' >> /etc/rc.local &&\
#service keepalived restart &&\
cat /etc/rc.local  &&\
echo 'keepalived installed ok'