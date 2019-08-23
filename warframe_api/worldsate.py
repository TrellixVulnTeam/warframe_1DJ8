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
#world_State = requests.get('http://192.168.6.192:8080/test1.json',headers={'User-Agent':'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.75 Safari/537.36',})
world_State = requests.get('http://content-zh.warframe.com.cn/dynamic/worldState.php',headers={'User-Agent':'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.75 Safari/537.36',})

world_State = world_State.json()
logger.info('world_State↓')
logger.debug(world_State)
#飞船新闻 world_State['Events']
#实时警报 world_State['Alerts']
#突击任务 world_State['Sorties']
#入侵任务 world_State['Invasions']
#虚空商人 world_State['VoidTraders']
#集团任务world_State['SyndicateMissions']
#world_State['PrimeAccessAvailability']
#world_State['PrimeVaultAvailabilities']
#world_State['PrimeAccessAvailability']
#world_State['PrimeVaultAvailabilities']

def worldstate_Events():
    opm = OPMysql()
    for i in world_State['Events']:
        Oid = i['_id']['$oid']
        Message = i['Messages'][0]['Message']
        Prop= i['Prop']
        Date = i['Date']['$date']['$numberLong']
        select_sql = "SELECT Oid  from  warframe_worldstate_Events WHERE Oid = '%s' " % (Oid)
        insert_sql = "INSERT INTO warframe_worldstate_Events(Oid,Message,Prop,Date) VALUES ('%s', '%s', '%s', '%s')" % (Oid,Message,Prop,Date)
        res = opm.op_select(select_sql)
        if isinstance(res,tuple):
            ree = opm.op_insert(insert_sql)
    opm.dispose()
    logger.info('worldstate_Events')

def wordstate_Alerts():
    opml = OPMysql()
    logger.info('world_State[\'Alerts\']')
    logger.debug(world_State['Alerts'])
    for _i in world_State['Alerts']:
        Oid = _i['_id']['$oid']
        Activation_date = _i['Activation']['$date']['$numberLong']
        Expiry_date = _i['Expiry']['$date']['$numberLong']
        Missiontype = _i['MissionInfo']['missionType']
        Faction = _i['MissionInfo']['faction']
        Location = _i['MissionInfo']['location']
        Leveloverride = _i['MissionInfo'][ 'levelOverride']
        Enemyspec = _i['MissionInfo'][ 'enemySpec']
        Minenemylevel =_i['MissionInfo']['minEnemyLevel']
        Maxenemylevel= _i['MissionInfo']['maxEnemyLevel']
        Difficulty = _i['MissionInfo']['difficulty']
        Seed = _i['MissionInfo']['seed']
        Mission_reward_credits = _i['MissionInfo']['missionReward']['credits']
        try:
            Mission_reward_items = _i['MissionInfo']['missionReward']['items'][0]
        except Exception as e:
            logger.debug(e)
            Mission_reward_items = ''
        try:
            Mission_reward_itemtype = _i['MissionInfo']['missionReward']['countedItems']['ItemType']
        except Exception as e:
            logger.debug(e)
            Mission_reward_itemtype = ''
        try:
            Mission_reward_itemcount = _i['MissionInfo']['missionReward']['countedItems']['ItemCount']
        except Exception as e:
            logger.debug(e)
            Mission_reward_itemcount = ''
        try:
            Nightmare = _i['MissionInfo']['nightmare']
        except Exception as e:
            logger.debug(e)
            Nightmare = ''
        select_sql = "SELECT Oid  from  warframe_worldstate_Alerts WHERE Oid = '%s' " % (Oid)
        insert_sql = "INSERT INTO warframe_worldstate_Alerts(Oid,Activation_date,Expiry_date,Missiontype,Faction,Location,Leveloverride,Enemyspec,Minenemylevel,Maxenemylevel,Difficulty,Seed,Mission_reward_credits,Mission_reward_items,Mission_reward_itemtype,Mission_reward_itemcount,Nightmare) VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s','%s', '%s', '%s','%s','%s')" % (Oid,Activation_date,Expiry_date,Missiontype,Faction,Location,Leveloverride,Enemyspec,Minenemylevel,Maxenemylevel,Difficulty,Seed,Mission_reward_credits,Mission_reward_items,Mission_reward_itemtype,Mission_reward_itemcount,Nightmare)
        res = opml.op_select(select_sql)
        if isinstance(res,tuple):
            ree = opml.op_insert(insert_sql)
    opml.dispose()
    logger.info('worldstate_Alerts')

def wordstate_Sorties():
    logger.info("world_State['Sorties']↓")
    logger.debug(world_State['Sorties'])
    opm = OPMysql()
    for _a in world_State['Sorties']:
        Oid = _a['_id']['$oid']
        Activation_date = _a['Activation']['$date']['$numberLong']
        Expiry_date = _a['Expiry']['$date']['$numberLong']
        Boss = _a['Boss']
        Reward = _a['Reward']
        Extradrops = _a['ExtraDrops']
        Seed = _a['Seed']
        Mission1_type = _a['Variants'][0]['missionType']
        Mission1_modifiertype = _a['Variants'][0]['modifierType']
        Mission1_node = _a['Variants'][0]['node']
        Mission1_tileset = _a['Variants'][0]['tileset']
        logger.debug(_a['Variants'][0])
        Mission2_type = _a['Variants'][1]['missionType']
        Mission2_modifiertype = _a['Variants'][1]['modifierType']
        Mission2_node = _a['Variants'][1]['node']
        Mission2_tileset = _a['Variants'][1]['tileset']
        Mission3_type = _a['Variants'][2]['missionType']
        Mission3_modifiertype = _a['Variants'][2]['modifierType']
        Mission3_node = _a['Variants'][2]['node']
        Mission3_tileset = _a['Variants'][2]['tileset']
        select_sql = "SELECT Oid  from  warframe_worldstate_Sorties WHERE Oid = '%s' " % (Oid)
        insert_sql = "INSERT INTO warframe_worldstate_Sorties(Oid,Activation_date,Expiry_date,Boss,Reward,Extradrops,Seed,Mission1_type,Mission1_modifiertype,Mission1_node,Mission1_tileset,Mission2_type,Mission2_modifiertype,Mission2_node,Mission2_tileset,Mission3_type,Mission3_modifiertype,Mission3_node,Mission3_tileset) VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s')" % (Oid,Activation_date,Expiry_date,Boss,Reward,Extradrops,Seed,Mission1_type,Mission1_modifiertype,Mission1_node,Mission1_tileset,Mission2_type,Mission2_modifiertype,Mission2_node,Mission2_tileset,Mission3_type,Mission3_modifiertype,Mission3_node,Mission3_tileset)
        res = opm.op_select(select_sql)
        if isinstance(res, tuple):
            ree = opm.op_insert(insert_sql)
    opm.dispose()
    logger.info('wordstate_Sorties')

def wordstate_SyndicateMissions():
    logger.debug(world_State['SyndicateMissions'])
    opm = OPMysql()
    for _a in world_State['SyndicateMissions']:
        Oid = _a['_id']['$oid']
        Activation_date = _a['Activation']['$date']['$numberLong']
        Expiry_date = _a['Expiry']['$date']['$numberLong']
        Tag = _a['Tag']
        Seed = _a['Seed']
        Node = _a['Nodes']
        Node = ' '.join(Node)
        try:
            Jobs1_type = _a['Jobs'][0]['jobType']
        except Exception as e:
            logger.debug(e)
            Jobs1_type = ''
        try:
            Jobs1_rewards = _a['Jobs'][0]['rewards']
        except Exception as e:
            logger.debug(e)
            Jobs1_rewards =''
        try:
            Jobs1_masteryreq = _a['Jobs'][0]['masteryReq']
        except Exception as e:
            logger.debug(e)
            Jobs1_masteryreq =''
        try:
            Jobs1_minenemylevel = _a['Jobs'][0]['minEnemyLevel']
        except Exception as e:
            logger.debug(e)
            Jobs1_minenemylevel = ''
        try:
            Jobs1_maxenemylevel = _a['Jobs'][0]['maxEnemyLevel']
        except Exception as e:
            logger.debug(e)
            Jobs1_maxenemylevel = ''
        try:
            Jobs1_xpamounts = _a['Jobs'][0]['xpAmounts']
        except Exception as e:
            logger.debug(e)
            Jobs1_xpamounts =''
        try:
            Jobs2_type = _a['Jobs'][0]['jobType']
        except Exception as e:
            logger.debug(e)
            Jobs2_type = ''
        try:
            Jobs2_rewards = _a['Jobs'][0]['rewards']
        except Exception as e:
            logger.debug(e)
            Jobs2_rewards =''
        try:
            Jobs2_masteryreq = _a['Jobs'][0]['masteryReq']
        except Exception as e:
            logger.debug(e)
            Jobs2_masteryreq =''
        try:
            Jobs2_minenemylevel = _a['Jobs'][0]['minEnemyLevel']
        except Exception as e:
            logger.debug(e)
            Jobs2_minenemylevel = ''
        try:
            Jobs2_maxenemylevel = _a['Jobs'][0]['maxEnemyLevel']
        except Exception as e:
            logger.debug(e)
            Jobs2_maxenemylevel = ''
        try:
            Jobs2_xpamounts = _a['Jobs'][0]['xpAmounts']
        except Exception as e:
            logger.debug(e)
            Jobs2_xpamounts =''
        try:
            Jobs3_type = _a['Jobs'][0]['jobType']
        except Exception as e:
            logger.debug(e)
            Jobs3_type = ''
        try:
            Jobs3_rewards = _a['Jobs'][0]['rewards']
        except Exception as e:
            logger.debug(e)
            Jobs3_rewards =''
        try:
            Jobs3_masteryreq = _a['Jobs'][0]['masteryReq']
        except Exception as e:
            logger.debug(e)
            Jobs3_masteryreq =''
        try:
            Jobs3_minenemylevel = _a['Jobs'][0]['minEnemyLevel']
        except Exception as e:
            logger.debug(e)
            Jobs3_minenemylevel = ''
        try:
            Jobs3_maxenemylevel = _a['Jobs'][0]['maxEnemyLevel']
        except Exception as e:
            logger.debug(e)
            Jobs3_maxenemylevel = ''
        try:
            Jobs3_xpamounts = _a['Jobs'][0]['xpAmounts']
            Jobs3_xpamounts = ' '.join(Jobs3_xpamounts)
        except Exception as e:
            logger.debug(e)
            Jobs3_xpamounts =''
        select_sql = "SELECT Oid  from  warframe_worldstate_SyndicateMissions WHERE Oid = '%s' " % (Oid)
        insert_sql = "INSERT INTO warframe_worldstate_SyndicateMissions(Oid,Activation_date,Expiry_date,Tag,Seed,Node,Jobs1_type,Jobs1_rewards,Jobs1_masteryreq,Jobs1_minenemylevel,Jobs1_maxenemylevel,Jobs1_xpamounts,Jobs2_type,Jobs2_rewards,Jobs2_masteryreq,Jobs2_minenemylevel,Jobs2_maxenemylevel,Jobs2_xpamounts,Jobs3_type,Jobs3_rewards,Jobs3_masteryreq,Jobs3_minenemylevel,Jobs3_maxenemylevel,Jobs3_xpamounts) VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s')" % (Oid,Activation_date,Expiry_date,Tag,Seed,Node,Jobs1_type,Jobs1_rewards,Jobs1_masteryreq,Jobs1_minenemylevel,Jobs1_maxenemylevel,Jobs1_xpamounts,Jobs2_type,Jobs2_rewards,Jobs2_masteryreq,Jobs2_minenemylevel,Jobs2_maxenemylevel,Jobs2_xpamounts,Jobs3_type,Jobs3_rewards,Jobs3_masteryreq,Jobs3_minenemylevel,Jobs3_maxenemylevel,Jobs3_xpamounts)
        res = opm.op_select(select_sql)
        if isinstance(res, tuple):
            ree = opm.op_insert(insert_sql)
    opm.dispose()
    logger.info('SyndicateMissions')
def worldstate_ActiveMissions():
    opm = OPMysql()
    for _a in world_State['ActiveMissions']:
        Oid = _a['_id']['$oid']
        Activation_date = _a['Activation']['$date']['$numberLong']
        Expiry_date = _a['Expiry']['$date']['$numberLong']
        Region = _a['Region']
        Seed = _a['Seed']
        Node = _a['Node']
        MissionType = _a['MissionType']
        Modifier = _a['Modifier']
        select_sql = "SELECT Oid  from  warframe_worldstate_ActiveMissions WHERE Oid = '%s' " % (Oid)
        insert_sql = "INSERT INTO warframe_worldstate_ActiveMissions(Oid,Activation_date,Expiry_date,Region,Seed,Node,MissionType,Modifier) VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s')" % (Oid,Activation_date,Expiry_date,Region,Seed,Node,MissionType,Modifier)
        res = opm.op_select(select_sql)
        if isinstance(res,tuple):
            ree = opm.op_insert(insert_sql)
    opm.dispose()
    logger.info('ActiveMissions')
def worldstate_FlashSales():
    opm = OPMysql()
    for _a in world_State['FlashSales']:
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
    logger.info('FlashSales')

def worldstate_Invasions():
    opm = OPMysql()
    for _a in world_State['Invasions']:
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
    logger.info('Invasions')

def wordstate_VoidTraders():
    logger.debug("world_State['VoidTraders']↓")
    logger.debug(world_State['VoidTraders'])
    opm = OPMysql()
    for _a in world_State['VoidTraders']:
        Oid = _a['_id']['$oid']
        Activation_date = _a['Activation']['$date']['$numberLong']
        Expiry_date = _a['Expiry']['$date']['$numberLong']
        Characters = _a['Character']
        Characters = Characters.replace("'"," ")
        Node = _a['Node']
        select_sql = "SELECT Oid  from  warframe_worldstate_VoidTraders WHERE Oid = '%s' " % (Oid)
        insert_sql = "INSERT INTO warframe_worldstate_VoidTraders(Oid,Activation_date,Expiry_date, Characters , Node ) VALUES ('%s', '%s', '%s', '%s', '%s' )" % (Oid,Activation_date,Expiry_date,Characters,Node)
        res = opm.op_select(select_sql)
        if isinstance(res, tuple):
            ree = opm.op_insert(insert_sql)
    opm.dispose()
    logger.info('VoidTraders')




def wordstate_Wordstate():
    opm = OPMysql()
    WorldSeed = world_State['WorldSeed']
    Version = world_State['Version']
    MobileVersion = world_State['MobileVersion']
    BuildLabel = world_State['BuildLabel']
    Time = world_State['Time']
    Date = world_State['Date']
    try:
        GlobalUpgrades = world_State['GlobalUpgrades']
    except Exception as e:
        logger.debug(e)
        GlobalUpgrades = ''
    try:
        HubEvents = world_State['HubEvents']
    except Exception as e:
        logger.debug(e)
        HubEvents = ''
    PrimeAccessAvailability_State = world_State['PrimeAccessAvailability']['State']
    try:
        PrimeVaultAvailabilities_State1 = world_State['PrimeVaultAvailabilities'][0]['State']
    except Exception as e:
        logger.debug(e)
        try:
            PrimeVaultAvailabilities_State1 = world_State['PrimeVaultAvailabilities']
        except Exception as e:
            logger.debug(e)
            PrimeVaultAvailabilities_State1 = 'unkown'

    try:
        PrimeVaultAvailabilities_State2 = world_State['PrimeVaultAvailabilities'][1]['State']
    except Exception as e:
        logger.debug(e)
        try:
            PrimeVaultAvailabilities_State2 = world_State['PrimeVaultAvailabilities']
        except Exception as e:
            logger.debug(e)
            PrimeVaultAvailabilities_State2 = 'unkown'
    try:
        PrimeVaultAvailabilities_State3 = world_State['PrimeVaultAvailabilities'][2]['State']
    except Exception as e:
        logger.debug(e)
        try:
            PrimeVaultAvailabilities_State3 = world_State['PrimeVaultAvailabilities']
        except Exception as e:
            logger.debug(e)
            PrimeVaultAvailabilities_State3 = 'unkown'
    LibraryInfo_LastCompletedTargetType = world_State['LibraryInfo']['LastCompletedTargetType']
    try:
        PersistentEnemies = world_State['PersistentEnemies']
    except Exception as e:
        logger.debug(e)
        PersistentEnemies = ''
    try:
        PVPAlternativeModes = world_State['PVPAlternativeModes']
    except Exception as e:
        logger.debug(e)
        PVPAlternativeModes = ''
    try:
        PVPActiveTournaments = world_State['PVPActiveTournaments']
    except Exception as e:
        logger.debug(e)
        PVPActiveTournaments = ''
    ProjectPct = world_State['ProjectPct']
    try:
        TwitchPromos = world_State['TwitchPromos']
    except Exception as e:
        logger.debug(e)
        TwitchPromos = ''

    select_sql = "SELECT Date  from  warframe_worldstate_Wordstate WHERE Date = '%s' " % (Date)
    insert_sql = "INSERT INTO warframe_worldstate_Wordstate(WorldSeed ,Version ,MobileVersion ,BuildLabel ,Time ,Date  ,GlobalUpgrades ,HubEvents ,PrimeAccessAvailability_State ,PrimeVaultAvailabilities_State1 ,PrimeVaultAvailabilities_State2 ,PrimeVaultAvailabilities_State3 ,LibraryInfo_LastCompletedTargetType ,PersistentEnemies ,PVPAlternativeModes ,PVPActiveTournaments ,ProjectPct ,TwitchPromos) VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s',  '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s')" % (WorldSeed ,Version ,MobileVersion ,BuildLabel ,Time ,Date ,GlobalUpgrades ,HubEvents ,PrimeAccessAvailability_State ,PrimeVaultAvailabilities_State1 ,PrimeVaultAvailabilities_State2 ,PrimeVaultAvailabilities_State3 ,LibraryInfo_LastCompletedTargetType ,PersistentEnemies ,PVPAlternativeModes ,PVPActiveTournaments ,ProjectPct ,TwitchPromos)
    res = opm.op_select(select_sql)
    if isinstance(res, tuple):
        ree = opm.op_insert(insert_sql)
    opm.dispose()
    logger.info('Wordstate')


def wordstate_NodeOverrides():
    opm = OPMysql()
    for _a in world_State['NodeOverrides']:
        Oid = _a['_id']['$oid']
        Node = _a['Node']
        try:
            Seed = _a['Seed']
        except Exception as e:
            logger.debug(e)
            Seed = ''
        try:
            Hide = _a['Hide']
        except Exception as e:
            logger.debug(e)
            Hide = ''
        try:
            LevelOverride = _a['LevelOverride']
        except Exception as e:
            logger.debug(e)
            LevelOverride = ''
        try:
            Activation_date = _a['Activation']['$date']['$numberLong']
        except Exception as e:
            logger.debug(e)
            Activation_date = ''
        select_sql = "SELECT Oid  from  warframe_worldstate_NodeOverrides WHERE Oid = '%s' " % (Oid)
        insert_sql = "INSERT INTO warframe_worldstate_NodeOverrides(Oid ,Node,Seed ,Activation_date ,Hide ,LevelOverride ) VALUES ('%s', '%s', '%s', '%s', '%s','%s' )" % (Oid ,Node,Seed ,Activation_date ,Hide ,LevelOverride)
        res = opm.op_select(select_sql)
        if isinstance(res, tuple):
            ree = opm.op_insert(insert_sql)
    opm.dispose()
    logger.info('NodeOverrides')


def wordstate_DailyDeals():
    opm = OPMysql()
    for _a in world_State['DailyDeals']:
        StoreItem = _a['StoreItem']
        Activation_date = _a['Activation']['$date']['$numberLong']
        Expiry_date = _a['Expiry']['$date']['$numberLong']
        Discount = _a['Discount']
        OriginalPrice = _a['OriginalPrice']
        SalePrice = _a['SalePrice']
        AmountTotal = _a['AmountTotal']
        AmountSold = _a['AmountSold']
        select_sql = "SELECT StoreItem  from  warframe_worldstate_DailyDeals WHERE StoreItem = '%s' " % (StoreItem)
        insert_sql = "INSERT INTO warframe_worldstate_DailyDeals(StoreItem ,Activation_date ,Expiry_date ,Discount ,OriginalPrice ,SalePrice ,AmountTotal ,AmountSold ) VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s'  )" % (StoreItem ,Activation_date ,Expiry_date ,Discount ,OriginalPrice ,SalePrice ,AmountTotal ,AmountSold)
        res = opm.op_select(select_sql)
        if isinstance(res, tuple):
            ree = opm.op_insert(insert_sql)
    opm.dispose()
    logger.info('wordstate_DailyDeals')



def wordstate_Goals():
    logger.debug("world_State['Goals']↓")
    logger.debug(world_State['Goals'])
    opm = OPMysql()
    for _a in world_State['Goals']:
        Oid = _a['_id']['$oid']
        Activation_date = _a['Activation']['$date']['$numberLong']
        Expiry_date = _a['Expiry']['$date']['$numberLong']
        HealthPct = _a['HealthPct']
        VictimNode = _a['VictimNode']
        Regions = _a['Regions']
        Success = _a['Success']
        Desc = _a['Desc']
        ToolTip = _a['ToolTip']
        Icon = _a['Icon']
        Tag = _a['Tag']
        JobAffiliationTag = _a['JobAffiliationTag']
        select_sql = "SELECT Oid  from  warframe_worldstate_VoidTraders WHERE Oid = '%s' " % (Oid)
        insert_sql = "INSERT INTO warframe_worldstate_VoidTraders(Oid ,Activation_date ,Expiry_date ,HealthPct ,VictimNode ,Regions ,Success ,Desc ,ToolTip ,Icon ,Tag ,JobAffiliationTag ) VALUES ('%s', '%s', '%s', '%s', '%s','%s', '%s', '%s', '%s', '%s', '%s' )" % (Oid ,Activation_date ,Expiry_date ,HealthPct ,VictimNode ,Regions ,Success ,Desc ,ToolTip ,Icon ,Tag ,JobAffiliationTag)
        res = opm.op_select(select_sql)
        if isinstance(res, tuple):
            ree = opm.op_insert(insert_sql)
    opm.dispose()
    logger.info('VoidTraders')



Oid ,Activation_date ,Expiry_date ,HealthPct ,VictimNode ,Regions ,Success ,Desc ,ToolTip ,Icon ,Tag ,JobAffiliationTag








wordstate_Sorties()
worldstate_Events()
wordstate_Alerts()
worldstate_ActiveMissions()
wordstate_SyndicateMissions()
worldstate_FlashSales()
wordstate_SyndicateMissions()
worldstate_Invasions()
wordstate_Wordstate()
wordstate_VoidTraders()
wordstate_NodeOverrides()

wordstate_DailyDeals()

#if __name__ =# = '__main__':
#    #申请资源
#    opm = OPMysql()
#
#    sql = "select * from t_alerts_history_data  WHERE  id > 100 ;"
#    res = opm.op_select(sql)
#
#    #释放资源
#    opm.dispose
