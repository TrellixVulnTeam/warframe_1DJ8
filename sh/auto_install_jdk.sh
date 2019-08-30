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
java -version &&\
echo 'jdk-8u45-linux-x64 isntalled ok'