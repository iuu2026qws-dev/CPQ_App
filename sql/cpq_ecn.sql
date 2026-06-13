-- =============================================
-- CPQ 模块 DDL — ECN/ECO 工程变更数据域（4张表）
-- Sprint 12
-- =============================================

DROP TABLE IF EXISTS cpq_ecn_change_order;
CREATE TABLE cpq_ecn_change_order (
    change_order_id   BIGINT       NOT NULL COMMENT '变更单ID',
    tenant_id         VARCHAR(20)  DEFAULT '000000' COMMENT '租户ID',
    ecn_number        VARCHAR(50)  NOT NULL COMMENT 'ECN编号',
    title             VARCHAR(200) NOT NULL COMMENT '变更标题',
    reason            TEXT         COMMENT '变更原因',
    change_type       VARCHAR(30)  COMMENT '变更类型: PRODUCT/BOM/PRICE/PROCESS/DOCUMENT',
    severity          VARCHAR(20)  DEFAULT 'NORMAL' COMMENT '严重程度: CRITICAL/MAJOR/NORMAL/MINOR',
    affected_products TEXT         COMMENT '受影响产品(JSON)',
    status            VARCHAR(20)  DEFAULT 'DRAFT' COMMENT '状态: DRAFT/ANALYZING/APPROVED/REJECTED/IMPLEMENTED/CLOSED',
    originator_id     BIGINT       COMMENT '发起人ID',
    orginator_name    VARCHAR(100) COMMENT '发起人姓名',
    del_flag          CHAR(1)      DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept       BIGINT,
    create_by         BIGINT,
    create_time       DATETIME,
    update_by         BIGINT,
    update_time       DATETIME,
    remark            VARCHAR(500),
    PRIMARY KEY (change_order_id),
    UNIQUE KEY uk_ecn_number (tenant_id, ecn_number),
    INDEX idx_status (tenant_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ECN变更单';

DROP TABLE IF EXISTS cpq_ecn_change_item;
CREATE TABLE cpq_ecn_change_item (
    item_id            BIGINT       NOT NULL COMMENT '变更项ID',
    tenant_id          VARCHAR(20)  DEFAULT '000000' COMMENT '租户ID',
    change_order_id    BIGINT       NOT NULL COMMENT '变更单ID(FK)',
    entity_type        VARCHAR(30)  NOT NULL COMMENT '实体类型: PRODUCT/BOM/PRICE/ATTRIBUTE/DOCUMENT/CONFIG_RULE',
    entity_id          BIGINT       NOT NULL COMMENT '实体ID',
    entity_name        VARCHAR(200) COMMENT '实体名称',
    change_description TEXT         COMMENT '变更描述',
    old_value          TEXT         COMMENT '旧值(JSON)',
    new_value          TEXT         COMMENT '新值(JSON)',
    sort_order         INT          DEFAULT 0 COMMENT '排序',
    del_flag           CHAR(1)      DEFAULT '0',
    create_dept        BIGINT,
    create_by          BIGINT,
    create_time        DATETIME,
    update_by          BIGINT,
    update_time        DATETIME,
    remark             VARCHAR(500),
    PRIMARY KEY (item_id),
    INDEX idx_change_order (tenant_id, change_order_id),
    INDEX idx_entity (tenant_id, entity_type, entity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ECN变更项';

DROP TABLE IF EXISTS cpq_ecn_impact_analysis;
CREATE TABLE cpq_ecn_impact_analysis (
    impact_id          BIGINT       NOT NULL COMMENT '影响分析ID',
    tenant_id          VARCHAR(20)  DEFAULT '000000' COMMENT '租户ID',
    change_order_id    BIGINT       NOT NULL COMMENT '变更单ID(FK)',
    change_item_id     BIGINT       COMMENT '变更项ID(FK)',
    propagation_level  INT          NOT NULL COMMENT '传播层级: 1-BOM 2-配置规则 3-报价单 4-审批链 5-ERP订单',
    affected_entity_type VARCHAR(30) COMMENT '受影响实体类型',
    affected_entity_id BIGINT       COMMENT '受影响实体ID',
    affected_entity_name VARCHAR(200) COMMENT '受影响实体名称',
    impact_description TEXT         COMMENT '影响描述',
    severity           VARCHAR(20)  COMMENT '影响程度: HIGH/MEDIUM/LOW',
    remediation        TEXT         COMMENT '缓解措施',
    del_flag           CHAR(1)      DEFAULT '0',
    create_dept        BIGINT,
    create_by          BIGINT,
    create_time        DATETIME,
    update_by          BIGINT,
    update_time        DATETIME,
    remark             VARCHAR(500),
    PRIMARY KEY (impact_id),
    INDEX idx_change_order (tenant_id, change_order_id),
    INDEX idx_level (tenant_id, propagation_level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ECN影响分析';

DROP TABLE IF EXISTS cpq_ecn_approval;
CREATE TABLE cpq_ecn_approval (
    ecn_approval_id    BIGINT       NOT NULL COMMENT '审批ID',
    tenant_id          VARCHAR(20)  DEFAULT '000000' COMMENT '租户ID',
    change_order_id    BIGINT       NOT NULL COMMENT '变更单ID(FK)',
    approval_chain_id  BIGINT       COMMENT '审批链ID(FK→cpq_approval_chain)',
    approver_id        BIGINT       COMMENT '审批人ID',
    approver_name      VARCHAR(100) COMMENT '审批人姓名',
    step_number        INT          COMMENT '审批步骤',
    action             VARCHAR(20)  COMMENT '审批动作: APPROVE/REJECT/COMMENT',
    comment            TEXT         COMMENT '审批意见',
    action_time        DATETIME     COMMENT '操作时间',
    del_flag           CHAR(1)      DEFAULT '0',
    create_dept        BIGINT,
    create_by          BIGINT,
    create_time        DATETIME,
    update_by          BIGINT,
    update_time        DATETIME,
    remark             VARCHAR(500),
    PRIMARY KEY (ecn_approval_id),
    INDEX idx_change_order (tenant_id, change_order_id),
    INDEX idx_chain (tenant_id, approval_chain_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ECN审批记录';
