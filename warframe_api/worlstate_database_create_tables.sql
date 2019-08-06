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

CREATE TABLE `warframe_worldstate_alerts` (
`oid` varchar(200) NOT NULL ,
`activation_date` varchar(200) NOT NULL ,
`expiry_date` varchar(200) NOT NULL ,
`missiontype` varchar(200) NOT NULL ,
`faction` varchar(200) NOT NULL ,
`location` varchar(200) NOT NULL ,
`leveloverride` varchar(200) NOT NULL ,
`enemyspec` varchar(200) NOT NULL ,
`minenemylevel` varchar(200) NOT NULL ,
`maxenemylevel` varchar(200) NOT NULL ,
`difficulty` varchar(200) NOT NULL ,
`seed` varchar(200) NOT NULL ,
`mission_reward_credits` varchar(200) NOT NULL ,
`mission_reward_items` varchar(200) NOT NULL ,
`mission_reward_itemtype` varchar(200) NOT NULL ,
`mission_reward_itemcount` varchar(200) NOT NULL ,
`nightmare` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='警报';

CREATE TABLE `warframe_worldstate_sorties` (
`oid` varchar(200) NOT NULL ,
`activation_date` varchar(200) NOT NULL ,
`expiry_date` varchar(200) NOT NULL ,
`boss` varchar(200) NOT NULL ,
`reward` varchar(200) NOT NULL ,
`extradrops` varchar(200) NOT NULL ,
`seed` varchar(200) NOT NULL ,
`mission1_type` varchar(200) NOT NULL ,
`mission1_modifiertype` varchar(200) NOT NULL ,
`mission1_node` varchar(200) NOT NULL ,
`mission1_tileset` varchar(200) NOT NULL ,
`mission2_type` varchar(200) NOT NULL ,
`mission2_modifiertype` varchar(200) NOT NULL ,
`mission2_node` varchar(200) NOT NULL ,
`mission2_tileset` varchar(200) NOT NULL ,
`mission3_type` varchar(200) NOT NULL ,
`mission3_modifiertype` varchar(200) NOT NULL ,
`mission3_node` varchar(200) NOT NULL ,
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