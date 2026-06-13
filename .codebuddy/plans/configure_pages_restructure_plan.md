# CPQ Portal 配置管理功能改造方案

> 日期：2026-06-13
> 目标：移除 Admin Portal 中的配置报价占位页面，将标准配置/向导式配置/ATO定制配置迁移到 CPQ Portal 配置管理下，实现全部动态数据读取

---

## 一、现状评估

### 1.1 Admin Portal（ruoyi-ui）当前状态

`ruoyi-ui/src/views/configure/` 下有 4 个页面，全部是静态占位页（硬编码 Mock 数据，无后端 API 调用）：

| 文件 | 菜单名称 | 状态 |
|------|---------|------|
| `ProductSearch.vue` | 产品搜索 | 调用 `/cpq/catalog/list`（查的是产品目录表，不是产品表） |
| `Configurator.vue` | 新建标准配置 | 纯静态，models/configOptions 全部硬编码 |
| `GuidedSelling.vue` | 向导式配置 | 纯静态，productType/spec/估价硬编码 |
| `AtoCustomize.vue` | ATO定制配置 | 纯静态，platforms/accessories 硬编码 |

### 1.2 CPQ Portal（cpq-portal）当前状态

`cpq-portal/src/views/configure/` 有 2 个页面，均完整接入后端：

| 文件 | 菜单路径 | 功能 | 数据来源 |
|------|---------|------|---------|
| `ProductSearch.vue` | 产品配置器 | 搜索产品→选择→进入配置 | `/cpq/product/model/search` + configType 筛选 |
| `Configurator.vue` | 产品配置器（选择后） | 三栏 CSP 配置器：属性选择→约束传播→BOM预览→验证→定价 | `/cpq/configure/model/{id}`, `/cpq/configure/validate`, `/cpq/configure/complete`, `/cpq/engine/config/propagate` |

cpq-portal 还有一个 `useConfiguratorStore`（Pinia），已封装完整配置会话状态管理，包含 `initModel`, `selectOption`, `nextGuideStep`, `complete` 等方法。

### 1.3 后端引擎状态

| 引擎方法 | 实现状态 | 暴露端点 |
|---------|:------:|---------|
| `loadModel` | ✅ 完整 | `GET /cpq/configure/model/{modelId}` |
| `validate` | ✅ 完整 | `POST /cpq/configure/validate` |
| `propagateConstraints` (MAC-3) | ✅ 完整 | `POST /cpq/engine/config/propagate` |
| `guidedSelling` (5状态机+MRV) | ✅ 完整 | ⚠️ 仅 `POST /cpq/engine/config/guide`（测试端点） |
| `complete` (验证+BOM+定价) | ✅ 完整 | `POST /cpq/configure/complete` |

关键发现：`guidedSelling` 后端方法已完整实现（5状态机、MRV启发式、约束传播），但只暴露在 `ConfigEngineController` 测试控制器 (`/cpq/engine/config/guide`)，未在 `ConfiguratorController` (`/cpq/configure/`) 暴露。

### 1.4 三者与产品配置器的关系

设计文档明确：这三个功能共用同一后端引擎 `ruoyi-cpq-config`、同一套配置数据表、同一条数据流水线。区别仅在前端交互模式：

| 功能 | 与产品配置器的关系 | 使用方式 |
|------|------------------|---------|
| **新建标准配置** | 就是产品配置器本身 | ProductSearch（搜产品）→ Configurator（选属性→CSP验证→定价→完成） |
| **向导式配置** | 标准配置的引导式包装 | ProductSearch（搜产品）→ GuidedWizard（MRV启发式分步引导选择属性）→ Configurator（最终确认） |
| **ATO定制配置** | 标准配置 + 非结构化定制 | ProductSearch（搜产品，过滤ATO）→ Configurator（标准属性选择）+ 定制需求表单 |

---

## 二、改造方案

### 2.1 Phase 1：清理 Admin Portal（ruoyi-ui）

**操作：**

1. **删除占位页面文件**（4个文件）
   ```
   ruoyi-ui/src/views/configure/ProductSearch.vue    → 删除
   ruoyi-ui/src/views/configure/Configurator.vue     → 删除
   ruoyi-ui/src/views/configure/GuidedSelling.vue    → 删除
   ruoyi-ui/src/views/configure/AtoCustomize.vue     → 删除
   ```

2. **更新菜单 SQL** — `sql/cpq_menu.sql`
   删除以下 4 条菜单记录：
   ```sql
   -- 删除 (50021, '产品搜索'), (50022, '新建标准配置'), (50023, '向导式配置'), (50024, 'ATO定制配置')
   -- 同时删除父菜单 50020 '配置报价'（因为已无子菜单）
   ```

3. **清理 API 文件** — `ruoyi-ui/src/api/cpq/configure.ts`
   删除或注释掉（因为 Admin Portal 不再需要配置器 API）

4. **清理路由** — `ruoyi-ui/src/router/index.ts`
   如果路由是动态从后端获取，则无需操作；如果有静态路由引用，需同步删除。

**风险**：低。这 4 个页面是纯静态占位，删除不影响任何功能。Admin Portal 的产品管理相关页面（产品模型、产品目录、产品分类等 CRUD 管理页面）不受影响。

---

### 2.2 Phase 2：CPQ Portal 菜单扩展

**文件**：`cpq-portal/src/config/menu.ts`

在当前「配置管理」一级菜单下，新增 3 个二级菜单项：

```typescript
{
  label: '配置管理',
  icon: Setting,
  children: [
    { path: '/config',              label: '配置规则',     icon: Setting },
    { path: '/configure',           label: '产品配置器',   icon: MagicStick },   // 已有，不动
    { path: '/configure-standard',  label: '新建标准配置', icon: MagicStick },   // 新增，复用产品配置器流程
    { path: '/configure-guided',    label: '向导式配置',   icon: Compass },      // 新增
    { path: '/configure-ato',       label: 'ATO定制配置',  icon: SetUp },        // 新增
  ]
}
```

**注意**：
- `新建标准配置` 路径 `/configure-standard` 实际复用 ProductSearch 页面（同 `/configure`），两者指向同一组件。这是为了给用户两个入口，不增加额外维护成本。
- 需要新增 `Compass` 和 `SetUp` 图标导入（从 `@element-plus/icons-vue`）

---

### 2.3 Phase 3：路由注册

**文件**：`cpq-portal/src/router/index.ts`

新增 3 条路由（全部在 `children` 中，复用现有 PortalLayout 布局）：

```typescript
// 新建标准配置（复用 ProductSearch 组件）
{
  path: 'configure-standard',
  component: () => import('@/views/configure/ProductSearch.vue'),
  meta: { title: '新建标准配置' }
},
// 向导式配置
{
  path: 'configure-guided',
  name: 'GuidedSelling',
  component: () => import('@/views/configure/GuidedSelling.vue'),
  meta: { title: '向导式配置' }
},
{
  path: 'configure-guided/:modelId',
  name: 'GuidedConfigurator',
  component: () => import('@/views/configure/GuidedSelling.vue'),
  meta: { title: '向导配置产品' }
},
// ATO定制配置
{
  path: 'configure-ato',
  name: 'AtoCustomize',
  component: () => import('@/views/configure/AtoCustomize.vue'),
  meta: { title: 'ATO定制配置' }
},
```

**不做**：不动已有的 `/configure` 和 `/configure/:modelId` 路由。

---

### 2.4 Phase 4：向导式配置页面（新建）

**文件**：`cpq-portal/src/views/configure/GuidedSelling.vue`（新建）

**设计依据**：设计文档 §8.2 + §3.3 五阶段状态机

**页面结构**：
```
┌─ 顶部 ───────────────────────────────────────────────────┐
│ 产品信息 + 5阶段进度指示器（雷达图/步骤条）                  │
├─ 主要内容区 ──────────────────────────────────────────────┤
│ Step 1 Questioning: 当前问题 + 选项卡片 + 已选摘要          │
│ Step 2 Narrowing: 过滤中产品列表 + 剩余匹配数               │
│ Step 3 Recommending: 推荐配置卡片（匹配度+推荐理由）        │
│ Step 4 Configuring: 嵌入简化版配置器（复用 store）          │
│ Step 5 Completed: 配置摘要 + [生成报价] / [继续选购]        │
│                                                           │
│ [上一步] [下一步] [跳过] [完成]                            │
└───────────────────────────────────────────────────────────┘
```

**数据来源**（全部动态）：

| 数据 | API | 表 |
|------|-----|-----|
| 产品模型 | `GET /cpq/configure/model/{modelId}` | `cpq_product_model` + `cpq_attribute_option` |
| 向导步骤 | `POST /cpq/engine/config/guide?modelId=` (调用 `guidedSelling`) | `cpq_config_rule` + `cpq_attribute_option` |
| 约束传播 | `POST /cpq/engine/config/propagate?modelId=` | `cpq_config_rule` |
| 完成配置 | `POST /cpq/configure/complete?modelId=` | 验证+BOM+定价流水线 |

**关键实现点**：
- 复用 `useConfiguratorStore` 的 `initModel` 加载产品 → `nextGuideStep` 获取向导步骤
- 5 阶段状态机在 `GuidedSelling.vue` 本地管理，`GuideState` 类型已定义（`QUESTIONING/NARROWING/RECOMMENDING/CONFIGURING/COMPLETED`）
- 每步选择自动保存到 store，支持回退
- Step 4 Configuring 复用 Configurator 组件或嵌入简化版属性选择器

**使用流程**：
```
用户点击「向导式配置」→ ProductSearch 搜产品（同标准配置入口）
→ 选择产品 → /configure-guided/:modelId → GuidedSelling 向导页面
→ 5步向导完成 → 可跳转标准 Configurator 最终确认 → 生成报价
```

**对接产品配置器**：引导完成后，`[完成配置]` 按钮调用 `store.complete()`，与产品配置器共用同一条完成流水线。选中的属性和 BOM 数据通过 `useConfiguratorStore` 共享。

---

### 2.5 Phase 5：ATO 定制配置页面（新建）

**文件**：`cpq-portal/src/views/configure/AtoCustomize.vue`（新建）

**设计依据**：设计文档 §CFG-006（ATO参数化配置）+ §1.4 场景2（ATO定制配置全流程）

**页面结构**：
```
┌─ 顶部 ─────────────────────────────────────────────┐
│ ATO定制配置                              [提交评审]   │
├─ 左侧：产品搜索（仅显示 configType=ATO） ────────────┤
├─ 中栏：标准属性配置区 ──────────────────────────────┤
│    （复用 Configurator 属性选择逻辑）                 │
│    属性分组导航 + 选项卡片 + 约束反馈                 │
├─ 右侧：定制需求面板 ────────────────────────────────┤
│    基础平台: [el-select 搜索產品]                     │
│    标准选配: 由标准配置器自动填充                       │
│    定制需求: [textarea 非结构化文本]                  │
│    期望数量: [el-input-number]                      │
│    期望交期: [el-date-picker]                       │
│    附件上传: [el-upload]                            │
│    BOM预览 / 预估价格                                │
└────────────────────────────────────────────────────┘
```

**数据来源**（全部动态）：

| 数据 | API | 表 |
|------|-----|-----|
| ATO产品列表 | `GET /cpq/product/model/search?configType=ATO` | `cpq_product_model` |
| 基础平台属性 | `GET /cpq/configure/model/{modelId}` | `cpq_product_model` + `cpq_attribute_option` |
| 可选配件 | `GET /cpq/configure/model/{modelId}` → `attributes` 字段 | `cpq_attribute_option`（所有属性及其选项） |
| 约束验证 | `POST /cpq/configure/validate` | `cpq_config_rule` |
| 价格估算 | `POST /cpq/configure/complete` | 定价引擎 |

**关键实现点**：
- 产品搜索自动过滤 `configType=ATO`
- 标准配置部分**直接复用** Configurator 的三栏选择逻辑（共享 `useConfiguratorStore`）
- 定制需求提交调用标准 `complete` 接口，额外附带 `customRequirements` 字段
- 后端的 `complete` 接口目前**没有**处理定制需求字段，**需要后端扩展**

**后端需扩展**（可选，P1优先级）：
- `ConfigCompleteRequest` 增加 `customRequirements: String` 字段
- `complete` 方法中 ATO 类型时，将定制需求存入 `cpq_quote_custom` 或类似表

**如暂不扩展后端**：定制需求暂存前端，页面提示"将随配置提交至售前评审"。

---

### 2.6 Phase 6：后端补齐

**操作 1**：在 `ConfiguratorController` 暴露 `guidedSelling` 端点

```java
// ConfiguratorController.java 新增方法
@PostMapping("/guide")
public R<GuideStep> guide(@RequestParam Long modelId, @RequestBody Map<String, String> selections) {
    GuideStep step = configEngineService.guidedSelling(modelId, selections);
    return R.ok(step);
}
```

前端 API (`cpq-portal/src/api/configure.ts`) 增加：
```typescript
export function getGuideStep(modelId: string, selections: Record<string, string>) {
  return request.post<GuideStep>('/cpq/configure/guide', selections, { params: { modelId } })
}
```

这样前端无需区分测试端点和生产端点，统一用 `/cpq/configure/guide`。

---

## 三、功能完整性与设计文档对照

| 设计规格 | 当前实现 | 差距 | 本方案补全 |
|---------|:------:|------|:---------:|
| **标准配置** (§8.1) 三栏布局 + CSP传播 + BOM预览 + ATP | ✅ Configurator.vue 已完整实现 | 无 | 不动 |
| **向导式配置** (§8.2) 5阶段状态机 + 雷达图指示器 + 推荐卡片 | ❌ 仅后端有 guidedSelling，前端无页面 | 前端 GuidedSelling.vue 全新开发 | ✅ Phase 4 |
| **ATO定制** (§CFG-006) 平台选择 + 标准配置 + 非结构化定制 | ❌ 无任何实现 | 前端 AtoCustomize.vue + 后端定制字段扩展 | ✅ Phase 5 |
| **向导端点** `/cpq/configure/guide` | ❌ 仅在 `engine/config/guide` | 需在 ConfiguratorController 暴露 | ✅ Phase 6 |
| **导游步骤持久化**每个向导步骤自动保存 | ❌ getGuideStep 调用后需保存 | 依赖 Pinia Store | ✅ 复用 useConfiguratorStore |
| **状态覆盖**(loading/empty/error) | ⚠️ 仅 Configurator 有基本错误处理 | 需补全骨架屏/空状态/错误边界 | P1 后续优化 |

---

## 四、实施步骤

### Step 1：清理 Admin Portal（1 人时）
- 删除 4 个占位 Vue 文件
- 删除 ruoyi-ui/src/api/cpq/configure.ts 或保留但注释
- 更新 `sql/cpq_menu.sql` 删除 50020-50024 菜单记录
- 验证 Admin Portal 编译无报错

### Step 2：CPQ Portal 菜单 + 路由（0.5 人时）
- 更新 `cpq-portal/src/config/menu.ts` 配置管理下增加 3 个菜单项
- 更新 `cpq-portal/src/router/index.ts` 增加 3 条路由

### Step 3：后端补充 guide 端点（0.5 人时）
- `ConfiguratorController` 加 `/guide` 方法
- cpq-portal `api/configure.ts` 加 `getGuideStep`（已有函数定义但改用新端点）

### Step 4：开发向导式配置页面（2 人时）
- 新建 `cpq-portal/src/views/configure/GuidedSelling.vue`
- 复用 `useConfiguratorStore`
- 实现 5 阶段状态机 UI

### Step 5：开发 ATO 定制配置页面（2 人时）
- 新建 `cpq-portal/src/views/configure/AtoCustomize.vue`
- ATO 产品搜索（configType=ATO 过滤）
- 标准配置区复用 Configurator 逻辑
- 定制需求面板

### 总计：约 6 人时

---

## 五、不做的事情

- **不动 cpq-portal 现有的 ProductSearch.vue 和 Configurator.vue**（用户明确要求）
- **不修改 useConfiguratorStore 核心逻辑**（已完整封装）
- **不修改后端 CSP 引擎**（ConfigEngineService 已完整）
- **不创建新的 Pinia Store**（复用现有 useConfiguratorStore）
- **不开发 Admin Portal 配置数据管理页面**（`cpq_attribute_option`/`cpq_config_rule` CRUD 管理，这是另一个独立任务）
