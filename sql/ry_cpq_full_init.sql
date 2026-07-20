-- ============================================================
-- Ruoyi_CPQ 完整数据库初始化脚本
-- 基于本地数据库结构导出，2026-07-01
-- 包含：所有表DDL + 系统初始数据（菜单、用户、角色、字典等）
-- 不包含：CPQ业务数据（由Mock Data脚本另行导入）
-- ============================================================

DROP DATABASE IF EXISTS Ruoyi_CPQ;
CREATE DATABASE Ruoyi_CPQ DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE Ruoyi_CPQ;

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

-- ============================================================
-- 系统初始数据
-- ============================================================

LOCK TABLES `sys_menu` WRITE;
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query_param`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_dept`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (1,'系统管理',0,1,'system',NULL,'',1,0,'M','0','0','','system',103,1,'2026-06-06 03:02:21',NULL,NULL,'系统管理目录'),(2,'系统监控',3,3,'monitor',NULL,'',1,0,'M','0','0','','monitor',103,1,'2026-06-06 03:02:21',1,'2026-06-06 17:12:58','系统监控目录'),(3,'系统工具',0,4,'tool',NULL,'',1,0,'M','0','0','','tool',103,1,'2026-06-06 03:02:21',NULL,NULL,'系统工具目录'),(6,'租户管理',3,5,'tenant',NULL,'',1,0,'M','0','0','','chart',103,1,'2026-06-06 03:02:21',1,'2026-06-06 16:56:32','租户管理目录'),(100,'用户管理',1,1,'user','system/user/index','',1,0,'C','0','0','system:user:list','user',103,1,'2026-06-06 03:02:21',NULL,NULL,'用户管理菜单'),(101,'角色管理',1,2,'role','system/role/index','',1,0,'C','0','0','system:role:list','peoples',103,1,'2026-06-06 03:02:21',NULL,NULL,'角色管理菜单'),(102,'菜单管理',1,3,'menu','system/menu/index','',1,0,'C','0','0','system:menu:list','tree-table',103,1,'2026-06-06 03:02:21',NULL,NULL,'菜单管理菜单'),(103,'部门管理',1,4,'dept','system/dept/index','',1,0,'C','0','0','system:dept:list','tree',103,1,'2026-06-06 03:02:21',NULL,NULL,'部门管理菜单'),(104,'岗位管理',1,5,'post','system/post/index','',1,0,'C','0','0','system:post:list','post',103,1,'2026-06-06 03:02:21',NULL,NULL,'岗位管理菜单'),(105,'字典管理',1,6,'dict','system/dict/index','',1,0,'C','0','0','system:dict:list','dict',103,1,'2026-06-06 03:02:21',NULL,NULL,'字典管理菜单'),(106,'参数设置',1,7,'config','system/config/index','',1,0,'C','0','0','system:config:list','edit',103,1,'2026-06-06 03:02:21',NULL,NULL,'参数设置菜单'),(107,'通知公告',1,8,'notice','system/notice/index','',1,0,'C','0','0','system:notice:list','message',103,1,'2026-06-06 03:02:21',NULL,NULL,'通知公告菜单'),(108,'日志管理',1,9,'log','','',1,0,'M','0','0','','log',103,1,'2026-06-06 03:02:21',NULL,NULL,'日志管理菜单'),(109,'在线用户',2,1,'online','monitor/online/index','',1,0,'C','0','0','monitor:online:list','online',103,1,'2026-06-06 03:02:21',NULL,NULL,'在线用户菜单'),(113,'缓存监控',2,5,'cache','monitor/cache/index','',1,0,'C','0','0','monitor:cache:list','redis',103,1,'2026-06-06 03:02:21',NULL,NULL,'缓存监控菜单'),(115,'代码生成',3,2,'gen','tool/gen/index','',1,0,'C','0','0','tool:gen:list','code',103,1,'2026-06-06 03:02:21',NULL,NULL,'代码生成菜单'),(116,'修改生成配置',3,2,'gen-edit/index/:tableId','tool/gen/editTable','',1,1,'C','1','0','tool:gen:edit','#',103,1,'2026-06-06 03:02:21',NULL,NULL,'/tool/gen'),(117,'Admin监控',2,5,'Admin','monitor/admin/index','',1,0,'C','0','0','monitor:admin:list','dashboard',103,1,'2026-06-06 03:02:21',NULL,NULL,'Admin监控菜单'),(118,'文件管理',1,10,'oss','system/oss/index','',1,0,'C','0','0','system:oss:list','upload',103,1,'2026-06-06 03:02:21',NULL,NULL,'文件管理菜单'),(120,'任务调度中心',2,6,'snailjob','monitor/snailjob/index','',1,0,'C','0','0','monitor:snailjob:list','job',103,1,'2026-06-06 03:02:21',NULL,NULL,'SnailJob控制台菜单'),(121,'租户管理',6,1,'tenant','system/tenant/index','',1,0,'C','0','0','system:tenant:list','list',103,1,'2026-06-06 03:02:21',NULL,NULL,'租户管理菜单'),(122,'租户套餐管理',6,2,'tenantPackage','system/tenantPackage/index','',1,0,'C','0','0','system:tenantPackage:list','form',103,1,'2026-06-06 03:02:21',NULL,NULL,'租户套餐管理菜单'),(123,'客户端管理',1,11,'client','system/client/index','',1,0,'C','0','0','system:client:list','international',103,1,'2026-06-06 03:02:21',NULL,NULL,'客户端管理菜单'),(130,'分配用户',1,2,'role-auth/user/:roleId','system/role/authUser','',1,1,'C','1','0','system:role:edit','#',103,1,'2026-06-06 03:02:21',NULL,NULL,'/system/role'),(131,'分配角色',1,1,'user-auth/role/:userId','system/user/authRole','',1,1,'C','1','0','system:user:edit','#',103,1,'2026-06-06 03:02:21',NULL,NULL,'/system/user'),(132,'字典数据',1,6,'dict-data/index/:dictId','system/dict/data','',1,1,'C','1','0','system:dict:list','#',103,1,'2026-06-06 03:02:21',NULL,NULL,'/system/dict'),(133,'文件配置管理',1,10,'oss-config/index','system/oss/config','',1,1,'C','1','0','system:ossConfig:list','#',103,1,'2026-06-06 03:02:21',NULL,NULL,'/system/oss'),(500,'操作日志',108,1,'operlog','monitor/operlog/index','',1,0,'C','0','0','monitor:operlog:list','form',103,1,'2026-06-06 03:02:21',NULL,NULL,'操作日志菜单'),(501,'登录日志',108,2,'logininfor','monitor/logininfor/index','',1,0,'C','0','0','monitor:logininfor:list','logininfor',103,1,'2026-06-06 03:02:21',NULL,NULL,'登录日志菜单'),(1001,'用户查询',100,1,'','','',1,0,'F','0','0','system:user:query','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1002,'用户新增',100,2,'','','',1,0,'F','0','0','system:user:add','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1003,'用户修改',100,3,'','','',1,0,'F','0','0','system:user:edit','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1004,'用户删除',100,4,'','','',1,0,'F','0','0','system:user:remove','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1005,'用户导出',100,5,'','','',1,0,'F','0','0','system:user:export','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1006,'用户导入',100,6,'','','',1,0,'F','0','0','system:user:import','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1007,'重置密码',100,7,'','','',1,0,'F','0','0','system:user:resetPwd','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1008,'角色查询',101,1,'','','',1,0,'F','0','0','system:role:query','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1009,'角色新增',101,2,'','','',1,0,'F','0','0','system:role:add','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1010,'角色修改',101,3,'','','',1,0,'F','0','0','system:role:edit','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1011,'角色删除',101,4,'','','',1,0,'F','0','0','system:role:remove','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1012,'角色导出',101,5,'','','',1,0,'F','0','0','system:role:export','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1013,'菜单查询',102,1,'','','',1,0,'F','0','0','system:menu:query','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1014,'菜单新增',102,2,'','','',1,0,'F','0','0','system:menu:add','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1015,'菜单修改',102,3,'','','',1,0,'F','0','0','system:menu:edit','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1016,'菜单删除',102,4,'','','',1,0,'F','0','0','system:menu:remove','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1017,'部门查询',103,1,'','','',1,0,'F','0','0','system:dept:query','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1018,'部门新增',103,2,'','','',1,0,'F','0','0','system:dept:add','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1019,'部门修改',103,3,'','','',1,0,'F','0','0','system:dept:edit','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1020,'部门删除',103,4,'','','',1,0,'F','0','0','system:dept:remove','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1021,'岗位查询',104,1,'','','',1,0,'F','0','0','system:post:query','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1022,'岗位新增',104,2,'','','',1,0,'F','0','0','system:post:add','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1023,'岗位修改',104,3,'','','',1,0,'F','0','0','system:post:edit','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1024,'岗位删除',104,4,'','','',1,0,'F','0','0','system:post:remove','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1025,'岗位导出',104,5,'','','',1,0,'F','0','0','system:post:export','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1026,'字典查询',105,1,'#','','',1,0,'F','0','0','system:dict:query','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1027,'字典新增',105,2,'#','','',1,0,'F','0','0','system:dict:add','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1028,'字典修改',105,3,'#','','',1,0,'F','0','0','system:dict:edit','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1029,'字典删除',105,4,'#','','',1,0,'F','0','0','system:dict:remove','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1030,'字典导出',105,5,'#','','',1,0,'F','0','0','system:dict:export','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1031,'参数查询',106,1,'#','','',1,0,'F','0','0','system:config:query','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1032,'参数新增',106,2,'#','','',1,0,'F','0','0','system:config:add','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1033,'参数修改',106,3,'#','','',1,0,'F','0','0','system:config:edit','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1034,'参数删除',106,4,'#','','',1,0,'F','0','0','system:config:remove','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1035,'参数导出',106,5,'#','','',1,0,'F','0','0','system:config:export','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1036,'公告查询',107,1,'#','','',1,0,'F','0','0','system:notice:query','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1037,'公告新增',107,2,'#','','',1,0,'F','0','0','system:notice:add','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1038,'公告修改',107,3,'#','','',1,0,'F','0','0','system:notice:edit','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1039,'公告删除',107,4,'#','','',1,0,'F','0','0','system:notice:remove','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1040,'操作查询',500,1,'#','','',1,0,'F','0','0','monitor:operlog:query','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1041,'操作删除',500,2,'#','','',1,0,'F','0','0','monitor:operlog:remove','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1042,'日志导出',500,4,'#','','',1,0,'F','0','0','monitor:operlog:export','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1043,'登录查询',501,1,'#','','',1,0,'F','0','0','monitor:logininfor:query','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1044,'登录删除',501,2,'#','','',1,0,'F','0','0','monitor:logininfor:remove','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1045,'日志导出',501,3,'#','','',1,0,'F','0','0','monitor:logininfor:export','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1046,'在线查询',109,1,'#','','',1,0,'F','0','0','monitor:online:query','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1047,'批量强退',109,2,'#','','',1,0,'F','0','0','monitor:online:batchLogout','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1048,'单条强退',109,3,'#','','',1,0,'F','0','0','monitor:online:forceLogout','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1050,'账户解锁',501,4,'#','','',1,0,'F','0','0','monitor:logininfor:unlock','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1055,'生成查询',115,1,'#','','',1,0,'F','0','0','tool:gen:query','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1056,'生成修改',115,2,'#','','',1,0,'F','0','0','tool:gen:edit','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1057,'生成删除',115,3,'#','','',1,0,'F','0','0','tool:gen:remove','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1058,'导入代码',115,2,'#','','',1,0,'F','0','0','tool:gen:import','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1059,'预览代码',115,4,'#','','',1,0,'F','0','0','tool:gen:preview','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1060,'生成代码',115,5,'#','','',1,0,'F','0','0','tool:gen:code','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1061,'客户端管理查询',123,1,'#','','',1,0,'F','0','0','system:client:query','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1062,'客户端管理新增',123,2,'#','','',1,0,'F','0','0','system:client:add','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1063,'客户端管理修改',123,3,'#','','',1,0,'F','0','0','system:client:edit','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1064,'客户端管理删除',123,4,'#','','',1,0,'F','0','0','system:client:remove','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1065,'客户端管理导出',123,5,'#','','',1,0,'F','0','0','system:client:export','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1600,'文件查询',118,1,'#','','',1,0,'F','0','0','system:oss:query','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1601,'文件上传',118,2,'#','','',1,0,'F','0','0','system:oss:upload','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1602,'文件下载',118,3,'#','','',1,0,'F','0','0','system:oss:download','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1603,'文件删除',118,4,'#','','',1,0,'F','0','0','system:oss:remove','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1606,'租户查询',121,1,'#','','',1,0,'F','0','0','system:tenant:query','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1607,'租户新增',121,2,'#','','',1,0,'F','0','0','system:tenant:add','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1608,'租户修改',121,3,'#','','',1,0,'F','0','0','system:tenant:edit','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1609,'租户删除',121,4,'#','','',1,0,'F','0','0','system:tenant:remove','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1610,'租户导出',121,5,'#','','',1,0,'F','0','0','system:tenant:export','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1611,'租户套餐查询',122,1,'#','','',1,0,'F','0','0','system:tenantPackage:query','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1612,'租户套餐新增',122,2,'#','','',1,0,'F','0','0','system:tenantPackage:add','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1613,'租户套餐修改',122,3,'#','','',1,0,'F','0','0','system:tenantPackage:edit','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1614,'租户套餐删除',122,4,'#','','',1,0,'F','0','0','system:tenantPackage:remove','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1615,'租户套餐导出',122,5,'#','','',1,0,'F','0','0','system:tenantPackage:export','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1620,'配置列表',118,5,'#','','',1,0,'F','0','0','system:ossConfig:list','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1621,'配置添加',118,6,'#','','',1,0,'F','0','0','system:ossConfig:add','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1622,'配置编辑',118,6,'#','','',1,0,'F','0','0','system:ossConfig:edit','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(1623,'配置删除',118,6,'#','','',1,0,'F','0','0','system:ossConfig:remove','#',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(11616,'工作流',3,6,'workflow','','',1,0,'M','0','0','','workflow',103,1,'2026-06-06 03:02:23',1,'2026-06-06 17:06:39',''),(11618,'我的任务',0,7,'task','','',1,0,'M','0','0','','my-task',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11619,'我的待办',11618,2,'taskWaiting','workflow/task/taskWaiting','',1,1,'C','0','0','','waiting',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11620,'流程定义',11616,3,'processDefinition','workflow/processDefinition/index','',1,1,'C','0','0','workflow:definition:list','process-definition',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11621,'流程实例',11630,1,'processInstance','workflow/processInstance/index','',1,1,'C','0','0','workflow:instance:list','tree-table',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11622,'流程分类',11616,1,'category','workflow/category/index','',1,0,'C','0','0','workflow:category:list','category',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11623,'流程分类查询',11622,1,'#','','',1,0,'F','0','0','workflow:category:query','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11624,'流程分类新增',11622,2,'#','','',1,0,'F','0','0','workflow:category:add','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11625,'流程分类修改',11622,3,'#','','',1,0,'F','0','0','workflow:category:edit','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11626,'流程分类删除',11622,4,'#','','',1,0,'F','0','0','workflow:category:remove','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11627,'流程分类导出',11622,5,'#','','',1,0,'F','0','0','workflow:category:export','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11629,'我发起的',11618,1,'myDocument','workflow/task/myDocument','',1,1,'C','0','0','workflow:instance:currentList','guide',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11630,'流程监控',11616,4,'processMonitor','','',1,0,'M','0','0','','monitor',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11631,'待办任务',11630,2,'allTaskWaiting','workflow/task/allTaskWaiting','',1,1,'C','0','0','','waiting',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11632,'我的已办',11618,3,'taskFinish','workflow/task/taskFinish','',1,1,'C','0','0','','finish',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11633,'我的抄送',11618,4,'taskCopyList','workflow/task/taskCopyList','',1,1,'C','0','0','','my-copy',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11638,'请假申请',5,1,'leave','workflow/leave/index','',1,0,'C','0','0','workflow:leave:list','#',103,1,'2026-06-06 03:02:23',NULL,NULL,'请假申请菜单'),(11639,'请假申请查询',11638,1,'#','','',1,0,'F','0','0','workflow:leave:query','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11640,'请假申请新增',11638,2,'#','','',1,0,'F','0','0','workflow:leave:add','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11641,'请假申请修改',11638,3,'#','','',1,0,'F','0','0','workflow:leave:edit','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11642,'请假申请删除',11638,4,'#','','',1,0,'F','0','0','workflow:leave:remove','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11643,'请假申请导出',11638,5,'#','','',1,0,'F','0','0','workflow:leave:export','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11644,'流程定义查询',11620,1,'#','','',1,0,'F','0','0','workflow:definition:query','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11645,'流程定义新增',11620,2,'#','','',1,0,'F','0','0','workflow:definition:add','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11646,'流程定义修改',11620,3,'#','','',1,0,'F','0','0','workflow:definition:edit','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11647,'流程定义删除',11620,4,'#','','',1,0,'F','0','0','workflow:definition:remove','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11648,'流程定义导出',11620,5,'#','','',1,0,'F','0','0','workflow:definition:export','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11649,'流程定义导入',11620,6,'#','','',1,0,'F','0','0','workflow:definition:import','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11650,'流程定义发布/取消发布',11620,7,'#','','',1,0,'F','0','0','workflow:definition:publish','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11651,'流程定义复制',11620,8,'#','','',1,0,'F','0','0','workflow:definition:copy','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11652,'流程定义激活/挂起',11620,9,'#','','',1,0,'F','0','0','workflow:definition:active','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11653,'流程实例查询',11621,1,'#','','',1,0,'F','0','0','workflow:instance:query','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11654,'流程变量查询',11621,2,'#','','',1,0,'F','0','0','workflow:instance:variableQuery','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11655,'流程变量修改',11621,3,'#','','',1,0,'F','0','0','workflow:instance:variable','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11656,'流程实例激活/挂起',11621,4,'#','','',1,0,'F','0','0','workflow:instance:active','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11657,'流程实例删除',11621,5,'#','','',1,0,'F','0','0','workflow:instance:remove','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11658,'流程实例作废',11621,6,'#','','',1,0,'F','0','0','workflow:instance:invalid','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11659,'流程实例撤销',11621,7,'#','','',1,0,'F','0','0','workflow:instance:cancel','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11700,'流程设计',11616,5,'design/index','workflow/processDefinition/design','',1,1,'C','1','0','workflow:leave:edit','#',103,1,'2026-06-06 03:02:23',NULL,NULL,'/workflow/processDefinition'),(11701,'请假申请',11616,6,'leaveEdit/index','workflow/leave/leaveEdit','',1,1,'C','1','0','workflow:leave:edit','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11801,'流程表达式',11616,2,'spel','workflow/spel/index','',1,0,'C','0','0','workflow:spel:list','input',103,1,'2026-06-06 03:02:23',1,'2026-06-06 03:02:23','流程达式定义菜单'),(11802,'流程达式定义查询',11801,1,'#','',NULL,1,0,'F','0','0','workflow:spel:query','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11803,'流程达式定义新增',11801,2,'#','',NULL,1,0,'F','0','0','workflow:spel:add','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11804,'流程达式定义修改',11801,3,'#','',NULL,1,0,'F','0','0','workflow:spel:edit','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11805,'流程达式定义删除',11801,4,'#','',NULL,1,0,'F','0','0','workflow:spel:remove','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(11806,'流程达式定义导出',11801,5,'#','',NULL,1,0,'F','0','0','workflow:spel:export','#',103,1,'2026-06-06 03:02:23',NULL,NULL,''),(50000,'CPQ管理',0,99,'',NULL,NULL,1,0,'M','0','0',NULL,'configure',103,1,'2026-06-06 10:15:26',NULL,NULL,'CPQ配置定价报价管理'),(50010,'首页工作台',50000,1,'/cpq/dashboard',NULL,NULL,1,0,'M','0','0',NULL,'home',103,1,'2026-06-06 10:15:26',NULL,NULL,'CPQ首页工作台'),(50020,'配置报价',50000,2,'/cpq/configure',NULL,NULL,1,1,'M','0','0',NULL,'setting',103,1,'2026-06-06 10:15:26',NULL,NULL,'CPQ配置报价'),(50021,'产品搜索',50020,1,'search','configure/ProductSearch',NULL,1,0,'C','0','0','cpq:configure:search','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50022,'新建标准配置',50020,2,'standard','configure/Configurator',NULL,1,0,'C','0','0','cpq:configure:standard','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50023,'向导式配置',50020,3,'guided','configure/GuidedSelling',NULL,1,0,'C','0','0','cpq:configure:guided','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50024,'ATO定制配置',50020,4,'ato','configure/AtoCustomize',NULL,1,0,'C','0','0','cpq:configure:ato','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50030,'报价管理',50000,3,'/cpq/quoting',NULL,NULL,1,1,'M','0','0',NULL,'documentation',103,1,'2026-06-06 10:15:26',NULL,NULL,'CPQ报价管理'),(50031,'报价单列表',50030,1,'list','quoting/QuoteList',NULL,1,0,'C','0','0','cpq:quoting:view','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50032,'新建报价',50030,2,'create','quoting/QuoteCreate',NULL,1,0,'C','0','0','cpq:quoting:create','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50033,'报价模板',50030,3,'templates','quoting/TemplateManager',NULL,1,0,'C','0','0','cpq:quoting:template','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50040,'方案管理',50000,4,'/cpq/solution',NULL,NULL,1,1,'M','0','0',NULL,'edit',103,1,'2026-06-06 10:15:26',NULL,NULL,'CPQ方案管理'),(50041,'方案列表',50040,1,'list','solution/SolutionList',NULL,1,0,'C','0','0','cpq:solution:create','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50042,'方案对比',50040,2,'compare','solution/SolutionCompare',NULL,1,0,'C','0','0','cpq:solution:compare','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50050,'审批中心',50000,5,'/cpq/approval',NULL,NULL,1,0,'M','0','0',NULL,'check',103,1,'2026-06-06 10:15:26',NULL,NULL,'CPQ审批中心'),(50051,'待我审批',50050,1,'pending','approval/PendingApproval',NULL,1,0,'C','0','0','cpq:approval:action','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50052,'我已审批',50050,2,'processed','approval/ApprovalHistory',NULL,1,0,'C','0','0','cpq:approval:action','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50053,'我发起的',50050,3,'initiated','approval/MyInitiated',NULL,1,0,'C','0','0','cpq:approval:submit','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50054,'效率看板',50050,4,'analytics','approval/ApprovalAnalytics',NULL,1,0,'C','0','0','cpq:approval:action','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50060,'售前协同',50000,6,'/cpq/presales',NULL,NULL,1,0,'M','0','0',NULL,'connection',103,1,'2026-06-06 10:15:26',NULL,NULL,'CPQ售前协同'),(50061,'任务看板',50060,1,'board','presales/TaskBoard',NULL,1,0,'C','0','0','cpq:solution:create','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50062,'评审工作台',50060,2,'review','presales/ReviewWorkbench',NULL,1,0,'C','0','0','cpq:solution:review','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50070,'竞品对标',50000,7,'/cpq/competitive',NULL,NULL,1,0,'M','0','0',NULL,'switch',103,1,'2026-06-06 10:15:26',NULL,NULL,'CPQ竞品对标'),(50071,'竞品库',50070,1,'library','competitive/CompetitorList',NULL,1,0,'C','0','0','cpq:competitive:view','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50072,'对比分析',50070,2,'compare','competitive/ComparisonView',NULL,1,0,'C','0','0','cpq:competitive:view','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50080,'产品管理',50000,8,'/cpq/product',NULL,NULL,1,1,'M','0','0',NULL,'component',103,1,'2026-06-06 10:15:26',NULL,NULL,'CPQ产品管理'),(50081,'产品目录',50080,1,'catalog','cpq/catalog',NULL,1,0,'C','0','0','cpq:product:catalog','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50082,'产品模型',50080,2,'model','cpq/model',NULL,1,0,'C','0','0','cpq:product:bom','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50083,'配置规则',50080,3,'rules','product/ConfigRuleManager',NULL,1,0,'C','0','0','cpq:product:rule','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50084,'替代品管理',50080,4,'supersession','cpq/supersession',NULL,1,0,'C','0','0','cpq:product:catalog','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50085,'产品分类管理',50080,5,'category','cpq/category',NULL,1,0,'C','0','0','cpq:product:category','#',103,1,'2026-06-06 21:46:35',1,'2026-06-06 21:46:35','产品分类层级树管理(L1产品线/L2产品族/L3产品系列)'),(50090,'定价管理',50000,9,'/cpq/pricing',NULL,NULL,1,0,'M','0','0',NULL,'money',103,1,'2026-06-06 10:15:26',NULL,NULL,'CPQ定价管理'),(50091,'价格手册',50090,1,'books','pricing/PriceBookList',NULL,1,0,'C','0','0','cpq:pricing:view','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50092,'定价规则',50090,2,'rules','pricing/PriceRuleConfig',NULL,1,0,'C','0','0','cpq:pricing:edit','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50093,'阶梯定价',50090,3,'volume','pricing/VolumeTierConfig',NULL,1,0,'C','0','0','cpq:pricing:edit','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50094,'折扣审批',50090,4,'discount','pricing/DiscountApproval',NULL,1,0,'C','0','0','cpq:pricing:edit','#',103,1,'2026-06-07 11:46:06',NULL,NULL,''),(50095,'汇率配置',50090,5,'currency','pricing/CurrencyConfig',NULL,1,0,'C','0','0','cpq:pricing:edit','#',103,1,'2026-06-07 11:46:06',NULL,NULL,''),(50100,'交期查询',50000,10,'/cpq/atpctp',NULL,NULL,1,0,'M','0','0',NULL,'time-range',103,1,'2026-06-06 10:15:26',NULL,NULL,'CPQ交期查询'),(50101,'交期检查',50100,1,'check','atpctp/AtpCheck',NULL,1,0,'C','0','0','cpq:atp:check','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50102,'批量查询',50100,2,'batch','atpctp/AtpBatch',NULL,1,0,'C','0','0','cpq:atp:check','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50103,'SLA看板',50100,3,'sla','atpctp/SlaDashboard',NULL,1,0,'C','0','0','cpq:atp:ctp','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50110,'知识库',50000,11,'/cpq/knowledge',NULL,NULL,1,0,'M','0','0',NULL,'education',103,1,'2026-06-06 10:15:26',NULL,NULL,'CPQ知识库'),(50111,'产品知识',50110,1,'products','knowledge/ProductKnowledge',NULL,1,0,'C','0','0','cpq:knowledge:view','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50112,'销售话术',50110,2,'scripts','knowledge/SalesScripts',NULL,1,0,'C','0','0','cpq:knowledge:view','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50113,'成功案例',50110,3,'cases','knowledge/CaseLibrary',NULL,1,0,'C','0','0','cpq:knowledge:view','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50114,'培训认证',50110,4,'training','knowledge/TrainingCenter',NULL,1,0,'C','0','0','cpq:knowledge:edit','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50120,'系统集成',50000,12,'/cpq/integration',NULL,NULL,1,0,'M','0','0',NULL,'link',103,1,'2026-06-06 10:15:26',NULL,NULL,'CPQ系统集成'),(50121,'CRM连接器',50120,1,'crm','integration/CrmConnector',NULL,1,0,'C','0','0','cpq:integration:config','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50122,'ERP连接器',50120,2,'erp','integration/ErpConnector',NULL,1,0,'C','0','0','cpq:integration:config','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50123,'PLM连接器',50120,3,'plm','integration/PlmConnector',NULL,1,0,'C','0','0','cpq:integration:config','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50124,'同步日志',50120,4,'logs','integration/SyncLogViewer',NULL,1,0,'C','0','0','cpq:integration:config','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50130,'系统设置',50000,13,'/cpq/settings',NULL,NULL,1,0,'M','0','0',NULL,'system',103,1,'2026-06-06 10:15:26',NULL,NULL,'CPQ系统设置'),(50131,'租户配置',50130,1,'tenant','settings/TenantConfig',NULL,1,0,'C','0','0','cpq:admin:tenant','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50132,'用户管理',50130,2,'users','settings/UserManagement',NULL,1,0,'C','0','0','cpq:admin:user','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50133,'角色管理',50130,3,'roles','settings/RoleManagement',NULL,1,0,'C','0','0','cpq:admin:user','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50134,'ABAC策略',50130,4,'abac','settings/AbacPolicyConfig',NULL,1,0,'C','0','0','cpq:admin:abac','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50135,'审计日志',50130,5,'audit','settings/AuditLogViewer',NULL,1,0,'C','0','0','cpq:admin:audit','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50136,'数据迁移',50130,6,'migration','settings/DataMigration',NULL,1,0,'C','0','0','cpq:admin:migration','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50137,'变更管理',50130,7,'ecn','settings/ChangeManagement',NULL,1,0,'C','0','0','cpq:admin:ecn','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50138,'系统参数',50130,8,'params','settings/SystemParams',NULL,1,0,'C','0','0','cpq:admin:tenant','#',103,1,'2026-06-06 10:15:26',NULL,NULL,''),(50140,'个人中心',50000,14,'/cpq/profile',NULL,NULL,1,0,'M','0','0',NULL,'user',103,1,'2026-06-06 10:15:26',NULL,NULL,'CPQ个人中心'),(50141,'配置规则',50000,7,'config','',NULL,1,0,'C','0','0','cpq:config:rule:list','setting',NULL,1,'2026-06-07 23:49:38',NULL,NULL,''),(50142,'捆绑包',50000,8,'bundle','',NULL,1,0,'C','0','0','cpq:bundle:list','box',NULL,1,'2026-06-07 23:49:38',NULL,NULL,'');
UNLOCK TABLES;
LOCK TABLES `sys_dept` WRITE;
INSERT INTO `sys_dept` (`dept_id`, `tenant_id`, `parent_id`, `ancestors`, `dept_name`, `dept_category`, `order_num`, `leader`, `phone`, `email`, `status`, `del_flag`, `create_dept`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES (100,'000000',0,'0','XXX科技',NULL,0,NULL,'15888888888','xxx@qq.com','0','0',103,1,'2026-06-06 03:02:21',NULL,NULL),(101,'000000',100,'0,100','深圳总公司',NULL,1,NULL,'15888888888','xxx@qq.com','0','0',103,1,'2026-06-06 03:02:21',NULL,NULL),(102,'000000',100,'0,100','长沙分公司',NULL,2,NULL,'15888888888','xxx@qq.com','0','0',103,1,'2026-06-06 03:02:21',NULL,NULL),(103,'000000',101,'0,100,101','研发部门',NULL,1,1,'15888888888','xxx@qq.com','0','0',103,1,'2026-06-06 03:02:21',NULL,NULL),(104,'000000',101,'0,100,101','市场部门',NULL,2,NULL,'15888888888','xxx@qq.com','0','0',103,1,'2026-06-06 03:02:21',NULL,NULL),(105,'000000',101,'0,100,101','测试部门',NULL,3,NULL,'15888888888','xxx@qq.com','0','0',103,1,'2026-06-06 03:02:21',NULL,NULL),(106,'000000',101,'0,100,101','财务部门',NULL,4,NULL,'15888888888','xxx@qq.com','0','0',103,1,'2026-06-06 03:02:21',NULL,NULL),(107,'000000',101,'0,100,101','运维部门',NULL,5,NULL,'15888888888','xxx@qq.com','0','0',103,1,'2026-06-06 03:02:21',NULL,NULL),(108,'000000',102,'0,100,102','市场部门',NULL,1,NULL,'15888888888','xxx@qq.com','0','0',103,1,'2026-06-06 03:02:21',NULL,NULL),(109,'000000',102,'0,100,102','财务部门',NULL,2,NULL,'15888888888','xxx@qq.com','0','0',103,1,'2026-06-06 03:02:21',NULL,NULL);
UNLOCK TABLES;
LOCK TABLES `sys_user` WRITE;
INSERT INTO `sys_user` (`user_id`, `tenant_id`, `dept_id`, `user_name`, `nick_name`, `user_type`, `email`, `phonenumber`, `sex`, `avatar`, `password`, `status`, `del_flag`, `login_ip`, `login_date`, `create_dept`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (1,'000000',103,'admin','疯狂的狮子Li','sys_user','crazyLionLi@163.com','15888888888','1',NULL,'$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2','0','0','0:0:0:0:0:0:0:1','2026-07-01 20:41:47',103,1,'2026-06-06 03:02:21',-1,'2026-07-01 20:41:47','管理员'),(3,'000000',108,'test','本部门及以下 密码666666','sys_user','','','0',NULL,'$2a$10$b8yUzN0C71sbz.PhNOCgJe.Tu1yWC3RNrTyjSQ8p1W0.aaUXUJ.Ne','0','0','127.0.0.1','2026-06-06 03:02:21',103,1,'2026-06-06 03:02:21',3,'2026-06-06 03:02:21',NULL),(4,'000000',102,'test1','仅本人 密码666666','sys_user','','','0',NULL,'$2a$10$b8yUzN0C71sbz.PhNOCgJe.Tu1yWC3RNrTyjSQ8p1W0.aaUXUJ.Ne','0','0','127.0.0.1','2026-06-06 03:02:21',103,1,'2026-06-06 03:02:21',4,'2026-06-06 03:02:21',NULL);
UNLOCK TABLES;
LOCK TABLES `sys_role` WRITE;
INSERT INTO `sys_role` (`role_id`, `tenant_id`, `role_name`, `role_key`, `role_sort`, `data_scope`, `menu_check_strictly`, `dept_check_strictly`, `status`, `del_flag`, `create_dept`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (1,'000000','超级管理员','superadmin',1,'1',1,1,'0','0',103,1,'2026-06-06 03:02:21',NULL,NULL,'超级管理员'),(3,'000000','本部门及以下','test1',3,'4',1,1,'0','0',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(4,'000000','仅本人','test2',4,'5',1,1,'0','0',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(100,'000000','销售代表','cpq_sales',1,'5',1,1,'0','0',103,1,'2026-06-06 10:17:06',NULL,NULL,'CPQ一线销售'),(101,'000000','售前工程师','cpq_presales',2,'5',1,1,'0','0',103,1,'2026-06-06 10:17:06',NULL,NULL,'CPQ技术方案与售前支持'),(102,'000000','销售经理','cpq_sales_mgr',3,'3',1,1,'0','0',103,1,'2026-06-06 10:17:06',NULL,NULL,'CPQ销售团队管理'),(103,'000000','渠道合作伙伴','cpq_partner',4,'5',1,1,'0','0',103,1,'2026-06-06 10:17:06',NULL,NULL,'CPQ经销商/代理商'),(104,'000000','产品经理','cpq_product_mgr',5,'1',1,1,'0','0',103,1,'2026-06-06 10:17:06',NULL,NULL,'CPQ产品目录与BOM管理'),(105,'000000','定价管理员','cpq_pricing_mgr',6,'1',1,1,'0','0',103,1,'2026-06-06 10:17:06',NULL,NULL,'CPQ价格手册与定价规则'),(106,'000000','供应链计划员','cpq_supply_chain',7,'1',1,1,'0','0',103,1,'2026-06-06 10:17:06',NULL,NULL,'CPQ产能/物料/交期管理'),(107,'000000','审批人','cpq_approver',8,'1',1,1,'0','0',103,1,'2026-06-06 10:17:06',NULL,NULL,'CPQ报价审批'),(108,'000000','销售运营','cpq_operations',9,'1',1,1,'0','0',103,1,'2026-06-06 10:17:06',NULL,NULL,'CPQ培训/赋能/模板管理'),(109,'000000','高层管理者','cpq_executive',10,'1',1,1,'0','0',103,1,'2026-06-06 10:17:06',NULL,NULL,'CPQ全局视图与洞察'),(110,'000000','外部审计','cpq_auditor',11,'1',1,1,'0','0',103,1,'2026-06-06 10:17:06',NULL,NULL,'CPQ审计日志查看(只读)'),(111,'000000','系统管理员','cpq_admin',12,'1',1,1,'0','0',103,1,'2026-06-06 10:17:06',NULL,NULL,'CPQ系统配置与运维');
UNLOCK TABLES;
LOCK TABLES `sys_post` WRITE;
INSERT INTO `sys_post` (`post_id`, `tenant_id`, `dept_id`, `post_code`, `post_category`, `post_name`, `post_sort`, `status`, `create_dept`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (1,'000000',103,'ceo',NULL,'董事长',1,'0',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(2,'000000',100,'se',NULL,'项目经理',2,'0',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(3,'000000',100,'hr',NULL,'人力资源',3,'0',103,1,'2026-06-06 03:02:21',NULL,NULL,''),(4,'000000',100,'user',NULL,'普通员工',4,'0',103,1,'2026-06-06 03:02:21',NULL,NULL,'');
UNLOCK TABLES;
LOCK TABLES `sys_dict_data` WRITE;
INSERT INTO `sys_dict_data` (`dict_code`, `tenant_id`, `dict_sort`, `dict_label`, `dict_value`, `dict_type`, `css_class`, `list_class`, `is_default`, `create_dept`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (1,'000000',1,'男','0','sys_user_sex','','','Y',103,1,'2026-06-06 03:02:22',NULL,NULL,'性别男'),(2,'000000',2,'女','1','sys_user_sex','','','N',103,1,'2026-06-06 03:02:22',NULL,NULL,'性别女'),(3,'000000',3,'未知','2','sys_user_sex','','','N',103,1,'2026-06-06 03:02:22',NULL,NULL,'性别未知'),(4,'000000',1,'显示','0','sys_show_hide','','primary','Y',103,1,'2026-06-06 03:02:22',NULL,NULL,'显示菜单'),(5,'000000',2,'隐藏','1','sys_show_hide','','danger','N',103,1,'2026-06-06 03:02:22',NULL,NULL,'隐藏菜单'),(6,'000000',1,'正常','0','sys_normal_disable','','primary','Y',103,1,'2026-06-06 03:02:22',NULL,NULL,'正常状态'),(7,'000000',2,'停用','1','sys_normal_disable','','danger','N',103,1,'2026-06-06 03:02:22',NULL,NULL,'停用状态'),(12,'000000',1,'是','Y','sys_yes_no','','primary','Y',103,1,'2026-06-06 03:02:22',NULL,NULL,'系统默认是'),(13,'000000',2,'否','N','sys_yes_no','','danger','N',103,1,'2026-06-06 03:02:22',NULL,NULL,'系统默认否'),(14,'000000',1,'通知','1','sys_notice_type','','warning','Y',103,1,'2026-06-06 03:02:22',NULL,NULL,'通知'),(15,'000000',2,'公告','2','sys_notice_type','','success','N',103,1,'2026-06-06 03:02:22',NULL,NULL,'公告'),(16,'000000',1,'正常','0','sys_notice_status','','primary','Y',103,1,'2026-06-06 03:02:22',NULL,NULL,'正常状态'),(17,'000000',2,'关闭','1','sys_notice_status','','danger','N',103,1,'2026-06-06 03:02:22',NULL,NULL,'关闭状态'),(18,'000000',1,'新增','1','sys_oper_type','','info','N',103,1,'2026-06-06 03:02:22',NULL,NULL,'新增操作'),(19,'000000',2,'修改','2','sys_oper_type','','info','N',103,1,'2026-06-06 03:02:22',NULL,NULL,'修改操作'),(20,'000000',3,'删除','3','sys_oper_type','','danger','N',103,1,'2026-06-06 03:02:22',NULL,NULL,'删除操作'),(21,'000000',4,'授权','4','sys_oper_type','','primary','N',103,1,'2026-06-06 03:02:22',NULL,NULL,'授权操作'),(22,'000000',5,'导出','5','sys_oper_type','','warning','N',103,1,'2026-06-06 03:02:22',NULL,NULL,'导出操作'),(23,'000000',6,'导入','6','sys_oper_type','','warning','N',103,1,'2026-06-06 03:02:22',NULL,NULL,'导入操作'),(24,'000000',7,'强退','7','sys_oper_type','','danger','N',103,1,'2026-06-06 03:02:22',NULL,NULL,'强退操作'),(25,'000000',8,'生成代码','8','sys_oper_type','','warning','N',103,1,'2026-06-06 03:02:22',NULL,NULL,'生成操作'),(26,'000000',9,'清空数据','9','sys_oper_type','','danger','N',103,1,'2026-06-06 03:02:22',NULL,NULL,'清空操作'),(27,'000000',1,'成功','0','sys_common_status','','primary','N',103,1,'2026-06-06 03:02:22',NULL,NULL,'正常状态'),(28,'000000',2,'失败','1','sys_common_status','','danger','N',103,1,'2026-06-06 03:02:22',NULL,NULL,'停用状态'),(29,'000000',99,'其他','0','sys_oper_type','','info','N',103,1,'2026-06-06 03:02:22',NULL,NULL,'其他操作'),(30,'000000',0,'密码认证','password','sys_grant_type','el-check-tag','default','N',103,1,'2026-06-06 03:02:22',NULL,NULL,'密码认证'),(31,'000000',0,'短信认证','sms','sys_grant_type','el-check-tag','default','N',103,1,'2026-06-06 03:02:22',NULL,NULL,'短信认证'),(32,'000000',0,'邮件认证','email','sys_grant_type','el-check-tag','default','N',103,1,'2026-06-06 03:02:22',NULL,NULL,'邮件认证'),(33,'000000',0,'小程序认证','xcx','sys_grant_type','el-check-tag','default','N',103,1,'2026-06-06 03:02:22',NULL,NULL,'小程序认证'),(34,'000000',0,'三方登录认证','social','sys_grant_type','el-check-tag','default','N',103,1,'2026-06-06 03:02:22',NULL,NULL,'三方登录认证'),(35,'000000',0,'PC','pc','sys_device_type','','default','N',103,1,'2026-06-06 03:02:22',NULL,NULL,'PC'),(36,'000000',0,'安卓','android','sys_device_type','','default','N',103,1,'2026-06-06 03:02:22',NULL,NULL,'安卓'),(37,'000000',0,'iOS','ios','sys_device_type','','default','N',103,1,'2026-06-06 03:02:22',NULL,NULL,'iOS'),(38,'000000',0,'小程序','xcx','sys_device_type','','default','N',103,1,'2026-06-06 03:02:22',NULL,NULL,'小程序'),(39,'000000',1,'已撤销','cancel','wf_business_status','','danger','N',103,1,'2026-06-06 03:02:23',NULL,NULL,'已撤销'),(40,'000000',2,'草稿','draft','wf_business_status','','info','N',103,1,'2026-06-06 03:02:23',NULL,NULL,'草稿'),(41,'000000',3,'待审核','waiting','wf_business_status','','primary','N',103,1,'2026-06-06 03:02:23',NULL,NULL,'待审核'),(42,'000000',4,'已完成','finish','wf_business_status','','success','N',103,1,'2026-06-06 03:02:23',NULL,NULL,'已完成'),(43,'000000',5,'已作废','invalid','wf_business_status','','danger','N',103,1,'2026-06-06 03:02:23',NULL,NULL,'已作废'),(44,'000000',6,'已退回','back','wf_business_status','','danger','N',103,1,'2026-06-06 03:02:23',NULL,NULL,'已退回'),(45,'000000',7,'已终止','termination','wf_business_status','','danger','N',103,1,'2026-06-06 03:02:23',NULL,NULL,'已终止'),(46,'000000',1,'自定义表单','static','wf_form_type','','success','N',103,1,'2026-06-06 03:02:23',NULL,NULL,'自定义表单'),(47,'000000',2,'动态表单','dynamic','wf_form_type','','primary','N',103,1,'2026-06-06 03:02:23',NULL,NULL,'动态表单'),(48,'000000',1,'撤销','cancel','wf_task_status','','danger','N',103,1,'2026-06-06 03:02:23',NULL,NULL,'撤销'),(49,'000000',2,'通过','pass','wf_task_status','','success','N',103,1,'2026-06-06 03:02:23',NULL,NULL,'通过'),(50,'000000',3,'待审核','waiting','wf_task_status','','primary','N',103,1,'2026-06-06 03:02:23',NULL,NULL,'待审核'),(51,'000000',4,'作废','invalid','wf_task_status','','danger','N',103,1,'2026-06-06 03:02:23',NULL,NULL,'作废'),(52,'000000',5,'退回','back','wf_task_status','','danger','N',103,1,'2026-06-06 03:02:23',NULL,NULL,'退回'),(53,'000000',6,'终止','termination','wf_task_status','','danger','N',103,1,'2026-06-06 03:02:23',NULL,NULL,'终止'),(54,'000000',7,'转办','transfer','wf_task_status','','primary','N',103,1,'2026-06-06 03:02:23',NULL,NULL,'转办'),(55,'000000',8,'委托','depute','wf_task_status','','primary','N',103,1,'2026-06-06 03:02:23',NULL,NULL,'委托'),(56,'000000',9,'抄送','copy','wf_task_status','','primary','N',103,1,'2026-06-06 03:02:23',NULL,NULL,'抄送'),(57,'000000',10,'加签','sign','wf_task_status','','primary','N',103,1,'2026-06-06 03:02:23',NULL,NULL,'加签'),(58,'000000',11,'减签','sign_off','wf_task_status','','danger','N',103,1,'2026-06-06 03:02:23',NULL,NULL,'减签'),(59,'000000',11,'超时','timeout','wf_task_status','','danger','N',103,1,'2026-06-06 03:02:23',NULL,NULL,'超时');
UNLOCK TABLES;
LOCK TABLES `sys_dict_type` WRITE;
INSERT INTO `sys_dict_type` (`dict_id`, `tenant_id`, `dict_name`, `dict_type`, `create_dept`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (1,'000000','用户性别','sys_user_sex',103,1,'2026-06-06 03:02:22',NULL,NULL,'用户性别列表'),(2,'000000','菜单状态','sys_show_hide',103,1,'2026-06-06 03:02:22',NULL,NULL,'菜单状态列表'),(3,'000000','系统开关','sys_normal_disable',103,1,'2026-06-06 03:02:22',NULL,NULL,'系统开关列表'),(6,'000000','系统是否','sys_yes_no',103,1,'2026-06-06 03:02:22',NULL,NULL,'系统是否列表'),(7,'000000','通知类型','sys_notice_type',103,1,'2026-06-06 03:02:22',NULL,NULL,'通知类型列表'),(8,'000000','通知状态','sys_notice_status',103,1,'2026-06-06 03:02:22',NULL,NULL,'通知状态列表'),(9,'000000','操作类型','sys_oper_type',103,1,'2026-06-06 03:02:22',NULL,NULL,'操作类型列表'),(10,'000000','系统状态','sys_common_status',103,1,'2026-06-06 03:02:22',NULL,NULL,'登录状态列表'),(11,'000000','授权类型','sys_grant_type',103,1,'2026-06-06 03:02:22',NULL,NULL,'认证授权类型'),(12,'000000','设备类型','sys_device_type',103,1,'2026-06-06 03:02:22',NULL,NULL,'客户端设备类型'),(13,'000000','业务状态','wf_business_status',103,1,'2026-06-06 03:02:23',NULL,NULL,'业务状态列表'),(14,'000000','表单类型','wf_form_type',103,1,'2026-06-06 03:02:23',NULL,NULL,'表单类型列表'),(15,'000000','任务状态','wf_task_status',103,1,'2026-06-06 03:02:23',NULL,NULL,'任务状态');
UNLOCK TABLES;
LOCK TABLES `sys_config` WRITE;
INSERT INTO `sys_config` (`config_id`, `tenant_id`, `config_name`, `config_key`, `config_value`, `config_type`, `create_dept`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (1,'000000','主框架页-默认皮肤样式名称','sys.index.skinName','skin-blue','Y',103,1,'2026-06-06 03:02:22',NULL,NULL,'蓝色 skin-blue、绿色 skin-green、紫色 skin-purple、红色 skin-red、黄色 skin-yellow'),(2,'000000','用户管理-账号初始密码','sys.user.initPassword','123456','Y',103,1,'2026-06-06 03:02:22',NULL,NULL,'初始化密码 123456'),(3,'000000','主框架页-侧边栏主题','sys.index.sideTheme','theme-dark','Y',103,1,'2026-06-06 03:02:22',NULL,NULL,'深色主题theme-dark，浅色主题theme-light'),(5,'000000','账号自助-是否开启用户注册功能','sys.account.registerUser','false','Y',103,1,'2026-06-06 03:02:22',NULL,NULL,'是否开启注册用户功能（true开启，false关闭）'),(11,'000000','OSS预览列表资源开关','sys.oss.previewListResource','true','Y',103,1,'2026-06-06 03:02:22',NULL,NULL,'true:开启, false:关闭');
UNLOCK TABLES;
LOCK TABLES `sys_oss_config` WRITE;
INSERT INTO `sys_oss_config` (`oss_config_id`, `tenant_id`, `config_key`, `access_key`, `secret_key`, `bucket_name`, `prefix`, `endpoint`, `domain`, `is_https`, `region`, `access_policy`, `status`, `ext1`, `create_dept`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (1,'000000','minio','ruoyi','ruoyi123','ruoyi','','127.0.0.1:9000','','N','','1','0','',103,1,'2026-06-06 03:02:22',1,'2026-06-06 03:02:22',NULL),(2,'000000','qiniu','XXXXXXXXXXXXXXX','XXXXXXXXXXXXXXX','ruoyi','','s3-cn-north-1.qiniucs.com','','N','','1','1','',103,1,'2026-06-06 03:02:22',1,'2026-06-06 03:02:22',NULL),(3,'000000','aliyun','XXXXXXXXXXXXXXX','XXXXXXXXXXXXXXX','ruoyi','','oss-cn-beijing.aliyuncs.com','','N','','1','1','',103,1,'2026-06-06 03:02:22',1,'2026-06-06 03:02:22',NULL),(4,'000000','qcloud','XXXXXXXXXXXXXXX','XXXXXXXXXXXXXXX','ruoyi-1240000000','','cos.ap-beijing.myqcloud.com','','N','ap-beijing','1','1','',103,1,'2026-06-06 03:02:22',1,'2026-06-06 03:02:22',NULL),(5,'000000','image','ruoyi','ruoyi123','ruoyi','image','127.0.0.1:9000','','N','','1','1','',103,1,'2026-06-06 03:02:22',1,'2026-06-06 03:02:22',NULL);
UNLOCK TABLES;
LOCK TABLES `sys_client` WRITE;
INSERT INTO `sys_client` (`id`, `client_id`, `client_key`, `client_secret`, `grant_type`, `device_type`, `active_timeout`, `timeout`, `status`, `del_flag`, `create_dept`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES (1,'e5cd7e4891bf95d1d19206ce24a7b32e','pc','pc123','password,social','pc',1800,604800,'0','0',103,1,'2026-06-06 03:02:22',1,'2026-06-06 03:02:22'),(2,'428a8310cd442757ae699df5d894f051','app','app123','password,sms,social','android',1800,604800,'0','0',103,1,'2026-06-06 03:02:22',1,'2026-06-06 03:02:22'),(10,'eureka','123456','123456','password,social','pc',1800,604800,'0','0',NULL,NULL,NULL,NULL,NULL);
UNLOCK TABLES;
LOCK TABLES `sys_tenant` WRITE;
INSERT INTO `sys_tenant` (`id`, `tenant_id`, `contact_user_name`, `contact_phone`, `company_name`, `license_number`, `address`, `intro`, `domain`, `remark`, `package_id`, `expire_time`, `account_count`, `status`, `del_flag`, `create_dept`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES (1,'000000','管理组','15888888888','XXX有限公司',NULL,NULL,'多租户通用后台管理管理系统',NULL,NULL,NULL,NULL,-1,'0','0',103,1,'2026-06-06 03:02:21',NULL,NULL);
UNLOCK TABLES;
LOCK TABLES `sys_tenant_package` WRITE;
UNLOCK TABLES;
LOCK TABLES `sys_social` WRITE;
UNLOCK TABLES;
LOCK TABLES `sys_user_role` WRITE;
INSERT INTO `sys_user_role` (`user_id`, `role_id`) VALUES (1,1),(3,3),(4,4);
UNLOCK TABLES;
LOCK TABLES `sys_user_post` WRITE;
INSERT INTO `sys_user_post` (`user_id`, `post_id`) VALUES (1,1);
UNLOCK TABLES;
LOCK TABLES `sys_role_menu` WRITE;
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1,50000),(1,50010),(1,50020),(1,50021),(1,50022),(1,50023),(1,50024),(1,50030),(1,50031),(1,50032),(1,50033),(1,50040),(1,50041),(1,50042),(1,50050),(1,50051),(1,50052),(1,50053),(1,50054),(1,50060),(1,50061),(1,50062),(1,50070),(1,50071),(1,50072),(1,50080),(1,50081),(1,50082),(1,50083),(1,50084),(1,50090),(1,50091),(1,50092),(1,50093),(1,50100),(1,50101),(1,50102),(1,50103),(1,50110),(1,50111),(1,50112),(1,50113),(1,50114),(1,50120),(1,50121),(1,50122),(1,50123),(1,50124),(1,50130),(1,50131),(1,50132),(1,50133),(1,50134),(1,50135),(1,50136),(1,50137),(1,50138),(1,50140),(1,50141),(1,50142),(3,1),(3,100),(3,101),(3,102),(3,103),(3,104),(3,105),(3,106),(3,107),(3,108),(3,118),(3,123),(3,130),(3,131),(3,132),(3,133),(3,500),(3,501),(3,1001),(3,1002),(3,1003),(3,1004),(3,1005),(3,1006),(3,1007),(3,1008),(3,1009),(3,1010),(3,1011),(3,1012),(3,1013),(3,1014),(3,1015),(3,1016),(3,1017),(3,1018),(3,1019),(3,1020),(3,1021),(3,1022),(3,1023),(3,1024),(3,1025),(3,1026),(3,1027),(3,1028),(3,1029),(3,1030),(3,1031),(3,1032),(3,1033),(3,1034),(3,1035),(3,1036),(3,1037),(3,1038),(3,1039),(3,1040),(3,1041),(3,1042),(3,1043),(3,1044),(3,1045),(3,1050),(3,1061),(3,1062),(3,1063),(3,1064),(3,1065),(3,1600),(3,1601),(3,1602),(3,1603),(3,1620),(3,1621),(3,1622),(3,1623),(3,11616),(3,11618),(3,11619),(3,11622),(3,11623),(3,11629),(3,11632),(3,11633),(3,11638),(3,11639),(3,11640),(3,11641),(3,11642),(3,11643),(3,11701),(100,50000),(100,50010),(100,50020),(100,50021),(100,50022),(100,50023),(100,50024),(100,50030),(100,50031),(100,50032),(100,50033),(100,50050),(100,50051),(100,50053),(100,50060),(100,50061),(100,50100),(100,50101),(100,50102),(100,50110),(100,50111),(100,50112),(100,50113),(100,50140),(101,50000),(101,50010),(101,50020),(101,50021),(101,50022),(101,50023),(101,50024),(101,50030),(101,50031),(101,50032),(101,50033),(101,50040),(101,50041),(101,50042),(101,50050),(101,50051),(101,50053),(101,50060),(101,50061),(101,50062),(101,50070),(101,50071),(101,50072),(101,50100),(101,50101),(101,50102),(101,50110),(101,50111),(101,50112),(101,50113),(101,50140),(102,50000),(102,50010),(102,50020),(102,50021),(102,50022),(102,50023),(102,50024),(102,50030),(102,50031),(102,50032),(102,50033),(102,50040),(102,50041),(102,50042),(102,50050),(102,50051),(102,50053),(102,50060),(102,50061),(102,50062),(102,50070),(102,50071),(102,50072),(102,50100),(102,50101),(102,50102),(102,50110),(102,50111),(102,50112),(102,50113),(102,50140),(103,50000),(103,50010),(103,50020),(103,50021),(103,50022),(103,50030),(103,50031),(103,50032),(103,50100),(103,50101),(103,50110),(103,50111),(103,50140),(104,50000),(104,50010),(104,50040),(104,50041),(104,50050),(104,50051),(104,50070),(104,50071),(104,50072),(104,50080),(104,50081),(104,50082),(104,50083),(104,50084),(104,50085),(104,50110),(104,50111),(104,50112),(104,50140),(104,50141),(104,50142),(105,50000),(105,50010),(105,50050),(105,50051),(105,50090),(105,50091),(105,50092),(105,50093),(105,50110),(105,50111),(105,50140),(106,50000),(106,50010),(106,50050),(106,50051),(106,50080),(106,50081),(106,50082),(106,50100),(106,50101),(106,50102),(106,50103),(106,50140),(107,50000),(107,50010),(107,50050),(107,50051),(107,50052),(107,50054),(107,50140),(108,50000),(108,50010),(108,50070),(108,50071),(108,50072),(108,50110),(108,50111),(108,50112),(108,50113),(108,50114),(108,50140),(109,50000),(109,50010),(109,50050),(109,50051),(109,50070),(109,50071),(109,50072),(109,50100),(109,50101),(109,50102),(109,50103),(109,50140),(110,50000),(110,50010),(110,50130),(110,50135),(110,50140),(111,50000),(111,50010),(111,50020),(111,50021),(111,50022),(111,50023),(111,50024),(111,50030),(111,50031),(111,50032),(111,50033),(111,50040),(111,50041),(111,50042),(111,50050),(111,50051),(111,50052),(111,50053),(111,50054),(111,50060),(111,50061),(111,50062),(111,50070),(111,50071),(111,50072),(111,50080),(111,50081),(111,50082),(111,50083),(111,50084),(111,50085),(111,50090),(111,50091),(111,50092),(111,50093),(111,50100),(111,50101),(111,50102),(111,50103),(111,50110),(111,50111),(111,50112),(111,50113),(111,50114),(111,50120),(111,50121),(111,50122),(111,50123),(111,50124),(111,50130),(111,50131),(111,50132),(111,50133),(111,50134),(111,50135),(111,50136),(111,50137),(111,50138),(111,50140),(111,50141),(111,50142);
UNLOCK TABLES;
LOCK TABLES `sys_role_dept` WRITE;
UNLOCK TABLES;
LOCK TABLES `sys_notice` WRITE;
INSERT INTO `sys_notice` (`notice_id`, `tenant_id`, `notice_title`, `notice_type`, `notice_content`, `status`, `create_dept`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`) VALUES (1,'000000','温馨提醒：2018-07-01 新版本发布啦','2',_binary '新版本内容','0',103,1,'2026-06-06 03:02:22',NULL,NULL,'管理员'),(2,'000000','维护通知：2018-07-01 系统凌晨维护','1',_binary '维护内容','0',103,1,'2026-06-06 03:02:22',NULL,NULL,'管理员');
UNLOCK TABLES;
LOCK TABLES `sys_oper_log` WRITE;
INSERT INTO `sys_oper_log` (`oper_id`, `tenant_id`, `title`, `business_type`, `method`, `request_method`, `operator_type`, `oper_name`, `dept_name`, `oper_url`, `oper_ip`, `oper_location`, `oper_param`, `json_result`, `status`, `error_msg`, `oper_time`, `cost_time`) VALUES (2063180244293345281,'000000','菜单管理',2,'org.dromara.system.controller.system.SysMenuController.edit()','PUT',1,'admin','管理员部门','/system/menu','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":103,\"createBy\":null,\"createTime\":\"2026-06-06 03:02:21\",\"updateBy\":null,\"updateTime\":null,\"menuId\":6,\"parentId\":3,\"menuName\":\"租户管理\",\"orderNum\":2,\"path\":\"tenant\",\"component\":null,\"queryParam\":\"\",\"isFrame\":\"1\",\"isCache\":\"0\",\"menuType\":\"M\",\"visible\":\"0\",\"status\":\"0\",\"perms\":\"\",\"icon\":\"chart\",\"remark\":\"租户管理目录\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-06 16:44:37',37),(2063183244986507265,'000000','菜单管理',2,'org.dromara.system.controller.system.SysMenuController.edit()','PUT',1,'admin','管理员部门','/system/menu','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":103,\"createBy\":null,\"createTime\":\"2026-06-06 03:02:21\",\"updateBy\":null,\"updateTime\":null,\"menuId\":6,\"parentId\":3,\"menuName\":\"租户管理\",\"orderNum\":5,\"path\":\"tenant\",\"component\":null,\"queryParam\":\"\",\"isFrame\":\"1\",\"isCache\":\"0\",\"menuType\":\"M\",\"visible\":\"0\",\"status\":\"0\",\"perms\":\"\",\"icon\":\"chart\",\"remark\":\"租户管理目录\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-06 16:56:32',16),(2063185789695909890,'000000','菜单管理',2,'org.dromara.system.controller.system.SysMenuController.edit()','PUT',1,'admin','管理员部门','/system/menu','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":103,\"createBy\":null,\"createTime\":\"2026-06-06 03:02:23\",\"updateBy\":null,\"updateTime\":null,\"menuId\":11616,\"parentId\":3,\"menuName\":\"工作流\",\"orderNum\":6,\"path\":\"workflow\",\"component\":\"\",\"queryParam\":\"\",\"isFrame\":\"1\",\"isCache\":\"0\",\"menuType\":\"M\",\"visible\":\"0\",\"status\":\"0\",\"perms\":\"\",\"icon\":\"workflow\",\"remark\":\"\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-06 17:06:39',13),(2063187379072884737,'000000','菜单管理',2,'org.dromara.system.controller.system.SysMenuController.edit()','PUT',1,'admin','管理员部门','/system/menu','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":103,\"createBy\":null,\"createTime\":\"2026-06-06 03:02:21\",\"updateBy\":null,\"updateTime\":null,\"menuId\":2,\"parentId\":3,\"menuName\":\"系统监控\",\"orderNum\":3,\"path\":\"monitor\",\"component\":null,\"queryParam\":\"\",\"isFrame\":\"1\",\"isCache\":\"0\",\"menuType\":\"M\",\"visible\":\"0\",\"status\":\"0\",\"perms\":\"\",\"icon\":\"monitor\",\"remark\":\"系统监控目录\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-06 17:12:58',20),(2063196139333967873,'000000','CPQ产品目录',1,'org.dromara.cpq.controller.CpqProductCatalogController.add()','POST',1,'admin','管理员部门','/cpq/product/catalog','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"catalogId\":null,\"catalogName\":\"可销售产品主目录\",\"catalogType\":\"SALES\",\"effectiveDate\":\"2026-06-01 00:00:00\",\"expiryDate\":\"2029-12-31 00:00:00\",\"status\":\"0\"}','',1,'cannot find converter from CpqProductCatalogBo to CpqProductCatalog','2026-06-06 17:47:47',57),(2063196143998033922,'000000','CPQ产品目录',1,'org.dromara.cpq.controller.CpqProductCatalogController.add()','POST',1,'admin','管理员部门','/cpq/product/catalog','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"catalogId\":null,\"catalogName\":\"可销售产品主目录\",\"catalogType\":\"SALES\",\"effectiveDate\":\"2026-06-01 00:00:00\",\"expiryDate\":\"2029-12-31 00:00:00\",\"status\":\"0\"}','',1,'cannot find converter from CpqProductCatalogBo to CpqProductCatalog','2026-06-06 17:47:48',8),(2063196262969466882,'000000','CPQ产品目录',1,'org.dromara.cpq.controller.CpqProductCatalogController.add()','POST',1,'admin','管理员部门','/cpq/product/catalog','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"catalogId\":null,\"catalogName\":\"可销售产品主目录\",\"catalogType\":\"SALES\",\"effectiveDate\":\"2026-06-01 00:00:00\",\"expiryDate\":\"2026-06-30 00:00:00\",\"status\":\"0\"}','',1,'cannot find converter from CpqProductCatalogBo to CpqProductCatalog','2026-06-06 17:48:16',16),(2063196327612080129,'000000','CPQ产品目录',1,'org.dromara.cpq.controller.CpqProductCatalogController.add()','POST',1,'admin','管理员部门','/cpq/product/catalog','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"catalogId\":null,\"catalogName\":\"可销售产品主目录\",\"catalogType\":\"SALES\",\"effectiveDate\":\"2026-06-01 00:00:00\",\"expiryDate\":\"2026-06-30 00:00:00\",\"status\":\"0\"}','',1,'cannot find converter from CpqProductCatalogBo to CpqProductCatalog','2026-06-06 17:48:31',10),(2063200231775100930,'000000','CPQ产品目录',1,'org.dromara.cpq.controller.CpqProductCatalogController.add()','POST',1,'admin','管理员部门','/cpq/product/catalog','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"catalogId\":null,\"catalogName\":\"测试目录123\",\"catalogType\":\"SALES\",\"effectiveDate\":null,\"expiryDate\":null,\"status\":\"0\"}','',1,'cannot find converter from CpqProductCatalogBo to CpqProductCatalog','2026-06-06 18:04:02',36),(2063201074356248578,'000000','CPQ产品目录',1,'org.dromara.cpq.controller.CpqProductCatalogController.add()','POST',1,'admin','管理员部门','/cpq/product/catalog','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"catalogId\":null,\"catalogName\":\"测试目录A\",\"catalogType\":\"SALES\",\"effectiveDate\":null,\"expiryDate\":null,\"status\":\"0\"}','',1,'cannot find converter from CpqProductCatalogBo to CpqProductCatalog','2026-06-06 18:07:23',38),(2063202356903104514,'000000','CPQ产品目录',1,'org.dromara.cpq.controller.CpqProductCatalogController.add()','POST',1,'admin','管理员部门','/cpq/product/catalog','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"catalogId\":null,\"catalogName\":\"测试目录OK\",\"catalogType\":\"SALES\",\"effectiveDate\":null,\"expiryDate\":null,\"status\":\"0\"}','',1,'cannot find converter from CpqProductCatalogBo to CpqProductCatalog','2026-06-06 18:12:29',71),(2063203566230007809,'000000','CPQ产品目录',1,'org.dromara.cpq.controller.CpqProductCatalogController.add()','POST',1,'admin','管理员部门','/cpq/product/catalog','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"catalogId\":null,\"catalogName\":\"测试目录OK2\",\"catalogType\":\"SALES\",\"effectiveDate\":null,\"expiryDate\":null,\"status\":\"0\"}','',1,'cannot find converter from CpqProductCatalogBo to CpqProductCatalog','2026-06-06 18:17:17',42),(2063204585190006786,'000000','CPQ产品目录',1,'org.dromara.cpq.controller.CpqProductCatalogController.add()','POST',1,'admin','管理员部门','/cpq/product/catalog','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"catalogId\":null,\"catalogName\":\"测试OK3\",\"catalogType\":\"SALES\",\"effectiveDate\":null,\"expiryDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-06 18:21:20',47),(2063216275134627841,'000000','CPQ产品目录',1,'org.dromara.cpq.controller.CpqProductCatalogController.add()','POST',1,'admin','管理员部门','/cpq/product/catalog','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"catalogId\":null,\"catalogName\":\"API测试目录\",\"catalogType\":\"SALES\",\"effectiveDate\":null,\"expiryDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-06 19:07:47',60),(2063216579095838721,'000000','CPQ产品目录',1,'org.dromara.cpq.controller.CpqProductCatalogController.add()','POST',1,'admin','管理员部门','/cpq/product/catalog','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"catalogId\":null,\"catalogName\":\"TestAPI\",\"catalogType\":\"SALES\",\"effectiveDate\":null,\"expiryDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-06 19:09:00',32),(2063216580186357761,'000000','CPQ产品',1,'org.dromara.cpq.controller.CpqProductModelController.add()','POST',1,'admin','管理员部门','/cpq/product/model','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"modelId\":null,\"catalogId\":1,\"productLine\":\"L1\",\"productFamily\":\"L2\",\"productSeries\":\"L3\",\"modelCode\":\"TEST01\",\"modelName\":\"Test\",\"description\":null,\"lifecycleStatus\":\"ACTIVE\",\"successorModelId\":null,\"basePrice\":null,\"currency\":null,\"minOrderQty\":null,\"leadTimeDays\":null,\"configType\":\"STANDARD\",\"defaultBomId\":null,\"thumbnailUrl\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-06 19:09:00',25),(2063216582321258498,'000000','CPQ产品',1,'org.dromara.cpq.controller.CpqProductModelController.add()','POST',1,'admin','管理员部门','/cpq/product/model','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"modelId\":null,\"catalogId\":1,\"productLine\":\"SL1\",\"productFamily\":\"SL2\",\"productSeries\":\"SL3\",\"modelCode\":\"SUPSRC1\",\"modelName\":\"SupSrc\",\"description\":null,\"lifecycleStatus\":\"EOL_ANNOUNCED\",\"successorModelId\":null,\"basePrice\":null,\"currency\":null,\"minOrderQty\":null,\"leadTimeDays\":null,\"configType\":\"STANDARD\",\"defaultBomId\":null,\"thumbnailUrl\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-06 19:09:01',49),(2063216583051067393,'000000','CPQ产品',1,'org.dromara.cpq.controller.CpqProductModelController.add()','POST',1,'admin','管理员部门','/cpq/product/model','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"modelId\":null,\"catalogId\":1,\"productLine\":\"TL1\",\"productFamily\":\"TL2\",\"productSeries\":\"TL3\",\"modelCode\":\"SUPTGT1\",\"modelName\":\"SupTgt\",\"description\":null,\"lifecycleStatus\":\"ACTIVE\",\"successorModelId\":null,\"basePrice\":null,\"currency\":null,\"minOrderQty\":null,\"leadTimeDays\":null,\"configType\":\"STANDARD\",\"defaultBomId\":null,\"thumbnailUrl\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-06 19:09:01',34),(2063216584640708609,'000000','CPQ产品替代关系',1,'org.dromara.cpq.controller.CpqProductSupersessionController.add()','POST',1,'admin','管理员部门','/cpq/product/supersession','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"supersessionId\":null,\"originalModelId\":0,\"replacementModelId\":0,\"supersessionType\":\"FULL\",\"conditionExpr\":null,\"priceImpactPct\":null,\"effectiveDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-06 19:09:01',24),(2063216585383100417,'000000','CPQ产品',3,'org.dromara.cpq.controller.CpqProductModelController.removeBatch()','DELETE',1,'admin','管理员部门','/cpq/product/model/batch','0:0:0:0:0:0:0:1','内网IP','[0,0]','{\"code\":500,\"msg\":\"操作失败\",\"data\":null}',0,'','2026-06-06 19:09:01',31),(2063217480871243778,'000000','CPQ产品目录',1,'org.dromara.cpq.controller.CpqProductCatalogController.add()','POST',1,'admin','管理员部门','/cpq/product/catalog','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"catalogId\":null,\"catalogName\":\"TestCatalog\",\"catalogType\":\"SALES\",\"effectiveDate\":null,\"expiryDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-06 19:12:35',52),(2063217482343444482,'000000','CPQ产品目录',2,'org.dromara.cpq.controller.CpqProductCatalogController.edit()','PUT',1,'admin','管理员部门','/cpq/product/catalog','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"catalogId\":0,\"catalogName\":\"UpdatedCat\",\"catalogType\":\"SALES\",\"effectiveDate\":null,\"expiryDate\":null,\"status\":\"0\"}','{\"code\":500,\"msg\":\"操作失败\",\"data\":null}',0,'','2026-06-06 19:12:35',36),(2063217482976784386,'000000','CPQ产品目录',3,'org.dromara.cpq.controller.CpqProductCatalogController.remove()','DELETE',1,'admin','管理员部门','/cpq/product/catalog/0','0:0:0:0:0:0:0:1','内网IP','0','{\"code\":500,\"msg\":\"操作失败\",\"data\":null}',0,'','2026-06-06 19:12:35',30),(2063217484411236353,'000000','CPQ产品',1,'org.dromara.cpq.controller.CpqProductModelController.add()','POST',1,'admin','管理员部门','/cpq/product/model','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"modelId\":null,\"catalogId\":1,\"productLine\":\"L1\",\"productFamily\":\"L2\",\"productSeries\":\"L3\",\"modelCode\":\"TEST01\",\"modelName\":\"TestModel\",\"description\":null,\"lifecycleStatus\":\"ACTIVE\",\"successorModelId\":null,\"basePrice\":null,\"currency\":null,\"minOrderQty\":null,\"leadTimeDays\":null,\"configType\":\"STANDARD\",\"defaultBomId\":null,\"thumbnailUrl\":null,\"status\":\"0\"}','',1,'产品编码已存在','2026-06-06 19:12:36',16),(2063217486554525698,'000000','CPQ产品',2,'org.dromara.cpq.controller.CpqProductModelController.edit()','PUT',1,'admin','管理员部门','/cpq/product/model','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"modelId\":0,\"catalogId\":1,\"productLine\":\"L1\",\"productFamily\":\"L2\",\"productSeries\":\"L3\",\"modelCode\":\"TEST01\",\"modelName\":\"UpdatedModel\",\"description\":null,\"lifecycleStatus\":\"ACTIVE\",\"successorModelId\":null,\"basePrice\":null,\"currency\":null,\"minOrderQty\":null,\"leadTimeDays\":null,\"configType\":\"STANDARD\",\"defaultBomId\":null,\"thumbnailUrl\":null,\"status\":\"0\"}','',1,'产品编码已存在','2026-06-06 19:12:36',14),(2063217487062036481,'000000','CPQ产品',3,'org.dromara.cpq.controller.CpqProductModelController.remove()','DELETE',1,'admin','管理员部门','/cpq/product/model/0','0:0:0:0:0:0:0:1','内网IP','0','{\"code\":500,\"msg\":\"操作失败\",\"data\":null}',0,'','2026-06-06 19:12:36',15),(2063217487498244097,'000000','CPQ产品',1,'org.dromara.cpq.controller.CpqProductModelController.add()','POST',1,'admin','管理员部门','/cpq/product/model','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"modelId\":null,\"catalogId\":1,\"productLine\":\"SL1\",\"productFamily\":\"SL2\",\"productSeries\":\"SL3\",\"modelCode\":\"SUPSRC\",\"modelName\":\"SrcModel\",\"description\":null,\"lifecycleStatus\":\"EOL_ANNOUNCED\",\"successorModelId\":null,\"basePrice\":null,\"currency\":null,\"minOrderQty\":null,\"leadTimeDays\":null,\"configType\":\"STANDARD\",\"defaultBomId\":null,\"thumbnailUrl\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-06 19:12:36',19),(2063217487649239041,'000000','CPQ产品',1,'org.dromara.cpq.controller.CpqProductModelController.add()','POST',1,'admin','管理员部门','/cpq/product/model','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"modelId\":null,\"catalogId\":1,\"productLine\":\"TL1\",\"productFamily\":\"TL2\",\"productSeries\":\"TL3\",\"modelCode\":\"SUPTGT\",\"modelName\":\"TgtModel\",\"description\":null,\"lifecycleStatus\":\"ACTIVE\",\"successorModelId\":null,\"basePrice\":null,\"currency\":null,\"minOrderQty\":null,\"leadTimeDays\":null,\"configType\":\"STANDARD\",\"defaultBomId\":null,\"thumbnailUrl\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-06 19:12:36',12),(2063217488689426433,'000000','CPQ产品替代关系',1,'org.dromara.cpq.controller.CpqProductSupersessionController.add()','POST',1,'admin','管理员部门','/cpq/product/supersession','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"supersessionId\":null,\"originalModelId\":0,\"replacementModelId\":0,\"supersessionType\":\"FULL\",\"conditionExpr\":null,\"priceImpactPct\":null,\"effectiveDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-06 19:12:37',11),(2063217489654116353,'000000','CPQ产品替代关系',2,'org.dromara.cpq.controller.CpqProductSupersessionController.edit()','PUT',1,'admin','管理员部门','/cpq/product/supersession','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"supersessionId\":0,\"originalModelId\":0,\"replacementModelId\":0,\"supersessionType\":\"CONDITIONAL\",\"conditionExpr\":null,\"priceImpactPct\":null,\"effectiveDate\":null,\"status\":\"0\"}','{\"code\":500,\"msg\":\"操作失败\",\"data\":null}',0,'','2026-06-06 19:12:37',13),(2063217490132267010,'000000','CPQ产品替代关系',3,'org.dromara.cpq.controller.CpqProductSupersessionController.remove()','DELETE',1,'admin','管理员部门','/cpq/product/supersession/0','0:0:0:0:0:0:0:1','内网IP','0','{\"code\":500,\"msg\":\"操作失败\",\"data\":null}',0,'','2026-06-06 19:12:37',15),(2063217490551697409,'000000','CPQ产品',3,'org.dromara.cpq.controller.CpqProductModelController.removeBatch()','DELETE',1,'admin','管理员部门','/cpq/product/model/batch','0:0:0:0:0:0:0:1','内网IP','[0,0]','{\"code\":500,\"msg\":\"操作失败\",\"data\":null}',0,'','2026-06-06 19:12:37',13),(2063218362375532545,'000000','CPQ产品',3,'org.dromara.cpq.controller.CpqProductModelController.removeBatch()','DELETE',1,'admin','管理员部门','/cpq/product/model/batch','0:0:0:0:0:0:0:1','内网IP','[\"2063217487460495361\",\"2063217487624073218\",\"2063216582241566721\",\"2063216582526779393\",\"2063216580136026113\"]','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-06 19:16:05',64),(2063218363600269313,'000000','CPQ产品目录',1,'org.dromara.cpq.controller.CpqProductCatalogController.add()','POST',1,'admin','管理员部门','/cpq/product/catalog','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"catalogId\":null,\"catalogName\":\"T1\",\"catalogType\":\"SALES\",\"effectiveDate\":null,\"expiryDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-06 19:16:05',34),(2063218365009555458,'000000','CPQ产品目录',2,'org.dromara.cpq.controller.CpqProductCatalogController.edit()','PUT',1,'admin','管理员部门','/cpq/product/catalog','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"catalogId\":\"2063218363528966145\",\"catalogName\":\"T1u\",\"catalogType\":\"SALES\",\"effectiveDate\":null,\"expiryDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-06 19:16:06',31),(2063218365508677634,'000000','CPQ产品目录',3,'org.dromara.cpq.controller.CpqProductCatalogController.remove()','DELETE',1,'admin','管理员部门','/cpq/product/catalog/2063218363528966145','0:0:0:0:0:0:0:1','内网IP','\"2063218363528966145\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-06 19:16:06',24),(2063218366959906818,'000000','CPQ产品',1,'org.dromara.cpq.controller.CpqProductModelController.add()','POST',1,'admin','管理员部门','/cpq/product/model','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"modelId\":null,\"catalogId\":\"2063204585085149186\",\"productLine\":\"L1\",\"productFamily\":\"L2\",\"productSeries\":\"L3\",\"modelCode\":\"T001\",\"modelName\":\"TModel\",\"description\":null,\"lifecycleStatus\":\"ACTIVE\",\"successorModelId\":null,\"basePrice\":null,\"currency\":null,\"minOrderQty\":null,\"leadTimeDays\":null,\"configType\":\"STANDARD\",\"defaultBomId\":null,\"thumbnailUrl\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-06 19:16:06',29),(2063218369241608193,'000000','CPQ产品',2,'org.dromara.cpq.controller.CpqProductModelController.edit()','PUT',1,'admin','管理员部门','/cpq/product/model','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"modelId\":\"2063218366905380866\",\"catalogId\":\"2063204585085149186\",\"productLine\":\"L1\",\"productFamily\":\"L2\",\"productSeries\":\"L3\",\"modelCode\":\"T001\",\"modelName\":\"TModelUpd\",\"description\":null,\"lifecycleStatus\":\"ACTIVE\",\"successorModelId\":null,\"basePrice\":null,\"currency\":null,\"minOrderQty\":null,\"leadTimeDays\":null,\"configType\":\"STANDARD\",\"defaultBomId\":null,\"thumbnailUrl\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-06 19:16:07',29),(2063218369652649986,'000000','CPQ产品',3,'org.dromara.cpq.controller.CpqProductModelController.remove()','DELETE',1,'admin','管理员部门','/cpq/product/model/2063218366905380866','0:0:0:0:0:0:0:1','内网IP','\"2063218366905380866\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-06 19:16:07',15),(2063218370084663297,'000000','CPQ产品',1,'org.dromara.cpq.controller.CpqProductModelController.add()','POST',1,'admin','管理员部门','/cpq/product/model','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"modelId\":null,\"catalogId\":\"2063204585085149186\",\"productLine\":\"S\",\"productFamily\":\"S\",\"productSeries\":\"S\",\"modelCode\":\"S1\",\"modelName\":\"SModel1\",\"description\":null,\"lifecycleStatus\":\"EOL_ANNOUNCED\",\"successorModelId\":null,\"basePrice\":null,\"currency\":null,\"minOrderQty\":null,\"leadTimeDays\":null,\"configType\":\"STANDARD\",\"defaultBomId\":null,\"thumbnailUrl\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-06 19:16:07',18),(2063218370323738626,'000000','CPQ产品',1,'org.dromara.cpq.controller.CpqProductModelController.add()','POST',1,'admin','管理员部门','/cpq/product/model','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"modelId\":null,\"catalogId\":\"2063204585085149186\",\"productLine\":\"S\",\"productFamily\":\"S\",\"productSeries\":\"S\",\"modelCode\":\"S2\",\"modelName\":\"SModel2\",\"description\":null,\"lifecycleStatus\":\"ACTIVE\",\"successorModelId\":null,\"basePrice\":null,\"currency\":null,\"minOrderQty\":null,\"leadTimeDays\":null,\"configType\":\"STANDARD\",\"defaultBomId\":null,\"thumbnailUrl\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-06 19:16:07',23),(2063218371850465282,'000000','CPQ产品替代关系',1,'org.dromara.cpq.controller.CpqProductSupersessionController.add()','POST',1,'admin','管理员部门','/cpq/product/supersession','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"supersessionId\":null,\"originalModelId\":\"2063218370042720258\",\"replacementModelId\":\"2063218370269212674\",\"supersessionType\":\"FULL\",\"conditionExpr\":null,\"priceImpactPct\":null,\"effectiveDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-06 19:16:07',11),(2063218372899041281,'000000','CPQ产品替代关系',2,'org.dromara.cpq.controller.CpqProductSupersessionController.edit()','PUT',1,'admin','管理员部门','/cpq/product/supersession','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"supersessionId\":\"2063216584552628225\",\"originalModelId\":\"2063218370042720258\",\"replacementModelId\":\"2063218370269212674\",\"supersessionType\":\"CONDITIONAL\",\"conditionExpr\":null,\"priceImpactPct\":null,\"effectiveDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-06 19:16:07',14),(2063218373263945730,'000000','CPQ产品替代关系',3,'org.dromara.cpq.controller.CpqProductSupersessionController.remove()','DELETE',1,'admin','管理员部门','/cpq/product/supersession/2063216584552628225','0:0:0:0:0:0:0:1','内网IP','\"2063216584552628225\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-06 19:16:08',11),(2063218373662404609,'000000','CPQ产品',3,'org.dromara.cpq.controller.CpqProductModelController.removeBatch()','DELETE',1,'admin','管理员部门','/cpq/product/model/batch','0:0:0:0:0:0:0:1','内网IP','[\"2063218370042720258\",\"2063218370269212674\"]','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-06 19:16:08',13),(2063219156365668353,'000000','CPQ产品目录',1,'org.dromara.cpq.controller.CpqProductCatalogController.add()','POST',1,'admin','管理员部门','/cpq/product/catalog','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"catalogId\":null,\"catalogName\":\"BrowserTest目录\",\"catalogType\":\"SALES\",\"effectiveDate\":null,\"expiryDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-06 19:19:14',30),(2063229571237736450,'000000','CPQ产品',1,'org.dromara.cpq.controller.CpqProductModelController.add()','POST',1,'admin','管理员部门','/cpq/product/model','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"modelId\":null,\"catalogId\":0,\"productLine\":\"1\",\"productFamily\":\"12\",\"productSeries\":\"123\",\"modelCode\":\"123001\",\"modelName\":\"123001——test\",\"description\":null,\"lifecycleStatus\":\"ACTIVE\",\"successorModelId\":null,\"basePrice\":\"23\",\"currency\":null,\"minOrderQty\":100,\"leadTimeDays\":30,\"configType\":\"STANDARD\",\"defaultBomId\":null,\"thumbnailUrl\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-06 20:00:37',50),(2063305600929202178,'000000','CPQ产品分类',1,'org.dromara.cpq.controller.CpqProductCategoryController.add()','POST',1,'admin','管理员部门','/cpq/product/category','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"categoryId\":null,\"parentCategoryId\":null,\"categoryLevel\":1,\"categoryCode\":\"TEST-L1\",\"categoryName\":\"测试产品线\",\"sortOrder\":99,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 01:02:44',55),(2063305601122140161,'000000','CPQ产品分类',3,'org.dromara.cpq.controller.CpqProductCategoryController.remove()','DELETE',1,'admin','管理员部门','/cpq/product/category/1','0:0:0:0:0:0:0:1','内网IP','1','',1,'该分类下存在子分类，无法删除','2026-06-07 01:02:44',14),(2063305601377992705,'000000','CPQ产品分类',3,'org.dromara.cpq.controller.CpqProductCategoryController.remove()','DELETE',1,'admin','管理员部门','/cpq/product/category/311','0:0:0:0:0:0:0:1','内网IP','311','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 01:02:44',29),(2063305692172091394,'000000','CPQ产品',1,'org.dromara.cpq.controller.CpqProductModelController.add()','POST',1,'admin','管理员部门','/cpq/product/model','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"modelId\":null,\"catalogId\":1,\"categoryId\":111,\"modelCode\":\"PD785-TEST\",\"modelName\":\"PD785测试款\",\"description\":\"3级级联lookup测试\",\"lifecycleStatus\":\"ACTIVE\",\"successorModelId\":null,\"basePrice\":null,\"currency\":null,\"minOrderQty\":null,\"leadTimeDays\":null,\"configType\":\"STANDARD\",\"defaultBomId\":null,\"thumbnailUrl\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 01:03:06',41),(2063317155804684290,'000000','CPQ系统参数',1,'org.dromara.cpq.controller.CpqSystemConfigController.add()','POST',1,'admin','管理员部门','/cpq/config','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"configId\":null,\"configKey\":\"TEST_KEY_001\",\"configValue\":\"test_value\",\"configType\":\"STRING\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 01:48:39',70),(2063317156035371009,'000000','CPQ系统参数',2,'org.dromara.cpq.controller.CpqSystemConfigController.edit()','PUT',1,'admin','管理员部门','/cpq/config','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"configId\":\"2063317155632717825\",\"configKey\":\"TEST_KEY_001\",\"configValue\":\"updated_value\",\"configType\":\"STRING\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 01:48:39',13),(2063317156136034306,'000000','CPQ系统参数',3,'org.dromara.cpq.controller.CpqSystemConfigController.remove()','DELETE',1,'admin','管理员部门','/cpq/config/2063317155632717825','0:0:0:0:0:0:0:1','内网IP','\"2063317155632717825\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 01:48:39',13),(2063317216689201154,'000000','CPQ系统参数',1,'org.dromara.cpq.controller.CpqSystemConfigController.add()','POST',1,'admin','管理员部门','/cpq/config','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"configId\":null,\"configKey\":\"TEST_KEY_001\",\"configValue\":\"test_value\",\"configType\":\"STRING\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 01:48:54',29),(2063317216932470785,'000000','CPQ系统参数',2,'org.dromara.cpq.controller.CpqSystemConfigController.edit()','PUT',1,'admin','管理员部门','/cpq/config','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"configId\":\"2063317216609509377\",\"configKey\":\"TEST_KEY_001\",\"configValue\":\"updated_value\",\"configType\":\"STRING\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 01:48:54',17),(2063317217049911297,'000000','CPQ系统参数',3,'org.dromara.cpq.controller.CpqSystemConfigController.remove()','DELETE',1,'admin','管理员部门','/cpq/config/2063317216609509377','0:0:0:0:0:0:0:1','内网IP','\"2063317216609509377\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 01:48:54',15),(2063317295193989121,'000000','CPQ生命周期状态变更',2,'org.dromara.cpq.controller.CpqProductLifecycleLogController.changeStatus()','PUT',1,'admin','管理员部门','/cpq/product/lifecycle/changeStatus','0:0:0:0:0:0:0:1','内网IP','{\"reason\":\"test status change\",\"modelId\":\"2063229571128684546\",\"targetStatus\":\"EOL_ANNOUNCED\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 01:49:12',60),(2063317295315623938,'000000','CPQ生命周期状态变更',2,'org.dromara.cpq.controller.CpqProductLifecycleLogController.changeStatus()','PUT',1,'admin','管理员部门','/cpq/product/lifecycle/changeStatus','0:0:0:0:0:0:0:1','内网IP','{\"reason\":\"illegal\",\"modelId\":\"2063229571128684546\",\"targetStatus\":\"CONCEPT\"}','',1,'不允许从 EOL_ANNOUNCED 变更到 CONCEPT（合法目标: DISCONTINUED, LAST_TIME_BUY）','2026-06-07 01:49:12',16),(2063317295504367618,'000000','CPQ生命周期状态变更',2,'org.dromara.cpq.controller.CpqProductLifecycleLogController.changeStatus()','PUT',1,'admin','管理员部门','/cpq/product/lifecycle/changeStatus','0:0:0:0:0:0:0:1','内网IP','{\"reason\":\"continue flow\",\"modelId\":\"2063229571128684546\",\"targetStatus\":\"LAST_TIME_BUY\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 01:49:12',25),(2063317295617613825,'000000','CPQ生命周期状态变更',2,'org.dromara.cpq.controller.CpqProductLifecycleLogController.changeStatus()','PUT',1,'admin','管理员部门','/cpq/product/lifecycle/changeStatus','0:0:0:0:0:0:0:1','内网IP','{\"reason\":\"final\",\"modelId\":\"2063229571128684546\",\"targetStatus\":\"DISCONTINUED\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 01:49:13',18),(2063323731403808770,'000000','CPQ产品替代关系',2,'org.dromara.cpq.controller.CpqProductSupersessionController.edit()','PUT',1,'admin','管理员部门','/cpq/product/supersession','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"supersessionId\":1,\"originalModelId\":\"9007199254740991\",\"replacementModelId\":\"9007199254740991\",\"supersessionType\":\"FULL\",\"conditionExpr\":null,\"priceImpactPct\":\"0\",\"effectiveDate\":\"2026-06-07 00:00:00\",\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 02:14:47',33),(2063325017255780354,'000000','CPQ产品替代关系',2,'org.dromara.cpq.controller.CpqProductSupersessionController.edit()','PUT',1,'admin','管理员部门','/cpq/product/supersession','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"supersessionId\":\"2063218371821105153\",\"originalModelId\":\"2063305692125954050\",\"replacementModelId\":\"2063229571128684546\",\"supersessionType\":\"FULL\",\"conditionExpr\":null,\"priceImpactPct\":null,\"effectiveDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 02:19:53',13),(2063325047605764098,'000000','CPQ产品替代关系',2,'org.dromara.cpq.controller.CpqProductSupersessionController.edit()','PUT',1,'admin','管理员部门','/cpq/product/supersession','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"supersessionId\":\"2063217488651677697\",\"originalModelId\":\"2063305692125954050\",\"replacementModelId\":0,\"supersessionType\":\"FULL\",\"conditionExpr\":null,\"priceImpactPct\":null,\"effectiveDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 02:20:01',14),(2063325100386885633,'000000','CPQ产品替代关系',2,'org.dromara.cpq.controller.CpqProductSupersessionController.edit()','PUT',1,'admin','管理员部门','/cpq/product/supersession','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"supersessionId\":\"2063217488651677697\",\"originalModelId\":\"2063305692125954050\",\"replacementModelId\":\"2063229571128684546\",\"supersessionType\":\"FULL\",\"conditionExpr\":null,\"priceImpactPct\":null,\"effectiveDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 02:20:13',7),(2063325154313052162,'000000','CPQ产品替代关系',2,'org.dromara.cpq.controller.CpqProductSupersessionController.edit()','PUT',1,'admin','管理员部门','/cpq/product/supersession','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"supersessionId\":1,\"originalModelId\":\"2063305692125954050\",\"replacementModelId\":\"2063229571128684546\",\"supersessionType\":\"FULL\",\"conditionExpr\":null,\"priceImpactPct\":\"0\",\"effectiveDate\":\"2026-06-07 00:00:00\",\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 02:20:26',10),(2063334208884211714,'000000','CPQ产品分类',1,'org.dromara.cpq.controller.CpqProductCategoryController.add()','POST',1,'admin','管理员部门','/cpq/product/category','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"categoryId\":null,\"parentCategoryId\":null,\"categoryLevel\":2,\"categoryCode\":\"TEST_ROOT\",\"categoryName\":\"测试产品族\",\"sortOrder\":0,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 02:56:25',116),(2063334413469777921,'000000','CPQ产品',2,'org.dromara.cpq.controller.CpqProductModelController.edit()','PUT',1,'admin','管理员部门','/cpq/product/model','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"modelId\":\"2063305692125954050\",\"catalogId\":\"2063204585085149186\",\"categoryId\":111,\"modelCode\":\"PD785-TEST\",\"modelName\":\"PD785测试款\",\"description\":\"3级级联lookup测试\",\"lifecycleStatus\":\"ACTIVE\",\"successorModelId\":null,\"basePrice\":null,\"currency\":\"CNY\",\"minOrderQty\":1,\"leadTimeDays\":null,\"configType\":\"STANDARD\",\"defaultBomId\":null,\"thumbnailUrl\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 02:57:14',73),(2063334457698713601,'000000','CPQ产品',2,'org.dromara.cpq.controller.CpqProductModelController.edit()','PUT',1,'admin','管理员部门','/cpq/product/model','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"modelId\":\"2063229571128684546\",\"catalogId\":\"2063216579007758337\",\"categoryId\":111,\"modelCode\":\"123001\",\"modelName\":\"123001——test\",\"description\":null,\"lifecycleStatus\":\"DISCONTINUED\",\"successorModelId\":null,\"basePrice\":\"23\",\"currency\":\"CNY\",\"minOrderQty\":100,\"leadTimeDays\":30,\"configType\":\"STANDARD\",\"defaultBomId\":null,\"thumbnailUrl\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 02:57:24',68),(2063463588002516993,'000000','CPQ价格手册',1,'org.dromara.cpq.pricing.controller.CpqPriceBookController.add()','POST',1,'admin','管理员部门','/cpq/pricing/pricebook','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceBookId\":null,\"bookName\":\"测试手册\",\"bookType\":null,\"currency\":null,\"effectiveDate\":null,\"expiryDate\":null,\"priority\":null,\"status\":\"active\"}','',1,'\n### Error updating database.  Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Data too long for column \'status\' at row 1\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqPriceBookMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqPriceBookMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_price_book (price_book_id, book_name, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Data too long for column \'status\' at row 1\n; Data truncation: Data too long for column \'status\' at row 1','2026-06-07 11:30:31',154),(2063463588296118273,'000000','CPQ定价规则',1,'org.dromara.cpq.pricing.controller.CpqPriceRuleController.add()','POST',1,'admin','管理员部门','/cpq/pricing/rule','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceRuleId\":null,\"ruleName\":\"Test\",\"ruleType\":\"discount\",\"priority\":1,\"conditionJson\":\"{}\",\"actionJson\":\"{\\\"discount\\\":0.9}\",\"approvalThreshold\":null,\"effectiveDate\":null,\"expiryDate\":null,\"status\":\"active\"}','',1,'\n### Error updating database.  Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Data too long for column \'status\' at row 1\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqPriceRuleMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqPriceRuleMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_price_rule (price_rule_id, rule_name, rule_type, priority, condition_json, action_json, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Data too long for column \'status\' at row 1\n; Data truncation: Data too long for column \'status\' at row 1','2026-06-07 11:30:31',25),(2063463588606496769,'000000','CPQ阶梯定价',1,'org.dromara.cpq.pricing.controller.CpqVolumeTierController.add()','POST',1,'admin','管理员部门','/cpq/pricing/volumetier','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"tierId\":null,\"priceBookEntryId\":1,\"minQuantity\":null,\"maxQuantity\":null,\"unitPrice\":\"95.00\",\"sortOrder\":null}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'min_quantity\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqVolumeTierMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqVolumeTierMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_volume_tier (tier_id, price_book_entry_id, unit_price, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'min_quantity\' doesn\'t have a default value\n; Field \'min_quantity\' doesn\'t have a default value','2026-06-07 11:30:31',21),(2063463588832989186,'000000','CPQ渠道价格',1,'org.dromara.cpq.pricing.controller.CpqChannelPriceController.add()','POST',1,'admin','管理员部门','/cpq/pricing/channelprice','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"channelPriceId\":null,\"channelCode\":\"D001\",\"modelId\":null,\"channelListPrice\":null,\"channelDiscountPct\":null,\"effectiveDate\":null,\"expiryDate\":null,\"status\":null}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'model_id\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqChannelPriceMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqChannelPriceMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_channel_price (channel_price_id, channel_code, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'model_id\' doesn\'t have a default value\n; Field \'model_id\' doesn\'t have a default value','2026-06-07 11:30:32',15),(2063463589512466434,'000000','CPQ汇率',1,'org.dromara.cpq.pricing.controller.CpqCurrencyRateController.add()','POST',1,'admin','管理员部门','/cpq/pricing/currencyrate','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"rateId\":null,\"fromCurrency\":\"USD\",\"toCurrency\":\"CNY\",\"exchangeRate\":null,\"effectiveDate\":\"2026-06-01 00:00:00\",\"status\":null}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'exchange_rate\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqCurrencyRateMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqCurrencyRateMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_currency_rate (rate_id, from_currency, to_currency, effective_date, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'exchange_rate\' doesn\'t have a default value\n; Field \'exchange_rate\' doesn\'t have a default value','2026-06-07 11:30:32',15),(2063463957680082946,'000000','CPQ价格手册',1,'org.dromara.cpq.pricing.controller.CpqPriceBookController.add()','POST',1,'admin','管理员部门','/cpq/pricing/pricebook','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceBookId\":null,\"bookName\":\"测试手册\",\"bookType\":\"standard\",\"currency\":\"CNY\",\"effectiveDate\":\"2026-06-01 00:00:00\",\"expiryDate\":null,\"priority\":null,\"status\":\"active\"}','',1,'\n### Error updating database.  Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Data too long for column \'status\' at row 1\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqPriceBookMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqPriceBookMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_price_book (price_book_id, book_name, book_type, currency, effective_date, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Data too long for column \'status\' at row 1\n; Data truncation: Data too long for column \'status\' at row 1','2026-06-07 11:31:59',100),(2063463958439251970,'000000','CPQ价格手册条目',1,'org.dromara.cpq.pricing.controller.CpqPriceBookEntryController.add()','POST',1,'admin','管理员部门','/cpq/pricing/entry','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"entryId\":null,\"priceBookId\":1,\"modelId\":1,\"itemCode\":null,\"regionCode\":null,\"channelCode\":null,\"listPrice\":\"100.00\",\"costPrice\":null,\"minPrice\":null,\"effectiveDate\":\"2026-06-01 00:00:00\",\"expiryDate\":null,\"status\":\"active\"}','',1,'\n### Error updating database.  Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Data too long for column \'status\' at row 1\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqPriceBookEntryMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqPriceBookEntryMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_price_book_entry (entry_id, price_book_id, model_id, list_price, effective_date, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Data too long for column \'status\' at row 1\n; Data truncation: Data too long for column \'status\' at row 1','2026-06-07 11:32:00',54),(2063463958783184897,'000000','CPQ定价规则',1,'org.dromara.cpq.pricing.controller.CpqPriceRuleController.add()','POST',1,'admin','管理员部门','/cpq/pricing/rule','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceRuleId\":null,\"ruleName\":\"测试规则\",\"ruleType\":\"discount\",\"priority\":1,\"conditionJson\":null,\"actionJson\":\"{\\\"discount\\\":0.9}\",\"approvalThreshold\":null,\"effectiveDate\":\"2026-06-01 00:00:00\",\"expiryDate\":null,\"status\":\"active\"}','',1,'\n### Error updating database.  Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Data too long for column \'status\' at row 1\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqPriceRuleMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqPriceRuleMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_price_rule (price_rule_id, rule_name, rule_type, priority, action_json, effective_date, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Data too long for column \'status\' at row 1\n; Data truncation: Data too long for column \'status\' at row 1','2026-06-07 11:32:00',10),(2063463960565764097,'000000','CPQ阶梯定价',1,'org.dromara.cpq.pricing.controller.CpqVolumeTierController.add()','POST',1,'admin','管理员部门','/cpq/pricing/volumetier','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"tierId\":null,\"priceBookEntryId\":1,\"minQuantity\":\"1\",\"maxQuantity\":\"100\",\"unitPrice\":\"95.00\",\"sortOrder\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 11:32:00',111),(2063463961157160961,'000000','CPQ渠道价格',1,'org.dromara.cpq.pricing.controller.CpqChannelPriceController.add()','POST',1,'admin','管理员部门','/cpq/pricing/channelprice','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"channelPriceId\":null,\"channelCode\":\"D001\",\"modelId\":1,\"channelListPrice\":\"88.00\",\"channelDiscountPct\":null,\"effectiveDate\":\"2026-06-01 00:00:00\",\"expiryDate\":null,\"status\":\"active\"}','',1,'\n### Error updating database.  Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Data too long for column \'status\' at row 1\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqChannelPriceMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqChannelPriceMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_channel_price (channel_price_id, channel_code, model_id, channel_list_price, effective_date, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Data too long for column \'status\' at row 1\n; Data truncation: Data too long for column \'status\' at row 1','2026-06-07 11:32:00',9),(2063463961450762241,'000000','CPQ汇率',1,'org.dromara.cpq.pricing.controller.CpqCurrencyRateController.add()','POST',1,'admin','管理员部门','/cpq/pricing/currencyrate','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"rateId\":null,\"fromCurrency\":\"USD\",\"toCurrency\":\"CNY\",\"exchangeRate\":\"7.25\",\"effectiveDate\":\"2026-06-01 00:00:00\",\"status\":\"active\"}','',1,'\n### Error updating database.  Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Data too long for column \'status\' at row 1\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqCurrencyRateMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqCurrencyRateMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_currency_rate (rate_id, from_currency, to_currency, exchange_rate, effective_date, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Data too long for column \'status\' at row 1\n; Data truncation: Data too long for column \'status\' at row 1','2026-06-07 11:32:00',16),(2063464647404015617,'000000','CPQ价格手册',1,'org.dromara.cpq.pricing.controller.CpqPriceBookController.add()','POST',1,'admin','管理员部门','/cpq/pricing/pricebook','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceBookId\":null,\"bookName\":\"测试手册\",\"bookType\":\"standard\",\"currency\":\"CNY\",\"effectiveDate\":\"2026-06-01 00:00:00\",\"expiryDate\":null,\"priority\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 11:34:44',36),(2063464648377094145,'000000','CPQ价格手册条目',1,'org.dromara.cpq.pricing.controller.CpqPriceBookEntryController.add()','POST',1,'admin','管理员部门','/cpq/pricing/entry','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"entryId\":null,\"priceBookId\":1,\"modelId\":1,\"itemCode\":null,\"regionCode\":null,\"channelCode\":null,\"listPrice\":\"100.00\",\"costPrice\":null,\"minPrice\":null,\"effectiveDate\":\"2026-06-01 00:00:00\",\"expiryDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 11:34:44',14),(2063464648607780866,'000000','CPQ定价规则',1,'org.dromara.cpq.pricing.controller.CpqPriceRuleController.add()','POST',1,'admin','管理员部门','/cpq/pricing/rule','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceRuleId\":null,\"ruleName\":\"测试规则\",\"ruleType\":\"discount\",\"priority\":1,\"conditionJson\":null,\"actionJson\":\"{\\\"discount\\\":0.9}\",\"approvalThreshold\":null,\"effectiveDate\":\"2026-06-01 00:00:00\",\"expiryDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 11:34:44',14),(2063464648830078977,'000000','CPQ阶梯定价',1,'org.dromara.cpq.pricing.controller.CpqVolumeTierController.add()','POST',1,'admin','管理员部门','/cpq/pricing/volumetier','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"tierId\":null,\"priceBookEntryId\":1,\"minQuantity\":\"10\",\"maxQuantity\":\"200\",\"unitPrice\":\"85.00\",\"sortOrder\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 11:34:44',10),(2063464649081737218,'000000','CPQ渠道价格',1,'org.dromara.cpq.pricing.controller.CpqChannelPriceController.add()','POST',1,'admin','管理员部门','/cpq/pricing/channelprice','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"channelPriceId\":null,\"channelCode\":\"D001\",\"modelId\":1,\"channelListPrice\":\"88.00\",\"channelDiscountPct\":null,\"effectiveDate\":\"2026-06-01 00:00:00\",\"expiryDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 11:34:44',10),(2063464649333395457,'000000','CPQ汇率',1,'org.dromara.cpq.pricing.controller.CpqCurrencyRateController.add()','POST',1,'admin','管理员部门','/cpq/pricing/currencyrate','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"rateId\":null,\"fromCurrency\":\"USD\",\"toCurrency\":\"CNY\",\"exchangeRate\":\"7.25\",\"effectiveDate\":\"2026-06-01 00:00:00\",\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 11:34:44',10),(2063464787506352130,'000000','CPQ价格手册',2,'org.dromara.cpq.pricing.controller.CpqPriceBookController.edit()','PUT',1,'admin','管理员部门','/cpq/pricing/pricebook','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceBookId\":1,\"bookName\":\"已修改手册\",\"bookType\":\"standard\",\"currency\":\"CNY\",\"effectiveDate\":null,\"expiryDate\":null,\"priority\":null,\"status\":\"0\"}','{\"code\":500,\"msg\":\"操作失败\",\"data\":null}',0,'','2026-06-07 11:35:17',35),(2063464788391350273,'000000','CPQ价格手册',3,'org.dromara.cpq.pricing.controller.CpqPriceBookController.remove()','DELETE',1,'admin','管理员部门','/cpq/pricing/pricebook/1','0:0:0:0:0:0:0:1','内网IP','1','{\"code\":500,\"msg\":\"操作失败\",\"data\":null}',0,'','2026-06-07 11:35:18',54),(2063464788949192705,'000000','CPQ定价规则',2,'org.dromara.cpq.pricing.controller.CpqPriceRuleController.edit()','PUT',1,'admin','管理员部门','/cpq/pricing/rule','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceRuleId\":1,\"ruleName\":\"已修改规则\",\"ruleType\":\"discount\",\"priority\":2,\"conditionJson\":null,\"actionJson\":\"{\\\"discount\\\":0.8}\",\"approvalThreshold\":null,\"effectiveDate\":null,\"expiryDate\":null,\"status\":\"0\"}','{\"code\":500,\"msg\":\"操作失败\",\"data\":null}',0,'','2026-06-07 11:35:18',17),(2063464789209239554,'000000','CPQ阶梯定价',3,'org.dromara.cpq.pricing.controller.CpqVolumeTierController.remove()','DELETE',1,'admin','管理员部门','/cpq/pricing/volumetier/1','0:0:0:0:0:0:0:1','内网IP','1','{\"code\":500,\"msg\":\"操作失败\",\"data\":null}',0,'','2026-06-07 11:35:18',13),(2063465285743529986,'000000','CPQ价格手册',2,'org.dromara.cpq.pricing.controller.CpqPriceBookController.edit()','PUT',1,'admin','管理员部门','/cpq/pricing/pricebook','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceBookId\":\"2063464647303352321\",\"bookName\":\"已修改手册\",\"bookType\":\"standard\",\"currency\":\"CNY\",\"effectiveDate\":null,\"expiryDate\":null,\"priority\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 11:37:16',20),(2063465286230069250,'000000','CPQ汇率',2,'org.dromara.cpq.pricing.controller.CpqCurrencyRateController.edit()','PUT',1,'admin','管理员部门','/cpq/pricing/currencyrate','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"rateId\":\"2063464649291452418\",\"fromCurrency\":\"USD\",\"toCurrency\":\"CNY\",\"exchangeRate\":\"7.30\",\"effectiveDate\":\"2026-06-07 00:00:00\",\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 11:37:16',8),(2063465286402035714,'000000','CPQ阶梯定价',3,'org.dromara.cpq.pricing.controller.CpqVolumeTierController.remove()','DELETE',1,'admin','管理员部门','/cpq/pricing/volumetier/2063463960075030529','0:0:0:0:0:0:0:1','内网IP','\"2063463960075030529\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 11:37:16',9),(2063465286574002177,'000000','CPQ渠道价格',3,'org.dromara.cpq.pricing.controller.CpqChannelPriceController.remove()','DELETE',1,'admin','管理员部门','/cpq/pricing/channelprice/2063464649043988482','0:0:0:0:0:0:0:1','内网IP','\"2063464649043988482\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 11:37:16',7),(2063465286737580033,'000000','CPQ价格手册',3,'org.dromara.cpq.pricing.controller.CpqPriceBookController.remove()','DELETE',1,'admin','管理员部门','/cpq/pricing/pricebook/2063464647303352321','0:0:0:0:0:0:0:1','内网IP','\"2063464647303352321\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 11:37:16',6),(2063468849719136258,'000000','CPQ价格手册',1,'org.dromara.cpq.pricing.controller.CpqPriceBookController.add()','POST',1,'admin','管理员部门','/cpq/pricing/pricebook','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceBookId\":null,\"bookName\":\"test1\",\"bookType\":\"STANDARD\",\"currency\":\"CNY\",\"effectiveDate\":null,\"expiryDate\":null,\"priority\":0,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqPriceBookMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqPriceBookMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_price_book (price_book_id, book_name, book_type, currency, priority, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n; Field \'effective_date\' doesn\'t have a default value','2026-06-07 11:51:26',42),(2063468855985426434,'000000','CPQ价格手册',1,'org.dromara.cpq.pricing.controller.CpqPriceBookController.add()','POST',1,'admin','管理员部门','/cpq/pricing/pricebook','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceBookId\":null,\"bookName\":\"test1\",\"bookType\":\"STANDARD\",\"currency\":\"CNY\",\"effectiveDate\":null,\"expiryDate\":null,\"priority\":0,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqPriceBookMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqPriceBookMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_price_book (price_book_id, book_name, book_type, currency, priority, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n; Field \'effective_date\' doesn\'t have a default value','2026-06-07 11:51:27',9),(2063551397065379841,'000000','CPQ渠道价格',1,'org.dromara.cpq.pricing.controller.CpqChannelPriceController.add()','POST',1,'admin','管理员部门','/cpq/pricing/channelprice','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"channelPriceId\":null,\"channelCode\":\"3334455554\",\"modelId\":2323,\"channelListPrice\":\"0\",\"channelDiscountPct\":null,\"effectiveDate\":null,\"expiryDate\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqChannelPriceMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqChannelPriceMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_channel_price (channel_price_id, channel_code, model_id, channel_list_price, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n; Field \'effective_date\' doesn\'t have a default value','2026-06-07 17:19:27',67),(2063551401943355394,'000000','CPQ渠道价格',1,'org.dromara.cpq.pricing.controller.CpqChannelPriceController.add()','POST',1,'admin','管理员部门','/cpq/pricing/channelprice','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"channelPriceId\":null,\"channelCode\":\"3334455554\",\"modelId\":2323,\"channelListPrice\":\"0\",\"channelDiscountPct\":null,\"effectiveDate\":null,\"expiryDate\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqChannelPriceMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqChannelPriceMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_channel_price (channel_price_id, channel_code, model_id, channel_list_price, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n; Field \'effective_date\' doesn\'t have a default value','2026-06-07 17:19:28',5),(2063551405235884033,'000000','CPQ渠道价格',1,'org.dromara.cpq.pricing.controller.CpqChannelPriceController.add()','POST',1,'admin','管理员部门','/cpq/pricing/channelprice','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"channelPriceId\":null,\"channelCode\":\"3334455554\",\"modelId\":2323,\"channelListPrice\":\"0\",\"channelDiscountPct\":null,\"effectiveDate\":null,\"expiryDate\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqChannelPriceMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqChannelPriceMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_channel_price (channel_price_id, channel_code, model_id, channel_list_price, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n; Field \'effective_date\' doesn\'t have a default value','2026-06-07 17:19:29',8),(2063551406003441666,'000000','CPQ渠道价格',1,'org.dromara.cpq.pricing.controller.CpqChannelPriceController.add()','POST',1,'admin','管理员部门','/cpq/pricing/channelprice','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"channelPriceId\":null,\"channelCode\":\"3334455554\",\"modelId\":2323,\"channelListPrice\":\"0\",\"channelDiscountPct\":null,\"effectiveDate\":null,\"expiryDate\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqChannelPriceMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqChannelPriceMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_channel_price (channel_price_id, channel_code, model_id, channel_list_price, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n; Field \'effective_date\' doesn\'t have a default value','2026-06-07 17:19:29',7),(2063551447682240514,'000000','CPQ阶梯定价',1,'org.dromara.cpq.pricing.controller.CpqVolumeTierController.add()','POST',1,'admin','管理员部门','/cpq/pricing/volumetier','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"tierId\":null,\"priceBookEntryId\":12,\"minQuantity\":\"0\",\"maxQuantity\":null,\"unitPrice\":\"0\",\"sortOrder\":0}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 17:19:39',16),(2063551491038760961,'000000','CPQ定价规则',1,'org.dromara.cpq.pricing.controller.CpqPriceRuleController.add()','POST',1,'admin','管理员部门','/cpq/pricing/rule','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceRuleId\":null,\"ruleName\":\"\",\"ruleType\":\"DISCOUNT\",\"priority\":2,\"conditionJson\":\"\",\"actionJson\":\"\",\"approvalThreshold\":null,\"effectiveDate\":null,\"expiryDate\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Invalid JSON text: \"The document is empty.\" at position 0 in value for column \'cpq_price_rule.condition_json\'.\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqPriceRuleMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqPriceRuleMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_price_rule (price_rule_id, rule_name, rule_type, priority, condition_json, action_json, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Invalid JSON text: \"The document is empty.\" at position 0 in value for column \'cpq_price_rule.condition_json\'.\n; Data truncation: Invalid JSON text: \"The document is empty.\" at position 0 in value for column \'cpq_price_rule.condition_json\'.','2026-06-07 17:19:49',17),(2063551495014961153,'000000','CPQ定价规则',1,'org.dromara.cpq.pricing.controller.CpqPriceRuleController.add()','POST',1,'admin','管理员部门','/cpq/pricing/rule','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceRuleId\":null,\"ruleName\":\"\",\"ruleType\":\"DISCOUNT\",\"priority\":2,\"conditionJson\":\"\",\"actionJson\":\"\",\"approvalThreshold\":null,\"effectiveDate\":null,\"expiryDate\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Invalid JSON text: \"The document is empty.\" at position 0 in value for column \'cpq_price_rule.condition_json\'.\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqPriceRuleMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqPriceRuleMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_price_rule (price_rule_id, rule_name, rule_type, priority, condition_json, action_json, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Invalid JSON text: \"The document is empty.\" at position 0 in value for column \'cpq_price_rule.condition_json\'.\n; Data truncation: Invalid JSON text: \"The document is empty.\" at position 0 in value for column \'cpq_price_rule.condition_json\'.','2026-06-07 17:19:50',9),(2063551499557392385,'000000','CPQ定价规则',1,'org.dromara.cpq.pricing.controller.CpqPriceRuleController.add()','POST',1,'admin','管理员部门','/cpq/pricing/rule','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceRuleId\":null,\"ruleName\":\"\",\"ruleType\":\"DISCOUNT\",\"priority\":2,\"conditionJson\":\"\",\"actionJson\":\"\",\"approvalThreshold\":null,\"effectiveDate\":null,\"expiryDate\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Invalid JSON text: \"The document is empty.\" at position 0 in value for column \'cpq_price_rule.condition_json\'.\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqPriceRuleMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqPriceRuleMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_price_rule (price_rule_id, rule_name, rule_type, priority, condition_json, action_json, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Invalid JSON text: \"The document is empty.\" at position 0 in value for column \'cpq_price_rule.condition_json\'.\n; Data truncation: Invalid JSON text: \"The document is empty.\" at position 0 in value for column \'cpq_price_rule.condition_json\'.','2026-06-07 17:19:51',35),(2063554481472655362,'000000','CPQ价格手册',1,'org.dromara.cpq.pricing.controller.CpqPriceBookController.add()','POST',1,'admin','管理员部门','/cpq/pricing/pricebook','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceBookId\":null,\"bookName\":\"123\",\"bookType\":\"STANDARD\",\"currency\":\"CNY\",\"effectiveDate\":null,\"expiryDate\":null,\"priority\":0,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqPriceBookMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqPriceBookMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_price_book (price_book_id, book_name, book_type, currency, priority, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n; Field \'effective_date\' doesn\'t have a default value','2026-06-07 17:31:42',67),(2063554484232507393,'000000','CPQ价格手册',1,'org.dromara.cpq.pricing.controller.CpqPriceBookController.add()','POST',1,'admin','管理员部门','/cpq/pricing/pricebook','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceBookId\":null,\"bookName\":\"123\",\"bookType\":\"STANDARD\",\"currency\":\"CNY\",\"effectiveDate\":null,\"expiryDate\":null,\"priority\":0,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqPriceBookMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqPriceBookMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_price_book (price_book_id, book_name, book_type, currency, priority, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n; Field \'effective_date\' doesn\'t have a default value','2026-06-07 17:31:43',14),(2063554484987482114,'000000','CPQ价格手册',1,'org.dromara.cpq.pricing.controller.CpqPriceBookController.add()','POST',1,'admin','管理员部门','/cpq/pricing/pricebook','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceBookId\":null,\"bookName\":\"123\",\"bookType\":\"STANDARD\",\"currency\":\"CNY\",\"effectiveDate\":null,\"expiryDate\":null,\"priority\":0,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqPriceBookMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqPriceBookMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_price_book (price_book_id, book_name, book_type, currency, priority, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n; Field \'effective_date\' doesn\'t have a default value','2026-06-07 17:31:43',15),(2063554532634775554,'000000','CPQ定价规则',1,'org.dromara.cpq.pricing.controller.CpqPriceRuleController.add()','POST',1,'admin','管理员部门','/cpq/pricing/rule','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceRuleId\":null,\"ruleName\":\"ccc\",\"ruleType\":\"DISCOUNT\",\"priority\":0,\"conditionJson\":\"\",\"actionJson\":\"\",\"approvalThreshold\":null,\"effectiveDate\":null,\"expiryDate\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Invalid JSON text: \"The document is empty.\" at position 0 in value for column \'cpq_price_rule.condition_json\'.\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqPriceRuleMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqPriceRuleMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_price_rule (price_rule_id, rule_name, rule_type, priority, condition_json, action_json, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Invalid JSON text: \"The document is empty.\" at position 0 in value for column \'cpq_price_rule.condition_json\'.\n; Data truncation: Invalid JSON text: \"The document is empty.\" at position 0 in value for column \'cpq_price_rule.condition_json\'.','2026-06-07 17:31:54',23),(2063554568152141826,'000000','CPQ阶梯定价',1,'org.dromara.cpq.pricing.controller.CpqVolumeTierController.add()','POST',1,'admin','管理员部门','/cpq/pricing/volumetier','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"tierId\":null,\"priceBookEntryId\":1333,\"minQuantity\":\"0\",\"maxQuantity\":null,\"unitPrice\":\"0\",\"sortOrder\":0}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 17:32:03',19),(2063554601362640898,'000000','CPQ阶梯定价',1,'org.dromara.cpq.pricing.controller.CpqVolumeTierController.add()','POST',1,'admin','管理员部门','/cpq/pricing/volumetier','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"tierId\":null,\"priceBookEntryId\":1,\"minQuantity\":\"0\",\"maxQuantity\":null,\"unitPrice\":\"0\",\"sortOrder\":0}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 17:32:11',35),(2063554635583967234,'000000','CPQ渠道价格',1,'org.dromara.cpq.pricing.controller.CpqChannelPriceController.add()','POST',1,'admin','管理员部门','/cpq/pricing/channelprice','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"channelPriceId\":null,\"channelCode\":\"343434\",\"modelId\":1,\"channelListPrice\":\"0\",\"channelDiscountPct\":null,\"effectiveDate\":null,\"expiryDate\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqChannelPriceMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqChannelPriceMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_channel_price (channel_price_id, channel_code, model_id, channel_list_price, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n; Field \'effective_date\' doesn\'t have a default value','2026-06-07 17:32:19',31),(2063554639555973121,'000000','CPQ渠道价格',1,'org.dromara.cpq.pricing.controller.CpqChannelPriceController.add()','POST',1,'admin','管理员部门','/cpq/pricing/channelprice','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"channelPriceId\":null,\"channelCode\":\"343434\",\"modelId\":1,\"channelListPrice\":\"0\",\"channelDiscountPct\":null,\"effectiveDate\":null,\"expiryDate\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqChannelPriceMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqChannelPriceMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_channel_price (channel_price_id, channel_code, model_id, channel_list_price, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n; Field \'effective_date\' doesn\'t have a default value','2026-06-07 17:32:20',21),(2063557682133454849,'000000','CPQ价格手册',1,'org.dromara.cpq.pricing.controller.CpqPriceBookController.add()','POST',1,'admin','管理员部门','/cpq/pricing/pricebook','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceBookId\":null,\"bookName\":\"test-api-book\",\"bookType\":\"STANDARD\",\"currency\":\"CNY\",\"effectiveDate\":\"2026-06-08 00:00:00\",\"expiryDate\":null,\"priority\":0,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 17:44:25',35),(2063558031162462210,'000000','CPQ价格手册',1,'org.dromara.cpq.pricing.controller.CpqPriceBookController.add()','POST',1,'admin','管理员部门','/cpq/pricing/pricebook','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceBookId\":null,\"bookName\":\"test-via-proxy\",\"bookType\":\"STANDARD\",\"currency\":\"CNY\",\"effectiveDate\":\"2026-06-08 00:00:00\",\"expiryDate\":null,\"priority\":0,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 17:45:48',30),(2063558899651825665,'000000','CPQ价格手册',1,'org.dromara.cpq.pricing.controller.CpqPriceBookController.add()','POST',1,'admin','管理员部门','/cpq/pricing/pricebook','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceBookId\":null,\"bookName\":\"Browser测试手册\",\"bookType\":\"STANDARD\",\"currency\":\"CNY\",\"effectiveDate\":null,\"expiryDate\":null,\"priority\":0,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqPriceBookMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqPriceBookMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_price_book (price_book_id, book_name, book_type, currency, priority, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n; Field \'effective_date\' doesn\'t have a default value','2026-06-07 17:49:15',31),(2063559178501738498,'000000','CPQ价格手册',1,'org.dromara.cpq.pricing.controller.CpqPriceBookController.add()','POST',1,'admin','管理员部门','/cpq/pricing/pricebook','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceBookId\":null,\"bookName\":\"test-empty-date\",\"bookType\":\"STANDARD\",\"currency\":\"CNY\",\"effectiveDate\":null,\"expiryDate\":null,\"priority\":0,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqPriceBookMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqPriceBookMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_price_book (price_book_id, book_name, book_type, currency, priority, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n; Field \'effective_date\' doesn\'t have a default value','2026-06-07 17:50:22',26),(2063559260227751938,'000000','CPQ价格手册',1,'org.dromara.cpq.pricing.controller.CpqPriceBookController.add()','POST',1,'admin','管理员部门','/cpq/pricing/pricebook','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceBookId\":null,\"bookName\":\"test-valid-date\",\"bookType\":\"STANDARD\",\"currency\":\"CNY\",\"effectiveDate\":\"2026-06-08 00:00:00\",\"expiryDate\":null,\"priority\":0,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 17:50:41',66),(2063559423210016769,'000000','CPQ价格手册',1,'org.dromara.cpq.pricing.controller.CpqPriceBookController.add()','POST',1,'admin','管理员部门','/cpq/pricing/pricebook','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceBookId\":null,\"bookName\":\"test\",\"bookType\":\"STANDARD\",\"currency\":\"CNY\",\"effectiveDate\":null,\"expiryDate\":null,\"priority\":0,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqPriceBookMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqPriceBookMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_price_book (price_book_id, book_name, book_type, currency, priority, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n; Field \'effective_date\' doesn\'t have a default value','2026-06-07 17:51:20',77),(2063559423415537665,'000000','CPQ价格手册',1,'org.dromara.cpq.pricing.controller.CpqPriceBookController.add()','POST',1,'admin','管理员部门','/cpq/pricing/pricebook','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceBookId\":null,\"bookName\":\"test2\",\"bookType\":\"STANDARD\",\"currency\":\"CNY\",\"effectiveDate\":\"2026-06-08 00:00:00\",\"expiryDate\":null,\"priority\":0,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 17:51:20',11),(2063560298364129281,'000000','CPQ价格手册',1,'org.dromara.cpq.pricing.controller.CpqPriceBookController.add()','POST',1,'admin','管理员部门','/cpq/pricing/pricebook','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceBookId\":null,\"bookName\":\"浏览器测试-修复后\",\"bookType\":\"STANDARD\",\"currency\":\"CNY\",\"effectiveDate\":\"2026-06-07 00:00:00\",\"expiryDate\":null,\"priority\":0,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 17:54:49',53),(2063560548273344514,'000000','CPQ定价规则',1,'org.dromara.cpq.pricing.controller.CpqPriceRuleController.add()','POST',1,'admin','管理员部门','/cpq/pricing/rule','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceRuleId\":null,\"ruleName\":\"测试规则\",\"ruleType\":\"DISCOUNT\",\"priority\":0,\"conditionJson\":\"\",\"actionJson\":\"\",\"approvalThreshold\":null,\"effectiveDate\":\"2026-06-07 00:00:00\",\"expiryDate\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Invalid JSON text: \"The document is empty.\" at position 0 in value for column \'cpq_price_rule.condition_json\'.\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqPriceRuleMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqPriceRuleMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_price_rule (price_rule_id, rule_name, rule_type, priority, condition_json, action_json, effective_date, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Invalid JSON text: \"The document is empty.\" at position 0 in value for column \'cpq_price_rule.condition_json\'.\n; Data truncation: Invalid JSON text: \"The document is empty.\" at position 0 in value for column \'cpq_price_rule.condition_json\'.','2026-06-07 17:55:48',39),(2063561100818370562,'000000','CPQ价格手册条目',1,'org.dromara.cpq.pricing.controller.CpqPriceBookEntryController.add()','POST',1,'admin','管理员部门','/cpq/pricing/entry','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"entryId\":null,\"priceBookId\":\"2063559260051591169\",\"modelId\":1,\"itemCode\":\"2323dsdsfee\",\"regionCode\":\"\",\"channelCode\":\"\",\"listPrice\":\"0\",\"costPrice\":null,\"minPrice\":null,\"effectiveDate\":\"2026-06-07 00:00:00\",\"expiryDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 17:58:00',21),(2063562154599501826,'000000','CPQ定价规则',1,'org.dromara.cpq.pricing.controller.CpqPriceRuleController.add()','POST',1,'admin','管理员部门','/cpq/pricing/rule','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceRuleId\":null,\"ruleName\":\"eeee\",\"ruleType\":\"DISCOUNT\",\"priority\":4,\"conditionJson\":\"\",\"actionJson\":\"\",\"approvalThreshold\":null,\"effectiveDate\":\"2026-06-07 00:00:00\",\"expiryDate\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Invalid JSON text: \"The document is empty.\" at position 0 in value for column \'cpq_price_rule.condition_json\'.\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqPriceRuleMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqPriceRuleMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_price_rule (price_rule_id, rule_name, rule_type, priority, condition_json, action_json, effective_date, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Invalid JSON text: \"The document is empty.\" at position 0 in value for column \'cpq_price_rule.condition_json\'.\n; Data truncation: Invalid JSON text: \"The document is empty.\" at position 0 in value for column \'cpq_price_rule.condition_json\'.','2026-06-07 18:02:11',43),(2063562162547707906,'000000','CPQ定价规则',1,'org.dromara.cpq.pricing.controller.CpqPriceRuleController.add()','POST',1,'admin','管理员部门','/cpq/pricing/rule','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceRuleId\":null,\"ruleName\":\"eeee\",\"ruleType\":\"DISCOUNT\",\"priority\":4,\"conditionJson\":\"\",\"actionJson\":\"\",\"approvalThreshold\":null,\"effectiveDate\":\"2026-06-07 00:00:00\",\"expiryDate\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Invalid JSON text: \"The document is empty.\" at position 0 in value for column \'cpq_price_rule.condition_json\'.\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqPriceRuleMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqPriceRuleMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_price_rule (price_rule_id, rule_name, rule_type, priority, condition_json, action_json, effective_date, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Invalid JSON text: \"The document is empty.\" at position 0 in value for column \'cpq_price_rule.condition_json\'.\n; Data truncation: Invalid JSON text: \"The document is empty.\" at position 0 in value for column \'cpq_price_rule.condition_json\'.','2026-06-07 18:02:13',8),(2063562224099119106,'000000','CPQ渠道价格',1,'org.dromara.cpq.pricing.controller.CpqChannelPriceController.add()','POST',1,'admin','管理员部门','/cpq/pricing/channelprice','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"channelPriceId\":null,\"channelCode\":\"wwww111\",\"modelId\":1,\"channelListPrice\":\"0\",\"channelDiscountPct\":null,\"effectiveDate\":\"2026-06-07 00:00:00\",\"expiryDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 18:02:28',17),(2063562323919360001,'000000','CPQ阶梯定价',2,'org.dromara.cpq.pricing.controller.CpqVolumeTierController.edit()','PUT',1,'admin','管理员部门','/cpq/pricing/volumetier','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":\"2026-06-07 17:32:11\",\"updateBy\":null,\"updateTime\":\"2026-06-07 17:32:11\",\"tenantId\":\"000000\",\"tierId\":\"2063554601245200386\",\"priceBookEntryId\":1,\"minQuantity\":\"2000\",\"maxQuantity\":null,\"unitPrice\":\"0\",\"sortOrder\":0}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 18:02:52',39),(2063562402805829634,'000000','CPQ阶梯定价',2,'org.dromara.cpq.pricing.controller.CpqVolumeTierController.edit()','PUT',1,'admin','管理员部门','/cpq/pricing/volumetier','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":\"2026-06-07 17:32:11\",\"updateBy\":null,\"updateTime\":\"2026-06-07 18:02:52\",\"tenantId\":\"000000\",\"tierId\":\"2063554601245200386\",\"priceBookEntryId\":1,\"minQuantity\":\"2000.0000\",\"maxQuantity\":null,\"unitPrice\":\"50\",\"sortOrder\":0}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 18:03:11',33),(2063562466550861825,'000000','CPQ阶梯定价',2,'org.dromara.cpq.pricing.controller.CpqVolumeTierController.edit()','PUT',1,'admin','管理员部门','/cpq/pricing/volumetier','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":\"2026-06-07 11:34:44\",\"updateBy\":null,\"updateTime\":\"2026-06-07 11:34:44\",\"tenantId\":\"000000\",\"tierId\":\"2063464648792330242\",\"priceBookEntryId\":1,\"minQuantity\":\"100\",\"maxQuantity\":\"200.0000\",\"unitPrice\":\"85.00\",\"sortOrder\":0}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 18:03:26',13),(2063562540848762881,'000000','CPQ阶梯定价',2,'org.dromara.cpq.pricing.controller.CpqVolumeTierController.edit()','PUT',1,'admin','管理员部门','/cpq/pricing/volumetier','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":\"2026-06-07 17:32:03\",\"updateBy\":null,\"updateTime\":\"2026-06-07 17:32:03\",\"tenantId\":\"000000\",\"tierId\":\"2063554568076644354\",\"priceBookEntryId\":1333,\"minQuantity\":\"50\",\"maxQuantity\":\"99\",\"unitPrice\":\"10000\",\"sortOrder\":0}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 18:03:44',16),(2063562574076039170,'000000','CPQ阶梯定价',2,'org.dromara.cpq.pricing.controller.CpqVolumeTierController.edit()','PUT',1,'admin','管理员部门','/cpq/pricing/volumetier','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":\"2026-06-07 17:32:03\",\"updateBy\":null,\"updateTime\":\"2026-06-07 18:03:44\",\"tenantId\":\"000000\",\"tierId\":\"2063554568076644354\",\"priceBookEntryId\":1333,\"minQuantity\":\"50.0000\",\"maxQuantity\":\"99.0000\",\"unitPrice\":\"100\",\"sortOrder\":0}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 18:03:51',20),(2063562641608527874,'000000','CPQ阶梯定价',2,'org.dromara.cpq.pricing.controller.CpqVolumeTierController.edit()','PUT',1,'admin','管理员部门','/cpq/pricing/volumetier','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":\"2026-06-07 17:19:39\",\"updateBy\":null,\"updateTime\":\"2026-06-07 17:19:39\",\"tenantId\":\"000000\",\"tierId\":\"2063551447619325954\",\"priceBookEntryId\":12,\"minQuantity\":\"1\",\"maxQuantity\":\"49\",\"unitPrice\":\"160\",\"sortOrder\":0}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 18:04:08',51),(2063563338001403906,'000000','CPQ汇率',2,'org.dromara.cpq.pricing.controller.CpqCurrencyRateController.edit()','PUT',1,'admin','管理员部门','/cpq/pricing/currencyrate','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":\"2026-06-07 11:34:44\",\"updateBy\":null,\"updateTime\":\"2026-06-07 11:37:16\",\"tenantId\":\"000000\",\"rateId\":\"2063464649291452418\",\"fromCurrency\":\"USD\",\"toCurrency\":\"CNY\",\"exchangeRate\":\"7.21\",\"effectiveDate\":\"2026-06-07 00:00:00\",\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 18:06:54',30),(2063569583701741569,'000000','CPQ渠道价格',2,'org.dromara.cpq.pricing.controller.CpqChannelPriceController.edit()','PUT',1,'admin','管理员部门','/cpq/pricing/channelprice','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":\"2026-06-07 18:02:28\",\"updateBy\":null,\"updateTime\":\"2026-06-07 18:02:28\",\"tenantId\":\"000000\",\"channelPriceId\":\"2063562224023621634\",\"channelCode\":\"wwww1113\",\"modelId\":1,\"channelListPrice\":\"0\",\"channelDiscountPct\":null,\"effectiveDate\":\"2026-06-07 00:00:00\",\"expiryDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 18:31:43',46),(2063572090339446785,'000000','CPQ价格手册条目',1,'org.dromara.cpq.pricing.controller.CpqPriceBookEntryController.add()','POST',1,'admin','管理员部门','/cpq/pricing/entry','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"entryId\":null,\"priceBookId\":\"2063560298246688769\",\"modelId\":1003,\"itemCode\":\"RW-ARC-200P\",\"regionCode\":\"\",\"channelCode\":\"\",\"listPrice\":\"0\",\"costPrice\":null,\"minPrice\":null,\"effectiveDate\":\"2026-06-07 00:00:00\",\"expiryDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 18:41:40',13),(2063572272321908738,'000000','CPQ价格手册条目',2,'org.dromara.cpq.pricing.controller.CpqPriceBookEntryController.edit()','PUT',1,'admin','管理员部门','/cpq/pricing/entry','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":\"2026-06-07 18:41:40\",\"updateBy\":null,\"updateTime\":\"2026-06-07 18:41:40\",\"tenantId\":\"000000\",\"entryId\":\"2063572090289115138\",\"priceBookId\":\"2063560298246688769\",\"modelId\":1006,\"itemCode\":\"RW-ARC-200P\",\"regionCode\":\"\",\"channelCode\":\"\",\"listPrice\":\"0\",\"costPrice\":null,\"minPrice\":null,\"effectiveDate\":\"2026-06-07 00:00:00\",\"expiryDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 18:42:24',15),(2063572351988518914,'000000','CPQ渠道价格',1,'org.dromara.cpq.pricing.controller.CpqChannelPriceController.add()','POST',1,'admin','管理员部门','/cpq/pricing/channelprice','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"channelPriceId\":null,\"channelCode\":\"223333\",\"modelId\":1002,\"channelListPrice\":\"0\",\"channelDiscountPct\":null,\"effectiveDate\":\"2026-06-07 00:00:00\",\"expiryDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 18:42:43',7),(2063572443659227137,'000000','CPQ定价规则',1,'org.dromara.cpq.pricing.controller.CpqPriceRuleController.add()','POST',1,'admin','管理员部门','/cpq/pricing/rule','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceRuleId\":null,\"ruleName\":\"2323\",\"ruleType\":\"DISCOUNT\",\"priority\":0,\"conditionJson\":\"\",\"actionJson\":\"\",\"approvalThreshold\":null,\"effectiveDate\":\"2026-06-07 00:00:00\",\"expiryDate\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Invalid JSON text: \"The document is empty.\" at position 0 in value for column \'cpq_price_rule.condition_json\'.\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqPriceRuleMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqPriceRuleMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_price_rule (price_rule_id, rule_name, rule_type, priority, condition_json, action_json, effective_date, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Invalid JSON text: \"The document is empty.\" at position 0 in value for column \'cpq_price_rule.condition_json\'.\n; Data truncation: Invalid JSON text: \"The document is empty.\" at position 0 in value for column \'cpq_price_rule.condition_json\'.','2026-06-07 18:43:05',6),(2063572489037402113,'000000','CPQ定价规则',1,'org.dromara.cpq.pricing.controller.CpqPriceRuleController.add()','POST',1,'admin','管理员部门','/cpq/pricing/rule','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceRuleId\":null,\"ruleName\":\"323\",\"ruleType\":\"DISCOUNT\",\"priority\":0,\"conditionJson\":\"\",\"actionJson\":\"\",\"approvalThreshold\":null,\"effectiveDate\":\"2026-06-07 00:00:00\",\"expiryDate\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Invalid JSON text: \"The document is empty.\" at position 0 in value for column \'cpq_price_rule.condition_json\'.\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqPriceRuleMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqPriceRuleMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_price_rule (price_rule_id, rule_name, rule_type, priority, condition_json, action_json, effective_date, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Invalid JSON text: \"The document is empty.\" at position 0 in value for column \'cpq_price_rule.condition_json\'.\n; Data truncation: Invalid JSON text: \"The document is empty.\" at position 0 in value for column \'cpq_price_rule.condition_json\'.','2026-06-07 18:43:15',7),(2063576326972362753,'000000','CPQ定价规则',1,'org.dromara.cpq.pricing.controller.CpqPriceRuleController.add()','POST',1,'admin','管理员部门','/cpq/pricing/rule','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceRuleId\":null,\"ruleName\":\"5566\",\"ruleType\":\"DISCOUNT\",\"priority\":0,\"conditionJson\":null,\"actionJson\":\"{}\",\"approvalThreshold\":null,\"effectiveDate\":\"2026-06-07 00:00:00\",\"expiryDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 18:58:30',17),(2063597634351235073,'000000','CPQ产品变体',1,'org.dromara.cpq.controller.CpqProductVariantController.add()','POST',1,'admin','管理员部门','/cpq/product/variant','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"variantId\":null,\"modelId\":1040,\"variantCode\":\"SWEEP-S1-PRO-WH\",\"variantName\":\"SweepBot S1 Pro 白色款\",\"attributes\":\"{\\\"颜色\\\":\\\"珍珠白\\\",\\\"基站版本\\\":\\\"全能基站(集尘+烘干)\\\"}\",\"defaultBomId\":null,\"basePrice\":\"4999\",\"thumbnailUrl\":null,\"isDefault\":\"1\",\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLSyntaxErrorException: Table \'ruoyi_cpq.cpq_product_variant\' doesn\'t exist\n### The error may exist in org/dromara/cpq/mapper/CpqProductVariantMapper.java (best guess)\n### The error may involve org.dromara.cpq.mapper.CpqProductVariantMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_product_variant (variant_id, model_id, variant_code, variant_name, attributes, base_price, is_default, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLSyntaxErrorException: Table \'ruoyi_cpq.cpq_product_variant\' doesn\'t exist\n; bad SQL grammar []','2026-06-07 20:23:10',254),(2063598279691042818,'000000','CPQ产品变体',1,'org.dromara.cpq.controller.CpqProductVariantController.add()','POST',1,'admin','管理员部门','/cpq/product/variant','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"variantId\":null,\"modelId\":1040,\"variantCode\":\"SWEEP-S1P-CUSTOM\",\"variantName\":\"SweepBot S1 Pro 定制款\",\"attributes\":\"{\\\"颜色\\\":\\\"定制蓝\\\",\\\"基站版本\\\":\\\"全能基站\\\"}\",\"defaultBomId\":null,\"basePrice\":\"5499\",\"thumbnailUrl\":null,\"isDefault\":\"0\",\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 20:25:44',15),(2063598280018198529,'000000','CPQ产品变体',2,'org.dromara.cpq.controller.CpqProductVariantController.edit()','PUT',1,'admin','管理员部门','/cpq/product/variant','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"variantId\":2001,\"modelId\":1001,\"variantCode\":\"ARC-A-A-YW\",\"variantName\":\"SLAM ArcBot A 黄色(已更新)\",\"attributes\":\"{\\\"颜色\\\":\\\"工程黄\\\"}\",\"defaultBomId\":null,\"basePrice\":\"188000\",\"thumbnailUrl\":null,\"isDefault\":\"1\",\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 20:25:44',10),(2063598280529903618,'000000','CPQ产品变体',3,'org.dromara.cpq.controller.CpqProductVariantController.remove()','DELETE',1,'admin','管理员部门','/cpq/product/variant/2063598279632322562','0:0:0:0:0:0:0:1','内网IP','\"2063598279632322562\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 20:25:45',26),(2063598718243274753,'000000','CPQ价格手册条目',2,'org.dromara.cpq.pricing.controller.CpqPriceBookEntryController.edit()','PUT',1,'admin','管理员部门','/cpq/pricing/entry','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":\"2026-06-07 18:41:40\",\"updateBy\":null,\"updateTime\":\"2026-06-07 18:42:24\",\"tenantId\":\"000000\",\"entryId\":\"2063572090289115138\",\"priceBookId\":\"2063560298246688769\",\"modelId\":1001,\"variantId\":2003,\"itemCode\":\"RW-ARC-160-GRY\",\"regionCode\":\"\",\"channelCode\":\"\",\"listPrice\":\"185000.00\",\"costPrice\":null,\"minPrice\":null,\"effectiveDate\":\"2026-06-07 00:00:00\",\"expiryDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 20:27:29',19),(2063599166593400834,'000000','CPQ价格手册条目',1,'org.dromara.cpq.pricing.controller.CpqPriceBookEntryController.add()','POST',1,'admin','管理员部门','/cpq/pricing/entry','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"entryId\":null,\"priceBookId\":1,\"modelId\":1001,\"variantId\":2001,\"itemCode\":\"RW-ARC-160-YLW\",\"regionCode\":null,\"channelCode\":null,\"listPrice\":\"188000\",\"costPrice\":null,\"minPrice\":null,\"effectiveDate\":\"2026-06-07 00:00:00\",\"expiryDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 20:29:16',8),(2063599473310269442,'000000','CPQ定价规则',2,'org.dromara.cpq.pricing.controller.CpqPriceRuleController.edit()','PUT',1,'admin','管理员部门','/cpq/pricing/rule','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":\"2026-06-07 18:58:30\",\"updateBy\":null,\"updateTime\":\"2026-06-07 18:58:30\",\"tenantId\":\"000000\",\"priceRuleId\":\"2063576326905253889\",\"ruleName\":\"5566\",\"ruleType\":\"DISCOUNT\",\"priority\":0,\"conditionJson\":null,\"actionJson\":\"{}\",\"approvalThreshold\":null,\"effectiveDate\":\"2026-06-07 00:00:00\",\"expiryDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 20:30:29',19),(2063599848054554625,'000000','CPQ产品变体',1,'org.dromara.cpq.controller.CpqProductVariantController.add()','POST',1,'admin','管理员部门','/cpq/product/variant','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"variantId\":null,\"modelId\":1001,\"variantCode\":\"RW-ARC-160-RED\",\"variantName\":\"ARC-160 红色限量款\",\"attributes\":\"{\\\"颜色\\\":\\\"中国红\\\"}\",\"defaultBomId\":null,\"basePrice\":\"195000\",\"thumbnailUrl\":null,\"isDefault\":\"0\",\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 20:31:58',27),(2063600571194507266,'000000','CPQ价格手册条目',1,'org.dromara.cpq.pricing.controller.CpqPriceBookEntryController.add()','POST',1,'admin','管理员部门','/cpq/pricing/entry','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"entryId\":null,\"priceBookId\":\"2063560298246688769\",\"modelId\":1001,\"variantId\":2001,\"itemCode\":\"ARC-A-A-YW\",\"regionCode\":\"\",\"channelCode\":\"\",\"listPrice\":\"188000.00\",\"costPrice\":null,\"minPrice\":null,\"effectiveDate\":\"2026-06-07 00:00:00\",\"expiryDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-07 20:34:51',23),(2063655853442412545,'000000','CPQ配置规则',1,'org.dromara.cpq.config.controller.CpqConfigRuleController.add()','POST',1,'admin','管理员部门','/cpq/config/rule','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"ruleId\":null,\"ruleName\":\"测试规则\",\"ruleType\":\"VALIDATION\",\"modelId\":null,\"conditionExpr\":null,\"actionExpr\":null,\"errorMessage\":null,\"severity\":null,\"priority\":null,\"effectiveDate\":null,\"expiryDate\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'condition_expr\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/config/mapper/CpqConfigRuleMapper.java (best guess)\n### The error may involve org.dromara.cpq.config.mapper.CpqConfigRuleMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_config_rule (rule_id, rule_name, rule_type, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'condition_expr\' doesn\'t have a default value\n; Field \'condition_expr\' doesn\'t have a default value','2026-06-08 00:14:31',185),(2063657667030130690,'000000','CPQ配置规则',1,'org.dromara.cpq.config.controller.CpqConfigRuleController.add()','POST',1,'admin','管理员部门','/cpq/config/rule','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"ruleId\":null,\"ruleName\":\"测试规则\",\"ruleType\":\"VALIDATION\",\"modelId\":null,\"conditionExpr\":\"{\\\"color\\\":\\\"RED\\\"}\",\"actionExpr\":\"{\\\"block\\\":true}\",\"errorMessage\":\"错误\",\"severity\":\"ERROR\",\"priority\":10,\"effectiveDate\":\"2026-06-08 00:00:00\",\"expiryDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:21:43',47),(2063657675607482369,'000000','CPQ捆绑包',1,'org.dromara.cpq.config.controller.CpqBundleController.add()','POST',1,'admin','管理员部门','/cpq/product/bundle','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"bundleId\":null,\"modelId\":1,\"bundleType\":\"FIXED\",\"pricingStrategy\":\"BUNDLE_PRICE\",\"bundleDiscountPct\":\"10.0\",\"isActive\":\"1\",\"description\":\"测试捆绑包\",\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:21:45',13),(2063657677297786882,'000000','CPQ捆绑包',1,'org.dromara.cpq.config.controller.CpqBundleController.add()','POST',1,'admin','管理员部门','/cpq/product/bundle','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"bundleId\":null,\"modelId\":1,\"bundleType\":\"FIXED\",\"pricingStrategy\":\"BUNDLE_PRICE\",\"bundleDiscountPct\":\"10.0\",\"isActive\":\"1\",\"description\":\"FKG测试用\",\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:21:46',13),(2063657912531132417,'000000','CPQ配置规则',1,'org.dromara.cpq.config.controller.CpqConfigRuleController.add()','POST',1,'admin','管理员部门','/cpq/config/rule','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"ruleId\":null,\"ruleName\":\"测试规则\",\"ruleType\":\"VALIDATION\",\"modelId\":null,\"conditionExpr\":\"{\\\"color\\\":\\\"RED\\\"}\",\"actionExpr\":\"{\\\"block\\\":true}\",\"errorMessage\":\"错误\",\"severity\":\"ERROR\",\"priority\":10,\"effectiveDate\":\"2026-06-08 00:00:00\",\"expiryDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:22:42',15),(2063657913441296386,'000000','CPQ配置规则',2,'org.dromara.cpq.config.controller.CpqConfigRuleController.edit()','PUT',1,'admin','管理员部门','/cpq/config/rule','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"ruleId\":\"2063657912464023554\",\"ruleName\":\"测试规则-UPD\",\"ruleType\":\"VALIDATION\",\"modelId\":null,\"conditionExpr\":\"{}\",\"actionExpr\":\"{}\",\"errorMessage\":\"updated\",\"severity\":\"WARNING\",\"priority\":5,\"effectiveDate\":\"2026-06-08 00:00:00\",\"expiryDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:22:42',22),(2063657913797812225,'000000','CPQ配置规则',3,'org.dromara.cpq.config.controller.CpqConfigRuleController.remove()','DELETE',1,'admin','管理员部门','/cpq/config/rule/2063657912464023554','0:0:0:0:0:0:0:1','内网IP','\"2063657912464023554\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:22:42',18),(2063657914523426817,'000000','CPQ变体BOM',1,'org.dromara.cpq.config.controller.CpqVariantBomController.add()','POST',1,'admin','管理员部门','/cpq/config/variantbom','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"variantId\":null,\"modelId\":1,\"sbomLineId\":null,\"materialCode\":\"MAT001\",\"quantity\":\"2.0\",\"effectivityCondition\":\"{\\\"color\\\":\\\"RED\\\"}\",\"isDefault\":\"0\",\"sortOrder\":1}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:22:42',11),(2063657915479728130,'000000','CPQ变体BOM',2,'org.dromara.cpq.config.controller.CpqVariantBomController.edit()','PUT',1,'admin','管理员部门','/cpq/config/variantbom','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"variantId\":\"2063657914494066689\",\"modelId\":1,\"sbomLineId\":null,\"materialCode\":\"MAT001-UPD\",\"quantity\":\"3.0\",\"effectivityCondition\":\"{\\\"color\\\":\\\"BLUE\\\"}\",\"isDefault\":\"0\",\"sortOrder\":2}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:22:43',16),(2063657915773329410,'000000','CPQ变体BOM',3,'org.dromara.cpq.config.controller.CpqVariantBomController.remove()','DELETE',1,'admin','管理员部门','/cpq/config/variantbom/2063657914494066689','0:0:0:0:0:0:0:1','内网IP','\"2063657914494066689\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:22:43',9),(2063657916465389570,'000000','CPQ属性映射',1,'org.dromara.cpq.config.controller.CpqAttributeMappingController.add()','POST',1,'admin','管理员部门','/cpq/config/attributemapping','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"mappingId\":null,\"modelId\":1,\"attrName\":\"color\",\"attrValue\":\"RED\",\"materialCode\":\"MAT-RED\",\"sbomLineId\":null,\"conditionExpr\":\"T>100\",\"sortOrder\":1}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:22:43',12),(2063657917761429506,'000000','CPQ属性映射',2,'org.dromara.cpq.config.controller.CpqAttributeMappingController.edit()','PUT',1,'admin','管理员部门','/cpq/config/attributemapping','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"mappingId\":\"2063657916427640833\",\"modelId\":1,\"attrName\":\"color\",\"attrValue\":\"BLUE\",\"materialCode\":\"MAT-BLUE\",\"sbomLineId\":null,\"conditionExpr\":\"T<50\",\"sortOrder\":2}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:22:43',57),(2063657918143111169,'000000','CPQ属性映射',3,'org.dromara.cpq.config.controller.CpqAttributeMappingController.remove()','DELETE',1,'admin','管理员部门','/cpq/config/attributemapping/2063657916427640833','0:0:0:0:0:0:0:1','内网IP','\"2063657916427640833\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:22:43',11),(2063657919074246657,'000000','CPQ兼容性矩阵',1,'org.dromara.cpq.config.controller.CpqCompatibilityMatrixController.add()','POST',1,'admin','管理员部门','/cpq/config/compatibility','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"matrixId\":null,\"sourceProductId\":1,\"targetProductId\":2,\"compatibilityType\":\"MUTUAL_EXCLUSIVE\",\"conditionDesc\":\"互斥\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:22:43',17),(2063657920072491009,'000000','CPQ兼容性矩阵',2,'org.dromara.cpq.config.controller.CpqCompatibilityMatrixController.edit()','PUT',1,'admin','管理员部门','/cpq/config/compatibility','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"matrixId\":\"2063657919015526402\",\"sourceProductId\":1,\"targetProductId\":3,\"compatibilityType\":\"DEPENDENCY\",\"conditionDesc\":\"依赖\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:22:44',14),(2063657920340926466,'000000','CPQ兼容性矩阵',3,'org.dromara.cpq.config.controller.CpqCompatibilityMatrixController.remove()','DELETE',1,'admin','管理员部门','/cpq/config/compatibility/2063657919015526402','0:0:0:0:0:0:0:1','内网IP','\"2063657919015526402\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:22:44',7),(2063657921007820802,'000000','CPQ属性选项',1,'org.dromara.cpq.config.controller.CpqAttributeOptionController.add()','POST',1,'admin','管理员部门','/cpq/config/attributeoption','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionId\":null,\"modelId\":1,\"attrName\":\"color\",\"optionCode\":\"RED\",\"optionLabel\":\"红色\",\"optionValue\":\"#FF0000\",\"isDefault\":\"0\",\"sortOrder\":1}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:22:44',10),(2063657922022842369,'000000','CPQ属性选项',2,'org.dromara.cpq.config.controller.CpqAttributeOptionController.edit()','PUT',1,'admin','管理员部门','/cpq/config/attributeoption','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionId\":\"2063657920974266369\",\"modelId\":1,\"attrName\":\"color\",\"optionCode\":\"BLUE\",\"optionLabel\":\"蓝色\",\"optionValue\":\"#0000FF\",\"isDefault\":\"1\",\"sortOrder\":2}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:22:44',13),(2063657922370969601,'000000','CPQ属性选项',3,'org.dromara.cpq.config.controller.CpqAttributeOptionController.remove()','DELETE',1,'admin','管理员部门','/cpq/config/attributeoption/2063657920974266369','0:0:0:0:0:0:0:1','内网IP','\"2063657920974266369\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:22:44',16),(2063657922773622785,'000000','CPQ捆绑包',1,'org.dromara.cpq.config.controller.CpqBundleController.add()','POST',1,'admin','管理员部门','/cpq/product/bundle','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"bundleId\":null,\"modelId\":1,\"bundleType\":\"FIXED\",\"pricingStrategy\":\"BUNDLE_PRICE\",\"bundleDiscountPct\":\"10.0\",\"isActive\":\"1\",\"description\":\"FK测试\",\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:22:44',12),(2063657923805421569,'000000','CPQ捆绑包',1,'org.dromara.cpq.config.controller.CpqBundleController.add()','POST',1,'admin','管理员部门','/cpq/product/bundle','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"bundleId\":null,\"modelId\":1,\"bundleType\":\"CONFIGURABLE\",\"pricingStrategy\":\"SUM_COMPONENTS\",\"bundleDiscountPct\":\"15.0\",\"isActive\":\"1\",\"description\":\"测试捆绑包\",\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:22:45',12),(2063657924635893761,'000000','CPQ捆绑包',2,'org.dromara.cpq.config.controller.CpqBundleController.edit()','PUT',1,'admin','管理员部门','/cpq/product/bundle','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"bundleId\":\"2063657922723291138\",\"modelId\":1,\"bundleType\":\"CONFIGURABLE\",\"pricingStrategy\":\"SUM_COMPONENTS\",\"bundleDiscountPct\":\"15.0\",\"isActive\":\"1\",\"description\":\"更新捆绑包\",\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:22:45',18),(2063657925155987458,'000000','CPQ捆绑选项组',1,'org.dromara.cpq.config.controller.CpqBundleOptionGroupController.add()','POST',1,'admin','管理员部门','/cpq/product/bundleoptiongroup','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionGroupId\":null,\"bundleId\":\"2063657922723291138\",\"groupName\":\"测试组\",\"groupCode\":\"TEST\",\"minSelections\":1,\"maxSelections\":1,\"isRequired\":\"1\",\"sortOrder\":1,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:22:45',16),(2063657926175203330,'000000','CPQ捆绑选项组',1,'org.dromara.cpq.config.controller.CpqBundleOptionGroupController.add()','POST',1,'admin','管理员部门','/cpq/product/bundleoptiongroup','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionGroupId\":null,\"bundleId\":\"2063657922723291138\",\"groupName\":\"正式组\",\"groupCode\":\"PROD\",\"minSelections\":2,\"maxSelections\":3,\"isRequired\":\"1\",\"sortOrder\":2,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:22:45',15),(2063657926842097665,'000000','CPQ捆绑选项组',2,'org.dromara.cpq.config.controller.CpqBundleOptionGroupController.edit()','PUT',1,'admin','管理员部门','/cpq/product/bundleoptiongroup','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionGroupId\":\"2063657925105655810\",\"bundleId\":\"2063657922723291138\",\"groupName\":\"更新组\",\"groupCode\":\"UPD\",\"minSelections\":1,\"maxSelections\":2,\"isRequired\":\"0\",\"sortOrder\":3,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:22:45',10),(2063657927223779330,'000000','CPQ捆绑选项',1,'org.dromara.cpq.config.controller.CpqBundleOptionController.add()','POST',1,'admin','管理员部门','/cpq/product/bundleoption','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionId\":null,\"optionGroupId\":\"2063657925105655810\",\"componentModelId\":1,\"quantity\":\"1\",\"unit\":\"个\",\"isDefault\":\"1\",\"priceModifierType\":\"FIXED_AMOUNT\",\"priceModifierValue\":\"500.0\",\"sortOrder\":1,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:22:45',14),(2063657927894867969,'000000','CPQ捆绑选项',1,'org.dromara.cpq.config.controller.CpqBundleOptionController.add()','POST',1,'admin','管理员部门','/cpq/product/bundleoption','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionId\":null,\"optionGroupId\":\"2063657925105655810\",\"componentModelId\":2,\"quantity\":\"2\",\"unit\":\"套\",\"isDefault\":\"0\",\"priceModifierType\":\"PERCENT\",\"priceModifierValue\":\"15.0\",\"sortOrder\":2,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:22:46',6),(2063657928456904706,'000000','CPQ捆绑选项',2,'org.dromara.cpq.config.controller.CpqBundleOptionController.edit()','PUT',1,'admin','管理员部门','/cpq/product/bundleoption','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionId\":\"2063657927181836289\",\"optionGroupId\":\"2063657925105655810\",\"componentModelId\":2,\"quantity\":\"3\",\"unit\":\"套\",\"isDefault\":\"0\",\"priceModifierType\":\"PERCENT\",\"priceModifierValue\":\"20.0\",\"sortOrder\":3,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:22:46',11),(2063657928725340161,'000000','CPQ捆绑选项',3,'org.dromara.cpq.config.controller.CpqBundleOptionController.remove()','DELETE',1,'admin','管理员部门','/cpq/product/bundleoption/2063657927181836289','0:0:0:0:0:0:0:1','内网IP','\"2063657927181836289\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:22:46',7),(2063657929010552834,'000000','CPQ捆绑选项组',3,'org.dromara.cpq.config.controller.CpqBundleOptionGroupController.remove()','DELETE',1,'admin','管理员部门','/cpq/product/bundleoptiongroup/2063657925105655810','0:0:0:0:0:0:0:1','内网IP','\"2063657925105655810\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:22:46',9),(2063657929325125634,'000000','CPQ捆绑包',3,'org.dromara.cpq.config.controller.CpqBundleController.remove()','DELETE',1,'admin','管理员部门','/cpq/product/bundle/2063657922723291138','0:0:0:0:0:0:0:1','内网IP','\"2063657922723291138\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:22:46',12),(2063660797855768577,'000000','CPQ配置规则',2,'org.dromara.cpq.config.controller.CpqConfigRuleController.edit()','PUT',1,'admin','管理员部门','/cpq/config/rule','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":\"2026-06-08 00:21:43\",\"updateBy\":null,\"updateTime\":\"2026-06-08 00:21:43\",\"tenantId\":\"000000\",\"ruleId\":\"2063657666904301570\",\"ruleName\":\"测试规则1\",\"ruleType\":\"VALIDATION\",\"modelId\":null,\"conditionExpr\":\"{\\\"color\\\":\\\"RED\\\"}\",\"actionExpr\":\"{\\\"block\\\":true}\",\"errorMessage\":\"错误\",\"severity\":\"ERROR\",\"priority\":10,\"effectiveDate\":\"2026-06-08 00:00:00\",\"expiryDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 00:34:10',14),(2063947705830359042,'000000','CPQ产品',1,'org.dromara.cpq.controller.CpqProductModelController.add()','POST',1,'admin','管理员部门','/cpq/product/model','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"modelId\":null,\"catalogId\":null,\"categoryId\":null,\"modelCode\":\"ENG-TEST-001\",\"modelName\":\"引擎测试产品\",\"description\":null,\"lifecycleStatus\":null,\"successorModelId\":null,\"basePrice\":null,\"currency\":null,\"minOrderQty\":null,\"leadTimeDays\":null,\"configType\":null,\"defaultBomId\":null,\"thumbnailUrl\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'catalog_id\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/mapper/CpqProductModelMapper.java (best guess)\n### The error may involve org.dromara.cpq.mapper.CpqProductModelMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_product_model (model_id, model_code, model_name, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'catalog_id\' doesn\'t have a default value\n; Field \'catalog_id\' doesn\'t have a default value','2026-06-08 19:34:14',297),(2063947731763740674,'000000','CPQ产品',1,'org.dromara.cpq.controller.CpqProductModelController.add()','POST',1,'admin','管理员部门','/cpq/product/model','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"modelId\":null,\"catalogId\":null,\"categoryId\":null,\"modelCode\":\"ENG-TEST-001\",\"modelName\":\"引擎测试产品\",\"description\":null,\"lifecycleStatus\":null,\"successorModelId\":null,\"basePrice\":null,\"currency\":null,\"minOrderQty\":null,\"leadTimeDays\":null,\"configType\":null,\"defaultBomId\":null,\"thumbnailUrl\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'catalog_id\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/mapper/CpqProductModelMapper.java (best guess)\n### The error may involve org.dromara.cpq.mapper.CpqProductModelMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_product_model (model_id, model_code, model_name, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'catalog_id\' doesn\'t have a default value\n; Field \'catalog_id\' doesn\'t have a default value','2026-06-08 19:34:20',20),(2063947766328999937,'000000','CPQ产品',1,'org.dromara.cpq.controller.CpqProductModelController.add()','POST',1,'admin','管理员部门','/cpq/product/model','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"modelId\":null,\"catalogId\":null,\"categoryId\":null,\"modelCode\":\"ENG-TEST-001\",\"modelName\":\"引擎测试产品\",\"description\":null,\"lifecycleStatus\":null,\"successorModelId\":null,\"basePrice\":null,\"currency\":null,\"minOrderQty\":null,\"leadTimeDays\":null,\"configType\":null,\"defaultBomId\":null,\"thumbnailUrl\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'catalog_id\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/mapper/CpqProductModelMapper.java (best guess)\n### The error may involve org.dromara.cpq.mapper.CpqProductModelMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_product_model (model_id, model_code, model_name, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'catalog_id\' doesn\'t have a default value\n; Field \'catalog_id\' doesn\'t have a default value','2026-06-08 19:34:28',19),(2063947990845898754,'000000','CPQ产品目录',1,'org.dromara.cpq.controller.CpqProductCatalogController.add()','POST',1,'admin','管理员部门','/cpq/product/catalog','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"catalogId\":null,\"catalogName\":\"测试目录\",\"catalogType\":null,\"effectiveDate\":null,\"expiryDate\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'catalog_type\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/mapper/CpqProductCatalogMapper.java (best guess)\n### The error may involve org.dromara.cpq.mapper.CpqProductCatalogMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_product_catalog (catalog_id, catalog_name, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'catalog_type\' doesn\'t have a default value\n; Field \'catalog_type\' doesn\'t have a default value','2026-06-08 19:35:22',27),(2063949031243005954,'000000','CPQ产品',1,'org.dromara.cpq.controller.CpqProductModelController.add()','POST',1,'admin','管理员部门','/cpq/product/model','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"modelId\":null,\"catalogId\":1,\"categoryId\":null,\"modelCode\":\"ENG-TEST-002\",\"modelName\":\"引擎测试产品\",\"description\":null,\"lifecycleStatus\":null,\"successorModelId\":null,\"basePrice\":null,\"currency\":null,\"minOrderQty\":null,\"leadTimeDays\":null,\"configType\":null,\"defaultBomId\":null,\"thumbnailUrl\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'category_id\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/mapper/CpqProductModelMapper.java (best guess)\n### The error may involve org.dromara.cpq.mapper.CpqProductModelMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_product_model (model_id, catalog_id, model_code, model_name, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'category_id\' doesn\'t have a default value\n; Field \'category_id\' doesn\'t have a default value','2026-06-08 19:39:30',13),(2063949166794522626,'000000','CPQ属性选项',1,'org.dromara.cpq.config.controller.CpqAttributeOptionController.add()','POST',1,'admin','管理员部门','/cpq/config/attributeoption','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionId\":null,\"modelId\":1001,\"attrName\":\"颜色\",\"optionCode\":\"WHITE\",\"optionLabel\":\"珍珠白\",\"optionValue\":\"珍珠白\",\"isDefault\":\"1\",\"sortOrder\":1}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 19:40:02',39),(2063949167230730242,'000000','CPQ属性选项',1,'org.dromara.cpq.config.controller.CpqAttributeOptionController.add()','POST',1,'admin','管理员部门','/cpq/config/attributeoption','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionId\":null,\"modelId\":1001,\"attrName\":\"颜色\",\"optionCode\":\"BLACK\",\"optionLabel\":\"曜石黑\",\"optionValue\":\"曜石黑\",\"isDefault\":\"0\",\"sortOrder\":2}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 19:40:02',12),(2063949167616606210,'000000','CPQ属性选项',1,'org.dromara.cpq.config.controller.CpqAttributeOptionController.add()','POST',1,'admin','管理员部门','/cpq/config/attributeoption','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionId\":null,\"modelId\":1001,\"attrName\":\"基站版本\",\"optionCode\":\"STD\",\"optionLabel\":\"标准洗拖布基站\",\"optionValue\":\"标准洗拖布基站\",\"isDefault\":\"1\",\"sortOrder\":1}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 19:40:03',14),(2063949167943761921,'000000','CPQ属性选项',1,'org.dromara.cpq.config.controller.CpqAttributeOptionController.add()','POST',1,'admin','管理员部门','/cpq/config/attributeoption','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionId\":null,\"modelId\":1001,\"attrName\":\"基站版本\",\"optionCode\":\"PRO\",\"optionLabel\":\"全能基站\",\"optionValue\":\"全能基站\",\"isDefault\":\"0\",\"sortOrder\":2}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 19:40:03',7),(2063949168379969538,'000000','CPQ配置规则',1,'org.dromara.cpq.config.controller.CpqConfigRuleController.add()','POST',1,'admin','管理员部门','/cpq/config/rule','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"ruleId\":null,\"ruleName\":\"颜色限制规则\",\"ruleType\":\"VALIDATION\",\"modelId\":1001,\"conditionExpr\":\"{\\\"颜色\\\":\\\"曜石黑\\\"}\",\"actionExpr\":\"{\\\"block\\\":true}\",\"errorMessage\":\"曜石黑不支持标准基站\",\"severity\":\"ERROR\",\"priority\":10,\"effectiveDate\":null,\"expiryDate\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/config/mapper/CpqConfigRuleMapper.java (best guess)\n### The error may involve org.dromara.cpq.config.mapper.CpqConfigRuleMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_config_rule (rule_id, rule_name, rule_type, model_id, condition_expr, action_expr, error_message, severity, priority, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n; Field \'effective_date\' doesn\'t have a default value','2026-06-08 19:40:03',18),(2063949324345163777,'000000','CPQ价格手册条目',1,'org.dromara.cpq.pricing.controller.CpqPriceBookEntryController.add()','POST',1,'admin','管理员部门','/cpq/pricing/entry','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"entryId\":null,\"priceBookId\":null,\"modelId\":1001,\"variantId\":null,\"itemCode\":null,\"regionCode\":null,\"channelCode\":null,\"listPrice\":\"1000.00\",\"costPrice\":\"600.00\",\"minPrice\":null,\"effectiveDate\":null,\"expiryDate\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'price_book_id\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqPriceBookEntryMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqPriceBookEntryMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_price_book_entry (entry_id, model_id, list_price, cost_price, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'price_book_id\' doesn\'t have a default value\n; Field \'price_book_id\' doesn\'t have a default value','2026-06-08 19:40:40',27),(2063949325490208770,'000000','CPQ配置规则',1,'org.dromara.cpq.config.controller.CpqConfigRuleController.add()','POST',1,'admin','管理员部门','/cpq/config/rule','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"ruleId\":null,\"ruleName\":\"颜色限制\",\"ruleType\":\"VALIDATION\",\"modelId\":1001,\"conditionExpr\":\"{\\\"颜色\\\":\\\"曜石黑\\\"}\",\"actionExpr\":\"{\\\"block\\\":true}\",\"errorMessage\":\"不兼容\",\"severity\":\"ERROR\",\"priority\":10,\"effectiveDate\":null,\"expiryDate\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/config/mapper/CpqConfigRuleMapper.java (best guess)\n### The error may involve org.dromara.cpq.config.mapper.CpqConfigRuleMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_config_rule (rule_id, rule_name, rule_type, model_id, condition_expr, action_expr, error_message, severity, priority, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'effective_date\' doesn\'t have a default value\n; Field \'effective_date\' doesn\'t have a default value','2026-06-08 19:40:40',19),(2063949506604449793,'000000','CPQ价格手册条目',1,'org.dromara.cpq.pricing.controller.CpqPriceBookEntryController.add()','POST',1,'admin','管理员部门','/cpq/pricing/entry','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"entryId\":null,\"priceBookId\":null,\"modelId\":1001,\"variantId\":null,\"itemCode\":null,\"regionCode\":null,\"channelCode\":null,\"listPrice\":\"1000.00\",\"costPrice\":\"600.00\",\"minPrice\":null,\"effectiveDate\":null,\"expiryDate\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'price_book_id\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/pricing/mapper/CpqPriceBookEntryMapper.java (best guess)\n### The error may involve org.dromara.cpq.pricing.mapper.CpqPriceBookEntryMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_price_book_entry (entry_id, model_id, list_price, cost_price, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'price_book_id\' doesn\'t have a default value\n; Field \'price_book_id\' doesn\'t have a default value','2026-06-08 19:41:23',28),(2063949507648831489,'000000','CPQ SBOM头',1,'org.dromara.cpq.controller.CpqSbomController.headerAdd()','POST',1,'admin','管理员部门','/cpq/product/sbom/header','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"sbomHeaderId\":null,\"modelId\":1001,\"sbomName\":\"测试SBOM\",\"sbomVersion\":\"1.0\",\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 19:41:24',21),(2063949508819042305,'000000','CPQ属性选项',1,'org.dromara.cpq.config.controller.CpqAttributeOptionController.add()','POST',1,'admin','管理员部门','/cpq/config/attributeoption','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionId\":null,\"modelId\":1001,\"attrName\":\"颜色\",\"optionCode\":\"WHITE\",\"optionLabel\":\"珍珠白\",\"optionValue\":\"珍珠白\",\"isDefault\":\"1\",\"sortOrder\":1}','',1,'\n### Error updating database.  Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'000000-1001-颜色-WHITE\' for key \'cpq_attribute_option.uk_attr_option\'\n### The error may exist in org/dromara/cpq/config/mapper/CpqAttributeOptionMapper.java (best guess)\n### The error may involve org.dromara.cpq.config.mapper.CpqAttributeOptionMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_attribute_option (option_id, model_id, attr_name, option_code, option_label, option_value, is_default, sort_order, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'000000-1001-颜色-WHITE\' for key \'cpq_attribute_option.uk_attr_option\'\n; Duplicate entry \'000000-1001-颜色-WHITE\' for key \'cpq_attribute_option.uk_attr_option\'','2026-06-08 19:41:24',13),(2063949509427216386,'000000','CPQ属性选项',1,'org.dromara.cpq.config.controller.CpqAttributeOptionController.add()','POST',1,'admin','管理员部门','/cpq/config/attributeoption','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionId\":null,\"modelId\":1001,\"attrName\":\"颜色\",\"optionCode\":\"BLACK\",\"optionLabel\":\"曜石黑\",\"optionValue\":\"曜石黑\",\"isDefault\":\"0\",\"sortOrder\":2}','',1,'\n### Error updating database.  Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'000000-1001-颜色-BLACK\' for key \'cpq_attribute_option.uk_attr_option\'\n### The error may exist in org/dromara/cpq/config/mapper/CpqAttributeOptionMapper.java (best guess)\n### The error may involve org.dromara.cpq.config.mapper.CpqAttributeOptionMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_attribute_option (option_id, model_id, attr_name, option_code, option_label, option_value, is_default, sort_order, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'000000-1001-颜色-BLACK\' for key \'cpq_attribute_option.uk_attr_option\'\n; Duplicate entry \'000000-1001-颜色-BLACK\' for key \'cpq_attribute_option.uk_attr_option\'','2026-06-08 19:41:24',19),(2063949509951504385,'000000','CPQ属性选项',1,'org.dromara.cpq.config.controller.CpqAttributeOptionController.add()','POST',1,'admin','管理员部门','/cpq/config/attributeoption','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionId\":null,\"modelId\":1001,\"attrName\":\"基站版本\",\"optionCode\":\"STD\",\"optionLabel\":\"标准版\",\"optionValue\":\"标准版\",\"isDefault\":\"1\",\"sortOrder\":1}','',1,'\n### Error updating database.  Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'000000-1001-基站版本-STD\' for key \'cpq_attribute_option.uk_attr_option\'\n### The error may exist in org/dromara/cpq/config/mapper/CpqAttributeOptionMapper.java (best guess)\n### The error may involve org.dromara.cpq.config.mapper.CpqAttributeOptionMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_attribute_option (option_id, model_id, attr_name, option_code, option_label, option_value, is_default, sort_order, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'000000-1001-基站版本-STD\' for key \'cpq_attribute_option.uk_attr_option\'\n; Duplicate entry \'000000-1001-基站版本-STD\' for key \'cpq_attribute_option.uk_attr_option\'','2026-06-08 19:41:24',18),(2063949510433849345,'000000','CPQ属性选项',1,'org.dromara.cpq.config.controller.CpqAttributeOptionController.add()','POST',1,'admin','管理员部门','/cpq/config/attributeoption','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionId\":null,\"modelId\":1001,\"attrName\":\"基站版本\",\"optionCode\":\"PRO\",\"optionLabel\":\"全能版\",\"optionValue\":\"全能版\",\"isDefault\":\"0\",\"sortOrder\":2}','',1,'\n### Error updating database.  Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'000000-1001-基站版本-PRO\' for key \'cpq_attribute_option.uk_attr_option\'\n### The error may exist in org/dromara/cpq/config/mapper/CpqAttributeOptionMapper.java (best guess)\n### The error may involve org.dromara.cpq.config.mapper.CpqAttributeOptionMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_attribute_option (option_id, model_id, attr_name, option_code, option_label, option_value, is_default, sort_order, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'000000-1001-基站版本-PRO\' for key \'cpq_attribute_option.uk_attr_option\'\n; Duplicate entry \'000000-1001-基站版本-PRO\' for key \'cpq_attribute_option.uk_attr_option\'','2026-06-08 19:41:24',16),(2063949512195457025,'000000','CPQ配置规则',1,'org.dromara.cpq.config.controller.CpqConfigRuleController.add()','POST',1,'admin','管理员部门','/cpq/config/rule','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"ruleId\":null,\"ruleName\":\"颜色限制规则\",\"ruleType\":\"VALIDATION\",\"modelId\":1001,\"conditionExpr\":\"{\\\"颜色\\\":\\\"曜石黑\\\"}\",\"actionExpr\":\"{\\\"block\\\":true}\",\"errorMessage\":\"曜石黑与当前配置不兼容\",\"severity\":\"ERROR\",\"priority\":10,\"effectiveDate\":\"2026-01-01 00:00:00\",\"expiryDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 19:41:25',19),(2063954159924690945,'000000','CPQ配置规则',1,'org.dromara.cpq.config.controller.CpqConfigRuleController.add()','POST',1,'admin','管理员部门','/cpq/config/rule','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"ruleId\":null,\"ruleName\":\"e2e-test\",\"ruleType\":\"VALIDATION\",\"modelId\":1001,\"conditionExpr\":\"{\\\"x\\\":\\\"1\\\"}\",\"actionExpr\":\"{\\\"block\\\":true}\",\"errorMessage\":null,\"severity\":\"WARN\",\"priority\":1,\"effectiveDate\":\"2026-01-01 00:00:00\",\"expiryDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 19:59:53',23),(2063974719119441922,'000000','CPQ配置规则',1,'org.dromara.cpq.config.controller.CpqConfigRuleController.add()','POST',1,'admin','管理员部门','/cpq/config/rule','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"ruleId\":null,\"ruleName\":\"S4规则1780924894\",\"ruleType\":\"VALIDATION\",\"modelId\":null,\"conditionExpr\":null,\"actionExpr\":null,\"errorMessage\":null,\"severity\":null,\"priority\":1,\"effectiveDate\":\"2026-01-01 00:00:00\",\"expiryDate\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'condition_expr\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/config/mapper/CpqConfigRuleMapper.java (best guess)\n### The error may involve org.dromara.cpq.config.mapper.CpqConfigRuleMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_config_rule (rule_id, rule_name, rule_type, priority, effective_date, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'condition_expr\' doesn\'t have a default value\n; Field \'condition_expr\' doesn\'t have a default value','2026-06-08 21:21:34',12),(2063974719836667905,'000000','CPQ变体BOM',1,'org.dromara.cpq.config.controller.CpqVariantBomController.add()','POST',1,'admin','管理员部门','/cpq/config/variantbom','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"variantId\":null,\"modelId\":1001,\"sbomLineId\":null,\"materialCode\":null,\"quantity\":null,\"effectivityCondition\":null,\"isDefault\":null,\"sortOrder\":null}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'material_code\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/config/mapper/CpqVariantBomMapper.java (best guess)\n### The error may involve org.dromara.cpq.config.mapper.CpqVariantBomMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_variant_bom (variant_id, model_id, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'material_code\' doesn\'t have a default value\n; Field \'material_code\' doesn\'t have a default value','2026-06-08 21:21:35',13),(2063974720587448322,'000000','CPQ属性映射',1,'org.dromara.cpq.config.controller.CpqAttributeMappingController.add()','POST',1,'admin','管理员部门','/cpq/config/attributemapping','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"mappingId\":null,\"modelId\":null,\"attrName\":null,\"attrValue\":null,\"materialCode\":null,\"sbomLineId\":null,\"conditionExpr\":null,\"sortOrder\":null}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'model_id\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/config/mapper/CpqAttributeMappingMapper.java (best guess)\n### The error may involve org.dromara.cpq.config.mapper.CpqAttributeMappingMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_attribute_mapping (mapping_id, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'model_id\' doesn\'t have a default value\n; Field \'model_id\' doesn\'t have a default value','2026-06-08 21:21:35',23),(2063974721380171777,'000000','CPQ兼容性矩阵',1,'org.dromara.cpq.config.controller.CpqCompatibilityMatrixController.add()','POST',1,'admin','管理员部门','/cpq/config/compatibility','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"matrixId\":null,\"sourceProductId\":null,\"targetProductId\":null,\"compatibilityType\":null,\"conditionDesc\":null}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'source_product_id\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/config/mapper/CpqCompatibilityMatrixMapper.java (best guess)\n### The error may involve org.dromara.cpq.config.mapper.CpqCompatibilityMatrixMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_compatibility_matrix (matrix_id, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'source_product_id\' doesn\'t have a default value\n; Field \'source_product_id\' doesn\'t have a default value','2026-06-08 21:21:35',14),(2063974721950597122,'000000','CPQ属性选项',1,'org.dromara.cpq.config.controller.CpqAttributeOptionController.add()','POST',1,'admin','管理员部门','/cpq/config/attributeoption','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionId\":null,\"modelId\":null,\"attrName\":null,\"optionCode\":\"S4AO_1780924894\",\"optionLabel\":null,\"optionValue\":null,\"isDefault\":null,\"sortOrder\":null}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'model_id\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/config/mapper/CpqAttributeOptionMapper.java (best guess)\n### The error may involve org.dromara.cpq.config.mapper.CpqAttributeOptionMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_attribute_option (option_id, option_code, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'model_id\' doesn\'t have a default value\n; Field \'model_id\' doesn\'t have a default value','2026-06-08 21:21:35',10),(2063974722449719297,'000000','CPQ捆绑包',1,'org.dromara.cpq.config.controller.CpqBundleController.add()','POST',1,'admin','管理员部门','/cpq/product/bundle','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"bundleId\":null,\"modelId\":null,\"bundleType\":null,\"pricingStrategy\":null,\"bundleDiscountPct\":null,\"isActive\":null,\"description\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'model_id\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/config/mapper/CpqBundleMapper.java (best guess)\n### The error may involve org.dromara.cpq.config.mapper.CpqBundleMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_bundle (bundle_id, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'model_id\' doesn\'t have a default value\n; Field \'model_id\' doesn\'t have a default value','2026-06-08 21:21:35',10),(2063974723238248449,'000000','CPQ捆绑选项组',1,'org.dromara.cpq.config.controller.CpqBundleOptionGroupController.add()','POST',1,'admin','管理员部门','/cpq/product/bundleoptiongroup','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionGroupId\":null,\"bundleId\":null,\"groupName\":\"S4组1780924894\",\"groupCode\":\"S4BOG_1780924894\",\"minSelections\":null,\"maxSelections\":null,\"isRequired\":null,\"sortOrder\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'bundle_id\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/config/mapper/CpqBundleOptionGroupMapper.java (best guess)\n### The error may involve org.dromara.cpq.config.mapper.CpqBundleOptionGroupMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_bundle_option_group (option_group_id, group_name, group_code, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'bundle_id\' doesn\'t have a default value\n; Field \'bundle_id\' doesn\'t have a default value','2026-06-08 21:21:35',14),(2063974723775119362,'000000','CPQ捆绑选项',1,'org.dromara.cpq.config.controller.CpqBundleOptionController.add()','POST',1,'admin','管理员部门','/cpq/product/bundleoption','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionId\":null,\"optionGroupId\":null,\"componentModelId\":null,\"quantity\":null,\"unit\":null,\"isDefault\":null,\"priceModifierType\":null,\"priceModifierValue\":null,\"sortOrder\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'option_group_id\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/config/mapper/CpqBundleOptionMapper.java (best guess)\n### The error may involve org.dromara.cpq.config.mapper.CpqBundleOptionMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_bundle_option (option_id, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'option_group_id\' doesn\'t have a default value\n; Field \'option_group_id\' doesn\'t have a default value','2026-06-08 21:21:36',9),(2063975956535590914,'000000','CPQ配置规则',1,'org.dromara.cpq.config.controller.CpqConfigRuleController.add()','POST',1,'admin','管理员部门','/cpq/config/rule','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"ruleId\":null,\"ruleName\":\"S4规则1780925189\",\"ruleType\":\"VALIDATION\",\"modelId\":null,\"conditionExpr\":\"color==RED\",\"actionExpr\":\"APPLY_DISCOUNT(0.1)\",\"errorMessage\":null,\"severity\":null,\"priority\":1,\"effectiveDate\":\"2026-01-01 00:00:00\",\"expiryDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:26:30',10),(2063975956908883969,'000000','CPQ变体BOM',1,'org.dromara.cpq.config.controller.CpqVariantBomController.add()','POST',1,'admin','管理员部门','/cpq/config/variantbom','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"variantId\":null,\"modelId\":1001,\"sbomLineId\":null,\"materialCode\":\"MAT-VB1780925189\",\"quantity\":\"10\",\"effectivityCondition\":\"{}\",\"isDefault\":null,\"sortOrder\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:26:30',5),(2063975957303148546,'000000','CPQ属性映射',1,'org.dromara.cpq.config.controller.CpqAttributeMappingController.add()','POST',1,'admin','管理员部门','/cpq/config/attributemapping','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"mappingId\":null,\"modelId\":1001,\"attrName\":\"颜色1780925189\",\"attrValue\":\"红1780925189\",\"materialCode\":\"MAT-AM1780925189\",\"sbomLineId\":null,\"conditionExpr\":null,\"sortOrder\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:26:30',5),(2063975957709996033,'000000','CPQ兼容性矩阵',1,'org.dromara.cpq.config.controller.CpqCompatibilityMatrixController.add()','POST',1,'admin','管理员部门','/cpq/config/compatibility','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"matrixId\":null,\"sourceProductId\":1001,\"targetProductId\":1002,\"compatibilityType\":\"MUTUAL_EXCLUSIVE\",\"conditionDesc\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:26:30',6),(2063975958074900481,'000000','CPQ属性选项',1,'org.dromara.cpq.config.controller.CpqAttributeOptionController.add()','POST',1,'admin','管理员部门','/cpq/config/attributeoption','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionId\":null,\"modelId\":1001,\"attrName\":\"颜色1780925189\",\"optionCode\":\"COL-R1780925189\",\"optionLabel\":\"红1780925189\",\"optionValue\":null,\"isDefault\":null,\"sortOrder\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:26:30',6),(2063975958506913793,'000000','CPQ捆绑包',1,'org.dromara.cpq.config.controller.CpqBundleController.add()','POST',1,'admin','管理员部门','/cpq/product/bundle','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"bundleId\":null,\"modelId\":null,\"bundleType\":null,\"pricingStrategy\":null,\"bundleDiscountPct\":null,\"isActive\":null,\"description\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'model_id\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/config/mapper/CpqBundleMapper.java (best guess)\n### The error may involve org.dromara.cpq.config.mapper.CpqBundleMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_bundle (bundle_id, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'model_id\' doesn\'t have a default value\n; Field \'model_id\' doesn\'t have a default value','2026-06-08 21:26:30',8),(2063975959056367617,'000000','CPQ捆绑选项组',1,'org.dromara.cpq.config.controller.CpqBundleOptionGroupController.add()','POST',1,'admin','管理员部门','/cpq/product/bundleoptiongroup','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionGroupId\":null,\"bundleId\":null,\"groupName\":\"选项组1780925189\",\"groupCode\":\"BOG1780925189\",\"minSelections\":null,\"maxSelections\":null,\"isRequired\":null,\"sortOrder\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'bundle_id\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/config/mapper/CpqBundleOptionGroupMapper.java (best guess)\n### The error may involve org.dromara.cpq.config.mapper.CpqBundleOptionGroupMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_bundle_option_group (option_group_id, group_name, group_code, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'bundle_id\' doesn\'t have a default value\n; Field \'bundle_id\' doesn\'t have a default value','2026-06-08 21:26:30',8),(2063975959421272066,'000000','CPQ捆绑选项',1,'org.dromara.cpq.config.controller.CpqBundleOptionController.add()','POST',1,'admin','管理员部门','/cpq/product/bundleoption','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionId\":null,\"optionGroupId\":null,\"componentModelId\":null,\"quantity\":null,\"unit\":null,\"isDefault\":null,\"priceModifierType\":null,\"priceModifierValue\":null,\"sortOrder\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'option_group_id\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/config/mapper/CpqBundleOptionMapper.java (best guess)\n### The error may involve org.dromara.cpq.config.mapper.CpqBundleOptionMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_bundle_option (option_id, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'option_group_id\' doesn\'t have a default value\n; Field \'option_group_id\' doesn\'t have a default value','2026-06-08 21:26:30',3),(2063976152967430145,'000000','CPQ捆绑包',1,'org.dromara.cpq.config.controller.CpqBundleController.add()','POST',1,'admin','管理员部门','/cpq/product/bundle','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"bundleId\":null,\"modelId\":1001,\"bundleType\":\"FIXED\",\"pricingStrategy\":\"BUNDLE_PRICE\",\"bundleDiscountPct\":null,\"isActive\":\"1\",\"description\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:27:16',27),(2063976182579216385,'000000','CPQ捆绑包',1,'org.dromara.cpq.config.controller.CpqBundleController.add()','POST',1,'admin','管理员部门','/cpq/product/bundle','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"bundleId\":null,\"modelId\":1001,\"bundleType\":\"FIXED\",\"pricingStrategy\":\"BUNDLE_PRICE\",\"bundleDiscountPct\":null,\"isActive\":null,\"description\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:27:23',7),(2063976213000503298,'000000','CPQ捆绑选项组',1,'org.dromara.cpq.config.controller.CpqBundleOptionGroupController.add()','POST',1,'admin','管理员部门','/cpq/product/bundleoptiongroup','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionGroupId\":null,\"bundleId\":1,\"groupName\":\"选项组1780925250\",\"groupCode\":null,\"minSelections\":0,\"maxSelections\":1,\"isRequired\":null,\"sortOrder\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'group_code\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/config/mapper/CpqBundleOptionGroupMapper.java (best guess)\n### The error may involve org.dromara.cpq.config.mapper.CpqBundleOptionGroupMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_bundle_option_group (option_group_id, bundle_id, group_name, min_selections, max_selections, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'group_code\' doesn\'t have a default value\n; Field \'group_code\' doesn\'t have a default value','2026-06-08 21:27:31',6),(2063976213164081153,'000000','CPQ捆绑选项',1,'org.dromara.cpq.config.controller.CpqBundleOptionController.add()','POST',1,'admin','管理员部门','/cpq/product/bundleoption','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionId\":null,\"optionGroupId\":1,\"componentModelId\":1001,\"quantity\":\"1\",\"unit\":null,\"isDefault\":null,\"priceModifierType\":null,\"priceModifierValue\":null,\"sortOrder\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:27:31',16),(2063978955924324354,'000000','CPQ SBOM头',1,'org.dromara.cpq.controller.CpqSbomController.headerAdd()','POST',1,'admin','管理员部门','/cpq/product/sbom/header','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"sbomHeaderId\":null,\"modelId\":1001,\"sbomName\":\"ARC-160标准SBOM_TS\",\"sbomVersion\":\"1.0\",\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:38:25',31),(2063978957316833282,'000000','CPQ属性选项',1,'org.dromara.cpq.config.controller.CpqAttributeOptionController.add()','POST',1,'admin','管理员部门','/cpq/config/attributeoption','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionId\":null,\"modelId\":1001,\"attrName\":\"COLOR\",\"optionCode\":\"RED\",\"optionLabel\":\"红色\",\"optionValue\":null,\"isDefault\":null,\"sortOrder\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:38:25',11),(2063978957664960513,'000000','CPQ属性选项',1,'org.dromara.cpq.config.controller.CpqAttributeOptionController.add()','POST',1,'admin','管理员部门','/cpq/config/attributeoption','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionId\":null,\"modelId\":1001,\"attrName\":\"COLOR\",\"optionCode\":\"BLUE\",\"optionLabel\":\"蓝色\",\"optionValue\":null,\"isDefault\":null,\"sortOrder\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:38:25',10),(2063978958013087745,'000000','CPQ属性选项',1,'org.dromara.cpq.config.controller.CpqAttributeOptionController.add()','POST',1,'admin','管理员部门','/cpq/config/attributeoption','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionId\":null,\"modelId\":1001,\"attrName\":\"COLOR\",\"optionCode\":\"SILVER\",\"optionLabel\":\"银色\",\"optionValue\":null,\"isDefault\":null,\"sortOrder\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:38:25',12),(2063978958512209922,'000000','CPQ价格手册',1,'org.dromara.cpq.pricing.controller.CpqPriceBookController.add()','POST',1,'admin','管理员部门','/cpq/pricing/pricebook','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceBookId\":null,\"bookName\":\"标准价格手册_TS\",\"bookType\":\"STANDARD\",\"currency\":\"CNY\",\"effectiveDate\":\"2026-01-01 00:00:00\",\"expiryDate\":null,\"priority\":1,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:38:25',27),(2063978958818394114,'000000','CPQ捆绑包',1,'org.dromara.cpq.config.controller.CpqBundleController.add()','POST',1,'admin','管理员部门','/cpq/product/bundle','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"bundleId\":null,\"modelId\":1001,\"bundleType\":\"FIXED\",\"pricingStrategy\":\"BUNDLE_PRICE\",\"bundleDiscountPct\":null,\"isActive\":null,\"description\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:38:25',9),(2063979114888445953,'000000','CPQ SBOM头',1,'org.dromara.cpq.controller.CpqSbomController.headerAdd()','POST',1,'admin','管理员部门','/cpq/product/sbom/header','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"sbomHeaderId\":null,\"modelId\":1001,\"sbomName\":\"ARC-160标准SBOM_v1780925942\",\"sbomVersion\":\"1.0\",\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:39:03',36),(2063979119921610754,'000000','CPQ产品属性',1,'org.dromara.cpq.controller.CpqProductAttributeController.add()','POST',1,'admin','管理员部门','/cpq/product/attribute','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"attributeId\":null,\"modelId\":1001,\"attrCategory\":\"外观\",\"attrName\":\"COLOR\",\"attrValue\":\"RED\",\"isConfigurable\":\"1\",\"isRequired\":\"1\",\"displayOrder\":null,\"dataType\":\"ENUM\",\"optionValues\":\"[\\\"RED\\\",\\\"BLUE\\\",\\\"SILVER\\\"]\",\"sortOrder\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:39:04',42),(2063979120173268994,'000000','CPQ产品属性',1,'org.dromara.cpq.controller.CpqProductAttributeController.add()','POST',1,'admin','管理员部门','/cpq/product/attribute','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"attributeId\":null,\"modelId\":1001,\"attrCategory\":\"规格\",\"attrName\":\"SIZE\",\"attrValue\":\"STANDARD\",\"isConfigurable\":\"1\",\"isRequired\":\"0\",\"displayOrder\":null,\"dataType\":\"ENUM\",\"optionValues\":\"[\\\"STANDARD\\\",\\\"LARGE\\\",\\\"COMPACT\\\"]\",\"sortOrder\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:39:04',9),(2063979120416538625,'000000','CPQ属性选项',1,'org.dromara.cpq.config.controller.CpqAttributeOptionController.add()','POST',1,'admin','管理员部门','/cpq/config/attributeoption','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionId\":null,\"modelId\":1001,\"attrName\":\"COLOR\",\"optionCode\":\"RED2_1780925942\",\"optionLabel\":\"红色v2\",\"optionValue\":null,\"isDefault\":null,\"sortOrder\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:39:04',7),(2063979120693362689,'000000','CPQ属性选项',1,'org.dromara.cpq.config.controller.CpqAttributeOptionController.add()','POST',1,'admin','管理员部门','/cpq/config/attributeoption','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionId\":null,\"modelId\":1001,\"attrName\":\"COLOR\",\"optionCode\":\"BLUE2_1780925942\",\"optionLabel\":\"蓝色v2\",\"optionValue\":null,\"isDefault\":null,\"sortOrder\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:39:04',8),(2063979121083432961,'000000','CPQ价格手册',1,'org.dromara.cpq.pricing.controller.CpqPriceBookController.add()','POST',1,'admin','管理员部门','/cpq/pricing/pricebook','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"priceBookId\":null,\"bookName\":\"标准手册_1780925942\",\"bookType\":\"STANDARD\",\"currency\":\"CNY\",\"effectiveDate\":\"2026-01-01 00:00:00\",\"expiryDate\":null,\"priority\":1,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:39:04',12),(2063979125810413569,'000000','CPQ捆绑包',1,'org.dromara.cpq.config.controller.CpqBundleController.add()','POST',1,'admin','管理员部门','/cpq/product/bundle','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"bundleId\":null,\"modelId\":1001,\"bundleType\":\"FIXED\",\"pricingStrategy\":\"BUNDLE_PRICE\",\"bundleDiscountPct\":null,\"isActive\":null,\"description\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:39:05',7),(2063979195234533378,'000000','CPQ SBOM头',1,'org.dromara.cpq.controller.CpqSbomController.headerAdd()','POST',1,'admin','管理员部门','/cpq/product/sbom/header','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"sbomHeaderId\":null,\"modelId\":1001,\"sbomName\":\"DIRECT_TEST_1780925961\",\"sbomVersion\":\"1.0\",\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:39:22',14),(2063979552761200641,'000000','CPQ SBOM行',1,'org.dromara.cpq.controller.CpqSbomController.lineAdd()','POST',1,'admin','管理员部门','/cpq/product/sbom/line','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"sbomLineId\":null,\"sbomHeaderId\":\"2063979195180007426\",\"parentLineId\":null,\"lineNumber\":1,\"itemCode\":\"MAT-HOST-001\",\"itemName\":\"弧焊控制器\",\"itemType\":\"HOST\",\"quantity\":\"1\",\"unit\":null,\"isRequired\":\"1\",\"isReplaceable\":null,\"replacementGroup\":null,\"isPhantom\":null,\"minQty\":null,\"maxQty\":null,\"priceImpact\":null,\"leadTimeDays\":null,\"sortOrder\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:40:47',42),(2063979552954138625,'000000','CPQ SBOM行',1,'org.dromara.cpq.controller.CpqSbomController.lineAdd()','POST',1,'admin','管理员部门','/cpq/product/sbom/line','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"sbomLineId\":null,\"sbomHeaderId\":\"2063979195180007426\",\"parentLineId\":null,\"lineNumber\":2,\"itemCode\":\"MAT-ACC-001\",\"itemName\":\"焊枪总成\",\"itemType\":\"ACCESSORY\",\"quantity\":\"1\",\"unit\":null,\"isRequired\":\"1\",\"isReplaceable\":null,\"replacementGroup\":null,\"isPhantom\":null,\"minQty\":null,\"maxQty\":null,\"priceImpact\":null,\"leadTimeDays\":null,\"sortOrder\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:40:47',12),(2063979553398734850,'000000','CPQ价格手册条目',1,'org.dromara.cpq.pricing.controller.CpqPriceBookEntryController.add()','POST',1,'admin','管理员部门','/cpq/pricing/entry','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"entryId\":null,\"priceBookId\":\"2063979121028907010\",\"modelId\":1001,\"variantId\":null,\"itemCode\":null,\"regionCode\":null,\"channelCode\":null,\"listPrice\":\"185000.00\",\"costPrice\":\"120000.00\",\"minPrice\":\"150000.00\",\"effectiveDate\":\"2026-01-01 00:00:00\",\"expiryDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:40:47',13),(2063979557001641986,'000000','CPQ捆绑选项组',1,'org.dromara.cpq.config.controller.CpqBundleOptionGroupController.add()','POST',1,'admin','管理员部门','/cpq/product/bundleoptiongroup','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionGroupId\":null,\"bundleId\":\"2063979125776859137\",\"groupName\":\"焊接组件组\",\"groupCode\":null,\"minSelections\":1,\"maxSelections\":1,\"isRequired\":\"1\",\"sortOrder\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'group_code\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/config/mapper/CpqBundleOptionGroupMapper.java (best guess)\n### The error may involve org.dromara.cpq.config.mapper.CpqBundleOptionGroupMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_bundle_option_group (option_group_id, bundle_id, group_name, min_selections, max_selections, is_required, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'group_code\' doesn\'t have a default value\n; Field \'group_code\' doesn\'t have a default value','2026-06-08 21:40:48',13),(2063980553991897089,'000000','CPQ捆绑选项组',1,'org.dromara.cpq.config.controller.CpqBundleOptionGroupController.add()','POST',1,'admin','管理员部门','/cpq/product/bundleoptiongroup','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionGroupId\":null,\"bundleId\":\"2063979125776859137\",\"groupName\":\"焊接组件组\",\"groupCode\":null,\"minSelections\":1,\"maxSelections\":1,\"isRequired\":\"1\",\"sortOrder\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'group_code\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/config/mapper/CpqBundleOptionGroupMapper.java (best guess)\n### The error may involve org.dromara.cpq.config.mapper.CpqBundleOptionGroupMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_bundle_option_group (option_group_id, bundle_id, group_name, min_selections, max_selections, is_required, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'group_code\' doesn\'t have a default value\n; Field \'group_code\' doesn\'t have a default value','2026-06-08 21:44:46',14),(2063982553781518338,'000000','CPQ属性映射',1,'org.dromara.cpq.config.controller.CpqAttributeMappingController.add()','POST',1,'admin','管理员部门','/cpq/config/attributemapping','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"mappingId\":null,\"modelId\":1001,\"attrName\":\"COLOR\",\"attrValue\":\"RED\",\"materialCode\":\"MAT-RED-TEST\",\"sbomLineId\":\"2063979552677314562\",\"conditionExpr\":null,\"sortOrder\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:52:42',32),(2063982569719873538,'000000','CPQ捆绑选项组',1,'org.dromara.cpq.config.controller.CpqBundleOptionGroupController.add()','POST',1,'admin','管理员部门','/cpq/product/bundleoptiongroup','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionGroupId\":null,\"bundleId\":\"2063979125776859137\",\"groupName\":\"测试选项组_1780926766\",\"groupCode\":null,\"minSelections\":null,\"maxSelections\":null,\"isRequired\":null,\"sortOrder\":null,\"status\":null}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'group_code\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/config/mapper/CpqBundleOptionGroupMapper.java (best guess)\n### The error may involve org.dromara.cpq.config.mapper.CpqBundleOptionGroupMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_bundle_option_group (option_group_id, bundle_id, group_name, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'group_code\' doesn\'t have a default value\n; Field \'group_code\' doesn\'t have a default value','2026-06-08 21:52:46',33),(2063982607300837377,'000000','CPQ属性映射',1,'org.dromara.cpq.config.controller.CpqAttributeMappingController.add()','POST',1,'admin','管理员部门','/cpq/config/attributemapping','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"mappingId\":null,\"modelId\":1001,\"attrName\":\"COLOR\",\"attrValue\":\"RED\",\"materialCode\":\"MAT-RED-TEST\",\"sbomLineId\":\"2063979552677314562\",\"conditionExpr\":null,\"sortOrder\":null}','',1,'\n### Error updating database.  Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'000000-1001-COLOR-RED\' for key \'cpq_attribute_mapping.uk_attr_value\'\n### The error may exist in org/dromara/cpq/config/mapper/CpqAttributeMappingMapper.java (best guess)\n### The error may involve org.dromara.cpq.config.mapper.CpqAttributeMappingMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_attribute_mapping (mapping_id, model_id, attr_name, attr_value, material_code, sbom_line_id, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'000000-1001-COLOR-RED\' for key \'cpq_attribute_mapping.uk_attr_value\'\n; Duplicate entry \'000000-1001-COLOR-RED\' for key \'cpq_attribute_mapping.uk_attr_value\'','2026-06-08 21:52:55',11),(2063982704973594626,'000000','CPQ属性映射',1,'org.dromara.cpq.config.controller.CpqAttributeMappingController.add()','POST',1,'admin','管理员部门','/cpq/config/attributemapping','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"mappingId\":null,\"modelId\":1001,\"attrName\":\"COLOR\",\"attrValue\":\"BLUE\",\"materialCode\":\"MAT-BLUE-TEST\",\"sbomLineId\":\"2063979552908001281\",\"conditionExpr\":null,\"sortOrder\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:53:18',19),(2063982705275584514,'000000','CPQ属性映射',1,'org.dromara.cpq.config.controller.CpqAttributeMappingController.add()','POST',1,'admin','管理员部门','/cpq/config/attributemapping','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"mappingId\":null,\"modelId\":1001,\"attrName\":\"SIZE\",\"attrValue\":\"LARGE\",\"materialCode\":\"MAT-LARGE-TEST\",\"sbomLineId\":\"2063979552677314562\",\"conditionExpr\":null,\"sortOrder\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:53:19',16),(2063982705816649729,'000000','CPQ属性映射',1,'org.dromara.cpq.config.controller.CpqAttributeMappingController.add()','POST',1,'admin','管理员部门','/cpq/config/attributemapping','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"mappingId\":null,\"modelId\":1001,\"attrName\":\"SIZE\",\"attrValue\":\"SMALL\",\"materialCode\":\"MAT-SMALL-TEST\",\"sbomLineId\":\"2063979552908001281\",\"conditionExpr\":null,\"sortOrder\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:53:19',20),(2063982712485593090,'000000','CPQ捆绑选项组',1,'org.dromara.cpq.config.controller.CpqBundleOptionGroupController.add()','POST',1,'admin','管理员部门','/cpq/product/bundleoptiongroup','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionGroupId\":null,\"bundleId\":\"2063979125776859137\",\"groupName\":\"测试选项组_1780926800\",\"groupCode\":null,\"minSelections\":null,\"maxSelections\":null,\"isRequired\":null,\"sortOrder\":null,\"status\":null}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'group_code\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/config/mapper/CpqBundleOptionGroupMapper.java (best guess)\n### The error may involve org.dromara.cpq.config.mapper.CpqBundleOptionGroupMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_bundle_option_group (option_group_id, bundle_id, group_name, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'group_code\' doesn\'t have a default value\n; Field \'group_code\' doesn\'t have a default value','2026-06-08 21:53:20',9),(2063983062709977090,'000000','CPQ捆绑选项组',1,'org.dromara.cpq.config.controller.CpqBundleOptionGroupController.add()','POST',1,'admin','管理员部门','/cpq/product/bundleoptiongroup','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionGroupId\":null,\"bundleId\":\"2063979125776859137\",\"groupName\":\"测试选项组_1780926883\",\"groupCode\":\"TST_1780926883\",\"minSelections\":null,\"maxSelections\":null,\"isRequired\":null,\"sortOrder\":null,\"status\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:54:44',36),(2063983895459700738,'000000','CPQ捆绑选项组',1,'org.dromara.cpq.config.controller.CpqBundleOptionGroupController.add()','POST',1,'admin','管理员部门','/cpq/product/bundleoptiongroup','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionGroupId\":null,\"bundleId\":\"2063979125776859137\",\"groupName\":\"最终测试组_1780927081\",\"groupCode\":\"FINAL_1780927081\",\"minSelections\":null,\"maxSelections\":null,\"isRequired\":null,\"sortOrder\":null,\"status\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 21:58:02',96),(2063984868680794114,'000000','CPQ捆绑包',2,'org.dromara.cpq.config.controller.CpqBundleController.edit()','PUT',1,'admin','管理员部门','/cpq/product/bundle','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":\"2026-06-08 21:39:05\",\"updateBy\":null,\"updateTime\":\"2026-06-08 21:39:05\",\"tenantId\":\"000000\",\"bundleId\":\"2063979125776859137\",\"modelId\":1001,\"bundleType\":\"FIXED\",\"pricingStrategy\":\"BUNDLE_PRICE\",\"bundleDiscountPct\":null,\"isActive\":\"1\",\"description\":\"2222\",\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 22:01:54',94),(2063984932744593410,'000000','CPQ捆绑包',2,'org.dromara.cpq.config.controller.CpqBundleController.edit()','PUT',1,'admin','管理员部门','/cpq/product/bundle','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":\"2026-06-08 00:22:45\",\"updateBy\":null,\"updateTime\":\"2026-06-08 00:22:45\",\"tenantId\":\"000000\",\"bundleId\":\"2063657923755089921\",\"modelId\":1,\"bundleType\":\"CONFIGURABLE\",\"pricingStrategy\":\"SUM_COMPONENTS\",\"bundleDiscountPct\":\"15\",\"isActive\":\"1\",\"description\":\"测试捆绑包222\",\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 22:02:10',31),(2063985217625915394,'000000','CPQ配置规则',2,'org.dromara.cpq.config.controller.CpqConfigRuleController.edit()','PUT',1,'admin','管理员部门','/cpq/config/rule','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":\"2026-06-08 21:26:30\",\"updateBy\":null,\"updateTime\":\"2026-06-08 21:26:30\",\"tenantId\":\"000000\",\"ruleId\":\"2063975956493647874\",\"ruleName\":\"S4规则178092518922\",\"ruleType\":\"VALIDATION\",\"modelId\":null,\"conditionExpr\":\"color==RED\",\"actionExpr\":\"APPLY_DISCOUNT(0.1)\",\"errorMessage\":null,\"severity\":\"ERROR\",\"priority\":1,\"effectiveDate\":\"2026-01-01 00:00:00\",\"expiryDate\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 22:03:18',104),(2063987296432029698,'000000','CPQ捆绑包',2,'org.dromara.cpq.config.controller.CpqBundleController.edit()','PUT',1,'admin','管理员部门','/cpq/product/bundle','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":\"2026-06-08 21:38:25\",\"updateBy\":null,\"updateTime\":\"2026-06-08 21:38:25\",\"tenantId\":\"000000\",\"bundleId\":\"2063978958780645378\",\"modelId\":1001,\"bundleType\":\"FIXED\",\"pricingStrategy\":\"BUNDLE_PRICE\",\"bundleDiscountPct\":null,\"isActive\":\"1\",\"description\":\"ccvvv\",\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 22:11:33',85),(2063987429219500034,'000000','CPQ捆绑包',2,'org.dromara.cpq.config.controller.CpqBundleController.edit()','PUT',1,'admin','管理员部门','/cpq/product/bundle','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":\"2026-06-08 21:38:25\",\"updateBy\":null,\"updateTime\":\"2026-06-08 22:11:33\",\"tenantId\":\"000000\",\"bundleId\":\"2063978958780645378\",\"modelId\":1003,\"bundleType\":\"CONFIGURABLE\",\"pricingStrategy\":\"BUNDLE_PRICE\",\"bundleDiscountPct\":\"23\",\"isActive\":\"1\",\"description\":\"ccvvv\",\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 22:12:05',134),(2063987666013126658,'000000','CPQ捆绑包',2,'org.dromara.cpq.config.controller.CpqBundleController.edit()','PUT',1,'admin','管理员部门','/cpq/product/bundle','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":\"2026-06-08 00:21:46\",\"updateBy\":null,\"updateTime\":\"2026-06-08 00:21:46\",\"tenantId\":\"000000\",\"bundleId\":\"2063657677239066625\",\"modelId\":1002,\"bundleType\":\"FIXED\",\"pricingStrategy\":\"BUNDLE_PRICE\",\"bundleDiscountPct\":\"10\",\"isActive\":\"1\",\"description\":\"FKG测试用\",\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 22:13:01',71),(2064009036377907202,'000000','CPQ产品',2,'org.dromara.cpq.controller.CpqProductModelController.edit()','PUT',1,'admin','管理员部门','/cpq/product/model','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"modelId\":1001,\"catalogId\":1,\"categoryId\":1,\"modelCode\":\"ARC-160\",\"modelName\":\"ARC-160 紧凑型弧焊机器人\",\"description\":null,\"lifecycleStatus\":\"RELEASED\",\"successorModelId\":null,\"basePrice\":null,\"currency\":null,\"minOrderQty\":null,\"leadTimeDays\":null,\"configType\":\"STANDARD\",\"defaultBomId\":\"2063979195180007426\",\"thumbnailUrl\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-08 23:37:56',47),(2064187531485818882,'000000','CPQ属性选项',1,'org.dromara.cpq.config.controller.CpqAttributeOptionController.add()','POST',1,'admin','管理员部门','/cpq/config/attributeoption','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionId\":null,\"modelId\":1001,\"attrName\":\"颜色\",\"optionCode\":\"TEST-RED\",\"optionLabel\":\"测试红色\",\"optionValue\":\"test_red\",\"isDefault\":\"0\",\"sortOrder\":99}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 11:27:13',1275),(2064187687664922625,'000000','CPQ属性选项',1,'org.dromara.cpq.config.controller.CpqAttributeOptionController.add()','POST',1,'admin','管理员部门','/cpq/config/attributeoption','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionId\":null,\"modelId\":1001,\"attrName\":\"颜色\",\"optionCode\":\"TEST-GOLD\",\"optionLabel\":\"测试金色\",\"optionValue\":\"test_gold\",\"isDefault\":\"0\",\"sortOrder\":99}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 11:27:50',50),(2064187688679944193,'000000','CPQ属性选项',2,'org.dromara.cpq.config.controller.CpqAttributeOptionController.edit()','PUT',1,'admin','管理员部门','/cpq/config/attributeoption','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionId\":\"2064187687471984641\",\"modelId\":1001,\"attrName\":\"颜色\",\"optionCode\":\"TEST-GOLD\",\"optionLabel\":\"测试金色(已编辑)\",\"optionValue\":\"test_gold_v2\",\"isDefault\":\"0\",\"sortOrder\":50}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 11:27:50',97),(2064187690357665793,'000000','CPQ属性选项',3,'org.dromara.cpq.config.controller.CpqAttributeOptionController.remove()','DELETE',1,'admin','管理员部门','/cpq/config/attributeoption/2064187687471984641','0:0:0:0:0:0:0:1','内网IP','\"2064187687471984641\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 11:27:51',340),(2064187776642887682,'000000','CPQ属性选项',3,'org.dromara.cpq.config.controller.CpqAttributeOptionController.remove()','DELETE',1,'admin','管理员部门','/cpq/config/attributeoption/2064187524464553985','0:0:0:0:0:0:0:1','内网IP','\"2064187524464553985\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 11:28:11',49),(2064193692477992961,'000000','CPQ属性选项',1,'org.dromara.cpq.config.controller.CpqAttributeOptionController.add()','POST',1,'admin','管理员部门','/cpq/config/attributeoption','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionId\":null,\"modelId\":1001,\"attrName\":\"颜色\",\"optionCode\":\"TEST-E2E-001\",\"optionLabel\":\"E2E测试色\",\"optionValue\":\"test_e2e_001\",\"isDefault\":\"0\",\"sortOrder\":99}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 11:51:42',36),(2064193693031641090,'000000','CPQ属性选项',2,'org.dromara.cpq.config.controller.CpqAttributeOptionController.edit()','PUT',1,'admin','管理员部门','/cpq/config/attributeoption','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"optionId\":\"2064193692364746754\",\"modelId\":1001,\"attrName\":\"颜色\",\"optionCode\":\"TEST-E2E-001\",\"optionLabel\":\"E2E测试色(已编辑)\",\"optionValue\":\"test_e2e_001_v2\",\"isDefault\":\"0\",\"sortOrder\":50}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 11:51:42',41),(2064193693702729729,'000000','CPQ属性选项',3,'org.dromara.cpq.config.controller.CpqAttributeOptionController.remove()','DELETE',1,'admin','管理员部门','/cpq/config/attributeoption/2064193692364746754','0:0:0:0:0:0:0:1','内网IP','\"2064193692364746754\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 11:51:42',22),(2064220192908554242,'000000','CPQ产品',1,'org.dromara.cpq.controller.CpqProductModelController.add()','POST',1,'admin','管理员部门','/cpq/product/model','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"modelId\":null,\"catalogId\":1,\"categoryId\":null,\"modelCode\":\"BW-ARC-BUNDLE\",\"modelName\":\"弧焊机器人入门套装\",\"description\":\"含ARC-160机器人+标准焊枪+基础控制器\",\"lifecycleStatus\":\"ACTIVE\",\"successorModelId\":null,\"basePrice\":null,\"currency\":\"CNY\",\"minOrderQty\":1,\"leadTimeDays\":null,\"configType\":\"BUNDLE\",\"defaultBomId\":null,\"thumbnailUrl\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'category_id\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/mapper/CpqProductModelMapper.java (best guess)\n### The error may involve org.dromara.cpq.mapper.CpqProductModelMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_product_model (model_id, catalog_id, model_code, model_name, description, lifecycle_status, currency, min_order_qty, config_type, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'category_id\' doesn\'t have a default value\n; Field \'category_id\' doesn\'t have a default value','2026-06-09 13:37:00',151),(2064220193185378306,'000000','CPQ产品',1,'org.dromara.cpq.controller.CpqProductModelController.add()','POST',1,'admin','管理员部门','/cpq/product/model','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"modelId\":null,\"catalogId\":1,\"categoryId\":null,\"modelCode\":\"BW-SPOT-BUNDLE\",\"modelName\":\"点焊机器人标准套装\",\"description\":\"含SPOT-210机器人+焊接变压器+电极修磨器\",\"lifecycleStatus\":\"ACTIVE\",\"successorModelId\":null,\"basePrice\":null,\"currency\":\"CNY\",\"minOrderQty\":1,\"leadTimeDays\":null,\"configType\":\"BUNDLE\",\"defaultBomId\":null,\"thumbnailUrl\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'category_id\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/mapper/CpqProductModelMapper.java (best guess)\n### The error may involve org.dromara.cpq.mapper.CpqProductModelMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_product_model (model_id, catalog_id, model_code, model_name, description, lifecycle_status, currency, min_order_qty, config_type, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'category_id\' doesn\'t have a default value\n; Field \'category_id\' doesn\'t have a default value','2026-06-09 13:37:00',23),(2064220193378316289,'000000','CPQ产品',1,'org.dromara.cpq.controller.CpqProductModelController.add()','POST',1,'admin','管理员部门','/cpq/product/model','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"modelId\":null,\"catalogId\":2,\"categoryId\":null,\"modelCode\":\"BW-SCARA-BUNDLE\",\"modelName\":\"SCARA机器人产线套装\",\"description\":\"含SCARA-400+视觉定位系统+输送带\",\"lifecycleStatus\":\"ACTIVE\",\"successorModelId\":null,\"basePrice\":null,\"currency\":\"USD\",\"minOrderQty\":1,\"leadTimeDays\":null,\"configType\":\"BUNDLE\",\"defaultBomId\":null,\"thumbnailUrl\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'category_id\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/mapper/CpqProductModelMapper.java (best guess)\n### The error may involve org.dromara.cpq.mapper.CpqProductModelMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_product_model (model_id, catalog_id, model_code, model_name, description, lifecycle_status, currency, min_order_qty, config_type, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'category_id\' doesn\'t have a default value\n; Field \'category_id\' doesn\'t have a default value','2026-06-09 13:37:00',19),(2064220193567059969,'000000','CPQ产品',1,'org.dromara.cpq.controller.CpqProductModelController.add()','POST',1,'admin','管理员部门','/cpq/product/model','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"modelId\":null,\"catalogId\":1,\"categoryId\":null,\"modelCode\":\"BW-SERVO-BUNDLE\",\"modelName\":\"伺服驱动系统套装\",\"description\":\"含伺服电机+驱动器+编码器电缆\",\"lifecycleStatus\":\"ACTIVE\",\"successorModelId\":null,\"basePrice\":null,\"currency\":\"CNY\",\"minOrderQty\":1,\"leadTimeDays\":null,\"configType\":\"BUNDLE\",\"defaultBomId\":null,\"thumbnailUrl\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'category_id\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/mapper/CpqProductModelMapper.java (best guess)\n### The error may involve org.dromara.cpq.mapper.CpqProductModelMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_product_model (model_id, catalog_id, model_code, model_name, description, lifecycle_status, currency, min_order_qty, config_type, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'category_id\' doesn\'t have a default value\n; Field \'category_id\' doesn\'t have a default value','2026-06-09 13:37:00',15),(2064220193785163778,'000000','CPQ产品',1,'org.dromara.cpq.controller.CpqProductModelController.add()','POST',1,'admin','管理员部门','/cpq/product/model','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"modelId\":null,\"catalogId\":1,\"categoryId\":null,\"modelCode\":\"BW-CNC-BUNDLE\",\"modelName\":\"CNC加工中心套装\",\"description\":\"含CNC控制系统+主轴电机+刀库\",\"lifecycleStatus\":\"CONCEPT\",\"successorModelId\":null,\"basePrice\":null,\"currency\":\"CNY\",\"minOrderQty\":1,\"leadTimeDays\":null,\"configType\":\"BUNDLE\",\"defaultBomId\":null,\"thumbnailUrl\":null,\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'category_id\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/mapper/CpqProductModelMapper.java (best guess)\n### The error may involve org.dromara.cpq.mapper.CpqProductModelMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_product_model (model_id, catalog_id, model_code, model_name, description, lifecycle_status, currency, min_order_qty, config_type, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'category_id\' doesn\'t have a default value\n; Field \'category_id\' doesn\'t have a default value','2026-06-09 13:37:00',20),(2064220268959674369,'000000','报价单',2,'org.dromara.cpq.quote.controller.CpqQuoteController.edit()','PUT',1,'admin','管理员部门','/cpq/quote/header','0:0:0:0:0:0:0:1','内网IP','{\"quoteId\":\"2064149007508221954\",\"quoteNumber\":\"新报价单\",\"opportunityId\":null,\"accountId\":1,\"accountName\":\"E2E终测\",\"quoteType\":\"STANDARD\",\"currency\":\"CNY\",\"subtotal\":null,\"discountTotal\":null,\"taxTotal\":null,\"grandTotal\":null,\"status\":\"DRAFT\",\"validUntil\":\"2026-06-29\",\"approvalChainId\":null,\"createdBy\":null,\"createdByName\":null,\"submittedDate\":null,\"wonDate\":null,\"remark\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 13:37:18',146),(2064220559499112450,'000000','CPQ产品',1,'org.dromara.cpq.controller.CpqProductModelController.add()','POST',1,'admin','管理员部门','/cpq/product/model','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"modelId\":null,\"catalogId\":1,\"categoryId\":301,\"modelCode\":\"BW-ARC-BUNDLE\",\"modelName\":\"弧焊机器人入门套装\",\"description\":\"ARC-160机器人+标准焊枪+基础控制器\",\"lifecycleStatus\":\"ACTIVE\",\"successorModelId\":null,\"basePrice\":null,\"currency\":\"CNY\",\"minOrderQty\":1,\"leadTimeDays\":null,\"configType\":\"BUNDLE\",\"defaultBomId\":null,\"thumbnailUrl\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 13:38:27',25),(2064220559704633345,'000000','CPQ产品',1,'org.dromara.cpq.controller.CpqProductModelController.add()','POST',1,'admin','管理员部门','/cpq/product/model','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"modelId\":null,\"catalogId\":1,\"categoryId\":302,\"modelCode\":\"BW-SPOT-BUNDLE\",\"modelName\":\"点焊机器人标准套装\",\"description\":\"SPOT-210+焊接变压器+电极修磨器\",\"lifecycleStatus\":\"ACTIVE\",\"successorModelId\":null,\"basePrice\":null,\"currency\":\"CNY\",\"minOrderQty\":1,\"leadTimeDays\":null,\"configType\":\"BUNDLE\",\"defaultBomId\":null,\"thumbnailUrl\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 13:38:27',22),(2064220559884988418,'000000','CPQ产品',1,'org.dromara.cpq.controller.CpqProductModelController.add()','POST',1,'admin','管理员部门','/cpq/product/model','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"modelId\":null,\"catalogId\":2,\"categoryId\":308,\"modelCode\":\"BW-SCARA-BUNDLE\",\"modelName\":\"SCARA机器人产线套装\",\"description\":\"SCARA-400+视觉定位+输送带\",\"lifecycleStatus\":\"ACTIVE\",\"successorModelId\":null,\"basePrice\":null,\"currency\":\"USD\",\"minOrderQty\":1,\"leadTimeDays\":null,\"configType\":\"BUNDLE\",\"defaultBomId\":null,\"thumbnailUrl\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 13:38:27',20),(2064220560216338433,'000000','CPQ产品',1,'org.dromara.cpq.controller.CpqProductModelController.add()','POST',1,'admin','管理员部门','/cpq/product/model','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"modelId\":null,\"catalogId\":1,\"categoryId\":301,\"modelCode\":\"BW-SERVO-BUNDLE\",\"modelName\":\"伺服驱动系统套装\",\"description\":\"伺服电机+驱动器+编码器电缆\",\"lifecycleStatus\":\"ACTIVE\",\"successorModelId\":null,\"basePrice\":null,\"currency\":\"CNY\",\"minOrderQty\":1,\"leadTimeDays\":null,\"configType\":\"BUNDLE\",\"defaultBomId\":null,\"thumbnailUrl\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 13:38:28',38),(2064220560405082113,'000000','CPQ产品',1,'org.dromara.cpq.controller.CpqProductModelController.add()','POST',1,'admin','管理员部门','/cpq/product/model','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"modelId\":null,\"catalogId\":1,\"categoryId\":308,\"modelCode\":\"BW-CNC-BUNDLE\",\"modelName\":\"CNC加工中心套装\",\"description\":\"CNC控制系统+主轴电机+刀库(规划中)\",\"lifecycleStatus\":\"CONCEPT\",\"successorModelId\":null,\"basePrice\":null,\"currency\":\"CNY\",\"minOrderQty\":1,\"leadTimeDays\":null,\"configType\":\"BUNDLE\",\"defaultBomId\":null,\"thumbnailUrl\":null,\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 13:38:28',22),(2064223743940538370,'000000','报价单',3,'org.dromara.cpq.quote.controller.CpqQuoteController.remove()','DELETE',1,'admin','管理员部门','/cpq/quote/header/2064149007508221954','0:0:0:0:0:0:0:1','内网IP','\"2064149007508221954\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 13:51:07',36),(2064223819001802753,'000000','报价单',1,'org.dromara.cpq.quote.controller.CpqQuoteController.add()','POST',1,'admin','管理员部门','/cpq/quote/header','0:0:0:0:0:0:0:1','内网IP','{\"quoteId\":null,\"quoteNumber\":\"新报价单\",\"opportunityId\":null,\"accountId\":1,\"accountName\":\"E2E终测\",\"quoteType\":\"STANDARD\",\"currency\":\"CNY\",\"subtotal\":null,\"discountTotal\":null,\"taxTotal\":null,\"grandTotal\":null,\"status\":\"DRAFT\",\"validUntil\":\"2026-06-29\",\"approvalChainId\":null,\"createdBy\":null,\"createdByName\":null,\"submittedDate\":null,\"wonDate\":null,\"remark\":null}','',1,'\n### Error updating database.  Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'000000-新报价单\' for key \'cpq_quote.uk_quote_number\'\n### The error may exist in org/dromara/cpq/quote/mapper/CpqQuoteMapper.java (best guess)\n### The error may involve org.dromara.cpq.quote.mapper.CpqQuoteMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_quote (quote_id, quote_number, account_id, account_name, quote_type, currency, status, valid_until, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'000000-新报价单\' for key \'cpq_quote.uk_quote_number\'\n; Duplicate entry \'000000-新报价单\' for key \'cpq_quote.uk_quote_number\'','2026-06-09 13:51:25',19),(2064250144785711106,'000000','报价行项目',1,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.add()','POST',1,'admin','管理员部门','/cpq/quote/lineitem','0:0:0:0:0:0:0:1','内网IP','{\"lineId\":null,\"quoteId\":\"2064149007508221954\",\"parentLineId\":null,\"lineNumber\":null,\"modelId\":1001,\"sbomLineId\":null,\"itemType\":\"PRODUCT\",\"itemCode\":\"ARC-160\",\"itemName\":\"ARC-160 紧凑型弧焊机器人\",\"quantity\":\"1\",\"unit\":null,\"listPrice\":null,\"unitPrice\":\"185000.00\",\"discountPct\":null,\"discountAmount\":null,\"netPrice\":null,\"lineTotal\":null,\"configurationJson\":null,\"customRequirements\":null,\"deliveryDays\":null,\"atpStatus\":null,\"sortOrder\":null,\"remark\":null}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'line_number\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/quote/mapper/CpqQuoteLineItemMapper.java (best guess)\n### The error may involve org.dromara.cpq.quote.mapper.CpqQuoteLineItemMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_quote_line_item (line_id, quote_id, model_id, item_type, item_code, item_name, quantity, unit_price, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'line_number\' doesn\'t have a default value\n; Field \'line_number\' doesn\'t have a default value','2026-06-09 15:36:01',535),(2064250152947826689,'000000','报价行项目',1,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.add()','POST',1,'admin','管理员部门','/cpq/quote/lineitem','0:0:0:0:0:0:0:1','内网IP','{\"lineId\":null,\"quoteId\":\"2064149007508221954\",\"parentLineId\":null,\"lineNumber\":null,\"modelId\":1001,\"sbomLineId\":null,\"itemType\":\"PRODUCT\",\"itemCode\":\"ARC-160\",\"itemName\":\"ARC-160 紧凑型弧焊机器人\",\"quantity\":\"1\",\"unit\":null,\"listPrice\":null,\"unitPrice\":\"185000.00\",\"discountPct\":null,\"discountAmount\":null,\"netPrice\":null,\"lineTotal\":null,\"configurationJson\":null,\"customRequirements\":null,\"deliveryDays\":null,\"atpStatus\":null,\"sortOrder\":null,\"remark\":null}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'line_number\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/quote/mapper/CpqQuoteLineItemMapper.java (best guess)\n### The error may involve org.dromara.cpq.quote.mapper.CpqQuoteLineItemMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_quote_line_item (line_id, quote_id, model_id, item_type, item_code, item_name, quantity, unit_price, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'line_number\' doesn\'t have a default value\n; Field \'line_number\' doesn\'t have a default value','2026-06-09 15:36:03',10),(2064250154512302081,'000000','报价行项目',1,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.add()','POST',1,'admin','管理员部门','/cpq/quote/lineitem','0:0:0:0:0:0:0:1','内网IP','{\"lineId\":null,\"quoteId\":\"2064149007508221954\",\"parentLineId\":null,\"lineNumber\":null,\"modelId\":1001,\"sbomLineId\":null,\"itemType\":\"PRODUCT\",\"itemCode\":\"ARC-160\",\"itemName\":\"ARC-160 紧凑型弧焊机器人\",\"quantity\":\"1\",\"unit\":null,\"listPrice\":null,\"unitPrice\":\"185000.00\",\"discountPct\":null,\"discountAmount\":null,\"netPrice\":null,\"lineTotal\":null,\"configurationJson\":null,\"customRequirements\":null,\"deliveryDays\":null,\"atpStatus\":null,\"sortOrder\":null,\"remark\":null}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'line_number\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/quote/mapper/CpqQuoteLineItemMapper.java (best guess)\n### The error may involve org.dromara.cpq.quote.mapper.CpqQuoteLineItemMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_quote_line_item (line_id, quote_id, model_id, item_type, item_code, item_name, quantity, unit_price, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'line_number\' doesn\'t have a default value\n; Field \'line_number\' doesn\'t have a default value','2026-06-09 15:36:03',13),(2064250155321802753,'000000','报价行项目',1,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.add()','POST',1,'admin','管理员部门','/cpq/quote/lineitem','0:0:0:0:0:0:0:1','内网IP','{\"lineId\":null,\"quoteId\":\"2064149007508221954\",\"parentLineId\":null,\"lineNumber\":null,\"modelId\":1001,\"sbomLineId\":null,\"itemType\":\"PRODUCT\",\"itemCode\":\"ARC-160\",\"itemName\":\"ARC-160 紧凑型弧焊机器人\",\"quantity\":\"1\",\"unit\":null,\"listPrice\":null,\"unitPrice\":\"185000.00\",\"discountPct\":null,\"discountAmount\":null,\"netPrice\":null,\"lineTotal\":null,\"configurationJson\":null,\"customRequirements\":null,\"deliveryDays\":null,\"atpStatus\":null,\"sortOrder\":null,\"remark\":null}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'line_number\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/quote/mapper/CpqQuoteLineItemMapper.java (best guess)\n### The error may involve org.dromara.cpq.quote.mapper.CpqQuoteLineItemMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_quote_line_item (line_id, quote_id, model_id, item_type, item_code, item_name, quantity, unit_price, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'line_number\' doesn\'t have a default value\n; Field \'line_number\' doesn\'t have a default value','2026-06-09 15:36:04',9),(2064250158014545922,'000000','报价行项目',1,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.add()','POST',1,'admin','管理员部门','/cpq/quote/lineitem','0:0:0:0:0:0:0:1','内网IP','{\"lineId\":null,\"quoteId\":\"2064149007508221954\",\"parentLineId\":null,\"lineNumber\":null,\"modelId\":1001,\"sbomLineId\":null,\"itemType\":\"PRODUCT\",\"itemCode\":\"ARC-160\",\"itemName\":\"ARC-160 紧凑型弧焊机器人\",\"quantity\":\"1\",\"unit\":null,\"listPrice\":null,\"unitPrice\":\"185000.00\",\"discountPct\":null,\"discountAmount\":null,\"netPrice\":null,\"lineTotal\":null,\"configurationJson\":null,\"customRequirements\":null,\"deliveryDays\":null,\"atpStatus\":null,\"sortOrder\":null,\"remark\":null}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'line_number\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/quote/mapper/CpqQuoteLineItemMapper.java (best guess)\n### The error may involve org.dromara.cpq.quote.mapper.CpqQuoteLineItemMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_quote_line_item (line_id, quote_id, model_id, item_type, item_code, item_name, quantity, unit_price, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'line_number\' doesn\'t have a default value\n; Field \'line_number\' doesn\'t have a default value','2026-06-09 15:36:04',10),(2064250284665749505,'000000','报价行项目',1,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.add()','POST',1,'admin','管理员部门','/cpq/quote/lineitem','0:0:0:0:0:0:0:1','内网IP','{\"lineId\":null,\"quoteId\":\"2064149007508221954\",\"parentLineId\":null,\"lineNumber\":null,\"modelId\":1001,\"sbomLineId\":null,\"itemType\":\"PRODUCT\",\"itemCode\":\"ARC-160\",\"itemName\":\"ARC-160 紧凑型弧焊机器人\",\"quantity\":\"1\",\"unit\":null,\"listPrice\":null,\"unitPrice\":\"185000.00\",\"discountPct\":null,\"discountAmount\":null,\"netPrice\":null,\"lineTotal\":null,\"configurationJson\":null,\"customRequirements\":null,\"deliveryDays\":null,\"atpStatus\":null,\"sortOrder\":null,\"remark\":null}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'line_number\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/quote/mapper/CpqQuoteLineItemMapper.java (best guess)\n### The error may involve org.dromara.cpq.quote.mapper.CpqQuoteLineItemMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_quote_line_item (line_id, quote_id, model_id, item_type, item_code, item_name, quantity, unit_price, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'line_number\' doesn\'t have a default value\n; Field \'line_number\' doesn\'t have a default value','2026-06-09 15:36:34',214),(2064250800896491521,'000000','报价行项目',1,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.add()','POST',1,'admin','管理员部门','/cpq/quote/lineitem','0:0:0:0:0:0:0:1','内网IP','{\"lineId\":null,\"quoteId\":\"2064149007508221954\",\"parentLineId\":null,\"lineNumber\":null,\"modelId\":1001,\"sbomLineId\":null,\"itemType\":\"PRODUCT\",\"itemCode\":\"ARC-160\",\"itemName\":\"TEST\",\"quantity\":\"1\",\"unit\":null,\"listPrice\":null,\"unitPrice\":\"0\",\"discountPct\":null,\"discountAmount\":null,\"netPrice\":null,\"lineTotal\":null,\"configurationJson\":null,\"customRequirements\":null,\"deliveryDays\":null,\"atpStatus\":null,\"sortOrder\":null,\"remark\":null}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'line_number\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/quote/mapper/CpqQuoteLineItemMapper.java (best guess)\n### The error may involve org.dromara.cpq.quote.mapper.CpqQuoteLineItemMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_quote_line_item (line_id, quote_id, model_id, item_type, item_code, item_name, quantity, unit_price, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'line_number\' doesn\'t have a default value\n; Field \'line_number\' doesn\'t have a default value','2026-06-09 15:38:38',21),(2064250801018126338,'000000','报价行项目',1,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.add()','POST',1,'admin','管理员部门','/cpq/quote/lineitem','0:0:0:0:0:0:0:1','内网IP','{\"lineId\":null,\"quoteId\":\"2064149007508221954\",\"parentLineId\":null,\"lineNumber\":null,\"modelId\":1001,\"sbomLineId\":null,\"itemType\":\"PRODUCT\",\"itemCode\":\"ARC-160\",\"itemName\":\"TEST\",\"quantity\":\"1\",\"unit\":null,\"listPrice\":null,\"unitPrice\":\"0\",\"discountPct\":null,\"discountAmount\":null,\"netPrice\":null,\"lineTotal\":null,\"configurationJson\":null,\"customRequirements\":null,\"deliveryDays\":null,\"atpStatus\":null,\"sortOrder\":null,\"remark\":null}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'line_number\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/quote/mapper/CpqQuoteLineItemMapper.java (best guess)\n### The error may involve org.dromara.cpq.quote.mapper.CpqQuoteLineItemMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_quote_line_item (line_id, quote_id, model_id, item_type, item_code, item_name, quantity, unit_price, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'line_number\' doesn\'t have a default value\n; Field \'line_number\' doesn\'t have a default value','2026-06-09 15:38:38',9),(2064251521419210753,'000000','报价行项目',1,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.add()','POST',1,'admin','管理员部门','/cpq/quote/lineitem','0:0:0:0:0:0:0:1','内网IP','{\"lineId\":null,\"quoteId\":\"2064149007508221954\",\"parentLineId\":null,\"lineNumber\":null,\"modelId\":1001,\"sbomLineId\":null,\"itemType\":\"PRODUCT\",\"itemCode\":\"ARC-160\",\"itemName\":\"ARC-160 紧凑型弧焊机器人\",\"quantity\":\"2\",\"unit\":null,\"listPrice\":null,\"unitPrice\":\"185000.00\",\"discountPct\":null,\"discountAmount\":null,\"netPrice\":null,\"lineTotal\":null,\"configurationJson\":null,\"customRequirements\":null,\"deliveryDays\":null,\"atpStatus\":null,\"sortOrder\":null,\"remark\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 15:41:29',57),(2064251521758949378,'000000','报价行项目',1,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.add()','POST',1,'admin','管理员部门','/cpq/quote/lineitem','0:0:0:0:0:0:0:1','内网IP','{\"lineId\":null,\"quoteId\":\"2064149007508221954\",\"parentLineId\":null,\"lineNumber\":null,\"modelId\":1001,\"sbomLineId\":null,\"itemType\":\"PRODUCT\",\"itemCode\":\"ARC-160\",\"itemName\":\"ARC-160 紧凑型弧焊机器人\",\"quantity\":\"3\",\"unit\":null,\"listPrice\":null,\"unitPrice\":\"185000.00\",\"discountPct\":null,\"discountAmount\":null,\"netPrice\":null,\"lineTotal\":null,\"configurationJson\":null,\"customRequirements\":null,\"deliveryDays\":null,\"atpStatus\":null,\"sortOrder\":null,\"remark\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 15:41:29',18),(2064251522249682945,'000000','报价行项目',3,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.remove()','DELETE',1,'admin','管理员部门','/cpq/quote/lineitem/2064251521272410113','0:0:0:0:0:0:0:1','内网IP','\"2064251521272410113\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 15:41:29',21),(2064251522392289281,'000000','报价行项目',3,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.remove()','DELETE',1,'admin','管理员部门','/cpq/quote/lineitem/2064251521717006338','0:0:0:0:0:0:0:1','内网IP','\"2064251521717006338\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 15:41:30',17),(2064252068515835906,'000000','报价行项目',1,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.add()','POST',1,'admin','管理员部门','/cpq/quote/lineitem','0:0:0:0:0:0:0:1','内网IP','{\"lineId\":null,\"quoteId\":\"2064149007508221954\",\"parentLineId\":null,\"lineNumber\":null,\"modelId\":1001,\"sbomLineId\":null,\"itemType\":\"PRODUCT\",\"itemCode\":\"ARC-160\",\"itemName\":\"ARC-160 紧凑型弧焊机器人\",\"quantity\":\"1\",\"unit\":null,\"listPrice\":null,\"unitPrice\":\"185000.00\",\"discountPct\":null,\"discountAmount\":null,\"netPrice\":null,\"lineTotal\":null,\"configurationJson\":null,\"customRequirements\":null,\"deliveryDays\":null,\"atpStatus\":null,\"sortOrder\":null,\"remark\":null}','',1,'\n### Error updating database.  Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'000000-2064149007508221954-1\' for key \'cpq_quote_line_item.uk_quote_line\'\n### The error may exist in org/dromara/cpq/quote/mapper/CpqQuoteLineItemMapper.java (best guess)\n### The error may involve org.dromara.cpq.quote.mapper.CpqQuoteLineItemMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_quote_line_item (line_id, quote_id, line_number, model_id, item_type, item_code, item_name, quantity, unit, unit_price, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'000000-2064149007508221954-1\' for key \'cpq_quote_line_item.uk_quote_line\'\n; Duplicate entry \'000000-2064149007508221954-1\' for key \'cpq_quote_line_item.uk_quote_line\'','2026-06-09 15:43:40',385),(2064253058774237186,'000000','报价行项目',1,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.add()','POST',1,'admin','管理员部门','/cpq/quote/lineitem','0:0:0:0:0:0:0:1','内网IP','{\"lineId\":null,\"quoteId\":\"2064149007508221954\",\"parentLineId\":null,\"lineNumber\":null,\"modelId\":1001,\"sbomLineId\":null,\"itemType\":\"PRODUCT\",\"itemCode\":\"ARC-160\",\"itemName\":\"ARC-160 紧凑型弧焊机器人\",\"quantity\":\"1\",\"unit\":null,\"listPrice\":null,\"unitPrice\":\"185000.00\",\"discountPct\":null,\"discountAmount\":null,\"netPrice\":null,\"lineTotal\":null,\"configurationJson\":null,\"customRequirements\":null,\"deliveryDays\":null,\"atpStatus\":null,\"sortOrder\":null,\"remark\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 15:47:36',449),(2064254764543148033,'000000','报价行项目',1,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.add()','POST',1,'admin','管理员部门','/cpq/quote/lineitem','0:0:0:0:0:0:0:1','内网IP','{\"lineId\":null,\"quoteId\":1,\"parentLineId\":null,\"lineNumber\":null,\"modelId\":1001,\"sbomLineId\":null,\"itemType\":\"PRODUCT\",\"itemCode\":\"ARC-160\",\"itemName\":\"ARC-160 紧凑型弧焊机器人\",\"quantity\":\"1\",\"unit\":null,\"listPrice\":null,\"unitPrice\":\"185000.00\",\"discountPct\":null,\"discountAmount\":null,\"netPrice\":null,\"lineTotal\":null,\"configurationJson\":null,\"customRequirements\":null,\"deliveryDays\":null,\"atpStatus\":null,\"sortOrder\":null,\"remark\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 15:54:23',84),(2064256480672018434,'000000','报价行项目',1,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.add()','POST',1,'admin','管理员部门','/cpq/quote/lineitem','0:0:0:0:0:0:0:1','内网IP','{\"lineId\":null,\"quoteId\":\"2064149007508221954\",\"parentLineId\":null,\"lineNumber\":null,\"modelId\":1001,\"sbomLineId\":null,\"itemType\":\"PRODUCT\",\"itemCode\":\"ARC-160\",\"itemName\":\"ARC-160 紧凑型弧焊机器人\",\"quantity\":\"1\",\"unit\":null,\"listPrice\":null,\"unitPrice\":\"185000.00\",\"discountPct\":null,\"discountAmount\":null,\"netPrice\":null,\"lineTotal\":null,\"configurationJson\":null,\"customRequirements\":null,\"deliveryDays\":null,\"atpStatus\":null,\"sortOrder\":null,\"remark\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 16:01:12',84),(2064256481087254530,'000000','报价行项目',1,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.add()','POST',1,'admin','管理员部门','/cpq/quote/lineitem','0:0:0:0:0:0:0:1','内网IP','{\"lineId\":null,\"quoteId\":\"2064149007508221954\",\"parentLineId\":null,\"lineNumber\":null,\"modelId\":1001,\"sbomLineId\":null,\"itemType\":\"PRODUCT\",\"itemCode\":\"ARC-160\",\"itemName\":\"ARC-160 紧凑型弧焊机器人\",\"quantity\":\"2\",\"unit\":null,\"listPrice\":null,\"unitPrice\":\"185000.00\",\"discountPct\":null,\"discountAmount\":null,\"netPrice\":null,\"lineTotal\":null,\"configurationJson\":null,\"customRequirements\":null,\"deliveryDays\":null,\"atpStatus\":null,\"sortOrder\":null,\"remark\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 16:01:12',20),(2064256481330524161,'000000','报价行项目',3,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.remove()','DELETE',1,'admin','管理员部门','/cpq/quote/lineitem/2064256480453914625','0:0:0:0:0:0:0:1','内网IP','\"2064256480453914625\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 16:01:12',21),(2064256481577988098,'000000','报价行项目',1,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.add()','POST',1,'admin','管理员部门','/cpq/quote/lineitem','0:0:0:0:0:0:0:1','内网IP','{\"lineId\":null,\"quoteId\":\"2064149007508221954\",\"parentLineId\":null,\"lineNumber\":null,\"modelId\":1001,\"sbomLineId\":null,\"itemType\":\"PRODUCT\",\"itemCode\":\"ARC-160\",\"itemName\":\"ARC-160 紧凑型弧焊机器人\",\"quantity\":\"3\",\"unit\":null,\"listPrice\":null,\"unitPrice\":\"185000.00\",\"discountPct\":null,\"discountAmount\":null,\"netPrice\":null,\"lineTotal\":null,\"configurationJson\":null,\"customRequirements\":null,\"deliveryDays\":null,\"atpStatus\":null,\"sortOrder\":null,\"remark\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 16:01:12',19),(2064256481833840642,'000000','报价行项目',3,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.remove()','DELETE',1,'admin','管理员部门','/cpq/quote/lineitem/2064256481032728577','0:0:0:0:0:0:0:1','内网IP','\"2064256481032728577\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 16:01:12',18),(2064256481997418498,'000000','报价行项目',3,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.remove()','DELETE',1,'admin','管理员部门','/cpq/quote/lineitem/2064256481531850754','0:0:0:0:0:0:0:1','内网IP','\"2064256481531850754\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 16:01:12',19),(2064256796641521665,'000000','报价行项目',1,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.add()','POST',1,'admin','管理员部门','/cpq/quote/lineitem','0:0:0:0:0:0:0:1','内网IP','{\"lineId\":null,\"quoteId\":\"2064149007508221954\",\"parentLineId\":null,\"lineNumber\":null,\"modelId\":1001,\"sbomLineId\":null,\"itemType\":\"PRODUCT\",\"itemCode\":\"ARC-160\",\"itemName\":\"ARC-160 紧凑型弧焊机器人\",\"quantity\":\"1\",\"unit\":null,\"listPrice\":null,\"unitPrice\":\"185000.00\",\"discountPct\":null,\"discountAmount\":null,\"netPrice\":null,\"lineTotal\":null,\"configurationJson\":null,\"customRequirements\":null,\"deliveryDays\":null,\"atpStatus\":null,\"sortOrder\":null,\"remark\":null}','',1,'\n### Error updating database.  Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'000000-2064149007508221954-1\' for key \'cpq_quote_line_item.uk_quote_line\'\n### The error may exist in org/dromara/cpq/quote/mapper/CpqQuoteLineItemMapper.java (best guess)\n### The error may involve org.dromara.cpq.quote.mapper.CpqQuoteLineItemMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_quote_line_item (line_id, quote_id, line_number, model_id, item_type, item_code, item_name, quantity, unit, unit_price, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'000000-2064149007508221954-1\' for key \'cpq_quote_line_item.uk_quote_line\'\n; Duplicate entry \'000000-2064149007508221954-1\' for key \'cpq_quote_line_item.uk_quote_line\'','2026-06-09 16:02:27',558),(2064259065734782978,'000000','报价行项目',1,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.add()','POST',1,'admin','管理员部门','/cpq/quote/lineitem','0:0:0:0:0:0:0:1','内网IP','{\"lineId\":null,\"quoteId\":\"2064149007508221954\",\"parentLineId\":null,\"lineNumber\":null,\"modelId\":1001,\"sbomLineId\":null,\"itemType\":\"PRODUCT\",\"itemCode\":\"ARC-160\",\"itemName\":\"ARC-160 紧凑型弧焊机器人\",\"quantity\":\"1\",\"unit\":null,\"listPrice\":null,\"unitPrice\":\"185000.00\",\"discountPct\":null,\"discountAmount\":null,\"netPrice\":null,\"lineTotal\":null,\"configurationJson\":null,\"customRequirements\":null,\"deliveryDays\":null,\"atpStatus\":null,\"sortOrder\":null,\"remark\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 16:11:28',71),(2064259066057744386,'000000','报价行项目',1,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.add()','POST',1,'admin','管理员部门','/cpq/quote/lineitem','0:0:0:0:0:0:0:1','内网IP','{\"lineId\":null,\"quoteId\":\"2064149007508221954\",\"parentLineId\":null,\"lineNumber\":null,\"modelId\":1001,\"sbomLineId\":null,\"itemType\":\"PRODUCT\",\"itemCode\":\"ARC-160\",\"itemName\":\"ARC-160 紧凑型弧焊机器人\",\"quantity\":\"2\",\"unit\":null,\"listPrice\":null,\"unitPrice\":\"185000.00\",\"discountPct\":null,\"discountAmount\":null,\"netPrice\":null,\"lineTotal\":null,\"configurationJson\":null,\"customRequirements\":null,\"deliveryDays\":null,\"atpStatus\":null,\"sortOrder\":null,\"remark\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 16:11:28',15),(2064259066301014018,'000000','报价行项目',1,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.add()','POST',1,'admin','管理员部门','/cpq/quote/lineitem','0:0:0:0:0:0:0:1','内网IP','{\"lineId\":null,\"quoteId\":\"2064149007508221954\",\"parentLineId\":null,\"lineNumber\":null,\"modelId\":1001,\"sbomLineId\":null,\"itemType\":\"PRODUCT\",\"itemCode\":\"ARC-160\",\"itemName\":\"ARC-160 紧凑型弧焊机器人\",\"quantity\":\"3\",\"unit\":null,\"listPrice\":null,\"unitPrice\":\"185000.00\",\"discountPct\":null,\"discountAmount\":null,\"netPrice\":null,\"lineTotal\":null,\"configurationJson\":null,\"customRequirements\":null,\"deliveryDays\":null,\"atpStatus\":null,\"sortOrder\":null,\"remark\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 16:11:28',15),(2064259066552672258,'000000','报价行项目',3,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.remove()','DELETE',1,'admin','管理员部门','/cpq/quote/lineitem/2064259066015801345','0:0:0:0:0:0:0:1','内网IP','\"2064259066015801345\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 16:11:28',20),(2064259066795941889,'000000','报价行项目',1,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.add()','POST',1,'admin','管理员部门','/cpq/quote/lineitem','0:0:0:0:0:0:0:1','内网IP','{\"lineId\":null,\"quoteId\":\"2064149007508221954\",\"parentLineId\":null,\"lineNumber\":null,\"modelId\":1001,\"sbomLineId\":null,\"itemType\":\"PRODUCT\",\"itemCode\":\"ARC-160\",\"itemName\":\"ARC-160 紧凑型弧焊机器人\",\"quantity\":\"4\",\"unit\":null,\"listPrice\":null,\"unitPrice\":\"185000.00\",\"discountPct\":null,\"discountAmount\":null,\"netPrice\":null,\"lineTotal\":null,\"configurationJson\":null,\"customRequirements\":null,\"deliveryDays\":null,\"atpStatus\":null,\"sortOrder\":null,\"remark\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 16:11:28',15),(2064259067345395714,'000000','报价行项目',3,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.remove()','DELETE',1,'admin','管理员部门','/cpq/quote/lineitem/2064259065562816513','0:0:0:0:0:0:0:1','内网IP','\"2064259065562816513\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 16:11:28',9),(2064259067420893186,'000000','报价行项目',3,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.remove()','DELETE',1,'admin','管理员部门','/cpq/quote/lineitem/2064259066267459585','0:0:0:0:0:0:0:1','内网IP','\"2064259066267459585\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 16:11:28',9),(2064259067488002049,'000000','报价行项目',3,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.remove()','DELETE',1,'admin','管理员部门','/cpq/quote/lineitem/2064259066766581761','0:0:0:0:0:0:0:1','内网IP','\"2064259066766581761\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 16:11:28',7),(2064259306995343362,'000000','报价行项目',1,'org.dromara.cpq.quote.controller.CpqQuoteLineItemController.add()','POST',1,'admin','管理员部门','/cpq/quote/lineitem','0:0:0:0:0:0:0:1','内网IP','{\"lineId\":null,\"quoteId\":\"2064149007508221954\",\"parentLineId\":null,\"lineNumber\":null,\"modelId\":1001,\"sbomLineId\":null,\"itemType\":\"PRODUCT\",\"itemCode\":\"ARC-160\",\"itemName\":\"ARC-160 紧凑型弧焊机器人\",\"quantity\":\"1\",\"unit\":null,\"listPrice\":null,\"unitPrice\":\"185000.00\",\"discountPct\":null,\"discountAmount\":null,\"netPrice\":null,\"lineTotal\":null,\"configurationJson\":null,\"customRequirements\":null,\"deliveryDays\":null,\"atpStatus\":null,\"sortOrder\":null,\"remark\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 16:12:26',56),(2064320384160788481,'000000','ABAC策略',1,'org.dromara.cpq.controller.CpqAbacPolicyController.add()','POST',1,'admin','管理员部门','/cpq/abac/policy','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"policyId\":null,\"policyName\":\"TestPolicy\",\"policyType\":\"COST_VISIBILITY\",\"subjectType\":\"ROLE\",\"subjectValue\":\"test_role\",\"attributeKey\":\"cost_visibility_level\",\"attributeValue\":\"1\",\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 20:15:07',127),(2064320388397035522,'000000','ABAC策略',1,'org.dromara.cpq.controller.CpqAbacPolicyController.add()','POST',1,'admin','管理员部门','/cpq/abac/policy','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"policyId\":\"2064320383745552386\",\"policyName\":\"TestPolicyUpdated\",\"policyType\":\"COST_VISIBILITY\",\"subjectType\":\"ROLE\",\"subjectValue\":\"test_role\",\"attributeKey\":\"cost_visibility_level\",\"attributeValue\":\"2\",\"status\":\"0\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'2064320383745552386\' for key \'cpq_abac_policy.PRIMARY\'\n### The error may exist in org/dromara/cpq/mapper/CpqAbacPolicyMapper.java (best guess)\n### The error may involve org.dromara.cpq.mapper.CpqAbacPolicyMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_abac_policy (policy_id, policy_name, policy_type, subject_type, subject_value, attribute_key, attribute_value, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'2064320383745552386\' for key \'cpq_abac_policy.PRIMARY\'\n; Duplicate entry \'2064320383745552386\' for key \'cpq_abac_policy.PRIMARY\'','2026-06-09 20:15:08',668),(2064320607863992321,'000000','ABAC策略',1,'org.dromara.cpq.controller.CpqAbacPolicyController.add()','POST',1,'admin','管理员部门','/cpq/abac/policy','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"policyId\":null,\"policyName\":\"TestABAC\",\"policyType\":\"COST_VISIBILITY\",\"subjectType\":\"ROLE\",\"subjectValue\":\"test_r\",\"attributeKey\":\"cost_visibility_level\",\"attributeValue\":\"1\",\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 20:16:01',29),(2064320608828682242,'000000','ABAC策略',2,'org.dromara.cpq.controller.CpqAbacPolicyController.edit()','PUT',1,'admin','管理员部门','/cpq/abac/policy','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"policyId\":\"2064320607767523329\",\"policyName\":\"TestABACv2\",\"policyType\":\"COST_VISIBILITY\",\"subjectType\":\"ROLE\",\"subjectValue\":\"test_r\",\"attributeKey\":\"cost_visibility_level\",\"attributeValue\":\"2\",\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 20:16:01',76),(2064320609646571521,'000000','ABAC策略',3,'org.dromara.cpq.controller.CpqAbacPolicyController.remove()','DELETE',1,'admin','管理员部门','/cpq/abac/policy/2064320607767523329','0:0:0:0:0:0:0:1','内网IP','\"2064320607767523329\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 20:16:01',83),(2064344859082256386,'000000','ABAC策略',1,'org.dromara.cpq.controller.CpqAbacPolicyController.add()','POST',1,'admin','管理员部门','/cpq/abac/policy','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"policyId\":null,\"policyName\":\"TenantIsolationTest\",\"policyType\":\"COST_VISIBILITY\",\"subjectType\":\"ROLE\",\"subjectValue\":\"test_role\",\"attributeKey\":\"isolation_test\",\"attributeValue\":\"A\",\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 21:52:23',119),(2064344868544606210,'000000','ABAC策略',3,'org.dromara.cpq.controller.CpqAbacPolicyController.remove()','DELETE',1,'admin','管理员部门','/cpq/abac/policy/2064344858658631682','0:0:0:0:0:0:0:1','内网IP','\"2064344858658631682\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 21:52:25',21),(2064344941563244545,'000000','ABAC策略',1,'org.dromara.cpq.controller.CpqAbacPolicyController.add()','POST',1,'admin','管理员部门','/cpq/abac/policy','0:0:0:0:0:0:0:1','内网IP','{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"tenantId\":null,\"policyId\":null,\"policyName\":\"TenantIsolationTest\",\"policyType\":\"COST_VISIBILITY\",\"subjectType\":\"ROLE\",\"subjectValue\":\"test_role\",\"attributeKey\":\"isolation_test\",\"attributeValue\":\"A\",\"status\":\"0\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 21:52:42',14),(2064344947670151170,'000000','ABAC策略',3,'org.dromara.cpq.controller.CpqAbacPolicyController.remove()','DELETE',1,'admin','管理员部门','/cpq/abac/policy/2064344941512912897','0:0:0:0:0:0:0:1','内网IP','\"2064344941512912897\"','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 21:52:44',10),(2064360480964665345,'000000','报价单',2,'org.dromara.cpq.quote.controller.CpqQuoteController.edit()','PUT',1,'admin','管理员部门','/cpq/quote/header','0:0:0:0:0:0:0:1','内网IP','{\"quoteId\":1,\"quoteNumber\":\"QTE-20260609-0001\",\"opportunityId\":null,\"accountId\":1,\"accountName\":\"测试客户1\",\"quoteType\":\"STANDARD\",\"currency\":\"CNY\",\"subtotal\":null,\"discountTotal\":null,\"taxTotal\":null,\"grandTotal\":null,\"status\":\"DRAFT\",\"validUntil\":null,\"approvalChainId\":null,\"createdBy\":null,\"createdByName\":null,\"submittedDate\":null,\"wonDate\":null,\"remark\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-09 22:54:27',191),(2064406061653221378,'000000','报价单',1,'org.dromara.cpq.quote.controller.CpqQuoteController.add()','POST',1,'admin','管理员部门','/cpq/quote/header','0:0:0:0:0:0:0:1','内网IP','{\"quoteId\":null,\"quoteNumber\":null,\"opportunityId\":null,\"accountId\":null,\"accountName\":null,\"quoteType\":\"QUICK\",\"currency\":null,\"subtotal\":null,\"discountTotal\":null,\"taxTotal\":null,\"grandTotal\":null,\"status\":null,\"validUntil\":null,\"approvalChainId\":null,\"createdBy\":null,\"createdByName\":null,\"submittedDate\":null,\"wonDate\":null,\"remark\":\"\"}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'account_id\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/quote/mapper/CpqQuoteMapper.java (best guess)\n### The error may involve org.dromara.cpq.quote.mapper.CpqQuoteMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_quote (quote_id, quote_number, quote_type, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'account_id\' doesn\'t have a default value\n; Field \'account_id\' doesn\'t have a default value','2026-06-10 01:55:35',628),(2065265900189179906,'000000','报价单',1,'org.dromara.cpq.quote.controller.CpqQuoteController.add()','POST',1,'admin','管理员部门','/cpq/quote/header','0:0:0:0:0:0:0:1','内网IP','{\"quoteId\":null,\"quoteNumber\":\"\",\"opportunityId\":null,\"accountId\":null,\"accountName\":null,\"quoteType\":\"STANDARD\",\"currency\":null,\"subtotal\":null,\"discountTotal\":null,\"taxTotal\":null,\"grandTotal\":null,\"status\":\"DRAFT\",\"validUntil\":null,\"approvalChainId\":null,\"createdBy\":null,\"createdByName\":null,\"submittedDate\":null,\"wonDate\":null,\"remark\":null}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'account_id\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/quote/mapper/CpqQuoteMapper.java (best guess)\n### The error may involve org.dromara.cpq.quote.mapper.CpqQuoteMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_quote (quote_id, quote_number, quote_type, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'account_id\' doesn\'t have a default value\n; Field \'account_id\' doesn\'t have a default value','2026-06-12 10:52:16',39),(2065265906409332737,'000000','报价单',1,'org.dromara.cpq.quote.controller.CpqQuoteController.add()','POST',1,'admin','管理员部门','/cpq/quote/header','0:0:0:0:0:0:0:1','内网IP','{\"quoteId\":null,\"quoteNumber\":\"\",\"opportunityId\":null,\"accountId\":null,\"accountName\":null,\"quoteType\":\"STANDARD\",\"currency\":null,\"subtotal\":null,\"discountTotal\":null,\"taxTotal\":null,\"grandTotal\":null,\"status\":\"DRAFT\",\"validUntil\":null,\"approvalChainId\":null,\"createdBy\":null,\"createdByName\":null,\"submittedDate\":null,\"wonDate\":null,\"remark\":null}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'account_id\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/quote/mapper/CpqQuoteMapper.java (best guess)\n### The error may involve org.dromara.cpq.quote.mapper.CpqQuoteMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_quote (quote_id, quote_number, quote_type, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'account_id\' doesn\'t have a default value\n; Field \'account_id\' doesn\'t have a default value','2026-06-12 10:52:18',10),(2065266071606190082,'000000','报价单',1,'org.dromara.cpq.quote.controller.CpqQuoteController.add()','POST',1,'admin','管理员部门','/cpq/quote/header','0:0:0:0:0:0:0:1','内网IP','{\"quoteId\":null,\"quoteNumber\":\"\",\"opportunityId\":null,\"accountId\":null,\"accountName\":null,\"quoteType\":\"STANDARD\",\"currency\":null,\"subtotal\":null,\"discountTotal\":null,\"taxTotal\":null,\"grandTotal\":null,\"status\":\"DRAFT\",\"validUntil\":null,\"approvalChainId\":null,\"createdBy\":null,\"createdByName\":null,\"submittedDate\":null,\"wonDate\":null,\"remark\":null}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'account_id\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/quote/mapper/CpqQuoteMapper.java (best guess)\n### The error may involve org.dromara.cpq.quote.mapper.CpqQuoteMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_quote (quote_id, quote_number, quote_type, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'account_id\' doesn\'t have a default value\n; Field \'account_id\' doesn\'t have a default value','2026-06-12 10:52:57',17),(2065266154275921922,'000000','报价单',1,'org.dromara.cpq.quote.controller.CpqQuoteController.add()','POST',1,'admin','管理员部门','/cpq/quote/header','0:0:0:0:0:0:0:1','内网IP','{\"quoteId\":null,\"quoteNumber\":\"\",\"opportunityId\":null,\"accountId\":null,\"accountName\":null,\"quoteType\":\"STANDARD\",\"currency\":null,\"subtotal\":null,\"discountTotal\":null,\"taxTotal\":null,\"grandTotal\":null,\"status\":\"DRAFT\",\"validUntil\":null,\"approvalChainId\":null,\"createdBy\":null,\"createdByName\":null,\"submittedDate\":null,\"wonDate\":null,\"remark\":null}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'account_id\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/quote/mapper/CpqQuoteMapper.java (best guess)\n### The error may involve org.dromara.cpq.quote.mapper.CpqQuoteMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_quote (quote_id, quote_number, quote_type, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'account_id\' doesn\'t have a default value\n; Field \'account_id\' doesn\'t have a default value','2026-06-12 10:53:17',10),(2065266188090400769,'000000','报价单',1,'org.dromara.cpq.quote.controller.CpqQuoteController.add()','POST',1,'admin','管理员部门','/cpq/quote/header','0:0:0:0:0:0:0:1','内网IP','{\"quoteId\":null,\"quoteNumber\":\"\",\"opportunityId\":null,\"accountId\":null,\"accountName\":null,\"quoteType\":\"STANDARD\",\"currency\":null,\"subtotal\":null,\"discountTotal\":null,\"taxTotal\":null,\"grandTotal\":null,\"status\":\"DRAFT\",\"validUntil\":null,\"approvalChainId\":null,\"createdBy\":null,\"createdByName\":null,\"submittedDate\":null,\"wonDate\":null,\"remark\":null}','',1,'\n### Error updating database.  Cause: java.sql.SQLException: Field \'account_id\' doesn\'t have a default value\n### The error may exist in org/dromara/cpq/quote/mapper/CpqQuoteMapper.java (best guess)\n### The error may involve org.dromara.cpq.quote.mapper.CpqQuoteMapper.insert-Inline\n### The error occurred while setting parameters\n### SQL: INSERT INTO cpq_quote (quote_id, quote_number, quote_type, status, create_dept, create_by, create_time, update_by, update_time, tenant_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, \'000000\')\n### Cause: java.sql.SQLException: Field \'account_id\' doesn\'t have a default value\n; Field \'account_id\' doesn\'t have a default value','2026-06-12 10:53:25',18),(2065266436242202626,'000000','报价单',1,'org.dromara.cpq.quote.controller.CpqQuoteController.add()','POST',1,'admin','管理员部门','/cpq/quote/header','0:0:0:0:0:0:0:1','内网IP','{\"quoteId\":null,\"quoteNumber\":null,\"opportunityId\":null,\"accountId\":1,\"accountName\":null,\"quoteType\":\"STANDARD\",\"currency\":null,\"subtotal\":null,\"discountTotal\":null,\"taxTotal\":null,\"grandTotal\":null,\"status\":null,\"validUntil\":null,\"approvalChainId\":null,\"createdBy\":null,\"createdByName\":null,\"submittedDate\":null,\"wonDate\":null,\"remark\":\"22\"}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-12 10:54:24',25),(2065801370719518722,'000000','报价单',2,'org.dromara.cpq.quote.controller.CpqQuoteController.edit()','PUT',1,'admin','管理员部门','/cpq/quote/header','0:0:0:0:0:0:0:1','内网IP','{\"quoteId\":\"2065266436183482369\",\"quoteNumber\":\"QTE-20260612-0007\",\"opportunityId\":null,\"accountId\":1,\"accountName\":\"gghh\",\"quoteType\":\"STANDARD\",\"currency\":\"CNY\",\"subtotal\":null,\"discountTotal\":null,\"taxTotal\":null,\"grandTotal\":null,\"status\":\"DRAFT\",\"validUntil\":null,\"approvalChainId\":null,\"createdBy\":null,\"createdByName\":null,\"submittedDate\":null,\"wonDate\":null,\"remark\":null}','{\"code\":200,\"msg\":\"操作成功\",\"data\":null}',0,'','2026-06-13 22:20:02',215);
UNLOCK TABLES;
LOCK TABLES `sys_logininfor` WRITE;
INSERT INTO `sys_logininfor` (`info_id`, `tenant_id`, `user_name`, `client_key`, `device_type`, `ipaddr`, `login_location`, `browser`, `os`, `status`, `msg`, `login_time`) VALUES (2063100035724558337,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','1','验证码已失效','2026-06-06 11:25:54'),(2063100484036943874,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 11:27:41'),(2063100625628258306,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 11:28:14'),(2063100656984875010,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 11:28:22'),(2063100961973690370,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 11:29:35'),(2063101118056325122,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 11:30:12'),(2063101348629798913,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 11:31:07'),(2063101573343830017,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 11:32:00'),(2063101835508801537,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 11:33:03'),(2063102009484337154,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 11:33:44'),(2063103113639059457,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 11:38:08'),(2063104591300747265,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 11:44:00'),(2063106801967390722,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 11:52:47'),(2063117980492193793,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 12:37:12'),(2063118059168948225,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 12:37:31'),(2063119210035634177,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 12:42:05'),(2063119367238148098,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 12:42:43'),(2063120158187413505,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 12:45:51'),(2063120286017216514,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 12:46:22'),(2063120887002259458,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 12:48:45'),(2063121029004615682,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 12:49:19'),(2063121513476087810,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 12:51:14'),(2063121656841592834,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 12:51:49'),(2063122142638465025,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 12:53:44'),(2063122161642856449,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 12:53:49'),(2063122207708897282,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 12:54:00'),(2063122228487479297,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 12:54:05'),(2063122549909577730,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 12:55:22'),(2063122570138705921,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 12:55:26'),(2063122665676562434,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 12:55:49'),(2063123347901079554,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 12:58:32'),(2063124037847310337,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 13:01:16'),(2063125616533004289,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 13:07:33'),(2063127837404389377,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 13:16:22'),(2063128668904185858,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-06 13:19:40'),(2063128674914623490,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 13:19:42'),(2063129601155358722,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-06 13:23:23'),(2063129607643947009,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 13:23:24'),(2063131020163899393,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 13:29:01'),(2063131069237256194,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 13:29:13'),(2063131274259030018,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 13:30:02'),(2063131288175730690,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 13:30:05'),(2063131333587460097,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 13:30:16'),(2063131346501722113,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 13:30:19'),(2063132140722544641,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 13:33:28'),(2063132860976816130,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 13:36:20'),(2063133010822520833,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 13:36:56'),(2063134494645641218,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-06 13:42:49'),(2063134500748353538,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 13:42:51'),(2063135420613746689,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 13:46:30'),(2063135587198918658,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 13:47:10'),(2063136057682386946,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-06 13:49:02'),(2063136063000764417,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 13:49:03'),(2063136364613165057,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-06 13:50:15'),(2063136369990262785,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 13:50:16'),(2063137244146130945,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 13:53:45'),(2063137327814107137,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 13:54:05'),(2063137510698344450,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 13:54:48'),(2063137511591731201,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 13:54:49'),(2063139007163097089,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 14:00:45'),(2063142355350151169,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 14:14:04'),(2063143239098392577,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-06 14:17:34'),(2063143245289185281,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 14:17:36'),(2063145905581023234,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 14:28:10'),(2063148023163478018,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 14:36:35'),(2063155918592630785,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-06 15:07:57'),(2063158787286851586,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 15:19:21'),(2063159342121967618,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-06 15:21:33'),(2063159348711219201,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 15:21:35'),(2063159568400474113,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 15:22:27'),(2063160211374694402,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-06 15:25:01'),(2063160216621768705,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 15:25:02'),(2063160450366136322,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 15:25:58'),(2063161080342208513,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-06 15:28:28'),(2063161086658830337,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 15:28:29'),(2063163109970108418,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 15:36:32'),(2063163729598832642,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 15:39:00'),(2063168473113387010,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 15:57:50'),(2063173331740614657,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 16:17:09'),(2063173354998030338,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-06 16:17:14'),(2063173359976669185,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 16:17:16'),(2063180030945878017,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-06 16:43:46'),(2063180037245722625,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 16:43:48'),(2063180988882968577,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 16:47:34'),(2063181147461214209,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-06 16:48:12'),(2063181151705849858,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 16:48:13'),(2063182692575698946,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 16:54:21'),(2063185662583332865,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-06 17:06:09'),(2063185667117375490,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 17:06:10'),(2063185870025220098,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-06 17:06:58'),(2063185875029024769,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 17:06:59'),(2063187041641127937,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 17:11:38'),(2063187284327751681,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-06 17:12:35'),(2063187288941486082,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 17:12:37'),(2063189701505146882,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-06 17:22:12'),(2063189711340789761,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 17:22:14'),(2063190485873549313,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-06 17:25:19'),(2063190491032543234,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 17:25:20'),(2063190901189337090,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-06 17:26:58'),(2063190906184753154,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 17:26:59'),(2063191201669275650,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 17:28:09'),(2063192086931660802,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 17:31:40'),(2063194782942191617,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 17:42:23'),(2063194855839195138,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 17:42:41'),(2063194935270924289,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 17:43:00'),(2063195011120717826,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 17:43:18'),(2063195885188505602,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-06 17:46:46'),(2063195890288779266,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 17:46:47'),(2063200231250812929,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 18:04:02'),(2063200974728945666,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 18:06:59'),(2063202355539955713,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 18:12:29'),(2063203565261123585,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 18:17:17'),(2063204584124653569,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 18:21:20'),(2063213821798195202,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 18:58:02'),(2063214226607251458,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 18:59:39'),(2063214299713970178,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 18:59:56'),(2063214352570589185,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 19:00:09'),(2063214386385068033,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 19:00:17'),(2063214422829375489,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 19:00:26'),(2063214463920971777,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 19:00:36'),(2063214795128381441,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 19:01:54'),(2063216207279177729,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 19:07:31'),(2063216274098634753,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 19:07:47'),(2063216578391195649,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 19:09:00'),(2063217478027505665,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 19:12:34'),(2063218360567787521,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 19:16:05'),(2063218504604381186,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 19:16:39'),(2063219357700648962,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-06 19:20:02'),(2063229435644276738,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 20:00:05'),(2063242903814467586,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-06 20:53:36'),(2063305370892599298,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 01:01:49'),(2063305405130702849,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 01:01:58'),(2063305497577357314,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 01:02:20'),(2063305541781127169,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 01:02:30'),(2063305600040009729,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 01:02:44'),(2063305691584888833,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 01:03:06'),(2063305736547827713,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 01:03:17'),(2063308824230854657,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 01:15:33'),(2063312223261257729,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 01:29:03'),(2063312300696498177,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 01:29:22'),(2063312349711134722,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 01:29:33'),(2063312435249770498,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 01:29:54'),(2063313207312060417,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 01:32:58'),(2063314854729834498,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 01:39:31'),(2063315131079942146,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 01:40:36'),(2063315183286444034,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 01:40:49'),(2063317041904164866,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 01:48:12'),(2063317154923880449,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 01:48:39'),(2063317216223633409,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 01:48:54'),(2063317294791335937,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 01:49:12'),(2063317350932094978,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 01:49:26'),(2063317985232494594,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 01:51:57'),(2063321352876924930,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-07 02:05:20'),(2063321360527335425,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 02:05:22'),(2063324742403039233,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-07 02:18:48'),(2063324747486535681,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 02:18:49'),(2063326853090103298,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 02:27:11'),(2063326936875520001,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-07 02:27:31'),(2063326943322165249,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 02:27:33'),(2063327778873659393,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-07 02:30:52'),(2063327784519192577,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 02:30:53'),(2063329619497832450,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-07 02:38:11'),(2063329625386635266,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 02:38:12'),(2063333683757436929,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-07 02:54:20'),(2063333691512705026,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 02:54:22'),(2063334178064465922,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 02:56:18'),(2063334206317297666,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 02:56:24'),(2063335574264381441,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-07 03:01:50'),(2063335580060909569,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 03:01:52'),(2063335872513036289,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 03:03:02'),(2063409762576748546,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 07:56:38'),(2063409807292223490,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 07:56:49'),(2063410513982115842,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 07:59:38'),(2063410902789902337,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 08:01:10'),(2063412048065581057,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 08:05:43'),(2063412437594787841,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 08:07:16'),(2063412997140107266,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 08:09:30'),(2063412997341433857,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-07 08:09:30'),(2063413003951656961,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 08:09:31'),(2063413004060708866,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-07 08:09:31'),(2063413081802133505,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 08:09:50'),(2063413081948934146,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-07 08:09:50'),(2063413139004051457,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 08:10:03'),(2063413139146657794,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-07 08:10:03'),(2063413431770664961,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 08:11:13'),(2063413735597658113,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 08:12:26'),(2063413984496046081,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 08:13:25'),(2063459619471478785,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 11:14:45'),(2063459645216116738,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 11:14:51'),(2063462936186703873,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 11:27:56'),(2063463260200882177,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 11:29:13'),(2063466154274836481,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 11:40:43'),(2063468365558042625,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-07 11:49:30'),(2063468374479327234,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 11:49:33'),(2063468388358279170,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-07 11:49:36'),(2063468396218404866,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 11:49:38'),(2063473933442076673,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-07 12:11:38'),(2063473943294496770,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 12:11:40'),(2063474931938086914,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-07 12:15:36'),(2063474938107908097,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 12:15:37'),(2063543163961200641,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 16:46:44'),(2063543916092182529,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 16:49:43'),(2063557483851927554,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 17:43:38'),(2063557609853014018,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 17:44:08'),(2063558332862943234,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 17:47:00'),(2063560104327237634,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 17:54:03'),(2063577401997643778,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-07 19:02:47'),(2063577421023006722,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 19:02:51'),(2063588137947877377,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 19:45:26'),(2063597632107282433,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 20:23:10'),(2063598279233863682,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 20:25:44'),(2063598862774796289,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 20:28:03'),(2063599165930700801,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 20:29:16'),(2063599233287028737,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-07 20:29:32'),(2063599407073820674,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 20:30:13'),(2063644948008763393,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-07 23:31:11'),(2063655278323642370,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-08 00:12:14'),(2063657505083858945,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-08 00:21:05'),(2063657665025253377,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-08 00:21:43'),(2063657911616774146,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-08 00:22:42'),(2063660484419624962,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-08 00:32:55'),(2063808265390104577,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-08 10:20:09'),(2063808834536185858,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-08 10:22:25'),(2063940514504744961,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-08 19:05:39'),(2063948978839371777,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-08 19:39:18'),(2063951214722170882,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-08 19:48:11'),(2063951245365755905,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-08 19:48:18'),(2063951294560747521,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-08 19:48:30'),(2063951409140744193,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-08 19:48:57'),(2063972787634061314,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-08 21:13:54'),(2063973964606095361,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-08 21:18:35'),(2063974502995345409,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-08 21:20:43'),(2063974549673754625,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-08 21:20:54'),(2063975528905326593,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-08 21:24:48'),(2063976432819781633,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-08 21:28:23'),(2063978564516069377,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-08 21:36:51'),(2063981506518335489,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-08 21:48:33'),(2063983853055287297,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-08 21:57:52'),(2063984727781539842,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-08 22:01:21'),(2063984753962385410,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-08 22:01:27'),(2063984771683319810,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-08 22:01:31'),(2063984777093971969,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-08 22:01:32'),(2063985060826054658,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-08 22:02:40'),(2063988428915126273,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-08 22:16:03'),(2064008863379644417,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-08 23:37:15'),(2064008903728848898,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-08 23:37:25'),(2064008960364535809,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-08 23:37:38'),(2064008998050357250,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-08 23:37:47'),(2064009035773927425,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-08 23:37:56'),(2064009079818313729,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-08 23:38:07'),(2064025474186633217,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-09 00:43:15'),(2064033569864441858,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-09 01:15:26'),(2064033581927260161,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-09 01:15:28'),(2064134623574646786,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 07:56:59'),(2064141127996448770,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 08:22:49'),(2064141481697910786,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 08:24:14'),(2064141837932732417,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-09 08:25:39'),(2064141899966488577,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 08:25:54'),(2064141962939768834,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 08:26:09'),(2064142043680120833,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 08:26:28'),(2064142338665521153,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 08:27:38'),(2064142368877092866,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 08:27:45'),(2064142879311306754,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 08:29:47'),(2064142895849447426,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 08:29:51'),(2064142913603936258,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 08:29:55'),(2064142930708307970,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 08:29:59'),(2064143143028170753,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 08:30:50'),(2064143479033864194,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 08:32:10'),(2064144071424778242,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 08:34:31'),(2064144207349587970,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 08:35:04'),(2064144482118443009,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-09 08:36:09'),(2064148461862825985,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 08:51:58'),(2064148595103281153,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 08:52:30'),(2064148655895523329,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 08:52:44'),(2064149001254514689,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 08:54:07'),(2064150335554891778,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-09 08:59:25'),(2064176885113335809,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-09 10:44:55'),(2064178752593637377,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 10:52:20'),(2064187223468716034,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 11:25:59'),(2064187485109399553,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 11:27:02'),(2064187686771535873,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 11:27:50'),(2064187775942438914,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 11:28:11'),(2064193689810415618,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 11:51:41'),(2064217535032635393,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-09 13:26:26'),(2064218123296354306,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 13:28:47'),(2064218927830970370,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 13:31:58'),(2064219204944441345,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 13:33:04'),(2064220191696400386,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 13:37:00'),(2064220559205511170,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 13:38:27'),(2064221796206424065,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 13:43:22'),(2064222034660995074,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 13:44:19'),(2064222366187171841,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 13:45:38'),(2064223742808076289,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 13:51:06'),(2064223818771116033,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 13:51:24'),(2064224858291613697,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 13:55:32'),(2064225145622409218,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 13:56:41'),(2064227864747749377,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-09 14:07:29'),(2064229804361691137,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 14:15:12'),(2064231596742979585,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 14:22:19'),(2064231792910577666,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 14:23:06'),(2064232585533370370,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 14:26:15'),(2064232759701843970,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 14:26:56'),(2064232926253461506,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 14:27:36'),(2064232926320570370,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 14:27:36'),(2064237582539046914,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 14:46:06'),(2064237808012247042,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-09 14:47:00'),(2064238755903979522,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-09 14:50:46'),(2064240737788116994,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-09 14:58:38'),(2064250800426729474,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 15:38:37'),(2064251519661797377,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 15:41:29'),(2064251755138412545,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-09 15:42:25'),(2064252306693582849,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 15:44:37'),(2064256478654558210,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 16:01:11'),(2064259063587299330,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 16:11:27'),(2064260690838839297,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-09 16:17:55'),(2064260697633611778,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-09 16:17:57'),(2064262813521567746,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-09 16:26:21'),(2064262823772446721,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-09 16:26:24'),(2064272093209456642,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 17:03:14'),(2064272938827280386,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 17:06:36'),(2064273928834076674,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 17:10:32'),(2064279406129483777,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 17:32:18'),(2064283451221114881,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 17:48:22'),(2064283850615324674,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 17:49:57'),(2064286888625209346,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 18:02:01'),(2064287838748311553,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 18:05:48'),(2064304626512982017,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 19:12:31'),(2064306154036555777,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-09 19:18:35'),(2064306771823980546,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-09 19:21:02'),(2064308945735938049,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 19:29:40'),(2064309099339739137,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-09 19:30:17'),(2064310206883459074,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-09 19:34:41'),(2064310471065890818,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 19:35:44'),(2064317385849991169,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-09 20:03:12'),(2064320380633378818,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 20:15:07'),(2064320606286934017,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 20:16:00'),(2064320616739139586,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-09 20:16:03'),(2064344857492615169,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 21:52:22'),(2064344941290614786,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 21:52:42'),(2064345001378213890,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 21:52:57'),(2064345359013933058,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-09 21:54:22'),(2064345558545362945,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 21:55:10'),(2064357548168941570,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 22:42:48'),(2064357617957965826,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 22:43:05'),(2064357887576215553,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-09 22:44:09'),(2064360096825139201,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-09 22:52:56'),(2064360992590061569,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-09 22:56:29'),(2064368917924601857,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-09 23:27:59'),(2064404605936132097,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-10 01:49:47'),(2064405415424221186,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-10 01:53:00'),(2065249624179924993,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-12 09:47:36'),(2065249799833182209,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-12 09:48:17'),(2065262417197195266,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-12 10:38:26'),(2065269606758539266,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-12 11:07:00'),(2065285144343797762,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-12 12:08:44'),(2065285519587205122,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-12 12:10:14'),(2065300672173105153,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-12 13:10:26'),(2065632059992367105,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 11:07:15'),(2065640843166932994,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 11:42:09'),(2065658829437198338,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-13 12:53:38'),(2065658864501579777,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 12:53:46'),(2065667829109153793,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 13:29:23'),(2065673168147767297,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 13:50:36'),(2065674010703691777,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-13 13:53:57'),(2065674021600493569,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 13:54:00'),(2065676459434835970,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-13 14:03:41'),(2065676477872996353,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 14:03:45'),(2065680706276687873,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-13 14:20:34'),(2065680724630962178,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 14:20:38'),(2065682577192124417,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-13 14:28:00'),(2065682583546494977,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 14:28:01'),(2065684474770751490,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-13 14:35:32'),(2065684493183746049,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 14:35:36'),(2065685404526313474,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-13 14:39:14'),(2065685424675749890,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 14:39:18'),(2065686783185649665,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 14:44:42'),(2065694428730753026,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 15:15:05'),(2065768894206836737,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 20:10:59'),(2065770676333051905,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-13 20:18:04'),(2065770682494484481,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 20:18:06'),(2065772287180668930,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-13 20:24:28'),(2065772294227099650,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 20:24:30'),(2065773365011939329,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-13 20:28:45'),(2065773373241163778,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 20:28:47'),(2065773917888315394,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-13 20:30:57'),(2065773924649533442,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 20:30:59'),(2065778290676760578,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-13 20:48:19'),(2065778296716558338,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 20:48:21'),(2065778810065813506,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 20:50:23'),(2065779502771896321,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 20:53:08'),(2065780017538826241,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 20:55:11'),(2065780959877300226,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 20:58:56'),(2065781401453625346,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-13 21:00:41'),(2065781407690555394,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 21:00:43'),(2065793011555532801,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-13 21:46:49'),(2065793046334701569,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-13 21:46:57'),(2065793202601885698,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-13 21:47:35'),(2065793294859796481,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-13 21:47:57'),(2065793367735828482,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-13 21:48:14'),(2065793512787443713,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-13 21:48:49'),(2065793568177422337,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-13 21:49:02'),(2065793768488992770,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-13 21:49:50'),(2065793908566163457,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-13 21:50:23'),(2065793993572122625,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-13 21:50:43'),(2065794166616522753,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 21:51:25'),(2065795988915781633,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-13 21:58:39'),(2065795996255813634,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 21:58:41'),(2065796440478744577,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 22:00:27'),(2065797091308896257,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-13 22:03:02'),(2065797097055092738,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 22:03:03'),(2065799597686554625,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-13 22:12:59'),(2065799604112228353,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 22:13:01'),(2065807168438829057,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-13 22:43:04'),(2065807174826754050,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 22:43:06'),(2065811009108475906,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-13 22:58:20'),(2065811015949385729,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 22:58:22'),(2065814563915309057,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 23:12:28'),(2065818220350173186,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-13 23:26:59'),(2065818228122218497,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 23:27:01'),(2065823277334405121,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-13 23:47:05'),(2065823464110956545,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-13 23:47:50'),(2065823637386043394,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-13 23:48:31'),(2065823766880985089,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-13 23:49:02'),(2065823823575392258,'000000','admin','','','0:0:0:0:0:0:0:1','内网IP','Unknown','Unknown','0','登录成功','2026-06-13 23:49:15'),(2065823985743962114,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-13 23:49:54'),(2065823992765227010,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 23:49:56'),(2065825173088509954,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-13 23:54:37'),(2065828417508483073,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','退出成功','2026-06-14 00:07:31'),(2065828425376997377,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-14 00:07:33'),(2065871062364594177,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-14 02:56:58'),(2066248012920791041,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-15 03:54:50'),(2066351439633981442,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-15 10:45:49'),(2066357085410435074,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-15 11:08:15'),(2066367362596085762,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-15 11:49:05'),(2066384055724728321,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-15 12:55:25'),(2066384102172450817,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-06-15 12:55:36'),(2072262745213915138,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-07-01 18:15:14'),(2072299627813556225,'000000','admin','pc','pc','0:0:0:0:0:0:0:1','内网IP','Chrome','OSX','0','登录成功','2026-07-01 20:41:47');
UNLOCK TABLES;
LOCK TABLES `sys_oss` WRITE;
UNLOCK TABLES;
LOCK TABLES `flow_category` WRITE;
INSERT INTO `flow_category` (`category_id`, `tenant_id`, `parent_id`, `ancestors`, `category_name`, `order_num`, `del_flag`, `create_dept`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES (100,'000000',0,'0','OA审批',0,'0',103,1,'2026-06-06 03:02:23',NULL,NULL),(101,'000000',100,'0,100','假勤管理',0,'0',103,1,'2026-06-06 03:02:23',NULL,NULL),(102,'000000',100,'0,100','人事管理',1,'0',103,1,'2026-06-06 03:02:23',NULL,NULL),(103,'000000',101,'0,100,101','请假',0,'0',103,1,'2026-06-06 03:02:23',NULL,NULL),(104,'000000',101,'0,100,101','出差',1,'0',103,1,'2026-06-06 03:02:23',NULL,NULL),(105,'000000',101,'0,100,101','加班',2,'0',103,1,'2026-06-06 03:02:23',NULL,NULL),(106,'000000',101,'0,100,101','换班',3,'0',103,1,'2026-06-06 03:02:23',NULL,NULL),(107,'000000',101,'0,100,101','外出',4,'0',103,1,'2026-06-06 03:02:23',NULL,NULL),(108,'000000',102,'0,100,102','转正',1,'0',103,1,'2026-06-06 03:02:23',NULL,NULL),(109,'000000',102,'0,100,102','离职',2,'0',103,1,'2026-06-06 03:02:23',NULL,NULL);
UNLOCK TABLES;
LOCK TABLES `flow_definition` WRITE;
UNLOCK TABLES;
