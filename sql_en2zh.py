#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Author:Dendi
import  requests,json,os,logging,pymysql,re

sql = "SELECT drop_name from  t_contents_missions"
db = pymysql.connect("192.168.10.204", "root", "password", "warframe")
# db = pymysql.connect("localhost", "root", "Asd1234566", "warframe_data")
cursor = db.cursor()
try:
    # 执行sql语句
    cursor.execute(sql)
    results = cursor.fetchall()
    print(type(results))
    db.commit()
except Exception as e:
    #  发生错误时回滚
    print(e, '数据库错误')
db.close()
with  open('./en_zh.json',encoding='UTF-8-sig',mode='r') as f:
    #print(f)
    a = json.load(f)
    #print(a)

    #print('b',b)
for i in results:
    for b in a:
        if i[0] == b:
            #print(a[i[0]],b)
            update_sql = "UPDATE   t_contents_missions set drop_name_zh = '%s' WHERE  drop_name = '%s' " % (a[i[0]],b)
            db = pymysql.connect("192.168.10.204", "root", "password", "warframe")
            # db = pymysql.connect("localhost", "root", "Asd1234566", "warframe_data")
            cursor = db.cursor()
            try:
                # 执行sql语句
                cursor.execute(update_sql)
                results = cursor.fetchall()
                print(results)
                db.commit()
            except Exception as e:
                #  发生错误时回滚
                print(e, '数据库xie错误')
            db.close()
        elif b in i[0]:
            print('b,i[0]',b,'i[0]',i[0])

        else:
            c =1
            #print(i[0],b)