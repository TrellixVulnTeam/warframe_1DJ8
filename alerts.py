#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Author:Dendi
import  os,json,requests
import time
import datetime
list = requests.get('http://192.168.6.192:8088/index.json')
list = list.json()
#print(list['alerts'])
print(list['time'])
time_ux_a = list['time']
time_ux = datetime.datetime.fromtimestamp(time_ux_a)
dtime = datetime.datetime.now()
ntime = time.time()
ctime = ntime - time_ux_a
#ctime = datetime.datetime.fromordinal(ctime)
print(time_ux)
print(dtime)
print(ntime)
print(ctime)
def shijiancha(self):
    if  self < 60:
        return  "%s" % (int(self))
    elif self > 60 and self <= 3600:
        return  "%s分%s秒" % (int(self / 60),int(self % 60))
    elif self > 3600 and self <=86400:
        return  "%s时%s分%s秒" % (int(self / 3600 ),int(self % 3600 / 60),int(self % 3600 / 60 % 60 ))
    else:
        return "%s天%s时%s分%s秒" % (int(self / 86400), int(self % 86400 / 3600), int(self % 86400 / 3600 % 60),int(self % 86400 / 3600 / 60 % 60))
ctime = shijiancha(ctime)
time_ux_a = shijiancha(time_ux_a)
print(ctime)
print(time_ux_a)
for i in list['alerts']:
    #print(i['rewards'])
    for rewards in i['rewards']:
        #print(rewards['item'])
        if rewards['item'] == '聚焦能量':
            print('1')
