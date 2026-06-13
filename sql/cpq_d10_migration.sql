-- S14 数据迁移模块 DDL（3张表）
DROP TABLE IF EXISTS cpq_migration_task;
CREATE TABLE cpq_migration_task (
    task_id             BIGINT NOT NULL COMMENT '任务ID',
    tenant_id           VARCHAR(20) DEFAULT '000000',
    task_name           VARCHAR(200) NOT NULL COMMENT '任务名称',
    source_system       VARCHAR(50) NOT NULL COMMENT '源系统: LEGACY_ERP/CRM/EXCEL',
    target_module       VARCHAR(50) NOT NULL COMMENT '目标模块: PRODUCT/PRICING/CUSTOMER',
    task_status         VARCHAR(20) DEFAULT 'DRAFT' COMMENT '状态: DRAFT/VALIDATING/RUNNING/COMPLETED/FAILED',
    total_records       INT DEFAULT 0 COMMENT '总记录数',
    processed_records   INT DEFAULT 0 COMMENT '已处理数',
    failed_records      INT DEFAULT 0 COMMENT '失败数',
    file_path           VARCHAR(500) DEFAULT NULL COMMENT '上传文件路径',
    started_at          DATETIME DEFAULT NULL,
    completed_at        DATETIME DEFAULT NULL,
    del_flag            CHAR(1) DEFAULT '0' COMMENT '0正常 2删除',
    create_dept         BIGINT DEFAULT NULL,
    create_by           BIGINT DEFAULT NULL,
    create_time         DATETIME DEFAULT NULL,
    update_by           BIGINT DEFAULT NULL,
    update_time         DATETIME DEFAULT NULL,
    remark              VARCHAR(500) DEFAULT NULL,
    PRIMARY KEY (task_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据迁移任务';

DROP TABLE IF EXISTS cpq_migration_mapping;
CREATE TABLE cpq_migration_mapping (
    mapping_id          BIGINT NOT NULL COMMENT '映射ID',
    tenant_id           VARCHAR(20) DEFAULT '000000',
    task_id             BIGINT NOT NULL COMMENT '迁移任务ID',
    source_field        VARCHAR(100) NOT NULL COMMENT '源字段',
    target_field        VARCHAR(100) NOT NULL COMMENT '目标字段',
    transform_rule      VARCHAR(500) DEFAULT NULL COMMENT '转换规则',
    default_value       VARCHAR(200) DEFAULT NULL COMMENT '默认值',
    is_required         CHAR(1) DEFAULT '0' COMMENT '是否必填',
    sort_order          INT DEFAULT 0,
    del_flag            CHAR(1) DEFAULT '0' COMMENT '0正常 2删除',
    create_dept         BIGINT DEFAULT NULL,
    create_by           BIGINT DEFAULT NULL,
    create_time         DATETIME DEFAULT NULL,
    update_by           BIGINT DEFAULT NULL,
    update_time         DATETIME DEFAULT NULL,
    PRIMARY KEY (mapping_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='迁移字段映射';

DROP TABLE IF EXISTS cpq_migration_log;
CREATE TABLE cpq_migration_log (
    log_id              BIGINT NOT NULL COMMENT '日志ID',
    tenant_id           VARCHAR(20) DEFAULT '000000',
    task_id             BIGINT NOT NULL COMMENT '迁移任务ID',
    row_index           INT DEFAULT NULL COMMENT '行号',
    log_level           VARCHAR(20) DEFAULT 'INFO' COMMENT '级别: INFO/WARN/ERROR',
    message             TEXT DEFAULT NULL COMMENT '日志消息',
    raw_data_json       JSON DEFAULT NULL COMMENT '原始数据',
    log_time            DATETIME DEFAULT NULL,
    PRIMARY KEY (log_id),
    INDEX idx_task (tenant_id, task_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='迁移日志';
