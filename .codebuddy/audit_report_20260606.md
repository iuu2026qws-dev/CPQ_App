# CPQ 开发计划全面审计报告

> 日期：2026-06-06 | 审计范围：开发计划 V2.0 vs 设计文档 vs 实际代码/数据库

---

## 一、Sprint 1 状态验证

### S1.1 Java 代码对齐（12项全部标记为 [x] 已完成）

| 任务 | 状态 | 验证结果 |
|------|:---:|---------|
| S1.1.1 CpqProductCatalogBo/Vo | ✅ | `CpqProductCatalogBo.java` + `CpqProductCatalogVo.java` 存在，extends TenantEntity，有 @AutoMapper |
| S1.1.2 CpqProductModelBo/Vo | ✅ | `CpqProductModelBo.java` + `CpqProductModelVo.java` 存在 |
| S1.1.3 CpqProductCatalogMapper | ✅ | `CpqProductCatalogMapper.java` 存在 |
| S1.1.4 CpqProductModelMapper | ✅ | `CpqProductModelMapper.java` 存在 |
| S1.1.5 ICpqProductCatalogService/Impl | ✅ | 接口+实现类存在 |
| S1.1.6 ICpqProductModelService/Impl | ✅ | 接口+实现类存在 |
| S1.1.7 CpqProductCatalogController | ✅ | `/cpq/product/catalog` 端点 |
| S1.1.8 CpqProductModelController | ✅ | `/cpq/product/model` 端点 |
| S1.1.9 CpqMbomLine/CpqProductLifecycleLog Domain | ⚠️ **部分完成** | Domain 类存在，但**无 Mapper/Service/Controller**，仅创建了 Entity 壳 |
| S1.1.10 mvn compile + package | ✅ | 编译通过 |
| S1.1.11 CpqProductSupersession 全套 | ✅ | Bo/Vo/Mapper/Service/Controller 全部存在 |
| S1.1.12 ruoyi-cpq 依赖 | ✅ | admin 2 已添加依赖 |

**发现：S1.1.9 实际产出不足**。CpqMbomLine 和 CpqProductLifecycleLog 仅是 Domain/Entity 类，缺少 Mapper、Service、Controller 三层。这两个实体在开发计划中标记为"已完成"，但无法独立提供 API 功能。此外，Sprint 1 还创建了另外 3 个 Domain 类（CpqProductAttribute、CpqSbomHeader、CpqSbomLine）和 2 个 Mapper（CpqProductAttributeMapper、CpqSbomHeaderMapper、CpqSbomLineMapper）和 1 个 Service 接口（ICpqSbomService），这些没有出现在 Sprint 1 的任务列表中，属于**未登记的工作项**。

### S1.2 前端对齐（6项全部标记为 [x] 已完成）

| 任务 | 状态 | 验证结果 |
|------|:---:|---------|
| S1.2.1 API 接口适配 | ✅ | catalog.ts / model.ts / supersession.ts 存在 |
| S1.2.2 ProductCatalog.vue | ✅ | `src/views/cpq/catalog/index.vue` 存在 |
| S1.2.3 ProductModel.vue | ✅ | `src/views/cpq/model/index.vue` 存在 |
| S1.2.4 ProductSupersession.vue | ✅ | `src/views/cpq/supersession/index.vue` 存在 |
| S1.2.5 删除旧页面 | ✅ | 旧 category/product/keyword 已删除 |
| S1.2.6 vue-tsc --noEmit | ✅ | 零错误 |

**Sprint 1 验证结论**：主体完成，但 S1.1.9 产出不足（仅有 Domain 无 API 层），且有 3 个额外的 Domain 类和 2 个 Mapper+1 个 Service 接口未在任务列表中登记。开发计划声称"18个CPQ API端点"，但未验证18个端点是否全部实际可用（如 curl 测试）。

---

## 二、开发计划遗漏项

### 遗漏 1：D01 数据域 6 个实体的 CRUD 未纳入任何 Sprint

D01 共 9 张表，DDL 已全部执行。但 **仅有 3 张表（catalog/model/supersession）有完整的 Controller→Service→Mapper→Domain 四层**。以下 6 张表**没有任何 Sprint 覆盖其 CRUD 开发**：

| 表 | Domain 类 | Mapper | Service | Controller | 被哪个 Sprint 覆盖 |
|----|:---:|:---:|:---:|:---:|---|
| cpq_sbom_header | ✅ CpqSbomHeader | ✅ CpqSbomHeaderMapper | ❌ 无 Impl | ❌ 无 | **未覆盖** |
| cpq_sbom_line | ✅ CpqSbomLine | ✅ CpqSbomLineMapper | ❌ 无 Impl | ❌ 无 | **未覆盖** |
| cpq_mbom_line | ✅ CpqMbomLine | ❌ 无 | ❌ 无 | ❌ 无 | **未覆盖** |
| cpq_product_attribute | ✅ CpqProductAttribute | ✅ CpqProductAttributeMapper | ❌ 无 | ❌ 无 | **未覆盖** |
| cpq_product_lifecycle_log | ✅ CpqProductLifecycleLog | ❌ 无 | ❌ 无 | ❌ 无 | **未覆盖** |

Sprint 2 的 B1 仅提到"SBOM管理 Service（BomExplosionService）"，这是**手写核心引擎**，而非标准 CRUD。标准 CRUD 的 SBOM Header/Line Controller+Service+Impl 完全被遗漏。

### 遗漏 2：开发计划缺少 D07 系统数据域表（cpq_system_config）

后端设计 §4 D07 定义了 `cpq_system_config` 表，但开发计划的 Sprint  1-6 中没有该表的 DDL 执行和 CRUD 开发任务。cs_abac_policy 已完成（Sprint 1），但 cpq_system_config 被遗漏。

### 遗漏 3：开发计划缺少 D06 客户渠道域 4 张表

后端设计 §4 D06 列出了 cpq_account、cpq_channel、cpq_agreement_price、cpq_territory 共 4 张表。Sprint 5 仅笼统提到"客户渠道域"但未列出具体表名和任务。这些表需要拆分出明确的任务项。

### 遗漏 4：开发计划缺少 D01 细分任务中的 BO/VO 类

当前仅 catalog/model/supersession 有 BO/VO。以下实体如果需要 API，也需要 BO/VO：
- CpqSbomHeaderBo/Vo
- CpqSbomLineBo/Vo  
- CpqMbomLineBo/Vo
- CpqProductAttributeBo/Vo（目前有 Domain 无 BO/VO）

### 遗漏 5：cpq-portal 前端项目初始化任务缺失

Sprint 2 提到"重构前端项目为 cpq-portal/ 完整结构"，但没有分解为具体的初始化任务：
- 创建 Vite + Vue3 + TypeScript 项目脚手架
- 配置 Element Plus + ag-Grid + ECharts + Tiptap + Yjs 依赖
- 配置 SCSS 变量（§6.1 设计 Token）
- 配置路由结构 + Pinia store 骨架
- 配置 Axios 拦截器（Sa-Token + tenant_id 注入）
- 配置 v-hasPermi / v-hasRole / v-cost-visibility 指令
- 配置与 ruoyi-admin 后端的 proxy

### 遗漏 6：Sprint 3-5 表级任务缺失

Sprint 3 说"定价数据域 DDL（7张表）"但未列出具体表名（后端设计 §4 D02 有 cpq_price_book / cpq_price_book_entry / cpq_price_rule / cpq_volume_tier / cpq_channel_price / cpq_currency_rate，共6张而非7张）。

类似地，Sprint 4 说"审批数据域 DDL（4张表）"但后端设计 §4 D05 有 cpq_approval_rule / cpq_approval_chain / cpq_approval_record / cpq_approval_matrix，数量对上了但未列出表名。

### 遗漏 7：缺少测试策略任务

开发计划没有在任何 Sprint 中包含单元测试、集成测试或 API 测试任务。后端设计的 §6 Sprint 规划中提到 Sprint 9 有"端到端集成测试"，但开发计划 Sprint 6 仅提到"集成测试与部署"，且没有具体的测试用例清单。

---

## 三、状态不一致项

### 不一致 1：菜单名称与设计文档不匹配

| 菜单 ID | 设计文档 §3.1 名称 | 数据库实际名称 | 说明 |
|---------|-------------------|---------------|------|
| 50082 | BOM管理 | 产品模型 | cpq_menu_fix.sql 将名称改为"产品模型"（因为当前未实现 BOM 功能，改为产品模型 CRUD） |

这属于 Sprint 1 中的合理调整，但设计文档需要同步更新（或标注为"Sprint 2 将改回 BOM管理"）。

### 不一致 2：Component 路径与设计文档不匹配

| 菜单 ID | 设计文档 §3.1 component | 数据库实际 component |
|---------|------------------------|---------------------|
| 50081 | product/ProductCatalog | cpq/catalog |
| 50082 | product/BomManager | cpq/model |
| 50084 | product/SupersessionManager | cpq/supersession |

这些路径变更反映在 cpq_menu_fix_20260606.sql 中，前端实际文件路径与数据库一致。设计文档需要同步更新。

### 不一致 3：Sprint 2 中的 B6 与 Sprint 1 中的 S1.1.11 重叠

Sprint 2 B6 写的是"Supersession Controller（/cpq/product/supersession）"，但 Sprint 1 S1.1.11 已经创建了 `CpqProductSupersessionController`。Sprint 2 B6 与 Sprint 1 S1.1.11 是重复任务。实际上 Sprint 2 需要的是**增强**替代品管理的 where-used 和推荐逻辑（B3），而非重新创建 Controller。

---

## 四、设计文档待细化清单

### 4.1 后端 API 契约层面

后端功能设计 §4 给出了完整的 DDL，§5 给出了代码生成计划，但**缺少以下内容**：

1. **每个 Controller 的 REST API 端点规格**：URL、HTTP 方法、路径参数、Query 参数、Request Body Schema、Response Body Schema、错误码。目前仅列出了"70 API 端点"的总数，但没有一一列举端点定义。

2. **手写核心 Service 的接口契约**（8个手写 Service）：
   - `BomExplosionService.explodeBom(modelId, selections)` — 输入/输出格式
   - `PricingEngineService.calculatePrice(quoteId, lineItems)` — 六阶段流水线的每阶段输入/输出
   - `ConfigEngineService.validate(selections)` — CSP 求解的输入格式和冲突输出格式
   - `AtpCtpService.checkAtp(lineItems)` — ATP 三级检查的输出结构
   - `ApprovalRouteService.buildChain(quoteId, triggerType)` — 审批链 JSON 结构
   - `QuoteGenerateService.generatePdf(quoteId, templateId)` — 模板变量列表
   - `EcnImpactAnalysisService.analyzeImpact(changeRequest)` — 五级联动影响输出的数据结构
   - `DataMigrationService.importData(file, mapping)` — 数据校验规则

3. **多租户数据隔离策略**：哪些表是租户级、哪些是系统级。后端设计 §4.1 说"所有表必须包含 tenant_id"，但 D07 中的 cpq_system_config 表可能应该是系统级别。需要明确。

4. **API 版本策略**：是否需要 `/api/v1/` 前缀。当前 Controller 路径是 `/cpq/product/catalog`，无版本号。

### 4.2 前端组件规格层面

前端门户设计 §8 给出了页面级规格，但**缺少组件级规格**：

1. **每个核心组件的 Props / Events / Slots 定义**：
   - OptionCard.vue：props（option, status, reason, recommended）、events（select, hover）
   - BomPreview.vue：props（bomData, loading）、events（node-click, expand）
   - ConfigTree.vue：props（treeData, selectedId）、events（node-select）
   - PriceBreakdown.vue：props（lineItems, currency）、events（edit-line）
   - ApprovalNode.vue：props（chain, currentNode）、events（approve, reject）

2. **12 个仪表盘页面的数据来源**：
   - 每个 KPI 卡片对应哪个后端 API
   - 图表（ECharts）的数据格式
   - 实时数据（SSE）的推送主题

3. **全局状态管理**（Pinia Store）的接口定义：
   - `useConfigurator` Store：selections 数据结构、undo/redo 栈格式
   - `useQuote` Store：草稿自动保存策略
   - `useTenant` Store：租户切换流程

4. **cpq-portal 与 ruoyi-ui 的前端交互**：
   - 是否共享登录状态（同域 SSO？跨域 token 传递？）
   - 是否共享 sys_menu 动态路由加载逻辑
   - 是否复用 ruoyi-ui 的 request.ts 拦截器

### 4.3 数据架构层面

1. **43 张表的完整 DDL 文件**：目前仅有 `cpq_d01_product.sql`（D01 的 9 张表），D02-D08 的 DDL 需要补齐。

2. **数据迁移五阶段**（前端设计附录 B 流程6）：需要细化每阶段的输入/验证规则/回滚策略。

3. **ECN/ECO 变更管理**（前端设计附录 B 流程5）：五级联动（产品变更→BOM 变更→配置规则变更→报价影响→审批触发）的具体数据流和传播规则。

### 4.4 菜单与角色层面

1. **Sprint 1 之后的菜单 component 路径**已与设计文档 §3.1 不一致。需要更新设计文档或开发计划以反映实际状态。

2. **角色-菜单分配**：设计文档 §3.2 仅给出了销售/售前/管理员的分配 SQL，其余 9 个角色的分配未给出。需要补全。

3. **权限字符串**：后端设计 §2.3 定义了权限字符串规范，但 Sprint 1 的三个 Controller 中的 `@SaCheckPermission` 注解使用了哪些权限字符串需要登记验证。

---

## 五、结论与建议

### 总体评估

Sprint 1 完成度约 **85%**——核心 CRUD 的三条链路（catalog/model/supersession）完整可用，但：
- D01 剩余 6 个实体只有 Domain 层，功能不完整
- 开发计划遗漏了这些实体的 CRUD 开发任务
- 设计文档与实现之间的菜单路径已产生偏离
- 后续 Sprint 的任务粒度太粗，缺少表级/API级的任务分解

### 建议立即执行

1. 将遗漏的 D01 6 个实体 CRUD 任务补充到开发计划 Sprint 2
2. 修正 Sprint 2 B6 与 Sprint 1 S1.1.11 的重复
3. 更新设计文档中的菜单 component 路径以反映 Sprint 1 实际产出
4. 补全 D02-D08 的 DDL SQL 文件
5. 细化 8 个手写核心 Service 的接口契约
