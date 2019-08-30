#!/bin/bash
#by : Dendy
#date 2017-10-19 11:25:11
#QQ : 2257752828
cd /software&&\
groupadd -r mysql &&\
useradd -s /sbin/nologin -g mysql -M mysql &&\
id mysql &&\
mkdir -p /home/mydata/{data,ibdata,log-bin,pid,relay-bin,sock} &&\
wget  http://192.168.6.11/software/mariadb-10.1.13.tar.gz &&\
yum install -y ncurses-devel openssl-devel openssl gcc-c++ cmake libxml2 libxml2-devel ncurses  libaio-devel &&\
tar zxf mariadb-10.1.13.tar.gz  -C /usr/src/ &&\
cd /usr/src/mariadb-10.1.13/ &&\
 cmake . \
-DCMAKE_INSTALL_PREFIX=/usr/local/mariadb-10.1.13 \
-DDEFAULT_CHARSET=utf8 \
-DMYSQL_UNIX_ADDR=/home/mysql/data/mysql.sock \
-DMYSQL_DATADIR=/home/mysql/data/data/ \
-DDEFAULT_COLLATION=utf8_general_ci \
-DWITH_EXTRA_CHARSETS=gbk,gb2312 \
-DENABLED_LOCAL_INFILE=ON \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_ARCHIVE_STPRAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITH_FEDERATED_STPRAGE_ENGINE=1 \
-DWITHOUT_EXAMPLE_STORAGE_ENGINE=1 \
-DWITHOUT_PARTITION_STORAGE_ENGINE=1 \
-DWITH_FAST_MUTEXES=1 \
-DWITH_ZLIB=bundled \
-DENABLED_LOCAL_INFILE=1 \
-DWITH_READLINE=1 \
-DWITH_EMBEDDED_SERVER=1 \
-DWITH_DEBUG=0 \
-DWITH_LOBWRAP=0 \
-DWITH_SSL=system &&\
make -j$(($(cat /proc/cpuinfo |grep processor |wc -l)*2)) && make -j$(($(cat /proc/cpuinfo |grep processor |wc -l)*2))  install 
ln -s /usr/local/mariadb-10.1.13 /usr/local/mysql
echo 'export PATH=/usr/local/mysql/bin:$PATH' >/etc/profile.d/mysql.sh
. /etc/profile.d/mysql.sh
ln -sv /usr/local/mysql/include/ /usr/local/include/mysql



cd /usr/local/mysql
/usr/local/mysql/scripts/mysql_install_db --defaults-file=/etc/my.cnf  --user=mysql --basedir=/usr/local/mysql
service mysqld restart

GRANT ALL PRIVILEGES on *.* to root@'localhost' IDENTIFIED BY 'hjzx.24k.1234566';
GRANt select,delete,drop,update,create on *.* to admin@'192.168.6.%' IDENTIFIED BY 'hjkj.24k.com';
GRANT ALL PRIVILEGES on *.* to root@'192.168.6.%' IDENTIFIED BY 'hjzx.24k.1234566';
GRANT ALL PRIVILEGES on *.* to root@'127.0.0.1' IDENTIFIED BY 'hjzx.24k.1234566';
use mysql ;
select user,host,password from user ;
delete from user where user='root' and host='mariadb01.24k.com';
delete from user where user='root' and host='::1';
delete from user where user='' and password='';
delete from user where user='' and host='';
grant replication slave on *.* to 'jack_rep'@'192.168.6.%' identified by 'hjkj.24k.com' ;
flush privileges ;
mysqldump -uroot -phjzx.24k.1234566 -S /home/mysql/data/mysql.sock -A --events -B -x --master-data=1|gzip >/opt/$(date +%F).sql.gz
gzip -d 2017-09-27.sql.gz
mysql -S /home/mysql/mysql.sock <2017-09-27.sql
mysql -S /home/mysql/mysql.sock <<EOP
change master to master_host='192.168.6.136', master_user='jack_rep',master_password='hjkj.24k.com',master_port=3306,master_log_file='mysql-bin.000008',master_log_pos=327;
EOP


mysql -phjzx.24k.1234566 -e 'stop slave' ; mysql -phjzx.24k.1234566 -e'SET GLOBAL SQL_SLAVE_SKIP_COUNTER=1';mysql -phjzx.24k.1234566 -e' START SLAVE';
wget -O /etc/my.cnf http://192.168.6.11/scripts/conf/mariadb/`cat /scripts/all_client_ip.txt|grep -v ^# | grep $(hostname)|awk '{print $2}'`.cnf
wget -O /etc/init.d/mysqld http://192.168.6.11/scripts/conf/mariadb/mysqld
