#!/bin/bash
#by : Dendy
#date 2017-10-19 11:25:11
#QQ : 2257752828
cd /scripts/software &&\
#wget   http://192.168.6.11/scripts/software/haproxy-1.6.5.tar.gz &&\
cd /scripts/software  &&\
tar xf haproxy-1.6.5.tar.gz -C /usr/src/   &&\
cd /usr/src/haproxy-1.6.5/  &&\
make target=linux`uname -r |awk -F'[.-]'  '{print $1$2$3}'` CPU=x86_64 PREFIX=/usr/local/haproxy-1.6.5 install  &&\
#### config haproxy
ln -s /usr/local/haproxy-1.6.5  /usr/local/haproxy &&\
ln -s /usr/local/haproxy/sbin/haproxy /usr/sbin &&\
cp -r /usr/src/haproxy-1.6.5/examples/haproxy.init  /etc/rc.d/init.d/haproxy &&\
cp -r /usr/src/haproxy-1.6.5/examples/errorfiles /usr/local/haproxy/ &&\
mkdir -p /etc/haproxy &&\
cp -r /usr/src/haproxy-1.6.5/examples/errorfiles /etc/haproxy/errorfiles &&\
chmod +x /etc/rc.d/init.d/haproxy &&\
cp -r /usr/src/haproxy-1.6.5/examples/option-http_proxy.cfg /etc/haproxy/haproxy.cfg&&\
echo '/etc/init.d/haproxy start' >>/etc/rc.local &&\
sed -i 's/net.ipv4.ip_forward\ =\ 0/net.ipv4.ip_forward\ =\ 1/' /etc/sysctl.conf &&\
sysctl -p &&\
#service  haproxy restart &&\
cat /etc/rc.local &&\
echo  'haproxy  isntalled ok'
