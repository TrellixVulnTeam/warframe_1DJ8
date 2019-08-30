#!/bin/bash
#by : Dendy
#date 2017-10-19 11:25:11
#QQ : 2257752828
cd /scripts/software
wget   http://192.168.6.11/scripts/software/haproxy-1.6.5.tar.gz
wget   http://192.168.6.11/scripts/software/openssl-1.0.2l.tar.gz
wget   http://192.168.6.11/scripts/software/keepalived-1.2.20.tar.gz
################ openssl ###################
cd /scripts/software  &&\
tar xf openssl-1.0.2l.tar.gz -C /usr/src/  &&\
cd /usr/src/openssl-1.0.2l/  &&\
./config     &&\
./config -t  &&\
make  -j$(($(cat /proc/cpuinfo |grep processor |wc -l)*2))&&\
make install -j$(($(cat /proc/cpuinfo |grep processor |wc -l)*2)) &&\
echo "/usr/local/ssl/lib" >> /etc/ld.so.conf.d/openssl_nginx.conf  &&\
ldconfig  &&\
echo "export OPENSSL=/usr/local/ssl/bin" >>/etc/profile  &&\
echo 'export PATH=$OPENSSL:$PATH:$HOME/bin' >>/etc/profile  &&\
source /etc/profile  &&\
ldd /usr/local/ssl/bin/openssl  &&\
which openssl  &&\
openssl version  &&\
yum install openssl-devel -y &&\
################ keepalived #################
cd /scripts/software &&\
tar xf keepalived-1.2.20.tar.gz  -C /usr/src/ &&\
cd /usr/src/keepalived-1.2.20/ &&\
./configure --prefix=/usr/local/keepalived &&\
make -j$(($(cat /proc/cpuinfo |grep processor |wc -l)*2)) &&\
make install -j$(($(cat /proc/cpuinfo |grep processor |wc -l)*2)) &&\
#### config keepalived
ln -s /usr/local/keepalived/sbin/keepalived /usr/sbin/ &&\
cp  /usr/local/keepalived/etc/sysconfig/keepalived /etc/sysconfig/ &&\
cp /usr/local/keepalived/etc/rc.d/init.d/keepalived  /etc/init.d/ &&\
chmod +x /etc/rc.d/init.d/keepalived &&\
mkdir -p /etc/keepalived &&\
cp /usr/local/keepalived/etc/keepalived/keepalived.conf  /etc/keepalived/keepalived.conf&&\
echo '/etc/init.d/keepalived start' >> /etc/rc.local&&\
#service keepalived restart &&\
cat /etc/rc.local  &&\
################ haproxy ###################
cd /scripts/software  &&\
tar xf haproxy-1.6.5.tar.gz -C /usr/src/   &&\
cd /usr/src/haproxy-1.6.5/  &&\
make target=linux26 CPU=x86_64 PREFIX=/usr/local/haproxy install  &&\
#### config haproxy
ln -s /usr/local/haproxy/sbin/haproxy /usr/sbin &&\
cp /usr/src/haproxy-1.6.5/examples/haproxy.init  /etc/rc.d/init.d/haproxy &&\
cp -r /usr/src/haproxy-1.6.5/examples/errorfiles /usr/local/haproxy/ &&\
ln -s /usr/local/haproxy/errorfiles /etc/haproxy/errorfiles &&\
chmod +x /etc/rc.d/init.d/haproxy &&\
mkdir -p /etc/haproxy &&\
cp /usr/local/haproxy/conf/haproxy.cfg /etc/haproxy/haproxy.cfg&&\
echo '/etc/init.d/haproxy start' >>/etc/rc.local &&\
sed -i 's/net.ipv4.ip_forward\ =\ 0/net.ipv4.ip_forward\ =\ 1/' /etc/sysctl.conf &&\
sysctl -p &&\
#service  haproxy restart &&\
cat /etc/rc.local