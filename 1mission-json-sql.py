#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Author:Dendi
import  requests,json,os,logging,pymysql,re
logging.basicConfig(level = logging.DEBUG,format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

logger.info("Start print log")
logger.debug("Do something")
logger.warning("Something maybe fail.")
logger.info("Finish")

with  open("./mission.json", 'r') as f:
    #print(f)
    a = json.load(f)
    #print(a)
    #a = list(a)
    #print(a)
    #line=a.readline()
    #print("type(a['missions']):",type(a['missions']))
    #logging.debug("a['missions']:",a['missions'])

for i in a['missions']:
    #print(type(i))
    #print(i)
    for mission in i:
        #b = json.loads(b)
        #print(type(mission))
        #print(mission)
        mission_map = mission.split("/",1)
        mission_star = mission_map[0]
        mission_type = mission_map[1]
        #print(mission_star,"-*-",mission_type)
        #print(i[mission])
        if isinstance(i[mission],dict):
            mission_rotation = "0"
           #print(i[mission])
            for drop_name in i[mission]:
                #print(drop_name)

                drop_chance = i[mission][drop_name]
               # print(drop_chance)
                sql = "INSERT INTO t_contents_missions(mission_star, mission_type, mission_rotation, drop_name, drop_chance) \
                               VALUES ('%s', '%s','%s','%s','%s')" % (
                mission_star, mission_type, mission_rotation, drop_name, drop_chance)
                db = pymysql.connect("192.168.10.204", "root", "password", "warframe")
                # db = pymysql.connect("localhost", "root", "Asd1234566", "warframe_data")
                cursor = db.cursor()
                try:
                    # 执行sql语句
                    cursor.execute(sql)
                    results = cursor.fetchall()
                    db.commit()
                except Exception as e:
                    #  发生错误时回滚
                    print(e, '数据库错误')
                db.close()

        elif isinstance(i[mission],list):
            for mission_ro_pre in i[mission]:
                # print(type(i[mission]))
                #print('mission_ro_pre:',mission_ro_pre)
                for mission_rotation in mission_ro_pre:
                    #print("mission_rotation:",mission_rotation)
                    #print("(type(mission_ro_pre)):",type(mission_ro_pre))
                    #print(mission_ro_pre)
                    for drop_name in mission_ro_pre[mission_rotation]:
                        drop_chance=mission_ro_pre[mission_rotation][drop_name]
                        #print(drop_chance)
                        drop_name =re.sub("'"," ",drop_name)
                        sql = "INSERT INTO t_contents_missions(mission_star, mission_type, mission_rotation, drop_name, drop_chance) \
                                       VALUES ('%s', '%s', '%s', '%s', '%s')" % (mission_star,mission_type,mission_rotation,drop_name,drop_chance )
                        print(sql)
                        db = pymysql.connect("192.168.10.204", "root", "password", "warframe")
                        # db = pymysql.connect("localhost", "root", "Asd1234566", "warframe_data")
                        cursor = db.cursor()
                        try:
                            # 执行sql语句
                            cursor.execute(sql)
                            results = cursor.fetchall()
                            db.commit()
                        except Exception as e:
                            #  发生错误时回滚
                            print(e, '数据库错误')
                        db.close()
        else:
            aaa = 1
