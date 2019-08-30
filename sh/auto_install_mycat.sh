#!/bin/bash
#by : Dendy
#date 2017-10-19 11:25:11
#QQ : 2257752828
useradd mycat && echo “mycat123456” |passwd --stdin mycat &&\
wget  -O /scripts/software/Mycat-server-1.5.1-RELEASE-20160509173344-linux.tar.gz http://192.168.6.11/scripts/software/Mycat-server-1.5.1-RELEASE-20160509173344-linux.tar.gz &&\
tar zxf Mycat-server-1.5.1-RELEASE-20160509173344-linux.tar.gz -C  /usr/local/ &&\
cd /usr/local/mycat/ &&\
#sed -i  's#wrapper.java.command\=java#wrapper.java.command\=/usr/local/java/bin/java#' /usr/local/mycat/conf/wrapper.conf
#sed -i  's/#wrapper.java.initmemory=3/wrapper.java.initmemory=2048/' /usr/local/mycat/conf/wrapper.conf
#sed -i  's/#wrapper.java.maxmemory=64/wrapper.java.maxmemory=2048/' /usr/local/mycat/conf/wrapper.conf
cp /usr/local/mycat/conf/wrapper.conf{,.bak} &&\
cp /usr/local/mycat/conf/rule.xml{,.bak}  &&\
cp /usr/local/mycat/conf/schema.xml{,.bak}  &&\
cp /usr/local/mycat/conf/server.xml{,.bak} &&\
#wget  -O /usr/local/mycat/conf/wrapper.conf http://192.168.6.11/scripts/conf/mycat/wrapper.conf &&\
#wget -O /usr/local/mycat/conf/rule.xml http://192.168.6.11/scripts/conf/mycat/rule.xml&&\
#wget -O /usr/local/mycat/conf/schema.xml http://192.168.6.11/scripts/conf/mycat/schema.xml&&\
#wget -O /usr/local/mycat/conf/server.xml http://192.168.6.11/scripts/conf/mycat/server.xml &&\
#chmod 777 /usr/local/mycat/conf/*
#/usr/local/mycat/bin/mycat start &&\
#netstat  -lnput &&\
echo "sh /usr/local/mycat/bin/mycat start" >>/etc/rc.local 
