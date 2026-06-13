-- =============================================
-- CPQ 模块 DDL — D03 配置引擎数据域（5张表）
-- 基于：M-CPQ_Product_Data_Architecture.md §四
-- 规范：tenant_id VARCHAR(20) 对齐 RuoYi-Vue-Plus TenantEntity
-- 目标 Sprint：S3（定价与配置引擎）
-- =============================================

-- 1. 配置规则表 (cpq_config_rule)
DROP TABLE IF EXISTS cpq_config_rule;
CREATE TABLE cpq_config_rule (
    rule_id         BIGINT       NOT NULL COMMENT '规则ID',
    tenant_id       VARCHAR(20)  DEFAULT '000000' COMMENT '租户ID',
    rule_name       VARCHAR(200) NOT NULL COMMENT '规则名称',
    rule_type       VARCHAR(30)  NOT NULL COMMENT '类型: VALIDATION(阻止错误组合)/SELECTION(自动添加推荐)/ALERT(通知销售)/VISIBILITY(隐藏无关项)',
    model_id        BIGINT       DEFAULT NULL COMMENT '适用产品ID(FK→cpq_product_model, 为空表示全局规则)',
    condition_expr  TEXT         NOT NULL COMMENT '条件表达式(JSON/DSL, 描述何时触发此规则)',
    action_expr     TEXT         NOT NULL COMMENT '动作表达式(JSON/DSL, 描述触发后执行的动作)',
    error_message   VARCHAR(500) DEFAULT NULL COMMENT '违反规则时的提示信息',
    severity        VARCHAR(10)  DEFAULT 'ERROR' COMMENT '严重级别: ERROR/WARNING/INFO',
    priority        INT          DEFAULT 0 COMMENT '优先级(越大越高)',
    effective_date  DATE         NOT NULL COMMENT '生效日期',
    expiry_date     DATE         DEFAULT NULL COMMENT '失效日期',
    status          CHAR(1)      DEFAULT '0' COMMENT '状态(0正常 1停用)',
    del_flag        CHAR(1)      DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept     BIGINT       DEFAULT NULL,
    create_by       BIGINT       DEFAULT NULL,
    create_time     DATETIME     DEFAULT NULL,
    update_by       BIGINT       DEFAULT NULL,
    update_time     DATETIME     DEFAULT NULL,
    remark          VARCHAR(500) DEFAULT NULL,
    PRIMARY KEY (rule_id),
    INDEX idx_model (tenant_id, model_id),
    INDEX idx_type (tenant_id, rule_type),
    INDEX idx_active (tenant_id, status, effective_date, expiry_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ配置规则(CSP约束求解)';

-- 2. 变体BOM表 (cpq_variant_bom) — 150% BOM
DROP TABLE IF EXISTS cpq_variant_bom;
CREATE TABLE cpq_variant_bom (
    variant_id              BIGINT         NOT NULL COMMENT '变体ID',
    tenant_id               VARCHAR(20)    DEFAULT '000000' COMMENT '租户ID',
    model_id                BIGINT         NOT NULL COMMENT '产品ID(FK→cpq_product_model)',
    sbom_line_id            BIGINT         DEFAULT NULL COMMENT '关联SBOM行ID(FK→cpq_sbom_line)',
    material_code           VARCHAR(100)   NOT NULL COMMENT '物料编码',
    quantity                DECIMAL(12,4)  NOT NULL COMMENT '用量',
    effectivity_condition   TEXT           NOT NULL COMMENT '有效性条件(JSON): {attr_name: value, ...}, 满足条件时此物料生效',
    is_default              CHAR(1)        DEFAULT '0' COMMENT '是否默认变体',
    sort_order              INT            DEFAULT 0 COMMENT '排序号',
    del_flag                CHAR(1)        DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept             BIGINT         DEFAULT NULL,
    create_by               BIGINT         DEFAULT NULL,
    create_time             DATETIME       DEFAULT NULL,
    update_by               BIGINT         DEFAULT NULL,
    update_time             DATETIME       DEFAULT NULL,
    remark                  VARCHAR(500)   DEFAULT NULL,
    PRIMARY KEY (variant_id),
    INDEX idx_model (tenant_id, model_id),
    INDEX idx_sbom_line (tenant_id, sbom_line_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ变体BOM(150% BOM: 全平台变体列出→CSP求解过滤为100%)';

-- 3. 属性→物料映射表 (cpq_attribute_mapping)
DROP TABLE IF EXISTS cpq_attribute_mapping;
CREATE TABLE cpq_attribute_mapping (
    mapping_id      BIGINT       NOT NULL COMMENT '映射ID',
    tenant_id       VARCHAR(20)  DEFAULT '000000' COMMENT '租户ID',
    model_id        BIGINT       NOT NULL COMMENT '产品ID(FK→cpq_product_model)',
    attr_name       VARCHAR(100) NOT NULL COMMENT '属性名',
    attr_value      VARCHAR(200) NOT NULL COMMENT '属性值',
    material_code   VARCHAR(100) NOT NULL COMMENT '物料编码',
    sbom_line_id    BIGINT       DEFAULT NULL COMMENT '关联SBOM行ID(FK→cpq_sbom_line)',
    condition_expr  VARCHAR(500) DEFAULT NULL COMMENT '附加条件',
    sort_order      INT          DEFAULT 0 COMMENT '排序号',
    del_flag        CHAR(1)      DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept     BIGINT       DEFAULT NULL,
    create_by       BIGINT       DEFAULT NULL,
    create_time     DATETIME     DEFAULT NULL,
    update_by       BIGINT       DEFAULT NULL,
    update_time     DATETIME     DEFAULT NULL,
    remark          VARCHAR(500) DEFAULT NULL,
    PRIMARY KEY (mapping_id),
    UNIQUE KEY uk_attr_value (tenant_id, model_id, attr_name, attr_value),
    INDEX idx_model_attr (tenant_id, model_id, attr_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ属性→物料映射表(选了钛合金外壳→自动匹配钛合金散热方案, SBOM→MBOM转换核心)';

-- 4. 兼容性矩阵表 (cpq_compatibility_matrix) — 跨产品互斥/依赖
DROP TABLE IF EXISTS cpq_compatibility_matrix;
CREATE TABLE cpq_compatibility_matrix (
    matrix_id           BIGINT       NOT NULL COMMENT '矩阵ID',
    tenant_id           VARCHAR(20)  DEFAULT '000000' COMMENT '租户ID',
    source_product_id   BIGINT       NOT NULL COMMENT '源产品ID(FK→cpq_product_model)',
    target_product_id   BIGINT       NOT NULL COMMENT '目标产品ID(FK→cpq_product_model)',
    compatibility_type  VARCHAR(20)  NOT NULL COMMENT '兼容类型: MUTUAL_EXCLUSIVE(互斥)/DEPENDENCY(依赖)/REQUIRES(前置)',
    condition_desc      VARCHAR(500) DEFAULT NULL COMMENT '兼容条件描述',
    del_flag            CHAR(1)      DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept         BIGINT       DEFAULT NULL,
    create_by           BIGINT       DEFAULT NULL,
    create_time         DATETIME     DEFAULT NULL,
    update_by           BIGINT       DEFAULT NULL,
    update_time         DATETIME     DEFAULT NULL,
    remark              VARCHAR(500) DEFAULT NULL,
    PRIMARY KEY (matrix_id),
    UNIQUE KEY uk_product_pair (tenant_id, source_product_id, target_product_id, compatibility_type),
    INDEX idx_source (tenant_id, source_product_id),
    INDEX idx_target (tenant_id, target_product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ跨产品兼容性矩阵(产品A与产品B互斥/依赖/前置关系)';

-- 5. 属性选项值定义表 (cpq_attribute_option)
DROP TABLE IF EXISTS cpq_attribute_option;
CREATE TABLE cpq_attribute_option (
    option_id       BIGINT       NOT NULL COMMENT '选项ID',
    tenant_id       VARCHAR(20)  DEFAULT '000000' COMMENT '租户ID',
    model_id        BIGINT       NOT NULL COMMENT '产品ID(FK→cpq_product_model)',
    attr_name       VARCHAR(100) NOT NULL COMMENT '属性名',
    option_code     VARCHAR(100) NOT NULL COMMENT '选项编码',
    option_label    VARCHAR(200) NOT NULL COMMENT '选项显示名',
    option_value    VARCHAR(200) DEFAULT NULL COMMENT '选项值',
    is_default      CHAR(1)      DEFAULT '0' COMMENT '是否默认选项',
    sort_order      INT          DEFAULT 0 COMMENT '排序号',
    del_flag        CHAR(1)      DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept     BIGINT       DEFAULT NULL,
    create_by       BIGINT       DEFAULT NULL,
    create_time     DATETIME     DEFAULT NULL,
    update_by       BIGINT       DEFAULT NULL,
    update_time     DATETIME     DEFAULT NULL,
    remark          VARCHAR(500) DEFAULT NULL,
    PRIMARY KEY (option_id),
    UNIQUE KEY uk_attr_option (tenant_id, model_id, attr_name, option_code),
    INDEX idx_model_attr (tenant_id, model_id, attr_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ属性选项值定义(属性的可选值列表)';
