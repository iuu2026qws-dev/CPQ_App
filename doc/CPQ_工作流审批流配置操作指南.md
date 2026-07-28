# CPQ 工作流与审批流配置操作指南

> 以「工艺确认流程」为例，涵盖数据库配置、API 操作和 Agent 集成。

---

## 一、流程概览

```
销售选品 → 工艺确认(PENDING) → 审批链(IN_PROGRESS) → 审批人操作 → CONFIRMED/REJECTED
                                                  ↘ 替代推荐(REPLACE) → 销售接受/拒绝
```

### 涉及 5 张核心表

| 表 | 作用 | 类比 |
|------|------|------|
| `cpq_approval_rule` | 定义**什么情况**触发审批 | 审批规则模板 |
| `cpq_approval_matrix` | 定义**谁来审批** | 审批人分配表 |
| `cpq_approval_chain` | 一次审批的**运行实例** | 工单 |
| `cpq_approval_record` | 审批链中**每一步**的记录 | 审批节点 |
| `cpq_process_confirm` | 工艺确认单 | 业务单据 |

---

## 二、表结构与配置

### 2.1 cpq_approval_rule — 审批规则

```sql
CREATE TABLE cpq_approval_rule (
  rule_id           bigint NOT NULL,
  tenant_id         varchar(20) DEFAULT '000000',
  rule_name         varchar(200) NOT NULL,              -- 规则名称
  trigger_type      varchar(30) NOT NULL,               -- 触发类型
  trigger_value     decimal(18,2) DEFAULT NULL,          -- 触发阈值
  approval_chain_json json NOT NULL,                     -- 审批链模板JSON
  priority          int DEFAULT '0',                     -- 优先级
  status            char(1) DEFAULT '0',                 -- 0=启用 1=停用
  del_flag          char(1) DEFAULT '0'
);
```

**trigger_type 可选值：**

| 值 | 含义 | 示例 |
|----|------|------|
| `DISCOUNT_EXCEED` | 折扣超标 | 折扣 > 20% 触发 |
| `MARGIN_BELOW` | 毛利过低 | 毛利 < 15% 触发 |
| `AMOUNT_ABOVE` | 金额超限 | 报价 > 100万 触发 |
| `NEW_CONFIG` | 首次配置 | 新产品首次配置 |
| `CROSS_REGION` | 跨区域 | 跨区域销售 |
| `CUSTOM_PART` | 定制件 | 含定制件 |
| `FIRST_ORDER` | 首单 | 新客户首单 |
| `EXPORT_CONTROL` | 出口管制 | 出口管制产品 |
| `ALWAYS` | 始终触发 | 工艺确认专用 |

**approval_chain_json 格式：**
```json
[
  {"step": 1, "approver_role": "process_scheduler", "type": "SERIAL"},
  {"step": 2, "approver_role": "sales_manager",     "type": "SERIAL"}
]
```

### 2.2 cpq_approval_matrix — 审批矩阵

```sql
CREATE TABLE cpq_approval_matrix (
  matrix_id         bigint NOT NULL,
  tenant_id         varchar(20) DEFAULT '000000',
  dimension_type    varchar(30) NOT NULL,              -- 维度类型
  dimension_value   varchar(200) NOT NULL,             -- 维度值
  approver_role     varchar(50) DEFAULT NULL,          -- 审批人角色
  approver_ids      varchar(500) DEFAULT NULL,          -- 固定审批人ID列表
  min_approvals     int DEFAULT '1',                    -- 最少通过数
  status            char(1) DEFAULT '0',
  del_flag          char(1) DEFAULT '0'
);
```

**dimension_type 可选值：**

| 值 | 含义 | 示例 dimension_value |
|----|------|---------------------|
| `REGION` | 按区域 | `CN`、`EU`、`NA` |
| `DEPT` | 按部门 | `1001`（部门ID） |
| `AMOUNT_RANGE` | 按金额区间 | `0-100000`、`100000-500000` |
| `PRODUCT_LINE` | 按产品线 | `507`（锂亚ER电池） |
| `QUOTE_TYPE` | 按报价类型 | `STANDARD`、`CUSTOM` |

### 2.3 cpq_approval_chain — 审批链（运行时）

```sql
CREATE TABLE cpq_approval_chain (
  chain_id          bigint NOT NULL,
  tenant_id         varchar(20) DEFAULT '000000',
  quote_id          bigint NOT NULL,                    -- 关联业务ID（工艺确认时=resultId）
  rule_id           bigint DEFAULT NULL,                -- 触发的规则ID
  current_step      int DEFAULT '1',
  total_steps       int DEFAULT '1',
  status            varchar(20) DEFAULT 'IN_PROGRESS',  -- IN_PROGRESS/COMPLETED/REJECTED
  submitted_by      bigint DEFAULT NULL,
  submitted_time    datetime DEFAULT NULL,
  completed_time    datetime DEFAULT NULL,
  sla_hours         int DEFAULT '48'
);
```

### 2.4 cpq_approval_record — 审批记录（运行时）

```sql
CREATE TABLE cpq_approval_record (
  record_id         bigint NOT NULL,
  tenant_id         varchar(20) DEFAULT '000000',
  chain_id          bigint NOT NULL,                    -- → cpq_approval_chain
  step_number       int NOT NULL,
  approver_id       bigint NOT NULL,                    -- → sys_user
  approver_name     varchar(100) DEFAULT NULL,
  action            varchar(30) DEFAULT NULL,           -- APPROVED/REJECTED/REPLACE
  comment           varchar(1000) DEFAULT NULL,
  action_time       datetime DEFAULT NULL
);
```

### 2.5 cpq_process_confirm — 工艺确认单

```sql
CREATE TABLE cpq_process_confirm (
  confirm_id        bigint NOT NULL,
  tenant_id         varchar(20) DEFAULT '000000',
  result_id         bigint NOT NULL,                    -- → cpq_match_result
  model_id          bigint NOT NULL,                    -- 选定的产品
  approval_chain_id bigint DEFAULT NULL,                -- → cpq_approval_chain
  confirm_status    varchar(20) DEFAULT 'PENDING',      -- PENDING/CONFIRMED/REJECTED
  confirm_by        bigint DEFAULT NULL,
  confirm_time      datetime DEFAULT NULL,
  reject_reason     varchar(1000) DEFAULT NULL,
  requirement_text  varchar(2000) DEFAULT NULL,          -- 客户需求描述
  replaced_model_id bigint DEFAULT NULL,                 -- 替代产品ID
  replaced_reason   varchar(1000) DEFAULT NULL
);
```

---

## 三、工艺确认流程 — 完整生命周期

### 3.1 流程步骤

```
步骤1: 销售选品
  → POST /cpq/process/confirm  {action:"CONFIRM"}
  → 创建 cpq_process_confirm (status=PENDING)
  → 创建 cpq_approval_chain (status=IN_PROGRESS)
  → 创建 cpq_approval_record (action=NULL, 待审批)

步骤2: 审批人查看待办
  → GET /cpq/process/pending?approverId=1
  → 返回待审批列表（含产品信息、客户需求、评分详情）

步骤3a: 审批通过
  → POST /cpq/process/approve  {chainId, action:"APPROVED"}
  → 更新 cpq_approval_record (action=APPROVED)
  → 更新 cpq_approval_chain (status=COMPLETED)
  → 更新 cpq_process_confirm (status=CONFIRMED)

步骤3b: 审批驳回
  → POST /cpq/process/approve  {chainId, action:"REJECTED"}
  → 同上三级联更新，状态全部变为 REJECTED

步骤3c: 替代推荐（审批人）
  → POST /cpq/process/confirm  {action:"REPLACE", replacedModelCode, replacedReason}
  → 更新 cpq_process_confirm (replaced_model_id, 状态保持 PENDING)

步骤4: 销售响应替代
  → 接受: POST /cpq/process/confirm  {action:"CONFIRM_REPLACEMENT", confirmId, accept:true}
  → 拒绝: POST /cpq/process/confirm  {action:"CONFIRM_REPLACEMENT", confirmId, accept:false}
```

### 3.2 状态机

```
                    ┌─────────┐
                    │ PENDING │ ← 初始提交
                    └────┬────┘
               ┌─────────┼─────────┐
               ▼         ▼         ▼
          CONFIRMED  REJECTED   PENDING(替代推荐)
                              ┌──────┴──────┐
                              ▼              ▼
                         接受替代        拒绝替代
                         CONFIRMED       PENDING(恢复原品)
```

---

## 四、API 操作示例

### 4.1 销售提交工艺确认

```bash
TOKEN=$(curl -s -X POST http://localhost:30000/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"admin123","clientId":"e5cd7e4891bf95d1d19206ce24a7b32e","grantType":"password","tenantId":"000000"}' \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['access_token'])")

curl -s -X POST http://localhost:30000/cpq/process/confirm \
  -H "Authorization: Bearer $TOKEN" \
  -H "clientid: e5cd7e4891bf95d1d19206ce24a7b32e" \
  -H 'Content-Type: application/json' \
  -d '{
    "resultId": 2951062,
    "modelId": 22862,
    "action": "CONFIRM",
    "requirementText": "用途:GPS追踪器\n温度:-40~85℃\n防护:IP67"
  }'
```

**返回：**
```json
{
  "code": 200,
  "data": {
    "confirmId": 1379573,
    "chainId": 1187654321,
    "recordId": 221379574,
    "status": "PENDING",
    "modelCode": "ER34615-BP-001",
    "modelName": "ER34615电池包",
    "message": "已推送至工艺端审核，请在审批中心查看"
  }
}
```

> `recordId` 即用户看到的「审批编号 #221379574」

### 4.2 审批人查看待办

```bash
curl -s "http://localhost:30000/cpq/process/pending?approverId=1" \
  -H "Authorization: Bearer $TOKEN" \
  -H "clientid: e5cd7e4891bf95d1d19206ce24a7b32e"
```

### 4.3 审批人通过

```bash
curl -s -X POST http://localhost:30000/cpq/process/approve \
  -H "Authorization: Bearer $TOKEN" \
  -H "clientid: e5cd7e4891bf95d1d19206ce24a7b32e" \
  -H 'Content-Type: application/json' \
  -d '{"chainId": 1187654321, "action": "APPROVED", "comment": "工艺可行，通过"}'
```

### 4.4 审批人替代推荐

```bash
curl -s -X POST http://localhost:30000/cpq/process/confirm \
  -H "Authorization: Bearer $TOKEN" \
  -H "clientid: e5cd7e4891bf95d1d19206ce24a7b32e" \
  -H 'Content-Type: application/json' \
  -d '{
    "action": "REPLACE",
    "resultId": 2951062,
    "modelId": 22862,
    "replacedModelCode": "ER14505",
    "replacedReason": "推荐ER14505替代，性价比更高"
  }'
```

### 4.5 查询确认状态

```bash
# 通过审批编号查询
curl -s "http://localhost:30000/cpq/process/status/byRecord/221379574" \
  -H "Authorization: Bearer $TOKEN" \
  -H "clientid: e5cd7e4891bf95d1d19206ce24a7b32e"

# 通过匹配结果ID查询
curl -s "http://localhost:30000/cpq/process/status/2951062" \
  -H "Authorization: Bearer $TOKEN" \
  -H "clientid: e5cd7e4891bf95d1d19206ce24a7b32e"
```

### 4.6 查看审批详情

```bash
curl -s "http://localhost:30000/cpq/process/detail/1187654321" \
  -H "Authorization: Bearer $TOKEN" \
  -H "clientid: e5cd7e4891bf95d1d19206ce24a7b32e"
```

---

## 五、配置审批规则（以工艺确认为例）

### 5.1 插入审批规则

```sql
-- 锂原标品匹配推荐 → 始终触发工艺确认
INSERT INTO cpq_approval_rule 
  (rule_id, tenant_id, rule_name, trigger_type, approval_chain_json, status, del_flag) 
VALUES 
  (100, '000000', '锂原标品匹配推荐确认', 'ALWAYS', '[]', '0', '0');
```

### 5.2 插入审批矩阵

```sql
-- 产品线 507（锂亚ER电池）→ process_scheduler 角色审批
INSERT INTO cpq_approval_matrix 
  (matrix_id, tenant_id, dimension_type, dimension_value, approver_role, min_approvals, status, del_flag) 
VALUES 
  (1, '000000', 'PRODUCT_LINE', '507', 'process_scheduler', 1, '0', '0');
```

### 5.3 多维度配置示例

```sql
-- 不同产品线不同审批人
INSERT INTO cpq_approval_matrix VALUES
  (2, '000000', 'PRODUCT_LINE', '507', 'process_scheduler', 1, '0', '0'),  -- 锂亚→工艺调度员
  (3, '000000', 'PRODUCT_LINE', '617', 'senior_engineer',  1, '0', '0');  -- 动力→高级工程师

-- 大金额额外审批
INSERT INTO cpq_approval_matrix VALUES
  (4, '000000', 'AMOUNT_RANGE', '100000-500000', 'sales_manager',   1, '0', '0'),
  (5, '000000', 'AMOUNT_RANGE', '500000-999999', 'sales_director', 1, '0', '0');

-- 跨区域加签
INSERT INTO cpq_approval_matrix VALUES
  (6, '000000', 'REGION', 'EU', 'export_control_officer', 1, '0', '0');
```

---

## 六、Agent 集成要点

### 6.1 Agent 如何调用工艺确认

Agent 的 `select_product` → `submit_feasibility_confirm` → `POST /cpq/process/confirm`

缓存三个关键 ID 供后续使用：
- `resultId` — 匹配结果ID
- `confirmId` — 确认单ID
- `recordId` — 审批编号（用户看到的 #号）

### 6.2 Agent 呈现给用户的流程

```
用户: 选第1款
Agent: 📋 已提交工艺确认
       产品：SKU-ER14250-A 3.6V锂亚电池
       审批编号：#221379574
       状态：审核中

用户: 工艺确认进度
Agent: 当前工艺确认状态：审核中 ⏳

审批人: (在审批中心点击通过)
Agent: ✅ 工艺确认已通过，产品可交付
       需要创建报价吗？
```

### 6.3 confirm_status 对照

| 状态 | 含义 | Agent 回应 |
|------|------|-----------|
| `PENDING` | 审核中 | "请等待工艺端处理" |
| `CONFIRMED` | 已通过 | "产品可交付，需要创建报价吗？" |
| `REJECTED` | 已驳回 | 显示驳回原因 |

---

## 七、常见操作 SQL

```sql
-- 查看所有审批规则
SELECT rule_id, rule_name, trigger_type, status FROM cpq_approval_rule WHERE del_flag='0';

-- 查看审批矩阵配置
SELECT dimension_type, dimension_value, approver_role, min_approvals FROM cpq_approval_matrix WHERE status='0';

-- 查看待审批的工艺确认单
SELECT pc.confirm_id, pc.result_id, pc.confirm_status, 
       m.model_code, m.model_name, ac.chain_id, ac.status
FROM cpq_process_confirm pc
JOIN cpq_product_model m ON pc.model_id=m.model_id
LEFT JOIN cpq_approval_chain ac ON pc.approval_chain_id=ac.chain_id
WHERE pc.tenant_id='000000' AND pc.del_flag='0'
ORDER BY pc.create_time DESC LIMIT 20;

-- 查看某审批链的完整流转
SELECT * FROM cpq_approval_chain WHERE chain_id = ?;
SELECT * FROM cpq_approval_record WHERE chain_id = ? ORDER BY step_number;

-- 手动通过一个审批
UPDATE cpq_approval_record SET action='APPROVED', action_time=NOW() WHERE chain_id=? AND action IS NULL;
UPDATE cpq_approval_chain SET status='COMPLETED', completed_time=NOW() WHERE chain_id=?;
UPDATE cpq_process_confirm SET confirm_status='CONFIRMED', confirm_time=NOW() WHERE approval_chain_id=?;
```
