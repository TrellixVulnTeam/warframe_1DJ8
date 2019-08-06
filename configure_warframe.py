#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Author:Dendi

import pymysql
import requests
import json
import sys
import os
import time,datetime
def timestamp2string(timeStamp):
  try:
    d = datetime.datetime.fromtimestamp(timeStamp)
    str1 = d.strftime("%Y-%m-%d %H:%M:%S")
    # 2015-08-28 16:43:37'
    return str1
  except Exception as e:
    #print(e,'time',f["id"])
    str1 = 0
    return str1
for i in range(668):
    c = i+399
    url = "https://api.null00.com/world/ZHCN/oldMission?start=%s&pageSize=30" % c
    #print(url)
    a =  requests.get(url)
    a = a.json()
    #a = {"txt": a}
    a = json.dumps(a, sort_keys=True, indent=4, separators=(',', ':'))
    a = json.loads(a)
    #print(type(a))
    if isinstance(a,list):
        #print(a[1])
        for f in a:
            f = json.dumps(f, sort_keys=True, indent=4, separators=(',', ':'))
            #a = json.loads(a)
            f = json.loads(f)
            #print(f["activation"])
            select_sql = "select id from t_alerts_history_data where id = '%s'" % f["id"]
            select_activation_sql = "select id from t_alerts_history_data where activation = '%s'" % f["activation"]
            #print(f["id"])
            sql = "INSERT INTO t_alerts_history_data(id, oid, activation, expiry, node, enemyLevel, missionType, rewards, world) \
               VALUES (%s, '%s','%s','%s',  '%s', '%s','%s','%s','%s')" % \
              (f["id"],f["oid"],timestamp2string(f["activation"]),timestamp2string(f["expiry"]),f["node"],f["enemyLevel"],f["missionType"],f["rewards"],f["world"])
            #print(sql)
            update_sql= "UPDATE  t_alerts_history_data SET activation = '%s',expiry= '%s' WHERE  id = %s" % (timestamp2string(f["activation"]),timestamp2string(f["expiry"]),f["id"])
            db = pymysql.connect("192.168.10.204","root","password","warframe" )
            #db = pymysql.connect("localhost", "root", "Asd1234566", "warframe_data")
            cursor = db.cursor()
            try:
                # 执行sql语句
                cursor.execute(select_sql)
                results = cursor.fetchall()
                if results:
                    cursor.execute(select_activation_sql)
                    select_activation_results = cursor.fetchall()
                    if select_activation_results:
                        try:
                            print(f["id"], '更新数据')
                            cursor.execute(update_sql)
                            db.commit()
                        except Exception as er:
                            db.rollback()
                            print(f["id"], '更新出错', er)
                else:
                    #print(f["id"], '插入数据')
                    try:
                        cursor.execute(sql)
                        db.commit()
                    except Exception as er:
                        db.rollback()
                        print(f["id"], '插入出错',er)
                        #print('插入出错')
                #print(results[0][0])
                #for i in results:
                #    print(i)
                # 执行sql语句
                #db.commit()
            except Exception as e:
                #  发生错误时回滚
                print(e,'数据库错误')
            db.close()
    else:
        print(url)
        print(a)
        break
