-- MySQL dump 10.13  Distrib 9.6.0, for macos26.4 (arm64)
--
-- Host: localhost    Database: Ruoyi_CPQ
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `cpq_abac_policy`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_abac_policy` (
  `policy_id` bigint NOT NULL COMMENT '策略ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户编号',
  `policy_name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '策略名称',
  `policy_type` varchar(30) COLLATE utf8mb4_general_ci NOT NULL COMMENT '策略类型: COST_VISIBILITY/REGION_SCOPE/PRODUCT_LINE_SCOPE',
  `subject_type` varchar(20) COLLATE utf8mb4_general_ci NOT NULL COMMENT '主体类型: ROLE/USER/DEPT',
  `subject_value` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '主体值(role_key/user_id/dept_id)',
  `attribute_key` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT '属性键: cost_visibility_level/region_list/product_line_list',
  `attribute_value` varchar(500) COLLATE utf8mb4_general_ci NOT NULL COMMENT '属性值: 0-3/csv列表/csv列表',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '状态(0启用 1停用)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  PRIMARY KEY (`policy_id`),
  KEY `idx_tenant` (`tenant_id`),
  KEY `idx_subject` (`tenant_id`,`subject_type`,`subject_value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ ABAC策略表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_account`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_account` (
  `account_id` bigint NOT NULL COMMENT '客户ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `account_name` varchar(200) COLLATE utf8mb4_general_ci NOT NULL COMMENT '客户名称',
  `account_code` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT '客户编码',
  `account_type` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '客户类型: DIRECT/CHANNEL/PARTNER/ENTERPRISE',
  `industry` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '行业',
  `region` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '区域',
  `contact_name` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '联系人',
  `contact_phone` varchar(30) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '联系电话',
  `contact_email` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '联系邮箱',
  `legal_representative` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '法人代表',
  `unified_social_credit_code` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '统一社会信用代码',
  `address` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '地址',
  `tax_id` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '税号',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`account_id`),
  UNIQUE KEY `uk_tenant_code` (`tenant_id`,`account_code`),
  KEY `idx_name` (`tenant_id`,`account_name`),
  KEY `idx_region` (`tenant_id`,`region`),
  KEY `idx_industry` (`tenant_id`,`industry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ客户';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_agreement_price`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_agreement_price` (
  `agreement_id` bigint NOT NULL COMMENT '协议价ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `account_id` bigint NOT NULL COMMENT '客户ID(FK→cpq_account)',
  `model_id` bigint NOT NULL COMMENT '产品ID(FK→cpq_product_model)',
  `item_code` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '物料编码(可选, 用于配件级协议价)',
  `agreement_price` decimal(18,2) NOT NULL COMMENT '协议价格',
  `discount_pct` decimal(5,2) DEFAULT NULL COMMENT '协议折扣率(%)',
  `effective_date` date NOT NULL COMMENT '生效日期',
  `expiry_date` date DEFAULT NULL COMMENT '失效日期',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`agreement_id`),
  KEY `idx_account` (`tenant_id`,`account_id`),
  KEY `idx_model` (`tenant_id`,`model_id`),
  KEY `idx_date` (`tenant_id`,`effective_date`,`expiry_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ客户协议价(大客户/渠道商与厂商签订的固定价格协议)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_approval_chain`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_approval_chain` (
  `chain_id` bigint NOT NULL COMMENT '审批链ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `quote_id` bigint NOT NULL COMMENT '报价单ID(FK→cpq_quote)',
  `rule_id` bigint DEFAULT NULL COMMENT '触发的审批规则ID(FK→cpq_approval_rule)',
  `current_step` int DEFAULT '1' COMMENT '当前审批步骤',
  `total_steps` int NOT NULL COMMENT '总步骤数',
  `status` varchar(20) COLLATE utf8mb4_general_ci DEFAULT 'IN_PROGRESS' COMMENT '状态: IN_PROGRESS/APPROVED/REJECTED/CANCELLED/EXPIRED',
  `submitted_by` bigint NOT NULL COMMENT '提交人ID',
  `submitted_time` datetime NOT NULL COMMENT '提交时间',
  `completed_time` datetime DEFAULT NULL COMMENT '完成时间',
  `sla_hours` int DEFAULT '48' COMMENT 'SLA超时(小时)',
  PRIMARY KEY (`chain_id`),
  KEY `idx_quote` (`tenant_id`,`quote_id`),
  KEY `idx_status` (`tenant_id`,`status`),
  KEY `idx_submitted` (`tenant_id`,`submitted_by`,`submitted_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ审批链(审批规则实例化, 记录每轮审批的完整上下文)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_approval_matrix`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_approval_matrix` (
  `matrix_id` bigint NOT NULL COMMENT '矩阵ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `dimension_type` varchar(30) COLLATE utf8mb4_general_ci NOT NULL COMMENT '维度类型: REGION/DEPT/AMOUNT_RANGE/PRODUCT_LINE/QUOTE_TYPE',
  `dimension_value` varchar(200) COLLATE utf8mb4_general_ci NOT NULL COMMENT '维度值(区域代码/部门ID/金额区间/产品线/报价类型)',
  `approver_role` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '审批人角色(role_key)',
  `approver_ids` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '审批人ID列表(逗号分隔, 用于指定固定审批人)',
  `min_approvals` int DEFAULT '1' COMMENT '最少审批通过数(并行审批时)',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`matrix_id`),
  UNIQUE KEY `uk_dimension` (`tenant_id`,`dimension_type`,`dimension_value`),
  KEY `idx_type` (`tenant_id`,`dimension_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ审批矩阵(按区域/部门/金额/产品线/报价类型确定审批人)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_approval_record`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_approval_record` (
  `record_id` bigint NOT NULL COMMENT '记录ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `chain_id` bigint NOT NULL COMMENT '审批链ID(FK→cpq_approval_chain)',
  `step_number` int NOT NULL COMMENT '步骤号',
  `approver_id` bigint NOT NULL COMMENT '审批人ID',
  `approver_name` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '审批人姓名(冗余)',
  `action` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '审批动作: APPROVE/CONDITIONAL_APPROVE/REJECT/TRANSFER(转审)/DELEGATE(委托)/ADD_SIGNER(加签)',
  `comment` varchar(1000) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '审批意见',
  `action_time` datetime DEFAULT NULL COMMENT '动作时间',
  `sla_deadline` datetime DEFAULT NULL COMMENT 'SLA截止时间',
  PRIMARY KEY (`record_id`),
  KEY `idx_chain` (`tenant_id`,`chain_id`),
  KEY `idx_approver` (`tenant_id`,`approver_id`,`action_time`),
  KEY `idx_sla` (`tenant_id`,`sla_deadline`,`action`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ审批记录(每步审批动作全记录: 通过/条件通过/驳回/转审/委托/加签)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_approval_rule`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_approval_rule` (
  `rule_id` bigint NOT NULL COMMENT '规则ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `rule_name` varchar(200) COLLATE utf8mb4_general_ci NOT NULL COMMENT '规则名称',
  `trigger_type` varchar(30) COLLATE utf8mb4_general_ci NOT NULL COMMENT '触发类型: DISCOUNT_EXCEED(折扣超标)/MARGIN_BELOW(毛利过低)/AMOUNT_ABOVE(金额超限)/NEW_CONFIG(首次配置)/CROSS_REGION(跨区域)/CUSTOM_PART(定制件)/FIRST_ORDER(首单)/EXPORT_CONTROL(出口管制)',
  `trigger_value` decimal(18,2) DEFAULT NULL COMMENT '触发阈值(如折扣>20%触发审批)',
  `approval_chain_json` json NOT NULL COMMENT '审批链模板(JSON): [{step, approver_role, approver_ids, type:PARALLEL/SERIAL}]',
  `priority` int DEFAULT '0' COMMENT '优先级(越大越高, 多条规则同时触发时取最高优先级)',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`rule_id`),
  KEY `idx_trigger` (`tenant_id`,`trigger_type`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ审批规则(8种触发类型: 折扣超标/毛利过低/金额超限/首次配置/跨区域/定制件/首单/出口管制)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_attribute_mapping`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_attribute_mapping` (
  `mapping_id` bigint NOT NULL COMMENT '映射ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `model_id` bigint NOT NULL COMMENT '产品ID(FK→cpq_product_model)',
  `attr_name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '属性名',
  `attr_value` varchar(200) COLLATE utf8mb4_general_ci NOT NULL COMMENT '属性值',
  `material_code` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '物料编码',
  `sbom_line_id` bigint DEFAULT NULL COMMENT '关联SBOM行ID(FK→cpq_sbom_line)',
  `condition_expr` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '附加条件',
  `sort_order` int DEFAULT '0' COMMENT '排序号',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`mapping_id`),
  UNIQUE KEY `uk_attr_value` (`tenant_id`,`model_id`,`attr_name`,`attr_value`),
  KEY `idx_model_attr` (`tenant_id`,`model_id`,`attr_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ属性→物料映射表(选了钛合金外壳→自动匹配钛合金散热方案, SBOM→MBOM转换核心)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_attribute_option`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_attribute_option` (
  `option_id` bigint NOT NULL COMMENT '选项ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `model_id` bigint NOT NULL COMMENT '产品ID(FK→cpq_product_model)',
  `attr_name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '属性名',
  `option_code` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '选项编码',
  `option_label` varchar(200) COLLATE utf8mb4_general_ci NOT NULL COMMENT '选项显示名',
  `option_value` varchar(200) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '选项值',
  `is_default` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '是否默认选项',
  `sort_order` int DEFAULT '0' COMMENT '排序号',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`option_id`),
  UNIQUE KEY `uk_attr_option` (`tenant_id`,`model_id`,`attr_name`,`option_code`),
  KEY `idx_model_attr` (`tenant_id`,`model_id`,`attr_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ属性选项值定义(属性的可选值列表)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_bundle`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_bundle` (
  `bundle_id` bigint NOT NULL COMMENT '捆绑包ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `model_id` bigint NOT NULL COMMENT '捆绑包产品ID(FK→cpq_product_model, config_type=BUNDLE)',
  `bundle_type` varchar(30) COLLATE utf8mb4_general_ci NOT NULL COMMENT '类型: FIXED/CONFIGURABLE/SOLUTION',
  `pricing_strategy` varchar(30) COLLATE utf8mb4_general_ci NOT NULL COMMENT '定价策略: BUNDLE_PRICE/SUM_COMPONENTS',
  `bundle_discount_pct` decimal(5,2) DEFAULT NULL COMMENT '捆绑折扣率(%)',
  `is_active` char(1) COLLATE utf8mb4_general_ci DEFAULT '1' COMMENT '是否启用',
  `description` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '描述',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`bundle_id`),
  KEY `idx_model` (`tenant_id`,`model_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ产品捆绑包定义';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_bundle_option`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_bundle_option` (
  `option_id` bigint NOT NULL COMMENT '选项ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `option_group_id` bigint NOT NULL COMMENT '选项组ID(FK→cpq_bundle_option_group)',
  `component_model_id` bigint NOT NULL COMMENT '组件产品ID(FK→cpq_product_model)',
  `quantity` decimal(12,4) DEFAULT '1.0000' COMMENT '默认数量',
  `unit` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '单位',
  `is_default` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '是否默认选中',
  `price_modifier_type` varchar(20) COLLATE utf8mb4_general_ci DEFAULT 'INCLUDE' COMMENT '价格调整类型: NONE/FIXED_AMOUNT/PERCENT/INCLUDE',
  `price_modifier_value` decimal(18,2) DEFAULT NULL COMMENT '价格调整数值',
  `sort_order` int DEFAULT '0' COMMENT '排序号',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '状态',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`option_id`),
  KEY `idx_group` (`tenant_id`,`option_group_id`),
  KEY `idx_component` (`tenant_id`,`component_model_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ捆绑选项';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_bundle_option_group`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_bundle_option_group` (
  `option_group_id` bigint NOT NULL COMMENT '选项组ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `bundle_id` bigint NOT NULL COMMENT '捆绑包ID(FK→cpq_bundle)',
  `group_name` varchar(200) COLLATE utf8mb4_general_ci NOT NULL COMMENT '选项组名称',
  `group_code` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '选项组编码',
  `min_selections` int DEFAULT '0' COMMENT '最少选择数',
  `max_selections` int DEFAULT '1' COMMENT '最多选择数',
  `is_required` char(1) COLLATE utf8mb4_general_ci DEFAULT '1' COMMENT '是否必选',
  `sort_order` int DEFAULT '0' COMMENT '排序号',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '状态',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`option_group_id`),
  KEY `idx_bundle` (`tenant_id`,`bundle_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ捆绑选项组';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_channel`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_channel` (
  `channel_id` bigint NOT NULL COMMENT '渠道ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `channel_name` varchar(200) COLLATE utf8mb4_general_ci NOT NULL COMMENT '渠道名称',
  `channel_code` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT '渠道编码',
  `channel_type` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '渠道类型: DIRECT/DISTRIBUTOR/RESELLER/SI/AGENT',
  `partner_id` bigint DEFAULT NULL COMMENT '合作伙伴ID(FK→cpq_account, 渠道商对应的客户记录)',
  `region` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '区域',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`channel_id`),
  UNIQUE KEY `uk_tenant_code` (`tenant_id`,`channel_code`),
  KEY `idx_type` (`tenant_id`,`channel_type`),
  KEY `idx_partner` (`tenant_id`,`partner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ渠道';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_channel_price`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_channel_price` (
  `channel_price_id` bigint NOT NULL COMMENT '渠道价格ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `channel_code` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT '渠道代码(FK→cpq_channel)',
  `model_id` bigint NOT NULL COMMENT '产品ID(FK→cpq_product_model)',
  `channel_list_price` decimal(18,2) NOT NULL COMMENT '渠道目录价',
  `channel_discount_pct` decimal(5,2) DEFAULT NULL COMMENT '渠道折扣率(%)',
  `effective_date` date NOT NULL COMMENT '生效日期',
  `expiry_date` date DEFAULT NULL COMMENT '失效日期',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `variant_id` bigint DEFAULT NULL COMMENT '变体ID(FK→cpq_product_variant, NULL=模型级定价)',
  PRIMARY KEY (`channel_price_id`),
  KEY `idx_channel` (`tenant_id`,`channel_code`),
  KEY `idx_model` (`tenant_id`,`model_id`),
  KEY `idx_date` (`tenant_id`,`effective_date`,`expiry_date`),
  KEY `idx_channel_variant` (`tenant_id`,`variant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ渠道价格(渠道客户专属定价)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_comparison`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_comparison` (
  `comparison_id` bigint NOT NULL COMMENT '对比记录ID',
  `tenant_id` varchar(20) DEFAULT '000000',
  `our_product_id` bigint NOT NULL COMMENT '我方产品ID',
  `competitor_product_id` bigint NOT NULL COMMENT '竞品产品ID',
  `radar_data_json` json DEFAULT NULL COMMENT '雷达图数据JSON',
  `win_rate` decimal(5,2) DEFAULT NULL COMMENT '赢率(%)',
  `price_diff_pct` decimal(5,2) DEFAULT NULL COMMENT '价差(%)',
  `comparison_notes` text COMMENT '对比备注',
  `compared_by` bigint DEFAULT NULL COMMENT '对比人',
  `compared_time` datetime DEFAULT NULL,
  `del_flag` char(1) DEFAULT '0' COMMENT '0正常 2删除',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`comparison_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='竞品对比记录';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_compatibility_matrix`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_compatibility_matrix` (
  `matrix_id` bigint NOT NULL COMMENT '矩阵ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `source_product_id` bigint NOT NULL COMMENT '源产品ID(FK→cpq_product_model)',
  `target_product_id` bigint NOT NULL COMMENT '目标产品ID(FK→cpq_product_model)',
  `compatibility_type` varchar(20) COLLATE utf8mb4_general_ci NOT NULL COMMENT '兼容类型: MUTUAL_EXCLUSIVE(互斥)/DEPENDENCY(依赖)/REQUIRES(前置)',
  `condition_desc` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '兼容条件描述',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`matrix_id`),
  UNIQUE KEY `uk_product_pair` (`tenant_id`,`source_product_id`,`target_product_id`,`compatibility_type`),
  KEY `idx_source` (`tenant_id`,`source_product_id`),
  KEY `idx_target` (`tenant_id`,`target_product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ跨产品兼容性矩阵(产品A与产品B互斥/依赖/前置关系)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_competitor`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_competitor` (
  `competitor_id` bigint NOT NULL COMMENT '竞品ID',
  `tenant_id` varchar(20) DEFAULT '000000',
  `competitor_name` varchar(100) NOT NULL COMMENT '竞品名称',
  `competitor_code` varchar(64) DEFAULT NULL COMMENT '竞品编码',
  `industry` varchar(100) DEFAULT NULL COMMENT '行业',
  `website` varchar(200) DEFAULT NULL COMMENT '官网',
  `description` text COMMENT '描述',
  `market_share` decimal(5,2) DEFAULT NULL COMMENT '市场份额(%)',
  `status` char(1) DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `del_flag` char(1) DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`competitor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='竞品库';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_competitor_product`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_competitor_product` (
  `product_id` bigint NOT NULL COMMENT '竞品产品ID',
  `tenant_id` varchar(20) DEFAULT '000000',
  `competitor_id` bigint NOT NULL COMMENT '竞品ID',
  `product_name` varchar(200) NOT NULL COMMENT '产品名称',
  `product_code` varchar(64) DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL COMMENT '产品类别',
  `base_price` decimal(18,2) DEFAULT NULL COMMENT '基准价格',
  `specs_json` json DEFAULT NULL COMMENT '规格参数JSON',
  `strengths` text COMMENT '优势',
  `weaknesses` text COMMENT '劣势',
  `status` char(1) DEFAULT '0',
  `del_flag` char(1) DEFAULT '0' COMMENT '0正常 2删除',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`product_id`),
  KEY `idx_competitor` (`tenant_id`,`competitor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='竞品产品';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_config_rule`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_config_rule` (
  `rule_id` bigint NOT NULL COMMENT '规则ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `rule_name` varchar(200) COLLATE utf8mb4_general_ci NOT NULL COMMENT '规则名称',
  `rule_type` varchar(30) COLLATE utf8mb4_general_ci NOT NULL COMMENT '类型: VALIDATION(阻止错误组合)/SELECTION(自动添加推荐)/ALERT(通知销售)/VISIBILITY(隐藏无关项)',
  `model_id` bigint DEFAULT NULL COMMENT '适用产品ID(FK→cpq_product_model, 为空表示全局规则)',
  `condition_expr` text COLLATE utf8mb4_general_ci NOT NULL COMMENT '条件表达式(JSON/DSL, 描述何时触发此规则)',
  `action_expr` text COLLATE utf8mb4_general_ci NOT NULL COMMENT '动作表达式(JSON/DSL, 描述触发后执行的动作)',
  `error_message` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '违反规则时的提示信息',
  `severity` varchar(10) COLLATE utf8mb4_general_ci DEFAULT 'ERROR' COMMENT '严重级别: ERROR/WARNING/INFO',
  `priority` int DEFAULT '0' COMMENT '优先级(越大越高)',
  `effective_date` date NOT NULL COMMENT '生效日期',
  `expiry_date` date DEFAULT NULL COMMENT '失效日期',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`rule_id`),
  KEY `idx_model` (`tenant_id`,`model_id`),
  KEY `idx_type` (`tenant_id`,`rule_type`),
  KEY `idx_active` (`tenant_id`,`status`,`effective_date`,`expiry_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ配置规则(CSP约束求解)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_config_snapshot`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_config_snapshot` (
  `snapshot_id` bigint NOT NULL COMMENT '快照ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `quote_id` bigint NOT NULL COMMENT '报价单ID(FK→cpq_quote)',
  `model_id` bigint NOT NULL COMMENT '产品ID(FK→cpq_product_model)',
  `snapshot_hash` varchar(64) COLLATE utf8mb4_general_ci NOT NULL COMMENT '快照哈希(SHA256)',
  `selections_json` json NOT NULL COMMENT '配置选择(JSON): {attr_name: attr_value, ...}',
  `bom_json` json DEFAULT NULL COMMENT '完整BOM快照(JSON): {lines: [{item_code, qty, ...}]}',
  `rule_version` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '配置规则版本号',
  `price_version` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '价格规则版本号',
  `product_version` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '产品定义版本号',
  `snapshot_time` datetime NOT NULL COMMENT '快照时间',
  PRIMARY KEY (`snapshot_id`),
  UNIQUE KEY `uk_snapshot_hash` (`tenant_id`,`snapshot_hash`),
  KEY `idx_quote` (`tenant_id`,`quote_id`),
  KEY `idx_model` (`tenant_id`,`model_id`),
  KEY `idx_time` (`tenant_id`,`snapshot_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ配置快照(时间胶囊: 记录报价时的完整配置+BOM+规则版本, 支持版本回溯和合规审计)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_crm_activity`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_crm_activity` (
  `activity_id` bigint NOT NULL COMMENT '活动ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `opportunity_id` bigint NOT NULL COMMENT '关联商机ID(FK→cpq_crm_opportunity)',
  `account_id` bigint NOT NULL COMMENT '关联客户ID(FK→cpq_account)',
  `activity_type` varchar(30) COLLATE utf8mb4_general_ci NOT NULL COMMENT '活动类型: CALL/MEETING/EMAIL/VISIT/DEMO/NEGOTIATION/SYSTEM/OTHER',
  `subject` varchar(200) COLLATE utf8mb4_general_ci NOT NULL COMMENT '活动主题',
  `activity_date` date NOT NULL COMMENT '活动日期',
  `activity_time` time DEFAULT NULL COMMENT '活动时间',
  `duration_minutes` int DEFAULT NULL COMMENT '持续时长(分钟)',
  `participants` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '参与人(逗号分隔姓名)',
  `result` varchar(1000) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '活动结果/纪要',
  `next_plan` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '下一步计划',
  `owner_id` bigint DEFAULT NULL COMMENT '负责人(用户ID)',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`activity_id`),
  KEY `idx_opportunity` (`tenant_id`,`opportunity_id`),
  KEY `idx_account` (`tenant_id`,`account_id`),
  KEY `idx_date` (`tenant_id`,`activity_date`),
  KEY `idx_owner` (`tenant_id`,`owner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ销售活动(商机跟进记录)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_crm_contract`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_crm_contract` (
  `contract_id` bigint NOT NULL COMMENT '合同ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `contract_number` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT '合同编号',
  `contract_name` varchar(200) COLLATE utf8mb4_general_ci NOT NULL COMMENT '合同名称',
  `account_id` bigint NOT NULL COMMENT '关联客户ID(FK→cpq_account)',
  `opportunity_id` bigint DEFAULT NULL COMMENT '关联商机ID(FK→cpq_crm_opportunity)',
  `contract_type` varchar(20) COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'PROJECT' COMMENT '合同类型: PROJECT(单项目制)/FRAMEWORK(框架合同)',
  `status` varchar(20) COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'DRAFT' COMMENT '合同状态',
  `start_date` date DEFAULT NULL COMMENT '合同开始日期',
  `end_date` date DEFAULT NULL COMMENT '合同结束日期',
  `total_amount` decimal(18,2) DEFAULT NULL COMMENT '合同总金额',
  `signed_date` date DEFAULT NULL COMMENT '签订日期',
  `signing_party` varchar(200) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '签约主体',
  `payment_terms` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '付款条款',
  `owner_id` bigint DEFAULT NULL COMMENT '负责人(用户ID)',
  `description` varchar(1000) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '合同描述',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`contract_id`),
  UNIQUE KEY `uk_tenant_number` (`tenant_id`,`contract_number`),
  KEY `idx_account` (`tenant_id`,`account_id`),
  KEY `idx_opportunity` (`tenant_id`,`opportunity_id`),
  KEY `idx_status` (`tenant_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ合同';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_crm_opportunity`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_crm_opportunity` (
  `opportunity_id` bigint NOT NULL COMMENT '商机ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `opportunity_name` varchar(200) COLLATE utf8mb4_general_ci NOT NULL COMMENT '商机名称',
  `opportunity_code` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT '商机编码',
  `account_id` bigint NOT NULL COMMENT '关联客户ID(FK→cpq_account)',
  `stage` varchar(30) COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'PROSPECTING' COMMENT '销售阶段',
  `close_date` date DEFAULT NULL COMMENT '预计关闭日期',
  `amount` decimal(18,2) DEFAULT NULL COMMENT '预计金额',
  `probability` decimal(5,2) DEFAULT NULL COMMENT '赢单概率(%)',
  `opportunity_type` varchar(30) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '商机类型',
  `lead_source` varchar(30) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '线索来源',
  `next_step` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '下一步计划',
  `owner_id` bigint DEFAULT NULL COMMENT '负责人(用户ID)',
  `contact_name` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '主要联系人',
  `contact_phone` varchar(30) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '联系电话',
  `description` varchar(1000) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '商机描述',
  `is_closed` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '是否关闭(0进行中 1已关闭)',
  `closed_reason` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '关闭原因(丢单时填写)',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`opportunity_id`),
  UNIQUE KEY `uk_tenant_code` (`tenant_id`,`opportunity_code`),
  KEY `idx_account` (`tenant_id`,`account_id`),
  KEY `idx_owner` (`tenant_id`,`owner_id`),
  KEY `idx_stage` (`tenant_id`,`stage`),
  KEY `idx_close_date` (`tenant_id`,`close_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ商机';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_crm_order`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_crm_order` (
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `order_number` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT '订单编号',
  `order_name` varchar(200) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '订单名称',
  `contract_id` bigint NOT NULL COMMENT '关联合同ID(FK→cpq_crm_contract)',
  `account_id` bigint NOT NULL COMMENT '关联客户ID(FK→cpq_account)',
  `quote_id` bigint DEFAULT NULL COMMENT '关联报价单ID(FK→cpq_quote)',
  `order_type` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '订单类型: STANDARD/RUSH/RENEWAL',
  `status` varchar(20) COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'DRAFT' COMMENT '订单状态',
  `order_date` date DEFAULT NULL COMMENT '订单日期',
  `total_amount` decimal(18,2) DEFAULT NULL COMMENT '订单总金额',
  `currency` varchar(10) COLLATE utf8mb4_general_ci DEFAULT 'CNY' COMMENT '币种',
  `delivery_date` date DEFAULT NULL COMMENT '期望交付日期',
  `shipping_address` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '收货地址',
  `billing_address` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '账单地址',
  `owner_id` bigint DEFAULT NULL COMMENT '负责人(用户ID)',
  `description` varchar(1000) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '订单描述',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`order_id`),
  UNIQUE KEY `uk_tenant_number` (`tenant_id`,`order_number`),
  KEY `idx_contract` (`tenant_id`,`contract_id`),
  KEY `idx_account` (`tenant_id`,`account_id`),
  KEY `idx_quote` (`tenant_id`,`quote_id`),
  KEY `idx_status` (`tenant_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ订单';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_crm_order_line`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_crm_order_line` (
  `line_id` bigint NOT NULL COMMENT '明细ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `order_id` bigint NOT NULL COMMENT '关联订单ID(FK→cpq_crm_order)',
  `line_number` int NOT NULL DEFAULT '1' COMMENT '行号',
  `source_type` varchar(20) COLLATE utf8mb4_general_ci NOT NULL COMMENT '来源类型: QUOTE_LINE(报价行)/MANUAL(手动添加)',
  `source_id` bigint DEFAULT NULL COMMENT '来源行ID(报价行ID等)',
  `product_code` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '产品编码',
  `product_name` varchar(200) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '产品名称',
  `model_id` bigint DEFAULT NULL COMMENT '产品模型ID',
  `quantity` decimal(18,4) NOT NULL COMMENT '数量',
  `unit` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '单位',
  `unit_price` decimal(18,2) DEFAULT NULL COMMENT '单价',
  `line_amount` decimal(18,2) DEFAULT NULL COMMENT '行金额',
  `discount_pct` decimal(5,2) DEFAULT NULL COMMENT '折扣率(%)',
  `tax_rate` decimal(5,2) DEFAULT NULL COMMENT '税率(%)',
  `delivery_schedule` varchar(200) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '交付计划说明',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`line_id`),
  KEY `idx_order` (`tenant_id`,`order_id`),
  KEY `idx_model` (`tenant_id`,`model_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ订单明细(来自报价配置清单)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_currency_rate`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_currency_rate` (
  `rate_id` bigint NOT NULL COMMENT '汇率ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `from_currency` varchar(3) COLLATE utf8mb4_general_ci NOT NULL COMMENT '源币种',
  `to_currency` varchar(3) COLLATE utf8mb4_general_ci NOT NULL COMMENT '目标币种',
  `exchange_rate` decimal(18,6) NOT NULL COMMENT '汇率',
  `effective_date` date NOT NULL COMMENT '生效日期',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`rate_id`),
  KEY `idx_currency` (`tenant_id`,`from_currency`,`to_currency`),
  KEY `idx_date` (`tenant_id`,`effective_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ汇率(多币种报价支持)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_ecn_approval`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_ecn_approval` (
  `ecn_approval_id` bigint NOT NULL COMMENT '审批ID',
  `tenant_id` varchar(20) DEFAULT '000000' COMMENT '租户ID',
  `change_order_id` bigint NOT NULL COMMENT '变更单ID(FK)',
  `approval_chain_id` bigint DEFAULT NULL COMMENT '审批链ID(FK→cpq_approval_chain)',
  `approver_id` bigint DEFAULT NULL COMMENT '审批人ID',
  `approver_name` varchar(100) DEFAULT NULL COMMENT '审批人姓名',
  `step_number` int DEFAULT NULL COMMENT '审批步骤',
  `action` varchar(20) DEFAULT NULL COMMENT '审批动作: APPROVE/REJECT/COMMENT',
  `comment` text COMMENT '审批意见',
  `action_time` datetime DEFAULT NULL COMMENT '操作时间',
  `del_flag` char(1) DEFAULT '0',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`ecn_approval_id`),
  KEY `idx_change_order` (`tenant_id`,`change_order_id`),
  KEY `idx_chain` (`tenant_id`,`approval_chain_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='ECN审批记录';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_ecn_change_item`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_ecn_change_item` (
  `item_id` bigint NOT NULL COMMENT '变更项ID',
  `tenant_id` varchar(20) DEFAULT '000000' COMMENT '租户ID',
  `change_order_id` bigint NOT NULL COMMENT '变更单ID(FK)',
  `entity_type` varchar(30) NOT NULL COMMENT '实体类型: PRODUCT/BOM/PRICE/ATTRIBUTE/DOCUMENT/CONFIG_RULE',
  `entity_id` bigint NOT NULL COMMENT '实体ID',
  `entity_name` varchar(200) DEFAULT NULL COMMENT '实体名称',
  `change_description` text COMMENT '变更描述',
  `old_value` text COMMENT '旧值(JSON)',
  `new_value` text COMMENT '新值(JSON)',
  `sort_order` int DEFAULT '0' COMMENT '排序',
  `del_flag` char(1) DEFAULT '0',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`item_id`),
  KEY `idx_change_order` (`tenant_id`,`change_order_id`),
  KEY `idx_entity` (`tenant_id`,`entity_type`,`entity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='ECN变更项';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_ecn_change_order`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_ecn_change_order` (
  `change_order_id` bigint NOT NULL COMMENT '变更单ID',
  `tenant_id` varchar(20) DEFAULT '000000' COMMENT '租户ID',
  `ecn_number` varchar(50) NOT NULL COMMENT 'ECN编号',
  `title` varchar(200) NOT NULL COMMENT '变更标题',
  `reason` text COMMENT '变更原因',
  `change_type` varchar(30) DEFAULT NULL COMMENT '变更类型: PRODUCT/BOM/PRICE/PROCESS/DOCUMENT',
  `severity` varchar(20) DEFAULT 'NORMAL' COMMENT '严重程度: CRITICAL/MAJOR/NORMAL/MINOR',
  `affected_products` text COMMENT '受影响产品(JSON)',
  `status` varchar(20) DEFAULT 'DRAFT' COMMENT '状态: DRAFT/ANALYZING/APPROVED/REJECTED/IMPLEMENTED/CLOSED',
  `originator_id` bigint DEFAULT NULL COMMENT '发起人ID',
  `originator_name` varchar(100) DEFAULT NULL COMMENT '发起人姓名',
  `del_flag` char(1) DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`change_order_id`),
  UNIQUE KEY `uk_ecn_number` (`tenant_id`,`ecn_number`),
  KEY `idx_status` (`tenant_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='ECN变更单';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_ecn_impact_analysis`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_ecn_impact_analysis` (
  `impact_id` bigint NOT NULL COMMENT '影响分析ID',
  `tenant_id` varchar(20) DEFAULT '000000' COMMENT '租户ID',
  `change_order_id` bigint NOT NULL COMMENT '变更单ID(FK)',
  `change_item_id` bigint DEFAULT NULL COMMENT '变更项ID(FK)',
  `propagation_level` int NOT NULL COMMENT '传播层级: 1-BOM 2-配置规则 3-报价单 4-审批链 5-ERP订单',
  `affected_entity_type` varchar(30) DEFAULT NULL COMMENT '受影响实体类型',
  `affected_entity_id` bigint DEFAULT NULL COMMENT '受影响实体ID',
  `affected_entity_name` varchar(200) DEFAULT NULL COMMENT '受影响实体名称',
  `impact_description` text COMMENT '影响描述',
  `severity` varchar(20) DEFAULT NULL COMMENT '影响程度: HIGH/MEDIUM/LOW',
  `remediation` text COMMENT '缓解措施',
  `del_flag` char(1) DEFAULT '0',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`impact_id`),
  KEY `idx_change_order` (`tenant_id`,`change_order_id`),
  KEY `idx_level` (`tenant_id`,`propagation_level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='ECN影响分析';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_integration_config`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_integration_config` (
  `config_id` bigint NOT NULL COMMENT '配置ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `system_type` varchar(20) COLLATE utf8mb4_general_ci NOT NULL COMMENT '系统类型: CRM/ERP/PLM/PRICING/CONTRACT/ECOMMERCE',
  `system_name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '系统名称',
  `endpoint_url` varchar(500) COLLATE utf8mb4_general_ci NOT NULL COMMENT '端点URL',
  `auth_type` varchar(20) COLLATE utf8mb4_general_ci NOT NULL COMMENT '认证类型: API_KEY/OAUTH2/BASIC/mTLS',
  `auth_config_json` json DEFAULT NULL COMMENT '认证配置(JSON): {api_key, client_id, client_secret, token_url, ...}',
  `sync_direction` varchar(20) COLLATE utf8mb4_general_ci NOT NULL COMMENT '同步方向',
  `sync_frequency` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '同步频率: REALTIME/HOURLY/DAILY/MANUAL',
  `timeout_seconds` int DEFAULT '30' COMMENT '超时时间(秒)',
  `retry_times` int DEFAULT '3' COMMENT '重试次数',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`config_id`),
  KEY `idx_tenant_system` (`tenant_id`,`system_type`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ集成配置(CRM/ERP/PLM连接器配置: 端点/认证/同步策略)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_integration_mapping`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_integration_mapping` (
  `mapping_id` bigint NOT NULL COMMENT '映射ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `config_id` bigint NOT NULL COMMENT '集成配置ID(FK→cpq_integration_config)',
  `source_field` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '源系统字段(CRM/ERP字段名)',
  `target_field` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'CPQ目标字段(CPQ表字段名)',
  `transform_rule` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '转换规则(表达式: 如 multiply(price, 1.13) 或 lookup(region_code))',
  `is_required` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '是否必填(1是 0否)',
  `sort_order` int DEFAULT '0' COMMENT '排序号',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '0正常 2删除',
  PRIMARY KEY (`mapping_id`),
  UNIQUE KEY `uk_config_field` (`tenant_id`,`config_id`,`source_field`),
  KEY `idx_config` (`tenant_id`,`config_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ集成字段映射(外部系统字段→CPQ字段的映射关系和转换规则)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_knowledge_article`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_knowledge_article` (
  `article_id` bigint NOT NULL COMMENT '文章ID',
  `tenant_id` varchar(20) DEFAULT '000000',
  `title` varchar(500) NOT NULL COMMENT '标题',
  `content` longtext COMMENT '内容',
  `category` varchar(100) DEFAULT NULL COMMENT '分类',
  `article_type` varchar(20) NOT NULL COMMENT '类型: PRODUCT/SCRIPT/CASE/TRAINING',
  `tags` varchar(500) DEFAULT NULL COMMENT '标签',
  `view_count` int DEFAULT '0' COMMENT '浏览次数',
  `status` char(1) DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `del_flag` char(1) DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`article_id`),
  KEY `idx_type` (`tenant_id`,`article_type`,`status`),
  FULLTEXT KEY `ft_title_content` (`title`,`content`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='CPQ知识库文章';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_mbom_line`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_mbom_line` (
  `mbom_line_id` bigint NOT NULL COMMENT 'MBOM行ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户编号',
  `sbom_line_id` bigint NOT NULL COMMENT '来源SBOM行ID',
  `model_id` bigint NOT NULL COMMENT '所属产品ID',
  `parent_mbom_line_id` bigint DEFAULT NULL COMMENT '父MBOM行ID(多层级)',
  `line_number` int NOT NULL COMMENT '行号',
  `material_code` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '生产物料编码',
  `material_desc` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '物料描述',
  `material_type` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '物料类型: RAW/SEMI/FINISHED/PACKAGE',
  `quantity` decimal(12,4) NOT NULL COMMENT '用量',
  `unit` varchar(10) COLLATE utf8mb4_general_ci DEFAULT 'PCS',
  `plant` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '工厂代码(Plant-Specific BOM)',
  `storage_location` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '库存地点',
  `requirement_type` char(1) COLLATE utf8mb4_general_ci DEFAULT 'M' COMMENT '需求类型: M必选/O可选',
  `substitute_group` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '替代组',
  `substitute_priority` int DEFAULT NULL COMMENT '替代优先级',
  `cost_component` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '成本归属: MATERIAL/LABOR/OVERHEAD/OUTSOURCE',
  `lead_time_days` int DEFAULT NULL COMMENT '采购/生产交期(天)',
  `moq` decimal(12,4) DEFAULT NULL COMMENT '最小起订量',
  `sort_order` int DEFAULT '0',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`mbom_line_id`),
  KEY `idx_sbom` (`tenant_id`,`sbom_line_id`),
  KEY `idx_model` (`tenant_id`,`model_id`),
  KEY `idx_parent` (`tenant_id`,`parent_mbom_line_id`),
  KEY `idx_plant` (`tenant_id`,`plant`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ制造BOM行';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_migration_log`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_migration_log` (
  `log_id` bigint NOT NULL COMMENT '日志ID',
  `tenant_id` varchar(20) DEFAULT '000000',
  `task_id` bigint NOT NULL COMMENT '迁移任务ID',
  `row_index` int DEFAULT NULL COMMENT '行号',
  `log_level` varchar(20) DEFAULT 'INFO' COMMENT '级别: INFO/WARN/ERROR',
  `message` text COMMENT '日志消息',
  `raw_data_json` json DEFAULT NULL COMMENT '原始数据',
  `log_time` datetime DEFAULT NULL,
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) DEFAULT NULL,
  `del_flag` char(1) DEFAULT '0' COMMENT '0正常 2删除',
  PRIMARY KEY (`log_id`),
  KEY `idx_task` (`tenant_id`,`task_id`),
  KEY `idx_tenant_del` (`tenant_id`,`del_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='迁移日志';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_migration_mapping`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_migration_mapping` (
  `mapping_id` bigint NOT NULL COMMENT '映射ID',
  `tenant_id` varchar(20) DEFAULT '000000',
  `task_id` bigint NOT NULL COMMENT '迁移任务ID',
  `source_field` varchar(100) NOT NULL COMMENT '源字段',
  `target_field` varchar(100) NOT NULL COMMENT '目标字段',
  `transform_rule` varchar(500) DEFAULT NULL COMMENT '转换规则',
  `default_value` varchar(200) DEFAULT NULL COMMENT '默认值',
  `is_required` char(1) DEFAULT '0' COMMENT '是否必填',
  `sort_order` int DEFAULT '0',
  `del_flag` char(1) DEFAULT '0' COMMENT '0正常 2删除',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`mapping_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='迁移字段映射';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_migration_task`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_migration_task` (
  `task_id` bigint NOT NULL COMMENT '任务ID',
  `tenant_id` varchar(20) DEFAULT '000000',
  `task_name` varchar(200) NOT NULL COMMENT '任务名称',
  `source_system` varchar(50) NOT NULL COMMENT '源系统: LEGACY_ERP/CRM/EXCEL',
  `target_module` varchar(50) NOT NULL COMMENT '目标模块: PRODUCT/PRICING/CUSTOMER',
  `task_status` varchar(20) DEFAULT 'DRAFT' COMMENT '状态: DRAFT/VALIDATING/RUNNING/COMPLETED/FAILED',
  `total_records` int DEFAULT '0' COMMENT '总记录数',
  `processed_records` int DEFAULT '0' COMMENT '已处理数',
  `failed_records` int DEFAULT '0' COMMENT '失败数',
  `file_path` varchar(500) DEFAULT NULL COMMENT '上传文件路径',
  `started_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `del_flag` char(1) DEFAULT '0' COMMENT '0正常 2删除',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`task_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='数据迁移任务';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_plant`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_plant` (
  `plant_id` bigint NOT NULL COMMENT '工厂ID',
  `tenant_id` varchar(20) DEFAULT '000000',
  `plant_code` varchar(50) NOT NULL COMMENT '工厂编码',
  `plant_name` varchar(100) NOT NULL COMMENT '工厂名称',
  `location` varchar(200) DEFAULT NULL COMMENT '位置',
  `capacity_per_day` int DEFAULT '0' COMMENT '日产能',
  `working_days_per_year` int DEFAULT '250' COMMENT '年工作天数',
  `quality_level` varchar(20) DEFAULT 'STANDARD' COMMENT '资质等级',
  `status` char(1) DEFAULT '0',
  `del_flag` char(1) DEFAULT '0' COMMENT '0正常 2删除',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`plant_id`),
  UNIQUE KEY `uk_plant` (`tenant_id`,`plant_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='CPQ工厂注册';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_price_book`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_price_book` (
  `price_book_id` bigint NOT NULL COMMENT '价格手册ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `book_name` varchar(200) COLLATE utf8mb4_general_ci NOT NULL COMMENT '手册名称',
  `book_type` varchar(20) COLLATE utf8mb4_general_ci NOT NULL COMMENT '类型: STANDARD/CHANNEL/PROMOTION/REGION',
  `currency` varchar(3) COLLATE utf8mb4_general_ci DEFAULT 'CNY' COMMENT '币种',
  `effective_date` date NOT NULL COMMENT '生效日期',
  `expiry_date` date DEFAULT NULL COMMENT '失效日期',
  `priority` int DEFAULT '0' COMMENT '优先级(越大越高, 用于多手册冲突时选择)',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`price_book_id`),
  KEY `idx_tenant` (`tenant_id`),
  KEY `idx_type` (`tenant_id`,`book_type`,`status`),
  KEY `idx_date` (`tenant_id`,`effective_date`,`expiry_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ价格手册';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_price_book_entry`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_price_book_entry` (
  `entry_id` bigint NOT NULL COMMENT '条目ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `price_book_id` bigint NOT NULL COMMENT '价格手册ID(FK→cpq_price_book)',
  `model_id` bigint NOT NULL COMMENT '产品ID(FK→cpq_product_model)',
  `item_code` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '物料编码(可选, 用于配件级定价)',
  `region_code` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '区域代码',
  `channel_code` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '渠道代码',
  `list_price` decimal(18,2) NOT NULL COMMENT '目录价',
  `cost_price` decimal(18,2) DEFAULT NULL COMMENT '成本价(ABAC保护: L0不可见, L3全可见)',
  `min_price` decimal(18,2) DEFAULT NULL COMMENT '最低销售价(低于此价需审批)',
  `effective_date` date NOT NULL COMMENT '生效日期',
  `expiry_date` date DEFAULT NULL COMMENT '失效日期',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `variant_id` bigint DEFAULT NULL COMMENT '变体ID(FK→cpq_product_variant, NULL=模型级定价)',
  PRIMARY KEY (`entry_id`),
  KEY `idx_book` (`tenant_id`,`price_book_id`),
  KEY `idx_model` (`tenant_id`,`model_id`),
  KEY `idx_region` (`tenant_id`,`region_code`),
  KEY `idx_channel` (`tenant_id`,`channel_code`),
  KEY `idx_entry_variant` (`tenant_id`,`variant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ价格手册条目';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_price_rule`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_price_rule` (
  `price_rule_id` bigint NOT NULL COMMENT '规则ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `rule_name` varchar(200) COLLATE utf8mb4_general_ci NOT NULL COMMENT '规则名称',
  `rule_type` varchar(30) COLLATE utf8mb4_general_ci NOT NULL COMMENT '类型: DISCOUNT/MARKUP/PROMOTION/CONTRACT',
  `priority` int DEFAULT '0' COMMENT '优先级(越大越高, 多条规则匹配时取最高优先级)',
  `condition_json` json DEFAULT NULL COMMENT '条件(JSON): {product_ids, regions, channels, customer_types, date_range, quantity_range, ...}',
  `action_json` json NOT NULL COMMENT '动作(JSON): {adjustment_type, adjustment_value, adjustment_unit}',
  `approval_threshold` decimal(18,2) DEFAULT NULL COMMENT '触发审批的金额/折扣阈值',
  `effective_date` date NOT NULL COMMENT '生效日期',
  `expiry_date` date DEFAULT NULL COMMENT '失效日期',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`price_rule_id`),
  KEY `idx_tenant_type` (`tenant_id`,`rule_type`,`status`),
  KEY `idx_date` (`tenant_id`,`effective_date`,`expiry_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ定价规则';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_product_attribute`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_product_attribute` (
  `attribute_id` bigint NOT NULL COMMENT '属性ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户编号',
  `model_id` bigint NOT NULL COMMENT '所属产品ID',
  `attr_category` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '属性分类(Feature Category)',
  `attr_name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '属性名称(Feature)',
  `attr_value` varchar(200) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '属性默认值(Option)',
  `is_configurable` char(1) COLLATE utf8mb4_general_ci DEFAULT '1' COMMENT '是否可配置(0否 1是)',
  `is_required` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '是否必选(0否 1是)',
  `display_order` int DEFAULT '0' COMMENT '显示顺序',
  `data_type` varchar(20) COLLATE utf8mb4_general_ci DEFAULT 'STRING' COMMENT '数据类型: STRING/NUMBER/BOOLEAN/ENUM',
  `option_values` json DEFAULT NULL COMMENT '可选项列表(JSON数组, data_type=ENUM时使用)',
  `sort_order` int DEFAULT '0',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`attribute_id`),
  UNIQUE KEY `uk_model_attr` (`tenant_id`,`model_id`,`attr_name`),
  KEY `idx_model` (`tenant_id`,`model_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ产品属性';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_product_catalog`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_product_catalog` (
  `catalog_id` bigint NOT NULL COMMENT '目录ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户编号',
  `catalog_name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '目录名称',
  `catalog_type` varchar(20) COLLATE utf8mb4_general_ci NOT NULL COMMENT '目录类型: SALES/CHANNEL/INTERNAL',
  `effective_date` date DEFAULT NULL COMMENT '生效日期',
  `expiry_date` date DEFAULT NULL COMMENT '失效日期',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL COMMENT '创建部门',
  `create_by` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`catalog_id`),
  KEY `idx_tenant` (`tenant_id`),
  KEY `idx_type` (`tenant_id`,`catalog_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ产品目录';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_product_category`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_product_category` (
  `category_id` bigint NOT NULL COMMENT '分类ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `parent_category_id` bigint DEFAULT NULL COMMENT '父分类ID(自引用FK, NULL=根节点/L1产品线)',
  `category_level` tinyint NOT NULL COMMENT '层级: 1=产品线(L1), 2=产品族(L2), 3=产品系列(L3)',
  `category_code` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT '分类编码',
  `category_name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '分类名称',
  `sort_order` int DEFAULT '0' COMMENT '排序号',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`category_id`),
  UNIQUE KEY `uk_tenant_code` (`tenant_id`,`category_code`),
  KEY `idx_parent` (`tenant_id`,`parent_category_id`),
  KEY `idx_level` (`tenant_id`,`category_level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ产品分类(层级树)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_product_lifecycle_log`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_product_lifecycle_log` (
  `log_id` bigint NOT NULL COMMENT '日志ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户编号',
  `model_id` bigint NOT NULL COMMENT '产品ID',
  `from_status` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '变更前状态',
  `to_status` varchar(20) COLLATE utf8mb4_general_ci NOT NULL COMMENT '变更后状态',
  `change_reason` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '变更原因',
  `change_by` bigint DEFAULT NULL COMMENT '变更人',
  `change_time` datetime NOT NULL COMMENT '变更时间',
  PRIMARY KEY (`log_id`),
  KEY `idx_model` (`tenant_id`,`model_id`,`change_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ产品生命周期变更日志';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_product_model`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_product_model` (
  `model_id` bigint NOT NULL COMMENT '产品ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户编号',
  `catalog_id` bigint NOT NULL COMMENT '所属目录ID',
  `model_code` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '产品编码/型号(L4)',
  `model_name` varchar(200) COLLATE utf8mb4_general_ci NOT NULL COMMENT '产品名称',
  `description` text COLLATE utf8mb4_general_ci COMMENT '产品描述',
  `lifecycle_status` varchar(20) COLLATE utf8mb4_general_ci DEFAULT 'ACTIVE' COMMENT '生命周期: CONCEPT/DESIGN/PRE_RELEASE/ACTIVE/EOL_ANNOUNCED/LAST_TIME_BUY/DISCONTINUED/ARCHIVED',
  `successor_model_id` bigint DEFAULT NULL COMMENT '替代产品ID(自引用)',
  `base_price` decimal(18,2) DEFAULT NULL COMMENT '基础目录价',
  `currency` varchar(3) COLLATE utf8mb4_general_ci DEFAULT 'CNY' COMMENT '币种',
  `min_order_qty` int DEFAULT '1' COMMENT '最小起订量',
  `lead_time_days` int DEFAULT NULL COMMENT '标准交期(天)',
  `config_type` varchar(20) COLLATE utf8mb4_general_ci DEFAULT 'STANDARD' COMMENT '配置类型: STANDARD/ATO/CTO/ETO/BUNDLE',
  `default_bom_id` bigint DEFAULT NULL COMMENT '默认SBOM Header ID',
  `thumbnail_url` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '产品缩略图(OSS路径)',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `category_id` bigint NOT NULL COMMENT '产品分类ID(FK→cpq_product_category, 指向L3产品系列)',
  PRIMARY KEY (`model_id`),
  UNIQUE KEY `uk_model_code` (`tenant_id`,`model_code`),
  KEY `idx_catalog` (`tenant_id`,`catalog_id`),
  KEY `idx_lifecycle` (`tenant_id`,`lifecycle_status`),
  KEY `idx_product_line` (`tenant_id`),
  KEY `idx_search` (`tenant_id`,`model_name`,`model_code`),
  KEY `idx_category` (`tenant_id`,`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ可销售产品';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_product_supersession`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_product_supersession` (
  `supersession_id` bigint NOT NULL COMMENT '替代关系ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户编号',
  `original_model_id` bigint NOT NULL COMMENT '被替代产品ID',
  `replacement_model_id` bigint NOT NULL COMMENT '替代产品ID',
  `supersession_type` varchar(20) COLLATE utf8mb4_general_ci NOT NULL COMMENT '替代类型: FULL/CONDITIONAL/SPLIT/AGGREGATE',
  `condition_expr` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '条件表达式(CONDITIONAL类型)',
  `price_impact_pct` decimal(5,2) DEFAULT NULL COMMENT '价格影响百分比',
  `effective_date` date DEFAULT NULL COMMENT '生效日期',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`supersession_id`),
  KEY `idx_original` (`tenant_id`,`original_model_id`),
  KEY `idx_replacement` (`tenant_id`,`replacement_model_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ产品替代关系';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_product_variant`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_product_variant` (
  `variant_id` bigint NOT NULL COMMENT '变体ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `model_id` bigint NOT NULL COMMENT '所属产品型号ID(FK→cpq_product_model)',
  `variant_code` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '变体编码(如 RW-SWEEP-S1P-WHT)',
  `variant_name` varchar(200) COLLATE utf8mb4_general_ci NOT NULL COMMENT '变体名称(如 SweepBot S1 Pro 白色款)',
  `attributes` text COLLATE utf8mb4_general_ci NOT NULL COMMENT '属性值集合(JSON): {"attr_name":"attr_value", ...}',
  `default_bom_id` bigint DEFAULT NULL COMMENT '此变体对应的确定SBOM Header ID(FK→cpq_sbom_header)',
  `base_price` decimal(18,2) DEFAULT NULL COMMENT '变体基础价(可继承model.base_price或覆盖)',
  `thumbnail_url` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '变体缩略图',
  `is_default` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '是否默认变体(0否 1是)',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL COMMENT '创建部门',
  `create_by` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`variant_id`),
  UNIQUE KEY `uk_variant_code` (`tenant_id`,`variant_code`),
  UNIQUE KEY `uk_model_attrs` (`tenant_id`,`model_id`,`attributes`(255)),
  KEY `idx_model` (`tenant_id`,`model_id`),
  KEY `idx_default` (`tenant_id`,`model_id`,`is_default`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ产品变体(型号+属性组合→确定的可售卖SKU)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_quote`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_quote` (
  `quote_id` bigint NOT NULL COMMENT '报价单ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `quote_number` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT '报价单编号(自动生成)',
  `opportunity_id` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '关联商机ID(CRM)',
  `account_id` bigint NOT NULL COMMENT '客户ID(FK→cpq_account)',
  `account_name` varchar(200) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '客户名称(冗余)',
  `quote_type` varchar(20) COLLATE utf8mb4_general_ci DEFAULT 'STANDARD' COMMENT '类型: STANDARD/RENEWAL/REVISION/QUICK',
  `currency` varchar(3) COLLATE utf8mb4_general_ci DEFAULT 'CNY' COMMENT '币种',
  `subtotal` decimal(18,2) DEFAULT NULL COMMENT '小计',
  `discount_total` decimal(18,2) DEFAULT NULL COMMENT '折扣总额',
  `tax_total` decimal(18,2) DEFAULT NULL COMMENT '税费',
  `grand_total` decimal(18,2) DEFAULT NULL COMMENT '总计',
  `status` varchar(20) COLLATE utf8mb4_general_ci DEFAULT 'DRAFT' COMMENT '状态: DRAFT/CONFIGURING/VALIDATED/PRICING/APPROVING/APPROVED/SENT/WON/LOST/EXPIRED/REJECTED',
  `valid_until` date DEFAULT NULL COMMENT '有效期至',
  `approval_chain_id` bigint DEFAULT NULL COMMENT '当前审批链ID(FK→cpq_approval_chain)',
  `created_by` bigint DEFAULT NULL COMMENT '创建人ID',
  `created_by_name` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '创建人姓名(冗余)',
  `create_by` bigint DEFAULT NULL COMMENT '创建者',
  `submitted_date` datetime DEFAULT NULL COMMENT '提交日期',
  `won_date` datetime DEFAULT NULL COMMENT '赢单日期',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`quote_id`),
  UNIQUE KEY `uk_quote_number` (`tenant_id`,`quote_number`),
  KEY `idx_account` (`tenant_id`,`account_id`),
  KEY `idx_status` (`tenant_id`,`status`,`create_time`),
  KEY `idx_created_by` (`tenant_id`,`created_by`,`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ报价单';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_quote_line_item`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_quote_line_item` (
  `line_id` bigint NOT NULL COMMENT '行项目ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `quote_id` bigint NOT NULL COMMENT '报价单ID(FK→cpq_quote)',
  `parent_line_id` bigint DEFAULT NULL COMMENT '父行项目ID(捆绑关系)',
  `line_number` int NOT NULL COMMENT '行号',
  `model_id` bigint DEFAULT NULL COMMENT '产品ID(FK→cpq_product_model)',
  `sbom_line_id` bigint DEFAULT NULL COMMENT 'SBOM物料ID(FK→cpq_sbom_line, 配件行)',
  `item_type` varchar(20) COLLATE utf8mb4_general_ci NOT NULL COMMENT '类型: PRODUCT/ACCESSORY/SERVICE/CUSTOM/SOFTWARE/LICENSE',
  `item_code` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '物料编码',
  `item_name` varchar(500) COLLATE utf8mb4_general_ci NOT NULL COMMENT '物料名称',
  `quantity` decimal(12,4) NOT NULL COMMENT '数量',
  `unit` varchar(10) COLLATE utf8mb4_general_ci DEFAULT 'PCS' COMMENT '单位',
  `list_price` decimal(18,2) DEFAULT NULL COMMENT '目录价',
  `unit_price` decimal(18,2) DEFAULT NULL COMMENT '单价(折扣后)',
  `discount_pct` decimal(5,2) DEFAULT NULL COMMENT '折扣百分比',
  `discount_amount` decimal(18,2) DEFAULT NULL COMMENT '折扣金额',
  `net_price` decimal(18,2) DEFAULT NULL COMMENT '净价',
  `line_total` decimal(18,2) DEFAULT NULL COMMENT '行总计',
  `configuration_json` json DEFAULT NULL COMMENT '该行的配置选择(JSON)',
  `custom_requirements` text COLLATE utf8mb4_general_ci COMMENT '定制需求描述',
  `delivery_days` int DEFAULT NULL COMMENT '预估交期(天)',
  `atp_status` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'ATP状态: AVAILABLE/CONSTRAINED/UNAVAILABLE',
  `sort_order` int DEFAULT '0' COMMENT '排序号',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`line_id`),
  UNIQUE KEY `uk_quote_line` (`tenant_id`,`quote_id`,`line_number`),
  KEY `idx_quote` (`tenant_id`,`quote_id`),
  KEY `idx_model` (`tenant_id`,`model_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ报价行项目';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_quote_template`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_quote_template` (
  `template_id` bigint NOT NULL COMMENT '模板ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `template_name` varchar(200) COLLATE utf8mb4_general_ci NOT NULL COMMENT '模板名称',
  `template_type` varchar(20) COLLATE utf8mb4_general_ci NOT NULL COMMENT '类型: PDF/DOCX/STANDARD/CUSTOM',
  `template_content` longtext COLLATE utf8mb4_general_ci COMMENT '模板内容(二进制/HTML/Markdown)',
  `template_json` json DEFAULT NULL COMMENT '模板配置(JSON): {sections, placeholders, styles, ...}',
  `is_default` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '是否默认模板',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`template_id`),
  KEY `idx_tenant` (`tenant_id`),
  KEY `idx_type` (`tenant_id`,`template_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ报价模板({{config.*}}占位符→配置数据填充, PDF/Word生成)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_quote_version`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_quote_version` (
  `version_id` bigint NOT NULL COMMENT '版本ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `quote_id` bigint NOT NULL COMMENT '报价单ID(FK→cpq_quote)',
  `version_number` int NOT NULL COMMENT '版本号(从1递增)',
  `version_json` json NOT NULL COMMENT '版本完整数据(JSON): 报价单+行项目+配置快照的完整快照',
  `version_note` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '版本说明',
  `created_by` bigint DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`version_id`),
  UNIQUE KEY `uk_quote_version` (`tenant_id`,`quote_id`,`version_number`),
  KEY `idx_quote` (`tenant_id`,`quote_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ报价版本(多版本支持+版本对比)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_recommendation`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_recommendation` (
  `recommendation_id` bigint NOT NULL COMMENT '推荐策略ID',
  `tenant_id` varchar(20) DEFAULT '000000',
  `scenario` varchar(200) NOT NULL COMMENT '应用场景',
  `our_product_id` bigint NOT NULL COMMENT '推荐我方产品ID',
  `competitor_product_id` bigint DEFAULT NULL COMMENT '替代竞品产品ID',
  `strategy_type` varchar(50) NOT NULL COMMENT '策略类型: PRICE/FEATURE/BUNDLE/SERVICE',
  `strategy_desc` text COMMENT '策略描述',
  `priority` int DEFAULT '0' COMMENT '优先级',
  `effective_from` date DEFAULT NULL,
  `effective_to` date DEFAULT NULL,
  `status` char(1) DEFAULT '0',
  `del_flag` char(1) DEFAULT '0' COMMENT '0正常 2删除',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`recommendation_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='竞品推荐策略';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_sbom_header`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_sbom_header` (
  `sbom_header_id` bigint NOT NULL COMMENT 'SBOM头ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户编号',
  `model_id` bigint NOT NULL COMMENT '所属产品ID',
  `sbom_name` varchar(200) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'SBOM名称',
  `sbom_version` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '1.0' COMMENT 'SBOM版本',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`sbom_header_id`),
  KEY `idx_model` (`tenant_id`,`model_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ销售BOM头';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_sbom_line`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_sbom_line` (
  `sbom_line_id` bigint NOT NULL COMMENT 'SBOM行ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户编号',
  `sbom_header_id` bigint NOT NULL COMMENT 'SBOM头ID',
  `parent_line_id` bigint DEFAULT NULL COMMENT '父行ID(多层级BOM)',
  `line_number` int NOT NULL COMMENT '行号',
  `item_code` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '物料编码',
  `item_name` varchar(500) COLLATE utf8mb4_general_ci NOT NULL COMMENT '物料名称',
  `item_type` varchar(20) COLLATE utf8mb4_general_ci NOT NULL COMMENT '类型: HOST/ACCESSORY/SERVICE/LICENSE/SOFTWARE/PACKAGE',
  `quantity` decimal(12,4) DEFAULT '1.0000' COMMENT '数量',
  `unit` varchar(10) COLLATE utf8mb4_general_ci DEFAULT 'PCS' COMMENT '单位',
  `is_required` char(1) COLLATE utf8mb4_general_ci DEFAULT '1' COMMENT '是否标配(0否 1是)',
  `is_replaceable` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '是否可替换(0否 1是)',
  `replacement_group` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '替换组',
  `is_phantom` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '是否虚项(0否 1是, Phantom Item)',
  `min_qty` decimal(12,4) DEFAULT NULL COMMENT '最小数量',
  `max_qty` decimal(12,4) DEFAULT NULL COMMENT '最大数量',
  `price_impact` varchar(10) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '价格影响: FIXED/VARIABLE/NONE',
  `lead_time_days` int DEFAULT NULL COMMENT '交期(天)',
  `sort_order` int DEFAULT '0',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`sbom_line_id`),
  UNIQUE KEY `uk_header_line` (`tenant_id`,`sbom_header_id`,`line_number`),
  KEY `idx_header` (`tenant_id`,`sbom_header_id`),
  KEY `idx_parent` (`tenant_id`,`parent_line_id`),
  KEY `idx_type` (`tenant_id`,`item_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ销售BOM行';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_solution_document`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_solution_document` (
  `document_id` bigint NOT NULL COMMENT '文档ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `quote_id` bigint DEFAULT NULL COMMENT '关联报价单ID(FK→cpq_quote)',
  `document_type` varchar(20) COLLATE utf8mb4_general_ci NOT NULL COMMENT '类型: TECHNICAL_PROPOSAL/BUSINESS_PROPOSAL/DELIVERY_PLAN/IMPLEMENTATION/ACCEPTANCE',
  `document_name` varchar(200) COLLATE utf8mb4_general_ci NOT NULL COMMENT '文档名称',
  `document_content` longtext COLLATE utf8mb4_general_ci COMMENT '文档内容(Tiptap JSON)',
  `document_json` json DEFAULT NULL COMMENT '文档结构化数据(JSON)',
  `version` int DEFAULT '1' COMMENT '版本号',
  `status` varchar(20) COLLATE utf8mb4_general_ci DEFAULT 'DRAFT' COMMENT '状态: DRAFT/EDITING/REVIEWING/APPROVED/PUBLISHED',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`document_id`),
  KEY `idx_quote` (`tenant_id`,`quote_id`),
  KEY `idx_type` (`tenant_id`,`document_type`),
  KEY `idx_status` (`tenant_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ方案文档(方案交付物: 技术方案书/商务方案书/实施计划/验收标准)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_sync_log`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_sync_log` (
  `log_id` bigint NOT NULL COMMENT '日志ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `config_id` bigint NOT NULL COMMENT '集成配置ID(FK→cpq_integration_config)',
  `sync_direction` varchar(10) COLLATE utf8mb4_general_ci NOT NULL COMMENT '方向: INBOUND(外部→CPQ)/OUTBOUND(CPQ→外部)',
  `sync_status` varchar(20) COLLATE utf8mb4_general_ci NOT NULL COMMENT '状态: SUCCESS/FAILED/PARTIAL',
  `records_total` int DEFAULT NULL COMMENT '总记录数',
  `records_success` int DEFAULT NULL COMMENT '成功数',
  `records_failed` int DEFAULT NULL COMMENT '失败数',
  `error_detail` text COLLATE utf8mb4_general_ci COMMENT '错误详情',
  `sync_time` datetime NOT NULL COMMENT '同步时间',
  `duration_ms` int DEFAULT NULL COMMENT '耗时(毫秒)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '0正常 2删除',
  PRIMARY KEY (`log_id`),
  KEY `idx_config_time` (`tenant_id`,`config_id`,`sync_time` DESC),
  KEY `idx_status` (`tenant_id`,`sync_status`,`sync_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ同步日志(记录每次数据集成的完整执行结果)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_system_config`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_system_config` (
  `config_id` bigint NOT NULL COMMENT '配置ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `config_key` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '配置键',
  `config_value` text COLLATE utf8mb4_general_ci NOT NULL COMMENT '配置值',
  `config_type` varchar(20) COLLATE utf8mb4_general_ci DEFAULT 'STRING' COMMENT '值类型: STRING/NUMBER/JSON/BOOLEAN',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`config_id`),
  UNIQUE KEY `uk_key` (`tenant_id`,`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ系统参数(扩展RuoYi sys_config, 存储CPQ业务级配置参数)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_territory`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_territory` (
  `territory_id` bigint NOT NULL COMMENT '区域ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `territory_name` varchar(200) COLLATE utf8mb4_general_ci NOT NULL COMMENT '区域名称',
  `territory_code` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT '区域编码',
  `parent_territory_id` bigint DEFAULT NULL COMMENT '父区域ID(自引用, 支持大区→省→市层级)',
  `region` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '地理区域: CN_NORTH/CN_EAST/CN_SOUTH/CN_WEST/CN_CENTER/APAC/EMEA/AMER',
  `manager_id` bigint DEFAULT NULL COMMENT '区域经理(用户ID)',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`territory_id`),
  UNIQUE KEY `uk_tenant_code` (`tenant_id`,`territory_code`),
  KEY `idx_parent` (`tenant_id`,`parent_territory_id`),
  KEY `idx_region` (`tenant_id`,`region`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ销售区域(多层级树: 大区→省→市, 用于区域权限控制和区域定价)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_variant_bom`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_variant_bom` (
  `variant_id` bigint NOT NULL COMMENT '变体ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `model_id` bigint NOT NULL COMMENT '产品ID(FK→cpq_product_model)',
  `sbom_line_id` bigint DEFAULT NULL COMMENT '关联SBOM行ID(FK→cpq_sbom_line)',
  `material_code` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '物料编码',
  `quantity` decimal(12,4) NOT NULL COMMENT '用量',
  `effectivity_condition` text COLLATE utf8mb4_general_ci NOT NULL COMMENT '有效性条件(JSON): {attr_name: value, ...}, 满足条件时此物料生效',
  `is_default` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '是否默认变体',
  `sort_order` int DEFAULT '0' COMMENT '排序号',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`variant_id`),
  KEY `idx_model` (`tenant_id`,`model_id`),
  KEY `idx_sbom_line` (`tenant_id`,`sbom_line_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ变体BOM(150% BOM: 全平台变体列出→CSP求解过滤为100%)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpq_volume_tier`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cpq_volume_tier` (
  `tier_id` bigint NOT NULL COMMENT '阶梯ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户ID',
  `price_book_entry_id` bigint NOT NULL COMMENT '价格手册条目ID(FK→cpq_price_book_entry)',
  `min_quantity` decimal(12,4) NOT NULL COMMENT '最小数量',
  `max_quantity` decimal(12,4) DEFAULT NULL COMMENT '最大数量(NULL=无限)',
  `unit_price` decimal(18,2) NOT NULL COMMENT '阶梯单价',
  `sort_order` int DEFAULT '0' COMMENT '排序号',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
  `create_dept` bigint DEFAULT NULL,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`tier_id`),
  KEY `idx_entry` (`tenant_id`,`price_book_entry_id`),
  KEY `idx_quantity` (`tenant_id`,`price_book_entry_id`,`min_quantity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ阶梯定价(100个以下¥100 / 100-500个¥85 / 500+个¥70)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flow_category`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `flow_category` (
  `category_id` bigint NOT NULL COMMENT '流程分类ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户编号',
  `parent_id` bigint DEFAULT '0' COMMENT '父流程分类id',
  `ancestors` varchar(500) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '祖级列表',
  `category_name` varchar(30) COLLATE utf8mb4_general_ci NOT NULL COMMENT '流程分类名称',
  `order_num` int DEFAULT '0' COMMENT '显示顺序',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志（0代表存在 1代表删除）',
  `create_dept` bigint DEFAULT NULL COMMENT '创建部门',
  `create_by` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='流程分类';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flow_definition`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `flow_definition` (
  `id` bigint NOT NULL COMMENT '主键id',
  `flow_code` varchar(40) COLLATE utf8mb4_general_ci NOT NULL COMMENT '流程编码',
  `flow_name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '流程名称',
  `model_value` varchar(40) COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'CLASSICS' COMMENT '设计器模型（CLASSICS经典模型 MIMIC仿钉钉模型）',
  `category` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '流程类别',
  `version` varchar(20) COLLATE utf8mb4_general_ci NOT NULL COMMENT '流程版本',
  `is_publish` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否发布（0未发布 1已发布 9失效）',
  `form_custom` char(1) COLLATE utf8mb4_general_ci DEFAULT 'N' COMMENT '审批表单是否自定义（Y是 N否）',
  `form_path` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '审批表单路径',
  `activity_status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '流程激活状态（0挂起 1激活）',
  `listener_type` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '监听器类型',
  `listener_path` varchar(400) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '监听器路径',
  `ext` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '业务详情 存业务表对象json字符串',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(64) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(64) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '更新人',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志',
  `tenant_id` varchar(40) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '租户id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='流程定义表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flow_his_task`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `flow_his_task` (
  `id` bigint NOT NULL COMMENT '主键id',
  `definition_id` bigint NOT NULL COMMENT '对应flow_definition表的id',
  `instance_id` bigint NOT NULL COMMENT '对应flow_instance表的id',
  `task_id` bigint NOT NULL COMMENT '对应flow_task表的id',
  `node_code` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '开始节点编码',
  `node_name` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '开始节点名称',
  `node_type` tinyint(1) DEFAULT NULL COMMENT '开始节点类型（0开始节点 1中间节点 2结束节点 3互斥网关 4并行网关）',
  `target_node_code` varchar(200) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '目标节点编码',
  `target_node_name` varchar(200) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '结束节点名称',
  `approver` varchar(40) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '审批人',
  `cooperate_type` tinyint(1) NOT NULL DEFAULT '0' COMMENT '协作方式(1审批 2转办 3委派 4会签 5票签 6加签 7减签)',
  `collaborator` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '协作人',
  `skip_type` varchar(10) COLLATE utf8mb4_general_ci NOT NULL COMMENT '流转类型（PASS通过 REJECT退回 NONE无动作）',
  `flow_status` varchar(20) COLLATE utf8mb4_general_ci NOT NULL COMMENT '流程状态（0待提交 1审批中 2审批通过 4终止 5作废 6撤销 8已完成 9已退回 10失效 11拿回）',
  `form_custom` char(1) COLLATE utf8mb4_general_ci DEFAULT 'N' COMMENT '审批表单是否自定义（Y是 N否）',
  `form_path` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '审批表单路径',
  `message` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '审批意见',
  `variable` text COLLATE utf8mb4_general_ci COMMENT '任务变量',
  `ext` text COLLATE utf8mb4_general_ci COMMENT '业务详情 存业务表对象json字符串',
  `create_time` datetime DEFAULT NULL COMMENT '任务开始时间',
  `update_time` datetime DEFAULT NULL COMMENT '审批完成时间',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志',
  `tenant_id` varchar(40) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '租户id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='历史任务记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flow_instance`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `flow_instance` (
  `id` bigint NOT NULL COMMENT '主键id',
  `definition_id` bigint NOT NULL COMMENT '对应flow_definition表的id',
  `business_id` varchar(40) COLLATE utf8mb4_general_ci NOT NULL COMMENT '业务id',
  `node_type` tinyint(1) NOT NULL COMMENT '节点类型（0开始节点 1中间节点 2结束节点 3互斥网关 4并行网关）',
  `node_code` varchar(40) COLLATE utf8mb4_general_ci NOT NULL COMMENT '流程节点编码',
  `node_name` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '流程节点名称',
  `variable` text COLLATE utf8mb4_general_ci COMMENT '任务变量',
  `flow_status` varchar(20) COLLATE utf8mb4_general_ci NOT NULL COMMENT '流程状态（0待提交 1审批中 2审批通过 4终止 5作废 6撤销 8已完成 9已退回 10失效 11拿回）',
  `activity_status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '流程激活状态（0挂起 1激活）',
  `def_json` text COLLATE utf8mb4_general_ci COMMENT '流程定义json',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(64) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(64) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '更新人',
  `ext` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '扩展字段，预留给业务系统使用',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志',
  `tenant_id` varchar(40) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '租户id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='流程实例表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flow_instance_biz_ext`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `flow_instance_biz_ext` (
  `id` bigint NOT NULL COMMENT '主键id',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户编号',
  `create_dept` bigint DEFAULT NULL COMMENT '创建部门',
  `create_by` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `business_code` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '业务编码',
  `business_title` varchar(1000) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '业务标题',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志（0代表存在 1代表删除）',
  `instance_id` bigint DEFAULT NULL COMMENT '流程实例Id',
  `business_id` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '业务Id',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='流程实例业务扩展表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flow_node`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `flow_node` (
  `id` bigint NOT NULL COMMENT '主键id',
  `node_type` tinyint(1) NOT NULL COMMENT '节点类型（0开始节点 1中间节点 2结束节点 3互斥网关 4并行网关）',
  `definition_id` bigint NOT NULL COMMENT '流程定义id',
  `node_code` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '流程节点编码',
  `node_name` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '流程节点名称',
  `permission_flag` varchar(200) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '权限标识（权限类型:权限标识，可以多个，用@@隔开)',
  `node_ratio` varchar(200) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '流程签署比例值',
  `coordinate` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '坐标',
  `any_node_skip` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '任意结点跳转',
  `listener_type` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '监听器类型',
  `listener_path` varchar(400) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '监听器路径',
  `form_custom` char(1) COLLATE utf8mb4_general_ci DEFAULT 'N' COMMENT '审批表单是否自定义（Y是 N否）',
  `form_path` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '审批表单路径',
  `version` varchar(20) COLLATE utf8mb4_general_ci NOT NULL COMMENT '版本',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(64) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(64) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '更新人',
  `ext` text COLLATE utf8mb4_general_ci COMMENT '节点扩展属性',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志',
  `tenant_id` varchar(40) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '租户id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='流程节点表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flow_skip`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `flow_skip` (
  `id` bigint NOT NULL COMMENT '主键id',
  `definition_id` bigint NOT NULL COMMENT '流程定义id',
  `now_node_code` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '当前流程节点的编码',
  `now_node_type` tinyint(1) DEFAULT NULL COMMENT '当前节点类型（0开始节点 1中间节点 2结束节点 3互斥网关 4并行网关）',
  `next_node_code` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '下一个流程节点的编码',
  `next_node_type` tinyint(1) DEFAULT NULL COMMENT '下一个节点类型（0开始节点 1中间节点 2结束节点 3互斥网关 4并行网关）',
  `skip_name` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '跳转名称',
  `skip_type` varchar(40) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '跳转类型（PASS审批通过 REJECT退回）',
  `skip_condition` varchar(200) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '跳转条件',
  `coordinate` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '坐标',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(64) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(64) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '更新人',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志',
  `tenant_id` varchar(40) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '租户id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='节点跳转关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flow_spel`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `flow_spel` (
  `id` bigint NOT NULL COMMENT '主键id',
  `component_name` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '组件名称',
  `method_name` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '方法名',
  `method_params` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '参数',
  `view_spel` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '预览spel表达式',
  `remark` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志',
  `create_dept` bigint DEFAULT NULL COMMENT '创建部门',
  `create_by` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='流程spel表达式定义表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flow_task`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `flow_task` (
  `id` bigint NOT NULL COMMENT '主键id',
  `definition_id` bigint NOT NULL COMMENT '对应flow_definition表的id',
  `instance_id` bigint NOT NULL COMMENT '对应flow_instance表的id',
  `node_code` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '节点编码',
  `node_name` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '节点名称',
  `node_type` tinyint(1) NOT NULL COMMENT '节点类型（0开始节点 1中间节点 2结束节点 3互斥网关 4并行网关）',
  `flow_status` varchar(20) COLLATE utf8mb4_general_ci NOT NULL COMMENT '流程状态（0待提交 1审批中 2审批通过 4终止 5作废 6撤销 8已完成 9已退回 10失效 11拿回）',
  `form_custom` char(1) COLLATE utf8mb4_general_ci DEFAULT 'N' COMMENT '审批表单是否自定义（Y是 N否）',
  `form_path` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '审批表单路径',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(64) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(64) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '更新人',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志',
  `tenant_id` varchar(40) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '租户id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='待办任务表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flow_user`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `flow_user` (
  `id` bigint NOT NULL COMMENT '主键id',
  `type` char(1) COLLATE utf8mb4_general_ci NOT NULL COMMENT '人员类型（1待办任务的审批人权限 2待办任务的转办人权限 3待办任务的委托人权限）',
  `processed_by` varchar(80) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '权限人',
  `associated` bigint NOT NULL COMMENT '任务表id',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(80) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(64) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '创建人',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志',
  `tenant_id` varchar(40) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '租户id',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `user_processed_type` (`processed_by`,`type`),
  KEY `user_associated` (`associated`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='流程用户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gen_table`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_table` (
  `table_id` bigint NOT NULL COMMENT '编号',
  `data_name` varchar(200) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '数据源名称',
  `table_name` varchar(200) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '表名称',
  `table_comment` varchar(500) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '表描述',
  `sub_table_name` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '关联子表的表名',
  `sub_table_fk_name` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '子表关联的外键名',
  `class_name` varchar(100) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '实体类名称',
  `tpl_category` varchar(200) COLLATE utf8mb4_general_ci DEFAULT 'crud' COMMENT '使用的模板（crud单表操作 tree树表操作）',
  `package_name` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '生成包路径',
  `module_name` varchar(30) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '生成模块名',
  `business_name` varchar(30) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '生成业务名',
  `function_name` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '生成功能名',
  `function_author` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '生成功能作者',
  `gen_type` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '生成代码方式（0zip压缩包 1自定义路径）',
  `gen_path` varchar(200) COLLATE utf8mb4_general_ci DEFAULT '/' COMMENT '生成路径（不填默认项目路径）',
  `options` varchar(1000) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '其它生成选项',
  `create_dept` bigint DEFAULT NULL COMMENT '创建部门',
  `create_by` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`table_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='代码生成业务表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gen_table_column`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_table_column` (
  `column_id` bigint NOT NULL COMMENT '编号',
  `table_id` bigint DEFAULT NULL COMMENT '归属表编号',
  `column_name` varchar(200) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '列名称',
  `column_comment` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '列描述',
  `column_type` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '列类型',
  `java_type` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'JAVA类型',
  `java_field` varchar(200) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'JAVA字段名',
  `is_pk` char(1) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '是否主键（1是）',
  `is_increment` char(1) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '是否自增（1是）',
  `is_required` char(1) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '是否必填（1是）',
  `is_insert` char(1) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '是否为插入字段（1是）',
  `is_edit` char(1) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '是否编辑字段（1是）',
  `is_list` char(1) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '是否列表字段（1是）',
  `is_query` char(1) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '是否查询字段（1是）',
  `query_type` varchar(200) COLLATE utf8mb4_general_ci DEFAULT 'EQ' COMMENT '查询方式（等于、不等于、大于、小于、范围）',
  `html_type` varchar(200) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '显示类型（文本框、文本域、下拉框、复选框、单选框、日期控件）',
  `dict_type` varchar(200) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '字典类型',
  `sort` int DEFAULT NULL COMMENT '排序',
  `create_dept` bigint DEFAULT NULL COMMENT '创建部门',
  `create_by` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`column_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='代码生成业务表字段';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sys_client`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_client` (
  `id` bigint NOT NULL COMMENT 'id',
  `client_id` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '客户端id',
  `client_key` varchar(32) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '客户端key',
  `client_secret` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '客户端秘钥',
  `grant_type` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '授权类型',
  `device_type` varchar(32) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '设备类型',
  `active_timeout` int DEFAULT '1800' COMMENT 'token活跃超时时间',
  `timeout` int DEFAULT '604800' COMMENT 'token固定超时',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志（0代表存在 1代表删除）',
  `create_dept` bigint DEFAULT NULL COMMENT '创建部门',
  `create_by` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='系统授权表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sys_config`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_config` (
  `config_id` bigint NOT NULL COMMENT '参数主键',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户编号',
  `config_name` varchar(100) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '参数名称',
  `config_key` varchar(100) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '参数键名',
  `config_value` varchar(500) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '参数键值',
  `config_type` char(1) COLLATE utf8mb4_general_ci DEFAULT 'N' COMMENT '系统内置（Y是 N否）',
  `create_dept` bigint DEFAULT NULL COMMENT '创建部门',
  `create_by` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`config_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='参数配置表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sys_dept`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dept` (
  `dept_id` bigint NOT NULL COMMENT '部门id',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户编号',
  `parent_id` bigint DEFAULT '0' COMMENT '父部门id',
  `ancestors` varchar(500) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '祖级列表',
  `dept_name` varchar(30) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '部门名称',
  `dept_category` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '部门类别编码',
  `order_num` int DEFAULT '0' COMMENT '显示顺序',
  `leader` bigint DEFAULT NULL COMMENT '负责人',
  `phone` varchar(11) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '联系电话',
  `email` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '邮箱',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '部门状态（0正常 1停用）',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志（0代表存在 1代表删除）',
  `create_dept` bigint DEFAULT NULL COMMENT '创建部门',
  `create_by` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`dept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='部门表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sys_dict_data`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dict_data` (
  `dict_code` bigint NOT NULL COMMENT '字典编码',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户编号',
  `dict_sort` int DEFAULT '0' COMMENT '字典排序',
  `dict_label` varchar(100) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '字典标签',
  `dict_value` varchar(100) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '字典键值',
  `dict_type` varchar(100) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '字典类型',
  `css_class` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '样式属性（其他样式扩展）',
  `list_class` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '表格回显样式',
  `is_default` char(1) COLLATE utf8mb4_general_ci DEFAULT 'N' COMMENT '是否默认（Y是 N否）',
  `create_dept` bigint DEFAULT NULL COMMENT '创建部门',
  `create_by` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='字典数据表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sys_dict_type`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dict_type` (
  `dict_id` bigint NOT NULL COMMENT '字典主键',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户编号',
  `dict_name` varchar(100) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '字典名称',
  `dict_type` varchar(100) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '字典类型',
  `create_dept` bigint DEFAULT NULL COMMENT '创建部门',
  `create_by` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_id`),
  UNIQUE KEY `tenant_id` (`tenant_id`,`dict_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='字典类型表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sys_logininfor`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_logininfor` (
  `info_id` bigint NOT NULL COMMENT '访问ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户编号',
  `user_name` varchar(50) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '用户账号',
  `client_key` varchar(32) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '客户端',
  `device_type` varchar(32) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '设备类型',
  `ipaddr` varchar(128) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '登录IP地址',
  `login_location` varchar(255) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '登录地点',
  `browser` varchar(50) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '浏览器类型',
  `os` varchar(50) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '操作系统',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '登录状态（0成功 1失败）',
  `msg` varchar(255) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '提示消息',
  `login_time` datetime DEFAULT NULL COMMENT '访问时间',
  PRIMARY KEY (`info_id`),
  KEY `idx_sys_logininfor_s` (`status`),
  KEY `idx_sys_logininfor_lt` (`login_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='系统访问记录';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sys_menu`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_menu` (
  `menu_id` bigint NOT NULL COMMENT '菜单ID',
  `menu_name` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT '菜单名称',
  `parent_id` bigint DEFAULT '0' COMMENT '父菜单ID',
  `order_num` int DEFAULT '0' COMMENT '显示顺序',
  `path` varchar(200) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '路由地址',
  `component` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '组件路径',
  `query_param` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '路由参数',
  `is_frame` int DEFAULT '1' COMMENT '是否为外链（0是 1否）',
  `is_cache` int DEFAULT '0' COMMENT '是否缓存（0缓存 1不缓存）',
  `menu_type` char(1) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '菜单类型（M目录 C菜单 F按钮）',
  `visible` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '显示状态（0显示 1隐藏）',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '菜单状态（0正常 1停用）',
  `perms` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '权限标识',
  `icon` varchar(100) COLLATE utf8mb4_general_ci DEFAULT '#' COMMENT '菜单图标',
  `create_dept` bigint DEFAULT NULL COMMENT '创建部门',
  `create_by` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='菜单权限表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sys_notice`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_notice` (
  `notice_id` bigint NOT NULL COMMENT '公告ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户编号',
  `notice_title` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT '公告标题',
  `notice_type` char(1) COLLATE utf8mb4_general_ci NOT NULL COMMENT '公告类型（1通知 2公告）',
  `notice_content` longblob COMMENT '公告内容',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '公告状态（0正常 1关闭）',
  `create_dept` bigint DEFAULT NULL COMMENT '创建部门',
  `create_by` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`notice_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='通知公告表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sys_oper_log`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_oper_log` (
  `oper_id` bigint NOT NULL COMMENT '日志主键',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户编号',
  `title` varchar(50) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '模块标题',
  `business_type` int DEFAULT '0' COMMENT '业务类型（0其它 1新增 2修改 3删除）',
  `method` varchar(100) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '方法名称',
  `request_method` varchar(10) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '请求方式',
  `operator_type` int DEFAULT '0' COMMENT '操作类别（0其它 1后台用户 2手机端用户）',
  `oper_name` varchar(50) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '操作人员',
  `dept_name` varchar(50) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '部门名称',
  `oper_url` varchar(255) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '请求URL',
  `oper_ip` varchar(128) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '主机地址',
  `oper_location` varchar(255) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '操作地点',
  `oper_param` varchar(4000) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '请求参数',
  `json_result` varchar(4000) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '返回参数',
  `status` int DEFAULT '0' COMMENT '操作状态（0正常 1异常）',
  `error_msg` varchar(4000) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '错误消息',
  `oper_time` datetime DEFAULT NULL COMMENT '操作时间',
  `cost_time` bigint DEFAULT '0' COMMENT '消耗时间',
  PRIMARY KEY (`oper_id`),
  KEY `idx_sys_oper_log_bt` (`business_type`),
  KEY `idx_sys_oper_log_s` (`status`),
  KEY `idx_sys_oper_log_ot` (`oper_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='操作日志记录';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sys_oss`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_oss` (
  `oss_id` bigint NOT NULL COMMENT '对象存储主键',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户编号',
  `file_name` varchar(255) COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '文件名',
  `original_name` varchar(255) COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '原名',
  `file_suffix` varchar(10) COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '文件后缀名',
  `url` varchar(500) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'URL地址',
  `ext1` text COLLATE utf8mb4_general_ci COMMENT '扩展字段',
  `create_dept` bigint DEFAULT NULL COMMENT '创建部门',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_by` bigint DEFAULT NULL COMMENT '上传人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新人',
  `service` varchar(20) COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'minio' COMMENT '服务商',
  PRIMARY KEY (`oss_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='OSS对象存储表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sys_oss_config`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_oss_config` (
  `oss_config_id` bigint NOT NULL COMMENT '主键',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户编号',
  `config_key` varchar(20) COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '配置key',
  `access_key` varchar(255) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT 'accessKey',
  `secret_key` varchar(255) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '秘钥',
  `bucket_name` varchar(255) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '桶名称',
  `prefix` varchar(255) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '前缀',
  `endpoint` varchar(255) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '访问站点',
  `domain` varchar(255) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '自定义域名',
  `is_https` char(1) COLLATE utf8mb4_general_ci DEFAULT 'N' COMMENT '是否https（Y=是,N=否）',
  `region` varchar(255) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '域',
  `access_policy` char(1) COLLATE utf8mb4_general_ci NOT NULL DEFAULT '1' COMMENT '桶权限类型(0=private 1=public 2=custom)',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '1' COMMENT '是否默认（0=是,1=否）',
  `ext1` varchar(255) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '扩展字段',
  `create_dept` bigint DEFAULT NULL COMMENT '创建部门',
  `create_by` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`oss_config_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='对象存储配置表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sys_post`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_post` (
  `post_id` bigint NOT NULL COMMENT '岗位ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户编号',
  `dept_id` bigint NOT NULL COMMENT '部门id',
  `post_code` varchar(64) COLLATE utf8mb4_general_ci NOT NULL COMMENT '岗位编码',
  `post_category` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '岗位类别编码',
  `post_name` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT '岗位名称',
  `post_sort` int NOT NULL COMMENT '显示顺序',
  `status` char(1) COLLATE utf8mb4_general_ci NOT NULL COMMENT '状态（0正常 1停用）',
  `create_dept` bigint DEFAULT NULL COMMENT '创建部门',
  `create_by` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`post_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='岗位信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sys_role`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role` (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户编号',
  `role_name` varchar(30) COLLATE utf8mb4_general_ci NOT NULL COMMENT '角色名称',
  `role_key` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '角色权限字符串',
  `role_sort` int NOT NULL COMMENT '显示顺序',
  `data_scope` char(1) COLLATE utf8mb4_general_ci DEFAULT '1' COMMENT '数据范围（1：全部数据权限 2：自定数据权限 3：本部门数据权限 4：本部门及以下数据权限 5：仅本人数据权限 6：部门及以下或本人数据权限）',
  `menu_check_strictly` tinyint(1) DEFAULT '1' COMMENT '菜单树选择项是否关联显示',
  `dept_check_strictly` tinyint(1) DEFAULT '1' COMMENT '部门树选择项是否关联显示',
  `status` char(1) COLLATE utf8mb4_general_ci NOT NULL COMMENT '角色状态（0正常 1停用）',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志（0代表存在 1代表删除）',
  `create_dept` bigint DEFAULT NULL COMMENT '创建部门',
  `create_by` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='角色信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sys_role_dept`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role_dept` (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `dept_id` bigint NOT NULL COMMENT '部门ID',
  PRIMARY KEY (`role_id`,`dept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='角色和部门关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sys_role_menu`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role_menu` (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `menu_id` bigint NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`,`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='角色和菜单关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sys_social`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_social` (
  `id` bigint NOT NULL COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户id',
  `auth_id` varchar(255) COLLATE utf8mb4_general_ci NOT NULL COMMENT '平台+平台唯一id',
  `source` varchar(255) COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户来源',
  `open_id` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '平台编号唯一id',
  `user_name` varchar(30) COLLATE utf8mb4_general_ci NOT NULL COMMENT '登录账号',
  `nick_name` varchar(30) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '用户昵称',
  `email` varchar(255) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '用户邮箱',
  `avatar` varchar(500) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '头像地址',
  `access_token` varchar(2000) COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户的授权令牌',
  `expire_in` int DEFAULT NULL COMMENT '用户的授权令牌的有效期，部分平台可能没有',
  `refresh_token` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '刷新令牌，部分平台可能没有',
  `access_code` varchar(2000) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '平台的授权信息，部分平台可能没有',
  `union_id` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '用户的 unionid',
  `scope` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '授予的权限，部分平台可能没有',
  `token_type` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '个别平台的授权信息，部分平台可能没有',
  `id_token` varchar(2000) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'id token，部分平台可能没有',
  `mac_algorithm` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '小米平台用户的附带属性，部分平台可能没有',
  `mac_key` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '小米平台用户的附带属性，部分平台可能没有',
  `code` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '用户的授权code，部分平台可能没有',
  `oauth_token` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'Twitter平台用户的附带属性，部分平台可能没有',
  `oauth_token_secret` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'Twitter平台用户的附带属性，部分平台可能没有',
  `create_dept` bigint DEFAULT NULL COMMENT '创建部门',
  `create_by` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志（0代表存在 1代表删除）',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='社会化关系表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sys_tenant`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_tenant` (
  `id` bigint NOT NULL COMMENT 'id',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci NOT NULL COMMENT '租户编号',
  `contact_user_name` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '联系人',
  `contact_phone` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '联系电话',
  `company_name` varchar(30) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '企业名称',
  `license_number` varchar(30) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '统一社会信用代码',
  `address` varchar(200) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '地址',
  `intro` varchar(200) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '企业简介',
  `domain` varchar(200) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '域名',
  `remark` varchar(200) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  `package_id` bigint DEFAULT NULL COMMENT '租户套餐编号',
  `expire_time` datetime DEFAULT NULL COMMENT '过期时间',
  `account_count` int DEFAULT '-1' COMMENT '用户数量（-1不限制）',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '租户状态（0正常 1停用）',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志（0代表存在 1代表删除）',
  `create_dept` bigint DEFAULT NULL COMMENT '创建部门',
  `create_by` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='租户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sys_tenant_package`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_tenant_package` (
  `package_id` bigint NOT NULL COMMENT '租户套餐id',
  `package_name` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '套餐名称',
  `menu_ids` varchar(3000) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '关联菜单id',
  `remark` varchar(200) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  `menu_check_strictly` tinyint(1) DEFAULT '1' COMMENT '菜单树选择项是否关联显示',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志（0代表存在 1代表删除）',
  `create_dept` bigint DEFAULT NULL COMMENT '创建部门',
  `create_by` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`package_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='租户套餐表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sys_user`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user` (
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户编号',
  `dept_id` bigint DEFAULT NULL COMMENT '部门ID',
  `user_name` varchar(30) COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户账号',
  `nick_name` varchar(30) COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户昵称',
  `user_type` varchar(10) COLLATE utf8mb4_general_ci DEFAULT 'sys_user' COMMENT '用户类型（sys_user系统用户）',
  `email` varchar(50) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '用户邮箱',
  `phonenumber` varchar(11) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '手机号码',
  `sex` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '用户性别（0男 1女 2未知）',
  `avatar` bigint DEFAULT NULL COMMENT '头像地址',
  `password` varchar(100) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '密码',
  `status` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '账号状态（0正常 1停用）',
  `del_flag` char(1) COLLATE utf8mb4_general_ci DEFAULT '0' COMMENT '删除标志（0代表存在 1代表删除）',
  `login_ip` varchar(128) COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '最后登录IP',
  `login_date` datetime DEFAULT NULL COMMENT '最后登录时间',
  `create_dept` bigint DEFAULT NULL COMMENT '创建部门',
  `create_by` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sys_user_post`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user_post` (
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `post_id` bigint NOT NULL COMMENT '岗位ID',
  PRIMARY KEY (`user_id`,`post_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户与岗位关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sys_user_role`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user_role` (
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`,`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户和角色关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `test_demo`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `test_demo` (
  `id` bigint NOT NULL COMMENT '主键',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户编号',
  `dept_id` bigint DEFAULT NULL COMMENT '部门id',
  `user_id` bigint DEFAULT NULL COMMENT '用户id',
  `order_num` int DEFAULT '0' COMMENT '排序号',
  `test_key` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'key键',
  `value` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '值',
  `version` int DEFAULT '0' COMMENT '版本',
  `create_dept` bigint DEFAULT NULL COMMENT '创建部门',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新人',
  `del_flag` int DEFAULT '0' COMMENT '删除标志',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='测试单表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `test_leave`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `test_leave` (
  `id` bigint NOT NULL COMMENT 'id',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户编号',
  `apply_code` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT '申请编号',
  `leave_type` varchar(255) COLLATE utf8mb4_general_ci NOT NULL COMMENT '请假类型',
  `start_date` datetime NOT NULL COMMENT '开始时间',
  `end_date` datetime NOT NULL COMMENT '结束时间',
  `leave_days` int NOT NULL COMMENT '请假天数',
  `remark` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '请假原因',
  `status` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '状态',
  `create_dept` bigint DEFAULT NULL COMMENT '创建部门',
  `create_by` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='请假申请表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `test_tree`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `test_tree` (
  `id` bigint NOT NULL COMMENT '主键',
  `tenant_id` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '000000' COMMENT '租户编号',
  `parent_id` bigint DEFAULT '0' COMMENT '父id',
  `dept_id` bigint DEFAULT NULL COMMENT '部门id',
  `user_id` bigint DEFAULT NULL COMMENT '用户id',
  `tree_name` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '值',
  `version` int DEFAULT '0' COMMENT '版本',
  `create_dept` bigint DEFAULT NULL COMMENT '创建部门',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新人',
  `del_flag` int DEFAULT '0' COMMENT '删除标志',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='测试树表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping routines for database 'Ruoyi_CPQ'
--
--
-- WARNING: can't read the INFORMATION_SCHEMA.libraries table. It's most probably an old server 8.0.46.
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-01 23:18:35
