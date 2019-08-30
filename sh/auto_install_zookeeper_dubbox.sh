#!/bin/bash
#by : Dendy
#date 2017-10-19 11:25:11
#QQ : 2257752828
cd /scripts/software &&\
wget -O /scripts/software/jdk-8u45-linux-x64.tar.gz http://192.168.6.11/scripts/software/jdk-8u45-linux-x64.tar.gz &&\
tar zxf jdk-8u45-linux-x64.tar.gz -C /usr/src/ &&\
mv /usr/src/jdk1.8.0_45 /usr/local/java &&\
sed -i  '$a\ JAVA_HOME=/usr/local/java\nJRE_HOME=/usr/local/java/jre\nPATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH\nCLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib\nexport JAVA_HOME JRE_HOME PATH CLASSPATH\n'   /etc/profile  &&\
.  /etc/profile &&\
cd /scripts/software &&\
wget -O /scripts/software/zookeeper-3.4.8.tar.gz http://192.168.6.11/scripts/software/zookeeper-3.4.8.tar.gz
tar zxf zookeeper-3.4.8.tar.gz  -C /usr/local/ &&\
ln -s /usr/local/zookeeper-3.4.8  /usr/local/zookeeper
sed -i  '$a\export PATH=/usr/local/zookeeper/bin:$PATH\n' /etc/profile &&\
.  /etc/profile &&\
#mv /usr/local/zookeeper/conf/zoo.cfg{,.bak}
cp /usr/local/zookeeper/conf/zoo_sample.cfg  /usr/local/zookeeper/conf/zoo.cfg &&\
sed -i 's#dataDir=/tmp/zookeeper#dataDir=/home/zookeeper/data#'  /usr/local/zookeeper/conf/zoo.cfg &&\
sed -i  '$a\dataLogDir=/home/zookeeper/logs\nserver.1=middle-01:2888:3888\nserver.2=middle-02:2888:3888\nserver.3=middle-03:2888:3888\n' /usr/local/zookeeper/conf/zoo.cfg
mkdir /home/zookeeper/logs -p &&\
mkdir /home/zookeeper/data -p &&\
a=`hostname |awk -F"[-.]+" '{print $3}'`
b=$(($a+1-1))
echo "$b" > /home/zookeeper/data/myid
/usr/local/zookeeper/bin/zkServer.sh  restart
#tar zxf apache-tomcat-9.0.0.M20.tar.gz  -C /usr/local/
#ln -s /usr/local/apache-tomcat-9.0.0.M20/ /usr/local/tomcat
#mv /usr/local/tomcat/webapps/ROOT{,$(date +%F)}
#unzip /scripts/software/dubbox-admin.zip  -d /usr/local/tomcat/webapps/
#wget -O /usr/local/tomcat/webapps/ROOT/WEB-INF/dubbo.properties  http://192.168.6.11/scripts/conf/dubbo/`cat /scripts/all_client_ip.txt |grep -v ^# | grep $HOSTNAME |awk '{print $3}'`.dubbo.properties
#wget -O /usr/local/tomcat/conf/server.xml  http://192.168.6.11/scripts/conf/dubbo/`cat /scripts/all_client_ip.txt |grep -v ^# | grep $HOSTNAME |awk '{print $3}'`.server


