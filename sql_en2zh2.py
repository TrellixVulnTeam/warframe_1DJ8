#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Author:Dendi
import  requests,json,os,logging,pymysql,re

with  open('./en_zh.json',encoding='UTF-8-sig',mode='r') as f:
    #print(f)
    a = json.load(f)
    print(a)
for b in a:
        print(a[b], b)
        c = '%'+b+'%'
        update_sql = "UPDATE   t_contents_missions set drop_name_zh = replace(drop_name_zh,'%s','%s')WHERE  drop_name LIKE '%s'  "% (b,a[b],'%'+b+'%')
        db = pymysql.connect("192.168.10.204", "root", "password", "warframe")
        #db = pymysql.connect("localhost", "root", "Asd1234566", "warframe_data")
        cursor = db.cursor()
        try:
            # 执行sql语句
            cursor.execute(update_sql)
            results = cursor.fetchall()
            print(results)
            db.commit()
            db.close()
        except Exception as e:
            #  发生错误时回滚
            print(e, '数据库xie错误')
            db.close()

