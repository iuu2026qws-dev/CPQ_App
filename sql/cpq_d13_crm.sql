-- cpq_d13_crm.sql — CRM信息模块 DDL

-- ========== 变更现有表：cpq_account ==========
-- MySQL 5.7 不支持 IF NOT EXISTS，使用存储过程安全添加列
DROP PROCEDURE IF EXISTS add_column_if_not_exists;
DELIMITER $$
CREATE PROCEDURE add_column_if_not_exists(IN tableName VARCHAR(100), IN colName VARCHAR(100), IN colDef VARCHAR(500))
BEGIN
    IF NOT EXISTS (
        SELECT * FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = tableName AND COLUMN_NAME = colName
    ) THEN
        SET @sql = CONCAT('ALTER TABLE ', tableName, ' ADD COLUMN ', colName, ' ', colDef);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$
DELIMITER ;

CALL add_column_if_not_exists('cpq_account', 'legal_representative', 'VARCHAR(100) DEFAULT NULL COMMENT ''法人代表'' AFTER contact_email');
CALL add_column_if_not_exists('cpq_account', 'unified_social_credit_code', 'VARCHAR(50) DEFAULT NULL COMMENT ''统一社会信用代码'' AFTER legal_representative');
DROP PROCEDURE IF EXISTS add_column_if_not_exists;

-- ========== 商机表 ==========
DROP TABLE IF EXISTS cpq_crm_opportunity;
CREATE TABLE cpq_crm_opportunity (
    opportunity_id      BIGINT          NOT NULL COMMENT '商机ID',
    tenant_id           VARCHAR(20)     DEFAULT '000000' COMMENT '租户ID',
    opportunity_name    VARCHAR(200)    NOT NULL COMMENT '商机名称',
    opportunity_code    VARCHAR(50)     NOT NULL COMMENT '商机编码',
    account_id          BIGINT          NOT NULL COMMENT '关联客户ID(FK→cpq_account)',
    stage               VARCHAR(30)     NOT NULL DEFAULT 'PROSPECTING' COMMENT '销售阶段',
    close_date          DATE            DEFAULT NULL COMMENT '预计关闭日期',
    amount              DECIMAL(18,2)   DEFAULT NULL COMMENT '预计金额',
    probability         DECIMAL(5,2)    DEFAULT NULL COMMENT '赢单概率(%)',
    opportunity_type    VARCHAR(30)     DEFAULT NULL COMMENT '商机类型',
    lead_source         VARCHAR(30)     DEFAULT NULL COMMENT '线索来源',
    next_step           VARCHAR(255)    DEFAULT NULL COMMENT '下一步计划',
    owner_id            BIGINT          DEFAULT NULL COMMENT '负责人(用户ID)',
    contact_name        VARCHAR(100)    DEFAULT NULL COMMENT '主要联系人',
    contact_phone       VARCHAR(30)     DEFAULT NULL COMMENT '联系电话',
    description         VARCHAR(1000)   DEFAULT NULL COMMENT '商机描述',
    is_closed           CHAR(1)         DEFAULT '0' COMMENT '是否关闭(0进行中 1已关闭)',
    closed_reason       VARCHAR(500)    DEFAULT NULL COMMENT '关闭原因(丢单时填写)',
    status              CHAR(1)         DEFAULT '0' COMMENT '状态(0正常 1停用)',
    del_flag            CHAR(1)         DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept         BIGINT          DEFAULT NULL,
    create_by           BIGINT          DEFAULT NULL,
    create_time         DATETIME        DEFAULT NULL,
    update_by           BIGINT          DEFAULT NULL,
    update_time         DATETIME        DEFAULT NULL,
    remark              VARCHAR(500)    DEFAULT NULL,
    PRIMARY KEY (opportunity_id),
    UNIQUE KEY uk_tenant_code (tenant_id, opportunity_code),
    INDEX idx_account (tenant_id, account_id),
    INDEX idx_owner (tenant_id, owner_id),
    INDEX idx_stage (tenant_id, stage),
    INDEX idx_close_date (tenant_id, close_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ商机';

-- ========== 合同表 ==========
DROP TABLE IF EXISTS cpq_crm_contract;
CREATE TABLE cpq_crm_contract (
    contract_id         BIGINT          NOT NULL COMMENT '合同ID',
    tenant_id           VARCHAR(20)     DEFAULT '000000' COMMENT '租户ID',
    contract_number     VARCHAR(50)     NOT NULL COMMENT '合同编号',
    contract_name       VARCHAR(200)    NOT NULL COMMENT '合同名称',
    account_id          BIGINT          NOT NULL COMMENT '关联客户ID(FK→cpq_account)',
    opportunity_id      BIGINT          DEFAULT NULL COMMENT '关联商机ID(FK→cpq_crm_opportunity)',
    contract_type       VARCHAR(20)     NOT NULL DEFAULT 'PROJECT' COMMENT '合同类型: PROJECT(单项目制)/FRAMEWORK(框架合同)',
    status              VARCHAR(20)     NOT NULL DEFAULT 'DRAFT' COMMENT '合同状态',
    start_date          DATE            DEFAULT NULL COMMENT '合同开始日期',
    end_date            DATE            DEFAULT NULL COMMENT '合同结束日期',
    total_amount        DECIMAL(18,2)   DEFAULT NULL COMMENT '合同总金额',
    signed_date         DATE            DEFAULT NULL COMMENT '签订日期',
    signing_party       VARCHAR(200)    DEFAULT NULL COMMENT '签约主体',
    payment_terms       VARCHAR(500)    DEFAULT NULL COMMENT '付款条款',
    owner_id            BIGINT          DEFAULT NULL COMMENT '负责人(用户ID)',
    description         VARCHAR(1000)   DEFAULT NULL COMMENT '合同描述',
    del_flag            CHAR(1)         DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept         BIGINT          DEFAULT NULL,
    create_by           BIGINT          DEFAULT NULL,
    create_time         DATETIME        DEFAULT NULL,
    update_by           BIGINT          DEFAULT NULL,
    update_time         DATETIME        DEFAULT NULL,
    remark              VARCHAR(500)    DEFAULT NULL,
    PRIMARY KEY (contract_id),
    UNIQUE KEY uk_tenant_number (tenant_id, contract_number),
    INDEX idx_account (tenant_id, account_id),
    INDEX idx_opportunity (tenant_id, opportunity_id),
    INDEX idx_status (tenant_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ合同';

-- ========== 订单表 ==========
DROP TABLE IF EXISTS cpq_crm_order;
CREATE TABLE cpq_crm_order (
    order_id            BIGINT          NOT NULL COMMENT '订单ID',
    tenant_id           VARCHAR(20)     DEFAULT '000000' COMMENT '租户ID',
    order_number        VARCHAR(50)     NOT NULL COMMENT '订单编号',
    order_name          VARCHAR(200)    DEFAULT NULL COMMENT '订单名称',
    contract_id         BIGINT          NOT NULL COMMENT '关联合同ID(FK→cpq_crm_contract)',
    account_id          BIGINT          NOT NULL COMMENT '关联客户ID(FK→cpq_account)',
    quote_id            BIGINT          DEFAULT NULL COMMENT '关联报价单ID(FK→cpq_quote)',
    order_type          VARCHAR(20)     DEFAULT NULL COMMENT '订单类型: STANDARD/RUSH/RENEWAL',
    status              VARCHAR(20)     NOT NULL DEFAULT 'DRAFT' COMMENT '订单状态',
    order_date          DATE            DEFAULT NULL COMMENT '订单日期',
    total_amount        DECIMAL(18,2)   DEFAULT NULL COMMENT '订单总金额',
    currency            VARCHAR(10)     DEFAULT 'CNY' COMMENT '币种',
    delivery_date       DATE            DEFAULT NULL COMMENT '期望交付日期',
    shipping_address    VARCHAR(500)    DEFAULT NULL COMMENT '收货地址',
    billing_address     VARCHAR(500)    DEFAULT NULL COMMENT '账单地址',
    owner_id            BIGINT          DEFAULT NULL COMMENT '负责人(用户ID)',
    description         VARCHAR(1000)   DEFAULT NULL COMMENT '订单描述',
    del_flag            CHAR(1)         DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept         BIGINT          DEFAULT NULL,
    create_by           BIGINT          DEFAULT NULL,
    create_time         DATETIME        DEFAULT NULL,
    update_by           BIGINT          DEFAULT NULL,
    update_time         DATETIME        DEFAULT NULL,
    remark              VARCHAR(500)    DEFAULT NULL,
    PRIMARY KEY (order_id),
    UNIQUE KEY uk_tenant_number (tenant_id, order_number),
    INDEX idx_contract (tenant_id, contract_id),
    INDEX idx_account (tenant_id, account_id),
    INDEX idx_quote (tenant_id, quote_id),
    INDEX idx_status (tenant_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ订单';

-- ========== 订单明细表 ==========
DROP TABLE IF EXISTS cpq_crm_order_line;
CREATE TABLE cpq_crm_order_line (
    line_id             BIGINT          NOT NULL COMMENT '明细ID',
    tenant_id           VARCHAR(20)     DEFAULT '000000' COMMENT '租户ID',
    order_id            BIGINT          NOT NULL COMMENT '关联订单ID(FK→cpq_crm_order)',
    line_number         INT             NOT NULL DEFAULT 1 COMMENT '行号',
    source_type         VARCHAR(20)     NOT NULL COMMENT '来源类型: QUOTE_LINE(报价行)/MANUAL(手动添加)',
    source_id           BIGINT          DEFAULT NULL COMMENT '来源行ID(报价行ID等)',
    product_code        VARCHAR(100)    DEFAULT NULL COMMENT '产品编码',
    product_name        VARCHAR(200)    DEFAULT NULL COMMENT '产品名称',
    model_id            BIGINT          DEFAULT NULL COMMENT '产品模型ID',
    quantity            DECIMAL(18,4)   NOT NULL COMMENT '数量',
    unit                VARCHAR(20)     DEFAULT NULL COMMENT '单位',
    unit_price          DECIMAL(18,2)   DEFAULT NULL COMMENT '单价',
    line_amount         DECIMAL(18,2)   DEFAULT NULL COMMENT '行金额',
    discount_pct        DECIMAL(5,2)    DEFAULT NULL COMMENT '折扣率(%)',
    tax_rate            DECIMAL(5,2)    DEFAULT NULL COMMENT '税率(%)',
    delivery_schedule   VARCHAR(200)    DEFAULT NULL COMMENT '交付计划说明',
    del_flag            CHAR(1)         DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept         BIGINT          DEFAULT NULL,
    create_by           BIGINT          DEFAULT NULL,
    create_time         DATETIME        DEFAULT NULL,
    update_by           BIGINT          DEFAULT NULL,
    update_time         DATETIME        DEFAULT NULL,
    remark              VARCHAR(500)    DEFAULT NULL,
    PRIMARY KEY (line_id),
    INDEX idx_order (tenant_id, order_id),
    INDEX idx_model (tenant_id, model_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ订单明细(来自报价配置清单)';

-- ========== 销售活动表 ==========
DROP TABLE IF EXISTS cpq_crm_activity;
CREATE TABLE cpq_crm_activity (
    activity_id         BIGINT          NOT NULL COMMENT '活动ID',
    tenant_id           VARCHAR(20)     DEFAULT '000000' COMMENT '租户ID',
    opportunity_id      BIGINT          NOT NULL COMMENT '关联商机ID(FK→cpq_crm_opportunity)',
    account_id          BIGINT          NOT NULL COMMENT '关联客户ID(FK→cpq_account)',
    activity_type       VARCHAR(30)     NOT NULL COMMENT '活动类型: CALL/MEETING/EMAIL/VISIT/DEMO/NEGOTIATION/SYSTEM/OTHER',
    subject             VARCHAR(200)    NOT NULL COMMENT '活动主题',
    activity_date       DATE            NOT NULL COMMENT '活动日期',
    activity_time       TIME            DEFAULT NULL COMMENT '活动时间',
    duration_minutes    INT             DEFAULT NULL COMMENT '持续时长(分钟)',
    participants        VARCHAR(500)    DEFAULT NULL COMMENT '参与人(逗号分隔姓名)',
    result              VARCHAR(1000)   DEFAULT NULL COMMENT '活动结果/纪要',
    next_plan           VARCHAR(500)    DEFAULT NULL COMMENT '下一步计划',
    owner_id            BIGINT          DEFAULT NULL COMMENT '负责人(用户ID)',
    del_flag            CHAR(1)         DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept         BIGINT          DEFAULT NULL,
    create_by           BIGINT          DEFAULT NULL,
    create_time         DATETIME        DEFAULT NULL,
    update_by           BIGINT          DEFAULT NULL,
    update_time         DATETIME        DEFAULT NULL,
    remark              VARCHAR(500)    DEFAULT NULL,
    PRIMARY KEY (activity_id),
    INDEX idx_opportunity (tenant_id, opportunity_id),
    INDEX idx_account (tenant_id, account_id),
    INDEX idx_date (tenant_id, activity_date),
    INDEX idx_owner (tenant_id, owner_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ销售活动(商机跟进记录)';
