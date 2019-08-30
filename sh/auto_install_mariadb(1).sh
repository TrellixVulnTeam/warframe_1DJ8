cd  /scripts/software
wget  http://192.168.6.11/scripts/software/gcc-5.2.0.tar.bz2
tar -xf  gcc-5.2.0.tar.bz2 -C /usr/src/
cd /usr/src/gcc-5.2.0/
./contrib/download_prerequisites
 yum install -y  gcc-c++  glibc-static gcc
 ./configure --prefix=/usr/local/gcc-5.2.0 --enable-bootstrap  --enable-checking=release --enable-languages=c,c++ --disable-multilib
make && make install



yum install cmake
groupadd -r mysql
useradd -s /sbin/nologin -g mysql -M mysql
mkdir -p /mydata/data
wget  http://192.168.6.11/scripts/software/mariadb-10.1.13.tar.gz
yum install  -y ncurses-devel libaio-devel cmake libxml2-devel
yum -y install gcc gcc-c++ make cmake ncurses  libxml2 libxml2-devel openssl-devel bison bison-devel
yum -y install readline-devel
yum -y install zlib-devel
yum -y install openssl-devel lz4 lz4-devel 
yum install -y czmq-devel czmq
 yum install  -y  libevent 
useradd -s /sbin/nologin -M mysql
tar zxf mariadb-10.1.13.tar.gz  -C /usr/src/
 cd /usr/src/mariadb-10.1.13/
 cmake . \
-DCMAKE_INSTALL_PREFIX=/usr/local/mariadb-10.1.13 \
-DDEFAULT_CHARSET=utf8 \
-DMYSQL_UNIX_ADDR=/mydata/mysql.sock \
-DMYSQL_DATADIR=/mydata/data/ \
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
-DWITH_SSL=system



cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
-DMYSQL_DATADIR=/mydata/data/ \
-DSYSCONFDIR=/etc \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_ARCHIVE_STPRAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWIYH_READLINE=1 \
-DWIYH_SSL=system \
-DVITH_ZLIB=system \
-DWITH_LOBWRAP=0 \
-DMYSQL_UNIX_ADDR=/mydata/mysql.sock \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci

