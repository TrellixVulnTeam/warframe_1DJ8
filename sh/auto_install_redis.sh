#!/bin/bash
#by : Dendy
#date 2017-10-19 11:25:11
#QQ : 2257752828
cd  /scripts/software &&\
tar zxf redis-3.0.7.tar.gz -C /usr/local/ &&\
cd /usr/local/redis-3.0.7/ &&\
make -j$(($(cat /proc/cpuinfo |grep processor |wc -l)*2)) &&\
make install -j$(($(cat /proc/cpuinfo |grep processor |wc -l)*2)) &&\
cp src/redis-trib.rb /usr/local/bin/ &&\
mkdir redis_cluster &&\
cd redis_cluster/ &&\
ln -s /usr/local/redis-3.0.7/ /usr/local/redis &&\

安装rvm
http://blog.csdn.net/fengye_yulu/article/details/77628094
gpg2 --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3 &&\
curl -L get.rvm.io | bash -s stable &&\
find / -name rvm -print &&\
source /usr/local/rvm/scripts/rvm &&\
rvm list known &&\
rvm install 2.3.3 &&\
rvm use 2.3.3 &&\
rvm use 2.3.3 --default &&\
ruby --version &&\
gem install redis

sed -i 's/daemonize no/daemonize yes/' redis_cluster/7383/redis.conf
sed -i 's/port 6379/port 7383/' redis_cluster/7383/redis.conf
sed -i 's#pidfile /var/run/redis.pid#pidfile /var/run/redis_7383.pid#' redis_cluster/7383/redis.conf 
sed -i 's/# bind 127.0.0.1/bind 192.168.6.144/' redis_cluster/7383/redis.conf
sed -i 's/# cluster-enabled yes/cluster-enabled yes/' redis_cluster/7383/redis.conf
sed -i 's/# cluster-config-file nodes-6379.conf/cluster-config-file redis_7383.conf/' redis_cluster/7383/redis.conf
sed -i 's/# cluster-node-timeout 15000/cluster-node-timeout 15000/' redis_cluster/7383/redis.conf
sed -i 's/appendonly no/appendonly yes/' redis_cluster/7383/redis.conf
mkdir 6381 6382 6383
mkdir 7381 7382 7383
cd  /usr/local/redis
cp redis.conf  redis_cluster/7381
cp redis.conf  redis_cluster/7382
cp redis.conf  redis_cluster/7383
redis-server redis_cluster/6381/redis.conf
redis-server redis_cluster/6382/redis.conf
redis-server redis_cluster/6383/redis.conf
redis-server redis_cluster/7381/redis.conf
redis-server redis_cluster/7382/redis.conf
redis-server redis_cluster/7383/redis.conf
redis-server redis_cluster/5381/redis.conf
redis-server redis_cluster/5382/redis.conf
redis-server redis_cluster/5383/redis.conf