#!/bin/bash
#by : Dendy
#date 2017-10-19 11:25:11
#QQ : 2257752828
cd /software &&\
################ nginx ################################
yum install  pcre pcre-devel  zlib-devel  -y  &&\
cd /scripts/software  &&\
useradd -r -d /dev/null -s /sbin/nologin nginx  &&\
tar xf nginx-1.9.15.tar.gz -C /usr/src/  &&\
cd /usr/src/nginx-1.9.15/  &&\
./configure  --prefix=/usr/local/nginx-1.9.15 --with-http_ssl_module --user=nginx --group=nginx --with-openssl=/usr/src/openssl-1.0.2l --with-http_flv_module --with-http_stub_status_module --with-http_gzip_static_module --with-pcre --with-http_realip_module &&\
make -j$(($(cat /proc/cpuinfo |grep processor |wc -l)*2)) &&\
make install -j$(($(cat /proc/cpuinfo |grep processor |wc -l)*2)) &&\
#### config nginx
ln -s /usr/local/nginx-1.9.15  /usr/local/nginx &&\
ln -s  /usr/local/nginx/sbin/nginx  /usr/sbin/ &&\
echo '/usr/local/nginx/sbin/nginx' >> /etc/rc.local &&\
echo 'nginx 1.9.15 installed ok!'
