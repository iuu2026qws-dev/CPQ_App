-- =============================================
-- CPQ 模块 DDL — D05 审批数据域（4张表）
-- 基于：M-CPQ_Product_Data_Architecture.md
-- 规范：tenant_id VARCHAR(20) 对齐 RuoYi-Vue-Plus TenantEntity
-- 目标 Sprint：S4（报价与审批）
-- =============================================

-- 1. 审批规则表 (cpq_approval_rule)
DROP TABLE IF EXISTS cpq_approval_rule;
CREATE TABLE cpq_approval_rule (
    rule_id                 BIGINT         NOT NULL COMMENT '规则ID',
    tenant_id               VARCHAR(20)    DEFAULT '000000' COMMENT '租户ID',
    rule_name               VARCHAR(200)   NOT NULL COMMENT '规则名称',
    trigger_type            VARCHAR(30)    NOT NULL COMMENT '触发类型: DISCOUNT_EXCEED(折扣超标)/MARGIN_BELOW(毛利过低)/AMOUNT_ABOVE(金额超限)/NEW_CONFIG(首次配置)/CROSS_REGION(跨区域)/CUSTOM_PART(定制件)/FIRST_ORDER(首单)/EXPORT_CONTROL(出口管制)',
    trigger_value           DECIMAL(18,2)  DEFAULT NULL COMMENT '触发阈值(如折扣>20%触发审批)',
    approval_chain_json     JSON           NOT NULL COMMENT '审批链模板(JSON): [{step, approver_role, approver_ids, type:PARALLEL/SERIAL}]',
    priority                INT            DEFAULT 0 COMMENT '优先级(越大越高, 多条规则同时触发时取最高优先级)',
    status                  CHAR(1)        DEFAULT '0' COMMENT '状态(0正常 1停用)',
    del_flag                CHAR(1)        DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept             BIGINT         DEFAULT NULL,
    create_by               BIGINT         DEFAULT NULL,
    create_time             DATETIME       DEFAULT NULL,
    update_by               BIGINT         DEFAULT NULL,
    update_time             DATETIME       DEFAULT NULL,
    remark                  VARCHAR(500)   DEFAULT NULL,
    PRIMARY KEY (rule_id),
    INDEX idx_trigger (tenant_id, trigger_type, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ审批规则(8种触发类型: 折扣超标/毛利过低/金额超限/首次配置/跨区域/定制件/首单/出口管制)';

-- 2. 审批链实例表 (cpq_approval_chain)
DROP TABLE IF EXISTS cpq_approval_chain;
CREATE TABLE cpq_approval_chain (
    chain_id            BIGINT       NOT NULL COMMENT '审批链ID',
    tenant_id           VARCHAR(20)  DEFAULT '000000' COMMENT '租户ID',
    quote_id            BIGINT       NOT NULL COMMENT '报价单ID(FK→cpq_quote)',
    rule_id             BIGINT       DEFAULT NULL COMMENT '触发的审批规则ID(FK→cpq_approval_rule)',
    current_step        INT          DEFAULT 1 COMMENT '当前审批步骤',
    total_steps         INT          NOT NULL COMMENT '总步骤数',
    status              VARCHAR(20)  DEFAULT 'IN_PROGRESS' COMMENT '状态: IN_PROGRESS/APPROVED/REJECTED/CANCELLED/EXPIRED',
    submitted_by        BIGINT       NOT NULL COMMENT '提交人ID',
    submitted_time      DATETIME     NOT NULL COMMENT '提交时间',
    completed_time      DATETIME     DEFAULT NULL COMMENT '完成时间',
    sla_hours           INT          DEFAULT 48 COMMENT 'SLA超时(小时)',
    PRIMARY KEY (chain_id),
    INDEX idx_quote (tenant_id, quote_id),
    INDEX idx_status (tenant_id, status),
    INDEX idx_submitted (tenant_id, submitted_by, submitted_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ审批链(审批规则实例化, 记录每轮审批的完整上下文)';

-- 3. 审批记录表 (cpq_approval_record)
DROP TABLE IF EXISTS cpq_approval_record;
CREATE TABLE cpq_approval_record (
    record_id       BIGINT         NOT NULL COMMENT '记录ID',
    tenant_id       VARCHAR(20)    DEFAULT '000000' COMMENT '租户ID',
    chain_id        BIGINT         NOT NULL COMMENT '审批链ID(FK→cpq_approval_chain)',
    step_number     INT            NOT NULL COMMENT '步骤号',
    approver_id     BIGINT         NOT NULL COMMENT '审批人ID',
    approver_name   VARCHAR(100)   DEFAULT NULL COMMENT '审批人姓名(冗余)',
    action          VARCHAR(20)    DEFAULT NULL COMMENT '审批动作: APPROVE/CONDITIONAL_APPROVE/REJECT/TRANSFER(转审)/DELEGATE(委托)/ADD_SIGNER(加签)',
    comment         VARCHAR(1000)  DEFAULT NULL COMMENT '审批意见',
    action_time     DATETIME       DEFAULT NULL COMMENT '动作时间',
    sla_deadline    DATETIME       DEFAULT NULL COMMENT 'SLA截止时间',
    PRIMARY KEY (record_id),
    INDEX idx_chain (tenant_id, chain_id),
    INDEX idx_approver (tenant_id, approver_id, action_time),
    INDEX idx_sla (tenant_id, sla_deadline, action)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ审批记录(每步审批动作全记录: 通过/条件通过/驳回/转审/委托/加签)';

-- 4. 审批矩阵表 (cpq_approval_matrix)
DROP TABLE IF EXISTS cpq_approval_matrix;
CREATE TABLE cpq_approval_matrix (
    matrix_id           BIGINT       NOT NULL COMMENT '矩阵ID',
    tenant_id           VARCHAR(20)  DEFAULT '000000' COMMENT '租户ID',
    dimension_type      VARCHAR(30)  NOT NULL COMMENT '维度类型: REGION/DEPT/AMOUNT_RANGE/PRODUCT_LINE/QUOTE_TYPE',
    dimension_value     VARCHAR(200) NOT NULL COMMENT '维度值(区域代码/部门ID/金额区间/产品线/报价类型)',
    approver_role       VARCHAR(50)  DEFAULT NULL COMMENT '审批人角色(role_key)',
    approver_ids        VARCHAR(500) DEFAULT NULL COMMENT '审批人ID列表(逗号分隔, 用于指定固定审批人)',
    min_approvals       INT          DEFAULT 1 COMMENT '最少审批通过数(并行审批时)',
    status              CHAR(1)      DEFAULT '0' COMMENT '状态(0正常 1停用)',
    del_flag            CHAR(1)      DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept         BIGINT       DEFAULT NULL,
    create_by           BIGINT       DEFAULT NULL,
    create_time         DATETIME     DEFAULT NULL,
    update_by           BIGINT       DEFAULT NULL,
    update_time         DATETIME     DEFAULT NULL,
    remark              VARCHAR(500) DEFAULT NULL,
    PRIMARY KEY (matrix_id),
    UNIQUE KEY uk_dimension (tenant_id, dimension_type, dimension_value),
    INDEX idx_type (tenant_id, dimension_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ审批矩阵(按区域/部门/金额/产品线/报价类型确定审批人)';
