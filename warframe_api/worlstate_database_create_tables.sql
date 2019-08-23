CREATE TABLE `t_alerts_history_data` (
  `id` varchar(20) NOT NULL COMMENT ' id',
  `oid` varchar(20) NOT NULL COMMENT '我也不知道是啥',
  `activation` varchar(20) DEFAULT NULL COMMENT '开始时间unix',
  `expiry` varchar(100) DEFAULT NULL COMMENT '结束时间 ',
  `node` varchar(30) DEFAULT NULL COMMENT ' 地点',
  `enemyLevel` varchar(20) DEFAULT NULL COMMENT '敌人等级',
  `missionType` varchar(20) DEFAULT NULL COMMENT '任务类型',
  `rewards` varchar(20) DEFAULT NULL COMMENT '奖励',
  `world` varchar(20) DEFAULT NULL COMMENT '服务器',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='历史数据';

CREATE TABLE `warframe_worldstate_Alerts` (
  `Oid` varchar(200) NOT NULL,
  `Activation_date` varchar(200) NOT NULL,
  `Expiry_date` varchar(200) NOT NULL,
  `Missiontype` varchar(200) NOT NULL,
  `Faction` varchar(200) NOT NULL,
  `Location` varchar(200) NOT NULL,
  `Leveloverride` varchar(200) NOT NULL,
  `Enemyspec` varchar(200) NOT NULL,
  `Minenemylevel` varchar(200) NOT NULL,
  `Maxenemylevel` varchar(200) NOT NULL,
  `Difficulty` varchar(200) NOT NULL,
  `Seed` varchar(200) NOT NULL,
  `Mission_reward_credits` varchar(200) NOT NULL,
  `Mission_reward_items` varchar(200) NOT NULL,
  `Mission_reward_itemtype` varchar(200) NOT NULL,
  `Mission_reward_itemcount` varchar(200) NOT NULL,
  `nightmare` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='警报';

CREATE TABLE `warframe_worldstate_Sorties` (
  `Oid` varchar(200) NOT NULL,
  `Activation_date` varchar(200) NOT NULL,
  `Expiry_date` varchar(200) NOT NULL,
  `Boss` varchar(200) NOT NULL,
  `Reward` varchar(200) NOT NULL,
  `Extradrops` varchar(200) NOT NULL,
  `Seed` varchar(200) NOT NULL,
  `Mission1_type` varchar(200) NOT NULL,
  `Mission1_modifiertype` varchar(200) NOT NULL,
  `Mission1_node` varchar(200) NOT NULL,
  `Mission1_tileset` varchar(200) NOT NULL,
  `Mission2_type` varchar(200) NOT NULL,
  `Mission2_modifiertype` varchar(200) NOT NULL,
  `Mission2_node` varchar(200) NOT NULL,
  `Mission2_tileset` varchar(200) NOT NULL,
  `mission3_type` varchar(200) NOT NULL,
  `mission3_modifiertype` varchar(200) NOT NULL,
  `mission3_node` varchar(200) NOT NULL,
  `mission3_tileset` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='突击';


CREATE TABLE `warframe_worldstate_SyndicateMissions` (
`oid` varchar(200) NOT NULL ,
`activation_date` varchar(200) NOT NULL ,
`expiry_date` varchar(200) NOT NULL ,
`tag` varchar(200) NOT NULL ,
`seed` varchar(200) NOT NULL ,
`node` varchar(200) NOT NULL ,
`jobs1_type` varchar(200) NOT NULL ,
`jobs1_rewards` varchar(200) NOT NULL ,
`jobs1_masteryreq` varchar(200) NOT NULL ,
`jobs1_minenemylevel` varchar(200) NOT NULL ,
`jobs1_maxenemylevel` varchar(200) NOT NULL ,
`jobs1_xpamounts` varchar(200) NOT NULL COMMENT '声望',
`jobs2_type` varchar(200) NOT NULL ,
`jobs2_rewards` varchar(200) NOT NULL ,
`jobs2_masteryreq` varchar(200) NOT NULL ,
`jobs2_minenemylevel` varchar(200) NOT NULL ,
`jobs2_maxenemylevel` varchar(200) NOT NULL ,
`jobs2_xpamounts` varchar(200) NOT NULL COMMENT '声望' ,
`jobs3_type` varchar(200) NOT NULL ,
`jobs3_rewards` varchar(200) NOT NULL ,
`jobs3_masteryreq` varchar(200) NOT NULL ,
`jobs3_minenemylevel` varchar(200) NOT NULL ,
`jobs3_maxenemylevel` varchar(200) NOT NULL ,
`jobs3_xpamounts` varchar(200) NOT NULL COMMENT '声望'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='集团任务';

CREATE TABLE `warframe_worldstate_ActiveMissions` (
`oid` varchar(200) NOT NULL ,
`activation_date` varchar(200) NOT NULL ,
`expiry_date` varchar(200) NOT NULL ,
`Region` varchar(200) NOT NULL comment '区域',
`Seed` varchar(200) NOT NULL ,
`Node` varchar(200) NOT NULL ,
`MissionType` varchar(200) NOT NULL ,
`Modifier` varchar(200) NOT NULL COMMENT '备注'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='裂隙任务';

CREATE TABLE `warframe_worldstate_FlashSales` (
`TypeName` varchar(200) NOT NULL ,
`StartDate` varchar(200) NOT NULL ,
`EndDate` varchar(200) NOT NULL ,
`Featured` varchar(200) NOT NULL ,
`Popular` varchar(200) NOT NULL ,
`ShowInMarket` varchar(200) NOT NULL ,
`BannerIndex` varchar(200) NOT NULL,
`Discount` varchar(200) NOT NULL,
`RegularOverride` varchar(200) NOT NULL,
`PremiumOverride` varchar(200) NOT NULL ,
`BogoBuy` varchar(200) NOT NULL,
`BogoGet` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='折扣销售';

CREATE TABLE `warframe_worldstate_Invasions` (
`Oid` varchar(200) NOT NULL ,
`Activation_Date` varchar(200) NOT NULL ,
`Faction` varchar(200) NOT NULL ,
`Node` varchar(200) NOT NULL ,
`Count` varchar(200) NOT NULL ,
`Goal` varchar(200) NOT NULL ,
`LocTag` varchar(200) NOT NULL ,
`Completed` varchar(200) NOT NULL ,
`AttackerReward_countedItems_ItemType` varchar(200) NOT NULL ,
`AttackerReward_countedItems_ItemCount` varchar(200) NOT NULL ,
`AttackerMissionInfo_seed` varchar(200) NOT NULL ,
`AttackerMissionInfo_faction` varchar(200) NOT NULL ,
`DefenderReward_countedItems_ItemType` varchar(200) NOT NULL ,
`DefenderReward_countedItems_ItemCount` varchar(200) NOT NULL ,
`DefenderMissionInfo_seed` varchar(200) NOT NULL ,
`DefenderMissionInfo_faction` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='入侵';

CREATE TABLE `warframe_worldstate_VoidTraders` (
`Oid` varchar(200) NOT NULL ,
`Activation_date` varchar(200) NOT NULL ,
`Expiry_date` varchar(200) NOT NULL ,
`Character` varchar(200) NOT NULL comment '人物',
`Node` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='虚空商人';


CREATE TABLE `warframe_worldstate_Wordstate` (
`WorldSeed` varchar(600) NOT NULL ,
`Version` varchar(200) NOT NULL ,
`MobileVersion` varchar(200) NOT NULL ,
`BuildLabel` varchar(200) NOT NULL ,
`Time` varchar(200) NOT NULL ,
`Date` varchar(200) NOT NULL ,
`Goals` varchar(200) NOT NULL ,
`GlobalUpgrades` varchar(200) NOT NULL ,
`HubEvents` varchar(200) NOT NULL ,
`PrimeAccessAvailability_State` varchar(200) NOT NULL ,
`PrimeVaultAvailabilities_State1` varchar(200) NOT NULL ,
`PrimeVaultAvailabilities_State2` varchar(200) NOT NULL ,
`PrimeVaultAvailabilities_State3` varchar(200) NOT NULL ,
`LibraryInfo_LastCompletedTargetType` varchar(200) NOT NULL ,
`PersistentEnemies` varchar(200) NOT NULL ,
`PVPAlternativeModes` varchar(200) NOT NULL ,
`PVPActiveTournaments` varchar(200) NOT NULL ,
`ProjectPct` varchar(200) NOT NULL ,
`TwitchPromos` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='状态信息';

CREATE TABLE `warframe_worldstate_NodeOverrides` (
`Oid` varchar(200) NOT NULL ,
`Node` varchar(200) NOT NULL,
`Seed` varchar(200) NOT NULL ,
`Activation_date` varchar(200) NOT NULL ,
`Hide` varchar(200) NOT NULL ,
`LevelOverride` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='NodeOverrides';

CREATE TABLE `warframe_worldstate_DailyDeals` (
`StoreItem` varchar(200) NOT NULL ,
`Activation_date` varchar(200) NOT NULL ,
`Expiry_date` varchar(200) NOT NULL ,
`Discount` varchar(200) NOT NULL ,
`OriginalPrice` varchar(200) NOT NULL ,
`SalePrice` varchar(200) NOT NULL ,
`AmountTotal` varchar(200) NOT NULL ,
`AmountSold` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='DailyDeals';

CREATE TABLE `warframe_worldstate_Goals` (
`Oid` varchar(200) NOT NULL ,
`Activation_date` varchar(200) NOT NULL ,
`Expiry_date` varchar(200) NOT NULL ,
`HealthPct` varchar(200) NOT NULL ,
`VictimNode` varchar(200) NOT NULL ,
`Regions` varchar(200) NOT NULL ,
`Success` varchar(200) NOT NULL ,
`Desc` varchar(200) NOT NULL ,
`ToolTip` varchar(200) NOT NULL ,
`Icon` varchar(200) NOT NULL ,
`Tag` varchar(200) NOT NULL ,
`JobAffiliationTag` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Goals';

CREATE TABLE `warframe_worldstate_Goals_Jobs` (
`Oid` varchar(200) NOT NULL ,
`jobType` varchar(200) NOT NULL ,
`rewards` varchar(200) NOT NULL ,
`masteryReq` varchar(200) NOT NULL ,
`minEnemyLevel` varchar(200) NOT NULL ,
`maxEnemyLevel` varchar(200) NOT NULL ,
`xpAmounts` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Goals_Jobs';