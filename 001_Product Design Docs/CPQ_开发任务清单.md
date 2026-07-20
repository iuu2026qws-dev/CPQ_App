# CPQ 项目开发任务清单

> 最后更新：2026-07-20 | 维护人：码农
>
> ⚠️ **本文档为 CPQ 项目唯一任务清单**。所有新增任务和进度更新均在此文档维护。
>
> 📋 2026-07-20 团队评审新增 8 项问题（CPQAPP-006 ~ CPQAPP-013），详见任务详情。

---

## 任务总览

| # | 任务ID | 任务 | 优先级 | 模块 | 状态 | 负责人 | 方案文档 |
|:--:|------|------|:--:|------|:--:|------|------|
| 1 | CPQAPP-002 | 审批规则配置页开发 | 🟡 P1 | CPQ_App | ⬜ 待开发 | — | [方案](CPQ_审批规则配置页_设计方案.md) |
| 2 | CPQAPP-003 | 审批矩阵配置页开发 | 🟢 P2 | CPQ_App | ⬜ 待开发 | — | 见上方 §7.6 |
| 3 | CPQAPP-004 | 配置规则 CSP 执行引擎开发 | 🔴 P0 | CPQ_App | ⬜ 待开发 | — | [方案](CPQ_CSP执行引擎_设计方案.md) |
| 4 | CPQAPP-005 | 定价规则引擎完善 | 🟡 P1 | CPQ_App | ⬜ 待开发 | — | [方案](CPQ_定价规则引擎完善_设计方案.md) |
| 5 | CPQAPP-006 | 配置审阅页→报价单生成打通 | 🔴 P0 | CPQ_App | ⬜ 待开发 | — | — |
| 6 | CPQAPP-007 | 配置结果快照自动保存 | 🟡 P1 | CPQ_App | ⬜ 待开发 | — | — |
| 7 | CPQAPP-008 | 报价单行项目带入配置属性+定制需求 | 🟡 P1 | CPQ_App | ⬜ 待开发 | — | — |
| 8 | CPQAPP-009 | BOM物料成本接入定价引擎 | 🟡 P1 | CPQ_App | ⬜ 待开发 | — | — |
| 9 | CPQAPP-010 | 报价单创建时带参数重算定价 | 🟢 P2 | CPQ_App | ⬜ 待开发 | — | — |
| 10 | CPQAPP-011 | 报价单行项目自动填充 | 🟡 P1 | CPQ_App | ⬜ 待开发 | — | — |
| 11 | CPQAPP-012 | 产品目录关键词搜索修复 | 🟢 P2 | CPQ_App | ⬜ 待开发 | — | — |
| 12 | CPQAPP-013 | MBOM覆盖写入改为会话级隔离 | 🟢 P2 | CPQ_App | ⬜ 待开发 | — | — |
| 13 | CPQAPP-014 | 新增报价单表单缺少客户搜索+数量输入 | 🟡 P1 | CPQ_App | ⬜ 待开发 | — | — |

---

## 任务详情

### 任务 1：审批规则配置页开发

| 字段 | 内容 |
|------|------|
| **任务ID** | CPQAPP-002 |
| **需求提出者** | 亿纬锂能客户 |
| **提出时间** | 2026-07-16 |
| **优先级** | 🟡 P1 |
| **模块/仓库** | CPQ_App |
| **当前状态** | ⬜ 待开发 |
| **测试状态** | ⬜ 未测试 |
| **发布状态** | ⬜ 未发布 |
| **发布时间** | — |
| **发布版本** | — |

**背景：**
系统具备完整后端审批能力（`ruoyi-cpq-approval` 模块），前端 API 层也已封装，但缺少管理页面。目前只能在数据库手写 JSON 配置审批链。

**需求：**
开发 `ApprovalRuleConfig.vue` 管理页面，支持：
- 审批规则 CRUD
- 可视化编排多级审批链（串行/并行 + 拖拽排序）
- 审批人远程搜索选择
- 审批矩阵维度管理（附件功能）

**方案简述：**
参见详细方案文档。

**详细方案文档：**
[CPQ_审批规则配置页_设计方案.md](CPQ_审批规则配置页_设计方案.md)

**开发计划（合计 6.5 天）：**

| 阶段 | 内容 | 工时 |
|:--:|------|:--:|
| 1 | 类型定义 + API 封装 + 路由注册 | 0.5 天 |
| 2 | `UserSelect` 审批人选择器 | 0.5 天 |
| 3 | `ChainStepCard` + `ChainConnector` 步骤组件 | 1 天 |
| 4 | `ApprovalChainBuilder` 审批链编排器（含 vuedraggable 拖拽） | 1.5 天 |
| 5 | `ApprovalRuleConfig` 主页面 + Pinia Store | 1 天 |
| 6 | `ApprovalMatrixConfig` 审批矩阵页 | 1 天 |
| 7 | 联调 + Playwright E2E | 1 天 |

**涉及文件（新增）：**
- `cpq-portal/src/views/approval/ApprovalRuleConfig.vue`
- `cpq-portal/src/views/approval/ApprovalMatrixConfig.vue`
- `cpq-portal/src/components/approval/ApprovalChainBuilder.vue`
- `cpq-portal/src/components/approval/ChainStepCard.vue`
- `cpq-portal/src/components/approval/ChainConnector.vue`
- `cpq-portal/src/components/approval/UserSelect.vue`
- `cpq-portal/src/components/approval/TriggerConditionBadge.vue`
- `cpq-portal/src/router/modules/approval-management.ts`
- `cpq-portal/src/types/approval.d.ts`
- `cpq-portal/src/store/approval-config.ts`

**已就绪资源（无需重复开发）：**
- 后端审批模块 `ruoyi-cpq-approval` ✅
- 前端 API 层 `api/approval.ts` ✅
- RuoYi 用户/角色 API ✅
- Element Plus 2.x ✅

---

### 任务 2：审批矩阵配置页开发

| 字段 | 内容 |
|------|------|
| **任务ID** | CPQAPP-003 |
| **需求提出者** | 亿纬锂能客户 |
| **提出时间** | 2026-07-16 |
| **优先级** | 🟢 P2 |
| **模块/仓库** | CPQ_App |
| **当前状态** | ⬜ 待开发 |
| **测试状态** | ⬜ 未测试 |
| **发布状态** | ⬜ 未发布 |
| **发布时间** | — |
| **发布版本** | — |

**背景：**
审批矩阵用于按组织维度（区域、部门、金额区间）映射审批人，与审批规则叠加使用。

**需求：**
开发审批矩阵 CRUD 管理页面，支持按维度类型 × 维度值 × 审批角色配置审批人映射。

**方案简述：**
表格列表 + 编辑对话框，字段包括：维度类型（REGION/AMOUNT/DEPARTMENT）、维度值、审批角色、审批人列表、最少通过人数。

**详细方案文档：**
合并在 [CPQ_审批规则配置页_设计方案.md](CPQ_审批规则配置页_设计方案.md) 第 7.6 节

**涉及文件：**
- `cpq-portal/src/views/approval/ApprovalMatrixConfig.vue`

**依赖：** 任务 1（审批规则配置页）完成后进行，复用 `UserSelect.vue` 组件

---

## 状态图例

| 符号 | 含义 |
|:--:|------|
| ⬜ | 待开发 |
| 🔄 | 开发中 |
| ✅ | 已完成 |
| 🐛 | 测试中/修复中 |
| 🚀 | 已发布 |
| ❌ | 已取消 |

---

### 任务 3：配置规则 CSP 执行引擎开发

| 字段 | 内容 |
|------|------|
| **任务ID** | CPQAPP-004 |
| **需求提出者** | 万维团队（内部排查发现） |
| **提出时间** | 2026-07-16 |
| **优先级** | 🔴 P0 |
| **模块/仓库** | CPQ_App |
| **当前状态** | ⬜ 待开发 |
| **测试状态** | ⬜ 未测试 |
| **发布状态** | ⬜ 未发布 |
| **发布时间** | — |
| **发布版本** | — |

**背景：**

`cpq_config_rule` 表已建好，`ConfigRuleManager.vue` 管理页面能正常 CRUD 规则数据。但 CSP 约束求解引擎从未实现——规则数据被存储后，从未在配置器（Configurator）中被读取、解析和执行。销售选属性时，互斥属性不会禁用、推荐值不会出现、无关属性不会隐藏。

**需求：**

实现完整的规则执行管线，使 `cpq_config_rule` 表中的规则在配置器中实时生效：
1. CSP 规则解析器：解析 conditionExpr JSON → 与用户当前 selections 比对
2. 动作执行器：按 actionExpr 计算冲突/警告/推荐/可见性
3. MAC-3 约束传播：增量更新，不重算全部规则
4. ConfiguratorController.validate() / propagate() 接入真实逻辑

**方案简述：**

参见详细方案文档。

**详细方案文档：** [CPQ_CSP执行引擎_设计方案.md](CPQ_CSP执行引擎_设计方案.md)

**已完成的部分（无需重复开发）：**
- 数据库表 `cpq_config_rule` ✅
- 后端 CRUD 接口 `CpqConfigRuleController` ✅
- 前端管理页面 `ConfigRuleManager.vue` ✅
- 前端配置器 `Configurator.vue`（UI 已准备好接收规则结果） ✅
- ConfiguratorController 接口签名（validate / propagate） ✅

**开发计划（合计 5 天）：**

| 阶段 | 内容 | 工时 |
|:--:|------|:--:|
| 1 | RuleLoader + ConditionEvaluator（JSON 解析 + 条件匹配） | 1.5 天 |
| 2 | ActionExecutor（四种规则类型的动作执行） | 1 天 |
| 3 | ConstraintPropagator（MAC-3 增量传播） | 1 天 |
| 4 | ConfiguratorController 接入 + 前后端联调 | 1 天 |
| 5 | 测试验证（Playwright E2E：配置规则 → 进入配置器 → 验证规则生效） | 0.5 天 |

**涉及文件：**
- `ruoyi-modules/ruoyi-cpq-config/src/main/java/.../service/RuleEngine.java`（新增）
- `ruoyi-modules/ruoyi-cpq-config/src/main/java/.../service/ConditionEvaluator.java`（新增）
- `ruoyi-modules/ruoyi-cpq-config/src/main/java/.../service/ActionExecutor.java`（新增）
- `ruoyi-modules/ruoyi-cpq-config/src/main/java/.../service/ConstraintPropagator.java`（新增）
- `ruoyi-modules/ruoyi-cpq-config/.../controller/ConfiguratorController.java`（改：替换桩代码）

---

### 任务 4：定价规则引擎完善

| 字段 | 内容 |
|------|------|
| **任务ID** | CPQAPP-005 |
| **需求提出者** | 万维团队（代码审查发现） |
| **提出时间** | 2026-07-16 |
| **优先级** | 🟡 P1 |
| **模块/仓库** | CPQ_App |
| **当前状态** | ⬜ 待开发 |
| **测试状态** | ⬜ 未测试 |
| **发布状态** | ⬜ 未发布 |
| **发布时间** | — |
| **发布版本** | — |

**背景（代码审查发现）：**

`PricingEngineService` 六阶段定价流水线已实现，`ConfiguratorController` 也在实际调用。但 `cpq_price_rule` 表中的规则接入度只有 5%：
- 定价引擎只在 Phase 5 查询了 `DISCOUNT_LIMIT` 一种规则类型
- `DISCOUNT` / `MARKUP` / `PROMOTION` / `CONTRACT` 四种规则写入数据库后，引擎完全忽略
- `conditionJson` 的解析用的是字符串替换（`replace("[{}\" ]", "").replace("maxDiscount:", "")`），不是标准 JSON 解析
- `actionJson` 字段从未被任何规则类型使用

**结论：** 定价规则管理页面（`PriceRuleConfig.vue`）能录入能存，但录入的数据大部分不生效。

**详细方案文档：** [CPQ_定价规则引擎完善_设计方案.md](CPQ_定价规则引擎完善_设计方案.md)

**需求：**

完善 `PricingEngineService`，使四种定价规则全部生效：
1. DISCOUNT 规则：根据 conditionJson（客户/区域/渠道/数量区间）匹配 → 执行 actionJson 中的折扣计算
2. MARKUP 规则：区域加价/渠道加价 → 在 Phase 3 多维定价阶段叠加
3. PROMOTION 规则：促销折扣/满减 → 在 Phase 4 阶梯定价之后叠加
4. CONTRACT 规则：合同协议价 → 作为最高优先级价格覆盖
5. 用 Gson/Jackson 标准 JSON 解析替换现有字符串替换逻辑
6. 规则优先级排序（priority 字段）+ 冲突策略（取最低价 / 取最高优先级）

**开发计划（合计 3 天）：**

| 阶段 | 内容 | 工时 |
|:--:|------|:--:|
| 1 | PriceRule 标准 JSON 解析器（ConditionParser + ActionParser） | 0.5 天 |
| 2 | DISCOUNT / MARKUP 规则接入 Phase 3 多维定价 | 0.5 天 |
| 3 | PROMOTION 规则接入 Phase 4 | 0.5 天 |
| 4 | CONTRACT 规则接入（最高优先级覆盖） | 0.5 天 |
| 5 | 规则优先级 + 冲突解决策略 | 0.5 天 |
| 6 | 前后端联调 + Playwright E2E | 0.5 天 |

**涉及文件：**
- `ruoyi-modules/ruoyi-cpq-pricing/src/main/java/.../service/ConditionParser.java`（新增）
- `ruoyi-modules/ruoyi-cpq-pricing/src/main/java/.../service/ActionParser.java`（新增）
- `ruoyi-modules/ruoyi-cpq-pricing/src/main/java/.../service/PriceRuleExecutor.java`（新增）
- `ruoyi-modules/ruoyi-cpq-pricing/.../service/PricingEngineService.java`（改：Phase 3/4/5 接入）
- `ruoyi-modules/ruoyi-cpq-pricing/.../controller/PricingEngineController.java`（改：测试用例更新）

**已就绪资源（无需重复开发）：**
- 数据库表 `cpq_price_rule` ✅
- 后端 CRUD 接口 `CpqPriceRuleController` ✅
- 前端管理页面 `PriceRuleConfig.vue` ✅
- `PricingEngineService` 六阶段框架 ✅

**风险：**
- 现有定价逻辑通过 `requestDiscount` 参数直接传入折扣，接入规则引擎后需要明确优先级：规则 > 手工折扣？规则仅做上限校验？
- 需要产品经理确认四种规则类型的详细业务语义（conditionJson / actionJson 的字段定义）

---

### 任务 5：配置审阅页→报价单生成打通

| 字段 | 内容 |
|------|------|
| **任务ID** | CPQAPP-006 |
| **需求提出者** | 万维团队（2026-07-20 产品评审） |
| **提出时间** | 2026-07-20 |
| **优先级** | 🔴 P0 |
| **模块/仓库** | CPQ_App |
| **当前状态** | ⬜ 待开发 |

**问题描述：**

配置完成后的审阅页展示了 MBOM + 定价结果，但**没有"生成报价单"按钮**。用户需手动导航到「报价管理 → 报价单管理」→ 点击「新增报价单」→ 选择客户 → 再手动逐行添加行项目。配置阶段的属性选择和定价结果完全丢失。

**需求：**
1. 配置审阅页增加"生成报价单"按钮
2. 点击时自动：
   - 调用 `POST /cpq/quote/header` 创建报价单头
   - 逐行调 `POST /cpq/quote/lineitem` 写入 MBOM 行项目，带 `configurationJson` 和 `unitPrice`
   - 调用 `POST /cpq/quote/snapshot` 保存配置快照
3. 报价单创建后跳转到报价单详情页

**涉及文件：**
- `cpq-portal/src/views/configure/Configurator.vue`（改：增加"生成报价单"按钮 + 触发逻辑）
- `cpq-portal/src/store/configurator.ts`（已有数据，需加 createQuote action）
- `cpq-portal/src/store/quote.ts`（已有 API，需加 createFromConfig 方法）

---

### 任务 6：配置结果快照自动保存

| 字段 | 内容 |
|------|------|
| **任务ID** | CPQAPP-007 |
| **需求提出者** | 万维团队（2026-07-20 产品评审） |
| **提出时间** | 2026-07-20 |
| **优先级** | 🟡 P1 |
| **模块/仓库** | CPQ_App |
| **当前状态** | ⬜ 待开发 |

**问题描述：**

`cpq_config_snapshot` 表和 `POST /cpq/quote/snapshot` API 已就绪，但从未被调用。配置完成后的属性选择和 BOM 结果仅在内存中，刷新页面即丢失。

**需求：**
1. 生成报价单时自动调用快照API保存 `selectionsJson` + `bomJson`
2. 报价单详情页通过快照列表回看历史配置
3. 快照关联 `quoteId`，支持版本对比

**依赖：** CPQAPP-006（配置→报价单打通）

---

### 任务 7：报价单行项目带入配置属性+定制需求

| 字段 | 内容 |
|------|------|
| **任务ID** | CPQAPP-008 |
| **需求提出者** | 万维团队（2026-07-20 产品评审） |
| **提出时间** | 2026-07-20 |
| **优先级** | 🟡 P1 |
| **模块/仓库** | CPQ_App |
| **当前状态** | ⬜ 待开发 |

**问题描述：**

报价单行项目 API（`POST /cpq/quote/lineitem`）支持 `configurationJson` 和 `customRequirements` 字段，但前端从不传入。导致：
- 报价单只显示物料编码（如 `MOD-HVI-4K-STD`），看不出选了什么属性（如"逆变器=15kW"）
- 定制需求（如"需-40°C低温版"）无处记录

**需求：**
1. 行项目写入时自动从 Pinia Store 带入 `selections` 作为 `configurationJson`
2. 报价单详情页行项目表格展示属性摘要（Tag标签形式）
3. 支持在报价单详情页编辑 `customRequirements`

**依赖：** CPQAPP-006

---

### 任务 8：BOM物料成本接入定价引擎

| 字段 | 内容 |
|------|------|
| **任务ID** | CPQAPP-009 |
| **需求提出者** | 万维团队（2026-07-20 代码审查） |
| **提出时间** | 2026-07-20 |
| **优先级** | 🟡 P1 |
| **模块/仓库** | CPQ_App |
| **当前状态** | ⬜ 待开发 |

**问题描述：**

`ConfiguratorController.complete()` 中 BOM 成本计算写死为 0：
```java
.map(line -> BigDecimal.ZERO) // TODO: 物料成本从主数据获取
```
导致定价引擎的 Phase 2（成本校验）和 Phase 6（成本底线检查）完全无效。

**需求：**
1. 从 `cpq_product_model` 或其他物料主数据表读取物料单价
2. BOM成本 = Σ(物料单价 × BOM用量 × 报价数量)
3. 成本底线检查生效：净价 < BOM成本时触发审批

**涉及文件：**
- `ConfiguratorController.java`（改：替换 `BigDecimal.ZERO` 为实际成本查询）

---

### 任务 9：报价单创建时带参数重算定价

| 字段 | 内容 |
|------|------|
| **任务ID** | CPQAPP-010 |
| **需求提出者** | 万维团队（2026-07-20 产品评审） |
| **提出时间** | 2026-07-20 |
| **优先级** | 🟢 P2 |
| **模块/仓库** | CPQ_App |
| **当前状态** | ⬜ 待开发 |

**问题描述：**

配置阶段的定价使用 `quantity=1, region=null, channelId=null`，仅作为预览。但生成报价单时没有重新调用定价引擎，导致：
- 报价单总金额永远为 `-`（空白）
- 渠道价、区域价、阶梯定价从未生效
- 客户关联的渠道/区域信息未从 CRM 反查并传给定价

**需求：**
1. 生成报价单时，从所选客户的 CRM 数据获取 `region`、`channelId`
2. 用报价单的实际 `quantity` + `region` + `channelId` 重新调 `calculatePrice()`
3. 将 `netPrice` 写入报价单头 `grandTotal`
4. 报价单列表显示实际金额

**依赖：** CPQAPP-006

---

### 任务 10：报价单行项目自动填充

| 字段 | 内容 |
|------|------|
| **任务ID** | CPQAPP-011 |
| **需求提出者** | 万维团队（2026-07-20 产品评审） |
| **提出时间** | 2026-07-20 |
| **优先级** | 🟡 P1 |
| **模块/仓库** | CPQ_App |
| **当前状态** | ⬜ 待开发 |

**问题描述：**

当前新建报价单时，表单只有客户/类型/币种/有效期/备注字段。MBOM 物料行需要报价单创建后，在详情页逐行手动添加。没有任何批量导入或从配置结果自动填充的能力。

**需求：**
1. 新增报价单表单支持"从配置结果导入"选项（如果 Pinia Store 中有配置数据）
2. 导入后自动逐行调用 `POST /cpq/quote/lineitem`，写入物料编码/名称/数量/单位/单价/行总计
3. 行项目的 `modelId`、`sbomLineId`、`configurationJson` 一并写入

**依赖：** CPQAPP-006

---

### 任务 11：产品目录关键词搜索修复

| 字段 | 内容 |
|------|------|
| **任务ID** | CPQAPP-012 |
| **需求提出者** | 万维团队（2026-07-20 测试发现） |
| **提出时间** | 2026-07-20 |
| **优先级** | 🟢 P2 |
| **模块/仓库** | CPQ_App |
| **当前状态** | ⬜ 待开发 |

**问题描述：**

产品目录搜索框输入 `ER14505` 或 `EVE` 等关键词后点击搜索，返回"未找到匹配的分类或产品"。但左侧分类树展开「物联网电池方案 → 锂亚硫酰氯电池」可以看到产品列表。搜索功能对具体型号编码和字母前缀匹配失效。

**需求：**
1. 排查后端 `GET /cpq/product/model/search?keyword=` 的查询逻辑
2. 确认 SQL LIKE 是否使用了正确的模糊匹配（`%keyword%`）
3. 确保搜索能匹配 `model_code` 和 `model_name` 的任意子串

---

### 任务 12：MBOM覆盖写入改为会话级隔离

| 字段 | 内容 |
|------|------|
| **任务ID** | CPQAPP-013 |
| **需求提出者** | 万维团队（2026-07-20 代码审查） |
| **提出时间** | 2026-07-20 |
| **优先级** | 🟢 P2 |
| **模块/仓库** | CPQ_App |
| **当前状态** | ⬜ 待开发 |

**问题描述：**

`BomExplosionService.saveMbomLines()` 按 `modelId` 逻辑删除旧 MBOM 后插入新行。这意味着：
- 用户 A 配置 EVE-HVI-40.0（选15kW逆变器）→ MBOM 写入 11 行
- 用户 B 配置 EVE-HVI-40.0（选25kW逆变器）→ 用户 A 的 MBOM 被覆盖

多用户/多会话并发时 MBOM 数据互相覆盖。

**需求：**
1. MBOM 写入改为按 `(modelId, sessionId/userId)` 隔离存放
2. 或取消 `saveMbomLines()` 中的覆盖写入，改为在生成报价单时一次性写入
3. 配置完成后的 MBOM 仅作为前端缓存，不持久化到 `cpq_mbom_line`（如果需要持久化则加 session 标识）

**涉及文件：**
- `BomExplosionService.java`（改：`saveMbomLines` 逻辑）

---

### 任务 13：新增报价单表单缺少客户搜索+数量输入

| 字段 | 内容 |
|------|------|
| **任务ID** | CPQAPP-014 |
| **需求提出者** | 万维团队（2026-07-20 产品评审） |
| **提出时间** | 2026-07-20 |
| **优先级** | 🟡 P1 |
| **模块/仓库** | CPQ_App |
| **当前状态** | ⬜ 待开发 |

**问题描述：**

新增报价单弹窗只有客户下拉/类型/币种/有效期/备注 5 个字段，缺少：
- 客户搜索（当前只能下拉选择，CRM 有 6 个客户，但无搜索过滤）
- 数量输入（报价数量需在行项目页面单独输入）
- 配置方案选择（没有"从配置器导入"或"选择产品"的入口）

**需求：**
1. 客户下拉增加远程搜索（输入关键词过滤 CRM 客户列表）
2. 如果是"从配置器生成报价单"（CPQAPP-006），则自动带入配置数据，跳过此弹窗
3. 如果是"手动创建报价单"，增加产品型号选择 + 数量输入
