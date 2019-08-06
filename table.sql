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
