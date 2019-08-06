#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Author:Dendi
import  pymysql
import time,datetime
def timestamp2string(timeStamp):
  try:
    d = datetime.datetime.fromtimestamp(timeStamp)
    str1 = d.strftime("%Y-%m-%d %H:%M:%S")
    # 2015-08-28 16:43:37.283000'
    return str1
  except Exception as e:
    print(e)
    return ''


print(timestamp2string(1548184174))
try:
    db = pymysql.connect("192.168.10.204","root","password","warframe" )
except Exception as e:
    print('hello word')

    print(e)
for i in range(1):
    a = i + 1
    #select_sql = "select id from t_alerts_history_data where id = '%s'" % a
    select_sql = "select id from t_alerts_history_data where activation = '15503328288'"
#for f in a:
#    print(f)
    cursor = db.cursor()
    try:
    # 执行sql语句
        cursor.execute(select_sql)
        results = cursor.fetchall()
        #print(type(results))
        print(results)
        if  results:
            #print(a, '数据已存在')
            if results[0][0] == a:
                pass
            else:
                print(a, results[0][0])
        else:

            print(a, '插入数据')

    # print(results[0][0])
    # for i in results:
    #    print(i)
    # 执行sql语句
    # db.commit()
    except Exception as e:
    #  发生错误时回滚
        print(e, '更新，或者错误')

db.close()