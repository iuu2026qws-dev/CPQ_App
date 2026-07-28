-- ============================================================
-- CPQ 统一审批流升级 DDL
-- 版本：v2.0 | 日期：2026-07-27
-- 说明：为 cpq_approval_rule / matrix 添加场景和流程关联字段，
--       新建业务快照表，为接入 Warm-Flow 引擎做准备。
--       不改动现有数据，不影响当前 Agent 工艺确认流程。
-- ============================================================

-- 1. cpq_approval_rule 添加 trigger_scene + flow_code
ALTER TABLE cpq_approval_rule
    ADD COLUMN IF NOT EXISTS trigger_scene VARCHAR(30) COMMENT '业务场景: QUOTE/PROCESS/ECN/PRICING/CONFIG/CRM/CUSTOMER' AFTER trigger_type,
    ADD COLUMN IF NOT EXISTS flow_code VARCHAR(40) COMMENT '关联 Warm-Flow 流程编码(flow_definition.flow_code)' AFTER approval_chain_json;

-- 2. cpq_approval_matrix 添加 flow_code
ALTER TABLE cpq_approval_matrix
    ADD COLUMN IF NOT EXISTS flow_code VARCHAR(40) COMMENT '关联 Warm-Flow 流程编码' AFTER dimension_value;

-- 3. 新建业务快照表 — 记录每次审批发起的业务上下文
CREATE TABLE IF NOT EXISTS cpq_approval_business_snapshot (
    snapshot_id      BIGINT        NOT NULL COMMENT '主键',
    tenant_id        VARCHAR(20)   DEFAULT '000000' COMMENT '租户ID',
    scene            VARCHAR(30)   NOT NULL COMMENT '业务场景: QUOTE/PROCESS/ECN/PRICING/CONFIG/CRM/CUSTOMER',
    business_id      BIGINT        NOT NULL COMMENT '业务表主键ID',
    business_summary VARCHAR(500)  COMMENT '业务摘要(审批列表展示用)',
    business_data    JSON          COMMENT '业务数据快照(JSON)',
    flow_instance_id BIGINT        COMMENT 'Warm-Flow flow_instance.id',
    status           VARCHAR(20)   DEFAULT 'PENDING' COMMENT '审批状态: PENDING/APPROVED/REJECTED/CANCELLED',
    create_by        BIGINT        COMMENT '创建人',
    create_time      DATETIME      COMMENT '创建时间',
    update_time      DATETIME      COMMENT '更新时间',
    PRIMARY KEY (snapshot_id),
    INDEX idx_scene_biz (scene, business_id),
    INDEX idx_flow_instance (flow_instance_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='CPQ审批业务快照表';
