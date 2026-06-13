# CPQ 开发计划 V2.0 — 对齐设计文档

> 版本：V2.0 | 日期：2026-06-06  
> 基于：CPQ_后端功能设计.md + CPQ_前端门户设计.md  
> 原则：已完成架构对齐，后续按 Sprint 分批交付

---

## V2.0 变更总结

### 已完成的对齐工作（V1.0 → V2.0）

| 变更项 | V1.0 | V2.0 | 状态 |
|--------|------|------|:--:|
| **菜单ID** | 12000-12999 | 50000-50140（避免与RuoYi系统菜单冲突） | ✅ |
| **菜单结构** | 3级树（CPQ管理→产品数据→产品目录/产品管理） | 14个一级菜单对齐设计§3（首页/配置报价/报价管理/方案管理/审批中心/售前协同/竞品对标/产品管理/定价管理/交期查询/知识库/系统集成/系统设置/个人中心） | ✅ |
| **角色** | 无 | 12个CPQ角色(100-111)+角色-菜单分配矩阵 | ✅ |
| **ABAC** | 无 | cpq_abac_policy表+8条成本可见性策略 | ✅ |
| **DDL表名** | cpq_product_category/cpq_product/cpq_substitute | cpq_product_catalog/cpq_product_model/cpq_product_supersession | ✅ |
| **DDL新增表** | 6张表 | 10张表（新增cpq_mbom_line/cpq_product_lifecycle_log/cpq_abac_policy/cpq_product_category） | ✅ |
| **tenant_id类型** | VARCHAR(20)（正确） | VARCHAR(20)（对齐TenantEntity String类型） | ✅ |
| **Domain类** | 6个 | 10个（新增CpqProductCategory，CpqProductModel字段变更） | 🔄 |
| **前端项目** | ruoyi-ui/（2个页面） | 4个页面（category/catalog/model/supersession），4个API模块 | 🔄 |
| **后台admin依赖** | 不含ruoyi-cpq | 已添加ruoyi-cpq依赖到ruoyi-admin 2/pom.xml | ✅ |

### V2.1 新增变更：产品分类从内联字段改为独立树表（2026-06-06）

> cpq_product_model 删除 product_line/product_family/product_series，新增 category_id FK → cpq_product_category。详见 `.codebuddy/Sprint1_Bundle_Impact_Modification_Plan.md` §变更B。

### 待完成的 Java 代码对齐工作

> ⚠️ **大部分完成（Sprint 1，2026-06-06）**。所有旧 BO/VO/Mapper/Service/Controller 已删除，9个新Domain类、8个新BO/VO、6个新Mapper、1个额外Service接口、3个新Service接口+Impl、3个新Controller已创建，前后端编译全部通过。**但 S1.1.9（CpqMbomLine/CpqProductLifecycleLog）仅有 Domain 类，无 Mapper/Service/Controller。另外 CpqProductAttribute/CpqSbomHeader/CpqSbomLine 的 Domain 类和部分 Mapper 也已创建但未在 Sprint 1 任务中登记。** 剩余 CRUD 补齐工作已纳入 Sprint 2。

---

## Sprint 规划（V2.0）

### Sprint 1：完成 V1.0→V2.0 代码对齐 ✅（已完成 2026-06-06）

**S1.1 Java代码对齐**
- [x] S1.1.1 重写 CpqProductCatalogBo/Vo（适配新字段）
- [x] S1.1.2 重写 CpqProductModelBo/Vo（适配新字段）
- [x] S1.1.3 重写 CpqProductCatalogMapper（改表名+字段映射）
- [x] S1.1.4 重写 CpqProductModelMapper（改表名+字段映射）
- [x] S1.1.5 重写 ICpqProductCatalogService/Impl（适配catalog）
- [x] S1.1.6 重写 ICpqProductModelService/Impl（适配model）
- [x] S1.1.7 重写 CpqProductCatalogController
- [x] S1.1.8 重写 CpqProductModelController
- [x] S1.1.9 新增 CpqMbomLine/CpqProductLifecycleLog Domain类
- [x] S1.1.10 mvn compile + mvn package 验证通过
- [x] S1.1.11 新增 CpqProductSupersessionBo/Vo/Mapper/Service/Controller
- [x] S1.1.12 添加 ruoyi-cpq 依赖到 ruoyi-admin 2/pom.xml

**S1.3 V2.1 产品分类独立建表（2026-06-07 完成）**
- [x] S1.3.1 新增 cpq_product_category DDL + Domain/Bo/Vo/Mapper/Service/Controller
- [x] S1.3.2 修改 cpq_product_model DDL/Domain/Bo/Vo（product_line/family/series → category_id）
- [x] S1.3.3 修改 CpqProductModelServiceImpl（新增 enrichCategoryPath）
- [x] S1.3.4 新增 api/cpq/category.ts + category/index.vue
- [x] S1.3.5 修改 model/index.vue（3个文本输入 → 3级级联 lookup）
- [x] S1.3.6 修改 model.ts API 类型

**S1.4 前端对齐**
- [x] S1.4.1 更新 API 接口适配新后端路径（catalog.ts/model.ts/supersession.ts）
- [x] S1.4.2 新建 ProductCatalog.vue（扁平表CRUD）
- [x] S1.4.3 新建 ProductModel.vue（5层结构+生命周期+配置类型 → V2.1改为3级级联lookup）
- [x] S1.4.4 新建 ProductSupersession.vue
- [x] S1.4.5 删除旧 category/product/keyword 页面和API
- [x] S1.4.6 vue-tsc --noEmit 编译通过

**Sprint 1 验证结果**（2026-06-06 19:20 初版通过 / 2026-06-07 00:59 V2.1终版通过）
- Swagger 注册：18个CPQ API端点全部可见（新增 Category 6个端点）
- 后端编译：mvn clean package BUILD SUCCESS
- 前端编译：vue-tsc --noEmit 零错误
- 路径冲突：无（四个Controller路径独立：catalog/model/supersession/category）
- 服务状态：后端8080/前端3000均运行正常
- **API测试**：全部端点CRUD测试通过（Catalog 5/5, Category 6/6, Model 7/7, Supersession 5/5），含 categoryPath 自动 enrich 验证
- **分类表**：cpq_product_category 含13条种子数据（3 L1 + 4 L2 + 6 L3），3级树形结构正确
- **模型表**：cpq_product_model 已迁移 category_id（删除 product_line/family/series），categoryPath 自动拼接 "L1 > L2 > L3"
- **前端**：category/index.vue 树形表格 CRUD 完整，model/index.vue 3级级联 lookup 已实现
- **修复**：CpqProductCatalogVo/CpqProductModelVo/CpqProductSupersessionVo 添加 @AutoMapper(reverseConvertGenerate=true) 修复 MapStruct Entity→VO 转换器缺失导致的500错误；种子数据 tenant_id 从 '1' 修正为 '000000'

### Sprint 2：D01 产品数据域完整交付（2026-06-07 完成）

**S2.1 D01 补齐 Domain 层 CRUD（2026-06-07 完成）**
- [x] S2.1.1 CpqSbomHeader Bo/Vo/Mapper/Service/Controller — SBOM 头表 CRUD
- [x] S2.1.2 CpqSbomLine Bo/Vo/Mapper/Service/Controller — SBOM 行表 CRUD
- [x] S2.1.3 CpqMbomLine Bo/Vo/Mapper/Service/Controller — MBOM 行表 CRUD
- [x] S2.1.4 CpqProductAttribute Bo/Vo/Mapper/Service/Controller — 产品属性 CRUD
- [x] S2.1.5 CpqProductLifecycleLog Bo/Vo/Mapper/Service/Controller — 生命周期日志 CRUD

**S2.2 D01 核心引擎 Service（手写）**
- [x] S2.2.1 BomExplosionService — explodeBom/implodeBom/filterVariantBom（已在 CpqSbomServiceImpl 中实现，含虚项展开和变体过滤）
- [x] S2.2.2 LifecycleService — 状态变更+日志记录（recordStateChange 方法追加到 CpqProductLifecycleLogServiceImpl）
- [x] S2.2.3 SupersessionService — where-used+推荐（whereUsed + recommendReplacement 追加到 CpqProductSupersessionServiceImpl + Controller）

**S2.3 D07 系统数据域 — cpq_system_config**
- [x] S2.3.1 cpq_system_config DDL（已执行建表 SQL）
- [x] S2.3.2 CpqSystemConfig Domain/Mapper/Service/Controller — CRUD（7个文件新建）

**前端（cpq-portal）**
- [x] S2.4.1 初始化 cpq-portal 项目（Vite+Vue3+TypeScript 脚手架，设计 Token SCSS 变量，Element Plus，Axios 拦截器含 Sa-Token + token 自动解包）
- [x] S2.4.2 PortalLayout.vue（侧边栏+顶栏+内容区三栏布局，深色侧边栏，Element Plus 路由导航）
- [x] S2.4.3 产品目录页 ProductCatalog.vue（左分类树 + 右产品表格联动，对齐设计 §8.1 ConfigTree）
- [x] S2.4.4 BOM查看页 BomManager.vue（产品远程搜索 + 树形表格 BOM 展开，对齐设计 §8.1 BomPreview）
- [x] S2.4.5 替代品管理页 SupersessionManager.vue（where-used + 推荐替代品双 Tab，对齐设计 §A.1 SupersessionManager）
- [x] S2.4.6 配置规则页 ConfigRuleManager.vue（预留占位，标注 Sprint 3 交付）

**S2.4 补充任务**
- [x] S2.4.7 BOM 管理 CRUD UI — BomManager.vue 升级为完整管理页：Header 新增/编辑弹窗 + Line 树形增删改（新增子行/编辑/删除/虚项标记/替换组/数量范围/排序），后端 API 已就绪

### Sprint 3：D02+D03 + Bundle 定价与配置引擎（2周）

**S3.1 D02 定价数据域（6张表，DDL 见 `sql/cpq_d02_pricing.sql`）**
- [ ] S3.1.1 执行 DDL：`mysql < sql/cpq_d02_pricing.sql`
- [ ] S3.1.2 cpq_price_book — 价格手册 CRUD
- [ ] S3.1.3 cpq_price_book_entry — 价格手册条目 CRUD
- [ ] S3.1.4 cpq_price_rule — 定价规则 CRUD
- [ ] S3.1.5 cpq_volume_tier — 阶梯定价 CRUD
- [ ] S3.1.6 cpq_channel_price — 渠道价格 CRUD
- [ ] S3.1.7 cpq_currency_rate — 汇率 CRUD

**S3.2 D03 配置数据域（5张表，DDL 见 `sql/cpq_d03_config.sql`）**
- [ ] S3.2.1 执行 DDL：`mysql < sql/cpq_d03_config.sql`
- [ ] S3.2.2 cpq_config_rule — 配置规则 CRUD
- [ ] S3.2.3 cpq_variant_bom — 变体BOM/150% BOM CRUD
- [ ] S3.2.4 cpq_attribute_mapping — 属性→物料映射 CRUD
- [ ] S3.2.5 cpq_compatibility_matrix — 跨产品兼容性矩阵 CRUD
- [ ] S3.2.6 cpq_attribute_option — 选项值定义 CRUD

**S3.3 产品捆绑域（3张表，DDL 见 `sql/cpq_d01_product.sql` §12-14）**
- [ ] S3.3.1 cpq_bundle — 捆绑包定义 CRUD
- [ ] S3.3.2 cpq_bundle_option_group — 捆绑选项组 CRUD
- [ ] S3.3.3 cpq_bundle_option — 捆绑选项 CRUD

**S3.4 核心引擎手写**
- [ ] S3.4.1 ConfigEngineService — CSP约束求解（validate/propagateConstraints/guidedSelling）
- [ ] S3.4.2 PricingEngineService — 六阶段定价流水线（calculatePrice/applyDiscount/getBestPrice，含捆绑定价策略 BUNDLE_PRICE/SUM_COMPONENTS）

### Sprint 4：D04+D05 报价与审批（2周）

**S4.1 D04 报价数据域（6张表，DDL 见 `sql/cpq_d04_quote.sql`）**
- [ ] S4.1.1 执行 DDL：`mysql < sql/cpq_d04_quote.sql`
- [ ] S4.1.2 cpq_quote — 报价单 CRUD
- [ ] S4.1.3 cpq_quote_line_item — 报价行项目 CRUD
- [ ] S4.1.4 cpq_config_snapshot — 配置快照/时间胶囊 CRUD
- [ ] S4.1.5 cpq_quote_version — 报价版本 CRUD
- [ ] S4.1.6 cpq_quote_template — 报价模板 CRUD
- [ ] S4.1.7 cpq_solution_document — 方案文档 CRUD

**S4.2 D05 审批数据域（4张表，DDL 见 `sql/cpq_d05_approval.sql`）**
- [ ] S4.2.1 执行 DDL：`mysql < sql/cpq_d05_approval.sql`
- [ ] S4.2.2 cpq_approval_rule — 审批规则 CRUD
- [ ] S4.2.3 cpq_approval_chain — 审批链实例 CRUD
- [ ] S4.2.4 cpq_approval_record — 审批记录 CRUD
- [ ] S4.2.5 cpq_approval_matrix — 审批矩阵 CRUD

**S4.3 核心引擎手写**
- [ ] S4.3.1 QuoteGenerateService — 报价单 PDF/Word 生成（generatePdf/generateWord/fillTemplate）
- [ ] S4.3.2 ApprovalRouteService — 审批链构建与流转（buildChain/processAction/escalateTimeout）

### Sprint 5：D06+D08 + 前端门户（2周）

**S5.1 D06 客户渠道域（4张表，DDL 见 `sql/cpq_d06_customer.sql`）**
- [ ] S5.1.1 执行 DDL：`mysql < sql/cpq_d06_customer.sql`
- [ ] S5.1.2 cpq_account — 客户 CRUD
- [ ] S5.1.3 cpq_channel — 渠道 CRUD
- [ ] S5.1.4 cpq_agreement_price — 协议价 CRUD
- [ ] S5.1.5 cpq_territory — 区域 CRUD

**S5.2 D08 集成数据域（3张表，DDL 见 `sql/cpq_d08_integration.sql`）**
- [ ] S5.2.1 执行 DDL：`mysql < sql/cpq_d08_integration.sql`
- [ ] S5.2.2 cpq_integration_config — 集成配置 CRUD
- [ ] S5.2.3 cpq_integration_mapping — 集成字段映射 CRUD
- [ ] S5.2.4 cpq_sync_log — 同步日志 CRUD
- [ ] S5.2.4 CrmConnector / ErpConnector / PlmConnector — 连接器 Service（手写）

**S5.3 ATP 引擎**
- [ ] S5.3.1 AtpCtpService — ATP三级检查 + CTP交期推算 + 替代推荐（手写）
- [ ] S5.3.2 AtpController — ATP/CTP REST API

**S5.4 前端门户**
- [ ] S5.4.1 门户首页（12角色 Dashboard：Sales/Presales/Manager/Partner/Product/Pricing/Supply/Approval/Operations/Executive/Audit/Admin）
- [ ] S5.4.2 配置器主页面 Configurator.vue（三栏布局+OptionCard+ConstraintWarning+BomPreview+AtpIndicator）
- [ ] S5.4.3 报价创建页面 QuoteCreate.vue（模板选择→自动填充→微调→生成PDF/Word→提交审批）
- [ ] S5.4.4 Store 模块（configurator/quote/tenant Pinia stores）
- [ ] S5.4.5 通用组件（CpqCard/StatusBadge/DataTable/EmptyState/LoadingSkeleton/ErrorBoundary）
- [ ] S5.4.6 权限指令（v-hasPermi/v-hasRole/v-cost-visibility）
- [ ] S5.4.7 全局搜索组件 MultiModalSearch.vue

### Sprint 6：集成测试与部署（1周）

- [ ] S6.1 端到端测试：标准配置报价全流程（产品搜索→配置器→BOM预览→ATP检查→报价生成→审批流转）
- [ ] S6.2 多租户隔离验证（两个租户数据不可见）
- [ ] S6.3 ABAC成本可见性验证（L0-L3四级角色成本脱敏）
- [ ] S6.4 RBAC权限验证（12角色菜单可见性+按钮权限）
- [ ] S6.5 移动端适配测试（响应式断点+移动端简化视图）
- [ ] S6.6 部署文档 + 运维手册

---

## 审计发现与待跟踪项（2026-06-06 审计）

以下为本次审计发现的设计文档与开发计划之间的差异，需持续跟踪：

| ID | 发现 | 优先级 | 状态 |
|----|------|:---:|:---:|
| A1 | 设计文档 §3.1 菜单 component 路径与数据库/代码不一致（50081/50082/50084），需同步更新设计文档 | 高 | 待处理 |
| A2 | 设计文档 §3.2 仅给出 3 个角色的菜单分配 SQL，其余 9 个角色未给出，需补全 | 中 | 待处理 |
| A3 | 设计文档缺少 8 个手写核心 Service 的输入/输出接口契约（见审计报告 §4.1） | 高 | 待处理 |
| A4 | 设计文档缺少前端组件的 Props/Events/Slots 规格（见审计报告 §4.2） | 中 | 待处理 |
| A5 | D02-D08 的 DDL SQL 文件已全部创建（7 个 SQL 文件，共 29 张表），详见 SQL 文件清单 | 高 | ✅ 已完成（2026-06-06） |
| A6 | cpq_system_config 表 DDL 遗漏（D07），已补入 Sprint 2 S2.3 | 高 | ✅ 已纳入计划 |
| A7 | Sprint 1 S1.1.9（CpqMbomLine/CpqProductLifecycleLog）产出不足，仅有 Domain 无 API 层 | 高 | ✅ 已纳入 Sprint 2 |
| A8 | cpq-portal 与 ruoyi-ui 的认证共享方案需要设计明确（同域 SSO? 跨域 token?） | 高 | 待设计 |
| A9 | Sprint 1 中额外创建的 3 个 Domain + 2 个 Mapper 未在任务列表中登记 | 低 | ✅ 已补登记 |
| A10 | 数据库中仅有 cpq_product_catalog 表有 1 条测试数据，其余表为空，缺少种子数据 | 中 | 待处理 |

---

## 当前数据库状态

| 数据库 | 表 | 条数 |
|--------|-----|:--:|
| Ruoyi_CPQ | cpq_product_catalog | 9张CPQ表 |
| Ruoyi_CPQ | sys_menu（CPQ菜单） | 58条 |
| Ruoyi_CPQ | sys_role（CPQ角色） | 12个 |
| Ruoyi_CPQ | cpq_abac_policy | 8条策略 |

## SQL 文件清单

| 文件 | 数据域 | 表数 | 目标 Sprint | 执行状态 |
|------|--------|:--:|:----------:|:------:|
| `sql/cpq_d01_product.sql` | D01 产品 + Bundle 捆绑 + D07 ABAC | 14 | S1 | ✅ 已执行 |
| `sql/cpq_d02_pricing.sql` | D02 定价（price_book/entry/rule/volume_tier/channel_price/currency_rate） | 6 | S3 | ⏳ 待执行 |
| `sql/cpq_d03_config.sql` | D03 配置引擎（config_rule/variant_bom/attribute_mapping/compatibility_matrix/attribute_option） | 5 | S3 | ⏳ 待执行 |
| `sql/cpq_d04_quote.sql` | D04 报价（quote/line_item/config_snapshot/version/template/solution_document） | 6 | S4 | ⏳ 待执行 |
| `sql/cpq_d05_approval.sql` | D05 审批（approval_rule/chain/record/matrix） | 4 | S4 | ⏳ 待执行 |
| `sql/cpq_d06_customer.sql` | D06 客户渠道（account/channel/agreement_price/territory） | 4 | S5 | ⏳ 待执行 |
| `sql/cpq_d07_system.sql` | D07 系统配置（cpq_system_config，cpq_abac_policy 在 d01 中） | 1 | S2 | ⏳ 待执行 |
| `sql/cpq_d08_integration.sql` | D08 集成（integration_config/mapping/sync_log） | 3 | S5 | ⏳ 待执行 |
| `sql/cpq_menu.sql` | 菜单数据 | — | S1 | ✅ 已执行 |
| `sql/cpq_roles.sql` | 角色+权限数据 | — | S1 | ✅ 已执行 |
| `sql/cpq_menu_fix_20260606.sql` | 菜单修复补丁 | — | S1 | ✅ 已执行 |

> **总计**：43 张 CPQ 业务表（D01 9 + Bundle 3 + D02 6 + D03 5 + D04 6 + D05 4 + D06 4 + D07 2 + D08 3），DDL 全部已生成，覆盖 8 个数据域，所有表严格对齐 `M-CPQ_Product_Data_Architecture.md` 设计。
