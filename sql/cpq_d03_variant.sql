-- =====================================================
-- CPQ 混合架构 — 阶段2：变体实体化
-- 创建 cpq_product_variant 表 + 修改现有表 + 种子数据
-- =====================================================

-- 1. 创建产品变体表
DROP TABLE IF EXISTS cpq_product_variant;
CREATE TABLE cpq_product_variant (
    variant_id       BIGINT         NOT NULL COMMENT '变体ID',
    tenant_id        VARCHAR(20)    DEFAULT '000000' COMMENT '租户ID',
    model_id         BIGINT         NOT NULL COMMENT '所属产品型号ID(FK→cpq_product_model)',
    variant_code     VARCHAR(100)   NOT NULL COMMENT '变体编码(如 RW-SWEEP-S1P-WHT)',
    variant_name     VARCHAR(200)   NOT NULL COMMENT '变体名称(如 SweepBot S1 Pro 白色款)',
    attributes       TEXT           NOT NULL COMMENT '属性值集合(JSON): {"attr_name":"attr_value", ...}',
    default_bom_id   BIGINT         DEFAULT NULL COMMENT '此变体对应的确定SBOM Header ID(FK→cpq_sbom_header)',
    base_price       DECIMAL(18,2)  DEFAULT NULL COMMENT '变体基础价(可继承model.base_price或覆盖)',
    thumbnail_url    VARCHAR(500)   DEFAULT NULL COMMENT '变体缩略图',
    is_default       CHAR(1)        DEFAULT '0' COMMENT '是否默认变体(0否 1是)',
    status           CHAR(1)        DEFAULT '0' COMMENT '状态(0正常 1停用)',
    del_flag         CHAR(1)        DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept      BIGINT         DEFAULT NULL COMMENT '创建部门',
    create_by        BIGINT         DEFAULT NULL COMMENT '创建者',
    create_time      DATETIME       DEFAULT NULL COMMENT '创建时间',
    update_by        BIGINT         DEFAULT NULL COMMENT '更新者',
    update_time      DATETIME       DEFAULT NULL COMMENT '更新时间',
    remark           VARCHAR(500)   DEFAULT NULL COMMENT '备注',
    PRIMARY KEY (variant_id),
    UNIQUE KEY uk_variant_code (tenant_id, variant_code),
    UNIQUE KEY uk_model_attrs (tenant_id, model_id, attributes(255)),
    INDEX idx_model (tenant_id, model_id),
    INDEX idx_default (tenant_id, model_id, is_default)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ产品变体(型号+属性组合→确定的可售卖SKU)';

-- 2. 价格手册条目表增加 variant_id
ALTER TABLE cpq_price_book_entry ADD COLUMN variant_id BIGINT DEFAULT NULL COMMENT '变体ID(FK→cpq_product_variant, NULL=模型级定价)';
ALTER TABLE cpq_price_book_entry ADD INDEX idx_entry_variant (tenant_id, variant_id);

-- 3. 渠道价格表增加 variant_id
ALTER TABLE cpq_channel_price ADD COLUMN variant_id BIGINT DEFAULT NULL COMMENT '变体ID(FK→cpq_product_variant, NULL=模型级定价)';
ALTER TABLE cpq_channel_price ADD INDEX idx_channel_variant (tenant_id, variant_id);

-- =====================================================
-- 种子数据：智元机器人变体
-- =====================================================

-- SweepBot S1 Pro (STANDARD, model_id 需要替换为实际ID): 3个颜色变体
-- INSERT INTO cpq_product_variant VALUES
-- (30000, '000000', 1001, 'RW-SWEEP-S1P-WHT', 'SweepBot S1 Pro 白色款', '{"颜色":"白色"}', NULL, 4999.00, NULL, '1', '0', '0', NULL, NULL, NOW(), NULL, NOW(), NULL),
-- (30001, '000000', 1001, 'RW-SWEEP-S1P-BLK', 'SweepBot S1 Pro 黑色款', '{"颜色":"黑色"}', NULL, 4999.00, NULL, '0', '0', '0', NULL, NULL, NOW(), NULL, NOW(), NULL),
-- (30002, '000000', 1001, 'RW-SWEEP-S1P-SLV', 'SweepBot S1 Pro 银色限量', '{"颜色":"银色"}', NULL, 5299.00, NULL, '0', '0', '0', NULL, NULL, NOW(), NULL, NOW(), NULL),
--
-- NaviBot V1 Ultra (ATO): 2个通信方式变体
-- (30010, '000000', 1002, 'RW-NAVI-V1U-WIFI', 'NaviBot V1 Ultra WiFi版', '{"通信方式":"WiFi 6"}', NULL, 7999.00, NULL, '1', '0', '0', NULL, NULL, NOW(), NULL, NOW(), NULL),
-- (30011, '000000', 1002, 'RW-NAVI-V1U-5G', 'NaviBot V1 Ultra 5G版', '{"通信方式":"5G"}', NULL, 8499.00, NULL, '0', '0', '0', NULL, NULL, NOW(), NULL, NOW(), NULL);

-- 种子数据需要根据实际产品 model_id 填充，上方为模板示例
