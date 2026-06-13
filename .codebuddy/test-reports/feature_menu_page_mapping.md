# 功能-菜单-页面对应关系清单

**依据文档**: `CPQ_前端门户设计.md` §1.1（双端分离架构）、§1.3（与RuoYi关系）、§3.1（菜单树结构）、§3.2（角色可见性）、§9.2（菜单扩展方案）  
**对比范围**: 设计文档规划 vs. 当前代码实际状态（ruoyi-ui + cpq-portal）  
**日期**: 2026-06-09

---

## 第一部分：设计文档的官方规划

### 1.1 双端定位（§1.1 + §1.3）

| 维度 | ruoyi-ui（Admin Portal） | cpq-portal（CPQ 业务门户） |
|------|--------------------------|---------------------------|
| **定位** | 系统管理后台 | CPQ 业务操作入口 |
| **使用者** | 系统管理员 / IT 运维 | 销售 / 售前 / 渠道 / 产品经理 / 审批人 / 定价管理员 / 供应链 / 高管等 |
| **内容** | 系统管理（用户/角色/菜单/部门/岗位/字典/参数）+ 监控（SpringBoot-Admin） | 全部 CPQ 业务功能页面 |
| **菜单来源** | sys_menu 表（RuoYi 原生菜单 + CPQ 菜单项） | sys_menu 表（复用 + 扩展） |
| **端口** | 80（dev）/ Nginx 统一域名（prod） | 3000（dev）/ Nginx 统一域名（prod） |
| **认证** | Sa-Token + JWT | 复用同一认证中心，SSO 同域共享 token |

### 1.2 cpq-portal 应有的完整菜单树（§3.1）

设计文档 §3.1 定义了 cpq-portal 侧边栏的完整菜单树，共计 14 个一级模块、50+ 个页面：

```
模块                  路由前缀         子页面（设计文档规划）
─────────────────────────────────────────────────────────────
🏠 首页工作台          /dashboard      我的工作台、我的报价单、待处理审批、我的任务
🔧 配置报价            /configure      产品搜索、新建标准配置、向导式配置、ATO定制配置、渠道自助配置
📋 报价管理            /quoting        报价单列表、新建报价、报价模板、已发送报价
📊 方案管理            /solution       方案列表、方案编辑器、方案对比、方案评审
✅ 审批中心            /approval       待我审批、我已审批、我发起的、审批效率看板
🤝 售前协同            /presales       任务看板、协同编辑、评审工作台
⚔️ 竞品对标            /competitive    竞品库、对比分析
📦 产品管理            /product        产品分类、产品目录、BOM管理、配置规则、替代品管理、捆绑包管理
💰 定价管理            /pricing        价格手册、定价规则、折扣审批
⏱️ 交期查询            /atpctp         交期检查、批量交期查询、交期SLA看板
📚 知识库              /knowledge      产品知识、销售话术、成功案例、培训认证
🔄 系统集成            /integration    CRM连接器、ERP连接器、PLM连接器、同步日志（仅管理员）
⚙️ 系统设置            /settings       租户配置、用户管理、角色管理、ABAC策略、审计日志、数据迁移、变更管理、系统参数
📱 个人中心            /profile        个人信息、消息通知、帮助文档
```

### 1.3 ruoyi-ui 应有的内容

按设计文档，ruoyi-ui（Admin Portal）**不承载 CPQ 业务页面**，只负责：
- RuoYi 系统管理：用户管理、角色管理、菜单管理、部门管理、岗位管理、字典管理、参数设置、通知公告、租户管理、租户套餐
- RuoYi 系统监控：在线用户、定时任务、数据监控、服务监控、缓存监控、缓存列表、SnailJob
- RuoYi 系统工具：代码生成、表单构建、系统接口
- RuoYi 工作流：流程定义、流程实例、任务管理、流程分类
- 菜单管理（sys_menu 的 CRUD 维护界面）

---

## 第二部分：实际代码状态 vs. 设计规划对比

### 2.1 sys_menu 表中的菜单分配现状

当前所有 46 个 CPQ 菜单（50000-50142）的 component 字段都指向 `ruoyi-ui/src/views/` 路径，但实际上这些页面的设计目标部署在 cpq-portal。

| menu_id | 菜单名称 | component | 设计应属 Portal | ruoyi-ui 有文件 | cpq-portal 有文件 |
|---------|---------|-----------|:---:|:---:|:---:|
| 50010 | 首页工作台 | NULL (目录) | cpq-portal | — | — |
| 50020 | 配置报价 | NULL (目录) | cpq-portal | — | — |
| 50021 | 产品搜索 | configure/ProductSearch | cpq-portal | ❌ | ✅ (实际) |
| 50022 | 新建标准配置 | configure/Configurator | cpq-portal | ❌ | ✅ (实际) |
| 50023 | 向导式配置 | configure/GuidedSelling | cpq-portal | ❌ | ❌ |
| 50024 | ATO定制配置 | configure/AtoCustomize | cpq-portal | ❌ | ❌ |
| 50030 | 报价管理 | NULL (目录) | cpq-portal | — | — |
| 50031 | 报价单列表 | quoting/QuoteList | cpq-portal | ❌ | ✅ (实际) |
| 50032 | 新建报价 | quoting/QuoteCreate | cpq-portal | ❌ | ❌ |
| 50033 | 报价模板 | quoting/TemplateManager | cpq-portal | ❌ | ❌ |
| 50040 | 方案管理 | NULL (目录) | cpq-portal | — | — |
| 50041 | 方案列表 | solution/SolutionList | cpq-portal | ❌ | ✅ (实际) |
| 50042 | 方案对比 | solution/SolutionCompare | cpq-portal | ❌ | ✅ (实际) |
| 50050 | 审批中心 | NULL (目录) | cpq-portal | — | — |
| 50051 | 待我审批 | approval/PendingApproval | cpq-portal | ❌ | ✅ (实际) |
| 50052 | 我已审批 | approval/ApprovalHistory | cpq-portal | ❌ | ✅ (实际) |
| 50053 | 我发起的 | approval/MyInitiated | cpq-portal | ❌ | ❌ |
| 50054 | 效率看板 | approval/ApprovalAnalytics | cpq-portal | ❌ | ❌ |
| 50060 | 售前协同 | NULL (目录) | cpq-portal | — | — |
| 50061 | 任务看板 | presales/TaskBoard | cpq-portal | ❌ | ❌ |
| 50062 | 评审工作台 | presales/ReviewWorkbench | cpq-portal | ❌ | ❌ |
| 50070 | 竞品对标 | NULL (目录) | cpq-portal | — | — |
| 50071 | 竞品库 | competitive/CompetitorList | cpq-portal | ❌ | ❌ |
| 50072 | 对比分析 | competitive/ComparisonView | cpq-portal | ❌ | ❌ |
| 50080 | 产品管理 | NULL (目录) | cpq-portal | — | — |
| 50081 | 产品目录 | cpq/catalog | cpq-portal | ✅ | ✅ (实际) |
| 50082 | 产品模型 | cpq/model | cpq-portal | ✅ | ❌ (有 ProductModel) |
| 50083 | 配置规则 | product/ConfigRuleManager | cpq-portal | ❌ | ✅ (实际，路径不同) |
| 50084 | 替代品管理 | cpq/supersession | cpq-portal | ✅ | ✅ (实际) |
| 50085 | 产品分类管理 | cpq/category | cpq-portal | ✅ | ❌ |
| 50090 | 定价管理 | NULL (目录) | cpq-portal | — | — |
| 50091 | 价格手册 | pricing/PriceBookList | cpq-portal | ❌ | ✅ (实际) |
| 50092 | 定价规则 | pricing/PriceRuleConfig | cpq-portal | ❌ | ✅ (实际) |
| 50093 | 阶梯定价 | pricing/VolumeTierConfig | cpq-portal | ❌ | ✅ (实际) |
| 50094 | 折扣审批 | pricing/DiscountApproval | cpq-portal | ❌ | ❌ |
| 50095 | 汇率配置 | pricing/CurrencyConfig | cpq-portal | ❌ | ✅ (实际) |
| 50100 | 交期查询 | NULL (目录) | cpq-portal | — | — |
| 50101 | 交期检查 | atpctp/AtpCheck | cpq-portal | ❌ | ✅ (实际) |
| 50102 | 批量查询 | atpctp/AtpBatch | cpq-portal | ❌ | ✅ (实际) |
| 50103 | SLA看板 | atpctp/SlaDashboard | cpq-portal | ❌ | ✅ (实际) |
| 50110 | 知识库 | NULL (目录) | cpq-portal | — | — |
| 50111 | 产品知识 | knowledge/ProductKnowledge | cpq-portal | ❌ | ❌ |
| 50112 | 销售话术 | knowledge/SalesScripts | cpq-portal | ❌ | ❌ |
| 50113 | 成功案例 | knowledge/CaseLibrary | cpq-portal | ❌ | ❌ |
| 50114 | 培训认证 | knowledge/TrainingCenter | cpq-portal | ❌ | ❌ |
| 50120 | 系统集成 | NULL (目录) | cpq-portal | — | — |
| 50121 | CRM连接器 | integration/CrmConnector | cpq-portal | ❌ | ❌ |
| 50122 | ERP连接器 | integration/ErpConnector | cpq-portal | ❌ | ❌ |
| 50123 | PLM连接器 | integration/PlmConnector | cpq-portal | ❌ | ❌ |
| 50124 | 同步日志 | integration/SyncLogViewer | cpq-portal | ❌ | ❌ |
| 50130 | 系统设置 | NULL (目录) | cpq-portal | — | — |
| 50131 | 租户配置 | settings/TenantConfig | cpq-portal | ❌ | ❌ |
| 50132 | 用户管理 | settings/UserManagement | cpq-portal | ❌ | ❌ |
| 50133 | 角色管理 | settings/RoleManagement | cpq-portal | ❌ | ❌ |
| 50134 | ABAC策略 | settings/AbacPolicyConfig | cpq-portal | ❌ | ❌ |
| 50135 | 审计日志 | settings/AuditLogViewer | cpq-portal | ❌ | ❌ |
| 50136 | 数据迁移 | settings/DataMigration | cpq-portal | ❌ | ❌ |
| 50137 | 变更管理 | settings/ChangeManagement | cpq-portal | ❌ | ✅ (实际) |
| 50138 | 系统参数 | settings/SystemParams | cpq-portal | ❌ | ❌ |
| 50140 | 个人中心 | NULL (目录) | cpq-portal | — | — |
| 50141 | 配置规则 | *(空)* | ⚠️异常 | ❌ | ❌ |
| 50142 | 捆绑包 | *(空)* | ⚠️异常 | ❌ | ❌ |

### 2.2 cpq-portal 当前实际已有页面

cpq-portal 的侧边栏菜单（`config/menu.ts`）仅定义了 12 个入口，远少于设计文档规划的 50+ 个：

| 侧边栏菜单项 | 路由 | 对应设计模块 | Vue 文件存在 |
|-------------|------|------------|:---:|
| 产品目录 | /catalog | 产品管理 | ✅ ProductCatalog.vue |
| BOM管理 | /bom | 产品管理（设计: BOM管理） | ✅ BomManager.vue |
| 捆绑包管理 | /bundle | 产品管理（设计: 捆绑包） | ✅ BundleManager.vue |
| 替代品管理 | /supersession | 产品管理（设计: 替代品） | ✅ SupersessionManager.vue |
| 配置规则 | /config | 产品管理（设计: 配置规则） | ✅ ConfigRuleManager.vue |
| 价格手册 | /pricing/book | 定价管理 | ✅ PriceBookList.vue |
| 定价规则 | /pricing/rule | 定价管理 | ✅ PriceRuleConfig.vue |
| 阶梯定价 | /pricing/volumetier | 定价管理（设计: 阶梯定价） | ✅ VolumeTierConfig.vue |
| 渠道价格 | /pricing/channelprice | 定价管理（设计额外） | ✅ ChannelPriceList.vue |
| 汇率配置 | /pricing/currencyrate | 定价管理（设计: 汇率配置） | ✅ CurrencyConfig.vue |
| 产品配置器 | /configure | 配置报价 | ✅ ProductSearch.vue |
| 报价单管理 | /quoting | 报价管理 | ✅ QuoteList.vue |
| 审批管理 | /approval | 审批中心 | ✅ PendingApproval.vue |

**cpq-portal 还有路由但不在侧边栏的页面**（通过内部导航进入）：
- `/configure/:modelId` → Configurator.vue（产品配置器参数化页面）
- `/quoting/:id` → QuoteDetail.vue（报价详情）
- `/quoting/:id/versions` → QuoteVersion.vue（版本对比）
- `/solution` → SolutionList.vue（方案列表）
- `/solution/:id/editor` → SolutionEditor.vue（方案编辑器）
- `/solution/:id/compare` → SolutionCompare.vue（方案对比）
- `/solution/:id/review` → SolutionReview.vue（方案评审）
- `/atp` → AtpCheck.vue（交期检查）
- `/atp/batch` → AtpBatch.vue（批量交期查询）
- `/atp/sla` → SlaDashboard.vue（SLA看板）
- `/ecn` → ChangeManagement.vue（ECN变更管理）
- `/ecn/:id/impact` → ImpactAnalysis.vue（影响分析）
- `/ecn/:id/approval` → ChangeApproval.vue（ECN审批）
- `/approval/:id` → ApprovalDetail.vue（审批详情）
- `/approval/history` → ApprovalHistory.vue（审批历史）
- `/approval/history/:id` → ApprovalDetail.vue

---

## 第三部分：差异分析

### 3.1 架构层面偏离

| 设计规定 | 实际代码 | 偏离程度 |
|---------|---------|:---:|
| cpq-portal 菜单从 sys_menu API 获取 | cpq-portal 使用静态 `config/menu.ts`，与 sys_menu 完全解耦 | 🔴 严重 |
| sys_menu 中的 CPQ 菜单供 cpq-portal 使用 | sys_menu 的 component 字段指向 ruoyi-ui 路径，cpq-portal 不消费 | 🔴 严重 |
| ruoyi-ui 不渲染 CPQ 业务页面 | ruoyi-ui 尝试渲染所有 46 个 CPQ 菜单，42 个显示"页面建设中" | 🔴 严重 |
| 两个应用通过 Nginx 同域部署，SSO 自然生效 | 两个应用都配置 port 3000，开发环境端口冲突 | 🟡 中等 |

### 3.2 cpq-portal 缺少的侧边栏模块

按设计文档，cpq-portal 当前侧边栏缺少以下模块的入口：

| 缺少的模块 | 涉及菜单数 | 当前有页面文件 | 说明 |
|-----------|:---:|:---:|------|
| 首页工作台 | 4 | ❌ | 无 dashboard 页面 |
| 方案管理 | 4 | ✅ | 有页面但不在侧边栏（通过内部链接进入） |
| 售前协同 | 3 | ❌ | 完全未开发 |
| 竞品对标 | 2 | ❌ | 完全未开发 |
| 交期查询 | 3 | ✅ | 有页面但不在侧边栏 |
| 知识库 | 4 | ❌ | 完全未开发 |
| 系统集成 | 4 | ❌ | 完全未开发（仅管理员） |
| 系统设置 | 8 | ❌ | 除 ECN 变更管理外均未开发 |
| 个人中心 | 0 | ❌ | 无独立页面 |

### 3.3 ruoyi-ui 中不应有的 CPQ 菜单

按设计文档，ruoyi-ui 不应渲染 CPQ 业务菜单，但目前 sys_menu 中所有 CPQ 菜单都被 ruoyi-ui 的动态路由加载尝试渲染。只有 4 个页面恰好在 ruoyi-ui 下有文件才能正常工作（cpq/catalog、cpq/model、cpq/category、cpq/supersession），其余全部回退到 placeholder。

---

## 第四部分：完整功能-菜单-页面-归属对照表

以下按照设计文档 §3.1 的模块顺序，列出每个功能的归属、菜单配置、页面实现状态。

### 4.1 配置报价模块

| 功能 | 设计归属 | menu_id | 菜单名称 | cpq-portal 页面路径 | 状态 |
|------|:---:|:---:|---------|---------|:---:|
| 产品搜索 | cpq-portal | 50021 | 产品搜索 | views/configure/ProductSearch.vue | ✅ 已实现 |
| 标准配置器 | cpq-portal | 50022 | 新建标准配置 | views/configure/Configurator.vue | ✅ 已实现 |
| 向导式配置 | cpq-portal | 50023 | 向导式配置 | views/configure/GuidedSelling.vue | ❌ 未开发 |
| ATO定制 | cpq-portal | 50024 | ATO定制配置 | views/configure/AtoCustomize.vue | ❌ 未开发 |

### 4.2 报价管理模块

| 功能 | 设计归属 | menu_id | 菜单名称 | cpq-portal 页面路径 | 状态 |
|------|:---:|:---:|---------|---------|:---:|
| 报价单列表 | cpq-portal | 50031 | 报价单列表 | views/quoting/QuoteList.vue | ✅ 已实现 |
| 报价详情 | cpq-portal | — | — | views/quoting/QuoteDetail.vue | ✅ 已实现（无独立菜单） |
| 版本对比 | cpq-portal | — | — | views/quoting/QuoteVersion.vue | ✅ 已实现（无独立菜单） |
| 新建报价 | cpq-portal | 50032 | 新建报价 | views/quoting/QuoteCreate.vue | ❌ 未开发 |
| 报价模板 | cpq-portal | 50033 | 报价模板 | — | ❌ 未开发 |

### 4.3 方案管理模块

| 功能 | 设计归属 | menu_id | 菜单名称 | cpq-portal 页面路径 | 状态 |
|------|:---:|:---:|---------|---------|:---:|
| 方案列表 | cpq-portal | 50041 | 方案列表 | views/solution/SolutionList.vue | ✅ 已实现 |
| 方案编辑器 | cpq-portal | — | — | views/solution/SolutionEditor.vue | ✅ 已实现（无独立菜单） |
| 方案对比 | cpq-portal | 50042 | 方案对比 | views/solution/SolutionCompare.vue | ✅ 已实现 |
| 方案评审 | cpq-portal | — | — | views/solution/SolutionReview.vue | ✅ 已实现（无独立菜单） |

### 4.4 审批中心模块

| 功能 | 设计归属 | menu_id | 菜单名称 | cpq-portal 页面路径 | 状态 |
|------|:---:|:---:|---------|---------|:---:|
| 待我审批 | cpq-portal | 50051 | 待我审批 | views/approval/PendingApproval.vue | ✅ 已实现 |
| 审批详情 | cpq-portal | — | — | views/approval/ApprovalDetail.vue | ✅ 已实现（无独立菜单） |
| 我已审批 | cpq-portal | 50052 | 我已审批 | views/approval/ApprovalHistory.vue | ✅ 已实现 |
| 我发起的 | cpq-portal | 50053 | 我发起的 | — | ❌ 未开发 |
| 效率看板 | cpq-portal | 50054 | 效率看板 | — | ❌ 未开发 |

### 4.5 售前协同模块

| 功能 | 设计归属 | menu_id | 菜单名称 | cpq-portal 页面路径 | 状态 |
|------|:---:|:---:|---------|---------|:---:|
| 任务看板 | cpq-portal | 50061 | 任务看板 | — | ❌ 未开发 |
| 评审工作台 | cpq-portal | 50062 | 评审工作台 | — | ❌ 未开发 |

### 4.6 竞品对标模块

| 功能 | 设计归属 | menu_id | 菜单名称 | cpq-portal 页面路径 | 状态 |
|------|:---:|:---:|---------|---------|:---:|
| 竞品库 | cpq-portal | 50071 | 竞品库 | — | ❌ 未开发 |
| 对比分析 | cpq-portal | 50072 | 对比分析 | — | ❌ 未开发 |

### 4.7 产品管理模块

| 功能 | 设计归属 | menu_id | 菜单名称 | 实际页面位置 | 状态 |
|------|:---:|:---:|---------|---------|:---:|
| 产品目录 | cpq-portal | 50081 | 产品目录 | cpq-portal: views/catalog/ProductCatalog.vue / ruoyi-ui: ✅ | ✅ |
| 产品模型 | cpq-portal | 50082 | 产品模型 | cpq-portal: views/product/ProductModel.vue / ruoyi-ui: ✅ | ✅ |
| 配置规则 | cpq-portal | 50083 | 配置规则 | cpq-portal: views/config/ConfigRuleManager.vue | ✅（menu component 指向错误路径） |
| 替代品管理 | cpq-portal | 50084 | 替代品管理 | cpq-portal: views/supersession/ / ruoyi-ui: ✅ | ✅ |
| 产品分类 | cpq-portal | 50085 | 产品分类管理 | ruoyi-ui: cpq/category/index.vue | ✅（cpq-portal 无） |
| BOM管理 | cpq-portal | — | — | cpq-portal: views/bom/BomManager.vue | ✅（无 sys_menu 条目） |
| 捆绑包 | cpq-portal | 50142 | 捆绑包 | cpq-portal: views/product/BundleManager.vue | ✅（menu_id 50142 component 为空） |

### 4.8 定价管理模块

| 功能 | 设计归属 | menu_id | 菜单名称 | cpq-portal 页面路径 | 状态 |
|------|:---:|:---:|---------|---------|:---:|
| 价格手册 | cpq-portal | 50091 | 价格手册 | views/pricing/PriceBookList.vue | ✅ |
| 定价规则 | cpq-portal | 50092 | 定价规则 | views/pricing/PriceRuleConfig.vue | ✅ |
| 阶梯定价 | cpq-portal | 50093 | 阶梯定价 | views/pricing/VolumeTierConfig.vue | ✅ |
| 折扣审批 | cpq-portal | 50094 | 折扣审批 | — | ❌ 未开发 |
| 汇率配置 | cpq-portal | 50095 | 汇率配置 | views/pricing/CurrencyConfig.vue | ✅ |

### 4.9 交期查询模块

| 功能 | 设计归属 | menu_id | 菜单名称 | cpq-portal 页面路径 | 状态 |
|------|:---:|:---:|---------|---------|:---:|
| 交期检查 | cpq-portal | 50101 | 交期检查 | views/atp/AtpCheck.vue | ✅ |
| 批量查询 | cpq-portal | 50102 | 批量查询 | views/atp/AtpBatch.vue | ✅ |
| SLA看板 | cpq-portal | 50103 | SLA看板 | views/atp/SlaDashboard.vue | ✅ |

### 4.10 知识库模块

| 功能 | 设计归属 | menu_id | 菜单名称 | cpq-portal 页面路径 | 状态 |
|------|:---:|:---:|---------|---------|:---:|
| 产品知识 | cpq-portal | 50111 | 产品知识 | — | ❌ 未开发 |
| 销售话术 | cpq-portal | 50112 | 销售话术 | — | ❌ 未开发 |
| 成功案例 | cpq-portal | 50113 | 成功案例 | — | ❌ 未开发 |
| 培训认证 | cpq-portal | 50114 | 培训认证 | — | ❌ 未开发 |

### 4.11 系统集成模块（仅管理员）

| 功能 | 设计归属 | menu_id | 菜单名称 | cpq-portal 页面路径 | 状态 |
|------|:---:|:---:|---------|---------|:---:|
| CRM连接器 | cpq-portal | 50121 | CRM连接器 | — | ❌ 未开发 |
| ERP连接器 | cpq-portal | 50122 | ERP连接器 | — | ❌ 未开发 |
| PLM连接器 | cpq-portal | 50123 | PLM连接器 | — | ❌ 未开发 |
| 同步日志 | cpq-portal | 50124 | 同步日志 | — | ❌ 未开发 |

### 4.12 系统设置模块（管理员+审计）

| 功能 | 设计归属 | menu_id | 菜单名称 | cpq-portal 页面路径 | 状态 |
|------|:---:|:---:|---------|---------|:---:|
| 租户配置 | cpq-portal | 50131 | 租户配置 | — | ❌ 未开发 |
| 用户管理 | cpq-portal | 50132 | 用户管理 | — | ❌ 未开发 |
| 角色管理 | cpq-portal | 50133 | 角色管理 | — | ❌ 未开发 |
| ABAC策略 | cpq-portal | 50134 | ABAC策略 | — | ❌ 未开发 |
| 审计日志 | cpq-portal | 50135 | 审计日志 | — | ❌ 未开发 |
| 数据迁移 | cpq-portal | 50136 | 数据迁移 | — | ❌ 未开发 |
| 变更管理(ECN) | cpq-portal | 50137 | 变更管理 | views/ecn/ChangeManagement.vue | ✅ |
| 系统参数 | cpq-portal | 50138 | 系统参数 | — | ❌ 未开发 |

### 4.13 ECN/ECO 变更模块

| 功能 | 设计归属 | menu_id | 菜单名称 | cpq-portal 页面路径 | 状态 |
|------|:---:|:---:|---------|---------|:---:|
| 变更管理 | cpq-portal | 50137 | 变更管理 | views/ecn/ChangeManagement.vue | ✅ |
| 影响分析 | cpq-portal | — | — | views/ecn/ImpactAnalysis.vue | ✅（无独立菜单） |
| 变更审批 | cpq-portal | — | — | views/ecn/ChangeApproval.vue | ✅（无独立菜单） |

### 4.14 首页工作台 & 个人中心

| 功能 | 设计归属 | menu_id | 菜单名称 | 状态 |
|------|:---:|:---:|---------|:---:|
| 首页工作台 | cpq-portal | 50010 | 首页工作台 | ❌ 未开发（设计文档规划了 11 种角色视图） |
| 个人中心 | cpq-portal | 50140 | 个人中心 | ❌ 未开发 |

---

## 第五部分：汇总统计

| 类别 | 数量 | 说明 |
|------|:---:|------|
| 设计规划总功能/页面数 | 50+ | cpq-portal 应有的全部页面 |
| cpq-portal 当前实际有页面文件 | 27 | 含侧边栏 13 个 + 内部路由 14 个 |
| cpq-portal 侧边栏入口数 | 13 | 仅覆盖设计规划约 40% 的模块 |
| cpq-portal 有文件但不在侧边栏 | 14 | 方案管理(4)、交期(3)、ECN(3)、报价详情/版本(2)、审批详情/历史(2) |
| 需新增 cpq-portal 页面 | 24+ | 售前协同/竞品对标/知识库/系统集成/系统设置/向导式/ATO/新建报价/报价模板/个人中心/工作台 |
| 需加入 cpq-portal 侧边栏 | 需决策 | 目前仅 13 项，是否扩展到全部模块 |
| ruoyi-ui 应保留的 CPQ 页面 | 0 | 按设计文档，所有 CPQ 页面应归属 cpq-portal |
| ruoyi-ui 当前多余的 CPQ 菜单 | 42 | 全部指向不存在的 component，应改为只保留 ruoyi-ui 系统管理菜单 |
| sys_menu 数据问题 | 2 | 50141/50142 parent_id 错误 + component 为空 |

---

## 第六部分：修复建议

### 6.1 根因修复：菜单架构对齐

**核心动作**：sys_menu 表中的 CPQ 菜单（50000-50142）是供 **cpq-portal** 使用的，不是 ruoyi-ui。需要：

1. **cpq-portal 改为从 sys_menu API 加载菜单**：替换 `config/menu.ts` 静态菜单，改为调用 `getRouters()` API 动态获取菜单树。这样 sys_menu 中定义的菜单才能真正生效。

2. **ruoyi-ui 排除 CPQ 菜单**：在 ruoyi-ui 的 `getRouters()` 处理中，过滤掉 menu_id ≥ 50000 的菜单（或通过 tenant/权限机制隔离），防止 ruoyi-ui 尝试渲染不存在于其 views 目录的 CPQ 页面。

### 6.2 短期快速修复（工作量最小）

保持两套应用独立，但解决"页面建设中"问题：

- **ruoyi-ui 侧**：将 42 个缺页菜单的 visible 设为 `1`（隐藏）或删除 sys_menu 中不属于 ruoyi-ui 的条目。只保留在 ruoyi-ui 中实际有页面的 4 个菜单。
- **cpq-portal 侧**：继续使用 `config/menu.ts` 管理菜单，不依赖 sys_menu。逐步补齐缺失页面。

### 6.3 中期完善方案

按设计文档补齐 cpq-portal 的侧边栏和页面：

| 优先级 | 模块 | 需要的动作 |
|:---:|------|-----------|
| P0 | 方案管理 | 加入侧边栏 ✅已有页面 |
| P0 | 交期查询 | 加入侧边栏 ✅已有页面 |
| P0 | ECN 变更管理 | 加入侧边栏 ✅已有页面 |
| P0 | BOM管理 | 已有 sys_menu 条目 (待创建) |
| P0 | 捆绑包 | 修复 50142 component |
| P1 | 审批中心 | 补全"我发起的"+"效率看板" |
| P1 | 配置报价 | 补全"向导式配置"+"ATO定制" |
| P1 | 报价管理 | 补全"新建报价"+"报价模板" |
| P1 | 系统设置 | 补全用户/角色/租户/ABAC/审计/迁移/参数（可复用 RuoYi 现有页面逻辑） |
| P2 | 售前协同 | 完整开发 |
| P2 | 竞品对标 | 完整开发 |
| P2 | 知识库 | 完整开发 |
| P2 | 系统集成 | 完整开发 |
| P2 | 首页工作台 | 完整开发 |
