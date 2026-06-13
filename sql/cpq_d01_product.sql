-- =============================================
-- CPQ 模块 DDL — D01 产品数据域（V2.0 对齐设计文档）
-- RuoYi-Vue-Plus 规范
-- 变更：表名/字段对齐设计文档，tenant_id 使用 VARCHAR(20) 对齐 RuoYi-Vue-Plus TenantEntity，表名/字段对齐 CPQ_后端功能设计.md
-- =============================================

-- 1. 产品分类表 (cpq_product_category) — 层级树，替代产品模型中的 L1/L2/L3 字符串字段
DROP TABLE IF EXISTS cpq_product_category;
CREATE TABLE cpq_product_category (
    category_id         BIGINT       NOT NULL COMMENT '分类ID',
    tenant_id           VARCHAR(20)  DEFAULT '000000' COMMENT '租户ID',
    parent_category_id  BIGINT       DEFAULT NULL COMMENT '父分类ID(自引用FK, NULL=根节点/L1产品族)',
    category_level      TINYINT      NOT NULL COMMENT '层级: 1=产品线(L2), 2=产品族(L1), 3=产品系列(L3)',
    category_code       VARCHAR(50)  NOT NULL COMMENT '分类编码',
    category_name       VARCHAR(100) NOT NULL COMMENT '分类名称',
    sort_order          INT          DEFAULT 0 COMMENT '排序号',
    status              CHAR(1)      DEFAULT '0' COMMENT '状态(0正常 1停用)',
    del_flag            CHAR(1)      DEFAULT '0' COMMENT '删除标志',
    create_dept         BIGINT       DEFAULT NULL,
    create_by           BIGINT       DEFAULT NULL,
    create_time         DATETIME     DEFAULT NULL,
    update_by           BIGINT       DEFAULT NULL,
    update_time         DATETIME     DEFAULT NULL,
    remark              VARCHAR(500) DEFAULT NULL,
    PRIMARY KEY (category_id),
    UNIQUE KEY uk_tenant_code (tenant_id, category_code),
    INDEX idx_parent (tenant_id, parent_category_id),
    INDEX idx_level (tenant_id, category_level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ产品分类(层级树, 替代product_model中L1/L2/L3字符串)';

-- 2. 产品目录表 (cpq_product_catalog)
DROP TABLE IF EXISTS cpq_product_catalog;
CREATE TABLE cpq_product_catalog (
    catalog_id      BIGINT       NOT NULL COMMENT '目录ID',
    tenant_id       VARCHAR(20)  DEFAULT '000000' COMMENT '租户ID',
    catalog_name    VARCHAR(100) NOT NULL COMMENT '目录名称',
    catalog_type    VARCHAR(20)  NOT NULL COMMENT '目录类型: SALES/CHANNEL/INTERNAL',
    effective_date  DATE         DEFAULT NULL COMMENT '生效日期',
    expiry_date     DATE         DEFAULT NULL COMMENT '失效日期',
    status          CHAR(1)      DEFAULT '0' COMMENT '状态(0正常 1停用)',
    del_flag        CHAR(1)      DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept     BIGINT       DEFAULT NULL COMMENT '创建部门',
    create_by       BIGINT       DEFAULT NULL COMMENT '创建者',
    create_time     DATETIME     DEFAULT NULL COMMENT '创建时间',
    update_by       BIGINT       DEFAULT NULL COMMENT '更新者',
    update_time     DATETIME     DEFAULT NULL COMMENT '更新时间',
    remark          VARCHAR(500) DEFAULT NULL COMMENT '备注',
    PRIMARY KEY (catalog_id),
    INDEX idx_tenant (tenant_id),
    INDEX idx_type (tenant_id, catalog_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ产品目录';

-- 3. 产品模型表 (cpq_product_model) — V1.2: L1/L2/L3 字符串字段替换为 category_id FK
DROP TABLE IF EXISTS cpq_product_model;
CREATE TABLE cpq_product_model (
    model_id            BIGINT         NOT NULL COMMENT '产品ID',
    tenant_id           VARCHAR(20)    DEFAULT '000000' COMMENT '租户ID',
    catalog_id          BIGINT         NOT NULL COMMENT '所属目录ID',
    category_id         BIGINT         NOT NULL COMMENT '产品分类ID(FK→cpq_product_category, 指向L3产品系列, 通过树向上获取L1/L2)',
    model_code          VARCHAR(100)   NOT NULL COMMENT '产品编码/型号(L4)',
    model_name          VARCHAR(200)   NOT NULL COMMENT '产品名称',
    description         TEXT           DEFAULT NULL COMMENT '产品描述',
    lifecycle_status    VARCHAR(20)    DEFAULT 'ACTIVE' COMMENT '生命周期: CONCEPT/DESIGN/PRE_RELEASE/ACTIVE/EOL_ANNOUNCED/LAST_TIME_BUY/DISCONTINUED/ARCHIVED',
    successor_model_id  BIGINT         DEFAULT NULL COMMENT '替代产品ID(自引用)',
    base_price          DECIMAL(18,2)  DEFAULT NULL COMMENT '基础目录价',
    currency            VARCHAR(3)     DEFAULT 'CNY' COMMENT '币种',
    min_order_qty       INT            DEFAULT 1 COMMENT '最小起订量',
    lead_time_days      INT            DEFAULT NULL COMMENT '标准交期(天)',
    config_type         VARCHAR(20)    DEFAULT 'STANDARD' COMMENT '配置类型: STANDARD/ATO/CTO/ETO/BUNDLE',
    default_bom_id      BIGINT         DEFAULT NULL COMMENT '默认SBOM Header ID',
    thumbnail_url       VARCHAR(500)   DEFAULT NULL COMMENT '产品缩略图(OSS路径)',
    status              CHAR(1)        DEFAULT '0',
    del_flag            CHAR(1)        DEFAULT '0',
    create_dept         BIGINT         DEFAULT NULL,
    create_by           BIGINT         DEFAULT NULL,
    create_time         DATETIME       DEFAULT NULL,
    update_by           BIGINT         DEFAULT NULL,
    update_time         DATETIME       DEFAULT NULL,
    remark              VARCHAR(500)   DEFAULT NULL,
    PRIMARY KEY (model_id),
    UNIQUE KEY uk_model_code (tenant_id, model_code),
    INDEX idx_catalog (tenant_id, catalog_id),
    INDEX idx_category (tenant_id, category_id),
    INDEX idx_lifecycle (tenant_id, lifecycle_status),
    INDEX idx_search (tenant_id, model_name, model_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ可销售产品';

-- 4. 产品属性表 (cpq_product_attribute)
DROP TABLE IF EXISTS cpq_product_attribute;
CREATE TABLE cpq_product_attribute (
    attribute_id    BIGINT       NOT NULL COMMENT '属性ID',
    tenant_id       VARCHAR(20)  DEFAULT '000000' COMMENT '租户ID',
    model_id        BIGINT       NOT NULL COMMENT '所属产品ID',
    attr_category   VARCHAR(100) NOT NULL COMMENT '属性分类(Feature Category)',
    attr_name       VARCHAR(100) NOT NULL COMMENT '属性名称(Feature)',
    attr_value      VARCHAR(200) DEFAULT NULL COMMENT '属性默认值(Option)',
    is_configurable CHAR(1)      DEFAULT '1' COMMENT '是否可配置(0否 1是)',
    is_required     CHAR(1)      DEFAULT '0' COMMENT '是否必选(0否 1是)',
    display_order   INT          DEFAULT 0 COMMENT '显示顺序',
    data_type       VARCHAR(20)  DEFAULT 'STRING' COMMENT '数据类型: STRING/NUMBER/BOOLEAN/ENUM',
    option_values   JSON         DEFAULT NULL COMMENT '可选项列表(JSON数组, data_type=ENUM时使用)',
    sort_order      INT          DEFAULT 0,
    del_flag        CHAR(1)      DEFAULT '0',
    create_dept     BIGINT       DEFAULT NULL,
    create_by       BIGINT       DEFAULT NULL,
    create_time     DATETIME     DEFAULT NULL,
    update_by       BIGINT       DEFAULT NULL,
    update_time     DATETIME     DEFAULT NULL,
    remark          VARCHAR(500) DEFAULT NULL,
    PRIMARY KEY (attribute_id),
    UNIQUE KEY uk_model_attr (tenant_id, model_id, attr_name),
    INDEX idx_model (tenant_id, model_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ产品属性';

-- 5. SBOM头表 (cpq_sbom_header)
DROP TABLE IF EXISTS cpq_sbom_header;
CREATE TABLE cpq_sbom_header (
    sbom_header_id  BIGINT       NOT NULL COMMENT 'SBOM头ID',
    tenant_id       VARCHAR(20)  DEFAULT '000000' COMMENT '租户ID',
    model_id        BIGINT       NOT NULL COMMENT '所属产品ID',
    sbom_name       VARCHAR(200) NOT NULL COMMENT 'SBOM名称',
    sbom_version    VARCHAR(20)  DEFAULT '1.0' COMMENT 'SBOM版本',
    status          CHAR(1)      DEFAULT '0',
    del_flag        CHAR(1)      DEFAULT '0',
    create_dept     BIGINT       DEFAULT NULL,
    create_by       BIGINT       DEFAULT NULL,
    create_time     DATETIME     DEFAULT NULL,
    update_by       BIGINT       DEFAULT NULL,
    update_time     DATETIME     DEFAULT NULL,
    remark          VARCHAR(500) DEFAULT NULL,
    PRIMARY KEY (sbom_header_id),
    INDEX idx_model (tenant_id, model_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ销售BOM头';

-- 6. SBOM行项目表 (cpq_sbom_line)
DROP TABLE IF EXISTS cpq_sbom_line;
CREATE TABLE cpq_sbom_line (
    sbom_line_id        BIGINT         NOT NULL COMMENT 'SBOM行ID',
    tenant_id           VARCHAR(20)    DEFAULT '000000' COMMENT '租户ID',
    sbom_header_id      BIGINT         NOT NULL COMMENT 'SBOM头ID',
    parent_line_id      BIGINT         DEFAULT NULL COMMENT '父行ID(多层级BOM)',
    line_number         INT            NOT NULL COMMENT '行号',
    item_code           VARCHAR(100)   NOT NULL COMMENT '物料编码',
    item_name           VARCHAR(500)   NOT NULL COMMENT '物料名称',
    item_type           VARCHAR(20)    NOT NULL COMMENT '类型: HOST/ACCESSORY/SERVICE/LICENSE/SOFTWARE/PACKAGE',
    quantity            DECIMAL(12,4)  DEFAULT 1 COMMENT '数量',
    unit                VARCHAR(10)    DEFAULT 'PCS' COMMENT '单位',
    is_required         CHAR(1)        DEFAULT '1' COMMENT '是否标配(0否 1是)',
    is_replaceable      CHAR(1)        DEFAULT '0' COMMENT '是否可替换(0否 1是)',
    replacement_group   VARCHAR(50)    DEFAULT NULL COMMENT '替换组',
    is_phantom          CHAR(1)        DEFAULT '0' COMMENT '是否虚项(0否 1是, Phantom Item)',
    min_qty             DECIMAL(12,4)  DEFAULT NULL COMMENT '最小数量',
    max_qty             DECIMAL(12,4)  DEFAULT NULL COMMENT '最大数量',
    price_impact        VARCHAR(10)    DEFAULT NULL COMMENT '价格影响: FIXED/VARIABLE/NONE',
    lead_time_days      INT            DEFAULT NULL COMMENT '交期(天)',
    sort_order          INT            DEFAULT 0,
    del_flag            CHAR(1)        DEFAULT '0',
    create_dept         BIGINT         DEFAULT NULL,
    create_by           BIGINT         DEFAULT NULL,
    create_time         DATETIME       DEFAULT NULL,
    update_by           BIGINT         DEFAULT NULL,
    update_time         DATETIME       DEFAULT NULL,
    remark              VARCHAR(500)   DEFAULT NULL,
    PRIMARY KEY (sbom_line_id),
    UNIQUE KEY uk_header_line (tenant_id, sbom_header_id, line_number),
    INDEX idx_header (tenant_id, sbom_header_id),
    INDEX idx_parent (tenant_id, parent_line_id),
    INDEX idx_type (tenant_id, item_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ销售BOM行';

-- 7. MBOM行项目表 (cpq_mbom_line) — 新增：SBOM→MBOM转换结果
DROP TABLE IF EXISTS cpq_mbom_line;
CREATE TABLE cpq_mbom_line (
    mbom_line_id        BIGINT         NOT NULL COMMENT 'MBOM行ID',
    tenant_id           VARCHAR(20)    DEFAULT '000000' COMMENT '租户ID',
    sbom_line_id        BIGINT         NOT NULL COMMENT '来源SBOM行ID',
    model_id            BIGINT         NOT NULL COMMENT '所属产品ID',
    parent_mbom_line_id BIGINT         DEFAULT NULL COMMENT '父MBOM行ID(多层级)',
    line_number         INT            NOT NULL COMMENT '行号',
    material_code       VARCHAR(100)   NOT NULL COMMENT '生产物料编码',
    material_desc       VARCHAR(500)   DEFAULT NULL COMMENT '物料描述',
    material_type       VARCHAR(20)    DEFAULT NULL COMMENT '物料类型: RAW/SEMI/FINISHED/PACKAGE',
    quantity            DECIMAL(12,4)  NOT NULL COMMENT '用量',
    unit                VARCHAR(10)    DEFAULT 'PCS',
    plant               VARCHAR(20)    DEFAULT NULL COMMENT '工厂代码(Plant-Specific BOM)',
    storage_location    VARCHAR(20)    DEFAULT NULL COMMENT '库存地点',
    requirement_type    CHAR(1)        DEFAULT 'M' COMMENT '需求类型: M必选/O可选',
    substitute_group    VARCHAR(50)    DEFAULT NULL COMMENT '替代组',
    substitute_priority INT            DEFAULT NULL COMMENT '替代优先级',
    cost_component      VARCHAR(20)    DEFAULT NULL COMMENT '成本归属: MATERIAL/LABOR/OVERHEAD/OUTSOURCE',
    lead_time_days      INT            DEFAULT NULL COMMENT '采购/生产交期(天)',
    moq                 DECIMAL(12,4)  DEFAULT NULL COMMENT '最小起订量',
    sort_order          INT            DEFAULT 0,
    del_flag            CHAR(1)        DEFAULT '0',
    create_dept         BIGINT         DEFAULT NULL,
    create_by           BIGINT         DEFAULT NULL,
    create_time         DATETIME       DEFAULT NULL,
    update_by           BIGINT         DEFAULT NULL,
    update_time         DATETIME       DEFAULT NULL,
    remark              VARCHAR(500)   DEFAULT NULL,
    PRIMARY KEY (mbom_line_id),
    INDEX idx_sbom (tenant_id, sbom_line_id),
    INDEX idx_model (tenant_id, model_id),
    INDEX idx_parent (tenant_id, parent_mbom_line_id),
    INDEX idx_plant (tenant_id, plant)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ制造BOM行';

-- 8. 产品生命周期日志表 (cpq_product_lifecycle_log) — 新增
DROP TABLE IF EXISTS cpq_product_lifecycle_log;
CREATE TABLE cpq_product_lifecycle_log (
    log_id          BIGINT       NOT NULL COMMENT '日志ID',
    tenant_id       VARCHAR(20)  DEFAULT '000000' COMMENT '租户ID',
    model_id        BIGINT       NOT NULL COMMENT '产品ID',
    from_status     VARCHAR(20)  DEFAULT NULL COMMENT '变更前状态',
    to_status       VARCHAR(20)  NOT NULL COMMENT '变更后状态',
    change_reason   VARCHAR(500) DEFAULT NULL COMMENT '变更原因',
    change_by       BIGINT       DEFAULT NULL COMMENT '变更人',
    change_time     DATETIME     NOT NULL COMMENT '变更时间',
    PRIMARY KEY (log_id),
    INDEX idx_model (tenant_id, model_id, change_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ产品生命周期变更日志';

-- 9. 产品替代关系表 (cpq_product_supersession)
DROP TABLE IF EXISTS cpq_product_supersession;
CREATE TABLE cpq_product_supersession (
    supersession_id      BIGINT       NOT NULL COMMENT '替代关系ID',
    tenant_id            VARCHAR(20)  DEFAULT '000000' COMMENT '租户ID',
    original_model_id    BIGINT       NOT NULL COMMENT '被替代产品ID',
    replacement_model_id BIGINT       NOT NULL COMMENT '替代产品ID',
    supersession_type    VARCHAR(20)  NOT NULL COMMENT '替代类型: FULL/CONDITIONAL/SPLIT/AGGREGATE',
    condition_expr       VARCHAR(500) DEFAULT NULL COMMENT '条件表达式(CONDITIONAL类型)',
    price_impact_pct     DECIMAL(5,2) DEFAULT NULL COMMENT '价格影响百分比',
    effective_date       DATE         DEFAULT NULL COMMENT '生效日期',
    status               CHAR(1)      DEFAULT '0',
    del_flag             CHAR(1)      DEFAULT '0',
    create_dept          BIGINT       DEFAULT NULL,
    create_by            BIGINT       DEFAULT NULL,
    create_time          DATETIME     DEFAULT NULL,
    update_by            BIGINT       DEFAULT NULL,
    update_time          DATETIME     DEFAULT NULL,
    remark               VARCHAR(500) DEFAULT NULL,
    PRIMARY KEY (supersession_id),
    INDEX idx_original (tenant_id, original_model_id),
    INDEX idx_replacement (tenant_id, replacement_model_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ产品替代关系';

-- 10. ABAC策略表 (cpq_abac_policy) — 新增，对应设计文档§2.2
DROP TABLE IF EXISTS cpq_abac_policy;
CREATE TABLE cpq_abac_policy (
    policy_id       BIGINT       NOT NULL COMMENT '策略ID',
    tenant_id       VARCHAR(20)  DEFAULT '000000' COMMENT '租户ID',
    policy_name     VARCHAR(100) NOT NULL COMMENT '策略名称',
    policy_type     VARCHAR(30)  NOT NULL COMMENT '策略类型: COST_VISIBILITY/REGION_SCOPE/PRODUCT_LINE_SCOPE',
    subject_type    VARCHAR(20)  NOT NULL COMMENT '主体类型: ROLE/USER/DEPT',
    subject_value   VARCHAR(100) NOT NULL COMMENT '主体值(role_key/user_id/dept_id)',
    attribute_key   VARCHAR(50)  NOT NULL COMMENT '属性键: cost_visibility_level/region_list/product_line_list',
    attribute_value VARCHAR(500) NOT NULL COMMENT '属性值: 0-3/csv列表/csv列表',
    status          CHAR(1)      DEFAULT '0' COMMENT '状态(0启用 1停用)',
    create_dept     BIGINT       DEFAULT NULL,
    create_by       BIGINT       DEFAULT NULL,
    create_time     DATETIME     DEFAULT NULL,
    update_by       BIGINT       DEFAULT NULL,
    update_time     DATETIME     DEFAULT NULL,
    remark          VARCHAR(500) DEFAULT NULL,
    PRIMARY KEY (policy_id),
    INDEX idx_tenant (tenant_id),
    INDEX idx_subject (tenant_id, subject_type, subject_value)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ ABAC策略表';

-- 11. 删除旧表（如果存在重命名的旧表）
DROP TABLE IF EXISTS cpq_product;
DROP TABLE IF EXISTS cpq_substitute;

-- =============================================
-- CPQ 模块 DDL — Bundle 产品捆绑域（V1.1 新增，Sprint 3 执行）
-- =============================================

-- 12. 捆绑包定义表 (cpq_bundle)
DROP TABLE IF EXISTS cpq_bundle;
CREATE TABLE cpq_bundle (
    bundle_id               BIGINT         NOT NULL COMMENT '捆绑包ID',
    tenant_id               VARCHAR(20)    DEFAULT '000000' COMMENT '租户ID',
    model_id                BIGINT         NOT NULL COMMENT '捆绑包产品ID(FK→cpq_product_model, config_type=BUNDLE)',
    bundle_type             VARCHAR(20)    NOT NULL COMMENT '捆绑类型: FIXED/CONFIGURABLE/SOLUTION',
    pricing_strategy        VARCHAR(20)    NOT NULL COMMENT '定价策略: BUNDLE_PRICE/SUM_COMPONENTS',
    bundle_discount_pct     DECIMAL(5,2)   DEFAULT NULL COMMENT '捆绑折扣率(%)',
    is_active               CHAR(1)        DEFAULT '1' COMMENT '是否启用(1是 0否)',
    description             VARCHAR(1000)  DEFAULT NULL COMMENT '捆绑描述',
    del_flag                CHAR(1)        DEFAULT '0',
    create_dept             BIGINT         DEFAULT NULL,
    create_by               BIGINT         DEFAULT NULL,
    create_time             DATETIME       DEFAULT NULL,
    update_by               BIGINT         DEFAULT NULL,
    update_time             DATETIME       DEFAULT NULL,
    remark                  VARCHAR(500)   DEFAULT NULL,
    PRIMARY KEY (bundle_id),
    UNIQUE KEY uk_model (tenant_id, model_id),
    INDEX idx_active (tenant_id, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ产品捆绑包';

-- 13. 捆绑选项组表 (cpq_bundle_option_group)
DROP TABLE IF EXISTS cpq_bundle_option_group;
CREATE TABLE cpq_bundle_option_group (
    option_group_id     BIGINT       NOT NULL COMMENT '选项组ID',
    tenant_id           VARCHAR(20)  DEFAULT '000000' COMMENT '租户ID',
    bundle_id           BIGINT       NOT NULL COMMENT '捆绑包ID',
    group_name          VARCHAR(100) NOT NULL COMMENT '选项组名称',
    group_code          VARCHAR(50)  DEFAULT NULL COMMENT '选项组编码',
    min_selections      INT          DEFAULT 0 COMMENT '最少选择数',
    max_selections      INT          DEFAULT 1 COMMENT '最多选择数',
    is_required         CHAR(1)      DEFAULT '1' COMMENT '是否必选(1是 0否)',
    sort_order          INT          DEFAULT 0,
    del_flag            CHAR(1)      DEFAULT '0',
    create_dept         BIGINT       DEFAULT NULL,
    create_by           BIGINT       DEFAULT NULL,
    create_time         DATETIME     DEFAULT NULL,
    update_by           BIGINT       DEFAULT NULL,
    update_time         DATETIME     DEFAULT NULL,
    remark              VARCHAR(500) DEFAULT NULL,
    PRIMARY KEY (option_group_id),
    INDEX idx_bundle (tenant_id, bundle_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ捆绑选项组';

-- 14. 捆绑选项表 (cpq_bundle_option)
DROP TABLE IF EXISTS cpq_bundle_option;
CREATE TABLE cpq_bundle_option (
    option_id               BIGINT         NOT NULL COMMENT '选项ID',
    tenant_id               VARCHAR(20)    DEFAULT '000000' COMMENT '租户ID',
    option_group_id         BIGINT         NOT NULL COMMENT '选项组ID',
    component_model_id      BIGINT         NOT NULL COMMENT '组件产品ID(FK→cpq_product_model)',
    quantity                DECIMAL(12,4)  DEFAULT 1 COMMENT '默认数量',
    unit                    VARCHAR(10)    DEFAULT 'PCS' COMMENT '单位',
    is_default              CHAR(1)        DEFAULT '0' COMMENT '是否默认选中',
    price_modifier_type     VARCHAR(20)    DEFAULT 'NONE' COMMENT '价格调整类型: NONE/FIXED_AMOUNT/PERCENT/INCLUDE',
    price_modifier_value    DECIMAL(18,2)  DEFAULT NULL COMMENT '价格调整数值',
    sort_order              INT            DEFAULT 0,
    del_flag                CHAR(1)        DEFAULT '0',
    create_dept             BIGINT         DEFAULT NULL,
    create_by               BIGINT         DEFAULT NULL,
    create_time             DATETIME       DEFAULT NULL,
    update_by               BIGINT         DEFAULT NULL,
    update_time             DATETIME       DEFAULT NULL,
    remark                  VARCHAR(500)   DEFAULT NULL,
    PRIMARY KEY (option_id),
    INDEX idx_group (tenant_id, option_group_id),
    INDEX idx_component (tenant_id, component_model_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ捆绑选项';
