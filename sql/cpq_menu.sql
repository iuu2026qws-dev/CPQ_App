-- =============================================
-- CPQ 菜单 SQL V2.1（ID 范围 50000-50999，避免与 RuoYi 系统菜单冲突）
-- 对齐设计文档 CPQ_后端功能设计.md §3 结构
-- =============================================

-- 一级菜单: CPQ管理(50000) — 所有 CPQ 子菜单的统一父节点
INSERT INTO sys_menu VALUES(50000, 'CPQ管理', 0, 99, '', NULL, NULL, 1, 0, 'M', '0', '0', NULL, 'configure', 103, 1, now(), NULL, NULL, 'CPQ配置定价报价管理');

-- 1. 首页工作台(50010)
INSERT INTO sys_menu VALUES(50010, '首页工作台', 50000, 1, '/cpq/dashboard', NULL, NULL, 1, 0, 'M', '0', '0', NULL, 'home', 103, 1, now(), NULL, NULL, 'CPQ首页工作台');

-- 2. 配置报价(50020) — 已废弃，配置功能迁移到CPQ Portal
-- 50020-50024 菜单记录已删除。配置数据管理页面（属性选项、配置规则、属性映射）见 50086-50087

-- 3. 报价管理(50030)
INSERT INTO sys_menu VALUES(50030, '报价管理', 50000, 3, '/cpq/quoting', NULL, NULL, 1, 1, 'M', '0', '0', NULL, 'documentation', 103, 1, now(), NULL, NULL, 'CPQ报价管理');
INSERT INTO sys_menu VALUES(50031, '报价单列表', 50030, 1, 'list', 'quoting/QuoteList', NULL, 1, 0, 'C', '0', '0', 'cpq:quoting:view', '#', 103, 1, now(), NULL, NULL, '');
INSERT INTO sys_menu VALUES(50032, '新建报价', 50030, 2, 'create', 'quoting/QuoteCreate', NULL, 1, 0, 'C', '0', '0', 'cpq:quoting:create', '#', 103, 1, now(), NULL, NULL, '');
INSERT INTO sys_menu VALUES(50033, '报价模板', 50030, 3, 'templates', 'quoting/TemplateManager', NULL, 1, 0, 'C', '0', '0', 'cpq:quoting:template', '#', 103, 1, now(), NULL, NULL, '');
-- 模板设计器（隐藏页面，从模板管理页跳转进入）
INSERT INTO sys_menu VALUES(50034, '模板设计', 50030, 4, 'template-design/:templateId(\\d+)', 'quoting/TemplateDesigner', NULL, 1, 0, 'C', '0', '0', 'cpq:quoting:template', '#', 103, 1, now(), NULL, NULL, '');

-- 4. 方案管理(50040)
INSERT INTO sys_menu VALUES(50040, '方案管理', 50000, 4, '/cpq/solution', NULL, NULL, 1, 1, 'M', '0', '0', NULL, 'edit', 103, 1, now(), NULL, NULL, 'CPQ方案管理');
INSERT INTO sys_menu VALUES(50041, '方案列表', 50040, 1, 'list', 'solution/SolutionList', NULL, 1, 0, 'C', '0', '0', 'cpq:solution:create', '#', 103, 1, now(), NULL, NULL, '');
INSERT INTO sys_menu VALUES(50042, '方案对比', 50040, 2, 'compare', 'solution/SolutionCompare', NULL, 1, 0, 'C', '0', '0', 'cpq:solution:compare', '#', 103, 1, now(), NULL, NULL, '');

-- 5. 审批中心(50050)
INSERT INTO sys_menu VALUES(50050, '审批中心', 50000, 5, '/cpq/approval', NULL, NULL, 1, 0, 'M', '0', '0', NULL, 'check', 103, 1, now(), NULL, NULL, 'CPQ审批中心');
INSERT INTO sys_menu VALUES(50051, '待我审批', 50050, 1, 'pending', 'approval/PendingApproval', NULL, 1, 0, 'C', '0', '0', 'cpq:approval:action', '#', 103, 1, now(), NULL, NULL, '');
INSERT INTO sys_menu VALUES(50052, '我已审批', 50050, 2, 'processed', 'approval/ApprovalHistory', NULL, 1, 0, 'C', '0', '0', 'cpq:approval:action', '#', 103, 1, now(), NULL, NULL, '');
INSERT INTO sys_menu VALUES(50053, '我发起的', 50050, 3, 'initiated', 'approval/MyInitiated', NULL, 1, 0, 'C', '0', '0', 'cpq:approval:submit', '#', 103, 1, now(), NULL, NULL, '');
INSERT INTO sys_menu VALUES(50054, '效率看板', 50050, 4, 'analytics', 'approval/ApprovalAnalytics', NULL, 1, 0, 'C', '0', '0', 'cpq:approval:action', '#', 103, 1, now(), NULL, NULL, '');

-- 6. 售前协同(50060)
INSERT INTO sys_menu VALUES(50060, '售前协同', 50000, 6, '/cpq/presales', NULL, NULL, 1, 0, 'M', '0', '0', NULL, 'connection', 103, 1, now(), NULL, NULL, 'CPQ售前协同');
INSERT INTO sys_menu VALUES(50061, '任务看板', 50060, 1, 'board', 'presales/TaskBoard', NULL, 1, 0, 'C', '0', '0', 'cpq:solution:create', '#', 103, 1, now(), NULL, NULL, '');
INSERT INTO sys_menu VALUES(50062, '评审工作台', 50060, 2, 'review', 'presales/ReviewWorkbench', NULL, 1, 0, 'C', '0', '0', 'cpq:solution:review', '#', 103, 1, now(), NULL, NULL, '');

-- 7. 竞品对标(50070)
INSERT INTO sys_menu VALUES(50070, '竞品对标', 50000, 7, '/cpq/competitive', NULL, NULL, 1, 0, 'M', '0', '0', NULL, 'switch', 103, 1, now(), NULL, NULL, 'CPQ竞品对标');
INSERT INTO sys_menu VALUES(50071, '竞品库', 50070, 1, 'library', 'competitive/CompetitorList', NULL, 1, 0, 'C', '0', '0', 'cpq:competitive:view', '#', 103, 1, now(), NULL, NULL, '');
INSERT INTO sys_menu VALUES(50072, '对比分析', 50070, 2, 'compare', 'competitive/ComparisonView', NULL, 1, 0, 'C', '0', '0', 'cpq:competitive:view', '#', 103, 1, now(), NULL, NULL, '');

-- 8. 产品管理(50080)
INSERT INTO sys_menu VALUES(50080, '产品管理', 50000, 8, '/cpq/product', NULL, NULL, 1, 1, 'M', '0', '0', NULL, 'component', 103, 1, now(), NULL, NULL, 'CPQ产品管理');
INSERT INTO sys_menu VALUES(50081, '产品目录', 50080, 1, 'catalog', 'cpq/catalog', NULL, 1, 0, 'C', '0', '0', 'cpq:product:catalog', '#', 103, 1, now(), NULL, NULL, '');
INSERT INTO sys_menu VALUES(50082, '产品模型', 50080, 2, 'model', 'cpq/model', NULL, 1, 0, 'C', '0', '0', 'cpq:product:bom', '#', 103, 1, now(), NULL, NULL, '');
INSERT INTO sys_menu VALUES(50083, '配置规则', 50080, 3, 'rules', 'product/ConfigRuleManager', NULL, 1, 0, 'C', '0', '0', 'cpq:product:rule', '#', 103, 1, now(), NULL, NULL, '');
INSERT INTO sys_menu VALUES(50084, '替代品管理', 50080, 4, 'supersession', 'cpq/supersession', NULL, 1, 0, 'C', '0', '0', 'cpq:product:catalog', '#', 103, 1, now(), NULL, NULL, '');
-- 50085 产品分类管理（Sprint 1 新增）
INSERT INTO sys_menu VALUES(50085, '产品分类管理', 50080, 5, 'category', 'cpq/category', NULL, 1, 0, 'C', '0', '0', 'cpq:product:category', '#', 103, 1, now(), NULL, NULL, '产品分类层级树管理(L1/L2/L3)');

-- 50086 属性选项管理（Sprint 3 新增 — 配置数据管理）
INSERT INTO sys_menu VALUES(50086, '属性选项管理', 50080, 6, 'attribute-option', 'cpq/attribute-option/index', NULL, 1, 0, 'C', '0', '0', 'cpq:config:attributeoption:list', '#', 103, 1, now(), NULL, NULL, 'CPQ属性选项配置管理（增删改查）');

-- 50087 属性映射管理（Sprint 3 新增 — 配置数据管理）
INSERT INTO sys_menu VALUES(50087, '属性映射管理', 50080, 7, 'attribute-mapping', 'cpq/attribute-mapping/index', NULL, 1, 0, 'C', '0', '0', 'cpq:config:attributemapping:list', '#', 103, 1, now(), NULL, NULL, 'CPQ属性映射配置管理（增删改查）');

-- 9. 定价管理(50090)
INSERT INTO sys_menu VALUES(50090, '定价管理', 50000, 9, '/cpq/pricing', NULL, NULL, 1, 0, 'M', '0', '0', NULL, 'money', 103, 1, now(), NULL, NULL, 'CPQ定价管理');
INSERT INTO sys_menu VALUES(50091, '价格手册', 50090, 1, 'books', 'pricing/PriceBookList', NULL, 1, 0, 'C', '0', '0', 'cpq:pricing:view', '#', 103, 1, now(), NULL, NULL, '');
INSERT INTO sys_menu VALUES(50092, '定价规则', 50090, 2, 'rules', 'pricing/PriceRuleConfig', NULL, 1, 0, 'C', '0', '0', 'cpq:pricing:edit', '#', 103, 1, now(), NULL, NULL, '');
INSERT INTO sys_menu VALUES(50093, '阶梯定价', 50090, 3, 'volume', 'pricing/VolumeTierConfig', NULL, 1, 0, 'C', '0', '0', 'cpq:pricing:edit', '#', 103, 1, now(), NULL, NULL, '');

-- 10. 交期查询(50100)
INSERT INTO sys_menu VALUES(50100, '交期查询', 50000, 10, '/cpq/atpctp', NULL, NULL, 1, 0, 'M', '0', '0', NULL, 'time-range', 103, 1, now(), NULL, NULL, 'CPQ交期查询');
INSERT INTO sys_menu VALUES(50101, '交期检查', 50100, 1, 'check', 'atpctp/AtpCheck', NULL, 1, 0, 'C', '0', '0', 'cpq:atp:check', '#', 103, 1, now(), NULL, NULL, '');
INSERT INTO sys_menu VALUES(50102, '批量查询', 50100, 2, 'batch', 'atpctp/AtpBatch', NULL, 1, 0, 'C', '0', '0', 'cpq:atp:check', '#', 103, 1, now(), NULL, NULL, '');
INSERT INTO sys_menu VALUES(50103, 'SLA看板', 50100, 3, 'sla', 'atpctp/SlaDashboard', NULL, 1, 0, 'C', '0', '0', 'cpq:atp:ctp', '#', 103, 1, now(), NULL, NULL, '');

-- 11. 知识库(50110)
INSERT INTO sys_menu VALUES(50110, '知识库', 50000, 11, '/cpq/knowledge', NULL, NULL, 1, 0, 'M', '0', '0', NULL, 'education', 103, 1, now(), NULL, NULL, 'CPQ知识库');
INSERT INTO sys_menu VALUES(50111, '产品知识', 50110, 1, 'products', 'knowledge/ProductKnowledge', NULL, 1, 0, 'C', '0', '0', 'cpq:knowledge:view', '#', 103, 1, now(), NULL, NULL, '');
INSERT INTO sys_menu VALUES(50112, '销售话术', 50110, 2, 'scripts', 'knowledge/SalesScripts', NULL, 1, 0, 'C', '0', '0', 'cpq:knowledge:view', '#', 103, 1, now(), NULL, NULL, '');
INSERT INTO sys_menu VALUES(50113, '成功案例', 50110, 3, 'cases', 'knowledge/CaseLibrary', NULL, 1, 0, 'C', '0', '0', 'cpq:knowledge:view', '#', 103, 1, now(), NULL, NULL, '');
INSERT INTO sys_menu VALUES(50114, '培训认证', 50110, 4, 'training', 'knowledge/TrainingCenter', NULL, 1, 0, 'C', '0', '0', 'cpq:knowledge:edit', '#', 103, 1, now(), NULL, NULL, '');

-- 12. 系统集成(50120) — 仅管理员
INSERT INTO sys_menu VALUES(50120, '系统集成', 50000, 12, '/cpq/integration', NULL, NULL, 1, 0, 'M', '0', '0', NULL, 'link', 103, 1, now(), NULL, NULL, 'CPQ系统集成');
INSERT INTO sys_menu VALUES(50121, 'CRM连接器', 50120, 1, 'crm', 'integration/CrmConnector', NULL, 1, 0, 'C', '0', '0', 'cpq:integration:config', '#', 103, 1, now(), NULL, NULL, '');
INSERT INTO sys_menu VALUES(50122, 'ERP连接器', 50120, 2, 'erp', 'integration/ErpConnector', NULL, 1, 0, 'C', '0', '0', 'cpq:integration:config', '#', 103, 1, now(), NULL, NULL, '');
INSERT INTO sys_menu VALUES(50123, 'PLM连接器', 50120, 3, 'plm', 'integration/PlmConnector', NULL, 1, 0, 'C', '0', '0', 'cpq:integration:config', '#', 103, 1, now(), NULL, NULL, '');
INSERT INTO sys_menu VALUES(50124, '同步日志', 50120, 4, 'logs', 'integration/SyncLogViewer', NULL, 1, 0, 'C', '0', '0', 'cpq:integration:config', '#', 103, 1, now(), NULL, NULL, '');

-- 13. 系统设置(50130) — 管理员+审计
INSERT INTO sys_menu VALUES(50130, '系统设置', 50000, 13, '/cpq/settings', NULL, NULL, 1, 0, 'M', '0', '0', NULL, 'system', 103, 1, now(), NULL, NULL, 'CPQ系统设置');
INSERT INTO sys_menu VALUES(50131, '租户配置', 50130, 1, 'tenant', 'settings/TenantConfig', NULL, 1, 0, 'C', '0', '0', 'cpq:admin:tenant', '#', 103, 1, now(), NULL, NULL, '');
INSERT INTO sys_menu VALUES(50132, '用户管理', 50130, 2, 'users', 'settings/UserManagement', NULL, 1, 0, 'C', '0', '0', 'cpq:admin:user', '#', 103, 1, now(), NULL, NULL, '');
INSERT INTO sys_menu VALUES(50133, '角色管理', 50130, 3, 'roles', 'settings/RoleManagement', NULL, 1, 0, 'C', '0', '0', 'cpq:admin:user', '#', 103, 1, now(), NULL, NULL, '');
INSERT INTO sys_menu VALUES(50134, 'ABAC策略', 50130, 4, 'abac', 'settings/AbacPolicyConfig', NULL, 1, 0, 'C', '0', '0', 'cpq:admin:abac', '#', 103, 1, now(), NULL, NULL, '');
INSERT INTO sys_menu VALUES(50135, '审计日志', 50130, 5, 'audit', 'settings/AuditLogViewer', NULL, 1, 0, 'C', '0', '0', 'cpq:admin:audit', '#', 103, 1, now(), NULL, NULL, '');
INSERT INTO sys_menu VALUES(50136, '数据迁移', 50130, 6, 'migration', 'settings/DataMigration', NULL, 1, 0, 'C', '0', '0', 'cpq:admin:migration', '#', 103, 1, now(), NULL, NULL, '');
INSERT INTO sys_menu VALUES(50137, '变更管理', 50130, 7, 'ecn', 'settings/ChangeManagement', NULL, 1, 0, 'C', '0', '0', 'cpq:admin:ecn', '#', 103, 1, now(), NULL, NULL, '');
INSERT INTO sys_menu VALUES(50138, '系统参数', 50130, 8, 'params', 'settings/SystemParams', NULL, 1, 0, 'C', '0', '0', 'cpq:admin:tenant', '#', 103, 1, now(), NULL, NULL, '');

-- 14. 个人中心(50140)
INSERT INTO sys_menu VALUES(50140, '个人中心', 50000, 14, '/cpq/profile', NULL, NULL, 1, 0, 'M', '0', '0', NULL, 'user', 103, 1, now(), NULL, NULL, 'CPQ个人中心');

-- ===== 为管理员(role_id=1)分配所有CPQ菜单 =====
INSERT INTO sys_role_menu (role_id, menu_id) SELECT 1, 50000 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_role_menu WHERE role_id=1 AND menu_id=50000);
INSERT INTO sys_role_menu (role_id, menu_id) SELECT 1, menu_id FROM sys_menu WHERE menu_id BETWEEN 50010 AND 50140 AND NOT EXISTS (SELECT 1 FROM sys_role_menu WHERE role_id=1 AND sys_role_menu.menu_id = sys_menu.menu_id);
