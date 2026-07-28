# CPQ 工艺审批流程 — Warm-Flow 接入方案

> 版本：v1.0 | 日期：2026-07-27 | 设计：基于代码分析

---

## 1. 背景与目标

### 1.1 当前状态

**Agent 侧（不改动）：**
- 用户选产品 → `select_product(rank)` → `submit_feasibility_confirm(CONFIRM)` → POST `/cpq/process/confirm`
- 查询状态：`check_process_status(resultId)` → GET `/cpq/process/status/byRecord/{id}`
- 工艺替换：`confirm_replacement(accept=True)` → POST `/cpq/process/confirm` (CONFIRM_REPLACEMENT)

**后端现状（需改造）：**
- `CpqProcessConfirmController.createApprovalChain()` 直接写入 `cpq_approval_chain` + `cpq_approval_record` 表
- 审批人硬编码为 `admin`（user_id=1），无实际审批路由
- `/pending` `/processed` `/approve` 接口直接操作 CPQ 自建表
- **未接入 Warm-Flow 引擎**，无法利用框架的流程设计器和任务管理

### 1.2 目标

- 工艺确认流程接入 Warm-Flow 引擎，支持**拖拽设计流程**
- 审批任务出现在 Admin UI **「我的待办」**中，审批人可操作通过/驳回
- **Agent 代码零改动**——所有 API 接口签名保持不变
- 不改动数据库表结构，仅修改 `CpqProcessConfirmController` 的实现

---

## 2. 架构设计

### 2.1 表职责重新划分

```
┌────────────────────────────────────────────────────────────┐
│                     Warm-Flow 引擎层                        │
│  flow_definition → flow_instance → flow_task → flow_his    │
│  (流程设计)       (流程实例)      (待办任务)    (已办历史)    │
│                                                             │
│  审批人通过 Warm-Flow 设计器的 "办理人" 配置灵活指定          │
│  支持：用户 / 角色 / 部门 / 岗位 / SPEL表达式               │
└──────────────────────────┬─────────────────────────────────┘
                           │ chainId=instanceId
┌──────────────────────────▼─────────────────────────────────┐
│                    CPQ 业务桥接层                            │
│                                                             │
│  cpq_process_confirm ← 工艺确认单                           │
│  ├─ result_id        → 关联匹配结果                         │
│  ├─ model_id         → 选定产品                             │
│  ├─ requirement_text → 客户需求描述                         │
│  ├─ approval_chain_id→ ★ 指向 flow_instance.id             │
│  └─ confirm_status   → PENDING / CONFIRMED / REJECTED      │
│                                                             │
│  cpq_match_result    → 匹配评分结果（已有，不改）             │
└────────────────────────────────────────────────────────────┘
                           │
┌──────────────────────────▼─────────────────────────────────┐
│              CPQ 审批规则配置层（后续前端开发）                │
│                                                             │
│  cpq_approval_rule   → 什么条件触发什么流程                  │
│  cpq_approval_matrix → 什么维度用哪个审批人                  │
│                                                             │
│  ★ 当前 POC 阶段：触发条件固定为"工艺确认"，审批人从         │
│    Warm-Flow 流程定义中配置                                  │
└────────────────────────────────────────────────────────────┘
```

### 2.2 废弃表

| 表 | 原因 |
|------|------|
| `cpq_approval_chain` | 被 `flow_instance` 替代 |
| `cpq_approval_record` | 被 `flow_task` + `flow_his_task` 替代 |

> 保留表结构不删，避免影响已有数据。新代码不再写入这两张表。

---

## 3. Warm-Flow 流程定义设计

### 3.1 流程基本信息

| 字段 | 值 | 说明 |
|------|-----|------|
| 流程编码 | `CPQ_PROCESS_CONFIRM` | 唯一标识，代码中引用 |
| 流程名称 | 工艺可行性确认审批 | Admin UI 显示 |
| 流程分类 | CPQ审批 (category_id=2) | 已插入的分类 |
| 设计器模型 | CLASSICS（经典模型） | 支持拖拽 |

### 3.2 流程节点设计

```
┌─────────┐     ┌──────────────────┐     ┌─────────┐
│  开始    │────→│   工艺审核         │────→│  结束    │
│ (开始节点)│     │ (用户任务节点)      │     │ (结束节点)│
└─────────┘     │                   │     └─────────┘
                │ 办理人: 角色/用户   │
                │ 表单: 工艺确认详情   │
                │ 可操作: 通过/驳回   │
                └──────────────────┘
```

### 3.3 节点详细配置

**用户任务节点 — "工艺审核"：**

| 配置项 | 值 | 说明 |
|------|-----|------|
| 节点名称 | 工艺审核 | |
| 办理人类型 | 角色 | 可通过设计器切换为用户/部门/SPEL |
| 办理人 | `工艺工程师`（建议创建该角色） | POC 阶段可先用 `admin` |
| 表单类型 | 自定义表单 | |
| 表单路径 | `/cpq/process/detail/{chainId}` | 复用已有审批详情接口 |
| 权限标识 | `cpq:process:approve` | |
| 可驳回 | 是 | |

### 3.4 操作步骤（管理员在 Admin UI 中操作）

1. 登录 `http://localhost:2999`，进入 **工作流 → 流程定义**
2. 点击 **新增**，填写流程编码 `CPQ_PROCESS_CONFIRM`，名称 `工艺可行性确认审批`
3. 选择分类 `CPQ审批`，点击 **流程设计**
4. 在拖拽设计器中：
   - 从左侧拖入「用户任务」节点
   - 节点名称设为「工艺审核」
   - 点击节点 → **办理人设置** → 选择 **角色** → 搜索并添加审批角色
   - 连接：开始 → 工艺审核 → 结束
5. 保存 → **发布**

---

## 4. 后端改造方案

### 4.1 改造 `CpqProcessConfirmController`

#### 4.1.1 注入 Warm-Flow 服务

```java
// 新增依赖注入
private final DefService defService;        // 流程定义服务
private final TaskService taskService;      // 任务服务
private final InsService insService;        // 实例服务
```

#### 4.1.2 改造 `createApprovalChain()` → `startWorkflow()`

```java
// ★ 旧代码：直接写 cpq_approval_chain + cpq_approval_record
// ★ 新代码：调用 Warm-Flow 启动流程实例

private Map<String, Long> startWorkflow(Long resultId, Long modelId) {
    // 1. 查找已发布的工艺确认流程定义
    FlowDefinition def = defService.getOne(new LambdaQueryWrapper<FlowDefinition>()
        .eq(FlowDefinition::getFlowCode, "CPQ_PROCESS_CONFIRM")
        .eq(FlowDefinition::getIsPublish, 1)
        .orderByDesc(FlowDefinition::getVersion)
        .last("LIMIT 1"));

    if (def == null) {
        throw new ServiceException("工艺确认审批流程未发布，请在 Admin UI 中发布后再试");
    }

    // 2. 构建启动参数
    Map<String, Object> variables = Map.of(
        "resultId", resultId.toString(),
        "modelId", modelId.toString(),
        "businessType", "PROCESS_CONFIRM"
    );

    // 3. 启动流程实例
    Instance instance = insService.start(def.getId(), variables);

    return Map.of(
        "chainId", instance.getId(),       // flow_instance.id → 复用为 chainId
        "recordId", instance.getId()       // 兼容 Agent 接口
    );
}
```

#### 4.1.3 改造审批动作 `/approve`

```java
@PostMapping("/approve")
public R<Map<String, String>> approve(@RequestBody Map<String, Object> body) {
    Long taskId = toLong(body.get("taskId"));  // ★ 改为 flow_task.id
    String action = (String) body.getOrDefault("action", "APPROVED");
    String comment = (String) body.getOrDefault("comment", "");

    if (taskId == null) return R.fail("taskId不能为空");

    // ★ 调用 Warm-Flow 完成任务
    CompleteTaskBo completeBo = new CompleteTaskBo();
    completeBo.setTaskId(taskId);
    completeBo.setMessage(comment);
    completeBo.setVariables(Map.of("approvalResult", action));

    taskService.completeTask(completeBo);

    return R.ok(Map.of("status", "APPROVED".equals(action) ? "COMPLETED" : "REJECTED",
        "message", "APPROVED".equals(action) ? "✅ 已通过" : "已驳回"));
}
```

#### 4.1.4 改造状态查询 `/status/{resultId}`

```java
@GetMapping("/status/{resultId}")
public R<Map<String, Object>> status(@PathVariable Long resultId) {
    // 1. 查 CPQ 确认单
    var rows = jdbc.queryForList(
        "SELECT pc.*, m.model_code, m.model_name " +
        "FROM cpq_process_confirm pc " +
        "LEFT JOIN cpq_product_model m ON pc.model_id=m.model_id " +
        "WHERE pc.tenant_id='000000' AND pc.result_id=? AND pc.del_flag='0' " +
        "ORDER BY pc.create_time DESC LIMIT 1", resultId);
    if (rows.isEmpty()) return R.ok(Map.of("status", "NOT_FOUND"));

    Map<String, Object> row = rows.get(0);
    Long chainId = (Long) row.get("approval_chain_id");

    // 2. 从 Warm-Flow 查实际状态
    String status = (String) row.get("confirm_status");
    if (chainId != null) {
        Instance instance = insService.getById(chainId);
        if (instance != null) {
            // 映射 Warm-Flow 状态到 CPQ 状态
            status = switch (instance.getFlowStatus()) {
                case "1" -> "PENDING";      // 审批中
                case "2" -> "CONFIRMED";    // 审批通过
                case "4" -> "REJECTED";     // 终止（驳回）
                case "5" -> "REJECTED";     // 作废
                default -> status;
            };
        }
    }

    // ... 其余字段不变
}
```

### 4.2 审批表单页面（新增）

后端已提供 `/cpq/process/detail/{chainId}` 接口，返回工艺确认详情（客户需求 + 匹配结果 + 选定产品 + 替代产品）。

审批人在「我的待办」中点击「办理」时，Warm-Flow 根据流程定义中的 `formPath` 加载审批表单。需新建一个简单的前端页面：

**文件**：`ruoyi-ui/src/views/workflow/form/ProcessConfirmForm.vue`

```
┌──────────────────────────────────────────┐
│  工艺可行性确认审批                        │
├──────────────────────────────────────────┤
│  客户需求                                 │
│  ┌──────────────────────────────────┐    │
│  │ 用途：GPS追踪器                    │    │
│  │ 温度：-40℃ ~ 85℃                 │    │
│  │ 防护等级：IP67                    │    │
│  │ ...                              │    │
│  └──────────────────────────────────┘    │
│                                          │
│  选定产品                                 │
│  ┌──────────────────────────────────┐    │
│  │ ER14505-BP-002                   │    │
│  │ 锂亚电池 AA 尺寸 2700mAh          │    │
│  │ 基准报价：¥15.00                  │    │
│  └──────────────────────────────────┘    │
│                                          │
│  匹配评分：85分 (Top 1)                   │
│                                          │
│  审批意见：                               │
│  ┌──────────────────────────────────┐    │
│  │                                  │    │
│  └──────────────────────────────────┘    │
│                                          │
│  [驳回]  [通过]                           │
└──────────────────────────────────────────┘
```

### 4.3 审批通过后回调 CPQ

Warm-Flow 的 `FlowProcessEventHandler` 监听流程完成事件：

```java
// 在 ruoyi-workflow 模块中新增监听
@Component
public class ProcessConfirmListener {
    
    @EventListener
    public void onProcessComplete(FlowCompletedEvent event) {
        Instance instance = event.getInstance();
        FlowDefinition def = defService.getById(instance.getDefinitionId());
        
        // 只处理工艺确认流程
        if (!"CPQ_PROCESS_CONFIRM".equals(def.getFlowCode())) {
            return;
        }
        
        // 更新 cpq_process_confirm 状态
        String status = "2".equals(instance.getFlowStatus()) ? "CONFIRMED" : "REJECTED";
        jdbc.update(
            "UPDATE cpq_process_confirm SET confirm_status=?, confirm_time=NOW() " +
            "WHERE approval_chain_id=?",
            status, instance.getId());
    }
}
```

---

## 5. Agent 兼容性确认

### 5.1 接口不变

| Agent 调用 | 请求 | 响应字段 | 兼容性 |
|------|------|------|:--:|
| `submit_feasibility_confirm` | POST `/cpq/process/confirm` | confirmId, chainId, recordId, status, modelCode, modelName | ✅ 不变 |
| `check_process_status` | GET `/cpq/process/status/byRecord/{id}` | status, modelCode, modelName, recordId | ✅ 不变 |
| `confirm_replacement` | POST `/cpq/process/confirm` (CONFIRM_REPLACEMENT) | status | ✅ 不变 |

### 5.2 行为变化（对 Agent 透明）

| 变化点 | 旧行为 | 新行为 |
|------|------|------|
| status=PENDING | 伪状态，无人审批 | Warm-Flow 任务等待审批人处理 |
| status=CONFIRMED | 直接通过（admin 即审批人） | 审批人在 Admin UI 中操作通过后 |
| 审批人 | 固定 admin | 由流程定义中的办理人配置决定 |

---

## 6. 实施步骤

| 步骤 | 内容 | 预估工时 |
|:--:|------|:--:|
| 1 | 在 Admin UI 流程设计器中创建并发布 `CPQ_PROCESS_CONFIRM` 流程 | 0.5h |
| 2 | 改造 `CpqProcessConfirmController`：启动流程 → 调用 Warm-Flow | 2h |
| 3 | 改造审批接口：`/approve` → 调用 Warm-Flow `completeTask` | 1h |
| 4 | 新增审批表单页 `ProcessConfirmForm.vue` | 3h |
| 5 | 新增流程完成监听器 `ProcessConfirmListener` | 1h |
| 6 | 联调：Agent 端到端工艺确认流程 | 2h |
| 7 | 清理：标记 `cpq_approval_chain` / `cpq_approval_record` 为废弃 | 0.5h |
| **合计** | | **10h** |

---

## 7. 后续扩展

完成本次接入后，后续可以：

1. **多级审批**：在流程设计器中拖入多个用户任务节点，形成串行/并行审批链
2. **审批规则配置页**：开发 `ApprovalRuleConfig.vue`（设计方案已完成），让业务方可视化配置触发条件
3. **审批矩阵**：按区域/金额维度动态指定审批人
4. **移动端审批**：Warm-Flow 已支持，直接可用

---

## 附录：相关文件索引

| 文件 | 说明 |
|------|------|
| `ruoyi-modules/ruoyi-cpq-match/.../CpqProcessConfirmController.java` | 工艺确认控制器（需改造） |
| `ruoyi-modules/ruoyi-workflow/.../FlwDefinitionController.java` | 流程定义 API |
| `ruoyi-modules/ruoyi-workflow/.../FlwTaskServiceImpl.java` | 任务服务（启动/完成流程） |
| `ruoyi-modules/ruoyi-workflow/.../FlwTaskAssigneeServiceImpl.java` | 办理人解析（用户/角色/部门/SPEL） |
| `ruoyi-ui/src/views/workflow/processDefinition/design.vue` | 流程设计器 iframe |
| `ruoyi-ui/src/views/workflow/task/taskWaiting.vue` | 我的待办页面 |
| `backend/tools.py` | Agent 工具（不改） |
| `backend/agent.py` | Agent 提示词（不改） |
