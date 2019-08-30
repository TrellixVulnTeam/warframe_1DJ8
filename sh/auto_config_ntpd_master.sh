restrict default kod nomodify notrap nopeer noquery
restrict -6 default kod nomodify notrap nopeer noquery
restrict 127.0.0.1
restrict 202.118.1.130
restrict 202.118.1.81
restrict 0.cn.pool.ntp.org
restrict 1.cn.pool.ntp.org
restrict 2.cn.pool.ntp.org
restrict -6 ::1
restrict 192.168.6.0 mast 255.255.255.0 nomodify
server 202.118.1.130 prefer
server 202.118.1.81
server 0.cn.pool.ntp.org
server 1.cn.pool.ntp.org
server 2.cn.pool.ntp.org
driftfile /var/lib/ntp/drift
keys /etc/ntp/keys
restrict 120.25.108.11
server 120.25.108.11