-- =============================================
-- CPQ 模块 DDL — D07 系统数据域（1张表）
-- 说明：cpq_abac_policy 已在 cpq_d01_product.sql 中定义
-- 基于：CPQ_后端功能设计.md §2.2 + §4 D07
-- 规范：tenant_id VARCHAR(20) 对齐 RuoYi-Vue-Plus TenantEntity
-- 目标 Sprint：S2（产品数据域完整交付）
-- =============================================

-- 1. CPQ系统参数表 (cpq_system_config) — 扩展 RuoYi sys_config
DROP TABLE IF EXISTS cpq_system_config;
CREATE TABLE cpq_system_config (
    config_id       BIGINT       NOT NULL COMMENT '配置ID',
    tenant_id       VARCHAR(20)  DEFAULT '000000' COMMENT '租户ID',
    config_key      VARCHAR(100) NOT NULL COMMENT '配置键',
    config_value    TEXT         NOT NULL COMMENT '配置值',
    config_type     VARCHAR(20)  DEFAULT 'STRING' COMMENT '值类型: STRING/NUMBER/JSON/BOOLEAN',
    create_dept     BIGINT       DEFAULT NULL,
    create_by       BIGINT       DEFAULT NULL,
    create_time     DATETIME     DEFAULT NULL,
    update_by       BIGINT       DEFAULT NULL,
    update_time     DATETIME     DEFAULT NULL,
    remark          VARCHAR(500) DEFAULT NULL,
    PRIMARY KEY (config_id),
    UNIQUE KEY uk_key (tenant_id, config_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ系统参数(扩展RuoYi sys_config, 存储CPQ业务级配置参数)';
