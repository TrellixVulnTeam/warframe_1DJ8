#!/bin/bash
#by : Dendy
#date 2017-10-19 11:25:11
#QQ : 2257752828
cd /scripts/software &&\
wget   http://192.168.6.11/scripts/software/openssl-1.0.2l.tar.gz &&\
wget   http://192.168.6.11/scripts/software/nginx-1.9.15.tar.gz &&\
wget   http://192.168.6.11/scripts/software/keepalived-1.2.20.tar.gz
############### openssl ##############################
cd /scripts/software  &&\
tar xf openssl-1.0.2l.tar.gz -C /usr/src/  &&\
cd /usr/src/openssl-1.0.2l/  &&\
./config     &&\
./config -t  &&\
make -j$(($(cat /proc/cpuinfo |grep processor |wc -l)*2)) &&\
make install -j$(($(cat /proc/cpuinfo |grep processor |wc -l)*2)) &&\
echo "/usr/local/ssl/lib" >> /etc/ld.so.conf.d/openssl_nginx.conf  &&\
ldconfig  &&\
echo "export OPENSSL=/usr/local/ssl/bin" >>/etc/profile  &&\
echo 'export PATH=$OPENSSL:$PATH:$HOME/bin' >>/etc/profile  &&\
source /etc/profile  &&\
ldd /usr/local/ssl/bin/openssl  &&\
which openssl  &&\
openssl version   &&\
################ nginx ################################
yum install  pcre pcre-devel  zlib-devel  -y  &&\
cd /scripts/software  &&\
useradd -r -d /dev/null -s /sbin/nologin nginx  &&\
tar xf nginx-1.9.15.tar.gz -C /usr/src/  &&\
cd /usr/src/nginx-1.9.15/  &&\
./configure  --with-http_ssl_module --user=nginx --group=nginx --with-openssl=/usr/src/openssl-1.0.2l --with-http_flv_module --with-http_stub_status_module --with-http_gzip_static_module --with-pcre --with-http_realip_module &&\
make -j$(($(cat /proc/cpuinfo |grep processor |wc -l)*2))&&\
make install -j$(($(cat /proc/cpuinfo |grep processor |wc -l)*2))&&\
#### config nginx
ln -s  /usr/local/nginx/sbin/nginx  /usr/sbin/ &&\
echo '/etc/init.d/keepalived start' >> /etc/rc.local &&\
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
echo '/etc/init.d/keepalived start' >> /etc/rc.local &&\
#service keepalived restart &&\
cat /etc/rc.local  &&\