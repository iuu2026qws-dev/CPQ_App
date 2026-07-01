# Smart CPQ — CRM信息模块 落地实施开发方案

> **版本**：V1.0  
> **日期**：2026年6月15日  
> **基于**：RuoYi-Vue-Plus 5.x + CPQ现有模块 + Salesforce CRM数据模型参考  
> **定位**：直接交付开发团队的实施规格文档，涵盖功能设计、UI/UX、数据架构、技术方案、集成接口，开发团队无需额外澄清即可开展开发工作

---

## 目录

- [1. 模块概述与业务背景](#1-模块概述与业务背景)
- [2. 数据架构设计](#2-数据架构设计)
- [3. 功能设计](#3-功能设计)
- [4. UI/UX设计](#4-uiux设计)
- [5. 技术方案设计](#5-技术方案设计)
- [6. 接口设计](#6-接口设计)
- [7. 集成设计](#7-集成设计)
- [8. 菜单与路由配置](#8-菜单与路由配置)
- [9. 权限设计](#9-权限设计)
- [10. 实施计划](#10-实施计划)

---

## 1. 模块概述与业务背景

### 1.1 业务背景

CPQ（配置-定价-报价）不是孤立存在的，它与客户、商机（销售项目）、订单、合同构成完整的制造业销售业务闭环：

```
客户(Account) ──1:N──> 商机(Opportunity) ──1:N──> CPQ核心流程(配置→定价→报价)
                                                        │
                                    报价确认后 ──────────┘
                                                        │
                                                        ▼
                                    合同(Contract) ──1:N──> 订单(Order)
                                                        │
                                                        ▼
                                          产品交付明细(来自配置清单)
```

**客户和商机是CPQ的上游**：有了客户和客户的项目需求（商机），才需要为商机创建产品配置、确定定价规则、生成报价单。

**订单和合同是CPQ的下游**：面向商机的报价最终确认后，根据报价关联的配置清单为订单或合同形成产品交付明细。

**合同与订单的两种关系**：
- **模式A：单项目制合同（1:1）**：一个合同下有一个订单，订单包含本次购买的所有交付产品明细，明细由配置清单形成
- **模式B：框架合同多订单（1:N）**：合同框定客户所购产品的定价条款，客户按需在合同下分批创建订单，每个订单包含当次采购的交付产品明细

### 1.2 模块定位

| 维度 | 说明 |
|------|------|
| **模块名称** | CRM信息 |
| **所属端** | cpq-portal（前端门户） |
| **一级菜单** | `CRM信息`（第9个一级菜单分组） |
| **二级菜单** | 客户管理、商机管理、合同管理、订单管理 |
| **角色** | 销售经理、售前工程师、销售运营 |
| **参照标准** | Salesforce CRM 标准对象模型（Account / Opportunity / Order / Contract），简化适配制造业CPQ场景 |

### 1.3 设计原则

1. **参照Salesforce但不照搬**：取关键字段和标准阶段定义，去掉与制造业CPQ无关的内容
2. **与现有CPQ模块紧密集成**：商机关联报价单、合同/订单从配置清单生成明细
3. **遵循项目现有规范**：表命名 `cpq_crm_*`、Java包 `org.dromara.cpq.crm`、URL前缀 `/cpq/crm/`、前端目录 `@/views/crm/`
4. **渐进实施**：分阶段交付，先客户/商机（上游），后合同/订单（下游）

### 1.4 与现有模块的关系

| 现有模块 | 关联方式 |
|----------|----------|
| `cpq_account` 客户表 | 在现有表基础上增加字段，CRM信息模块提供增强的CRUD管理 |
| `cpq_quote` 报价表 | 新增 `opportunity_id` 字段（当前已存在VARCHAR(100)引用），双向关联 |
| `cpq_cpq-quote` 报价模块 | 商机关联报价单列表、合同/订单从报价配置清单生成明细 |
| `cpq-cpq-approval` 审批模块 | 报价审批后触发合同/订单生成 |
| `cpq-cpq-customer` 客户模块 | 复用现有4张表，CRM信息模块提供业务层封装 |

---

## 2. 数据架构设计

### 2.1 实体关系图（ER）

```
cpq_account (客户) ──── 1:N ────> cpq_crm_opportunity (商机)
     │                                    │
     │                                    │ 1:N
     │                                    ▼
     │                            cpq_quote (报价单，已存在)
     │                                    │
     │                                    │ (报价确认后)
     │                                    ▼
     │                            cpq_crm_contract (合同)
     │                                    │
     │                                    │ 1:N
     │                                    ▼
     │                            cpq_crm_order (订单)
     │                                    │
     │                                    │ 1:N
     │                                    ▼
     │                            cpq_crm_order_line (订单明细)
     │
     └── 1:N ────> cpq_crm_activity (销售活动)
```

### 2.2 新增表 DDL

#### 2.2.1 变更现有表：cpq_account（增加3个字段）

```sql
-- 在 cpq_account 表上增加三个字段
ALTER TABLE cpq_account
    ADD COLUMN legal_representative      VARCHAR(100) DEFAULT NULL COMMENT '法人代表' AFTER contact_email,
    ADD COLUMN unified_social_credit_code VARCHAR(50)  DEFAULT NULL COMMENT '统一社会信用代码' AFTER legal_representative;
```

> **说明**：`address` 字段已存在（VARCHAR(500)），无需新增。`legal_representative` 和 `unified_social_credit_code` 为新增字段，均为纯文本类型。

#### 2.2.2 商机表（cpq_crm_opportunity）

```sql
-- cpq_d13_crm.sql — 商机表
DROP TABLE IF EXISTS cpq_crm_opportunity;
CREATE TABLE cpq_crm_opportunity (
    opportunity_id      BIGINT          NOT NULL COMMENT '商机ID',
    tenant_id           VARCHAR(20)     DEFAULT '000000' COMMENT '租户ID',
    opportunity_name    VARCHAR(200)    NOT NULL COMMENT '商机名称',
    opportunity_code    VARCHAR(50)     NOT NULL COMMENT '商机编码',
    account_id          BIGINT          NOT NULL COMMENT '关联客户ID(FK→cpq_account)',
    stage               VARCHAR(30)     NOT NULL DEFAULT 'PROSPECTING' COMMENT '销售阶段',
    close_date          DATE            DEFAULT NULL COMMENT '预计关闭日期',
    amount              DECIMAL(18,2)   DEFAULT NULL COMMENT '预计金额',
    probability         DECIMAL(5,2)    DEFAULT NULL COMMENT '赢单概率(%)',
    opportunity_type    VARCHAR(30)     DEFAULT NULL COMMENT '商机类型: NEW_BUSINESS/EXISTING_BUSINESS/UPSELL/RENEWAL',
    lead_source         VARCHAR(30)     DEFAULT NULL COMMENT '线索来源: WEB/PHONE/REFERRAL/EXHIBITION/PARTNER/OTHER',
    next_step           VARCHAR(255)    DEFAULT NULL COMMENT '下一步计划',
    owner_id            BIGINT          DEFAULT NULL COMMENT '负责人(用户ID)',
    contact_name        VARCHAR(100)    DEFAULT NULL COMMENT '主要联系人',
    contact_phone       VARCHAR(30)     DEFAULT NULL COMMENT '联系电话',
    description         VARCHAR(1000)   DEFAULT NULL COMMENT '商机描述',
    is_closed           CHAR(1)         DEFAULT '0' COMMENT '是否关闭(0进行中 1已关闭)',
    closed_reason       VARCHAR(500)    DEFAULT NULL COMMENT '关闭原因(丢单时填写)',
    status              CHAR(1)         DEFAULT '0' COMMENT '状态(0正常 1停用)',
    del_flag            CHAR(1)         DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept         BIGINT          DEFAULT NULL,
    create_by           BIGINT          DEFAULT NULL,
    create_time         DATETIME        DEFAULT NULL,
    update_by           BIGINT          DEFAULT NULL,
    update_time         DATETIME        DEFAULT NULL,
    remark              VARCHAR(500)    DEFAULT NULL,
    PRIMARY KEY (opportunity_id),
    UNIQUE KEY uk_tenant_code (tenant_id, opportunity_code),
    INDEX idx_account (tenant_id, account_id),
    INDEX idx_owner (tenant_id, owner_id),
    INDEX idx_stage (tenant_id, stage),
    INDEX idx_close_date (tenant_id, close_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ商机';
```

**销售阶段（stage）枚举值**（参照Salesforce，精简为6阶段）：

| 阶段值 | 中文名称 | 默认概率 | 说明 |
|--------|---------|---------|------|
| `PROSPECTING` | 寻找商机 | 10% | 初步识别潜在销售机会 |
| `QUALIFICATION` | 资格认定 | 25% | 确认客户意向和预算 |
| `PROPOSAL` | 提案/报价 | 50% | 已发出产品方案或报价 |
| `NEGOTIATION` | 谈判/审核 | 75% | 价格谈判或内部审核中 |
| `CLOSED_WON` | 已赢得 | 100% | 赢单，进入合同/订单流程 |
| `CLOSED_LOST` | 已丢失 | 0% | 丢单，记录关闭原因 |

#### 2.2.3 合同表（cpq_crm_contract）

```sql
-- cpq_d13_crm.sql — 合同表
DROP TABLE IF EXISTS cpq_crm_contract;
CREATE TABLE cpq_crm_contract (
    contract_id         BIGINT          NOT NULL COMMENT '合同ID',
    tenant_id           VARCHAR(20)     DEFAULT '000000' COMMENT '租户ID',
    contract_number     VARCHAR(50)     NOT NULL COMMENT '合同编号',
    contract_name       VARCHAR(200)    NOT NULL COMMENT '合同名称',
    account_id          BIGINT          NOT NULL COMMENT '关联客户ID(FK→cpq_account)',
    opportunity_id      BIGINT          DEFAULT NULL COMMENT '关联商机ID(FK→cpq_crm_opportunity)',
    contract_type       VARCHAR(20)     NOT NULL DEFAULT 'PROJECT' COMMENT '合同类型: PROJECT(单项目制)/FRAMEWORK(框架合同)',
    status              VARCHAR(20)     NOT NULL DEFAULT 'DRAFT' COMMENT '合同状态',
    start_date          DATE            DEFAULT NULL COMMENT '合同开始日期',
    end_date            DATE            DEFAULT NULL COMMENT '合同结束日期',
    total_amount        DECIMAL(18,2)   DEFAULT NULL COMMENT '合同总金额',
    signed_date         DATE            DEFAULT NULL COMMENT '签订日期',
    signing_party       VARCHAR(200)    DEFAULT NULL COMMENT '签约主体',
    payment_terms       VARCHAR(500)    DEFAULT NULL COMMENT '付款条款',
    owner_id            BIGINT          DEFAULT NULL COMMENT '负责人(用户ID)',
    description         VARCHAR(1000)   DEFAULT NULL COMMENT '合同描述',
    del_flag            CHAR(1)         DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept         BIGINT          DEFAULT NULL,
    create_by           BIGINT          DEFAULT NULL,
    create_time         DATETIME        DEFAULT NULL,
    update_by           BIGINT          DEFAULT NULL,
    update_time         DATETIME        DEFAULT NULL,
    remark              VARCHAR(500)    DEFAULT NULL,
    PRIMARY KEY (contract_id),
    UNIQUE KEY uk_tenant_number (tenant_id, contract_number),
    INDEX idx_account (tenant_id, account_id),
    INDEX idx_opportunity (tenant_id, opportunity_id),
    INDEX idx_status (tenant_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ合同';
```

**合同状态枚举**：

| 状态值 | 中文名称 | 说明 |
|--------|---------|------|
| `DRAFT` | 草稿 | 合同草拟中 |
| `PENDING_APPROVAL` | 待审批 | 提交内部审批 |
| `PENDING_SIGN` | 待签署 | 审批通过，等待双方签署 |
| `ACTIVE` | 生效中 | 合同已生效 |
| `COMPLETED` | 已完成 | 合同履行完毕 |
| `TERMINATED` | 已终止 | 合同提前终止或到期 |

**合同类型**：
- `PROJECT`（单项目制）：一个合同对应一个商机，合同下有一个订单
- `FRAMEWORK`（框架合同）：合同框定定价条款，可包含多个订单

#### 2.2.4 订单表（cpq_crm_order）

```sql
-- cpq_d13_crm.sql — 订单表
DROP TABLE IF EXISTS cpq_crm_order;
CREATE TABLE cpq_crm_order (
    order_id            BIGINT          NOT NULL COMMENT '订单ID',
    tenant_id           VARCHAR(20)     DEFAULT '000000' COMMENT '租户ID',
    order_number        VARCHAR(50)     NOT NULL COMMENT '订单编号',
    order_name          VARCHAR(200)    DEFAULT NULL COMMENT '订单名称',
    contract_id         BIGINT          NOT NULL COMMENT '关联合同ID(FK→cpq_crm_contract)',
    account_id          BIGINT          NOT NULL COMMENT '关联客户ID(FK→cpq_account)',
    quote_id            BIGINT          DEFAULT NULL COMMENT '关联报价单ID(FK→cpq_quote)',
    order_type          VARCHAR(20)     DEFAULT NULL COMMENT '订单类型: STANDARD/RUSH/RENEWAL',
    status              VARCHAR(20)     NOT NULL DEFAULT 'DRAFT' COMMENT '订单状态',
    order_date          DATE            DEFAULT NULL COMMENT '订单日期',
    total_amount        DECIMAL(18,2)   DEFAULT NULL COMMENT '订单总金额',
    currency            VARCHAR(10)     DEFAULT 'CNY' COMMENT '币种',
    delivery_date       DATE            DEFAULT NULL COMMENT '期望交付日期',
    shipping_address    VARCHAR(500)    DEFAULT NULL COMMENT '收货地址',
    billing_address     VARCHAR(500)    DEFAULT NULL COMMENT '账单地址',
    owner_id            BIGINT          DEFAULT NULL COMMENT '负责人(用户ID)',
    description         VARCHAR(1000)   DEFAULT NULL COMMENT '订单描述',
    del_flag            CHAR(1)         DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept         BIGINT          DEFAULT NULL,
    create_by           BIGINT          DEFAULT NULL,
    create_time         DATETIME        DEFAULT NULL,
    update_by           BIGINT          DEFAULT NULL,
    update_time         DATETIME        DEFAULT NULL,
    remark              VARCHAR(500)    DEFAULT NULL,
    PRIMARY KEY (order_id),
    UNIQUE KEY uk_tenant_number (tenant_id, order_number),
    INDEX idx_contract (tenant_id, contract_id),
    INDEX idx_account (tenant_id, account_id),
    INDEX idx_quote (tenant_id, quote_id),
    INDEX idx_status (tenant_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ订单';
```

**订单状态枚举**：

| 状态值 | 中文名称 | 说明 |
|--------|---------|------|
| `DRAFT` | 草稿 | 订单草拟中 |
| `PENDING_APPROVAL` | 待审批 | 提交审批 |
| `APPROVED` | 已审批 | 审批通过 |
| `IN_PRODUCTION` | 生产中 | 已转生产 |
| `IN_DELIVERY` | 交付中 | 物流配送或安装部署中 |
| `COMPLETED` | 已完成 | 交付完成 |
| `CANCELLED` | 已取消 | 订单取消 |

#### 2.2.5 订单明细表（cpq_crm_order_line）

```sql
-- cpq_d13_crm.sql — 订单明细表
DROP TABLE IF EXISTS cpq_crm_order_line;
CREATE TABLE cpq_crm_order_line (
    line_id             BIGINT          NOT NULL COMMENT '明细ID',
    tenant_id           VARCHAR(20)     DEFAULT '000000' COMMENT '租户ID',
    order_id            BIGINT          NOT NULL COMMENT '关联订单ID(FK→cpq_crm_order)',
    line_number         INT             NOT NULL DEFAULT 1 COMMENT '行号',
    source_type         VARCHAR(20)     NOT NULL COMMENT '来源类型: QUOTE_LINE(报价行)/MANUAL(手动添加)',
    source_id           BIGINT          DEFAULT NULL COMMENT '来源行ID(报价行ID等)',
    product_code        VARCHAR(100)    DEFAULT NULL COMMENT '产品编码',
    product_name        VARCHAR(200)    DEFAULT NULL COMMENT '产品名称',
    model_id            BIGINT          DEFAULT NULL COMMENT '产品模型ID',
    quantity            DECIMAL(18,4)   NOT NULL COMMENT '数量',
    unit                VARCHAR(20)     DEFAULT NULL COMMENT '单位',
    unit_price          DECIMAL(18,2)   DEFAULT NULL COMMENT '单价',
    line_amount         DECIMAL(18,2)   DEFAULT NULL COMMENT '行金额(quantity × unit_price)',
    discount_pct        DECIMAL(5,2)    DEFAULT NULL COMMENT '折扣率(%)',
    tax_rate            DECIMAL(5,2)    DEFAULT NULL COMMENT '税率(%)',
    delivery_schedule   VARCHAR(200)    DEFAULT NULL COMMENT '交付计划说明',
    del_flag            CHAR(1)         DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept         BIGINT          DEFAULT NULL,
    create_by           BIGINT          DEFAULT NULL,
    create_time         DATETIME        DEFAULT NULL,
    update_by           BIGINT          DEFAULT NULL,
    update_time         DATETIME        DEFAULT NULL,
    remark              VARCHAR(500)    DEFAULT NULL,
    PRIMARY KEY (line_id),
    INDEX idx_order (tenant_id, order_id),
    INDEX idx_model (tenant_id, model_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ订单明细(来自报价配置清单)';
```

#### 2.2.6 销售活动表（cpq_crm_activity）

```sql
-- cpq_d13_crm.sql — 销售活动表
DROP TABLE IF EXISTS cpq_crm_activity;
CREATE TABLE cpq_crm_activity (
    activity_id         BIGINT          NOT NULL COMMENT '活动ID',
    tenant_id           VARCHAR(20)     DEFAULT '000000' COMMENT '租户ID',
    opportunity_id      BIGINT          NOT NULL COMMENT '关联商机ID(FK→cpq_crm_opportunity)',
    account_id          BIGINT          NOT NULL COMMENT '关联客户ID(FK→cpq_account)',
    activity_type       VARCHAR(30)     NOT NULL COMMENT '活动类型: CALL/MEETING/EMAIL/VISIT/DEMO/NEGOTIATION/OTHER',
    subject             VARCHAR(200)    NOT NULL COMMENT '活动主题',
    activity_date       DATE            NOT NULL COMMENT '活动日期',
    activity_time       TIME            DEFAULT NULL COMMENT '活动时间',
    duration_minutes    INT             DEFAULT NULL COMMENT '持续时长(分钟)',
    participants        VARCHAR(500)    DEFAULT NULL COMMENT '参与人(逗号分隔姓名)',
    result              VARCHAR(1000)   DEFAULT NULL COMMENT '活动结果/纪要',
    next_plan           VARCHAR(500)    DEFAULT NULL COMMENT '下一步计划',
    owner_id            BIGINT          DEFAULT NULL COMMENT '负责人(用户ID)',
    del_flag            CHAR(1)         DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept         BIGINT          DEFAULT NULL,
    create_by           BIGINT          DEFAULT NULL,
    create_time         DATETIME        DEFAULT NULL,
    update_by           BIGINT          DEFAULT NULL,
    update_time         DATETIME        DEFAULT NULL,
    remark              VARCHAR(500)    DEFAULT NULL,
    PRIMARY KEY (activity_id),
    INDEX idx_opportunity (tenant_id, opportunity_id),
    INDEX idx_account (tenant_id, account_id),
    INDEX idx_date (tenant_id, activity_date),
    INDEX idx_owner (tenant_id, owner_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ销售活动(商机跟进记录)';
```

### 2.3 现有cpq_quote表需增加字段

```sql
-- 增强报价单与商机的关联（cpq_quote 表已有 opportunity_id VARCHAR(100)，需确认是否需要改为BIGINT外键）
-- 如需加强关联，执行：
-- ALTER TABLE cpq_quote MODIFY COLUMN opportunity_id BIGINT DEFAULT NULL COMMENT '关联商机ID(FK→cpq_crm_opportunity)';
```

### 2.4 SQL文件组织

新增 `sql/cpq_d13_crm.sql`，包含上述4张新表DDL + cpq_account变更ALTER语句。

菜单数据追加到 `sql/cpq_menu.sql`，ID范围：**50150-50179**。

### 2.5 数据字典汇总

| 表名 | 数据域 | 说明 |
|------|--------|------|
| `cpq_account` | D06 客户渠道 | 客户（已有，增加2个字段） |
| `cpq_channel` | D06 客户渠道 | 渠道 |
| `cpq_agreement_price` | D06 客户渠道 | 协议价 |
| `cpq_territory` | D06 客户渠道 | 销售区域 |
| `cpq_crm_opportunity` | **D13 CRM** | **商机（新增）** |
| `cpq_crm_contract` | **D13 CRM** | **合同（新增）** |
| `cpq_crm_order` | **D13 CRM** | **订单（新增）** |
| `cpq_crm_order_line` | **D13 CRM** | **订单明细（新增）** |
| `cpq_crm_activity` | **D13 CRM** | **销售活动（新增）** |

---

## 3. 功能设计

### 3.1 客户管理

**功能范围**：在现有 `cpq_account` 表基础上，提供CRM信息模块内的增强型客户管理。

| 功能点 | 说明 | 优先级 |
|--------|------|--------|
| 客户列表 | 分页展示客户列表，支持按名称/编码/行业/区域/类型筛选 | P0 |
| 新增客户 | 包含全部字段，必填：名称、编码；新增字段：法人代表、统一社会信用代码 | P0 |
| 编辑客户 | 修改全部可编辑字段 | P0 |
| 删除客户 | 软删除（del_flag=2） | P0 |
| 客户详情 | 查看客户全部信息 + 关联商机列表 + 关联合同列表 + 关联订单列表 | P0 |
| 客户搜索 | 名称/编码的模糊搜索 + 行业/区域/类型的下拉筛选 | P0 |
| 客户类型管理 | DIRECT/CHANNEL/PARTNER/ENTERPRISE 四类 | P1 |

**关键字段清单**（参照Salesforce Account）：

| 字段 | 数据库列 | 类型 | 必填 | 说明 |
|------|---------|------|------|------|
| 客户名称 | account_name | VARCHAR(200) | 是 | — |
| 客户编码 | account_code | VARCHAR(50) | 是 | 唯一 |
| 客户类型 | account_type | VARCHAR(20) | 否 | DIRECT/CHANNEL/PARTNER/ENTERPRISE |
| 行业 | industry | VARCHAR(50) | 否 | — |
| 区域 | region | VARCHAR(50) | 否 | — |
| 法人代表 | **legal_representative** | **VARCHAR(100)** | **否** | **新增** |
| 统一社会信用代码 | **unified_social_credit_code** | **VARCHAR(50)** | **否** | **新增，18位** |
| 联系人 | contact_name | VARCHAR(100) | 否 | — |
| 联系电话 | contact_phone | VARCHAR(30) | 否 | — |
| 联系邮箱 | contact_email | VARCHAR(100) | 否 | — |
| 地址 | address | VARCHAR(500) | 否 | 已存在 |
| 税号 | tax_id | VARCHAR(50) | 否 | — |

### 3.2 商机管理

| 功能点 | 说明 | 优先级 |
|--------|------|--------|
| 商机列表 | 分页展示，支持按名称/编号/客户/阶段/负责人/预计关闭日期筛选 | P0 |
| 新增商机 | 必填：名称、关联客户、阶段；选填：金额、关闭日期、类型、负责人等 | P0 |
| 编辑商机 | 修改商机信息，阶段变更时自动更新概率 | P0 |
| 删除商机 | 软删除 | P0 |
| 商机详情 | 完整信息 + 关联报价单列表 + 销售活动时间线 + 关联合同/订单 | P0 |
| 阶段推进 | 商机阶段向前推进（不可回退），每个阶段切换时自动记录活动日志 | P1 |
| 关联报价 | 在商机详情中展示关联的CPQ报价单列表，支持从商机直接跳转创建报价 | P0 |
| 销售活动 | 商机详情中可新增/查看跟进活动记录（电话/会议/拜访/演示/谈判等） | P1 |

**商机字段清单**：

| 字段 | 数据库列 | 类型 | 必填 | 说明 |
|------|---------|------|------|------|
| 商机名称 | opportunity_name | VARCHAR(200) | 是 | — |
| 商机编码 | opportunity_code | VARCHAR(50) | 是 | 唯一，自动生成 |
| 关联客户 | account_id | BIGINT | 是 | 下拉选择 cpq_account |
| 销售阶段 | stage | VARCHAR(30) | 是 | 6阶段枚举 |
| 预计关闭日期 | close_date | DATE | 否 | — |
| 预计金额 | amount | DECIMAL(18,2) | 否 | — |
| 赢单概率 | probability | DECIMAL(5,2) | 否 | 阶段变更时自动计算 |
| 商机类型 | opportunity_type | VARCHAR(30) | 否 | 新业务/存量业务/增购/续约 |
| 线索来源 | lead_source | VARCHAR(30) | 否 | 网络/电话/推荐/展会/合作伙伴/其他 |
| 下一步计划 | next_step | VARCHAR(255) | 否 | — |
| 负责人 | owner_id | BIGINT | 否 | 用户下拉选择 |
| 主要联系人 | contact_name | VARCHAR(100) | 否 | — |
| 联系电话 | contact_phone | VARCHAR(30) | 否 | — |
| 是否关闭 | is_closed | CHAR(1) | 否 | 0进行中/1已关闭 |
| 关闭原因 | closed_reason | VARCHAR(500) | 否 | 丢单时必填 |

**阶段→概率映射**（自动计算）：

| 阶段 | 概率 |
|------|------|
| PROSPECTING | 10% |
| QUALIFICATION | 25% |
| PROPOSAL | 50% |
| NEGOTIATION | 75% |
| CLOSED_WON | 100% |
| CLOSED_LOST | 0% |

### 3.3 合同管理

| 功能点 | 说明 | 优先级 |
|--------|------|--------|
| 合同列表 | 分页展示，支持按编号/名称/客户/类型/状态筛选 | P0 |
| 新增合同 | 模式A（单项目制）：选商机→自动填充客户+产品明细（来自报价配置清单）；模式B（框架合同）：选客户→手动填写合同条款 | P0 |
| 编辑合同 | 仅DRAFT状态下可编辑 | P0 |
| 合同详情 | 完整信息 + 关联订单列表 + 产品明细 | P0 |
| 合同审批 | 提交合同审批，状态从DRAFT→PENDING_APPROVAL | P1 |
| 从商机生成合同 | 商机CLOSED_WON后，一键生成合同（模式A），自动带入配置清单产品 | P0 |
| 合同状态流转 | DRAFT→PENDING_APPROVAL→PENDING_SIGN→ACTIVE→COMPLETED（或TERMINATED） | P1 |

**合同字段清单**：

| 字段 | 数据库列 | 类型 | 必填 | 说明 |
|------|---------|------|------|------|
| 合同编号 | contract_number | VARCHAR(50) | 是 | 唯一 |
| 合同名称 | contract_name | VARCHAR(200) | 是 | — |
| 关联客户 | account_id | BIGINT | 是 | 下拉选择 |
| 关联商机 | opportunity_id | BIGINT | 否 | 单项目制必填 |
| 合同类型 | contract_type | VARCHAR(20) | 是 | PROJECT/FRAMEWORK |
| 合同状态 | status | VARCHAR(20) | 是 | 6状态枚举 |
| 合同开始日期 | start_date | DATE | 否 | — |
| 合同结束日期 | end_date | DATE | 否 | — |
| 合同总金额 | total_amount | DECIMAL(18,2) | 否 | — |
| 签订日期 | signed_date | DATE | 否 | — |
| 签约主体 | signing_party | VARCHAR(200) | 否 | — |
| 付款条款 | payment_terms | VARCHAR(500) | 否 | — |
| 负责人 | owner_id | BIGINT | 否 | — |

### 3.4 订单管理

| 功能点 | 说明 | 优先级 |
|--------|------|--------|
| 订单列表 | 分页展示，支持按编号/名称/客户/合同/状态筛选 | P0 |
| 新增订单 | 模式A：选合同（PROJECT类型）→自动带入产品明细；模式B：选合同（FRAMEWORK类型）→选择合同下的产品手工配置数量 | P0 |
| 订单详情 | 完整信息 + 订单明细列表 | P0 |
| 从报价生成订单 | 报价确认后，一键生成订单，自动将配置清单产品生成订单明细 | P0 |
| 订单明细管理 | 支持查看/编辑订单明细（数量/单价/折扣/税率等），支持手动添加明细行 | P1 |
| 订单状态流转 | DRAFT→PENDING_APPROVAL→APPROVED→IN_PRODUCTION→IN_DELIVERY→COMPLETED | P1 |

**订单字段清单**：

| 字段 | 数据库列 | 类型 | 必填 | 说明 |
|------|---------|------|------|------|
| 订单编号 | order_number | VARCHAR(50) | 是 | 唯一，自动生成 |
| 订单名称 | order_name | VARCHAR(200) | 否 | — |
| 关联合同 | contract_id | BIGINT | 是 | 下拉选择 |
| 关联客户 | account_id | BIGINT | 是 | 自动填充 |
| 关联报价 | quote_id | BIGINT | 否 | 来源报价单 |
| 订单类型 | order_type | VARCHAR(20) | 否 | 标准/紧急/续约 |
| 订单状态 | status | VARCHAR(20) | 是 | 7状态枚举 |
| 订单日期 | order_date | DATE | 否 | — |
| 总金额 | total_amount | DECIMAL(18,2) | 否 | 由明细汇总 |
| 币种 | currency | VARCHAR(10) | 否 | 默认CNY |
| 期望交付日期 | delivery_date | DATE | 否 | — |
| 收货地址 | shipping_address | VARCHAR(500) | 否 | — |
| 账单地址 | billing_address | VARCHAR(500) | 否 | — |

### 3.5 销售活动管理

| 功能点 | 说明 | 优先级 |
|--------|------|--------|
| 活动列表 | 在商机详情中以时间线形式展示所有活动记录 | P1 |
| 新增活动 | 在商机详情中新增活动：类型/主题/日期/时长/参与人/结果/下一步计划 | P1 |
| 活动类型 | CALL/MEETING/EMAIL/VISIT/DEMO/NEGOTIATION/OTHER | P1 |

---

## 4. UI/UX设计

### 4.1 整体布局

CRM信息模块内所有页面采用标准 cpq-portal 页面布局：
```
┌─────────────────────────────────────────────────────┐
│  面包屑：首页 / CRM信息 / [当前二级页面名]           │
├─────────────────────────────────────────────────────┤
│                                                     │
│  [页面标题]                    [操作按钮区]          │
│                                                     │
│  [筛选栏：下拉框/输入框/搜索按钮]                    │
│                                                     │
│  [主内容区域：表格/详情/表单]                        │
│                                                     │
│  [分页器]                                            │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### 4.2 客户管理页面

#### 4.2.1 客户列表页

```
┌──────────────────────────────────────────────────────┐
│ 页面标题：客户管理        [+ 新增客户] [刷新]         │
├──────────────────────────────────────────────────────┤
│ [客户名称___] [客户编码___] [类型▼] [行业▼] [搜索][重置]│
├──────────────────────────────────────────────────────┤
│ ┌──────────────────────────────────────────────────┐ │
│ │ 客户名称 │ 编码 │ 类型 │ 行业 │ 联系人 │ 电话   │...│ │
│ │ 华为     │HUAWEI│DIRECT│ 通信 │ 张三   │1380000│   │ │
│ │ 比亚迪   │BYD   │ENTERPRISE│制造│ 李四 │1390000│   │ │
│ │ ...                                            │   │ │
│ └──────────────────────────────────────────────────┘ │
│                           [分页: 1 2 3 ... 10]       │
└──────────────────────────────────────────────────────┘
```

**操作**：每行尾部操作列包含 **[编辑] [删除]**，点击客户名称进入详情页。

#### 4.2.2 客户新增/编辑（Dialog弹窗, 600px宽）

```
┌─────────────────────────────────────┐
│  新增客户 / 编辑客户                │
├─────────────────────────────────────┤
│  基本信息                           │
│  ┌───────────────────────────────┐ │
│  │ 客户名称*   [____________]    │ │
│  │ 客户编码*   [____________]    │ │
│  │ 客户类型    [▼ DIRECT/CHANNEL]│ │
│  │ 行业        [____________]    │ │
│  │ 区域        [▼ 下拉选择]      │ │
│  └───────────────────────────────┘ │
│  企业信息                           │
│  ┌───────────────────────────────┐ │
│  │ 法人代表    [____________]    │ │
│  │ 统一社会信用代码 [________]    │ │
│  │ 地址        [____________]    │ │
│  │ 税号        [____________]    │ │
│  └───────────────────────────────┘ │
│  联系信息                           │
│  ┌───────────────────────────────┐ │
│  │ 联系人      [____________]    │ │
│  │ 联系电话    [____________]    │ │
│  │ 联系邮箱    [____________]    │ │
│  └───────────────────────────────┘ │
│                                    │
│  [取消]              [确定]        │
└─────────────────────────────────────┘
```

**验证规则**：
- 客户名称：必填，1-200字符
- 客户编码：必填，字母/数字/下划线，唯一
- 统一社会信用代码：选填，18位字母数字，格式校验
- 联系电话：选填，合法手机号/座机格式

#### 4.2.3 客户详情页

```
┌──────────────────────────────────────────────────────┐
│ [< 返回列表]  客户详情：华为技术有限公司              │
├──────────────────────────────────────────────────────┤
│ ┌─ 基本信息 ─────────────────────────────────────┐   │
│ │ 客户名称: 华为   编码: HUAWEI   类型: DIRECT   │   │
│ │ 行业: 通信       区域: 华南                    │   │
│ │ 法人代表: 任XX   信用代码: 91440300...         │   │
│ │ 地址: 深圳市龙岗区...  税号: 440300...         │   │
│ │ 联系人: 张三     电话: 138...   邮箱: z@hw.com │   │
│ └────────────────────────────────────────────────┘   │
│                                                      │
│ ┌─ 关联商机 ─────────────────── [查看全部商机>] ──┐   │
│ │ 商机名称        │ 阶段        │ 金额    │ 日期 │   │
│ │ 5G基站采购项目  │ PROPOSAL    │ 500万   │ 06-15│   │
│ │ ...                                             │   │
│ └────────────────────────────────────────────────┘   │
│                                                      │
│ ┌─ 关联合同 ─────────────────── [查看全部合同>] ──┐   │
│ │ 合同编号       │ 类型      │ 状态    │ 金额   │   │
│ │ CT-2026-001   │ PROJECT   │ ACTIVE  │ 500万  │   │
│ └────────────────────────────────────────────────┘   │
│                                                      │
│ ┌─ 关联订单 ─────────────────── [查看全部订单>] ──┐   │
│ │ 订单编号       │ 状态      │ 金额    │ 日期   │   │
│ │ ORD-2026-001  │ IN_PROD   │ 500万   │ 06-15  │   │
│ └────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────┘
```

### 4.3 商机管理页面

#### 4.3.1 商机列表页

```
┌──────────────────────────────────────────────────────┐
│ 商机管理                          [+ 新增商机] [刷新] │
├──────────────────────────────────────────────────────┤
│ [名称___] [编码___] [客户▼] [阶段▼] [负责人▼] [搜索][重置]│
├──────────────────────────────────────────────────────┤
│ ┌──────────────────────────────────────────────────┐ │
│ │ 名称 │ 编码 │ 客户 │ 阶段 │ 金额 │ 概率│截止日期│...│ │
│ │ 5G采购│OPP-01│ 华为 │PROPOSAL│500万│50%│06-30 │   │ │
│ │ 弧焊 │OPP-02│比亚迪│QUALIFY │200万│25%│07-15 │   │ │
│ └──────────────────────────────────────────────────┘ │
│                           [分页: 1 2 3 ... 10]       │
└──────────────────────────────────────────────────────┘
```

**操作列**：**[详情] [编辑] [推进阶段] [删除]**

阶段列使用 `el-tag` 颜色区分：PROSPECTING(gray)、QUALIFICATION(info)、PROPOSAL(warning)、NEGOTIATION(primary)、CLOSED_WON(success)、CLOSED_LOST(danger)。

#### 4.3.2 商机详情页（核心页面）

```
┌──────────────────────────────────────────────────────┐
│ [< 返回]  商机详情：5G基站采购项目     [编辑] [推进]  │
├──────────────────────────────────────────────────────┤
│ ┌─ 商机信息 ──────────────────────────────────────┐  │
│ │ 名称: 5G基站采购项目  编码: OPP-2026-001         │  │
│ │ 客户: 华为技术        阶段: PROPOSAL [50%]       │  │
│ │ 类型: 新业务          来源: 合作伙伴              │  │
│ │ 金额: ¥5,000,000     关闭日期: 2026-06-30       │  │
│ │ 负责人: 王五          联系人: 张三               │  │
│ │ 下一步: 发送正式报价   描述: 为华为5G基站...      │  │
│ └─────────────────────────────────────────────────┘  │
│                                                      │
│ ┌─ 销售活动时间线 ──────────── [+ 新增活动] ──────┐  │
│ │ ● 2026-06-10  电话沟通  与客户确认技术需求      │  │
│ │ ● 2026-06-05  客户拜访  演示产品配置方案        │  │
│ │ ● 2026-06-01  初次接触  展会获取客户需求        │  │
│ └─────────────────────────────────────────────────┘  │
│                                                      │
│ ┌─ 关联报价单 ────────────── [创建报价单] ────────┐  │
│ │ 报价单号  │ 金额    │ 状态    │ 创建时间      │  │
│ │ QT-001   │ 500万   │ 已确认  │ 2026-06-15    │  │
│ │ QT-002   │ 480万   │ 草稿    │ 2026-06-14    │  │
│ └─────────────────────────────────────────────────┘  │
│                                                      │
│ ┌─ 关联合同/订单 ─────────────────────────────────┐  │
│ │ 合同: CT-2026-001 (ACTIVE) → 订单: ORD-001      │  │
│ └─────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────┘
```

### 4.4 合同管理页面

#### 4.4.1 合同列表页

```
┌──────────────────────────────────────────────────────┐
│ 合同管理                   [+ 新增合同] [+ 从商机生成] │
├──────────────────────────────────────────────────────┤
│ [编号___] [名称___] [客户▼] [类型▼] [状态▼] [搜索][重置]│
├──────────────────────────────────────────────────────┤
│ ┌──────────────────────────────────────────────────┐ │
│ │ 编号 │ 名称 │ 客户 │ 类型 │ 状态│金额│开始│结束│...│ │
│ │CT-01│设备采购│华为│PROJECT│ACTIVE│500万│06-01│12-31│ │
│ │CT-02│年度框架│比亚迪│FRAMEWORK│ACTIVE│2000万│01-01│12-31││
│ └──────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────┘
```

#### 4.4.2 创建合同流程（模式A：单项目制）

```
Step 1: 选择商机
┌─────────────────────────────────┐
│ 选择关联商机                     │
│ [商机搜索/下拉：5G基站采购项目]   │
│ 自动带入：客户、配置清单产品       │
│                     [下一步 >]   │
└─────────────────────────────────┘

Step 2: 填写合同信息
┌─────────────────────────────────────┐
│ 合同名称*     [____________]        │
│ 合同编号      [CT-自动生成]         │
│ 合同类型      PROJECT（自动锁定）    │
│ 合同开始日期  [2026-06-15]          │
│ 合同结束日期  [2026-12-31]          │
│ 签约主体      [____________]        │
│ 付款条款      [____________]        │
│ 负责人        [▼ 用户选择]          │
│                                     │
│ 产品明细（来自配置清单，可调整）     │
│ ┌─────────────────────────────────┐ │
│ │ 产品编码 │ 名称 │ 数量 │ 单价  │ │ │
│ │ ARC-200P│弧焊机│ 10  │ ¥50万 │ │ │
│ │ ...                             │ │ │
│ └─────────────────────────────────┘ │
│                         [创建合同]  │
└─────────────────────────────────────┘
```

### 4.5 订单管理页面

#### 4.5.1 订单列表页（与合同列表类似）

#### 4.5.2 订单详情页

```
┌──────────────────────────────────────────────────────┐
│ [< 返回]  订单详情：ORD-2026-001                      │
├──────────────────────────────────────────────────────┤
│ ┌─ 订单信息 ──────────────────────────────────────┐  │
│ │ 订单编号: ORD-2026-001  状态: IN_PRODUCTION      │  │
│ │ 关联合同: CT-2026-001    客户: 华为技术           │  │
│ │ 关联报价: QT-001         总金额: ¥5,000,000      │  │
│ │ 订单日期: 2026-06-15    期望交付: 2026-07-30     │  │
│ │ 收货地址: 深圳市...      账单地址: 深圳市...      │  │
│ └─────────────────────────────────────────────────┘  │
│                                                      │
│ ┌─ 订单明细 ────────────── [+ 添加明细] ──────────┐  │
│ │ 行号│产品编码│产品名称 │数量 │单价  │金额 │折扣│税│ │
│ │ 1  │ARC-200P│弧焊机   │10  │50万  │500万│0%  │13│ │
│ │ 2  │SP-210D │点焊机   │5   │30万  │150万│5%  │13│ │
│ │                合计: ¥6,500,000                │  │
│ └─────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────┘
```

### 4.6 UI交互统一规范

| 规范项 | 说明 |
|--------|------|
| 页面容器 | `class="cpq-page"`, 内边距16px |
| 列表操作列宽度 | 200-280px, `fixed="right"` |
| 弹窗宽度 | 新增/编辑Dialog: 600-700px, 详情Drawer: 500px |
| 成功提示 | `ElMessage.success('操作成功')` |
| 删除确认 | `ElMessageBox.confirm` |
| 表格加载 | `v-loading="loading"` |
| 空状态 | `<el-empty v-if="list.length===0" description="暂无数据" />` |
| 分页条 | `<el-pagination>` 固定布局：`total, sizes, prev, pager, next` |

---

## 5. 技术方案设计

### 5.1 后端模块结构

在 `ruoyi-modules/` 下新建 Maven 模块：

```
ruoyi-modules/
└── ruoyi-cpq-crm/                      # CRM业务模块（新增）
    ├── pom.xml
    └── src/main/java/org/dromara/cpq/crm/
        ├── controller/
        │   ├── CpqCrmAccountController.java     # 客户CRUD
        │   ├── CpqCrmOpportunityController.java  # 商机CRUD + 关联查询
        │   ├── CpqCrmContractController.java     # 合同CRUD
        │   ├── CpqCrmOrderController.java        # 订单CRUD + 明细管理
        │   └── CpqCrmActivityController.java     # 销售活动CRUD
        ├── service/
        │   ├── ICpqCrmOpportunityService.java
        │   ├── ICpqCrmContractService.java
        │   ├── ICpqCrmOrderService.java
        │   └── impl/
        │       ├── CpqCrmOpportunityServiceImpl.java
        │       ├── CpqCrmContractServiceImpl.java
        │       └── CpqCrmOrderServiceImpl.java
        ├── mapper/
        │   ├── CpqCrmOpportunityMapper.java
        │   ├── CpqCrmContractMapper.java
        │   ├── CpqCrmOrderMapper.java
        │   ├── CpqCrmOrderLineMapper.java
        │   └── CpqCrmActivityMapper.java
        └── domain/
            ├── CpqCrmOpportunity.java
            ├── CpqCrmContract.java
            ├── CpqCrmOrder.java
            ├── CpqCrmOrderLine.java
            ├── CpqCrmActivity.java
            ├── bo/
            │   ├── CpqCrmOpportunityBo.java
            │   ├── CpqCrmContractBo.java
            │   ├── CpqCrmOrderBo.java
            │   └── CpqCrmActivityBo.java
            └── vo/
                ├── CpqCrmOpportunityVo.java
                ├── CpqCrmContractVo.java
                ├── CpqCrmOrderVo.java
                ├── CpqCrmOrderLineVo.java
                └── CpqCrmActivityVo.java
```

### 5.2 Maven依赖

`ruoyi-cpq-crm/pom.xml` 依赖：
- `ruoyi-cpq-customer`（复用cpq_account、cpq_channel、cpq_agreement_price、cpq_territory的Mapper）
- `ruoyi-cpq-quote`（关联报价单查询）
- `ruoyi-common-core`、`ruoyi-common-security`、`ruoyi-common-tenant`、`ruoyi-common-mybatis`

### 5.3 前端目录结构

```
cpq-portal/src/
├── api/
│   └── cpq/
│       └── crm.ts                          # CRM API（全部接口）
├── store/
│   └── crm.ts                              # useCrmStore（可选，如需要跨组件状态）
├── router/index.ts                         # 新增CRM路由
├── config/menu.ts                          # 新增"CRM信息"菜单分组
└── views/
    └── crm/
        ├── AccountList.vue                 # 客户列表页
        ├── AccountDetail.vue               # 客户详情页
        ├── OpportunityList.vue             # 商机列表页
        ├── OpportunityDetail.vue           # 商机详情页（含活动时间线）
        ├── ContractList.vue                # 合同列表页
        ├── ContractForm.vue                # 合同创建/编辑页（Step流程）
        ├── ContractDetail.vue              # 合同详情页
        ├── OrderList.vue                   # 订单列表页
        ├── OrderDetail.vue                 # 订单详情页（含明细表）
        └── components/
            ├── CustomerSelect.vue          # 客户下拉选择器（可复用）
            ├── OpportunitySelect.vue       # 商机下拉选择器
            ├── ActivityTimeline.vue        # 活动时间线组件
            └── OrderLineEditor.vue         # 订单明细编辑器
```

### 5.4 代码实现规范

**后端 Entity**：
```java
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_crm_opportunity")
public class CpqCrmOpportunity extends TenantEntity {
    @TableId
    private Long opportunityId;
    private String opportunityName;
    private String opportunityCode;
    private Long accountId;
    private String stage;
    // ... 其余字段
}
```

**后端 Mapper**：
```java
@Mapper
public interface CpqCrmOpportunityMapper extends BaseMapperPlus<CpqCrmOpportunity, CpqCrmOpportunity> {
}
```

**后端 Controller**（标准分页查询）：
```java
@RestController
@RequestMapping("/cpq/crm/opportunity")
public class CpqCrmOpportunityController {
    
    @GetMapping("/list")
    public TableDataInfo<CpqCrmOpportunityVo> list(CpqCrmOpportunityBo bo, PageQuery pageQuery) {
        return service.queryPageList(bo, pageQuery);
    }
    
    @GetMapping("/{id}")
    public R<CpqCrmOpportunityVo> getById(@PathVariable Long id) {
        return R.ok(service.getById(id));
    }
    
    @PostMapping
    public R<Void> add(@RequestBody CpqCrmOpportunityBo bo) {
        return toAjax(service.insertByBo(bo));
    }
    
    @PutMapping
    public R<Void> edit(@RequestBody CpqCrmOpportunityBo bo) {
        return toAjax(service.updateByBo(bo));
    }
    
    @DeleteMapping("/{ids}")
    public R<Void> remove(@PathVariable Long[] ids) {
        return toAjax(service.deleteWithValidByIds(Arrays.asList(ids)));
    }
}
```

**URL路径规范**：`/cpq/crm/{resource}/...`
- 客户：`/cpq/crm/account/list`
- 商机：`/cpq/crm/opportunity/list`
- 合同：`/cpq/crm/contract/list`
- 订单：`/cpq/crm/order/list`
- 活动：`/cpq/crm/activity/list`

**前端 API 模式**（`api/cpq/crm.ts`）：
```typescript
import request from '@/utils/request'

// 类型定义
export interface OpportunityVo {
  opportunityId: number
  opportunityName: string
  opportunityCode: string
  accountId: number
  accountName?: string  // 关联查询字段
  stage: string
  amount: number
  // ...
}

export interface OpportunityBo {
  opportunityId?: number
  opportunityName: string
  opportunityCode?: string
  accountId: number
  stage: string
  // ...
}

// CRUD函数
export function listOpportunity(params?: Record<string, unknown>) {
  return request.get<{ rows: OpportunityVo[]; total: number }>('/cpq/crm/opportunity/list', { params })
}
export function getOpportunity(id: number) {
  return request.get<OpportunityVo>('/cpq/crm/opportunity/' + id)
}
export function addOpportunity(data: OpportunityBo) {
  return request.post('/cpq/crm/opportunity', data)
}
export function updateOpportunity(data: OpportunityBo) {
  return request.put('/cpq/crm/opportunity', data)
}
export function delOpportunity(ids: number[]) {
  return request.delete('/cpq/crm/opportunity/' + ids.join(','))
}
```

---

## 6. 接口设计

### 6.1 客户接口（cpq_crm_account）

> 注：客户CRUD复用现有 `ruoyi-cpq-customer` 模块的 `CpqAccountController`，CRM信息模块仅需调用现有API。前端封装在 `crm.ts` 中。

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/cpq/customer/account/list` | 分页查询客户列表 |
| GET | `/cpq/customer/account/{id}` | 获取客户详情 |
| POST | `/cpq/customer/account` | 新增客户 |
| PUT | `/cpq/customer/account` | 更新客户 |
| DELETE | `/cpq/customer/account/{ids}` | 删除客户 |

### 6.2 商机接口

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/cpq/crm/opportunity/list` | 分页查询商机列表 |
| GET | `/cpq/crm/opportunity/{id}` | 获取商机详情（含关联客户信息） |
| POST | `/cpq/crm/opportunity` | 新增商机 |
| PUT | `/cpq/crm/opportunity` | 更新商机 |
| PUT | `/cpq/crm/opportunity/{id}/stage` | 推进商机阶段 |
| DELETE | `/cpq/crm/opportunity/{ids}` | 删除商机 |
| GET | `/cpq/crm/opportunity/{id}/quotes` | 获取商机关联的报价单列表 |
| GET | `/cpq/crm/opportunity/{id}/activities` | 获取商机关联的销售活动列表 |

**请求示例 — 新增商机**：
```json
POST /cpq/crm/opportunity
{
  "opportunityName": "5G基站采购项目",
  "accountId": 1001,
  "stage": "PROSPECTING",
  "closeDate": "2026-06-30",
  "amount": 5000000.00,
  "opportunityType": "NEW_BUSINESS",
  "leadSource": "PARTNER",
  "ownerId": 10001,
  "contactName": "张三",
  "contactPhone": "13800138000",
  "description": "为华为5G基站建设提供弧焊机器人"
}
```

**响应示例**：
```json
{
  "code": 200,
  "msg": "操作成功"
}
```

**请求示例 — 推进阶段**：
```json
PUT /cpq/crm/opportunity/50001/stage
{
  "stage": "PROPOSAL",
  "nextStep": "发送正式报价方案"
}
```

**查询列表请求参数**：

| 参数 | 类型 | 说明 |
|------|------|------|
| pageNum | int | 页码（默认1） |
| pageSize | int | 每页条数（默认10） |
| opportunityName | string | 商机名称（模糊搜索） |
| opportunityCode | string | 商机编码（模糊搜索） |
| accountId | long | 客户ID筛选 |
| stage | string | 阶段筛选 |
| ownerId | long | 负责人筛选 |

### 6.3 合同接口

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/cpq/crm/contract/list` | 分页查询合同列表 |
| GET | `/cpq/crm/contract/{id}` | 获取合同详情（含关联客户/商机/订单） |
| POST | `/cpq/crm/contract` | 新增合同 |
| POST | `/cpq/crm/contract/from-opportunity` | 从商机生成合同 |
| PUT | `/cpq/crm/contract` | 更新合同 |
| PUT | `/cpq/crm/contract/{id}/status` | 变更合同状态 |
| DELETE | `/cpq/crm/contract/{ids}` | 删除合同 |
| GET | `/cpq/crm/contract/{id}/orders` | 获取合同关联的订单列表 |

**请求示例 — 从商机生成合同**：
```json
POST /cpq/crm/contract/from-opportunity
{
  "opportunityId": 50001,
  "contractName": "5G基站设备采购合同",
  "startDate": "2026-06-15",
  "endDate": "2026-12-31",
  "signingParty": "华为技术有限公司",
  "paymentTerms": "30%预付，70%验收后付",
  "ownerId": 10001
}
```

### 6.4 订单接口

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/cpq/crm/order/list` | 分页查询订单列表 |
| GET | `/cpq/crm/order/{id}` | 获取订单详情（含明细行） |
| POST | `/cpq/crm/order` | 新增订单 |
| POST | `/cpq/crm/order/from-quote` | 从报价生成订单 |
| PUT | `/cpq/crm/order` | 更新订单 |
| PUT | `/cpq/crm/order/{id}/status` | 变更订单状态 |
| DELETE | `/cpq/crm/order/{ids}` | 删除订单 |
| POST | `/cpq/crm/order/{id}/line` | 新增订单明细行 |
| PUT | `/cpq/crm/order/{id}/line` | 更新订单明细行 |
| DELETE | `/cpq/crm/order/{id}/line/{lineId}` | 删除订单明细行 |

**请求示例 — 从报价生成订单**：
```json
POST /cpq/crm/order/from-quote
{
  "quoteId": 30001,
  "contractId": 40001,
  "deliveryDate": "2026-07-30",
  "shippingAddress": "深圳市龙岗区坂田华为基地",
  "billingAddress": "深圳市龙岗区坂田华为基地",
  "ownerId": 10001
}
```

### 6.5 销售活动接口

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/cpq/crm/activity/list` | 分页查询（按商机ID筛选） |
| POST | `/cpq/crm/activity` | 新增销售活动 |
| PUT | `/cpq/crm/activity` | 更新活动 |
| DELETE | `/cpq/crm/activity/{ids}` | 删除活动 |

**请求示例 — 新增活动**：
```json
POST /cpq/crm/activity
{
  "opportunityId": 50001,
  "accountId": 1001,
  "activityType": "CALL",
  "subject": "电话确认技术需求",
  "activityDate": "2026-06-10",
  "activityTime": "14:30",
  "durationMinutes": 30,
  "participants": "王五, 张三",
  "result": "客户确认弧焊机器人技术参数，要求增加激光焊缝跟踪功能",
  "nextPlan": "下周三安排现场演示",
  "ownerId": 10001
}
```

### 6.6 错误码定义

| 错误码 | 说明 |
|--------|------|
| 200 | 操作成功 |
| 500 | 服务器内部错误 |
| CRM_001 | 商机已关闭，无法修改 |
| CRM_002 | 阶段不可回退 |
| CRM_003 | 客户编码已存在 |
| CRM_004 | 合同编号已存在 |
| CRM_005 | 订单编号已存在 |
| CRM_006 | 合同非ACTIVE状态，无法创建订单 |
| CRM_007 | 统一社会信用代码格式错误（需18位字母数字） |

---

## 7. 集成设计

### 7.1 商机→报价的关联

- 商机详情页展示**关联报价单列表**（查询 `cpq_quote` 表中 `opportunity_id = 当前商机ID` 的记录）
- 提供「创建报价单」按钮：携带 `opportunityId` 参数跳转到 `/quoting`（产品配置器→定价→报价）
- 报价单创建时，在 `cpq_quote` 中回填 `opportunity_id`

### 7.2 商机→合同的转换（CLOSED_WON触发）

```
商机状态 → CLOSED_WON
    │
    ├─ 前端提示："商机已赢得，是否为该商机创建合同？"
    │
    ├─ [是] → 跳转 ContractForm.vue（模式A流程）
    │         Step 1: 自动加载商机关联的报价单
    │         Step 2: 从确认的报价中提取配置清单产品
    │         Step 3: 填写合同基础信息，确认产品明细
    │         Step 4: 创建合同（DRAFT状态）
    │
    └─ [否] → 返回商机详情（后续可手动"从商机生成合同"）
```

### 7.3 合同→订单的生成

```
模式A（单项目制合同）:
  合同创建时，自动在合同下生成一个订单（DRAFT状态），
  订单明细直接从合同的配置清单产品填充。

模式B（框架合同）:
  合同ACTIVE后，提供「新建订单」按钮，
  订单创建时选择框架合同下的产品并手工配置数量。
```

### 7.4 报价→订单的直接转换

```
报价单确认后:
  报价详情页提供「生成订单」按钮
    │
    ├─ 选择关联合同（或新建合同）
    └─ 自动创建订单，明细来自报价配置清单
```

### 7.5 阶段推进自动记录活动

商机阶段每次推进时，自动在 `cpq_crm_activity` 中插入一条系统活动记录：
```json
{
  "activityType": "SYSTEM",
  "subject": "阶段变更：PROSPECTING → QUALIFICATION",
  "activityDate": "2026-06-15",
  "result": "系统自动记录"
}
```

---

## 8. 菜单与路由配置

### 8.1 菜单配置（cpq-portal/src/config/menu.ts）

在现有8个分组之后新增第9个分组：

```typescript
// 新增图标导入
import { User, Aim, DocumentAdd, Tickets, Notebook } from '@element-plus/icons-vue'
// ... 已有导入 ...

{
  label: 'CRM信息',
  icon: User,
  children: [
    { path: '/crm/account',      label: '客户管理', icon: User },
    { path: '/crm/opportunity',  label: '商机管理', icon: Aim },
    { path: '/crm/contract',     label: '合同管理', icon: DocumentAdd },
    { path: '/crm/order',        label: '订单管理', icon: Tickets },
  ]
},
```

### 8.2 路由配置（cpq-portal/src/router/index.ts）

```typescript
// ===== CRM信息模块 =====
{
  path: 'crm/account',
  name: 'CrmAccountList',
  component: () => import('@/views/crm/AccountList.vue'),
  meta: { title: '客户管理' }
},
{
  path: 'crm/account/:id',
  name: 'CrmAccountDetail',
  component: () => import('@/views/crm/AccountDetail.vue'),
  meta: { title: '客户详情' }
},
{
  path: 'crm/opportunity',
  name: 'CrmOpportunityList',
  component: () => import('@/views/crm/OpportunityList.vue'),
  meta: { title: '商机管理' }
},
{
  path: 'crm/opportunity/:id',
  name: 'CrmOpportunityDetail',
  component: () => import('@/views/crm/OpportunityDetail.vue'),
  meta: { title: '商机详情' }
},
{
  path: 'crm/contract',
  name: 'CrmContractList',
  component: () => import('@/views/crm/ContractList.vue'),
  meta: { title: '合同管理' }
},
{
  path: 'crm/contract/create',
  name: 'CrmContractCreate',
  component: () => import('@/views/crm/ContractForm.vue'),
  meta: { title: '新建合同' }
},
{
  path: 'crm/contract/:id',
  name: 'CrmContractDetail',
  component: () => import('@/views/crm/ContractDetail.vue'),
  meta: { title: '合同详情' }
},
{
  path: 'crm/order',
  name: 'CrmOrderList',
  component: () => import('@/views/crm/OrderList.vue'),
  meta: { title: '订单管理' }
},
{
  path: 'crm/order/:id',
  name: 'CrmOrderDetail',
  component: () => import('@/views/crm/OrderDetail.vue'),
  meta: { title: '订单详情' }
},
```

### 8.3 路由注意事项

- 详情路由 `/:id` 放在列表路由之后，避免被Vue Router将 `/create` 解析为 `:id` 参数
- 合同创建页使用独立路径 `/crm/contract/create`，与详情页 `/crm/contract/:id` 区分

---

## 9. 权限设计

### 9.1 权限字符串定义（cpq-portal/src/config/permissions.ts 追加）

```typescript
// CRM信息模块权限
export const CRM_PERMISSIONS = {
  // 客户管理
  ACCOUNT_LIST:   'cpq:crm:account:list',
  ACCOUNT_ADD:    'cpq:crm:account:add',
  ACCOUNT_EDIT:   'cpq:crm:account:edit',
  ACCOUNT_DELETE: 'cpq:crm:account:delete',
  // 商机管理
  OPPORTUNITY_LIST:   'cpq:crm:opportunity:list',
  OPPORTUNITY_ADD:    'cpq:crm:opportunity:add',
  OPPORTUNITY_EDIT:   'cpq:crm:opportunity:edit',
  OPPORTUNITY_DELETE: 'cpq:crm:opportunity:delete',
  OPPORTUNITY_STAGE:  'cpq:crm:opportunity:stage',  // 阶段推进
  // 合同管理
  CONTRACT_LIST:   'cpq:crm:contract:list',
  CONTRACT_ADD:    'cpq:crm:contract:add',
  CONTRACT_EDIT:   'cpq:crm:contract:edit',
  CONTRACT_DELETE: 'cpq:crm:contract:delete',
  // 订单管理
  ORDER_LIST:   'cpq:crm:order:list',
  ORDER_ADD:    'cpq:crm:order:add',
  ORDER_EDIT:   'cpq:crm:order:edit',
  ORDER_DELETE: 'cpq:crm:order:delete',
}
```

### 9.2 角色分配建议

| 角色 | 客户 | 商机 | 合同 | 订单 |
|------|:----:|:----:|:----:|:----:|
| 销售经理 | 增删改查 | 增删改查+阶段推进 | 增删改查 | 查看 |
| 售前工程师 | 查看 | 增删改查 | 查看 | 查看 |
| 销售运营 | 查看 | 查看 | 增删改查 | 增删改查 |
| 系统管理员 | 全部 | 全部 | 全部 | 全部 |

---

## 10. 实施计划

### 10.1 分阶段交付

#### Phase 1：数据基础 + 客户/商机管理（预估3人天）

| 任务 | 说明 | 负责人 | 验收标准 |
|------|------|--------|----------|
| T1.1 DDL脚本 | 编写 `sql/cpq_d13_crm.sql`（4表+cpq_account ALTER） | 后端 | DDL语法正确，在测试DB执行通过 |
| T1.2 后端Entity/Mapper | 新建4个Entity + 5个Mapper + BO/VO | 后端 | Maven compile通过 |
| T1.3 客户API封装 | 前端 `api/cpq/crm.ts` 客户接口 | 前端 | API类型定义正确 |
| T1.4 客户列表页 | `AccountList.vue` — 列表/搜索/新增/编辑弹窗/删除 | 前端 | 完整CRUD交互正常 |
| T1.5 客户详情页 | `AccountDetail.vue` — 基本信息+关联商机/合同/订单 | 前端 | 详情页数据正确展示 |
| T1.6 商机Controller+Service | `CpqCrmOpportunityController` + Service完整CRUD | 后端 | curl测试通过 |
| T1.7 商机列表页 | `OpportunityList.vue` — 列表/搜索/新增/编辑/阶段颜色标签 | 前端 | 完整CRUD交互正常 |
| T1.8 商机详情页 | `OpportunityDetail.vue` — 商机信息+关联报价+活动时间线 | 前端 | 关联数据正确展示 |
| T1.9 商机阶段推进 | 后端stage推进逻辑 + 前端操作按钮 + 概率自动更新 | 前后端 | 阶段变更+概率同步+不可回退 |
| T1.10 菜单+路由 | menu.ts + router/index.ts + 图标导入 | 前端 | 菜单渲染正确，路由跳转正常 |
| T1.11 集成测试 | 客户→创建商机→推进阶段→关联报价 完整流程 | QA | 流程走通无阻塞 |

#### Phase 2：合同/订单管理（预估3人天）

| 任务 | 说明 | 负责人 | 验收标准 |
|------|------|--------|----------|
| T2.1 合同Controller+Service | 合同完整CRUD + 状态流转 | 后端 | curl测试通过 |
| T2.2 合同列表页 | `ContractList.vue` — 列表/搜索/类型+状态标签 | 前端 | 列表交互正常 |
| T2.3 合同创建（从商机） | `ContractForm.vue` — Step流程：选商机→填信息→确认产品明细 | 前端 | 完整创建流程正常 |
| T2.4 合同详情页 | `ContractDetail.vue` — 信息+关联订单+产品明细 | 前端 | 关联数据正确 |
| T2.5 订单Controller+Service | 订单CRUD + 明细行管理 + 从报价生成 | 后端 | curl测试通过 |
| T2.6 订单列表页 | `OrderList.vue` — 列表/搜索/状态标签 | 前端 | 列表交互正常 |
| T2.7 订单详情页 | `OrderDetail.vue` — 信息+明细表+编辑/添加明细 | 前端 | 明细CRUD正常 |
| T2.8 从报价生成订单 | 后端集成逻辑 + 前端触发按钮 | 前后端 | 配置清单→订单明细正确 |
| T2.9 集成测试 | 商机CLOSED_WON→合同→订单 完整流程 | QA | 流程走通无阻塞 |

#### Phase 3：销售活动 + 增强功能（预估2人天）

| 任务 | 说明 | 负责人 | 验收标准 |
|------|------|--------|----------|
| T3.1 活动Controller | 活动CRUD | 后端 | curl测试通过 |
| T3.2 活动时间线组件 | `ActivityTimeline.vue` + 新增活动弹窗 | 前端 | 时间线+新增交互正常 |
| T3.3 合同审批流程 | 合同状态DRAFT→PENDING_APPROVAL→PENDING_SIGN→ACTIVE | 前后端 | 状态流转正常 |
| T3.4 订单状态流转 | 订单DRAFT→PENDING_APPROVAL→APPROVED→IN_PRODUCTION→... | 前后端 | 状态流转正常 |
| T3.5 菜单SQL | `sql/cpq_menu.sql` 追加50150-50179菜单项 | 后端 | SQL执行无错误 |
| T3.6 整体回归测试 | 端到端流程：客户→商机→报价→合同→订单 全链路 | QA | 全链路通过 |

### 10.2 依赖关系图

```
Phase 1 ──────────── Phase 2 ──────────── Phase 3
T1.1 DDL
 ├─ T1.2 Entity/Mapper
 ├─ T1.3 前端API
 ├─ T1.4-1.5 客户页面
 ├─ T1.6-1.8 商机页面
 └─ T1.9-1.10 阶段+菜单
      │
      ├─ T1.11 集成测试
      │
      ▼
T2.1 合同后端 ── T2.2-2.4 合同页面
T2.5 订单后端 ── T2.6-2.7 订单页面
T2.8 报价→订单集成
      │
      ├─ T2.9 集成测试
      │
      ▼
T3.1-3.2 活动功能
T3.3-3.4 状态流转
T3.5 菜单SQL
T3.6 回归测试
```

### 10.3 验收标准总览

| 验收项 | 标准 |
|--------|------|
| 后端编译 | `mvn compile` 通过，零错误 |
| 后端测试 | 所有CRUD端点 curl 测试通过（200/数据正确返回） |
| 前端编译 | `vue-tsc --noEmit` 零新增错误 |
| 前端Lint | 零新增Lint错误 |
| 菜单渲染 | 8个二级菜单项正确显示在CRM信息分组下 |
| 路由导航 | 所有路由跳转正常，面包屑正确 |
| CRUD功能 | 客户/商机/合同/订单 4个对象均支持增删改查 |
| 关联展示 | 客户详情展示关联商机/合同/订单，商机详情展示关联报价/活动 |
| 集成流程 | 商机→报价 关联、商机CLOSED_WON→合同、合同→订单、报价→订单 4条链路正常 |
| 状态流转 | 商机阶段（6阶段，不可回退）、合同状态（6状态）、订单状态（7状态）正确流转 |

---

## 附录A：与Salesforce的字段映射

### Account → cpq_account

| Salesforce字段 | cpq_account列 | 说明 |
|----------------|--------------|------|
| Name | account_name | — |
| AccountNumber | account_code | — |
| Type | account_type | 简化：DIRECT/CHANNEL/PARTNER/ENTERPRISE |
| Industry | industry | — |
| Phone | contact_phone | — |
| Website | (不实现) | 制造业客户不需要 |
| BillingAddress | address | — |
| AnnualRevenue | (不实现) | 暂不需要 |
| OwnerId | (不实现) | 通过create_by追踪 |
| — | legal_representative | **新增** |
| — | unified_social_credit_code | **新增** |

### Opportunity → cpq_crm_opportunity

| Salesforce字段 | cpq_crm_opportunity列 | 说明 |
|----------------|----------------------|------|
| Name | opportunity_name | — |
| StageName | stage | 精简为6阶段 |
| CloseDate | close_date | — |
| Amount | amount | — |
| Probability | probability | 阶段切换自动计算 |
| Type | opportunity_type | — |
| LeadSource | lead_source | — |
| NextStep | next_step | — |
| Description | description | — |
| AccountId | account_id | — |
| OwnerId | owner_id | — |
| ContactId | (简化) | 用contact_name/contact_phone代替 |

---

## 附录B：文件清单

| 操作 | 文件 | 说明 |
|------|------|------|
| **新建** | `sql/cpq_d13_crm.sql` | CRM表DDL（4表 + ALTER） |
| **新建** | `ruoyi-modules/ruoyi-cpq-crm/pom.xml` | CRM模块POM |
| **新建** | `ruoyi-modules/ruoyi-cpq-crm/.../controller/*.java` | 5个Controller |
| **新建** | `ruoyi-modules/ruoyi-cpq-crm/.../service/*.java` | 3个Service + 3个Impl |
| **新建** | `ruoyi-modules/ruoyi-cpq-crm/.../mapper/*.java` | 5个Mapper |
| **新建** | `ruoyi-modules/ruoyi-cpq-crm/.../domain/*.java` | 5个Entity + 4个BO + 5个VO |
| **新建** | `cpq-portal/src/api/cpq/crm.ts` | CRM前端API |
| **新建** | `cpq-portal/src/views/crm/AccountList.vue` | 客户列表 |
| **新建** | `cpq-portal/src/views/crm/AccountDetail.vue` | 客户详情 |
| **新建** | `cpq-portal/src/views/crm/OpportunityList.vue` | 商机列表 |
| **新建** | `cpq-portal/src/views/crm/OpportunityDetail.vue` | 商机详情 |
| **新建** | `cpq-portal/src/views/crm/ContractList.vue` | 合同列表 |
| **新建** | `cpq-portal/src/views/crm/ContractForm.vue` | 合同创建 |
| **新建** | `cpq-portal/src/views/crm/ContractDetail.vue` | 合同详情 |
| **新建** | `cpq-portal/src/views/crm/OrderList.vue` | 订单列表 |
| **新建** | `cpq-portal/src/views/crm/OrderDetail.vue` | 订单详情 |
| **新建** | `cpq-portal/src/views/crm/components/ActivityTimeline.vue` | 活动时间线 |
| **新建** | `cpq-portal/src/views/crm/components/CustomerSelect.vue` | 客户选择器 |
| **新建** | `cpq-portal/src/views/crm/components/OrderLineEditor.vue` | 订单明细编辑 |
| **修改** | `ruoyi-modules/pom.xml` | 添加 ruoyi-cpq-crm 模块 |
| **修改** | `ruoyi-admin/pom.xml` | 添加 ruoyi-cpq-crm 依赖 |
| **修改** | `cpq-portal/src/router/index.ts` | 新增10条路由 |
| **修改** | `cpq-portal/src/config/menu.ts` | 新增CRM信息分组 |
| **修改** | `cpq-portal/src/config/permissions.ts` | 新增CRM权限字符串 |
| **修改** | `sql/cpq_menu.sql` | 追加50150-50179菜单 |
| **修改** | `sql/cpq_d06_customer.sql` | cpq_account增加2个字段（或新增ALTER脚本） |

---

> **文档结束** — 开发团队可依据本文档直接开展 Phase 1 开发工作。如有疑问，参照各章节中的具体字段定义、UI线框图、API Schema和代码示例。
