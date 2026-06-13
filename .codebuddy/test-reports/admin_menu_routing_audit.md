# Admin Portal 菜单路由全面审计报告

**审计日期**: 2026-06-09  
**审计范围**: `sys_menu` 表中所有 CPQ 相关菜单（menu_id: 50000-50142）→ 对应前端 Vue 组件文件  
**审计目标**: 找出所有显示"页面建设中"的菜单项，定位根因

---

## 总体概览

| 状态 | 数量 | 占比 |
|------|:----:|:----:|
| 路由正常（组件文件存在） | 4 | 8.7% |
| 显示"页面建设中" | 42 | 91.3% |
| **总计** | **46** | **100%** |

42 个"页面建设中"的菜单中：16 个在 `cpq-portal` 中有对应页面但不在 `ruoyi-ui` 中，24 个在两个项目中均无页面，2 个菜单无 component 定义。

---

## 第一部分：架构根因分析

项目存在**两套前端应用**，彼此独立：

1. **ruoyi-ui**（Admin Portal，`vite.config.ts` 端口 3000）：RuoYi-Vue-Plus 管理后台，动态路由从数据库 `sys_menu` 表加载。`loadView()`（permission.ts）将 component 字段解析为 `ruoyi-ui/src/views/` 下的 `.vue` 文件。文件不存在时组件为 `undefined`，页面无法渲染，或由 `router/index.ts` 的 `resolveComponent()` 回退到 `placeholder/index.vue`（显示"页面建设中"）。

2. **cpq-portal**（CPQ 业务应用，`vite.config.ts` 端口也是 3000）：独立的业务前端，有自己的 `router/index.ts` 和侧边栏菜单 `config/menu.ts`，**完全不依赖** `sys_menu` 表。页面文件位于 `cpq-portal/src/views/`。

**核心问题**：`sys_menu` 表中所有 46 个 CPQ 菜单的 component 字段都指向 `ruoyi-ui/src/views/` 下的路径。但只有 4 个页面真正放在那里。其余约 40 个页面的 Vue 文件要么在 `cpq-portal/` 中（两个项目文件不共享），要么根本不存在于任何项目中。

**次要问题**：两个应用都配置了 `port: 3000`，同时启动会产生端口冲突。

---

## 第二部分：菜单逐项审计

### A. 路由正常 — 4 项（component 文件存在于 ruoyi-ui/src/views/）

| menu_id | 菜单名称 | component | 实际文件 |
|---------|---------|-----------|---------|
| 50081 | 产品目录 | cpq/catalog | ruoyi-ui/src/views/cpq/catalog/index.vue |
| 50082 | 产品模型 | cpq/model | ruoyi-ui/src/views/cpq/model/index.vue |
| 50084 | 替代品管理 | cpq/supersession | ruoyi-ui/src/views/cpq/supersession/index.vue |
| 50085 | 产品分类管理 | cpq/category | ruoyi-ui/src/views/cpq/category/index.vue |

### B. "页面建设中" — 42 项

#### B1. 页面存在于 cpq-portal 但未同步到 ruoyi-ui — 16 项

这些页面的 Vue 文件在 `cpq-portal/src/views/` 下已开发完成，但 Admin Portal 的 `ruoyi-ui/src/views/` 中没有对应文件，导致菜单点击后显示"页面建设中"。

| menu_id | 菜单名称 | sys_menu component | cpq-portal 实际文件 |
|---------|---------|-------------------|-------------------|
| 50021 | 产品搜索 | configure/ProductSearch | cpq-portal/src/views/configure/ProductSearch.vue |
| 50022 | 新建标准配置 | configure/Configurator | cpq-portal/src/views/configure/Configurator.vue |
| 50031 | 报价单列表 | quoting/QuoteList | cpq-portal/src/views/quoting/QuoteList.vue |
| 50041 | 方案列表 | solution/SolutionList | cpq-portal/src/views/solution/SolutionList.vue |
| 50042 | 方案对比 | solution/SolutionCompare | cpq-portal/src/views/solution/SolutionCompare.vue |
| 50051 | 待我审批 | approval/PendingApproval | cpq-portal/src/views/approval/PendingApproval.vue |
| 50052 | 我已审批 | approval/ApprovalHistory | cpq-portal/src/views/approval/ApprovalHistory.vue |
| 50083 | 配置规则 | product/ConfigRuleManager | cpq-portal/src/views/config/ConfigRuleManager.vue |
| 50091 | 价格手册 | pricing/PriceBookList | cpq-portal/src/views/pricing/PriceBookList.vue |
| 50092 | 定价规则 | pricing/PriceRuleConfig | cpq-portal/src/views/pricing/PriceRuleConfig.vue |
| 50093 | 阶梯定价 | pricing/VolumeTierConfig | cpq-portal/src/views/pricing/VolumeTierConfig.vue |
| 50095 | 汇率配置 | pricing/CurrencyConfig | cpq-portal/src/views/pricing/CurrencyConfig.vue |
| 50101 | 交期检查 | atpctp/AtpCheck | cpq-portal/src/views/atp/AtpCheck.vue |
| 50102 | 批量查询 | atpctp/AtpBatch | cpq-portal/src/views/atp/AtpBatch.vue |
| 50103 | SLA看板 | atpctp/SlaDashboard | cpq-portal/src/views/atp/SlaDashboard.vue |
| 50137 | 变更管理 | settings/ChangeManagement | cpq-portal/src/views/ecn/ChangeManagement.vue |

**说明**：这 16 个菜单的 component 路径与 cpq-portal 中的实际目录结构不完全一致（例如 menu 用的 `atpctp/` 但 cpq-portal 用的 `atp/`，menu 用的 `product/` 但 cpq-portal 用的 `config/`，menu 用的 `settings/` 但 cpq-portal 用的 `ecn/`），即使复制文件也需要修正路径或修改菜单 component 值。

#### B2. 两个项目中均不存在页面 — 24 项（完全缺失）

| menu_id | 菜单名称 | component | 所属模块 |
|---------|---------|-----------|---------|
| 50023 | 向导式配置 | configure/GuidedSelling | 配置报价 |
| 50024 | ATO定制配置 | configure/AtoCustomize | 配置报价 |
| 50032 | 新建报价 | quoting/QuoteCreate | 报价管理 |
| 50033 | 报价模板 | quoting/TemplateManager | 报价管理 |
| 50053 | 我发起的 | approval/MyInitiated | 审批中心 |
| 50054 | 效率看板 | approval/ApprovalAnalytics | 审批中心 |
| 50061 | 任务看板 | presales/TaskBoard | 售前协同 |
| 50062 | 评审工作台 | presales/ReviewWorkbench | 售前协同 |
| 50071 | 竞品库 | competitive/CompetitorList | 竞品对标 |
| 50072 | 对比分析 | competitive/ComparisonView | 竞品对标 |
| 50094 | 折扣审批 | pricing/DiscountApproval | 定价管理 |
| 50111 | 产品知识 | knowledge/ProductKnowledge | 知识库 |
| 50112 | 销售话术 | knowledge/SalesScripts | 知识库 |
| 50113 | 成功案例 | knowledge/CaseLibrary | 知识库 |
| 50114 | 培训认证 | knowledge/TrainingCenter | 知识库 |
| 50121 | CRM连接器 | integration/CrmConnector | 系统集成 |
| 50122 | ERP连接器 | integration/ErpConnector | 系统集成 |
| 50123 | PLM连接器 | integration/PlmConnector | 系统集成 |
| 50124 | 同步日志 | integration/SyncLogViewer | 系统集成 |
| 50131 | 租户配置 | settings/TenantConfig | 系统设置 |
| 50132 | 用户管理 | settings/UserManagement | 系统设置 |
| 50133 | 角色管理 | settings/RoleManagement | 系统设置 |
| 50134 | ABAC策略 | settings/AbacPolicyConfig | 系统设置 |
| 50135 | 审计日志 | settings/AuditLogViewer | 系统设置 |
| 50136 | 数据迁移 | settings/DataMigration | 系统设置 |
| 50138 | 系统参数 | settings/SystemParams | 系统设置 |

**说明**：这 26 个（含 B3 的 2 个）菜单的后端 API 大多已开发并通过 E2E 测试（S9-S12 全部 25 项 API 测试通过率 100%），但前端 Vue 页面尚未创建。涉及的模块有：配置报价、报价管理、审批中心、售前协同、竞品对标、定价管理、知识库、系统集成、系统设置。

#### B3. 菜单缺少 component 定义 — 2 项

| menu_id | 菜单名称 | parent_id | component | 问题 |
|---------|---------|:---------:|-----------|------|
| 50141 | 配置规则 | 50000 | *(空)* | 无 component，且 parent_id=50000（应归入 50080 产品管理） |
| 50142 | 捆绑包 | 50000 | *(空)* | 无 component，且 parent_id=50000（应归入 50080 产品管理） |

---

## 第三部分：按模块分组汇总

| 模块 | 菜单数 | 正常 | B1(cpq-portal有) | B2(完全缺失) | B3(无component) |
|------|:---:|:---:|:---:|:---:|:---:|
| 首页工作台 | 1 | 0 | 0 | 1 (dashboard) | — |
| 配置报价 | 4 | 0 | 2 | 2 | — |
| 报价管理 | 3 | 0 | 1 | 2 | — |
| 方案管理 | 2 | 0 | 2 | 0 | — |
| 审批中心 | 4 | 0 | 2 | 2 | — |
| 售前协同 | 2 | 0 | 0 | 2 | — |
| 竞品对标 | 2 | 0 | 0 | 2 | — |
| 产品管理 | 5 | 4 | 1(gap) | 0 | 0 |
| 定价管理 | 5 | 0 | 3 | 1 | — |
| 交期查询 | 3 | 0 | 3 | 0 | — |
| 知识库 | 4 | 0 | 0 | 4 | — |
| 系统集成 | 4 | 0 | 0 | 4 | — |
| 系统设置 | 8 | 0 | 1 | 6 | — |
| 个人中心 | 0* | — | — | — | — |
| 孤立菜单 | 2 | 0 | 0 | 0 | 2 |

*个人中心（50140）为目录型菜单（M 类型），无子菜单。

---

## 第四部分：修复建议

### 优先级 P0（立即修复 — 影响核心业务流程）

1. **方案管理**（50041/50042）：cpq-portal 已有完整页面，可复制到 ruoyi-ui 或建立 iframe 路由
2. **交期查询**（50101/50102/50103）：cpq-portal 已有完整页面，同上
3. **定价管理**（50091/50092/50093/50095）：cpq-portal 已有完整页面，同上
4. **产品搜索/配置**（50021/50022）：cpq-portal 已有页面

### 优先级 P1（需要开发新页面 — 后端 API 已就绪）

以下模块的后端 API 已在 S9-S12 中通过 E2E 测试（100%），只需开发前端 Vue 页面：

- **审批中心**：50053（我发起的）、50054（效率看板）
- **报价管理**：50032（新建报价）、50033（报价模板）
- **系统设置**：50131-50136、50138 — 可复用 RuoYi 系统已有的用户/角色管理页面作为参考
- **ECN 变更管理**（50137）：cpq-portal 已有页面

### 优先级 P2（需要完整前后端开发）

以下模块对应的后端 API 和前端页面均未开发：

- **售前协同**（50061/50062）
- **竞品对标**（50071/50072）
- **知识库**（50111/50112/50113/50114）
- **系统集成**（50121/50122/50123/50124）

### 优先级 P3（菜单数据修正）

- 50141/50142：修正 parent_id 从 50000 → 50080，并添加 component 或删除
- 50083（配置规则）：`cpq-portal/src/views/cpq/product/` 为空目录，需创建或从 cpq-portal 迁移

---

## 第五部分：架构建议

当前两套前端（ruoyi-ui + cpq-portal）分离的架构导致菜单维护困难。建议长期方案三选一：

**方案 A：合并到 ruoyi-ui**  
将 cpq-portal 的页面全部迁移到 `ruoyi-ui/src/views/cpq/` 下，统一由 Admin Portal 管理菜单和路由。工作量较大但架构最清晰。

**方案 B：微前端嵌入**  
在 ruoyi-ui 中使用 iframe 或 qiankun/wujie 微前端方案嵌入 cpq-portal。菜单 component 改为 InnerLink 类型，path 指向 cpq-portal 部署地址。改动最小。

**方案 C：菜单分离**  
在 sys_menu 中只保留 ruoyi-ui 实际拥有的页面，其余菜单在 cpq-portal 内通过 `config/menu.ts` 独立管理。两个应用各自维护自己的菜单，不混用。

---

## 附录：数据库当前菜单完整清单

以下是从数据库直接查询的完整结果（`SELECT menu_id, menu_name, parent_id, path, component, menu_type, status FROM sys_menu WHERE menu_id >= 50000 ORDER BY menu_id`）：

```
50000  CPQ管理           parent=0      path=                   type=M
50010  首页工作台         parent=50000  path=/cpq/dashboard     type=M
50020  配置报价           parent=50000  path=/cpq/configure     type=M
50021  产品搜索           parent=50020  path=search     component=configure/ProductSearch      type=C
50022  新建标准配置       parent=50020  path=standard   component=configure/Configurator       type=C
50023  向导式配置         parent=50020  path=guided     component=configure/GuidedSelling      type=C
50024  ATO定制配置        parent=50020  path=ato        component=configure/AtoCustomize       type=C
50030  报价管理           parent=50000  path=/cpq/quoting       type=M
50031  报价单列表         parent=50030  path=list       component=quoting/QuoteList             type=C
50032  新建报价           parent=50030  path=create     component=quoting/QuoteCreate           type=C
50033  报价模板           parent=50030  path=templates  component=quoting/TemplateManager       type=C
50040  方案管理           parent=50000  path=/cpq/solution      type=M
50041  方案列表           parent=50040  path=list       component=solution/SolutionList          type=C
50042  方案对比           parent=50040  path=compare    component=solution/SolutionCompare       type=C
50050  审批中心           parent=50000  path=/cpq/approval      type=M
50051  待我审批           parent=50050  path=pending    component=approval/PendingApproval       type=C
50052  我已审批           parent=50050  path=processed  component=approval/ApprovalHistory       type=C
50053  我发起的           parent=50050  path=initiated  component=approval/MyInitiated           type=C
50054  效率看板           parent=50050  path=analytics  component=approval/ApprovalAnalytics     type=C
50060  售前协同           parent=50000  path=/cpq/presales      type=M
50061  任务看板           parent=50060  path=board      component=presales/TaskBoard             type=C
50062  评审工作台         parent=50060  path=review     component=presales/ReviewWorkbench       type=C
50070  竞品对标           parent=50000  path=/cpq/competitive   type=M
50071  竞品库             parent=50070  path=library    component=competitive/CompetitorList     type=C
50072  对比分析           parent=50070  path=compare    component=competitive/ComparisonView     type=C
50080  产品管理           parent=50000  path=/cpq/product       type=M
50081  产品目录           parent=50080  path=catalog    component=cpq/catalog                   type=C ✅
50082  产品模型           parent=50080  path=model      component=cpq/model                     type=C ✅
50083  配置规则           parent=50080  path=rules      component=product/ConfigRuleManager     type=C
50084  替代品管理         parent=50080  path=supersession component=cpq/supersession            type=C ✅
50085  产品分类管理       parent=50080  path=category   component=cpq/category                  type=C ✅
50090  定价管理           parent=50000  path=/cpq/pricing       type=M
50091  价格手册           parent=50090  path=books      component=pricing/PriceBookList          type=C
50092  定价规则           parent=50090  path=rules      component=pricing/PriceRuleConfig        type=C
50093  阶梯定价           parent=50090  path=volume     component=pricing/VolumeTierConfig       type=C
50094  折扣审批           parent=50090  path=discount   component=pricing/DiscountApproval       type=C
50095  汇率配置           parent=50090  path=currency   component=pricing/CurrencyConfig         type=C
50100  交期查询           parent=50000  path=/cpq/atpctp        type=M
50101  交期检查           parent=50100  path=check      component=atpctp/AtpCheck                type=C
50102  批量查询           parent=50100  path=batch      component=atpctp/AtpBatch                type=C
50103  SLA看板            parent=50100  path=sla        component=atpctp/SlaDashboard            type=C
50110  知识库             parent=50000  path=/cpq/knowledge     type=M
50111  产品知识           parent=50110  path=products   component=knowledge/ProductKnowledge     type=C
50112  销售话术           parent=50110  path=scripts    component=knowledge/SalesScripts         type=C
50113  成功案例           parent=50110  path=cases      component=knowledge/CaseLibrary          type=C
50114  培训认证           parent=50110  path=training   component=knowledge/TrainingCenter       type=C
50120  系统集成           parent=50000  path=/cpq/integration   type=M
50121  CRM连接器          parent=50120  path=crm        component=integration/CrmConnector       type=C
50122  ERP连接器          parent=50120  path=erp        component=integration/ErpConnector       type=C
50123  PLM连接器          parent=50120  path=plm        component=integration/PlmConnector       type=C
50124  同步日志           parent=50120  path=logs       component=integration/SyncLogViewer      type=C
50130  系统设置           parent=50000  path=/cpq/settings      type=M
50131  租户配置           parent=50130  path=tenant     component=settings/TenantConfig          type=C
50132  用户管理           parent=50130  path=users      component=settings/UserManagement        type=C
50133  角色管理           parent=50130  path=roles      component=settings/RoleManagement        type=C
50134  ABAC策略           parent=50130  path=abac       component=settings/AbacPolicyConfig      type=C
50135  审计日志           parent=50130  path=audit      component=settings/AuditLogViewer        type=C
50136  数据迁移           parent=50130  path=migration  component=settings/DataMigration         type=C
50137  变更管理           parent=50130  path=ecn        component=settings/ChangeManagement      type=C
50138  系统参数           parent=50130  path=params     component=settings/SystemParams          type=C
50140  个人中心           parent=50000  path=/cpq/profile       type=M
50141  配置规则           parent=50000  path=config     component=(空)                          type=C ⚠️
50142  捆绑包             parent=50000  path=bundle     component=(空)                          type=C ⚠️
```

**图例**：✅ = 路由正常，`⚠️` = 无 component 定义且 parent 不正确
