-- =============================================
-- CPQ 模块 DDL — D04 报价数据域（6张表）
-- 基于：M-CPQ_Product_Data_Architecture.md
-- 规范：tenant_id VARCHAR(20) 对齐 RuoYi-Vue-Plus TenantEntity
-- 目标 Sprint：S4（报价与审批）
-- =============================================

-- 1. 报价单表 (cpq_quote)
DROP TABLE IF EXISTS cpq_quote;
CREATE TABLE cpq_quote (
    quote_id            BIGINT         NOT NULL COMMENT '报价单ID',
    tenant_id           VARCHAR(20)    DEFAULT '000000' COMMENT '租户ID',
    quote_number        VARCHAR(50)    NOT NULL COMMENT '报价单编号(自动生成)',
    opportunity_id      VARCHAR(100)   DEFAULT NULL COMMENT '关联商机ID(CRM)',
    account_id          BIGINT         NOT NULL COMMENT '客户ID(FK→cpq_account)',
    account_name        VARCHAR(200)   DEFAULT NULL COMMENT '客户名称(冗余)',
    quote_type          VARCHAR(20)    DEFAULT 'STANDARD' COMMENT '类型: STANDARD/RENEWAL/REVISION/QUICK',
    currency            VARCHAR(3)     DEFAULT 'CNY' COMMENT '币种',
    subtotal            DECIMAL(18,2)  DEFAULT NULL COMMENT '小计',
    discount_total      DECIMAL(18,2)  DEFAULT NULL COMMENT '折扣总额',
    tax_total           DECIMAL(18,2)  DEFAULT NULL COMMENT '税费',
    grand_total         DECIMAL(18,2)  DEFAULT NULL COMMENT '总计',
    status              VARCHAR(20)    DEFAULT 'DRAFT' COMMENT '状态: DRAFT/CONFIGURING/VALIDATED/PRICING/APPROVING/APPROVED/SENT/WON/LOST/EXPIRED/REJECTED',
    valid_until         DATE           DEFAULT NULL COMMENT '有效期至',
    approval_chain_id   BIGINT         DEFAULT NULL COMMENT '当前审批链ID(FK→cpq_approval_chain)',
    created_by          BIGINT         DEFAULT NULL COMMENT '创建人ID',
    created_by_name     VARCHAR(100)   DEFAULT NULL COMMENT '创建人姓名(冗余)',
    submitted_date      DATETIME       DEFAULT NULL COMMENT '提交日期',
    won_date            DATETIME       DEFAULT NULL COMMENT '赢单日期',
    del_flag            CHAR(1)        DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept         BIGINT         DEFAULT NULL,
    create_time         DATETIME       DEFAULT NULL,
    update_by           BIGINT         DEFAULT NULL,
    update_time         DATETIME       DEFAULT NULL,
    remark              VARCHAR(500)   DEFAULT NULL,
    PRIMARY KEY (quote_id),
    UNIQUE KEY uk_quote_number (tenant_id, quote_number),
    INDEX idx_account (tenant_id, account_id),
    INDEX idx_status (tenant_id, status, create_time),
    INDEX idx_created_by (tenant_id, created_by, create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ报价单';

-- 2. 报价行项目表 (cpq_quote_line_item)
DROP TABLE IF EXISTS cpq_quote_line_item;
CREATE TABLE cpq_quote_line_item (
    line_id             BIGINT         NOT NULL COMMENT '行项目ID',
    tenant_id           VARCHAR(20)    DEFAULT '000000' COMMENT '租户ID',
    quote_id            BIGINT         NOT NULL COMMENT '报价单ID(FK→cpq_quote)',
    parent_line_id      BIGINT         DEFAULT NULL COMMENT '父行项目ID(捆绑关系)',
    line_number         INT            NOT NULL COMMENT '行号',
    model_id            BIGINT         DEFAULT NULL COMMENT '产品ID(FK→cpq_product_model)',
    sbom_line_id        BIGINT         DEFAULT NULL COMMENT 'SBOM物料ID(FK→cpq_sbom_line, 配件行)',
    item_type           VARCHAR(20)    NOT NULL COMMENT '类型: PRODUCT/ACCESSORY/SERVICE/CUSTOM/SOFTWARE/LICENSE',
    item_code           VARCHAR(100)   DEFAULT NULL COMMENT '物料编码',
    item_name           VARCHAR(500)   NOT NULL COMMENT '物料名称',
    quantity            DECIMAL(12,4)  NOT NULL COMMENT '数量',
    unit                VARCHAR(10)    DEFAULT 'PCS' COMMENT '单位',
    list_price          DECIMAL(18,2)  DEFAULT NULL COMMENT '目录价',
    unit_price          DECIMAL(18,2)  DEFAULT NULL COMMENT '单价(折扣后)',
    discount_pct        DECIMAL(5,2)   DEFAULT NULL COMMENT '折扣百分比',
    discount_amount     DECIMAL(18,2)  DEFAULT NULL COMMENT '折扣金额',
    net_price           DECIMAL(18,2)  DEFAULT NULL COMMENT '净价',
    line_total          DECIMAL(18,2)  DEFAULT NULL COMMENT '行总计',
    configuration_json  JSON           DEFAULT NULL COMMENT '该行的配置选择(JSON)',
    custom_requirements TEXT           DEFAULT NULL COMMENT '定制需求描述',
    delivery_days       INT            DEFAULT NULL COMMENT '预估交期(天)',
    atp_status          VARCHAR(20)    DEFAULT NULL COMMENT 'ATP状态: AVAILABLE/CONSTRAINED/UNAVAILABLE',
    sort_order          INT            DEFAULT 0 COMMENT '排序号',
    del_flag            CHAR(1)        DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept         BIGINT         DEFAULT NULL,
    create_by           BIGINT         DEFAULT NULL,
    create_time         DATETIME       DEFAULT NULL,
    update_by           BIGINT         DEFAULT NULL,
    update_time         DATETIME       DEFAULT NULL,
    remark              VARCHAR(500)   DEFAULT NULL,
    PRIMARY KEY (line_id),
    UNIQUE KEY uk_quote_line (tenant_id, quote_id, line_number),
    INDEX idx_quote (tenant_id, quote_id),
    INDEX idx_model (tenant_id, model_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ报价行项目';

-- 3. 配置快照表 (cpq_config_snapshot) — 时间胶囊
DROP TABLE IF EXISTS cpq_config_snapshot;
CREATE TABLE cpq_config_snapshot (
    snapshot_id     BIGINT       NOT NULL COMMENT '快照ID',
    tenant_id       VARCHAR(20)  DEFAULT '000000' COMMENT '租户ID',
    quote_id        BIGINT       NOT NULL COMMENT '报价单ID(FK→cpq_quote)',
    model_id        BIGINT       NOT NULL COMMENT '产品ID(FK→cpq_product_model)',
    snapshot_hash   VARCHAR(64)  NOT NULL COMMENT '快照哈希(SHA256)',
    selections_json JSON         NOT NULL COMMENT '配置选择(JSON): {attr_name: attr_value, ...}',
    bom_json        JSON         DEFAULT NULL COMMENT '完整BOM快照(JSON): {lines: [{item_code, qty, ...}]}',
    rule_version    VARCHAR(20)  DEFAULT NULL COMMENT '配置规则版本号',
    price_version   VARCHAR(20)  DEFAULT NULL COMMENT '价格规则版本号',
    product_version VARCHAR(20)  DEFAULT NULL COMMENT '产品定义版本号',
    snapshot_time   DATETIME     NOT NULL COMMENT '快照时间',
    PRIMARY KEY (snapshot_id),
    UNIQUE KEY uk_snapshot_hash (tenant_id, snapshot_hash),
    INDEX idx_quote (tenant_id, quote_id),
    INDEX idx_model (tenant_id, model_id),
    INDEX idx_time (tenant_id, snapshot_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ配置快照(时间胶囊: 记录报价时的完整配置+BOM+规则版本, 支持版本回溯和合规审计)';

-- 4. 报价版本表 (cpq_quote_version)
DROP TABLE IF EXISTS cpq_quote_version;
CREATE TABLE cpq_quote_version (
    version_id      BIGINT       NOT NULL COMMENT '版本ID',
    tenant_id       VARCHAR(20)  DEFAULT '000000' COMMENT '租户ID',
    quote_id        BIGINT       NOT NULL COMMENT '报价单ID(FK→cpq_quote)',
    version_number  INT          NOT NULL COMMENT '版本号(从1递增)',
    version_json    JSON         NOT NULL COMMENT '版本完整数据(JSON): 报价单+行项目+配置快照的完整快照',
    version_note    VARCHAR(500) DEFAULT NULL COMMENT '版本说明',
    created_by      BIGINT       DEFAULT NULL COMMENT '创建人',
    created_time    DATETIME     NOT NULL COMMENT '创建时间',
    PRIMARY KEY (version_id),
    UNIQUE KEY uk_quote_version (tenant_id, quote_id, version_number),
    INDEX idx_quote (tenant_id, quote_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ报价版本(多版本支持+版本对比)';

-- 5. 报价模板表 (cpq_quote_template)
DROP TABLE IF EXISTS cpq_quote_template;
CREATE TABLE cpq_quote_template (
    template_id         BIGINT         NOT NULL COMMENT '模板ID',
    tenant_id           VARCHAR(20)    DEFAULT '000000' COMMENT '租户ID',
    template_name       VARCHAR(200)   NOT NULL COMMENT '模板名称',
    template_type       VARCHAR(20)    NOT NULL COMMENT '类型: PDF/DOCX/STANDARD/CUSTOM',
    template_content    LONGTEXT       DEFAULT NULL COMMENT '模板内容(二进制/HTML/Markdown)',
    template_json       JSON           DEFAULT NULL COMMENT '模板配置(JSON): {sections, placeholders, styles, ...}',
    is_default          CHAR(1)        DEFAULT '0' COMMENT '是否默认模板',
    status              CHAR(1)        DEFAULT '0' COMMENT '状态(0正常 1停用)',
    del_flag            CHAR(1)        DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept         BIGINT         DEFAULT NULL,
    create_by           BIGINT         DEFAULT NULL,
    create_time         DATETIME       DEFAULT NULL,
    update_by           BIGINT         DEFAULT NULL,
    update_time         DATETIME       DEFAULT NULL,
    remark              VARCHAR(500)   DEFAULT NULL,
    PRIMARY KEY (template_id),
    INDEX idx_tenant (tenant_id),
    INDEX idx_type (tenant_id, template_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ报价模板({{config.*}}占位符→配置数据填充, PDF/Word生成)';

-- 6. 方案文档表 (cpq_solution_document)
DROP TABLE IF EXISTS cpq_solution_document;
CREATE TABLE cpq_solution_document (
    document_id         BIGINT         NOT NULL COMMENT '文档ID',
    tenant_id           VARCHAR(20)    DEFAULT '000000' COMMENT '租户ID',
    quote_id            BIGINT         DEFAULT NULL COMMENT '关联报价单ID(FK→cpq_quote)',
    document_type       VARCHAR(20)    NOT NULL COMMENT '类型: TECHNICAL_PROPOSAL/BUSINESS_PROPOSAL/DELIVERY_PLAN/IMPLEMENTATION/ACCEPTANCE',
    document_name       VARCHAR(200)   NOT NULL COMMENT '文档名称',
    document_content    LONGTEXT       DEFAULT NULL COMMENT '文档内容(Tiptap JSON)',
    document_json       JSON           DEFAULT NULL COMMENT '文档结构化数据(JSON)',
    version             INT            DEFAULT 1 COMMENT '版本号',
    status              VARCHAR(20)    DEFAULT 'DRAFT' COMMENT '状态: DRAFT/EDITING/REVIEWING/APPROVED/PUBLISHED',
    del_flag            CHAR(1)        DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept         BIGINT         DEFAULT NULL,
    create_by           BIGINT         DEFAULT NULL,
    create_time         DATETIME       DEFAULT NULL,
    update_by           BIGINT         DEFAULT NULL,
    update_time         DATETIME       DEFAULT NULL,
    remark              VARCHAR(500)   DEFAULT NULL,
    PRIMARY KEY (document_id),
    INDEX idx_quote (tenant_id, quote_id),
    INDEX idx_type (tenant_id, document_type),
    INDEX idx_status (tenant_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ方案文档(方案交付物: 技术方案书/商务方案书/实施计划/验收标准)';
