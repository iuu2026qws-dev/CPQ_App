-- =============================================
-- CPQ 模块 DDL — D08 集成数据域（3张表）
-- 基于：M-CPQ_Product_Data_Architecture.md
-- 规范：tenant_id VARCHAR(20) 对齐 RuoYi-Vue-Plus TenantEntity
-- 目标 Sprint：S5（客户渠道+集成+ATP引擎）
-- =============================================

-- 1. 集成配置表 (cpq_integration_config)
DROP TABLE IF EXISTS cpq_integration_config;
CREATE TABLE cpq_integration_config (
    config_id           BIGINT       NOT NULL COMMENT '配置ID',
    tenant_id           VARCHAR(20)  DEFAULT '000000' COMMENT '租户ID',
    system_type         VARCHAR(20)  NOT NULL COMMENT '系统类型: CRM/ERP/PLM/PRICING/CONTRACT/ECOMMERCE',
    system_name         VARCHAR(100) NOT NULL COMMENT '系统名称',
    endpoint_url        VARCHAR(500) NOT NULL COMMENT '端点URL',
    auth_type           VARCHAR(20)  NOT NULL COMMENT '认证类型: API_KEY/OAUTH2/BASIC/mTLS',
    auth_config_json    JSON         DEFAULT NULL COMMENT '认证配置(JSON): {api_key, client_id, client_secret, token_url, ...}',
    sync_direction      VARCHAR(10)  NOT NULL COMMENT '同步方向: INBOUND/OUTBOUND/BIDIRECTIONAL',
    sync_frequency      VARCHAR(20)  DEFAULT NULL COMMENT '同步频率: REALTIME/HOURLY/DAILY/MANUAL',
    timeout_seconds     INT          DEFAULT 30 COMMENT '超时时间(秒)',
    retry_times         INT          DEFAULT 3 COMMENT '重试次数',
    status              CHAR(1)      DEFAULT '0' COMMENT '状态(0正常 1停用)',
    del_flag            CHAR(1)      DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept         BIGINT       DEFAULT NULL,
    create_by           BIGINT       DEFAULT NULL,
    create_time         DATETIME     DEFAULT NULL,
    update_by           BIGINT       DEFAULT NULL,
    update_time         DATETIME     DEFAULT NULL,
    remark              VARCHAR(500) DEFAULT NULL,
    PRIMARY KEY (config_id),
    INDEX idx_tenant_system (tenant_id, system_type, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ集成配置(CRM/ERP/PLM连接器配置: 端点/认证/同步策略)';

-- 2. 集成字段映射表 (cpq_integration_mapping)
DROP TABLE IF EXISTS cpq_integration_mapping;
CREATE TABLE cpq_integration_mapping (
    mapping_id      BIGINT       NOT NULL COMMENT '映射ID',
    tenant_id       VARCHAR(20)  DEFAULT '000000' COMMENT '租户ID',
    config_id       BIGINT       NOT NULL COMMENT '集成配置ID(FK→cpq_integration_config)',
    source_field    VARCHAR(100) NOT NULL COMMENT '源系统字段(CRM/ERP字段名)',
    target_field    VARCHAR(100) NOT NULL COMMENT 'CPQ目标字段(CPQ表字段名)',
    transform_rule  VARCHAR(500) DEFAULT NULL COMMENT '转换规则(表达式: 如 multiply(price, 1.13) 或 lookup(region_code))',
    is_required     CHAR(1)      DEFAULT '0' COMMENT '是否必填(1是 0否)',
    sort_order      INT          DEFAULT 0 COMMENT '排序号',
    PRIMARY KEY (mapping_id),
    UNIQUE KEY uk_config_field (tenant_id, config_id, source_field),
    INDEX idx_config (tenant_id, config_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ集成字段映射(外部系统字段→CPQ字段的映射关系和转换规则)';

-- 3. 同步日志表 (cpq_sync_log)
DROP TABLE IF EXISTS cpq_sync_log;
CREATE TABLE cpq_sync_log (
    log_id          BIGINT       NOT NULL COMMENT '日志ID',
    tenant_id       VARCHAR(20)  DEFAULT '000000' COMMENT '租户ID',
    config_id       BIGINT       NOT NULL COMMENT '集成配置ID(FK→cpq_integration_config)',
    sync_direction  VARCHAR(10)  NOT NULL COMMENT '方向: INBOUND(外部→CPQ)/OUTBOUND(CPQ→外部)',
    sync_status     VARCHAR(20)  NOT NULL COMMENT '状态: SUCCESS/FAILED/PARTIAL',
    records_total   INT          DEFAULT NULL COMMENT '总记录数',
    records_success INT          DEFAULT NULL COMMENT '成功数',
    records_failed  INT          DEFAULT NULL COMMENT '失败数',
    error_detail    TEXT         DEFAULT NULL COMMENT '错误详情',
    sync_time       DATETIME     NOT NULL COMMENT '同步时间',
    duration_ms     INT          DEFAULT NULL COMMENT '耗时(毫秒)',
    PRIMARY KEY (log_id),
    INDEX idx_config_time (tenant_id, config_id, sync_time DESC),
    INDEX idx_status (tenant_id, sync_status, sync_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ同步日志(记录每次数据集成的完整执行结果)';
