-- ============================================================
-- CPQ POC 评分引擎 + 工艺确认 — 完整数据库脚本
-- 数据库: Ruoyi_CPQ @ 8.148.208.235:3306
-- 日期:   2026-07-24
-- 内容:   6 张新表 DDL + 4 张审批表 DDL + 种子数据 + 1 个字段修改
-- ============================================================

-- ############################################################
-- Part 1: 新增 6 张表
-- ############################################################

-- ============================================================
-- 表1: cpq_dimension_def — 评分维度字典
-- 用途: 定义所有可能的评分维度标识和名称
-- 说明: 算法类型、算法参数、权重移至 cpq_scoring_weight，
--        本表退化为纯字典（评分引擎不直接读此表）
-- ============================================================
DROP TABLE IF EXISTS `cpq_dimension_def`;
CREATE TABLE `cpq_dimension_def` (
  `dimension_id` bigint NOT NULL,
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000',
  `dimension_code` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT '维度编码(全局唯一)',
  `dimension_name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '维度名称',
  `sort_order` int DEFAULT '0',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0',
  PRIMARY KEY (`dimension_id`),
  UNIQUE KEY `uk_dim_code` (`tenant_id`,`dimension_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ评分维度字典';


-- ============================================================
-- 表2: cpq_scoring_weight — ★ 核心评分配置
-- 用途: 按(产品线, 维度)定义算法类型+算法参数+权重
-- 说明: 评分引擎只读此表，不跨表查表1
--        不同产品线可独立配置:
--          - 维度集合（动力电池有"放电倍率"，锂原没有）
--          - 算法参数（尺寸容差锂原5% vs 动力2%）
-- ============================================================
DROP TABLE IF EXISTS `cpq_scoring_weight`;
CREATE TABLE `cpq_scoring_weight` (
  `weight_id` bigint NOT NULL,
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000',
  `category_id` bigint NOT NULL COMMENT '产品线ID → cpq_product_category',
  `dimension_code` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT '维度编码',
  `dimension_name` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '维度中文名',
  `score_type` varchar(30) COLLATE utf8mb4_general_ci NOT NULL COMMENT '算法类型',
  `score_formula` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '算法参数JSON',
  `dim_weight` decimal(5,2) NOT NULL COMMENT '权重百分比',
  `sort_order` int DEFAULT '0',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0',
  PRIMARY KEY (`weight_id`),
  UNIQUE KEY `uk_cat_dim` (`tenant_id`,`category_id`,`dimension_code`),
  KEY `idx_category` (`tenant_id`,`category_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ评分核心配置';


-- ============================================================
-- 表3: cpq_dimension_attr_mapping — 维度→产品属性绑定
-- 用途: 通过 dimension_code 关联权重表，指定每个评分维度
--        对应产品表中的哪些属性（分类+属性名）
-- ============================================================
DROP TABLE IF EXISTS `cpq_dimension_attr_mapping`;
CREATE TABLE `cpq_dimension_attr_mapping` (
  `mapping_id` bigint NOT NULL,
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000',
  `dimension_code` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT '→ cpq_scoring_weight.dimension_code',
  `product_attr_category` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '→ cpq_product_attribute.attr_category',
  `product_attr_name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '→ cpq_product_attribute.attr_name',
  `mapping_role` varchar(30) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'REQUIREMENT_INPUT / PRODUCT_COMPARE / BOTH',
  `sort_order` int DEFAULT '0',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0',
  PRIMARY KEY (`mapping_id`),
  UNIQUE KEY `uk_dim_attr` (`tenant_id`,`dimension_code`,`product_attr_category`,`product_attr_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ维度-产品属性映射';


-- ============================================================
-- 表4: cpq_match_config — 匹配引擎全局配置
-- 用途: 存储匹配引擎的运行时参数（阈值、TopN等）
-- ============================================================
DROP TABLE IF EXISTS `cpq_match_config`;
CREATE TABLE `cpq_match_config` (
  `config_id` bigint NOT NULL,
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000',
  `config_key` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'DEFAULT_THRESHOLD / TOP_N_COUNT / ENABLE_DIY_SUGGESTION / SCORE_PRECISION / MAX_REMATCH_ROUNDS',
  `config_value` varchar(500) COLLATE utf8mb4_general_ci NOT NULL,
  `config_type` varchar(20) COLLATE utf8mb4_general_ci DEFAULT 'STRING' COMMENT 'NUMBER / STRING / BOOLEAN',
  `category_id` bigint DEFAULT NULL COMMENT 'NULL=全局，非NULL=产品线级覆盖',
  `description` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0',
  PRIMARY KEY (`config_id`),
  UNIQUE KEY `uk_cfg` (`tenant_id`,`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ匹配引擎全局配置';


-- ============================================================
-- 表5: cpq_match_result — 匹配评分结果审计
-- 用途: 记录每次 match_product 调用的完整输入输出
-- ============================================================
DROP TABLE IF EXISTS `cpq_match_result`;
CREATE TABLE `cpq_match_result` (
  `result_id` bigint NOT NULL,
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000',
  `session_id` varchar(64) COLLATE utf8mb4_general_ci NOT NULL COMMENT '会话ID',
  `category_id` bigint DEFAULT NULL COMMENT '产品线ID',
  `requirement_json` json NOT NULL COMMENT '客户原始需求JSON',
  `scored_json` json NOT NULL COMMENT '评分结果JSON(含Top10详情)',
  `threshold_passed` char(1) COLLATE utf8mb4_general_ci DEFAULT '1' COMMENT '是否达标',
  `suggest_diy` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '是否建议转定制',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`result_id`),
  UNIQUE KEY `uk_session` (`tenant_id`,`session_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ匹配评分结果审计';


-- ============================================================
-- 表6: cpq_process_confirm — ★ 工艺确认单（核心业务表）
-- 用途: 记录销售选择产品 → 工艺确认 → 替代推荐的完整流程
--       关联审批链，存储客户需求自然语言描述
-- ============================================================
DROP TABLE IF EXISTS `cpq_process_confirm`;
CREATE TABLE `cpq_process_confirm` (
  `confirm_id` bigint NOT NULL COMMENT '确认单ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000',
  `result_id` bigint NOT NULL COMMENT '→ cpq_match_result.result_id',
  `model_id` bigint NOT NULL COMMENT '→ cpq_product_model.model_id',
  `approval_chain_id` bigint DEFAULT NULL COMMENT '→ cpq_approval_chain.chain_id',
  `confirm_status` varchar(20) COLLATE utf8mb4_general_ci DEFAULT 'PENDING' COMMENT 'PENDING / CONFIRMED / REJECTED',
  `confirm_by` bigint DEFAULT NULL COMMENT '确认人ID',
  `confirm_time` datetime DEFAULT NULL COMMENT '确认时间',
  `reject_reason` varchar(1000) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '驳回原因',
  `requirement_text` varchar(2000) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '客户需求自然语言描述(Agent确认后的原文)',
  `replaced_model_id` bigint DEFAULT NULL COMMENT '工艺替代推荐产品ID',
  `replaced_reason` varchar(1000) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '替代推荐理由',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`confirm_id`),
  UNIQUE KEY `uk_result_model` (`tenant_id`,`result_id`,`model_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ订单可行性确认';


-- ============================================================
-- 表修改: cpq_product_model — 新增产品高清主图URL
-- ============================================================
-- ALTER TABLE `cpq_product_model`
--   ADD COLUMN `image_url` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '产品高清主图URL'
--   AFTER `thumbnail_url`;


-- ############################################################
-- Part 2: 审批相关表（已有，POC 复用，此处提供 DDL 参考）
-- ############################################################

-- cpq_approval_chain: 审批链主表（审批流程实例）
-- cpq_approval_record: 审批记录（每个审批人的待办/已办）
-- cpq_approval_rule: 审批规则定义
-- cpq_approval_matrix: 审批矩阵（按维度确定审批人）


-- ############################################################
-- Part 3: 种子数据
-- ############################################################

-- 维度字典（7个维度）
INSERT INTO `cpq_dimension_def` (dimension_id, tenant_id, dimension_code, dimension_name, sort_order, status) VALUES
(1, '000000', 'SIZE_MATCH',     '尺寸合规',     1, '0'),
(2, '000000', 'USAGE_MATCH',    '用途场景匹配', 2, '0'),
(3, '000000', 'TEMP_MATCH',     '温度范围覆盖', 3, '0'),
(4, '000000', 'LIFE_MATCH',     '寿命满足',     4, '0'),
(5, '000000', 'SEAL_MATCH',     '密封性匹配',   5, '0'),
(6, '000000', 'CERT_MATCH',     '认证匹配',     6, '0'),
(7, '000000', 'BONUS',          '综合加分',     7, '0');


-- 锂原电池(分类ID=507) 7维权重配置
INSERT INTO `cpq_scoring_weight` (weight_id, tenant_id, category_id, dimension_code, dimension_name, score_type, score_formula, dim_weight, sort_order, status) VALUES
(1, '000000', 507, 'SIZE_MATCH',   '尺寸合规',     'RANGE_COVER',      '{"tolerance":5}',                                    35.00, 1, '0'),
(2, '000000', 507, 'USAGE_MATCH',  '用途场景匹配', 'ENUM_HIERARCHY',   '{"hierarchy":{"智能表计":["智能水表","智能燃气表","智能电表"],"安防报警":["安防","ETC","报警器"],"物联网":["GPS追踪","环境监测","NB-IoT"],"工业":["PLC","CNC","RTU"],"医疗":["医疗设备","紧急发射器"],"汽车":["汽车电子","TPMS"],"其他":["RTC","记忆备份"]}}', 15.00, 2, '0'),
(3, '000000', 507, 'TEMP_MATCH',   '温度范围覆盖', 'RANGE_COVER',      '{"tolerance":0}',                                    15.00, 3, '0'),
(4, '000000', 507, 'LIFE_MATCH',   '寿命满足',     'NUMERIC_SCALE',    '{"direction":"gte"}',                                12.00, 4, '0'),
(5, '000000', 507, 'SEAL_MATCH',   '密封性匹配',   'ENUM_MATCH',       '{"rankMap":{"NONE":0,"IP54":3,"IP65":4,"IP67":6,"IP68":7,"IP69K":8}}', 10.00, 5, '0'),
(6, '000000', 507, 'CERT_MATCH',   '认证匹配',     'CERT_CHAIN',       '{"rankMap":{"CE":10,"RoHS":20,"UL1642":30,"UN38.3":40,"IEC60086":50,"ATEX":60}}', 8.00, 6, '0'),
(7, '000000', 507, 'BONUS',        '综合加分',     'BONUS_COMPOSITE',  '{"fields":["min_order_qty","lead_time_days","stock_available"]}', 5.00, 7, '0');


-- 维度→产品属性映射
INSERT INTO `cpq_dimension_attr_mapping` (mapping_id, tenant_id, dimension_code, product_attr_category, product_attr_name, mapping_role) VALUES
(1,  '000000', 'SIZE_MATCH',   '物理规格', '外形长度',     'BOTH'),
(2,  '000000', 'SIZE_MATCH',   '物理规格', '外形宽度',     'BOTH'),
(3,  '000000', 'SIZE_MATCH',   '物理规格', '外形高度',     'BOTH'),
(4,  '000000', 'USAGE_MATCH',  '应用信息', '适用场景',     'PRODUCT_COMPARE'),
(5,  '000000', 'TEMP_MATCH',   '电气性能', '工作温度下限', 'PRODUCT_COMPARE'),
(6,  '000000', 'TEMP_MATCH',   '电气性能', '工作温度上限', 'PRODUCT_COMPARE'),
(7,  '000000', 'LIFE_MATCH',   '电气性能', '使用寿命(年)', 'PRODUCT_COMPARE'),
(8,  '000000', 'SEAL_MATCH',   '机械性能', '防护等级',     'BOTH'),
(9,  '000000', 'CERT_MATCH',   '认证信息', '认证列表',     'PRODUCT_COMPARE'),
(10, '000000', 'BONUS',        '商务信息', '最小起订量',   'PRODUCT_COMPARE'),
(11, '000000', 'BONUS',        '供应链',   '标准交期(天)', 'PRODUCT_COMPARE'),
(12, '000000', 'BONUS',        '供应链',   '现货库存',     'PRODUCT_COMPARE');


-- 匹配引擎全局配置
INSERT INTO `cpq_match_config` (config_id, tenant_id, config_key, config_value, config_type, description) VALUES
(1, '000000', 'DEFAULT_THRESHOLD',     '70',   'NUMBER',  '默认匹配阈值(70分)'),
(2, '000000', 'TOP_N_COUNT',           '10',   'NUMBER',  '推荐TopN数量'),
(3, '000000', 'ENABLE_DIY_SUGGESTION', 'true', 'BOOLEAN', '低于阈值提示转定制'),
(4, '000000', 'SCORE_PRECISION',       '2',    'NUMBER',  '评分精度(小数位)'),
(5, '000000', 'MAX_REMATCH_ROUNDS',    '2',    'NUMBER',  '最大重匹配轮数');


-- 审批规则: 锂原标品匹配推荐确认
INSERT INTO `cpq_approval_rule` (rule_id, tenant_id, rule_name, trigger_type, approval_chain_json, status, del_flag) VALUES
(100, '000000', '锂原标品匹配推荐确认', 'ALWAYS', '[]', '0', '0');

-- 审批矩阵: process_scheduler 角色审批（匹配推荐场景）
INSERT INTO `cpq_approval_matrix` (matrix_id, tenant_id, dimension_type, dimension_value, approver_role, min_approvals, status, del_flag) VALUES
(1, '000000', 'PRODUCT_LINE', '507', 'process_scheduler', 1, '0', '0');

-- 产品列表查询性能优化索引
CREATE INDEX IF NOT EXISTS idx_cat_status ON cpq_product_model(category_id, status, del_flag);
