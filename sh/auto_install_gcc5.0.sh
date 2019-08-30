#!/bin/bash
#by : Dendy
#date 2017-10-19 11:25:11
#QQ : 2257752828
cd  /scripts/software &&\

# wget  http://192.168.6.11/scripts/software/gcc-5.2.0.tar.bz2 &&\
tar -xf  gcc-5.2.0.tar.bz2 -C /usr/src/ &&\
cd /usr/src/gcc-5.2.0/ &&\
mv ~/* . &&\
MPFR=mpfr-2.4.2
GMP=gmp-4.3.2
MPC=mpc-0.8.1
tar xjf $MPFR.tar.bz2 || exit 1
ln -sf $MPFR mpfr || exit 1
tar xjf $GMP.tar.bz2  || exit 1
ln -sf $GMP gmp || exit 1
tar xzf $MPC.tar.gz || exit 1
ln -sf $MPC mpc || exit 1
tar xjf $ISL.tar.bz2  || exit 1
 ln -sf $ISL isl || exit 1
#./contrib/download_prerequisites &&\
yum install -y  gcc-c++  glibc-static gcc &&\
./configure --prefix=/usr/local/gcc-5.2.0  --enable-bootstrap  --enable-checking=release --enable-languages=c,c++ --disable-multilib &&\
make -j$(($(cat /proc/cpuinfo |grep processor |wc -l)*2)) && make install -j$(($(cat /proc/cpuinfo |grep processor |wc -l)*2))  &&\
ln -s  /usr/local/gcc-5.2.0/ /usr/local/gcc &&\
gcc --version &&\
echo "export PATH=/usr/local/gcc/bin:\$PATH" >/etc/profile.d/gcc.sh &&\
source /etc/profile.d/gcc.sh &&\
gcc --version &&\
ln -s /usr/local/gcc/include/ /usr/include/gcc &&\
echo "/usr/local/gcc/lib64" > /etc/ld.so.conf.d/gcc.conf &&\
rm -f /usr/local/gcc/lib64/libstdc++.so.6.0.21-gdb.py &&\
ldconfig &&\
echo 'gcc-5.2.0 installed ok'





