# M-CPQ 全方位设计文档交叉追溯报告 V2（终版）

> 审计日期: 2026-06-07 08:40  
> 审计范围: 阶段一(867行) + 阶段二(626行) + 阶段三(477行) + 前端设计(1213行) + 后端设计(1253行) + 开发计划(246行)，共 6 份文档完整通读  
> 方法论: 纵向上溯（阶段三→二→一）+ 横向对比（前端设计↔后端设计↔开发计划）

---

## 一、技术栈溯源

### 1.1 三层技术栈不一致

| 层级 | 阶段三设计 | 后端设计 | 前端设计 | 实际开发 |
|------|-----------|---------|---------|---------|
| 后端语言 | **Go 1.23** / Hertz + Kitex | **Java** / Spring Boot (RuoYi-Vue-Plus) | — | Java |
| 数据库 | **PostgreSQL 16** (递归CTE/RLS/JSONB/Multi-Schema) | **MySQL** (utf8mb4, InnoDB) | — | MySQL |
| ORM | GORM v2 | MyBatis-Plus | — | MyBatis-Plus |
| 前端 | React 19 + TypeScript | — | **Vue 3** + TypeScript + ElementPlus | Vue 3 |
| 状态管理 | Zustand + TanStack | — | Pinia | Pinia |
| UI组件 | Ant Design 5 + ag-Grid | — | Element Plus + ag-Grid | Element Plus |
| 缓存 | Redis Cluster | Redis | — | Redis |
| 搜索引擎 | MeiliSearch | — | — | 无 |
| 消息队列 | NATS + Pulsar | SSE (RuoYi-common-sse) | — | SSE |
| API网关 | APISIX | Nginx | Nginx | Nginx |
| 容器编排 | K3s + Rancher | — | — | 无 |
| 私有化 | K3s 离线 + ARM 信创 | — | — | 无 |

前端设计 V2.1 §1.1 明确记录了裁决: "本项目后端采用 RuoYi-Vue-Plus (Java/SpringBoot)，前端采用 Vue3+ElementPlus。阶段三的 Go 技术方案作为备选参考"。因此阶段三的大量产出在当前栈下无法复用。

### 1.2 不可复用项清单

阶段三以下具体设计在当前 Java + MySQL 栈下不可直接使用，需重新设计:

- **递归 CTE View** (v_bom_explosion 等 8 个 View): MySQL 支持递归 CTE 但语法与 PG 不同，需改写
- **4 个存储过程** (sp_bom_explosion/sp_mrp_net_requirement/sp_config_validate_batch/sp_quote_recalculate): MySQL 存储过程语法不同，需改写
- **JSONB 类型**: MySQL 5.7+ 支持 JSON 类型但功能弱于 PG JSONB，配置快照/ABAC 策略需调整
- **RLS 行级安全**: MySQL 不支持 RLS，ABAC 必须在应用层实现 (MyBatis-Plus 多租户插件)
- **Multi-Schema 多租户**: MySQL 不支持 Schema 隔离，当前使用 tenant_id 字段隔离
- **CSP 求解器 goroutine 池化**: Go 的 goroutine 模型在 Java 中需用线程池替代
- **K3s 部署**: 当前无容器化部署方案
- **HPA 弹性伸缩**: 当前无自动伸缩配置
- **分区归档**: MySQL 分区语法不同于 PG

---

## 二、模块级别覆盖度 (15 个功能模块 × 4 层设计)

| 模块 | 阶段一 P0 | 阶段二流程 | 阶段三服务 | 后端设计模块 | 开发计划 |
|------|:---:|:---:|:---:|------|:---:|
| 配置引擎 | 8 | 流程1/2/3 | S06 (3-12副本 HPA) | ruoyi-cpq-config | S3 ⏳ |
| 定价引擎 | 6 | 流程1/2 | S07 | ruoyi-cpq-pricing | S3 ⏳ |
| 报价引擎 | 5 | 流程1/2/3 | S08 | ruoyi-cpq-quote | S4 ⏳ |
| 审批工作流 | 4 | 流程7 | S09 | ruoyi-cpq-approval | S4 ⏳ |
| 方案管理 | 4 | 流程4 | S11 (+S12共享DB) | ruoyi-cpq-solution | S5 ⏳ |
| 售前协同 | 5 | 流程4 | S12 | ruoyi-cpq-solution (合并) | ❌ 无独立 |
| **竞品对标** | **2** | 未设计 | S13 | ruoyi-cpq-competitive | ❌ **无** |
| **销售赋能/知识库** | **1** | 未设计 | 无 | ruoyi-cpq-knowledge | ❌ **无** |
| ATP/CTP 交期 | 4 | 流程1/2 含 ATP | S10 (4副本 1000mCPU) | ruoyi-cpq-atp | S5 ⏳ |
| 产品与BOM管理 | 6 | 流程1 核心 | S14 (4副本 SoT) | ruoyi-cpq-product | S1+S2 ✅ |
| 系统集成 | 4 | 未设计专属流程 | S15 | ruoyi-cpq-integration | S5 ⏳ |
| **数据迁移** | **2** | **流程6 (5阶段)** | 无 | ruoyi-cpq-migration | ❌ **无** |
| **ECN/ECO变更** | **2** | **流程5 (9步传播链)** | 无 | ruoyi-cpq-ecn | ❌ **无** |
| 安全与权限 | 4 | 未设计 | S02-S04 | CPQ扩展(sys_menu+ABAC) | S1 ✅ 角色+菜单 |
| 管理与运维 | 0 P0 | 未设计 | S01/S05 | — | S1 部分 |

**覆盖度统计**: 15 模块中，9 个有 Sprint 规划 (60%)，2 个部分覆盖 (安全+运维)，4 个完全缺失 (竞品对标/知识库/数据迁移/ECN-ECO)。

---

## 三、P0 功能点追溯 (56 项)

### 3.1 当前计划覆盖的 P0

| 模块 | 计划 P0 | 状态 |
|------|:---:|------|
| 配置引擎 8 项 | S3 (ConfigEngine + CSP) | ⏳ |
| 定价引擎 6 项 | S3 (PricingEngine 6阶段) | ⏳ |
| 报价引擎 5 项 | S4 (QuoteGenerate) | ⏳ |
| 审批 4 项 | S4 (ApprovalRoute) | ⏳ |
| 方案管理 4 项 | S5 前端 | ⏳ |
| 产品BOM 6 项 | S1+S2 (已完成) | ✅ |
| ATP/CTP 4 项 | S5 (AtpCtpService) | ⏳ |
| 安全权限 4 项 | S1 (角色+菜单，ABAC DL 已建) | ⚠️ 部分 |

### 3.2 完全遗漏的 P0

| 模块 | 遗漏 P0 | 后端设计 | 开发计划 |
|------|---------|:---:|:---:|
| 售前协同 5 项 | 方案请求创建/指派、售前接单/编辑、在线评论、提交评审、修改闭环 | 有模块(合并到solution) | ❌ 无 |
| 竞品对标 2 项 | 竞品参数录入、参数自动对比基础版 | 有模块 | ❌ 无 |
| 销售赋能 1 项 | 产品知识库基础版 | 有模块 | ❌ 无 |
| 系统集成 4 项 | CRM集成/ERP集成/PLM集成/SSO | 有模块 | S5 ⏳ 但简略 |
| 数据迁移 2 项 | 批量导入(Excel/CSV)、导入校验基础版 | 有模块 | ❌ 无 |
| ECN/ECO 2 项 | 变更申请、影响范围评估基础版 | 有模块 | ❌ 无 |

### 3.3 统计

- 阶段一 56 项 P0 中: **已完成 6 项** (产品BOM) + **已规划 35 项** (配置/定价/报价/审批/ATP)
- **14 项 P0 完全未纳入 Sprint**: 售前协同 5 + 竞品对标 2 + 销售赋能 1 + 数据迁移 2 + ECN 2 + 系统集成 2(CRM/ERP 之外的 PLM + SSO)

---

## 四、核心引擎 Service 覆盖

后端设计 §5.2 列出 8 个手写核心 Service:

| Service | 所属模块 | 开发计划 | 状态 |
|---------|---------|:---:|:---:|
| BomExplosionService | ruoyi-cpq-product | S2.2.1 | ✅ 已完成 |
| ConfigEngineService | ruoyi-cpq-config | S3.4.1 | ⏳ |
| PricingEngineService | ruoyi-cpq-pricing | S3.4.2 | ⏳ |
| QuoteGenerateService | ruoyi-cpq-quote | S4.3.1 | ⏳ |
| ApprovalRouteService | ruoyi-cpq-approval | S4.3.2 | ⏳ |
| AtpCtpService | ruoyi-cpq-atp | S5.3.1 | ⏳ |
| **EcnImpactAnalysisService** | ruoyi-cpq-ecn | ❌ | **缺失** |
| **DataMigrationService** | ruoyi-cpq-migration | ❌ | **缺失** |

---

## 五、数据库执行状态 (43 张表)

| 数据域 | 表数 | 目标 Sprint | 当前状态 |
|--------|:--:|:----------:|:------:|
| D01 产品 + Bundle + D07 ABAC | 14 | S1 | ✅ 已执行 |
| D02 定价 | 6 | S3 | ⏳ 待执行 |
| D03 配置引擎 | 5 | S3 | ⏳ 待执行 |
| D04 报价 | 6 | S4 | ⏳ 待执行 |
| D05 审批 | 4 | S4 | ⏳ 待执行 |
| D06 客户渠道 | 4 | S5 | ⏳ 待执行 |
| D07 系统 (system_config) | 1 | S2 | ✅ 已执行 |
| D08 集成 | 3 | S5 | ⏳ 待执行 |

**注意**: 竞品对标 (cpq_competitive)、知识库 (cpq_knowledge)、ECN (cpq_ecn)、数据迁移 (cpq_migration) 四个模块后端设计有定义但未分配独立数据域也未纳入 Sprint，对应的数据库也未创建。

---

## 六、前端页面覆盖度 (完整追溯)

### 6.1 前端设计定义了但开发计划未覆盖的页面

**P0 级别遗漏** (对应阶段二 P0 功能):

| 前端页面/组件 | 对应阶段二 | 开发计划状态 |
|-------------|----------|:--:|
| GuidedSelling.vue + GuidedWizard.vue | §3.3 五状态机 (改进项#2) | ❌ 无 |
| SolutionEditor.vue (Tiptap + Yjs CRDT) | §3.4 四区布局协同编辑器 | ❌ 无 |
| SolutionCompare.vue (雷达图+成本瀑布图+对比矩阵) | — | ❌ 无 |
| SolutionReview.vue (评审工作台) | — | ❌ 无 |
| CompetitorList.vue + ComparisonView.vue + RecommendationView.vue | — | ❌ 无 |
| ProductKnowledge.vue + SalesScripts.vue + CaseLibrary.vue + TrainingCenter.vue | — | ❌ 无 |
| DataMigration.vue | 阶段二流程6 (5阶段) | ❌ 无 |
| ChangeManagement.vue (ECN) | 阶段二流程5 (9步传播链) | ❌ 无 |
| PriceBookList.vue + PriceRuleConfig.vue + VolumeTierConfig + DiscountApproval + CurrencyConfig | PRC-001~006 | ❌ 无 |
| PendingApproval.vue + ApprovalDetail + ApprovalHistory + ApprovalAnalytics | APV-001~004 | ❌ 无 |
| TaskBoard.vue + CollabEditor + ReviewWorkbench (售前协同) | PRE-001~005 | ❌ 无 |
| CrmConnector + ErpConnector + PlmConnector + SyncLogViewer | INT-001~004 | ❌ 无 |
| MultiModalSearch.vue (全局搜索组件) | §3.1 四模式搜索 | S5.4.7 ⏳ |
| 7 个额外 Dashboard (售前/经理/渠道/产品/定价/供应链/运营/高管/审批/审计) 共 10个 | 前端设计 §4.2 | S5.4.1 ⏳ |

### 6.2 前端设计已规划但仍未实现

S5.4 列出了 7 项前端任务:
- S5.4.1 12 角色 Dashboard ✅ planned
- S5.4.2 Configurator.vue ✅ planned
- S5.4.3 QuoteCreate.vue ✅ planned
- S5.4.4 Store 模块 ✅ planned
- S5.4.5 通用组件 (CpqCard/StatusBadge/DataTable/EmptyState) ✅ planned (但 LoadingSkeleton/ErrorBoundary 未列出)
- S5.4.6 权限指令 (v-hasPermi/v-hasRole/v-cost-visibility) ✅ planned
- S5.4.7 MultiModalSearch.vue ✅ planned (任务存在但组件路径不对应设计)

S5.4 未覆盖前端设计中的大量组件: ConfigTree/BomPreview/GuidedWizard/PriceBreakdown/DiscountSlider/TemplateSelector/DeliveryKit/RadarChart/ComparisonMatrix/WaterfallChart/ApprovalNode/AtpIndicator/DeliveryTimeline/SolutionEditor/ReviewWorkbench/SceneNavigator 等。

---

## 七、阶段一 → 阶段二 → 阶段三 → 开发计划 纵向断层

### 7.1 五条全链路断层 (阶段一 P0 → 开发计划)

| # | 模块 | 阶段一 | 阶段二 | 阶段三 | 后端设计 | 开发计划 |
|:--:|------|:---:|:---:|:---:|:---:|:---:|
| 1 | **ECN/ECO** | P0 × 2 | ✅ 流程5 9步五级传播链 (唯一完整设计的非核心流程) | ❌ 无服务 | ✅ ruoyi-cpq-ecn | ❌ **全无** |
| 2 | **数据迁移** | P0 × 2 | ✅ 流程6 五阶段时间线 + 五维对账 | ❌ 无服务 | ✅ ruoyi-cpq-migration | ❌ **全无** |
| 3 | **竞品对标** | P0 × 2 | ❌ 无流程 (阶段一优先但未在阶段二展开) | ✅ S13 | ✅ ruoyi-cpq-competitive | ❌ **全无** |
| 4 | **售前协同** | P0 × 5 | ✅ 流程4 (4阶段10步) 含 CRDT | ✅ S12 (共享S11 DB) | ✅ ruoyi-cpq-solution 内合并 | ❌ **无** (S5 只有前端门户未区分售前) |
| 5 | **销售赋能/知识库** | P0 × 1 | ❌ 无 (阶段一 P0 但阶段二无流程无功能) | ❌ 无 | ✅ ruoyi-cpq-knowledge | ❌ **全无** |

### 7.2 两条支撑层断层

| # | 能力 | 阶段一 | 阶段二 | 阶段三 | 开发计划 |
|:--:|------|:---:|:---:|:---:|:---:|
| 6 | **多工厂产能分配** | 架构师单覆盖(改进项#3) | ✅ 12项P2功能 (改进项#3闭环) | ❌ (阶段三未提及) | ❌ 无 |
| 7 | **AI 能力** | P3 预留 | ✅ P2 4项 + P3 3项 + 架构图 | ❌ (阶段三未提及AI) | ❌ 无 |

### 7.3 阶段二独有但后续断层

阶段二精心设计了以下内容，在阶段三或开发计划中完全丢失:
- **向导式销售五状态机** (§3.3): 5 状态 + QuestionCard + RecommendPanel，阶段三无对应实现设计
- **方案编辑器协同编辑** (§3.4): Tiptap + Yjs + CRDT 协同光标 (8色)，无对应后端服务设计
- **CRDT 协同编辑后端服务**: 阶段二前端设计了 Yjs + y-websocket，但后端设计无对应 WebSocket 协同服务
- **消息队列体系**: 阶段三设计了 NATS + Pulsar 双层 (内部/外部)，实际开发使用 RuoYi SSE

---

## 八、流程覆盖度

阶段一 8 个核心使用场景 vs 阶段二 7 流程 vs 前端设计 7 页面流 vs 开发计划:

| 阶段一场景 | 阶段二流程 | 前端页面流 | 开发计划 |
|-----------|:---:|:---:|:---:|
| 1. 标准产品配置报价 | ✅ 流程1 (10步) | ✅ 页面流1 | Configurator + QuoteCreate (S5) ⏳ |
| 2. ATO定制配置 | ✅ 流程2 (15步) | ✅ 页面流2 | AtoCustomize (S5) ⏳ |
| 3. 海外多区域报价 | 未设计 | 未设计 | ❌ 无 |
| 4. 渠道自助报价 | ✅ 流程3 (12步) | ✅ 页面流3 | PartnerLayout (S5) ⏳ |
| 5. 项目型方案协同 | ✅ 流程4 (4阶段10步) | ✅ 页面流4 | SolutionEditor (S5 未列出) ❌ |
| 6. **竞品对标报价** | **未设计** | **未设计** | ❌ **全无** |
| 7. **售前协同方案** | ✅ 流程4 内 | ✅ 页面流4 内 | ❌ (合并到方案) |
| 8. 审批异常处理 | ✅ 流程7 (5分支) | ✅ 页面流7 | PendingApproval (S5 未列出) ❌ |

---

## 九、角色体系覆盖

### 9.1 12 角色在开发计划中的覆盖

| 角色 | 后端角色 SQL | 菜单分配 SQL | 前端 Dashboard | 状态 |
|------|:---:|:---:|:---:|:---:|
| 销售代表 | ✅ | ✅ (完整) | S5.4.1 ⏳ | ⏳ |
| 售前工程师 | ✅ | ✅ (基于销售+扩展) | S5.4.1 ⏳ | ⏳ |
| 销售经理 | ✅ | ❌ (开发计划标注"略") | S5.4.1 ⏳ | ⚠️ |
| 渠道合作伙伴 | ✅ | ❌ | S5.4.1 ⏳ | ⚠️ |
| 产品经理 | ✅ | ❌ | S5.4.1 ⏳ | ⚠️ |
| 定价管理员 | ✅ | ❌ | S5.4.1 ⏳ | ⚠️ |
| 供应链计划员 | ✅ | ❌ | S5.4.1 ⏳ | ⚠️ |
| 审批人 | ✅ | ❌ | S5.4.1 ⏳ | ⚠️ |
| 销售运营 | ✅ | ❌ | S5.4.1 ⏳ | ⚠️ |
| 高层管理者 | ✅ | ❌ | S5.4.1 ⏳ | ⚠️ |
| 外部审计 | ✅ | ❌ | S5.4.1 ⏳ | ⚠️ |
| 系统管理员 | ✅ | ✅ (全部) | S5.4.1 ⏳ | ⏳ |

**结论**: 12 角色定义完整 (角色 SQL + ABAC 策略已生成)，但 9 个角色的菜单分配 SQL 标注"略"，未给出具体分配。

### 9.2 开发计划审计遗留项

| ID | 发现 | 状态 |
|----|------|:---:|
| A1 | 菜单 component 路径不一致 | 待处理 |
| A2 | 9 个角色菜单分配缺失 | 待处理 |
| A3 | 8 个核心 Service 缺少接口契约 | 待处理 |
| A4 | 前端组件 Props/Events/Slots 规格缺失 | 待处理 |
| A8 | cpq-portal vs ruoyi-ui SSO 方案 | 已明确 (前端设计 §2.2.1) |
| A10 | 种子数据不足 | 待处理 |

---

## 十、差异化竞争力覆盖

阶段一 §3.6 定义 10 项 vs Salesforce/Oracle/SAP 的差异化能力，在开发计划中的覆盖:

| 差异化能力 | 开发计划状态 |
|-----------|:---:|
| SBOM→MBOM 内建全链路 | ✅ S2.2.1 BomExplosion |
| ATO 参数化配置原生支持 | ⏳ S3+S5 |
| ATP/CTP 三级交期内建 | ⏳ S5 |
| **售前协同工作台 (原生)** | ❌ |
| **竞品对标引擎 (原生)** | ❌ |
| **销售赋能工具 (原生)** | ❌ |
| **ECN/ECO 五级联动变更** | ❌ |
| **数据迁移工具 (内建)** | ❌ |
| ABAC 安全模型 (原生) | ⚠️ (表已建但未完整实现) |
| 部署灵活性 (公有云+私有化) | ❌ (私有化完全未涉及) |

**10 项差异化中 5 项完全缺失，1 项部分覆盖，2 项已规划，2 项已完成/部分完成。**

---

## 十一、优先级排序建议

### P0 — 核心业务完全缺失 (必须在 Sprint 3-5 补)

| # | 遗漏项 | 影响 |
|:--:|--------|------|
| 1 | **ECN/ECO 模块** (后端+前端) | 阶段二唯一有完整9步流程的非核心模块，产品变更同步关键 |
| 2 | **数据迁移模块** (后端+前端) | 实施落地前提，无此模块无法交付客户 |
| 3 | **售前协同模块** (后端 WebSocket + 前端 CRDT) | 12 页面前端设计完整，后端方案管理模块需扩展 |
| 4 | **竞品对标模块** (后端+前端 3 页面) | 差异化核心，阶段三有完整微服务设计可参考 |
| 5 | **销售赋能/知识库** (后端+前端 4 页面) | 销售用户高频使用的基础能力 |

### P1 — 设计完整但计划遗漏

| # | 遗漏项 | 依赖 |
|:--:|--------|------|
| 6 | 向导式销售前端 (GuidedSelling.vue) | 配置引擎 Service 完成后 |
| 7 | 方案编辑器前端 (SolutionEditor.vue + Yjs) | 后端协同服务 (WebSocket) |
| 8 | 定价管理 5 页面 (PriceBook/PriceRule/VolumeTier/Discount/Currency) | S3 DDL 执行后 |
| 9 | 审批管理 4 页面 | S4 DDL 执行后 |
| 10 | 系统设置 8 页面 (含 ECN + 数据迁移前端) | ECN+迁移模块后端先启动 |
| 11 | 集成连接器 4 页面 | S5 DDL 执行后 |
| 12 | 9 个角色的菜单分配 SQL 补全 | 角色体系闭环 |

### P2 — 长期规划

| # | 遗漏项 |
|:--:|--------|
| 13 | 多工厂产能分配 (12 项 P2 功能) |
| 14 | AI 能力 (7 项，P2 4项 + P3 3项) |
| 15 | 海外多区域报价场景 |
| 16 | 移动端专用视图开发 |
| 17 | 私有化部署方案 |
| 18 | K3s/HPA 容器化 |
| 19 | MySQL 替代 PG 的存储过程 / View / 分区 |

---

## 十二、总结

### 整体覆盖度

| 维度 | 已覆盖 | 待覆盖 | 缺失 |
|------|:---:|:---:|:---:|
| 15 功能模块 | 9 (60%) | 2 (13%) | 4 (27%) |
| 56 项 P0 功能 | 6 ✅ + 35 ⏳ (73%) | — | 14 (25%) |
| 8 核心 Service | 1 + 5 ⏳ (75%) | — | 2 (25%) |
| 43 张表 | 15 (35%) | 28 (65%) | — |
| ~60+ 前端页面/组件 | ~25 (42%) | 14 ⏳ (23%) | ~21 (35%) |
| 7 核心流程 | 5 (71%) | — | 2 (29%) |
| 12 角色 | 3 (25%) | 9 (75%) | — |
| 10 差异化能力 | 2 + 2 ⏳ (40%) | 1 (10%) | 5 (50%) |

### 最关键的三条发现

**1. ECN/ECO 模块全链路断层**: 阶段一 P0，阶段二设计最完整的流程 (9步五级传播链，含紧急/常规/策略三级 + 反向ECN)，后端设计有独立模块 ruoyi-cpq-ecn，但开发计划 0 任务。

**2. 5 项核心差异化能力无开发计划**: 售前协同、竞品对标、销售赋能、ECN/ECO、数据迁移这 5 项是 M-CPQ 区别于 Salesforce/Oracle/SAP 的核心竞争力，全部缺失将导致产品无法实现差异化定位。

**3. 阶段三产出大量无法复用**: Go + PostgreSQL 技术栈设计的 8 个 View、4 个 SP、CSP 求解器池化、K3s 部署、HPA 等需在 Java + MySQL 栈下重新设计实现。
