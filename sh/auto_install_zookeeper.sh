#!/bin/bash
#by : Dendy
#date 2017-10-19 11:25:11
#QQ : 2257752828
cd /scripts/software &&\
wget -O /scripts/software/zookeeper-3.4.8.tar.gz http://192.168.6.11/scripts/software/zookeeper-3.4.8.tar.gz
tar zxf zookeeper-3.4.8.tar.gz  -C /usr/local/ &&\
ln -s /usr/local/zookeeper-3.4.8  /usr/local/zookeeper &&\
sed -i  '$a\export PATH=/usr/local/zookeeper/bin:$PATH\n' /etc/profile &&\
.  /etc/profile &&\
echo '/usr/local/zookeeper/bin/zkServer.sh' >>/etc/rc.local &&\
echo 'zookeeper installed ok'
