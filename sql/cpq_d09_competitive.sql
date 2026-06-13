-- S14 竞品对标模块 DDL（4张表）
DROP TABLE IF EXISTS cpq_competitor;
CREATE TABLE cpq_competitor (
    competitor_id       BIGINT NOT NULL COMMENT '竞品ID',
    tenant_id           VARCHAR(20) DEFAULT '000000',
    competitor_name     VARCHAR(100) NOT NULL COMMENT '竞品名称',
    competitor_code     VARCHAR(64) DEFAULT NULL COMMENT '竞品编码',
    industry            VARCHAR(100) DEFAULT NULL COMMENT '行业',
    website             VARCHAR(200) DEFAULT NULL COMMENT '官网',
    description         TEXT DEFAULT NULL COMMENT '描述',
    market_share        DECIMAL(5,2) DEFAULT NULL COMMENT '市场份额(%)',
    status              CHAR(1) DEFAULT '0' COMMENT '状态(0正常 1停用)',
    del_flag            CHAR(1) DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept         BIGINT DEFAULT NULL,
    create_by           BIGINT DEFAULT NULL,
    create_time         DATETIME DEFAULT NULL,
    update_by           BIGINT DEFAULT NULL,
    update_time         DATETIME DEFAULT NULL,
    remark              VARCHAR(500) DEFAULT NULL,
    PRIMARY KEY (competitor_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='竞品库';

DROP TABLE IF EXISTS cpq_competitor_product;
CREATE TABLE cpq_competitor_product (
    product_id          BIGINT NOT NULL COMMENT '竞品产品ID',
    tenant_id           VARCHAR(20) DEFAULT '000000',
    competitor_id       BIGINT NOT NULL COMMENT '竞品ID',
    product_name        VARCHAR(200) NOT NULL COMMENT '产品名称',
    product_code        VARCHAR(64) DEFAULT NULL,
    category            VARCHAR(100) DEFAULT NULL COMMENT '产品类别',
    base_price          DECIMAL(18,2) DEFAULT NULL COMMENT '基准价格',
    specs_json          JSON DEFAULT NULL COMMENT '规格参数JSON',
    strengths           TEXT DEFAULT NULL COMMENT '优势',
    weaknesses          TEXT DEFAULT NULL COMMENT '劣势',
    status              CHAR(1) DEFAULT '0',
    del_flag            CHAR(1) DEFAULT '0' COMMENT '0正常 2删除',
    create_dept         BIGINT DEFAULT NULL,
    create_by           BIGINT DEFAULT NULL,
    create_time         DATETIME DEFAULT NULL,
    update_by           BIGINT DEFAULT NULL,
    update_time         DATETIME DEFAULT NULL,
    remark              VARCHAR(500) DEFAULT NULL,
    PRIMARY KEY (product_id),
    INDEX idx_competitor (tenant_id, competitor_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='竞品产品';

DROP TABLE IF EXISTS cpq_comparison;
CREATE TABLE cpq_comparison (
    comparison_id       BIGINT NOT NULL COMMENT '对比记录ID',
    tenant_id           VARCHAR(20) DEFAULT '000000',
    our_product_id      BIGINT NOT NULL COMMENT '我方产品ID',
    competitor_product_id BIGINT NOT NULL COMMENT '竞品产品ID',
    radar_data_json     JSON DEFAULT NULL COMMENT '雷达图数据JSON',
    win_rate            DECIMAL(5,2) DEFAULT NULL COMMENT '赢率(%)',
    price_diff_pct      DECIMAL(5,2) DEFAULT NULL COMMENT '价差(%)',
    comparison_notes    TEXT DEFAULT NULL COMMENT '对比备注',
    compared_by         BIGINT DEFAULT NULL COMMENT '对比人',
    compared_time       DATETIME DEFAULT NULL,
    del_flag            CHAR(1) DEFAULT '0' COMMENT '0正常 2删除',
    create_dept         BIGINT DEFAULT NULL,
    create_by           BIGINT DEFAULT NULL,
    create_time         DATETIME DEFAULT NULL,
    update_by           BIGINT DEFAULT NULL,
    update_time         DATETIME DEFAULT NULL,
    remark              VARCHAR(500) DEFAULT NULL,
    PRIMARY KEY (comparison_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='竞品对比记录';

DROP TABLE IF EXISTS cpq_recommendation;
CREATE TABLE cpq_recommendation (
    recommendation_id   BIGINT NOT NULL COMMENT '推荐策略ID',
    tenant_id           VARCHAR(20) DEFAULT '000000',
    scenario            VARCHAR(200) NOT NULL COMMENT '应用场景',
    our_product_id      BIGINT NOT NULL COMMENT '推荐我方产品ID',
    competitor_product_id BIGINT DEFAULT NULL COMMENT '替代竞品产品ID',
    strategy_type       VARCHAR(50) NOT NULL COMMENT '策略类型: PRICE/FEATURE/BUNDLE/SERVICE',
    strategy_desc       TEXT DEFAULT NULL COMMENT '策略描述',
    priority            INT DEFAULT 0 COMMENT '优先级',
    effective_from      DATE DEFAULT NULL,
    effective_to        DATE DEFAULT NULL,
    status              CHAR(1) DEFAULT '0',
    del_flag            CHAR(1) DEFAULT '0' COMMENT '0正常 2删除',
    create_dept         BIGINT DEFAULT NULL,
    create_by           BIGINT DEFAULT NULL,
    create_time         DATETIME DEFAULT NULL,
    update_by           BIGINT DEFAULT NULL,
    update_time         DATETIME DEFAULT NULL,
    remark              VARCHAR(500) DEFAULT NULL,
    PRIMARY KEY (recommendation_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='竞品推荐策略';
