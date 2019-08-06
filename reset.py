#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Author:Dendi
import  requests,json

url = "https://api.null00.com/world/ZHCN"
# print(url)
a = requests.get(url)
a = a.json()
print(a)
# a = {"txt": a}
a = json.dumps(a, sort_keys=True, indent=4, separators=(',', ':'))
a = json.loads(a)
# print(type(a))
list = a['alerts']
#print(a['alerts'][0]['rewards'][0]['item'])
for i in list:
    if i['rewards']:
        print(i['rewards'][0]['item'])