#!/bin/bash
#by : Dendy
#date 2017-10-19 11:25:11
#QQ : 2257752828
cd /scripts/software
wget   http://192.168.6.11/scripts/software/openssl-1.0.2l.tar.gz
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
echo 'openssl-1.0.21 installed  ok'