#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Author:Dendi
import  os,json,requests,pymysql,logging,logging.handlers
import time
import datetime
import MySQLdb
from DBUtils.PooledDB import PooledDB

logging.basicConfig(level = logging.DEBUG,format = '%(asctime)s -%(name)s- %(filename)s[line:%(lineno)d] - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)
handler1 = logging.StreamHandler()
handler2 = logging.FileHandler(filename="../log/test.log", encoding = 'utf-8')
handler2 = logging.handlers.TimedRotatingFileHandler("../log/test.log", when="H", interval=1, backupCount=1, encoding = 'utf-8')
logger.setLevel(logging.DEBUG)
handler1.setLevel(logging.WARNING)
handler2.setLevel(logging.DEBUG)

formatter = logging.Formatter('%(asctime)s -%(name)s- %(filename)s[line:%(lineno)d] - %(levelname)s - %(message)s')
handler1.setFormatter(formatter)
handler2.setFormatter(formatter)

logger.addHandler(handler1)
logger.addHandler(handler2)
logger.info("Start print log")
logger.debug("Do something")
logger.warning("Something maybe fail.")
logger.info("Finish")

class OPMysql(object):

    __pool = None

    def __init__(self):
        # 构造函数，创建数据库连接、游标
        self.coon = OPMysql.getmysqlconn()
        self.cur = self.coon.cursor(cursor=pymysql.cursors.DictCursor)


    # 数据库连接池连接
    @staticmethod
    def getmysqlconn():
        if OPMysql.__pool is None:
            __pool = PooledDB(creator=pymysql, mincached=1, maxcached=20, host=mysqlInfo['host'], user=mysqlInfo['user'], passwd=mysqlInfo['passwd'], db=mysqlInfo['db'], port=mysqlInfo['port'])
            #print(__pool,'zaizheli')
            logger.debug("创建数据库实例，create sql connect↓")
            logger.debug(__pool)
        return __pool.connection()

    # 插入\更新\删除sql
    def op_insert(self, sql):
        logger.debug('op_insert↓')
        logger.debug(sql)
        insert_num = self.cur.execute(sql)
        logger.debug('mysql sucess ')
        logger.debug(insert_num)
        self.coon.commit()
        return insert_num

    # 查询
    def op_select(self, sql):
        logger.debug('op_select')
        logger.debug(sql)
        self.cur.execute(sql)  # 执行sql
        select_res = self.cur.fetchall()  # 返回结果为字典
        logger.debug('op_select')
        logger.debug(select_res)
        return select_res

    #释放资源
    def dispose(self):
        self.coon.close()
        self.cur.close()
mysqlInfo = {
    "host": 'caoj.cc',
    "user": 'root',
    "passwd": 'Asd123456',
    "db": 'warframe',
    "port": 3306
}
'''mysqlInfo = {
    "host": '192.168.10.204',
    "user": 'root',
    "passwd": 'password',
    "db": 'warframe',
    "port": 3306
}
'''
world_state = requests.get('http://192.168.6.192:8080/test.json',headers={'User-Agent':'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.75 Safari/537.36',})
#world_state = requests.get('http://content-zh.warframe.com.cn/dynamic/worldState.php',headers={'User-Agent':'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.75 Safari/537.36',})

world_state = world_state.json()
logger.info('world_state↓')
logger.debug(world_state)
#飞船新闻 world_state['Events']
#实时警报 world_state['Alerts']
#突击任务 world_state['Sorties']
#入侵任务 world_state['Invasions']
#虚空商人 world_state['VoidTraders']
#集团任务world_state['SyndicateMissions']
#world_state['PrimeAccessAvailability']
#world_state['PrimeVaultAvailabilities']
#world_state['PrimeAccessAvailability']
#world_state['PrimeVaultAvailabilities']
logger.debug(world_state['PrimeAccessAvailability'])
logger.debug(world_state['PrimeVaultAvailabilities'])
def worldstate_events():
    opm = OPMysql()
    for i in world_state['Events']:
        oid = i['_id']['$oid']
        message = i['Messages'][0]['Message']
        prop= i['Prop']
        date = i['Date']['$date']['$numberLong']
        select_sql = "SELECT oid  from  warframe_worldstate_events WHERE oid = '%s' " % (oid)
        insert_sql = "INSERT INTO warframe_worldstate_events(oid,message,prop,date) VALUES ('%s', '%s', '%s', '%s')" % (oid,message,prop,date)
        res = opm.op_select(select_sql)
        if isinstance(res,tuple):
            ree = opm.op_insert(insert_sql)
    opm.dispose()

def wordstate_alerts():
    opml = OPMysql()
    logger.debug('world_state[\'Alerts\']')
    logger.debug(world_state['Alerts'])
    for _i in world_state['Alerts']:
        oid = _i['_id']['$oid']
        activation_date = _i['Activation']['$date']['$numberLong']
        expiry_date = _i['Expiry']['$date']['$numberLong']
        missiontype = _i['MissionInfo']['missionType']
        faction = _i['MissionInfo']['faction']
        location = _i['MissionInfo']['location']
        leveloverride = _i['MissionInfo'][ 'levelOverride']
        enemyspec = _i['MissionInfo'][ 'enemySpec']
        minenemylevel =_i['MissionInfo']['minEnemyLevel']
        maxenemylevel= _i['MissionInfo']['maxEnemyLevel']
        difficulty = _i['MissionInfo']['difficulty']
        seed = _i['MissionInfo']['seed']
        mission_reward_credits = _i['MissionInfo']['missionReward']['credits']
        try:
            mission_reward_items = _i['MissionInfo']['missionReward']['items'][0]
        except Exception as e:
            logger.error(e)
            mission_reward_items = ''
        try:
            mission_reward_itemtype = _i['MissionInfo']['missionReward']['countedItems']['ItemType']
        except Exception as e:
            logger.error(e)
            mission_reward_itemtype = ''
        try:
            mission_reward_itemcount = _i['MissionInfo']['missionReward']['countedItems']['ItemCount']
        except Exception as e:
            logger.error(e)
            mission_reward_itemcount = ''
        try:
            nightmare = _i['MissionInfo']['nightmare']
        except Exception as e:
            logger.error(e)
            nightmare = ''
        select_sql = "SELECT oid  from  warframe_worldstate_alerts WHERE oid = '%s' " % (oid)
        insert_sql = "INSERT INTO warframe_worldstate_alerts(oid,activation_date,expiry_date,missiontype,faction,location,leveloverride,enemyspec,minenemylevel,maxenemylevel,difficulty,seed,mission_reward_credits,mission_reward_items,mission_reward_itemtype,mission_reward_itemcount,nightmare) VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s','%s', '%s', '%s','%s','%s')" % (oid,activation_date,expiry_date,missiontype,faction,location,leveloverride,enemyspec,minenemylevel,maxenemylevel,difficulty,seed,mission_reward_credits,mission_reward_items,mission_reward_itemtype,mission_reward_itemcount,nightmare)
        res = opml.op_select(select_sql)
        if isinstance(res,tuple):
            ree = opml.op_insert(insert_sql)
    opml.dispose()

def wordstate_sorties():
    logger.debug("world_state['Sorties']↓")
    logger.debug(world_state['Sorties'])
    opm = OPMysql()
    for _a in world_state['Sorties']:
        oid = _a['_id']['$oid']
        activation_date = _a['Activation']['$date']['$numberLong']
        expiry_date = _a['Expiry']['$date']['$numberLong']
        boss = _a['Boss']
        reward = _a['Reward']
        extradrops = _a['ExtraDrops']
        seed = _a['Seed']
        mission1_type = _a['Variants'][0]['missionType']
        mission1_modifiertype = _a['Variants'][0]['modifierType']
        mission1_node = _a['Variants'][0]['node']
        mission1_tileset = _a['Variants'][0]['tileset']
        logger.debug(_a['Variants'][0])
        mission2_type = _a['Variants'][1]['missionType']
        mission2_modifiertype = _a['Variants'][1]['modifierType']
        mission2_node = _a['Variants'][1]['node']
        mission2_tileset = _a['Variants'][1]['tileset']
        mission3_type = _a['Variants'][2]['missionType']
        mission3_modifiertype = _a['Variants'][2]['modifierType']
        mission3_node = _a['Variants'][2]['node']
        mission3_tileset = _a['Variants'][2]['tileset']
        select_sql = "SELECT oid  from  warframe_worldstate_sorties WHERE oid = '%s' " % (oid)
        insert_sql = "INSERT INTO warframe_worldstate_sorties(oid,activation_date,expiry_date,boss,reward,extradrops,seed,mission1_type,mission1_modifiertype,mission1_node,mission1_tileset,mission2_type,mission2_modifiertype,mission2_node,mission2_tileset,mission3_type,mission3_modifiertype,mission3_node,mission3_tileset) VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s')" % (oid,activation_date,expiry_date,boss,reward,extradrops,seed,mission1_type,mission1_modifiertype,mission1_node,mission1_tileset,mission2_type,mission2_modifiertype,mission2_node,mission2_tileset,mission3_type,mission3_modifiertype,mission3_node,mission3_tileset)
        res = opm.op_select(select_sql)
        if isinstance(res, tuple):
            ree = opm.op_insert(insert_sql)
    opm.dispose()


def wordstate_SyndicateMissions():
    logger.debug("world_state['SyndicateMissions']↓")
    logger.debug(world_state['SyndicateMissions'])
    opm = OPMysql()
    for _a in world_state['SyndicateMissions']:
        oid = _a['_id']['$oid']
        activation_date = _a['Activation']['$date']['$numberLong']
        expiry_date = _a['Expiry']['$date']['$numberLong']
        tag = _a['Tag']
        seed = _a['Seed']
        node = _a['Nodes']
        node = ' '.join(node)
        try:
            jobs1_type = _a['Jobs'][0]['jobType']
        except Exception as e:
            logger.debug(e)
            jobs1_type = ''
        try:
            jobs1_rewards = _a['Jobs'][0]['rewards']
        except Exception as e:
            logger.debug(e)
            jobs1_rewards =''
        try:
            jobs1_masteryreq = _a['Jobs'][0]['masteryReq']
        except Exception as e:
            logger.debug(e)
            jobs1_masteryreq =''
        try:
            jobs1_minenemylevel = _a['Jobs'][0]['minEnemyLevel']
        except Exception as e:
            logger.debug(e)
            jobs1_minenemylevel = ''
        try:
            jobs1_maxenemylevel = _a['Jobs'][0]['maxEnemyLevel']
        except Exception as e:
            logger.debug(e)
            jobs1_maxenemylevel = ''
        try:
            jobs1_xpamounts = _a['Jobs'][0]['xpAmounts']
        except Exception as e:
            logger.debug(e)
            jobs1_xpamounts =''
        try:
            jobs2_type = _a['Jobs'][0]['jobType']
        except Exception as e:
            logger.debug(e)
            jobs2_type = ''
        try:
            jobs2_rewards = _a['Jobs'][0]['rewards']
        except Exception as e:
            logger.debug(e)
            jobs2_rewards =''
        try:
            jobs2_masteryreq = _a['Jobs'][0]['masteryReq']
        except Exception as e:
            logger.debug(e)
            jobs2_masteryreq =''
        try:
            jobs2_minenemylevel = _a['Jobs'][0]['minEnemyLevel']
        except Exception as e:
            logger.debug(e)
            jobs2_minenemylevel = ''
        try:
            jobs2_maxenemylevel = _a['Jobs'][0]['maxEnemyLevel']
        except Exception as e:
            logger.debug(e)
            jobs2_maxenemylevel = ''
        try:
            jobs2_xpamounts = _a['Jobs'][0]['xpAmounts']
        except Exception as e:
            logger.debug(e)
            jobs2_xpamounts =''
        try:
            jobs3_type = _a['Jobs'][0]['jobType']
        except Exception as e:
            logger.debug(e)
            jobs3_type = ''
        try:
            jobs3_rewards = _a['Jobs'][0]['rewards']
        except Exception as e:
            logger.debug(e)
            jobs3_rewards =''
        try:
            jobs3_masteryreq = _a['Jobs'][0]['masteryReq']
        except Exception as e:
            logger.debug(e)
            jobs3_masteryreq =''
        try:
            jobs3_minenemylevel = _a['Jobs'][0]['minEnemyLevel']
        except Exception as e:
            logger.debug(e)
            jobs3_minenemylevel = ''
        try:
            jobs3_maxenemylevel = _a['Jobs'][0]['maxEnemyLevel']
        except Exception as e:
            logger.debug(e)
            jobs3_maxenemylevel = ''
        try:
            jobs3_xpamounts = _a['Jobs'][0]['xpAmounts']
            jobs3_xpamounts = ' '.join(jobs3_xpamounts)
        except Exception as e:
            logger.debug(e)
            jobs3_xpamounts =''
        select_sql = "SELECT oid  from  warframe_worldstate_SyndicateMissions WHERE oid = '%s' " % (oid)
        insert_sql = "INSERT INTO warframe_worldstate_SyndicateMissions(oid,activation_date,expiry_date,tag,seed,node,jobs1_type,jobs1_rewards,jobs1_masteryreq,jobs1_minenemylevel,jobs1_maxenemylevel,jobs1_xpamounts,jobs2_type,jobs2_rewards,jobs2_masteryreq,jobs2_minenemylevel,jobs2_maxenemylevel,jobs2_xpamounts,jobs3_type,jobs3_rewards,jobs3_masteryreq,jobs3_minenemylevel,jobs3_maxenemylevel,jobs3_xpamounts) VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s')" % (oid,activation_date,expiry_date,tag,seed,node,jobs1_type,jobs1_rewards,jobs1_masteryreq,jobs1_minenemylevel,jobs1_maxenemylevel,jobs1_xpamounts,jobs2_type,jobs2_rewards,jobs2_masteryreq,jobs2_minenemylevel,jobs2_maxenemylevel,jobs2_xpamounts,jobs3_type,jobs3_rewards,jobs3_masteryreq,jobs3_minenemylevel,jobs3_maxenemylevel,jobs3_xpamounts)
        res = opm.op_select(select_sql)
        if isinstance(res, tuple):
            ree = opm.op_insert(insert_sql)
    opm.dispose()
def worldstate_ActiveMissions():
    opm = OPMysql()
    for _a in world_state['ActiveMissions']:
        oid = _a['_id']['$oid']
        activation_date = _a['Activation']['$date']['$numberLong']
        expiry_date = _a['Expiry']['$date']['$numberLong']
        Region = _a['Region']
        Seed = _a['Seed']
        Node = _a['Node']
        MissionType = _a['MissionType']
        Modifier = _a['Modifier']
        select_sql = "SELECT oid  from  warframe_worldstate_ActiveMissions WHERE oid = '%s' " % (oid)
        insert_sql = "INSERT INTO warframe_worldstate_ActiveMissions(oid,activation_date,expiry_date,Region,Seed,Node,MissionType,Modifier) VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s')" % (oid,activation_date,expiry_date,Region,Seed,Node,MissionType,Modifier)
        res = opm.op_select(select_sql)
        if isinstance(res,tuple):
            ree = opm.op_insert(insert_sql)
    opm.dispose()
def worldstate_FlashSales():
    opm = OPMysql()
    for _a in world_state['FlashSales']:
        TypeName = _a['TypeName']
        StartDate = _a['StartDate']['$date']['$numberLong']
        EndDate = _a['EndDate']['$date']['$numberLong']
        Featured = _a['Featured']
        Popular = _a['Popular']
        ShowInMarket = _a['ShowInMarket']
        BannerIndex = _a['BannerIndex']
        Discount = _a['Discount']
        RegularOverride = _a['RegularOverride']
        PremiumOverride = _a['PremiumOverride']
        BogoBuy = _a['BogoBuy']
        BogoGet = _a['BogoGet']
        select_sql = "SELECT TypeName  from  warframe_worldstate_FlashSales WHERE TypeName = '%s' " % (TypeName)
        insert_sql = "INSERT INTO warframe_worldstate_FlashSales(TypeName ,StartDate ,EndDate ,Featured ,Popular ,ShowInMarket ,BannerIndex,Discount,RegularOverride,PremiumOverride ,BogoBuy,BogoGet) VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s')" % (
            TypeName, StartDate, EndDate, Featured, Popular, ShowInMarket, BannerIndex, Discount, RegularOverride,
            PremiumOverride, BogoBuy, BogoGet)
        res = opm.op_select(select_sql)
        if isinstance(res, tuple):
            ree = opm.op_insert(insert_sql)
    opm.dispose()


def worldstate_Invasions():
    opm = OPMysql()
    for _a in world_state['Invasions']:
        Oid = _a['_id']['$oid']
        Activation_Date = _a['Activation']['$date']['$numberLong']
        Faction = _a['Faction']
        Node = _a['Node']
        Count = _a['Count']
        Goal = _a['Goal']
        LocTag = _a['LocTag']
        Completed = _a['Completed']
        try:
            AttackerReward_countedItems_ItemType = _a['AttackerReward']['countedItems'][0]['ItemType']
        except Exception as e:
            logger.debug(e)
            AttackerReward_countedItems_ItemType =''
        try:
            AttackerReward_countedItems_ItemCount = _a['AttackerReward']['countedItems'][0]['ItemCount']
        except Exception as e:
            logger.debug(e)
            AttackerReward_countedItems_ItemCount = ''
        AttackerMissionInfo_seed = _a['AttackerMissionInfo']['seed']
        AttackerMissionInfo_faction = _a['AttackerMissionInfo']['faction']
        DefenderReward_countedItems_ItemType = _a['DefenderReward']['countedItems'][0]['ItemType']
        DefenderReward_countedItems_ItemCount = _a['DefenderReward']['countedItems'][0]['ItemCount']
        DefenderMissionInfo_seed = _a['DefenderMissionInfo']['seed']
        DefenderMissionInfo_faction = _a['DefenderMissionInfo']['faction']
        select_sql = "SELECT Oid  from  warframe_worldstate_Invasions WHERE Oid = '%s' " % (Oid)
        insert_sql = "INSERT INTO warframe_worldstate_Invasions(Oid ,Activation_Date ,Faction ,Node ,Count ,Goal ,LocTag ,Completed ,AttackerReward_countedItems_ItemType ,AttackerReward_countedItems_ItemCount ,AttackerMissionInfo_seed ,AttackerMissionInfo_faction ,DefenderReward_countedItems_ItemType ,DefenderReward_countedItems_ItemCount ,DefenderMissionInfo_seed ,DefenderMissionInfo_faction) VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s')" % (Oid ,Activation_Date ,Faction ,Node ,Count ,Goal ,LocTag ,Completed ,AttackerReward_countedItems_ItemType ,AttackerReward_countedItems_ItemCount ,AttackerMissionInfo_seed ,AttackerMissionInfo_faction ,DefenderReward_countedItems_ItemType ,DefenderReward_countedItems_ItemCount ,DefenderMissionInfo_seed ,DefenderMissionInfo_faction)
        update_sql = "UPDATE warframe_worldstate_Invasions SET Activation_Date = '%s' ,Faction = '%s' ,Node = '%s' ,Count = '%s' ,Goal = '%s' ,LocTag = '%s' ,Completed = '%s' ,AttackerReward_countedItems_ItemType = '%s' ,AttackerReward_countedItems_ItemCount = '%s' ,AttackerMissionInfo_seed = '%s' ,AttackerMissionInfo_faction = '%s' ,DefenderReward_countedItems_ItemType = '%s' ,DefenderReward_countedItems_ItemCount = '%s' ,DefenderMissionInfo_seed = '%s' ,DefenderMissionInfo_faction = '%s' WHERE Oid = '%s'"% (Activation_Date ,Faction ,Node ,Count ,Goal ,LocTag ,Completed ,AttackerReward_countedItems_ItemType ,AttackerReward_countedItems_ItemCount ,AttackerMissionInfo_seed ,AttackerMissionInfo_faction ,DefenderReward_countedItems_ItemType ,DefenderReward_countedItems_ItemCount ,DefenderMissionInfo_seed ,DefenderMissionInfo_faction,Oid)
        res = opm.op_select(select_sql)
        if isinstance(res, tuple):
            ree = opm.op_insert(insert_sql)
        else:
            ree = opm.op_insert(update_sql)
    opm.dispose()

def wordstate_VoidTraders():
    logger.debug("world_state['VoidTraders']↓")
    logger.debug(world_state['VoidTraders'])
    opm = OPMysql()
    for _a in world_state['VoidTraders']:
        Oid = _a['_id']['$oid']
        Activation_date = _a['Activation']['$date']['$numberLong']
        Expiry_date = _a['Expiry']['$date']['$numberLong']
        Characters = _a['Character']
        print(Characters)
        Characters = Characters.replace("'"," ")
        Node = _a['Node']
        select_sql = "SELECT Oid  from  warframe_worldstate_VoidTraders WHERE Oid = '%s' " % (Oid)
        insert_sql = "INSERT INTO warframe_worldstate_VoidTraders(Oid,Activation_date,Expiry_date, Characters , Node ) VALUES ('%s', '%s', '%s', '%s', '%s' )" % (Oid,Activation_date,Expiry_date,Characters,Node)
        res = opm.op_select(select_sql)
        if isinstance(res, tuple):
            ree = opm.op_insert(insert_sql)
    opm.dispose()

wordstate_VoidTraders()


#oid,activation_date,expiry_date,boss,reward,extradrops,seed,mission1_type,mission1_modifiertype,mission1_node,mission1_tilelset,mission2_type,mission2_modifiertype,mission2_node,mission2_tilelset,mission3_type,mission3_modifiertype,mission3_node,mission3_tilelset
#wordstate_sorties()
#worldstate_events()
#wordstate_alerts()
#worldstate_ActiveMissions()
#wordstate_SyndicateMissions()
#worldstate_FlashSales()
#wordstate_SyndicateMissions()
#worldstate_Invasions()
##ssssssssssssss
#if __name__ =# = '__main__':
#    #申请资源
#    opm = OPMysql()
#
#    sql = "select * from t_alerts_history_data  WHERE  id > 100 ;"
#    res = opm.op_select(sql)
#
#    #释放资源
#    opm.dispose()