-- =============================================
-- CPQ 模块 DDL — D06 客户渠道数据域（4张表）
-- 基于：M-CPQ_Product_Data_Architecture.md
-- 规范：tenant_id VARCHAR(20) 对齐 RuoYi-Vue-Plus TenantEntity
-- 目标 Sprint：S5（客户渠道+集成+ATP引擎）
-- =============================================

-- 1. 客户表 (cpq_account)
DROP TABLE IF EXISTS cpq_account;
CREATE TABLE cpq_account (
    account_id      BIGINT       NOT NULL COMMENT '客户ID',
    tenant_id       VARCHAR(20)  DEFAULT '000000' COMMENT '租户ID',
    account_name    VARCHAR(200) NOT NULL COMMENT '客户名称',
    account_code    VARCHAR(50)  NOT NULL COMMENT '客户编码',
    account_type    VARCHAR(20)  DEFAULT NULL COMMENT '客户类型: DIRECT/CHANNEL/PARTNER/ENTERPRISE',
    industry        VARCHAR(50)  DEFAULT NULL COMMENT '行业',
    region          VARCHAR(50)  DEFAULT NULL COMMENT '区域',
    contact_name    VARCHAR(100) DEFAULT NULL COMMENT '联系人',
    contact_phone   VARCHAR(30)  DEFAULT NULL COMMENT '联系电话',
    contact_email   VARCHAR(100) DEFAULT NULL COMMENT '联系邮箱',
    address         VARCHAR(500) DEFAULT NULL COMMENT '地址',
    tax_id          VARCHAR(50)  DEFAULT NULL COMMENT '税号',
    status          CHAR(1)      DEFAULT '0' COMMENT '状态(0正常 1停用)',
    del_flag        CHAR(1)      DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept     BIGINT       DEFAULT NULL,
    create_by       BIGINT       DEFAULT NULL,
    create_time     DATETIME     DEFAULT NULL,
    update_by       BIGINT       DEFAULT NULL,
    update_time     DATETIME     DEFAULT NULL,
    remark          VARCHAR(500) DEFAULT NULL,
    PRIMARY KEY (account_id),
    UNIQUE KEY uk_tenant_code (tenant_id, account_code),
    INDEX idx_name (tenant_id, account_name),
    INDEX idx_region (tenant_id, region),
    INDEX idx_industry (tenant_id, industry)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ客户';

-- 2. 渠道表 (cpq_channel)
DROP TABLE IF EXISTS cpq_channel;
CREATE TABLE cpq_channel (
    channel_id      BIGINT       NOT NULL COMMENT '渠道ID',
    tenant_id       VARCHAR(20)  DEFAULT '000000' COMMENT '租户ID',
    channel_name    VARCHAR(200) NOT NULL COMMENT '渠道名称',
    channel_code    VARCHAR(50)  NOT NULL COMMENT '渠道编码',
    channel_type    VARCHAR(20)  DEFAULT NULL COMMENT '渠道类型: DIRECT/DISTRIBUTOR/RESELLER/SI/AGENT',
    partner_id      BIGINT       DEFAULT NULL COMMENT '合作伙伴ID(FK→cpq_account, 渠道商对应的客户记录)',
    region          VARCHAR(50)  DEFAULT NULL COMMENT '区域',
    status          CHAR(1)      DEFAULT '0' COMMENT '状态(0正常 1停用)',
    del_flag        CHAR(1)      DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept     BIGINT       DEFAULT NULL,
    create_by       BIGINT       DEFAULT NULL,
    create_time     DATETIME     DEFAULT NULL,
    update_by       BIGINT       DEFAULT NULL,
    update_time     DATETIME     DEFAULT NULL,
    remark          VARCHAR(500) DEFAULT NULL,
    PRIMARY KEY (channel_id),
    UNIQUE KEY uk_tenant_code (tenant_id, channel_code),
    INDEX idx_type (tenant_id, channel_type),
    INDEX idx_partner (tenant_id, partner_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ渠道';

-- 3. 协议价表 (cpq_agreement_price)
DROP TABLE IF EXISTS cpq_agreement_price;
CREATE TABLE cpq_agreement_price (
    agreement_id    BIGINT         NOT NULL COMMENT '协议价ID',
    tenant_id       VARCHAR(20)    DEFAULT '000000' COMMENT '租户ID',
    account_id      BIGINT         NOT NULL COMMENT '客户ID(FK→cpq_account)',
    model_id        BIGINT         NOT NULL COMMENT '产品ID(FK→cpq_product_model)',
    item_code       VARCHAR(100)   DEFAULT NULL COMMENT '物料编码(可选, 用于配件级协议价)',
    agreement_price DECIMAL(18,2)  NOT NULL COMMENT '协议价格',
    discount_pct    DECIMAL(5,2)   DEFAULT NULL COMMENT '协议折扣率(%)',
    effective_date  DATE           NOT NULL COMMENT '生效日期',
    expiry_date     DATE           DEFAULT NULL COMMENT '失效日期',
    status          CHAR(1)        DEFAULT '0' COMMENT '状态(0正常 1停用)',
    del_flag        CHAR(1)        DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept     BIGINT         DEFAULT NULL,
    create_by       BIGINT         DEFAULT NULL,
    create_time     DATETIME       DEFAULT NULL,
    update_by       BIGINT         DEFAULT NULL,
    update_time     DATETIME       DEFAULT NULL,
    remark          VARCHAR(500)   DEFAULT NULL,
    PRIMARY KEY (agreement_id),
    INDEX idx_account (tenant_id, account_id),
    INDEX idx_model (tenant_id, model_id),
    INDEX idx_date (tenant_id, effective_date, expiry_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ客户协议价(大客户/渠道商与厂商签订的固定价格协议)';

-- 4. 销售区域表 (cpq_territory)
DROP TABLE IF EXISTS cpq_territory;
CREATE TABLE cpq_territory (
    territory_id        BIGINT       NOT NULL COMMENT '区域ID',
    tenant_id           VARCHAR(20)  DEFAULT '000000' COMMENT '租户ID',
    territory_name      VARCHAR(200) NOT NULL COMMENT '区域名称',
    territory_code      VARCHAR(50)  NOT NULL COMMENT '区域编码',
    parent_territory_id BIGINT       DEFAULT NULL COMMENT '父区域ID(自引用, 支持大区→省→市层级)',
    region              VARCHAR(50)  DEFAULT NULL COMMENT '地理区域: CN_NORTH/CN_EAST/CN_SOUTH/CN_WEST/CN_CENTER/APAC/EMEA/AMER',
    manager_id          BIGINT       DEFAULT NULL COMMENT '区域经理(用户ID)',
    status              CHAR(1)      DEFAULT '0' COMMENT '状态(0正常 1停用)',
    del_flag            CHAR(1)      DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept         BIGINT       DEFAULT NULL,
    create_by           BIGINT       DEFAULT NULL,
    create_time         DATETIME     DEFAULT NULL,
    update_by           BIGINT       DEFAULT NULL,
    update_time         DATETIME     DEFAULT NULL,
    remark              VARCHAR(500) DEFAULT NULL,
    PRIMARY KEY (territory_id),
    UNIQUE KEY uk_tenant_code (tenant_id, territory_code),
    INDEX idx_parent (tenant_id, parent_territory_id),
    INDEX idx_region (tenant_id, region)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ销售区域(多层级树: 大区→省→市, 用于区域权限控制和区域定价)';
