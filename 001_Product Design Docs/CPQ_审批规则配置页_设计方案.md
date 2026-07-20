# CPQ 审批规则配置页 — 完整设计方案

> 版本：v1.0 | 日期：2026-07-16 | 作者：码农

---

## 1. 概述

### 1.1 背景

当前系统已具备完整后端审批能力（`ruoyi-cpq-approval` 模块），但缺少**管理员可视化管理审批规则和审批链**的前端页面。目前只能在数据库中手写 JSON 配置审批链，对业务运维不可用。

### 1.2 目标

构建 `ApprovalRuleConfig.vue`，让管理员能够：
- 可视化查看、新建、编辑、启用/停用审批规则
- 拖拽式编排多级审批链（串行/并行）
- 维护审批矩阵（维度 × 审批人映射）
- 实时预览审批链流转效果

### 1.3 关联模块

| 模块 | 路径 | 状态 |
|------|------|:--:|
| 后端审批模块 | `ruoyi-modules/ruoyi-cpq-approval/` | ✅ |
| 前端 API 层 | `cpq-portal/src/api/approval.ts` | ✅ |
| 前端审批历史页 | `views/approval/ApprovalHistory.vue` | ✅ |
| **前端规则配置页** | **`views/approval/ApprovalRuleConfig.vue`** | ❌ 待开发 |

---

## 2. 路由与菜单

### 2.1 路由设计

```typescript
// router/modules/approval-management.ts
{
  path: '/approval-management',
  component: Layout,
  redirect: '/approval-management/pending',
  name: 'ApprovalManagement',
  meta: { title: '审批管理', icon: 'check', permission: 'cpq:approval:manage' },
  children: [
    {
      path: 'rules',
      name: 'ApprovalRuleConfig',
      component: () => import('@/views/approval/ApprovalRuleConfig.vue'),
      meta: { title: '审批规则配置', permission: 'cpq:approval:rule:config' }
    },
    {
      path: 'matrix',
      name: 'ApprovalMatrixConfig',
      component: () => import('@/views/approval/ApprovalMatrixConfig.vue'),
      meta: { title: '审批矩阵', permission: 'cpq:approval:matrix:config' }
    }
  ]
}
```

### 2.2 菜单层级

```
审批管理
├── 待我审批          (已有)
├── 我已审批          (已有)
├── 我发起的          (已有)
├── 效率看板          (已有)
├── 审批规则配置      (新增)  ← 本方案
└── 审批矩阵          (新增)  ← 附件
```

### 2.3 权限码

| 权限码 | 说明 |
|--------|------|
| `cpq:approval:manage` | 审批管理模块入口 |
| `cpq:approval:rule:config` | 审批规则的新增/编辑/删除 |
| `cpq:approval:matrix:config` | 审批矩阵的配置 |

---

## 3. 页面布局

### 3.1 整体布局（三区）

```
┌─────────────────────────────────────────────────────────────────────┐
│ 审批规则配置                                          [+ 新建规则]   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ 规则名称      │ 触发条件        │ 审批步骤 │ 优先级 │ 状态  │操作│   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │ 大额折扣审批   │ DISCOUNT_EXCEED  │  3步串行  │  P1    │ 启用  │···│   │
│  │ 低利润审批     │ MARGIN_BELOW    │  2步串行  │  P2    │ 启用  │···│   │
│  │ 新客户首单     │ FIRST_ORDER     │  2步并行  │  P3    │ 停用  │···│   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  < 1 2 3 > 共 12 条                                                 │
│                                                                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─ 规则详情 / 编辑 ────────────────────────────────────────────┐  │
│  │                                                                │  │
│  │  规则名称: [大额折扣审批                  ]                    │  │
│  │  触发条件: [DISCOUNT_EXCEED ▼]  阈值: [15.00 ] %              │  │
│  │  优先级:   [P1 ▼]              SLA超时: [48    ] 小时         │  │
│  │  状态:     ● 启用  ○ 停用                                     │  │
│  │                                                                │  │
│  │  ┌─ 审批链编排 ───────────────────────────────────────────┐  │  │
│  │  │                                                        │  │  │
│  │  │  [步骤1: 销售经理]  ──→  [步骤2: 区域总监]  ──→  [步骤3]│  │  │
│  │  │   类型: ●串行 ○并行       串行          类型: ●串行 ○并行│  │  │
│  │  │   审批人: 张三(销售经理)   审批人: 李四(区域总监)        │  │  │
│  │  │   备选人: 王五             备选人: 赵六                  │  │  │
│  │  │              [+ 添加步骤]                                │  │  │
│  │  │                                                        │  │  │
│  │  │  ┌────────────────────────────────────────────────────┐│  │  │
│  │  │  │ 步骤3:                                           ││  │  │
│  │  │  │ ┌──────────┐  ┌──────────┐  ┌──────────┐        ││  │  │
│  │  │  │ │ 财务总监  │  │ 法务总监  │  │  VP审批   │        ││  │  │
│  │  │  │ │ 刘副总    │  │ 陈总监    │  │ 钱总      │        ││  │  │
│  │  │  │ └──────────┘  └──────────┘  └──────────┘        ││  │  │
│  │  │  │         类型: 并行 (需全部通过)                   ││  │  │
│  │  │  └────────────────────────────────────────────────────┘│  │  │
│  │  └────────────────────────────────────────────────────────┘  │  │
│  │                                                                │  │
│  │  [取消] [保存草稿] [保存并启用]                                  │  │
│  └────────────────────────────────────────────────────────────────┘  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 3.2 操作列下拉菜单

```
[···]
 ├── 编辑
 ├── 复制规则
 ├── 启用/停用
 └── 删除
```

---

## 4. 组件树

```
ApprovalRuleConfig.vue                    # 主页面（规则列表 + 规则编辑抽屉）
├── ApprovalRuleTable.vue                 # 规则列表表格（可内联在主页）
├── ApprovalRuleDrawer.vue                # 规则编辑抽屉（ElDrawer, 80%宽度）
│   ├── RuleBasicForm.vue                 # 基本信息表单
│   │   ├── ElInput (规则名称)
│   │   ├── ElSelect (触发条件, 8种)
│   │   ├── ElInputNumber (阈值)
│   │   ├── ElSelect (优先级 P1-P5)
│   │   ├── ElInputNumber (SLA超时小时)
│   │   └── ElSwitch (启用/停用)
│   └── ApprovalChainBuilder.vue          # ★ 审批链可视化编排器（核心）
│       ├── ChainStepCard.vue             # 单个审批步骤卡片
│       │   ├── ElInputNumber (步骤序号)
│       │   ├── ElRadioGroup (串行/并行)
│       │   ├── UserSelect.vue            # 用户/角色选择器（远程搜索）
│       │   ├── ElTag (已选审批人, 可删除)
│       │   └── ElButton (添加备选人)
│       ├── ChainConnector.vue            # 步骤间连接线（箭头 + "串行/并行"标签）
│       └── ElButton (添加步骤)
└── ApprovalMatrixConfig.vue              # 审批矩阵页（独立路由）
    ├── ElTable (矩阵列表)
    └── MatrixEditDialog.vue              # 矩阵编辑对话框
```

---

## 5. 数据模型

### 5.1 TypeScript 类型定义

```typescript
// types/approval.d.ts（新增文件）

/** 触发条件枚举 */
export type TriggerType =
  | 'DISCOUNT_EXCEED'    // 折扣超限
  | 'MARGIN_BELOW'       // 利润率过低
  | 'AMOUNT_ABOVE'       // 金额超限
  | 'NEW_CONFIG'         // 新配置
  | 'CROSS_REGION'       // 跨区域
  | 'CUSTOM_PART'        // 定制件
  | 'FIRST_ORDER'        // 新客户首单
  | 'EXPORT_CONTROL'     // 出口管制

/** 触发条件选项（中文标签） */
export const TRIGGER_TYPE_OPTIONS: { value: TriggerType; label: string; unit: string }[] = [
  { value: 'DISCOUNT_EXCEED',  label: '折扣超限',    unit: '%' },
  { value: 'MARGIN_BELOW',     label: '利润率过低',   unit: '%' },
  { value: 'AMOUNT_ABOVE',     label: '金额超限',     unit: '元' },
  { value: 'NEW_CONFIG',       label: '新配置方案',   unit: '' },
  { value: 'CROSS_REGION',     label: '跨区域报价',   unit: '' },
  { value: 'CUSTOM_PART',      label: '含定制件',     unit: '' },
  { value: 'FIRST_ORDER',      label: '新客户首单',   unit: '' },
  { value: 'EXPORT_CONTROL',   label: '出口管制产品', unit: '' },
]

/** 审批步骤节点 */
export interface ApprovalStep {
  step: number                    // 步骤序号（从1开始）
  approverRole: string           // 审批角色（如 "销售经理"）
  approverIds: number[]          // 指定审批人ID列表
  approverNames: string[]        // 审批人姓名列表（前端展示用）
  backupApproverIds: number[]    // 备选审批人ID
  backupApproverNames: string[]  // 备选审批人姓名
  type: 'SERIAL' | 'PARALLEL'   // 审批类型
  minApprovals?: number          // 并行时最少通过人数（默认全部）
}

/** 审批链 JSON（与后端 cpq_approval_rule.approval_chain_json 对应） */
export type ApprovalChainJson = ApprovalStep[]

/** 审批规则前端表单 */
export interface ApprovalRuleForm {
  ruleName: string
  triggerType: TriggerType
  triggerValue: number | null        // 无阈值条件（如FIRST_ORDER）为 null
  approvalChain: ApprovalStep[]
  priority: number                    // 1-5
  slaHours: number                    // 默认 48
  status: '0' | '1'                   // '0'=启用 '1'=停用
}

/** 审批规则列表行（与后端 ApprovalRuleVo 对应） */
export interface ApprovalRuleRow {
  ruleId: number
  ruleName: string
  triggerType: string
  triggerValue: number
  approvalChainJson: string          // JSON 字符串，前端 parse 后使用
  stepCount: number                   // 审批步骤数（前端计算）
  priority: number
  status: string
  createTime: string
}
```

### 5.2 后端 API（已有，无需新增）

```typescript
// 复用 api/approval.ts，无需新增接口
listApprovalRule(params)    // GET  /cpq/approval/rule/list
addApprovalRule(data)       // POST /cpq/approval/rule
updateApprovalRule(data)    // PUT  /cpq/approval/rule/{id}
delApprovalRule(id)         // DELETE /cpq/approval/rule/{id}

// 审批矩阵（已有）
listApprovalMatrix(params)   // GET  /cpq/approval/matrix/list
addApprovalMatrix(data)      // POST /cpq/approval/matrix
updateApprovalMatrix(data)   // PUT  /cpq/approval/matrix/{id}
delApprovalMatrix(id)        // DELETE /cpq/approval/matrix/{id}

// 用户/角色远程搜索（复用 RuoYi 系统接口）
// GET /system/user/list?userName=关键词&status=0
// GET /system/role/list?roleName=关键词&status=0
```

---

## 6. 核心交互流程

### 6.1 规则列表加载

```
页面进入
  → onMounted() 调用 listApprovalRule()
  → 解析每行的 approvalChainJson (JSON.parse)
  → 计算 stepCount = chain.length
  → 渲染表格
```

### 6.2 新建/编辑规则

```
点击 [+ 新建规则] 或 操作列[编辑]
  → 打开 ElDrawer (width: 80%)
  → 加载规则表单（编辑时回填数据）
  → 用户填写：
      1. 基本信息（规则名、触发条件、阈值、优先级、SLA）
      2. 编排审批链（见 6.3）
  → 点击 [保存并启用]
  → 前端校验：
      - 规则名称非空
      - 审批链至少 1 步
      - 每步至少选 1 个审批人
      - 并行步骤 minApprovals ≤ 审批人数
  → approvalChainJson = JSON.stringify(form.approvalChain)
  → 调 addApprovalRule() 或 updateApprovalRule()
  → 成功 → ElMessage.success → 关闭抽屉 → 刷新列表
  → 失败 → ElMessage.error(后端返回的 msg)
```

### 6.3 审批链编排 ★

**核心组件 `ApprovalChainBuilder.vue` 的实现逻辑：**

```
初始化：
  approvalChain: ApprovalStep[] = [{ step: 1, approverRole: '', approverIds: [], type: 'SERIAL' }]

添加步骤：
  push({ step: chain.length + 1, approverRole: '', approverIds: [], type: 'SERIAL' })

删除步骤：
  splice(index, 1) → 重新编号 step 字段

拖拽排序（使用 vuedraggable）：
  @change → 重新编号 step 字段

审批人选择（UserSelect 组件）：
  - 远程搜索：GET /system/user/list?userName=关键词
  - 支持多选
  - 选中后在步骤卡片内显示为 ElTag（可删除）

切换串行/并行：
  - 串行：步骤卡片纵向排列，箭头连接
  - 并行：步骤卡片横向排列，虚线框包裹，标注"需全部通过"或"至少 N 人通过"
```

### 6.4 审批人选择器 `UserSelect.vue`

```
模板：
  <el-select
    v-model="selectedUserIds"
    multiple
    filterable
    remote
    :remote-method="searchUsers"
    placeholder="搜索并选择审批人"
  >
    <el-option v-for="u in userOptions" :key="u.userId" :label="u.userName" :value="u.userId" />
  </el-select>

逻辑：
  - debounce 300ms 后调 GET /system/user/list?userName=关键词&status=0
  - 同时支持按角色筛选：GET /system/role/list → 选择角色后自动加载该角色下所有用户
  - 选中用户后同步 approverIds 和 approverNames
```

### 6.5 删除规则

```
点击 [删除]
  → ElMessageBox.confirm('确定删除该审批规则？')
  → 确认 → delApprovalRule(id)
  → 成功 → ElMessage.success → 刷新列表
  → 失败 → ElMessage.error('该规则已被报价单引用，无法删除')
```

---

## 7. 技术实现关键细节

### 7.1 文件清单

```
cpq-portal/src/
├── views/approval/
│   ├── ApprovalRuleConfig.vue          # 主页面（新增）
│   └── ApprovalMatrixConfig.vue        # 审批矩阵页（新增）
├── components/approval/
│   ├── ApprovalChainBuilder.vue        # 审批链编排器（新增）
│   ├── ChainStepCard.vue               # 步骤卡片（新增）
│   ├── ChainConnector.vue              # 步骤连接线（新增）
│   ├── UserSelect.vue                  # 审批人选择器（新增，可复用）
│   └── TriggerConditionBadge.vue       # 触发条件标签（新增）
├── api/
│   └── approval.ts                     # 已有，无需修改
├── router/
│   └── modules/
│       └── approval-management.ts      # 审批管理路由模块（新增）
├── types/
│   └── approval.d.ts                   # 审批类型定义（新增）
└── store/
    └── approval-config.ts              # 审批配置 store（新增，Pinia）
```

### 7.2 拖拽排序实现

审批链步骤拖拽使用 `vuedraggable`（需安装）：

```bash
npm install vuedraggable@next
```

```vue
<!-- ApprovalChainBuilder.vue 核心片段 -->
<template>
  <draggable v-model="chain" item-key="step" handle=".drag-handle" @change="onDragEnd">
    <template #item="{ element, index }">
      <ChainStepCard
        :step="element"
        :index="index"
        :is-last="index === chain.length - 1"
        @update="updateStep(index, $event)"
        @remove="removeStep(index)"
      />
      <ChainConnector
        v-if="index < chain.length - 1"
        :from-type="element.type"
        :to-type="chain[index + 1].type"
      />
    </template>
  </draggable>
  <el-button @click="addStep" type="primary" plain>+ 添加审批步骤</el-button>
</template>
```

### 7.3 审批链预览模式

编辑器中提供一个「预览」Toggle，切换后显示审批链流转动画：

```
┌─────────────────────────────────────────────┐
│  预览模式：报价单提交 → 审批流转             │
│                                             │
│  [提交人] ──→ [步骤1: 销售经理 ✓]           │
│                    ↓                        │
│              [步骤2: 区域总监 ⏳]            │
│                    ↓                        │
│         ┌─────────┼─────────┐              │
│         ↓         ↓         ↓              │
│      [财务]    [法务]     [VP]             │
│      (并行，需2人通过)                      │
│                    ↓                        │
│              [审批通过 ✓]                   │
└─────────────────────────────────────────────┘
```

使用 `ElSteps` + `ElTimeline` 组件实现，当前激活步骤用 `process-status="process"`。

### 7.4 表单校验规则

```typescript
const rules = {
  ruleName: [
    { required: true, message: '请输入规则名称', trigger: 'blur' },
    { max: 200, message: '规则名称不超过200个字符', trigger: 'blur' }
  ],
  triggerType: [
    { required: true, message: '请选择触发条件', trigger: 'change' }
  ],
  triggerValue: [
    {
      validator: (_rule: any, value: any, callback: any) => {
        // NEW_CONFIG / CROSS_REGION / CUSTOM_PART / FIRST_ORDER / EXPORT_CONTROL 不需要阈值
        const noThresholdTypes = ['NEW_CONFIG', 'CROSS_REGION', 'CUSTOM_PART', 'FIRST_ORDER', 'EXPORT_CONTROL']
        if (!noThresholdTypes.includes(form.triggerType) && (value === null || value === undefined)) {
          callback(new Error('请输入触发阈值'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ],
  approvalChain: [
    {
      validator: (_rule: any, value: ApprovalStep[], callback: any) => {
        if (!value || value.length === 0) {
          callback(new Error('至少需要配置一个审批步骤'))
        } else {
          for (const step of value) {
            if (!step.approverRole && step.approverIds.length === 0) {
              callback(new Error(`步骤${step.step}：请选择审批角色或指定审批人`))
              return
            }
          }
          callback()
        }
      },
      trigger: 'change'
    }
  ]
}
```

### 7.5 状态管理（Pinia Store）

```typescript
// store/approval-config.ts
import { defineStore } from 'pinia'
import { ref } from 'vue'
import { listApprovalRule, addApprovalRule, updateApprovalRule, delApprovalRule } from '@/api/approval'
import type { ApprovalRuleRow, ApprovalRuleForm } from '@/types/approval'

export const useApprovalConfigStore = defineStore('approval-config', () => {
  const rules = ref<ApprovalRuleRow[]>([])
  const loading = ref(false)
  const total = ref(0)

  async function fetchRules(params?: Record<string, unknown>) {
    loading.value = true
    try {
      const res = await listApprovalRule(params)
      rules.value = (res.rows || []).map((r: any) => ({
        ...r,
        stepCount: r.approvalChainJson ? JSON.parse(r.approvalChainJson).length : 0
      }))
      total.value = res.total || 0
    } finally {
      loading.value = false
    }
  }

  async function saveRule(form: ApprovalRuleForm, isEdit: boolean, ruleId?: number) {
    const payload = {
      ...form,
      approvalChainJson: JSON.stringify(form.approvalChain)
    }
    if (isEdit && ruleId) {
      await updateApprovalRule({ ruleId, ...payload })
    } else {
      await addApprovalRule(payload)
    }
  }

  async function removeRule(id: number) {
    await delApprovalRule(id)
  }

  return { rules, loading, total, fetchRules, saveRule, removeRule }
})
```

### 7.6 审批矩阵页（独立页面，附件设计）

```
┌─────────────────────────────────────────────────────────────────────┐
│ 审批矩阵                                                    [+ 新建] │
├─────────────────────────────────────────────────────────────────────┤
│ 维度类型    │ 维度值       │ 审批角色    │ 审批人     │ 最少通过 │操作│
├─────────────────────────────────────────────────────────────────────┤
│ REGION      │ 华东区       │ 区域总监    │ 李四,赵六  │   1     │···│
│ AMOUNT      │ >500万       │ VP审批     │ 钱总       │   1     │···│
│ DEPARTMENT  │ 海外事业部   │ 法务总监    │ 陈总监     │   1     │···│
└─────────────────────────────────────────────────────────────────────┘
```

审批矩阵与审批规则的区别：
- **审批规则**：按报价属性触发（折扣、利润率、金额…）
- **审批矩阵**：按组织维度路由（区域、部门、金额区间 → 指定审批人）

两者可以叠加使用：报价先匹配审批规则确定审批链模板，再通过审批矩阵补充/覆盖特定维度的审批人。

---

## 8. 开发计划

| 阶段 | 内容 | 预估工时 | 依赖 |
|:--:|------|:--:|------|
| 1 | 类型定义 + API 层补全 + 路由注册 | 0.5 天 | 无 |
| 2 | `UserSelect.vue` 审批人选择器 | 0.5 天 | RuoYi 用户/角色 API |
| 3 | `ChainStepCard.vue` + `ChainConnector.vue` | 1 天 | 阶段 2 |
| 4 | `ApprovalChainBuilder.vue` 审批链编排器 | 1.5 天 | 阶段 3、vuedraggable |
| 5 | `ApprovalRuleConfig.vue` 主页面 + Pinia Store | 1 天 | 阶段 4 |
| 6 | `ApprovalMatrixConfig.vue` 审批矩阵页 | 1 天 | 无 |
| 7 | 联调测试 + Playwright E2E | 1 天 | 全部 |
| **合计** | | **6.5 天** | |

---

## 9. 已有资源（无需重复开发）

以下资源已就绪，直接复用：

| 资源 | 位置 |
|------|------|
| 审批规则 CRUD API | `GET/POST/PUT/DELETE /cpq/approval/rule` |
| 审批矩阵 CRUD API | `GET/POST/PUT/DELETE /cpq/approval/matrix` |
| 审批链查询 API | `GET /cpq/approval/chain/list` |
| 审批记录 API | `GET /cpq/approval/record/list` |
| 前端 API 封装 | `cpq-portal/src/api/approval.ts` |
| 用户搜索 API | `GET /system/user/list`（RuoYi 标准接口） |
| 角色列表 API | `GET /system/role/list`（RuoYi 标准接口） |
| Element Plus 版本 | `element-plus@2.x`（el-table, el-form, el-drawer, el-steps, el-tag…） |
| 现有审批页面参考 | `views/approval/PendingApproval.vue` 等 6 个页面 |

---

## 附录 A：审批链 JSON 存储格式

```json
[
  {
    "step": 1,
    "approverRole": "销售经理",
    "approverIds": [1001, 1002],
    "approverNames": ["张三", "王五"],
    "backupApproverIds": [1003],
    "backupApproverNames": ["赵六"],
    "type": "SERIAL"
  },
  {
    "step": 2,
    "approverRole": "区域总监",
    "approverIds": [2001],
    "approverNames": ["李四"],
    "type": "SERIAL"
  },
  {
    "step": 3,
    "approverRole": "财务总监",
    "approverIds": [3001, 3002, 3003],
    "approverNames": ["刘副总", "陈总监", "钱总"],
    "type": "PARALLEL",
    "minApprovals": 2
  }
]
```

> 与后端 `cpq_approval_rule.approval_chain_json` 字段格式完全一致，前端 `JSON.stringify` / `JSON.parse` 即可。
