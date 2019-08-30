ln -s /usr/local/keepalived/sbin/keepalived /usr/sbin/ &&\
cp  /usr/local/keepalived/etc/sysconfig/keepalived /etc/sysconfig/ &&\
cp /usr/local/keepalived/etc/rc.d/init.d/keepalived  /etc/init.d/ &&\
chmod +x /etc/rc.d/init.d/keepalived &&\
mkdir -p /etc/keepalived &&\
cp /usr/local/keepalived/etc/keepalived/keepalived.conf  /etc/keepalived/keepalived.conf&&\
echo '/etc/init.d/keepalived start' >> /etc/rc.local&&\
service keepalived restart
cat /etc/rc.local



ln -s /usr/local/haproxy/sbin/haproxy /usr/sbin &&\
cp /usr/src/haproxy-1.6.5/examples/haproxy.init  /etc/rc.d/init.d/haproxy &&\
cp -r /usr/src/haproxy-1.6.5/examples/errorfiles /usr/local/haproxy/ &&\
ln -s /usr/local/haproxy/errorfiles /etc/haproxy/errorfiles &&\
chmod +x /etc/rc.d/init.d/haproxy &&\
mkdir -p /etc/haproxy &&\
cp /usr/local/haproxy/conf/haproxy.cfg /etc/haproxy/haproxy.cfg&&\
echo '/etc/init.d/haproxy start' >>/etc/rc.local &&\
cat /etc/rc.local
sed -i 's/net.ipv4.ip_forward\ =\ 0/net.ipv4.ip_forward\ =\ 1/' /etc/sysctl.conf && sysctl -p &&\
service  haproxy restart &&\