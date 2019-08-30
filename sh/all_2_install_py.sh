for i in `cat /scripts/all_client_ip.txt |grep -v ^# | awk '{print $1}' |sort |uniq`
do
	b=
	for a in `grep -i $i /scripts/all_client_ip.txt|awk  '{print $3}'`
	do
	b=$b,\'$a\'
	done
	c=`echo "test$b"|awk -F"test," '{print $2}'`
	d=`echo "loops=[$c]"`
	[ -f /script/$i ] || mkdir /scripts/$i
	rm -f /scripts/$i/install.py
	cp /scripts/install.py  /scripts/$i/
	sed -i "5d" /scripts/$i/install.py
	sed -i "4a$d" /scripts/$i/install.py
	rsync -avzP /scripts/$i/install.py -e 'ssh -t -p 22 ' root@`cat /scripts/all_client_ip.txt2|grep -v ^# |grep -i $i|awk '{print$1}'`:~
	ssh -t -p 22 root@`cat /scripts/all_client_ip.txt2|grep -v ^# |grep -i $i|awk '{print$1}'` sudo rsync ~/install.py /scripts/install.py
done