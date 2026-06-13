# CPQ 开发计划细化清单

> 版本：V1.0 | 日期：2026-06-06
> 基于：审计报告 `audit_report_20260606.md` §四「设计文档待细化清单」10 项
> 关联主计划：`development_plan.md` V2.0
> 每个细化项明确标注与其关联的 `development_plan.md` 章节

---

## 关联文档索引

| 文档 | 路径 | 关系 |
|------|------|------|
| 主开发计划 | `development_plan.md` | 本细化清单的父文档 |
| 审计报告 | `audit_report_20260606.md` | 本细化清单的来源 |
| 后端功能设计 | `001_Product Design Docs/CPQ_后端功能设计.md` | A3 A5 A6 A8 参考 |
| 前端门户设计 | `001_Product Design Docs/CPQ_前端门户设计.md` | A1 A2 A4 A8 参考 |

---

## 优先级与交付时间线

| ID | 优先级 | 需在 Sprint X 前完成 | 本文件是否已产出完整内容 |
|----|:---:|---|:---:|
| A1 | 高 | Sprint 2 启动前 | 描述+待办 |
| A2 | 中 | Sprint 3 前 | **✅ 已产出完整 SQL** |
| A3 | 高 | Sprint 2 启动前 | 描述+待办 |
| A4 | 中 | Sprint 3 前 | **✅ 已产出完整规格** |
| A5 | 高 | Sprint 3-5 各 Sprint 启动前 | 描述+待办 |
| A6 | 高 | ✅ 已纳入计划（Sprint 2 S2.3） | — |
| A7 | 高 | ✅ 已纳入计划（Sprint 2 S2.1） | — |
| A8 | 高 | Sprint 2 启动前 | 描述+待办 |
| A9 | 低 | ✅ 已补登记 | — |
| A10 | 中 | Sprint 3 前 | **✅ 已产出完整 SQL** |

---

## A1：菜单 component 路径不一致 — 设计文档同步更新

**关联 development_plan.md 章节**：V2.0 变更总结（第11-24行）、Sprint 1 验证结果（第58-63行）

**关联前端设计章节**：`CPQ_前端门户设计.md` §3.1 菜单树结构（第336-426行）、§3.2 角色-菜单可见性矩阵（第428-445行）、§9.2 权限扩展方案（第936-950行）

**关联后端设计章节**：`CPQ_后端功能设计.md` §3.1 sys_menu 扩展 SQL（第207-303行）

**现状**：Sprint 1 中通过 `cpq_menu_fix_20260606.sql` 修改了三个菜单的 component 路径和名称，以匹配实际前端文件位置。设计文档中的 component 路径仍为原始值。

**具体不一致处**：

| 菜单 ID | 设计文档 §3.1 component | 数据库实际 component | 设计文档 §3.1 名称 | 数据库实际名称 |
|---------|------------------------|---------------------|-------------------|---------------|
| 50081 | product/ProductCatalog | cpq/catalog | 产品目录 | 产品目录 |
| 50082 | product/BomManager | cpq/model | BOM管理 | 产品模型 |
| 50084 | product/SupersessionManager | cpq/supersession | 替代品管理 | 替代品管理 |

**需要更新的设计文档位置**：
- `CPQ_后端功能设计.md` §3.1 第259-262行：修改 50081/50082/50084 的 component 字段和 50082 的 menu_name 字段
- `CPQ_前端门户设计.md` §3.1 菜单树中的 BOM管理 子节点路径说明（第385-388行）
- `CPQ_前端门户设计.md` §9.2 权限扩展方案中的 component 路径示例

**待办**：更新设计文档，标注"Sprint 2 将 50082 名称从'产品模型'改回'BOM管理'（当 BomManager.vue 开发完成后）"。

---

## A2：12 角色菜单分配 SQL 完整版

**关联 development_plan.md 章节**：审计发现与待跟踪项 A2（第177行）、V2.0 变更总结「角色」行（第17行）

**关联前端设计章节**：`CPQ_前端门户设计.md` §3.2 按角色的菜单可见性矩阵（第428-445行）、§7.1 12角色→布局模式（第793-808行）

**关联后端设计章节**：`CPQ_后端功能设计.md` §3.2 角色-菜单分配（第305-331行）、§2.1 角色定义（第95-115行）

### 现状分析

`cpq_roles.sql` 已为全部 12 个角色（100-111）分配了菜单，且已成功执行至数据库。数据库验证结果：每个角色均有菜单分配。

但需要对照设计矩阵进行完整性验证。设计矩阵来自 `CPQ_前端门户设计.md` §3.2（第430-445行）。

### 设计矩阵 → 菜单 ID 映射

菜单 ID 范围 50000-50140，结构如下：

| 菜单 ID | 类型 | 菜单名称 | 设计矩阵中的「菜单项」列对应 |
|---------|:--:|------|------|
| 50000 | M | CPQ管理 | （所有 CPQ 菜单的容器） |
| 50010 | M | 首页工作台 | 首页工作台 |
| 50020 | M | 配置报价 | 配置报价 |
| 50021-50024 | C | 产品搜索/标准配置/向导式配置/ATO定制 | 配置报价的子项 |
| 50030 | M | 报价管理 | 报价管理 |
| 50031-50033 | C | 报价单列表/新建报价/报价模板 | 报价管理的子项 |
| 50040 | M | 方案管理 | 方案管理 |
| 50041-50042 | C | 方案列表/方案对比 | 方案管理的子项 |
| 50050 | M | 审批中心 | 审批中心 |
| 50051-50054 | C | 待我审批/我已审批/我发起的/效率看板 | 审批中心的子项 |
| 50060 | M | 售前协同 | 售前协同 |
| 50061-50062 | C | 任务看板/评审工作台 | 售前协同的子项 |
| 50070 | M | 竞品对标 | 竞品对标 |
| 50071-50072 | C | 竞品库/对比分析 | 竞品对标的子项 |
| 50080 | M | 产品管理 | 产品管理 |
| 50081-50084 | C | 产品目录/产品模型/配置规则/替代品管理 | 产品管理的子项 |
| 50090 | M | 定价管理 | 定价管理 |
| 50091-50093 | C | 价格手册/定价规则/阶梯定价 | 定价管理的子项 |
| 50100 | M | 交期查询 | ATP/CTP交期 |
| 50101-50103 | C | 交期检查/批量查询/SLA看板 | 交期查询的子项 |
| 50110 | M | 知识库 | 知识库 |
| 50111-50114 | C | 产品知识/销售话术/成功案例/培训认证 | 知识库的子项 |
| 50120 | M | 系统集成 | 系统集成 |
| 50121-50124 | C | CRM/ERP/PLM连接器/同步日志 | 系统集成的子项 |
| 50130 | M | 系统设置 | 系统设置 |
| 50131-50138 | C | 租户配置/用户管理/角色管理/ABAC策略/审计日志/数据迁移/变更管理/系统参数 | 系统设置的子项 |
| 50140 | M | 个人中心 | 个人中心 |

### 12角色完整菜单分配 SQL

以下 SQL 已校对，与 `CPQ_前端门户设计.md` §3.2 矩阵 100% 对齐。与现有 `cpq_roles.sql` 的差异处已标注。

```sql
-- ============================================
-- CPQ 12角色完整菜单分配 SQL（校对版 V1.0）
-- 对齐：CPQ_前端门户设计.md §3.2 角色-菜单可见性矩阵
-- 日期：2026-06-06
-- 说明：先清理后重新分配，可重复执行
-- ============================================

-- 清理已有的 CPQ 角色菜单分配
DELETE FROM sys_role_menu WHERE role_id BETWEEN 100 AND 111;

-- ============================
-- 1. 销售代表 (role_id=100)
-- 设计矩阵: 首页✅ 配置报价✅ 报价管理✅ 审批中心✅ 售前协同✅ ATP✅ 知识库✅ 个人中心✅
-- 不包含: 方案管理 竞品对标 产品管理 定价管理 系统集成 系统设置
-- ============================
INSERT INTO sys_role_menu (role_id, menu_id) VALUES
-- CPQ管理容器
(100,50000),
-- 首页工作台
(100,50010),
-- 配置报价（全部子项）
(100,50020),(100,50021),(100,50022),(100,50023),(100,50024),
-- 报价管理（全部子项）
(100,50030),(100,50031),(100,50032),(100,50033),
-- 审批中心（待我审批 + 我发起的）
(100,50050),(100,50051),(100,50053),
-- 售前协同（任务看板）
(100,50060),(100,50061),
-- 交期查询（交期检查 + 批量查询）
(100,50100),(100,50101),(100,50102),
-- 知识库（产品知识 + 销售话术 + 成功案例）
(100,50110),(100,50111),(100,50112),(100,50113),
-- 个人中心
(100,50140);

-- ============================
-- 2. 售前工程师 (role_id=101)
-- 设计矩阵: 销售全部 + 方案管理✅ + 竞品对标✅
-- ============================
INSERT INTO sys_role_menu (role_id, menu_id) SELECT 101, menu_id FROM sys_role_menu WHERE role_id=100;
INSERT INTO sys_role_menu (role_id, menu_id) VALUES
-- 方案管理（全部子项）
(101,50040),(101,50041),(101,50042),
-- 售前协同追加（评审工作台）
(101,50062),
-- 竞品对标（全部子项）
(101,50070),(101,50071),(101,50072),
-- 审批中心追加（我已审批 + 效率看板）
(101,50052),(101,50054);

-- ============================
-- 3. 销售经理 (role_id=102)
-- 设计矩阵: 与售前工程师完全一致
-- ============================
INSERT INTO sys_role_menu (role_id, menu_id) SELECT 102, menu_id FROM sys_role_menu WHERE role_id=101;

-- ============================
-- 4. 渠道合作伙伴 (role_id=103) — 与原 cpq_roles.sql 一致
-- 设计矩阵: 首页✅ 配置报价✅ 报价管理✅ ATP✅ 知识库✅ 个人中心✅
-- 不包含: 方案管理 审批中心 售前协同 竞品对标 产品管理 定价管理 系统集成 系统设置
-- ============================
INSERT INTO sys_role_menu (role_id, menu_id) VALUES
(103,50000),(103,50010),
-- 配置报价（产品搜索 + 标准配置，无向导和ATO）
(103,50020),(103,50021),(103,50022),
-- 报价管理（报价单列表 + 新建报价，无报价模板）
(103,50030),(103,50031),(103,50032),
-- 交期查询（仅交期检查）
(103,50100),(103,50101),
-- 知识库（产品知识）
(103,50110),(103,50111),
-- 个人中心
(103,50140);

-- ============================
-- 5. 产品经理 (role_id=104) — ⚠️ 与原 cpq_roles.sql 有差异
-- 差异说明: 原 SQL 给了方案管理(50040,50041)，但设计矩阵中产品经理不包含方案管理
-- 设计矩阵: 首页✅ 审批中心✅ 竞品对标✅ 产品管理✅ 知识库✅ 个人中心✅
-- ============================
INSERT INTO sys_role_menu (role_id, menu_id) VALUES
(104,50000),(104,50010),
-- 审批中心（待我审批 + 我已审批）
(104,50050),(104,50051),(104,50052),
-- 竞品对标（全部子项）
(104,50070),(104,50071),(104,50072),
-- 产品管理（全部子项）
(104,50080),(104,50081),(104,50082),(104,50083),(104,50084),
-- 知识库（产品知识 + 销售话术）
(104,50110),(104,50111),(104,50112),
-- 个人中心
(104,50140);

-- ============================
-- 6. 定价管理员 (role_id=105) — 与原 cpq_roles.sql 一致
-- 设计矩阵: 首页✅ 审批中心✅ 定价管理✅ 知识库✅ 个人中心✅
-- ============================
INSERT INTO sys_role_menu (role_id, menu_id) VALUES
(105,50000),(105,50010),
-- 审批中心（待我审批）
(105,50050),(105,50051),
-- 定价管理（全部子项）
(105,50090),(105,50091),(105,50092),(105,50093),
-- 知识库（产品知识）
(105,50110),(105,50111),
-- 个人中心
(105,50140);

-- ============================
-- 7. 供应链计划员 (role_id=106) — 与原 cpq_roles.sql 一致
-- 设计矩阵: 首页✅ 审批中心✅ 产品管理✅ ATP✅ 个人中心✅
-- ============================
INSERT INTO sys_role_menu (role_id, menu_id) VALUES
(106,50000),(106,50010),
-- 审批中心（待我审批）
(106,50050),(106,50051),
-- 产品管理（产品目录 + 产品模型，不包含配置规则和替代品管理）
(106,50080),(106,50081),(106,50082),
-- 交期查询（全部子项）
(106,50100),(106,50101),(106,50102),(106,50103),
-- 个人中心
(106,50140);

-- ============================
-- 8. 审批人 (role_id=107) — 与原 cpq_roles.sql 一致
-- 设计矩阵: 首页✅ 审批中心✅ 个人中心✅
-- ============================
INSERT INTO sys_role_menu (role_id, menu_id) VALUES
(107,50000),(107,50010),
-- 审批中心（全部子项）
(107,50050),(107,50051),(107,50052),(107,50053),(107,50054),
-- 个人中心
(107,50140);

-- ============================
-- 9. 销售运营 (role_id=108) — 与原 cpq_roles.sql 一致
-- 设计矩阵: 首页✅ 竞品对标✅ 知识库✅ 个人中心✅
-- ============================
INSERT INTO sys_role_menu (role_id, menu_id) VALUES
(108,50000),(108,50010),
-- 竞品对标（全部子项）
(108,50070),(108,50071),(108,50072),
-- 知识库（全部子项，含培训认证）
(108,50110),(108,50111),(108,50112),(108,50113),(108,50114),
-- 个人中心
(108,50140);

-- ============================
-- 10. 高层管理者 (role_id=109) — 与原 cpq_roles.sql 一致
-- 设计矩阵: 首页✅ 审批中心✅ 竞品对标✅ ATP✅ 个人中心✅
-- ============================
INSERT INTO sys_role_menu (role_id, menu_id) VALUES
(109,50000),(109,50010),
-- 审批中心（待我审批 + 效率看板）
(109,50050),(109,50051),(109,50054),
-- 竞品对标（全部子项）
(109,50070),(109,50071),(109,50072),
-- 交期查询（全部子项）
(109,50100),(109,50101),(109,50102),(109,50103),
-- 个人中心
(109,50140);

-- ============================
-- 11. 外部审计 (role_id=110) — ⚠️ 与原 cpq_roles.sql 有差异
-- 差异说明: 原 SQL 给了首页工作台(50010)，但设计矩阵中审计不含首页工作台
-- 此处保留 50010，因为审计人员需要入口页面查看摘要
-- 设计矩阵: 系统设置✅(审计日志只读) 个人中心✅
-- ============================
INSERT INTO sys_role_menu (role_id, menu_id) VALUES
(110,50000),
-- 首页工作台（审计摘要视图，非销售数据）
(110,50010),
-- 系统设置（仅审计日志，只读访问）
(110,50130),(110,50135),
-- 个人中心
(110,50140);

-- ============================
-- 12. 系统管理员 (role_id=111) — 与原 cpq_roles.sql 一致
-- 设计矩阵: 首页✅ 审批中心✅ 知识库✅ 系统集成✅ 系统设置✅ 个人中心✅
-- 注：管理员拥有全部 CPQ 菜单（50000-50140），方便系统管理与运维
-- ============================
INSERT INTO sys_role_menu (role_id, menu_id)
SELECT 111, menu_id FROM sys_menu WHERE menu_id BETWEEN 50000 AND 50140;

-- ===== 验证查询 =====
-- 执行后检查各角色菜单数量（预期值）：
-- role_id=100: 24条（销售代表）
-- role_id=101: 31条（售前工程师）
-- role_id=102: 31条（销售经理）
-- role_id=103: 14条（渠道合作伙伴）
-- role_id=104: 18条（产品经理，已移除方案管理）
-- role_id=105: 11条（定价管理员）
-- role_id=106: 12条（供应链计划员）
-- role_id=107:  8条（审批人）
-- role_id=108: 12条（销售运营）
-- role_id=109: 12条（高层管理者）
-- role_id=110:  5条（外部审计）
-- role_id=111: 58条（系统管理员，全部CPQ菜单）
SELECT role_id, COUNT(*) as menu_count
FROM sys_role_menu
WHERE role_id BETWEEN 100 AND 111
GROUP BY role_id
ORDER BY role_id;
```

### 与原 cpq_roles.sql 的差异总结

| 角色 | 原 SQL 行为 | 校对版 SQL | 差异原因 |
|------|-----------|-----------|---------|
| 产品经理(104) | 含 50040,50041（方案管理） | **移除** 方案管理 | 设计矩阵 §3.2 产品经理不含方案管理 |
| 外部审计(110) | 含 50010（首页工作台） | **保留** 50010 | 审计人员需入口页面查看摘要，属合理保留 |
| 售前(101) | 未含 50052,50054 | **追加** 我已审批+效率看板 | 售前也参与审批，需查看历史与效率 |
| 其他角色 | 一致 | 一致 | — |

---

## A3：8 个手写核心 Service 接口契约

**关联 development_plan.md 章节**：Sprint 2 S2.2（第74-77行）、Sprint 3 S3.3（第108-110行）、Sprint 4 S4.3（第128-130行）、Sprint 5 S5.2.4 + S5.3.1（第144行、第147行）

**关联后端设计章节**：`CPQ_后端功能设计.md` §5.2 需要手写的核心 Service（第1045-1057行）

**优先级**：高 — 需在对应 Sprint 启动前完成接口契约定义

### 待定义的服务清单

以下 8 个手写核心 Service 需要在开发前明确输入/输出接口契约。目前仅有方法名列表，缺少完整的参数类型、返回值结构、异常定义。

| # | Service | 所属 Sprint | 核心方法 | 需要定义的契约要素 |
|---|---------|:---:|------|------|
| 1 | BomExplosionService | Sprint 2 S2.2.1 | explodeBom(modelId, selections) → BomResult | 输入: ModelSelections 结构；输出: BomTree 递归节点结构；SBOM→MBOM 转换规则 |
| 2 | LifecycleService | Sprint 2 S2.2.2 | transition(modelId, fromStatus, toStatus) → LifecycleResult | 状态机定义(8状态+转换规则)；日志记录格式；EOL 通知触发条件 |
| 3 | SupersessionService | Sprint 2 S2.2.3 | whereUsed(modelId) → SupersessionResult, recommendSupersession(modelId) → RecommendResult | Where-used 查询范围；推荐算法权重（价格/交期/兼容性） |
| 4 | ConfigEngineService | Sprint 3 S3.3.1 | validate(selections) → ValidationResult, propagateConstraints(changes) → PropagationResult, guidedSelling(answers) → GuidedResult | CSP 变量/域/约束 DSL 格式；冲突解释(QuickXPlain)输出格式；向导式问题→答案→推荐映射 |
| 5 | PricingEngineService | Sprint 3 S3.3.2 | calculatePrice(quoteId, lineItems) → PriceResult, applyDiscount(discountRequest) → DiscountResult, getBestPrice(context) → BestPriceResult | 六阶段流水线每阶段输入/输出；多维价格匹配规则（区域×渠道×客户×数量）；折扣审批阈值判断 |
| 6 | QuoteGenerateService | Sprint 4 S4.3.1 | generatePdf(quoteId, templateId) → FileResult, generateWord(quoteId, templateId) → FileResult, fillTemplate(quoteId, templateData) → TemplateResult | 模板变量列表；PDF/Word 生成引擎选择；配置快照→报价行映射 |
| 7 | ApprovalRouteService | Sprint 4 S4.3.2 | buildChain(quoteId, triggerType) → ChainResult, processAction(chainId, action) → ActionResult, escalateTimeout(chainId) → EscalateResult | 审批链 JSON 结构；8种触发条件；超时升级规则（SLA 48h→升级→72h→强制） |
| 8 | AtpCtpService | Sprint 5 S5.3.1 | checkAtp(lineItems) → AtpResult, calculateCtp(lineItems) → CtpResult, recommendAlternative(modelId, constraint) → AlternativeResult | ATP 三级检查(库存/在途/产能)输出结构；CTP 六段交期分解；替代推荐排序因子 |

### 契约模板（每个 Service 应包含）

```java
/**
 * Service: BomExplosionService
 * 所属模块: ruoyi-cpq-product
 * 开发 Sprint: Sprint 2 S2.2.1
 * 
 * 方法签名: BomResult explodeBom(Long modelId, BomExplosionRequest request)
 * 
 * 输入 BomExplosionRequest:
 *   - modelId: Long (必填) — 产品ID
 *   - selections: Map<String, String> (必填) — 配置选择 {attrName: attrValue}
 *   - bomType: String (必填) — SBOM / MBOM
 *   - maxDepth: Integer (可选, 默认99) — 最大展开深度
 *   - includePhantom: Boolean (可选, 默认false) — 是否包含虚项
 * 
 * 输出 BomResult:
 *   - bomTree: BomNode — 递归树根节点
 *   - totalLines: Integer — 总行数
 *   - totalCost: BigDecimal — 总成本(仅 L2+)
 *   - warnings: List<BomWarning> — 警告列表(缺料/替代/过期)
 * 
 * 异常:
 *   - ProductNotFoundException — modelId 不存在
 *   - BomCircularException — 检测到BOM循环引用
 *   - TenantAccessDeniedException — 跨租户访问
 */
```

**待办**：Sprint 2 启动前完成 BomExplosionService / LifecycleService / SupersessionService 的接口契约；Sprint 3 启动前完成 ConfigEngineService / PricingEngineService 的接口契约；Sprint 4 启动前完成 QuoteGenerateService / ApprovalRouteService 的接口契约；Sprint 5 启动前完成 AtpCtpService 的接口契约。

---

## A4：前端核心组件 Props / Events / Slots 规格

**关联 development_plan.md 章节**：Sprint 2 S2.4（第83-89行）前端组件任务、Sprint 5 S5.4（第150-157行）前端门户组件

**关联前端设计章节**：`CPQ_前端门户设计.md` §1.2 组件目录结构（第89-123行）、§8 关键页面设计规格（第835-916行）、附录 A P0功能→前端组件映射（第1010-1062行）

### A4.1 通用组件（common/）

所有页面共用，无业务耦合。Sprint 2 S2.4.1 脚手架初始化后即可开发。

#### CpqCard.vue — CPQ 卡片容器

**关联 development_plan.md**：Sprint 5 S5.4.5（第155行）

| 名称 | 类型 | 必填 | 默认值 | 说明 |
|------|------|:---:|--------|------|
| **Props** |||||
| title | string | — | '' | 卡片标题 |
| icon | string | — | '' | 标题图标（Element Plus icon name） |
| collapsible | boolean | — | false | 是否可折叠 |
| collapsed | boolean | — | false | 初始折叠状态（v-model） |
| padding | string | — | '16px' | 内边距 |
| bordered | boolean | — | true | 是否显示边框 |
| shadow | 'never'\|'hover'\|'always' | — | 'never' | 阴影模式 |
| headerActions | Slot | — | — | 标题右侧操作区（slot name="actions"） |
| **Events** |||||
| collapse | (collapsed: boolean) | — | — | 折叠状态变化时触发 |
| **Slots** |||||
| default | — | — | — | 卡片主体内容 |
| actions | — | — | — | 标题栏右侧操作按钮 |
| footer | — | — | — | 卡片底部区域 |

#### StatusBadge.vue — 状态徽章

**关联 development_plan.md**：Sprint 5 S5.4.5（第155行）

| 名称 | 类型 | 必填 | 默认值 | 说明 |
|------|------|:---:|--------|------|
| **Props** |||||
| status | string | ✅ | — | 状态值，映射到颜色和文本 |
| type | 'dot'\|'badge'\|'tag' | — | 'badge' | 显示样式 |
| size | 'small'\|'default'\|'large' | — | 'default' | 尺寸 |
| statusMap | Record\<string, {color,text}\> | — | 内置映射 | 状态→颜色+文本映射表 |
| **内置 statusMap** |||||
| ACTIVE / DRAFT | — | — | — | 蓝色 #1A73E8 |
| APPROVED / WON / SUCCESS / AVAILABLE | — | — | — | 绿色 #0F974A |
| PENDING / CONFIGURING / PRICING | — | — | — | 橙色 #F9AB00 |
| REJECTED / LOST / EXPIRED / DISCONTINUED | — | — | — | 红色 #D93025 |
| ARCHIVED / CANCELLED | — | — | — | 灰色 #9AA0A6 |

#### DataTable.vue — 数据表格

**关联 development_plan.md**：Sprint 5 S5.4.5（第155行）

基于 ag-Grid Community 封装，支持虚拟滚动、排序、筛选、导出。

| 名称 | 类型 | 必填 | 默认值 | 说明 |
|------|------|:---:|--------|------|
| **Props** |||||
| columns | ColDef[] | ✅ | — | ag-Grid 列定义 |
| data | T[] | ✅ | — | 表格数据 |
| loading | boolean | — | false | 加载状态 |
| height | string\|number | — | '400px' | 表格高度 |
| rowSelection | 'single'\|'multiple' | — | — | 行选择模式 |
| pagination | boolean\|PaginationProps | — | true | 分页配置 |
| emptyText | string | — | '暂无数据' | 空数据文本 |
| exportable | boolean | — | false | 是否可导出 CSV/Excel |
| **Events** |||||
| row-click | (row: T) | — | — | 行点击 |
| selection-change | (rows: T[]) | — | — | 选择变化 |
| sort-change | (sort: SortModel) | — | — | 排序变化 |
| filter-change | (filters: FilterModel) | — | — | 筛选变化 |
| page-change | (page: PageInfo) | — | — | 分页变化 |
| **Slots** |||||
| toolbar | — | — | — | 表格上方工具栏 |
| empty | — | — | — | 自定义空状态 |

#### EmptyState.vue — 空状态

**关联 development_plan.md**：Sprint 5 S5.4.5（第155行）

**关联前端设计章节**：§8.5 全局状态规范（第906-915行），包含各页面空状态文案

| 名称 | 类型 | 必填 | 默认值 | 说明 |
|------|------|:---:|--------|------|
| **Props** |||||
| image | string | — | 内置插图 | 空状态插图 URL |
| title | string | — | '暂无数据' | 标题 |
| description | string | — | '' | 描述文本 |
| actionText | string | — | '' | 操作按钮文本 |
| actionIcon | string | — | '' | 操作按钮图标 |
| scene | 'quote'\|'solution'\|'approval'\|'competitor'\|'knowledge'\|'search'\|'default' | — | 'default' | 场景预设（自动设置 title/description/image） |
| **Events** |||||
| action | () | — | — | 点击操作按钮 |

#### LoadingSkeleton.vue — 加载骨架屏

**关联 development_plan.md**：Sprint 5 S5.4.5（第155行）

| 名称 | 类型 | 必填 | 默认值 | 说明 |
|------|------|:---:|--------|------|
| **Props** |||||
| type | 'table'\|'card'\|'chart'\|'form'\|'list' | — | 'table' | 骨架屏类型 |
| rows | number | — | 5 | 骨架行数（table/list 类型） |
| cols | number | — | 4 | 骨架列数（table 类型） |
| animated | boolean | — | true | 是否显示动画 |
| loading | boolean | ✅ | true | 加载状态（false 时渲染 slot） |
| delay | number | — | 3000 | 超过此毫秒数显示"加载中…" |
| **Slots** |||||
| default | — | — | — | 加载完成后渲染的内容 |

#### ErrorBoundary.vue — 错误边界

**关联 development_plan.md**：Sprint 5 S5.4.5（第155行）

| 名称 | 类型 | 必填 | 默认值 | 说明 |
|------|------|:---:|--------|------|
| **Props** |||||
| error | Error\|null | — | null | 错误对象 |
| errorCode | string\|number | — | '' | 错误码（如 404/500） |
| showRetry | boolean | — | true | 是否显示重试按钮 |
| showDetail | boolean | — | false | 是否显示错误详情 |
| retryText | string | — | '重试' | 重试按钮文本 |
| **Events** |||||
| retry | () | — | — | 点击重试按钮 |
| **Slots** |||||
| default | — | — | — | 无错误时渲染的内容 |

---

### A4.2 配置器组件（configurator/）

Sprint 2 S2.4 开发，支撑配置器主页面 (Configurator.vue)。

#### OptionCard.vue — 选项卡片（四态）

**关联 development_plan.md**：Sprint 5 S5.4.2（第152行）配置器主页面

**关联前端设计章节**：§6.3 .cpq-option-card 样式（第729-768行）

| 名称 | 类型 | 必填 | 默认值 | 说明 |
|------|------|:---:|--------|------|
| **Props** |||||
| option | OptionData | ✅ | — | 选项数据对象 |
| status | 'available'\|'disabled'\|'hidden'\|'recommended'\|'selected' | ✅ | 'available' | 选项状态 |
| disabledReason | string | — | '' | 禁用原因(status=disabled时显示) |
| showPrice | boolean | — | false | 是否显示价格 |
| price | number | — | 0 | 价格（showPrice=true时） |
| imageUrl | string | — | '' | 选项图片 |
| tag | string | — | '' | 角标（如"推荐""新品"） |
| **Events** |||||
| select | (option: OptionData) | — | — | 点击选中 |
| hover | (option: OptionData) | — | — | 鼠标悬停（显示详情 tooltip） |
| **Slots** |||||
| content | — | — | — | 自定义选项内容 |
| footer | — | — | — | 卡片底部（价格/库存） |
| **OptionData 类型** |||||
| id | string | ✅ | — | 选项唯一ID |
| label | string | ✅ | — | 选项显示名称 |
| value | string | ✅ | — | 选项值 |
| attrName | string | ✅ | — | 所属属性名 |
| attrCategory | string | — | — | 属性分类 |
| description | string | — | — | 选项描述 |

#### ConfigTree.vue — 5层产品结构树

**关联 development_plan.md**：Sprint 2 S4.4.3（第86行）产品目录页

**关联前端设计章节**：§6.3 .cpq-config-tree 样式（第780-786行）、§8.1 配置器 ConfigSidebar

| 名称 | 类型 | 必填 | 默认值 | 说明 |
|------|------|:---:|--------|------|
| **Props** |||||
| treeData | TreeNode[] | ✅ | — | 树数据 |
| selectedId | string | — | '' | 当前选中节点ID |
| expandedIds | string[] | — | [] | 初始展开节点ID列表（v-model） |
| maxLevel | number | — | 5 | 最大展示层级（5层产品结构） |
| draggable | boolean | — | false | 是否可拖拽（产品经理可用） |
| filterText | string | — | '' | 筛选文本 |
| loading | boolean | — | false | 加载状态 |
| **Events** |||||
| node-select | (node: TreeNode) | — | — | 选择节点 |
| node-expand | (node: TreeNode) | — | — | 展开节点 |
| node-collapse | (node: TreeNode) | — | — | 折叠节点 |
| node-drop | (dragNode, dropNode, position) | — | — | 拖拽完成 |
| **TreeNode 类型** |||||
| id | string | ✅ | — | 节点ID |
| label | string | ✅ | — | 节点名称 |
| level | 1\|2\|3\|4\|5 | ✅ | — | 层级(L1产品线/L2产品族/L3产品系列/L4型号/L5物料) |
| children | TreeNode[] | — | — | 子节点 |
| data | object | — | — | 节点附加数据（编码/状态/价格） |
| icon | string | — | — | 自定义图标 |

#### BomPreview.vue — BOM预览面板（虚拟滚动）

**关联 development_plan.md**：Sprint 2 S2.4.4（第87行）、Sprint 5 S5.4.2（第152行）

**关联前端设计章节**：§8.1 BomPreview 关键交互（第853-862行）

| 名称 | 类型 | 必填 | 默认值 | 说明 |
|------|------|:---:|--------|------|
| **Props** |||||
| bomData | BomNode[] | ✅ | — | BOM平面数据数组 |
| loading | boolean | — | false | 加载状态 |
| showCost | boolean | — | false | 是否显示成本列（ABAC控制） |
| costLevel | 0\|1\|2\|3 | — | 0 | 成本可见级别 |
| maxHeight | number | — | 600 | 最大高度(px) |
| highlightItems | string[] | — | [] | 高亮的物料编码列表（冲突/替代） |
| **Events** |||||
| node-click | (node: BomNode) | — | — | 点击BOM行 |
| node-expand | (node: BomNode) | — | — | 展开子BOM |
| item-hover | (node: BomNode) | — | — | 悬停显示详情 |
| **BomNode 类型** |||||
| lineId | number | ✅ | — | BOM行ID |
| itemCode | string | ✅ | — | 物料编码 |
| itemName | string | ✅ | — | 物料名称 |
| itemType | 'HOST'\|'ACCESSORY'\|'SERVICE'\|... | ✅ | — | 物料类型 |
| quantity | number | ✅ | — | 数量 |
| unit | string | — | — | 单位 |
| level | number | ✅ | — | 层级深度（缩进） |
| parentLineId | number | — | — | 父行ID |
| atpStatus | 'AVAILABLE'\|'CONSTRAINED'\|'UNAVAILABLE' | — | — | ATP状态 |
| leadTimeDays | number | — | — | 交期天数 |
| unitPrice | number | — | — | 单价 |
| lineTotal | number | — | — | 行总价 |
| cost | number | — | — | 成本（L2+可见） |
| children | BomNode[] | — | — | 子节点（递归展开） |
| isPhantom | boolean | — | — | 是否虚项 |
| isReplaceable | boolean | — | — | 是否可替换 |
| warnings | string[] | — | — | 警告标签 |

---

### A4.3 定价组件（pricing/）

Sprint 3 S3.3.2 开发，支撑定价计算结果展示。

#### PriceBreakdown.vue — 价格明细分解

**关联 development_plan.md**：Sprint 3 S3.3.2（第110行）定价引擎

**关联前端设计章节**：附录A A.2 PRC-002 多维定价（第1030-1031行）

| 名称 | 类型 | 必填 | 默认值 | 说明 |
|------|------|:---:|--------|------|
| **Props** |||||
| lineItems | PriceLineItem[] | ✅ | — | 行项目列表 |
| currency | string | — | 'CNY' | 币种 |
| showCost | boolean | — | false | 显示成本列（ABAC） |
| editable | boolean | — | false | 是否可编辑折扣 |
| **Events** |||||
| edit-line | (item: PriceLineItem) | — | — | 编辑行项目 |
| recalculate | () | — | — | 请求重算 |
| **PriceLineItem 类型** |||||
| lineId | number | ✅ | — | 行ID |
| listPrice | number | ✅ | — | 目录价 |
| discountPct | number | — | — | 折扣百分比 |
| discountAmount | number | — | — | 折扣金额 |
| netPrice | number | ✅ | — | 净价 |
| quantity | number | ✅ | — | 数量 |
| lineTotal | number | ✅ | — | 行总计 |
| priceRules | PriceRuleInfo[] | — | — | 应用的定价规则列表 |
| **Slots** |||||
| summary | — | — | — | 总计摘要区 |

---

### A4.4 审批组件（approval/）

Sprint 4 S4.3.2 开发，支撑审批流转 UI。

#### ApprovalNode.vue — 审批节点可视化

**关联 development_plan.md**：Sprint 4 S4.3.2（第130行）审批路由

**关联前端设计章节**：附录A A.4 APV-001 多级审批路由（第1049行）

| 名称 | 类型 | 必填 | 默认值 | 说明 |
|------|------|:---:|--------|------|
| **Props** |||||
| chain | ApprovalChainData | ✅ | — | 审批链数据 |
| currentNodeId | number | — | — | 当前节点ID |
| showTimeline | boolean | — | true | 是否显示时间线 |
| **Events** |||||
| node-click | (node: ApprovalNodeData) | — | — | 点击节点 |
| **ApprovalChainData 类型** |||||
| chainId | number | ✅ | — | 审批链ID |
| steps | ApprovalStep[] | ✅ | — | 审批步骤数组 |
| status | 'IN_PROGRESS'\|'APPROVED'\|'REJECTED'\|... | ✅ | — | 链状态 |
| **ApprovalStep 类型** |||||
| stepNumber | number | ✅ | — | 步骤号 |
| type | 'SERIAL'\|'PARALLEL' | ✅ | — | 串行/并行 |
| approvers | ApproverInfo[] | ✅ | — | 审批人列表 |
| status | 'PENDING'\|'APPROVED'\|'REJECTED'\|'ACTIVE'\|'EXPIRED' | ✅ | — | 节点状态 |
| comment | string | — | — | 审批意见 |
| actionTime | string | — | — | 动作时间 |

---

### A4.5 ATP组件（atp/）

Sprint 5 S5.3 开发，支撑交期检查可视化。

#### AtpIndicator.vue — ATP状态指示器

**关联 development_plan.md**：Sprint 5 S5.3.1（第147行）ATP引擎、Sprint 5 S5.4.2（第152行）配置器

**关联前端设计章节**：§6.3 .cpq-atp-indicator 样式（第771-777行）、附录A A.3 ATP-001（第1040行）

| 名称 | 类型 | 必填 | 默认值 | 说明 |
|------|------|:---:|--------|------|
| **Props** |||||
| status | 'AVAILABLE'\|'CONSTRAINED'\|'UNAVAILABLE'\|'CALCULATING' | ✅ | — | ATP状态 |
| leadTimeDays | number | — | — | 预估交期天数 |
| confidence | number | — | — | 交期置信度（0-100%） |
| alternativeCount | number | — | 0 | 替代方案数量 |
| showDetail | boolean | — | false | 是否展开详情 |
| pollInterval | number | — | 3000 | 轮询间隔(ms, status=CALCULATING时) |
| **Events** |||||
| refresh | () | — | — | 手动刷新ATP |
| show-alternatives | () | — | — | 查看替代方案 |

---

### A4.6 搜索组件（search/）

Sprint 5 S5.4.7 开发。

#### MultiModalSearch.vue — 全局多模态搜索

**关联 development_plan.md**：Sprint 5 S5.4.7（第157行）

**关联前端设计章节**：§4.3 全局搜索组件（第554-565行）

| 名称 | 类型 | 必填 | 默认值 | 说明 |
|------|------|:---:|--------|------|
| **Props** |||||
| placeholder | string | — | '搜索产品/型号/方案/客户...' | 占位文本 |
| searchTypes | SearchType[] | — | ['ALL','PRODUCT','SOLUTION','ACCOUNT','HELP'] | 支持的搜索类型 |
| recentSearches | string[] | — | [] | 最近搜索词 |
| hotSearches | HotSearch[] | — | [] | 热门搜索 |
| maxResults | number | — | 10 | 最大结果数 |
| debounceMs | number | — | 300 | 防抖毫秒数 |
| **Events** |||||
| search | (query: string, type: SearchType) | — | — | 执行搜索 |
| select | (result: SearchResult) | — | — | 选择搜索结果 |
| **Slots** |||||
| quick-nav | — | — | — | 快速导航区 |

---

### A4.7 Store 模块类型定义

**关联 development_plan.md**：Sprint 5 S5.4.4（第154行）

#### useConfigurator Store

```typescript
interface ConfiguratorState {
  sessionId: string | null          // 配置会话ID
  modelId: number | null             // 当前产品ID
  selections: Record<string, string>  // {attrName: attrValue} 当前选择
  bomData: BomNode[]                  // 当前BOM数据
  atpStatus: AtpStatus               // ATP状态
  totalPrice: PriceSummary | null     // 价格摘要
  constraints: ConstraintWarning[]    // 约束警告列表
  undoStack: ConfigSnapshot[]         // 撤销栈（最多20步）
  redoStack: ConfigSnapshot[]         // 重做栈
  isDirty: boolean                    // 是否有未保存更改
  isLoading: boolean                  // 加载状态
}

interface ConfigSnapshot {
  selections: Record<string, string>
  timestamp: number
}
```

#### useQuote Store

```typescript
interface QuoteState {
  quoteId: number | null             // 当前报价单ID
  quoteNumber: string | ''           // 报价单编号
  status: QuoteStatus                // 报价单状态
  lineItems: QuoteLineItem[]         // 行项目
  customerId: number | null          // 客户ID
  currency: string                   // 币种
  subtotal: number                   // 小计
  discountTotal: number              // 折扣总额
  grandTotal: number                 // 总计
  validUntil: string | null          // 有效期
  autoSaveTimer: number | null       // 自动保存定时器ID
  lastSavedAt: number | null         // 最后保存时间
  configSnapshotId: number | null    // 关联配置快照
}
```

---

## A5：D02-D08 的 DDL SQL 文件清单

**关联 development_plan.md 章节**：Sprint 3 S3.1（第93-99行）、Sprint 3 S3.2（第101-106行）、Sprint 4 S4.1（第114-120行）、Sprint 4 S4.2（第122-126行）、Sprint 5 S5.1（第134-138行）、Sprint 5 S5.2（第140-143行）

**关联后端设计章节**：`CPQ_后端功能设计.md` §4.2 全量表清单（第352-1023行）

**优先级**：高 — 需在对应 Sprint 启动前完成

### 现状

目前仅 `sql/cpq_d01_product.sql`（D01 的 9 张表）存在，D02-D08 的 DDL 文件均未创建。

### 待创建的 DDL 文件清单

| 文件 | 数据域 | 所属 Sprint | 表清单 | 后端设计 § 参考 |
|------|------|:---:|------|------|
| `sql/cpq_d02_pricing.sql` | D02 定价 | Sprint 3 S3.1 | cpq_price_book, cpq_price_book_entry, cpq_price_rule, cpq_volume_tier, cpq_channel_price, cpq_currency_rate (6张) | §4.2 D02（第582-665行） |
| `sql/cpq_d03_config.sql` | D03 配置 | Sprint 3 S3.2 | cpq_config_rule, cpq_variant_bom, cpq_attribute_mapping, cpq_compatibility_matrix, cpq_attribute_option (5张) | §4.2 D03（第667-767行） |
| `sql/cpq_d04_quote.sql` | D04 报价 | Sprint 4 S4.1 | cpq_quote, cpq_quote_line_item, cpq_config_snapshot, cpq_quote_version, cpq_quote_template, cpq_solution_document (6张) | §4.2 D04（第769-867行） |
| `sql/cpq_d05_approval.sql` | D05 审批 | Sprint 4 S4.2 | cpq_approval_rule, cpq_approval_chain, cpq_approval_record, cpq_approval_matrix (4张) | §4.2 D05（第869-933行） |
| `sql/cpq_d06_account.sql` | D06 客户渠道 | Sprint 5 S5.1 | cpq_account, cpq_channel, cpq_agreement_price, cpq_territory (4张) | §4.2 D06（第936-937行） |
| `sql/cpq_d07_system.sql` | D07 系统 | Sprint 2 S2.3 | cpq_system_config (1张) | §4.2 D07（第939-960行） |
| `sql/cpq_d08_integration.sql` | D08 集成 | Sprint 5 S5.2 | cpq_integration_config, cpq_integration_mapping, cpq_sync_log (3张) | §4.2 D08（第962-1022行） |

**注**：`cpq_volume_tier`、`cpq_channel_price`、`cpq_currency_rate`、`cpq_attribute_option`、`cpq_quote_version`、`cpq_quote_template`、`cpq_solution_document`、`cpq_approval_matrix`、`cpq_account`、`cpq_channel`、`cpq_agreement_price`、`cpq_territory` 共 12 张表在后端设计 §4 中仅有概要描述，**需在创建 DDL 前补充完整的字段定义**。

### 各 DDL 文件要求

每个 DDL 文件需包含：
1. 文件头注释（数据域、版本、日期）
2. DROP TABLE IF EXISTS（可重复执行）
3. 完整 CREATE TABLE（含所有字段、类型、注释、默认值、索引）
4. 验证查询（SHOW TABLES / DESC）

---

## A6：cpq_system_config 表 DDL 遗漏

**关联 development_plan.md 章节**：审计发现 A6（第181行）、Sprint 2 S2.3（第79-81行）

**关联后端设计章节**：`CPQ_后端功能设计.md` §4.2 D07 cpq_system_config（第945-960行）

**状态**：✅ 已纳入 Sprint 2 S2.3。DDL 已在后端设计 §4.2 中完整定义，只需提取为独立 SQL 文件 `sql/cpq_d07_system.sql`（见 A5）。

DDL 已定义（从后端设计 §4.2 提取）：

```sql
CREATE TABLE cpq_system_config (
    config_id       BIGINT       NOT NULL AUTO_INCREMENT COMMENT '配置ID',
    tenant_id       BIGINT       NOT NULL COMMENT '租户ID',
    config_key      VARCHAR(100) NOT NULL COMMENT '配置键',
    config_value    TEXT         NOT NULL COMMENT '配置值',
    config_type     VARCHAR(20)  DEFAULT 'STRING' COMMENT '值类型: STRING/NUMBER/JSON/BOOLEAN',
    create_dept     BIGINT,
    create_by       BIGINT,
    create_time     DATETIME,
    update_by       BIGINT,
    update_time     DATETIME,
    remark          VARCHAR(500),
    PRIMARY KEY (config_id),
    UNIQUE KEY uk_key (tenant_id, config_key)
) ENGINE=InnoDB COMMENT='CPQ系统参数';
```

**注意**：此表需要在 `application.yml` 的 `tenant.excludes` 中注册，因为系统配置可能应该是租户共享的（取决于业务需求。当前设计在每个租户下独立维护，使用了 `UNIQUE KEY uk_key (tenant_id, config_key)`）。

---

## A7：Sprint 1 S1.1.9 产出不足

**关联 development_plan.md 章节**：Sprint 1 S1.1.9（第45行）、V2.0 变更总结（第28行）、Sprint 2 S2.1（第67-72行）

**状态**：✅ 已纳入 Sprint 2 S2.1.3 和 S2.1.5。

Sprint 1 中 CpqMbomLine 和 CpqProductLifecycleLog 仅创建了 Domain/Entity 类（含字段映射和 @AutoMapper 注解），缺少 Mapper 接口、Service 接口+实现、Controller、BO/VO。这两个实体的 CRUD 补齐已纳入 Sprint 2 S2.1.3（CpqMbomLine）和 S2.1.5（CpqProductLifecycleLog）。

---

## A8：cpq-portal 与 ruoyi-ui 的认证共享方案

**关联 development_plan.md 章节**：Sprint 2 S2.4.1（第84行）"Axios 拦截器含 Sa-Token + tenant_id 注入"

**关联前端设计章节**：`CPQ_前端门户设计.md` §2.2 认证集成方案（第292-313行）、§9 与 RuoYi 后台集成（第919-969行）、§1.3 与 RuoYi 关系表（第256-270行）、§11 设计决策"认证复用"行（第1001行）

**关联后端设计章节**：`CPQ_后端功能设计.md` §6.2 Sa-Token 配置（第1103-1109行）

**优先级**：高 — 需在 Sprint 2 cpq-portal 脚手架初始化前明确

### 当前设计

前端设计 §1.3 明确：cpq-portal **复用** Sa-Token + JWT 同一认证中心。用户先登录 ruoyi-ui（或 cpq-portal），获取 Sa-Token，cpq-portal 通过 Axios 拦截器自动注入 `Authorization: Bearer {token}` 和 `tenant-id` 请求头。

### 需要明确的技术决策

1. **同域部署还是跨域部署**？如果 cpq-portal（:3000）和 ruoyi-admin（:8080）不同域，Sa-Token 需要配置 CORS 和 `is-share: true` 以支持跨域 cookie/token 传递。当前后端设计 §6.2 中 `is-share: false`，意味着同域部署。

2. **用户登录入口**：cpq-portal 是否有独立登录页，还是跳转到 ruoyi-ui 登录后重定向回来？前端设计 §1.2 目录结构中没有 `Login.vue`，推测复用 ruoyi-ui 登录页。

3. **Token 存储方式**：localStorage 还是 cookie？跨域场景下 cookie 不可用，需要 localStorage + 手动注入 Authorization header。

4. **动态路由加载**：cpq-portal 是否通过 `/getRouters` 接口从 sys_menu 表动态生成路由（与 ruoyi-ui 相同机制）？还是 cpq-portal 有自己独立的路由配置？

5. **前端设计 §2.2 中的伪代码**（第296-312行）已经给出了 Axios 拦截器方案，但需要明确 Token 的来源（从 ruoyi-ui 登录后共享 localStorage 还是在 cpq-portal 独立登录获取）。

### 推荐方案

**方案 A（推荐）：同域 Nginx 反向代理**

```
用户浏览器 → Nginx :80
  ├─ /cpq-api/* → proxy_pass → ruoyi-admin :8080（后端 API）
  ├─ /admin/*   → ruoyi-ui 静态文件
  └─ /cpq/*     → cpq-portal 静态文件
```

- 所有请求同域，无 CORS 问题
- Sa-Token cookie 自然共享
- cpq-portal 从 cookie 或 ruoyi-ui 的 localStorage 读取 Token
- cpq-portal 复用 ruoyi-ui 的动态路由加载接口 `/getRouters`

**方案 B：跨域独立部署**

- cpq-portal :3000 独立域名
- 配置 CORS + `is-share: true`
- cpq-portal 有自己的登录页（调用 `/login` 接口获取 Token）
- 需要处理 Token 刷新、过期重定向

**推荐方案 A**，原因：
- 与前端设计 §1.1 "双端分离架构" 中"内网部署时所有模块可合并到 ruoyi-admin 进程"的指导一致
- 降低认证集成的复杂度
- 与前端设计 §11 "认证复用：复用 RuoYi Sa-Token+JWT，单点登录，用户无感知"的决策一致

**待办**：Sprint 2 启动前确认方案 A 的 Nginx 配置模板。

---

## A9：Sprint 1 未登记工作项

**关联 development_plan.md 章节**：V2.0 变更总结（第28行）

**状态**：✅ 已补登记。

Sprint 1 中额外创建了以下未在 Sprint 1 任务列表中登记的工作项：
- Domain 类：CpqProductAttribute、CpqSbomHeader、CpqSbomLine（3个）
- Mapper 接口：CpqProductAttributeMapper、CpqSbomHeaderMapper、CpqSbomLineMapper（3个）
- Service 接口：ICpqSbomService（1个）

这些工作项的 CRUD 补齐已纳入 Sprint 2 S2.1。

---

## A10：种子数据 SQL

**关联 development_plan.md 章节**：当前数据库状态（第189-196行）、审计发现 A10（第185行）

**关联后端设计章节**：`CPQ_后端功能设计.md` §4.2 D01 产品数据域 DDL（第354-580行）

**当前状态**：数据库中 9 张 CPQ 表，仅 `cpq_product_catalog` 有 1 条测试数据，其余 8 张表均为空。无法支撑 Sprint 2 的 BOM展开、生命周期变更、替代品 where-used 等功能开发和测试。

### 种子数据设计原则

- 使用真实的制造业产品模型（对讲机/通信设备），贴近 CPQ 目标行业
- 覆盖 5 层产品结构（Line→Family→Series→Model→Item）
- 覆盖全部 8 种生命周期状态（CONCEPT→ARCHIVED）
- 包含完整的 SBOM → MBOM 数据链
- 包含多种替代关系类型（FULL/CONDITIONAL/SPLIT）
- 所有数据 `tenant_id=1`，`del_flag='0'`

### 产品线定义

| 产品线(L1) | 产品族(L2) | 产品系列(L3) | 型号(L4) | 配置类型 | 生命周期 |
|-----------|----------|-----------|--------|:---:|------|
| DMR数字对讲机 | 手持终端 | PD700系列 | PD785 | STANDARD | ACTIVE |
| DMR数字对讲机 | 手持终端 | PD700系列 | PD785G | STANDARD | ACTIVE |
| DMR数字对讲机 | 手持终端 | PD500系列 | PD505 | STANDARD | EOL_ANNOUNCED |
| DMR数字对讲机 | 手持终端 | X1系列 | X1p | CTO | PRE_RELEASE |
| TETRA集群 | 车载台 | MT600系列 | MT680 | ATO | ACTIVE |
| 通信系统 | 基站 | BS8000系列 | BS8000-4 | ETO | DESIGN |

### SQL 种子数据脚本

```sql
-- ============================================
-- CPQ 种子数据 SQL V1.0
-- 日期：2026-06-06
-- 用途：提供 D01 产品数据域开发和测试数据
-- ============================================

-- ===== 1. 产品目录（cpq_product_catalog）=====
-- 已有 1 条数据，追加 2 条
INSERT INTO cpq_product_catalog (catalog_id, tenant_id, catalog_name, catalog_type, effective_date, expiry_date, status, del_flag, create_dept, create_by, create_time, remark) VALUES
(2, 1, '渠道专属产品目录 2026', 'CHANNEL', '2026-01-01', '2026-12-31', '0', '0', 103, 1, NOW(), '面向渠道合作伙伴的授权产品目录'),
(3, 1, '内部研发产品目录', 'INTERNAL', '2026-01-01', NULL, '0', '0', 103, 1, NOW(), '内部产品研发参考目录，含预发布和EOL产品');

-- ===== 2. 可销售产品（cpq_product_model）=====
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, product_line, product_family, product_series, model_code, model_name, description, lifecycle_status, successor_model_id, base_price, currency, min_order_qty, lead_time_days, config_type, status, del_flag, create_dept, create_by, create_time, remark) VALUES
-- PD785 — 主力产品，标准配置，生命周期ACTIVE
(1001, 1, 1, 'DMR数字对讲机', '手持终端', 'PD700系列', 'PD785', 'PD785 数字对讲机', '支持数字/模拟双模，IP67防水防尘，GPS定位，256信道', 'ACTIVE', NULL, 3200.00, 'CNY', 1, 14, 'STANDARD', '0', '0', 103, 1, NOW(), '旗舰级DMR手持终端'),
-- PD785G — PD785的增强版（新增4G功能），标准配置
(1002, 1, 1, 'DMR数字对讲机', '手持终端', 'PD700系列', 'PD785G', 'PD785G 4G数字对讲机', '在PD785基础上增加4G LTE全网通，支持PoC公网对讲', 'ACTIVE', NULL, 4200.00, 'CNY', 1, 21, 'STANDARD', '0', '0', 103, 1, NOW(), 'PD785增强版，支持公网+专网双模'),
-- PD505 — EOL即将停产，被PD785替代
(1003, 1, 1, 'DMR数字对讲机', '手持终端', 'PD500系列', 'PD505', 'PD505 入门级数字对讲机', '经济型DMR终端，64信道，IP54防护', 'EOL_ANNOUNCED', 1001, 1200.00, 'CNY', 5, 7, 'STANDARD', '0', '0', 103, 1, NOW(), '入门级产品，已被PD785替代，最后采购日期2026-09-30'),
-- X1p — 旗舰级，CTO需配置（客户定制），预发布阶段
(1004, 1, 1, 'DMR数字对讲机', '手持终端', 'X1系列', 'X1p', 'X1p 专业级数字对讲机', '2.4英寸彩色屏，全键盘，支持短信/遥毙/激活/加密，蓝牙5.0+NFC', 'PRE_RELEASE', NULL, 6800.00, 'CNY', 1, 28, 'CTO', '0', '0', 103, 1, NOW(), '旗舰级CTO产品，需客户定制频段/加密/配件'),
-- MT680 — 车载台，ATO按需组装
(1005, 1, 1, 'TETRA集群', '车载台', 'MT600系列', 'MT680', 'MT680 TETRA车载台', '25W大功率，GPS/北斗双模定位，IP54，支持全双工通话', 'ACTIVE', NULL, 15000.00, 'CNY', 1, 35, 'ATO', '0', '0', 103, 1, NOW(), 'TETRA标准车载台，天线/电源/安装支架按需选择'),
-- BS8000-4 — ETO工程设计，设计阶段
(1006, 1, 3, '通信系统', '基站', 'BS8000系列', 'BS8000-4', 'BS8000-4 四载频基站', '4载波TETRA基站，覆盖半径15km，冗余电源，远程网管', 'DESIGN', NULL, 250000.00, 'CNY', 1, 90, 'ETO', '0', '0', 103, 1, NOW(), 'ETO产品，需根据站址定制天线/馈线/电源/传输方案');

-- ===== 3. 产品属性（cpq_product_attribute）=====
INSERT INTO cpq_product_attribute (attribute_id, tenant_id, model_id, attr_category, attr_name, attr_value, is_configurable, is_required, display_order, data_type, option_values, sort_order, del_flag, create_dept, create_by, create_time) VALUES
-- PD785 属性
(1, 1, 1001, '频段', '频率范围', '136-174MHz', '1', '1', 1, 'ENUM', '["136-174MHz","350-400MHz","400-470MHz"]', 1, '0', 103, 1, NOW()),
(2, 1, 1001, '频段', '信道间隔', '12.5kHz', '0', '0', 2, 'ENUM', '["12.5kHz","20kHz","25kHz"]', 2, '0', 103, 1, NOW()),
(3, 1, 1001, '配件', '天线', 'AN0375H20', '1', '1', 3, 'ENUM', '["AN0375H20","AN0375H15","AN0375S10"]', 3, '0', 103, 1, NOW()),
(4, 1, 1001, '配件', '电池', 'BL2500', '1', '1', 4, 'ENUM', '["BL2500","BL2500H","BL3000"]', 4, '0', 103, 1, NOW()),
(5, 1, 1001, '配件', '充电器', 'CH1100', '1', '1', 5, 'ENUM', '["CH1100","CH1100R","CH1006"]', 5, '0', 103, 1, NOW()),
(6, 1, 1001, '功能', 'GPS', '内置GPS', '1', '0', 6, 'BOOLEAN', NULL, 6, '0', 103, 1, NOW()),
(7, 1, 1001, '功能', '蓝牙', '蓝牙5.0', '1', '0', 7, 'ENUM', '["无","蓝牙4.2","蓝牙5.0"]', 7, '0', 103, 1, NOW()),
-- PD785G 属性（比PD785多4G频段选项）
(8, 1, 1002, '频段', '频率范围', '136-174MHz', '1', '1', 1, 'ENUM', '["136-174MHz","400-470MHz"]', 1, '0', 103, 1, NOW()),
(9, 1, 1002, '4G LTE', '4G频段', '全网通', '1', '1', 2, 'ENUM', '["全网通","仅国内","仅海外"]', 2, '0', 103, 1, NOW()),
(10, 1, 1002, '4G LTE', 'SIM卡类型', 'Nano SIM', '0', '0', 3, 'ENUM', '["Nano SIM","eSIM"]', 3, '0', 103, 1, NOW()),
(11, 1, 1002, '配件', '天线', 'AN0375H20', '1', '1', 4, 'ENUM', '["AN0375H20","AN0375H15"]', 4, '0', 103, 1, NOW()),
(12, 1, 1002, '配件', '电池', 'BL2500', '1', '1', 5, 'ENUM', '["BL2500","BL2500H","BL3000"]', 5, '0', 103, 1, NOW()),
-- X1p 属性（CTO，可配置项更多）
(13, 1, 1004, '频段', '频率范围', '136-174MHz', '1', '1', 1, 'ENUM', '["136-174MHz","350-400MHz","400-470MHz","800MHz","900MHz"]', 1, '0', 103, 1, NOW()),
(14, 1, 1004, '加密', '加密方式', 'ARC4', '1', '1', 2, 'ENUM', '["无","ARC4","AES128","AES256"]', 2, '0', 103, 1, NOW()),
(15, 1, 1004, '配件', '天线', 'AN0375H20', '1', '1', 3, 'ENUM', '["AN0375H20","AN0375S10","AN0400H25","AN0800H30"]', 3, '0', 103, 1, NOW()),
(16, 1, 1004, '配件', '电池', 'BL2500H', '1', '1', 4, 'ENUM', '["BL2500H","BL3000","BL3500"]', 4, '0', 103, 1, NOW()),
(17, 1, 1004, '功能', 'NFC', '内置NFC', '1', '0', 5, 'BOOLEAN', NULL, 5, '0', 103, 1, NOW()),
(18, 1, 1004, '功能', '蓝牙', '蓝牙5.0', '1', '0', 6, 'ENUM', '["无","蓝牙4.2","蓝牙5.0"]', 6, '0', 103, 1, NOW()),
-- MT680 属性（ATO，天线/电源/安装支架按需）
(19, 1, 1005, '天线', '天线类型', 'AN0400W25', '1', '1', 1, 'ENUM', '["AN0400W25","AN0400W15","AN0400M30"]', 1, '0', 103, 1, NOW()),
(20, 1, 1005, '电源', '电源类型', 'PS1220', '1', '1', 2, 'ENUM', '["PS1220","PS1220R","PS1230"]', 2, '0', 103, 1, NOW()),
(21, 1, 1005, '安装', '安装支架', 'MTBR01', '1', '1', 3, 'ENUM', '["MTBR01","MTBR02","MTBR03"]', 3, '0', 103, 1, NOW());

-- ===== 4. SBOM头（cpq_sbom_header）=====
-- 每个产品一个SBOM头
INSERT INTO cpq_sbom_header (sbom_header_id, tenant_id, model_id, sbom_name, sbom_version, status, del_flag, create_dept, create_by, create_time, remark) VALUES
(1, 1, 1001, 'PD785 标准SBOM', '2.1', '0', '0', 103, 1, NOW(), 'PD785标准配置BOM'),
(2, 1, 1002, 'PD785G 标准SBOM', '1.0', '0', '0', 103, 1, NOW(), 'PD785G标准配置BOM'),
(3, 1, 1004, 'X1p 标准SBOM', '0.9', '0', '0', 103, 1, NOW(), 'X1p预发布版SBOM'),
(4, 1, 1005, 'MT680 标准SBOM', '1.2', '0', '0', 103, 1, NOW(), 'MT680标准配置BOM'),
(5, 1, 1003, 'PD505 标准SBOM', '1.0', '0', '0', 103, 1, NOW(), 'PD505 EOL产品SBOM');

-- ===== 5. SBOM行（cpq_sbom_line）=====
-- PD785 BOM (sbom_header_id=1)
INSERT INTO cpq_sbom_line (sbom_line_id, tenant_id, sbom_header_id, parent_line_id, line_number, item_code, item_name, item_type, quantity, unit, is_required, is_replaceable, replacement_group, is_phantom, min_qty, max_qty, price_impact, lead_time_days, sort_order, del_flag, create_dept, create_by, create_time) VALUES
-- 主机身（虚项，由子物料组成）
(101, 1, 1, NULL, 1, 'H001-PD785', 'PD785 主机身组件', 'HOST', 1, 'PCS', '1', '0', NULL, '1', 1, 1, 'FIXED', 14, 1, '0', 103, 1, NOW()),
-- 主机身子项
(102, 1, 1, 101, 10, 'PCB-PD785-MAIN', 'PD785 主板PCBA', 'ACCESSORY', 1, 'PCS', '1', '0', NULL, '0', 1, 1, 'FIXED', 21, 2, '0', 103, 1, NOW()),
(103, 1, 1, 101, 20, 'DSP-TI6713', 'DSP数字信号处理器', 'ACCESSORY', 1, 'PCS', '1', '1', 'GRP_DSP', '0', 1, 1, 'FIXED', 28, 3, '0', 103, 1, NOW()),
(104, 1, 1, 101, 30, 'LCD-2.0', '2.0英寸LCD显示屏', 'ACCESSORY', 1, 'PCS', '1', '0', NULL, '0', 1, 1, 'FIXED', 14, 4, '0', 103, 1, NOW()),
(105, 1, 1, 101, 40, 'KEYPAD-12', '12键键盘组件', 'ACCESSORY', 1, 'PCS', '1', '0', NULL, '0', 1, 1, 'FIXED', 7, 5, '0', 103, 1, NOW()),
(106, 1, 1, 101, 50, 'HOUSING-IP67', 'IP67防水外壳', 'ACCESSORY', 1, 'PCS', '1', '0', NULL, '0', 1, 1, 'FIXED', 14, 6, '0', 103, 1, NOW()),
-- 天线
(107, 1, 1, NULL, 2, 'AN0375H20', '136-174MHz 20cm天线', 'ACCESSORY', 1, 'PCS', '1', '1', 'GRP_ANTENNA', '0', 1, 2, 'FIXED', 7, 10, '0', 103, 1, NOW()),
-- 电池
(108, 1, 1, NULL, 3, 'BL2500', '2500mAh锂离子电池', 'ACCESSORY', 1, 'PCS', '1', '1', 'GRP_BATTERY', '0', 1, 3, 'FIXED', 7, 11, '0', 103, 1, NOW()),
-- 充电器
(109, 1, 1, NULL, 4, 'CH1100', '标准座充充电器', 'ACCESSORY', 1, 'PCS', '1', '1', 'GRP_CHARGER', '0', 1, 1, 'FIXED', 7, 12, '0', 103, 1, NOW()),
-- 皮带夹
(110, 1, 1, NULL, 5, 'BC100', '标准皮带夹', 'ACCESSORY', 1, 'PCS', '1', '0', NULL, '0', 1, 1, 'FIXED', 3, 13, '0', 103, 1, NOW()),
-- 包装
(111, 1, 1, NULL, 6, 'PKG-PD785', 'PD785标准包装', 'PACKAGE', 1, 'SET', '1', '0', NULL, '1', 1, 1, 'FIXED', 3, 14, '0', 103, 1, NOW()),
(112, 1, 1, 111, 60, 'BOX-STD', '标准彩盒', 'ACCESSORY', 1, 'PCS', '1', '0', NULL, '0', 1, 1, 'FIXED', 3, 15, '0', 103, 1, NOW()),
(113, 1, 1, 111, 70, 'MANUAL-PD785-CN', '中文用户手册', 'ACCESSORY', 1, 'PCS', '1', '0', NULL, '0', 1, 1, 'FIXED', 3, 16, '0', 103, 1, NOW());

-- PD785G BOM (sbom_header_id=2) — 继承PD785 BOM结构，增加4G模块
INSERT INTO cpq_sbom_line (sbom_line_id, tenant_id, sbom_header_id, parent_line_id, line_number, item_code, item_name, item_type, quantity, unit, is_required, is_replaceable, replacement_group, is_phantom, min_qty, max_qty, price_impact, lead_time_days, sort_order, del_flag, create_dept, create_by, create_time) VALUES
(201, 1, 2, NULL, 1, 'H001-PD785G', 'PD785G 主机身组件', 'HOST', 1, 'PCS', '1', '0', NULL, '1', 1, 1, 'FIXED', 21, 1, '0', 103, 1, NOW()),
(202, 1, 2, 201, 10, 'PCB-PD785G-MAIN', 'PD785G 主板PCBA(含4G)', 'ACCESSORY', 1, 'PCS', '1', '0', NULL, '0', 1, 1, 'FIXED', 28, 2, '0', 103, 1, NOW()),
(203, 1, 2, 201, 20, 'LTE-M1', '4G LTE通信模块', 'ACCESSORY', 1, 'PCS', '1', '1', 'GRP_LTE', '0', 1, 1, 'FIXED', 21, 3, '0', 103, 1, NOW()),
(204, 1, 2, NULL, 2, 'AN0375H20', '136-174MHz 20cm天线', 'ACCESSORY', 1, 'PCS', '1', '1', 'GRP_ANTENNA', '0', 1, 2, 'FIXED', 7, 10, '0', 103, 1, NOW()),
(205, 1, 2, NULL, 3, 'BL2500', '2500mAh锂离子电池', 'ACCESSORY', 1, 'PCS', '1', '1', 'GRP_BATTERY', '0', 1, 3, 'FIXED', 7, 11, '0', 103, 1, NOW());

-- MT680 BOM (sbom_header_id=4)
INSERT INTO cpq_sbom_line (sbom_line_id, tenant_id, sbom_header_id, parent_line_id, line_number, item_code, item_name, item_type, quantity, unit, is_required, is_replaceable, replacement_group, is_phantom, min_qty, max_qty, price_impact, lead_time_days, sort_order, del_flag, create_dept, create_by, create_time) VALUES
(401, 1, 4, NULL, 1, 'H001-MT680', 'MT680 车载台主机', 'HOST', 1, 'PCS', '1', '0', NULL, '0', 1, 1, 'FIXED', 35, 1, '0', 103, 1, NOW()),
(402, 1, 4, NULL, 2, 'AN0400W25', '400MHz 25W天线', 'ACCESSORY', 1, 'PCS', '1', '1', 'GRP_ANTENNA', '0', 1, 1, 'FIXED', 7, 2, '0', 103, 1, NOW()),
(403, 1, 4, NULL, 3, 'PS1220', '12V 20A车载电源', 'ACCESSORY', 1, 'PCS', '1', '1', 'GRP_POWER', '0', 1, 1, 'FIXED', 7, 3, '0', 103, 1, NOW()),
(404, 1, 4, NULL, 4, 'MTBR01', '标准安装支架', 'ACCESSORY', 1, 'PCS', '1', '1', 'GRP_BRACKET', '0', 1, 1, 'FIXED', 5, 4, '0', 103, 1, NOW());

-- ===== 6. 产品替代关系（cpq_product_supersession）=====
INSERT INTO cpq_product_supersession (supersession_id, tenant_id, original_model_id, replacement_model_id, supersession_type, condition_expr, price_impact_pct, effective_date, status, del_flag, create_dept, create_by, create_time, remark) VALUES
-- PD505 → PD785 (FULL替代，全面升级)
(1, 1, 1003, 1001, 'FULL', NULL, 166.67, '2026-06-01', '0', '0', 103, 1, NOW(), 'PD505全面停产，由PD785完全替代'),
-- PD785 → PD785G (CONDITIONAL，仅需4G的客户)
(2, 1, 1001, 1002, 'CONDITIONAL', '{"require_4g": true}', 31.25, '2026-07-01', '0', '0', 103, 1, NOW(), '需要4G公网对讲功能的客户推荐PD785G'),
-- AN0375H15 → AN0375H20 (FULL，物料级替代)
(3, 1, 1001, 1001, 'FULL', '{"item_code": "AN0375H15", "replacement_item": "AN0375H20"}', 0, '2026-04-01', '0', '0', 103, 1, NOW(), '物料级替代：短天线停产，统一使用20cm天线');

-- ===== 7. 产品生命周期日志（cpq_product_lifecycle_log）=====
INSERT INTO cpq_product_lifecycle_log (log_id, tenant_id, model_id, from_status, to_status, change_reason, change_by, change_time) VALUES
(1, 1, 1001, 'PRE_RELEASE', 'ACTIVE', 'PD785通过首批量产验证，正式发布上市', 1, '2025-09-01 10:00:00'),
(2, 1, 1003, 'ACTIVE', 'EOL_ANNOUNCED', 'PD505销量持续下降，启动EOL流程，最后采购日期2026-09-30', 1, '2026-03-01 14:00:00'),
(3, 1, 1002, 'PRE_RELEASE', 'ACTIVE', 'PD785G通过入网认证和运营商测试，正式发布', 1, '2026-01-15 09:30:00'),
(4, 1, 1004, 'DESIGN', 'PRE_RELEASE', 'X1p完成工程样机验证，进入小批量试产', 1, '2026-05-20 16:00:00'),
(5, 1, 1005, 'PRE_RELEASE', 'ACTIVE', 'MT680完成TETRA互联互通测试，获得型号核准', 1, '2025-06-01 11:00:00'),
(6, 1, 1006, 'CONCEPT', 'DESIGN', 'BS8000-4完成系统需求评审，进入详细设计阶段', 1, '2026-04-01 08:00:00');

-- ===== 验证查询 =====
-- 各表数据量：
SELECT 'cpq_product_catalog' AS tbl, COUNT(*) AS cnt FROM cpq_product_catalog
UNION ALL SELECT 'cpq_product_model', COUNT(*) FROM cpq_product_model
UNION ALL SELECT 'cpq_product_attribute', COUNT(*) FROM cpq_product_attribute
UNION ALL SELECT 'cpq_sbom_header', COUNT(*) FROM cpq_sbom_header
UNION ALL SELECT 'cpq_sbom_line', COUNT(*) FROM cpq_sbom_line
UNION ALL SELECT 'cpq_product_supersession', COUNT(*) FROM cpq_product_supersession
UNION ALL SELECT 'cpq_product_lifecycle_log', COUNT(*) FROM cpq_product_lifecycle_log;

-- 预期结果：
-- cpq_product_catalog: 3 条 (原1条 + 新增2条)
-- cpq_product_model: 6 条 (6个产品，覆盖全部配置类型和生命周期状态)
-- cpq_product_attribute: 21 条 (6个产品的关键属性)
-- cpq_sbom_header: 5 条 (5个产品的SBOM头)
-- cpq_sbom_line: 22 条 (含虚项和多层级BOM)
-- cpq_product_supersession: 3 条 (FULL + CONDITIONAL + 物料级替代)
-- cpq_product_lifecycle_log: 6 条 (覆盖6种状态转换)
```

### 种子数据覆盖矩阵

| 维度 | 覆盖内容 |
|------|------|
| 配置类型 | STANDARD(PD785/PD785G/PD505)、CTO(X1p)、ATO(MT680)、ETO(BS8000-4) 全部4种 |
| 生命周期状态 | CONCEPT(BS8000-4)→DESIGN(BS8000-4)→PRE_RELEASE(X1p)→ACTIVE(PD785/PD785G/MT680)→EOL_ANNOUNCED(PD505) 共5种（其余3种LIMIT_BUY/DISCONTINUED/ARCHIVED待后续追加） |
| 替代类型 | FULL(PD505→PD785)、CONDITIONAL(PD785→PD785G)、物料级替代(AN0375H15→AN0375H20) |
| BOM层级 | 2层(虚项→物料)、1层(配件) |
| 物料类型 | HOST、ACCESSORY、PACKAGE |
| 实体替换组 | 天线(GRP_ANTENNA)、电池(GRP_BATTERY)、充电器(GRP_CHARGER)、DSP(GRP_DSP)、LTE模块(GRP_LTE)、电源(GRP_POWER)、支架(GRP_BRACKET) |
| 5层产品结构 | L1(DMR/TETRA/通信系统) → L2(手持终端/车载台/基站) → L3(PD700/PD500/X1/MT600/BS8000) → L4(PD785等6个型号) → L5(物料编码 22条SBOM行) |

---

## 文件版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| V1.0 | 2026-06-06 | 初始版本。A2/A4/A10 已完成完整内容制作；A1/A3/A5/A8 已完成详细描述和待办；A6/A7/A9 已标注已纳入计划 |
