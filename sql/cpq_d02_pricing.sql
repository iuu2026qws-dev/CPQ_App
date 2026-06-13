-- =============================================
-- CPQ 模块 DDL — D02 定价数据域（6张表）
-- 基于：M-CPQ_Product_Data_Architecture.md §五
-- 规范：tenant_id VARCHAR(20) 对齐 RuoYi-Vue-Plus TenantEntity
-- 目标 Sprint：S3（定价与配置引擎）
-- =============================================

-- 1. 价格手册表 (cpq_price_book)
DROP TABLE IF EXISTS cpq_price_book;
CREATE TABLE cpq_price_book (
    price_book_id   BIGINT       NOT NULL COMMENT '价格手册ID',
    tenant_id       VARCHAR(20)  DEFAULT '000000' COMMENT '租户ID',
    book_name       VARCHAR(200) NOT NULL COMMENT '手册名称',
    book_type       VARCHAR(20)  NOT NULL COMMENT '类型: STANDARD/CHANNEL/PROMOTION/REGION',
    currency        VARCHAR(3)   DEFAULT 'CNY' COMMENT '币种',
    effective_date  DATE         NOT NULL COMMENT '生效日期',
    expiry_date     DATE         DEFAULT NULL COMMENT '失效日期',
    priority        INT          DEFAULT 0 COMMENT '优先级(越大越高, 用于多手册冲突时选择)',
    status          CHAR(1)      DEFAULT '0' COMMENT '状态(0正常 1停用)',
    del_flag        CHAR(1)      DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept     BIGINT       DEFAULT NULL,
    create_by       BIGINT       DEFAULT NULL,
    create_time     DATETIME     DEFAULT NULL,
    update_by       BIGINT       DEFAULT NULL,
    update_time     DATETIME     DEFAULT NULL,
    remark          VARCHAR(500) DEFAULT NULL,
    PRIMARY KEY (price_book_id),
    INDEX idx_tenant (tenant_id),
    INDEX idx_type (tenant_id, book_type, status),
    INDEX idx_date (tenant_id, effective_date, expiry_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ价格手册';

-- 2. 价格手册条目表 (cpq_price_book_entry)
DROP TABLE IF EXISTS cpq_price_book_entry;
CREATE TABLE cpq_price_book_entry (
    entry_id        BIGINT         NOT NULL COMMENT '条目ID',
    tenant_id       VARCHAR(20)    DEFAULT '000000' COMMENT '租户ID',
    price_book_id   BIGINT         NOT NULL COMMENT '价格手册ID(FK→cpq_price_book)',
    model_id        BIGINT         NOT NULL COMMENT '产品ID(FK→cpq_product_model)',
    item_code       VARCHAR(100)   DEFAULT NULL COMMENT '物料编码(可选, 用于配件级定价)',
    region_code     VARCHAR(20)    DEFAULT NULL COMMENT '区域代码',
    channel_code    VARCHAR(20)    DEFAULT NULL COMMENT '渠道代码',
    list_price      DECIMAL(18,2)  NOT NULL COMMENT '目录价',
    cost_price      DECIMAL(18,2)  DEFAULT NULL COMMENT '成本价(ABAC保护: L0不可见, L3全可见)',
    min_price       DECIMAL(18,2)  DEFAULT NULL COMMENT '最低销售价(低于此价需审批)',
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
    PRIMARY KEY (entry_id),
    INDEX idx_book (tenant_id, price_book_id),
    INDEX idx_model (tenant_id, model_id),
    INDEX idx_region (tenant_id, region_code),
    INDEX idx_channel (tenant_id, channel_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ价格手册条目';

-- 3. 定价规则表 (cpq_price_rule)
DROP TABLE IF EXISTS cpq_price_rule;
CREATE TABLE cpq_price_rule (
    price_rule_id       BIGINT         NOT NULL COMMENT '规则ID',
    tenant_id           VARCHAR(20)    DEFAULT '000000' COMMENT '租户ID',
    rule_name           VARCHAR(200)   NOT NULL COMMENT '规则名称',
    rule_type           VARCHAR(30)    NOT NULL COMMENT '类型: DISCOUNT/MARKUP/PROMOTION/CONTRACT',
    priority            INT            DEFAULT 0 COMMENT '优先级(越大越高, 多条规则匹配时取最高优先级)',
    condition_json      JSON           DEFAULT NULL COMMENT '条件(JSON): {product_ids, regions, channels, customer_types, date_range, quantity_range, ...}',
    action_json         JSON           NOT NULL COMMENT '动作(JSON): {adjustment_type, adjustment_value, adjustment_unit}',
    approval_threshold  DECIMAL(18,2)  DEFAULT NULL COMMENT '触发审批的金额/折扣阈值',
    effective_date      DATE           NOT NULL COMMENT '生效日期',
    expiry_date         DATE           DEFAULT NULL COMMENT '失效日期',
    status              CHAR(1)        DEFAULT '0' COMMENT '状态(0正常 1停用)',
    del_flag            CHAR(1)        DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept         BIGINT         DEFAULT NULL,
    create_by           BIGINT         DEFAULT NULL,
    create_time         DATETIME       DEFAULT NULL,
    update_by           BIGINT         DEFAULT NULL,
    update_time         DATETIME       DEFAULT NULL,
    remark              VARCHAR(500)   DEFAULT NULL,
    PRIMARY KEY (price_rule_id),
    INDEX idx_tenant_type (tenant_id, rule_type, status),
    INDEX idx_date (tenant_id, effective_date, expiry_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ定价规则';

-- 4. 阶梯定价表 (cpq_volume_tier)
DROP TABLE IF EXISTS cpq_volume_tier;
CREATE TABLE cpq_volume_tier (
    tier_id             BIGINT         NOT NULL COMMENT '阶梯ID',
    tenant_id           VARCHAR(20)    DEFAULT '000000' COMMENT '租户ID',
    price_book_entry_id BIGINT         NOT NULL COMMENT '价格手册条目ID(FK→cpq_price_book_entry)',
    min_quantity        DECIMAL(12,4)  NOT NULL COMMENT '最小数量',
    max_quantity        DECIMAL(12,4)  DEFAULT NULL COMMENT '最大数量(NULL=无限)',
    unit_price          DECIMAL(18,2)  NOT NULL COMMENT '阶梯单价',
    sort_order          INT            DEFAULT 0 COMMENT '排序号',
    del_flag            CHAR(1)        DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept         BIGINT         DEFAULT NULL,
    create_by           BIGINT         DEFAULT NULL,
    create_time         DATETIME       DEFAULT NULL,
    update_by           BIGINT         DEFAULT NULL,
    update_time         DATETIME       DEFAULT NULL,
    remark              VARCHAR(500)   DEFAULT NULL,
    PRIMARY KEY (tier_id),
    INDEX idx_entry (tenant_id, price_book_entry_id),
    INDEX idx_quantity (tenant_id, price_book_entry_id, min_quantity)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ阶梯定价(100个以下¥100 / 100-500个¥85 / 500+个¥70)';

-- 5. 渠道价格表 (cpq_channel_price)
DROP TABLE IF EXISTS cpq_channel_price;
CREATE TABLE cpq_channel_price (
    channel_price_id    BIGINT         NOT NULL COMMENT '渠道价格ID',
    tenant_id           VARCHAR(20)    DEFAULT '000000' COMMENT '租户ID',
    channel_code        VARCHAR(50)    NOT NULL COMMENT '渠道代码(FK→cpq_channel)',
    model_id            BIGINT         NOT NULL COMMENT '产品ID(FK→cpq_product_model)',
    channel_list_price  DECIMAL(18,2)  NOT NULL COMMENT '渠道目录价',
    channel_discount_pct DECIMAL(5,2)  DEFAULT NULL COMMENT '渠道折扣率(%)',
    effective_date      DATE           NOT NULL COMMENT '生效日期',
    expiry_date         DATE           DEFAULT NULL COMMENT '失效日期',
    status              CHAR(1)        DEFAULT '0' COMMENT '状态(0正常 1停用)',
    del_flag            CHAR(1)        DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept         BIGINT         DEFAULT NULL,
    create_by           BIGINT         DEFAULT NULL,
    create_time         DATETIME       DEFAULT NULL,
    update_by           BIGINT         DEFAULT NULL,
    update_time         DATETIME       DEFAULT NULL,
    remark              VARCHAR(500)   DEFAULT NULL,
    PRIMARY KEY (channel_price_id),
    INDEX idx_channel (tenant_id, channel_code),
    INDEX idx_model (tenant_id, model_id),
    INDEX idx_date (tenant_id, effective_date, expiry_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ渠道价格(渠道客户专属定价)';

-- 6. 汇率表 (cpq_currency_rate)
DROP TABLE IF EXISTS cpq_currency_rate;
CREATE TABLE cpq_currency_rate (
    rate_id         BIGINT         NOT NULL COMMENT '汇率ID',
    tenant_id       VARCHAR(20)    DEFAULT '000000' COMMENT '租户ID',
    from_currency   VARCHAR(3)     NOT NULL COMMENT '源币种',
    to_currency     VARCHAR(3)     NOT NULL COMMENT '目标币种',
    exchange_rate   DECIMAL(18,6)  NOT NULL COMMENT '汇率',
    effective_date  DATE           NOT NULL COMMENT '生效日期',
    status          CHAR(1)        DEFAULT '0' COMMENT '状态(0正常 1停用)',
    del_flag        CHAR(1)        DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept     BIGINT         DEFAULT NULL,
    create_by       BIGINT         DEFAULT NULL,
    create_time     DATETIME       DEFAULT NULL,
    update_by       BIGINT         DEFAULT NULL,
    update_time     DATETIME       DEFAULT NULL,
    remark          VARCHAR(500)   DEFAULT NULL,
    PRIMARY KEY (rate_id),
    INDEX idx_currency (tenant_id, from_currency, to_currency),
    INDEX idx_date (tenant_id, effective_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ汇率(多币种报价支持)';
