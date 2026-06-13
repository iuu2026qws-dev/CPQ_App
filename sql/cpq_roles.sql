-- =============================================
-- CPQ 角色与ABAC策略 SQL（V2.0 对齐设计文档 §2）
-- 修正：sys_role 字段对齐
-- =============================================

-- 先删除已有CPQ角色
DELETE FROM sys_role_menu WHERE role_id BETWEEN 100 AND 111;
DELETE FROM sys_role WHERE role_id BETWEEN 100 AND 111;

INSERT INTO sys_role (role_id, tenant_id, role_name, role_key, role_sort, data_scope, menu_check_strictly, dept_check_strictly, status, del_flag, create_dept, create_by, create_time, remark) VALUES
(100, '000000', '销售代表',       'cpq_sales',        1, '5', 1, 1, '0', '0', 103, 1, NOW(), 'CPQ一线销售'),
(101, '000000', '售前工程师',     'cpq_presales',     2, '5', 1, 1, '0', '0', 103, 1, NOW(), 'CPQ技术方案与售前支持'),
(102, '000000', '销售经理',       'cpq_sales_mgr',    3, '3', 1, 1, '0', '0', 103, 1, NOW(), 'CPQ销售团队管理'),
(103, '000000', '渠道合作伙伴',   'cpq_partner',      4, '5', 1, 1, '0', '0', 103, 1, NOW(), 'CPQ经销商/代理商'),
(104, '000000', '产品经理',       'cpq_product_mgr',  5, '1', 1, 1, '0', '0', 103, 1, NOW(), 'CPQ产品目录与BOM管理'),
(105, '000000', '定价管理员',     'cpq_pricing_mgr',  6, '1', 1, 1, '0', '0', 103, 1, NOW(), 'CPQ价格手册与定价规则'),
(106, '000000', '供应链计划员',   'cpq_supply_chain', 7, '1', 1, 1, '0', '0', 103, 1, NOW(), 'CPQ产能/物料/交期管理'),
(107, '000000', '审批人',         'cpq_approver',     8, '1', 1, 1, '0', '0', 103, 1, NOW(), 'CPQ报价审批'),
(108, '000000', '销售运营',       'cpq_operations',   9, '1', 1, 1, '0', '0', 103, 1, NOW(), 'CPQ培训/赋能/模板管理'),
(109, '000000', '高层管理者',     'cpq_executive',   10, '1', 1, 1, '0', '0', 103, 1, NOW(), 'CPQ全局视图与洞察'),
(110, '000000', '外部审计',       'cpq_auditor',     11, '1', 1, 1, '0', '0', 103, 1, NOW(), 'CPQ审计日志查看(只读)'),
(111, '000000', '系统管理员',     'cpq_admin',       12, '1', 1, 1, '0', '0', 103, 1, NOW(), 'CPQ系统配置与运维');

-- ===== 角色-菜单分配 =====
-- 销售代表(100)
INSERT INTO sys_role_menu (role_id, menu_id) VALUES
(100,50000),(100,50010),(100,50020),(100,50021),(100,50022),(100,50023),(100,50024),
(100,50030),(100,50031),(100,50032),(100,50033),
(100,50050),(100,50051),(100,50053),
(100,50060),(100,50061),
(100,50100),(100,50101),(100,50102),
(100,50110),(100,50111),(100,50112),(100,50113),
(100,50140);

-- 售前工程师(101) = 销售全部 + 方案 + 售前完整 + 竞品
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) SELECT 101, menu_id FROM sys_role_menu WHERE role_id=100;
INSERT INTO sys_role_menu (role_id, menu_id) VALUES
(101,50040),(101,50041),(101,50042),
(101,50062),
(101,50070),(101,50071),(101,50072);

-- 销售经理(102) = 售前全部权限
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) SELECT 102, menu_id FROM sys_role_menu WHERE role_id=101;

-- 渠道伙伴(103)
INSERT INTO sys_role_menu (role_id, menu_id) VALUES
(103,50000),(103,50010),(103,50020),(103,50021),(103,50022),
(103,50030),(103,50031),(103,50032),
(103,50100),(103,50101),
(103,50110),(103,50111),(103,50140);

-- 产品经理(104)
INSERT INTO sys_role_menu (role_id, menu_id) VALUES
(104,50000),(104,50010),(104,50040),(104,50041),
(104,50050),(104,50051),
(104,50070),(104,50071),(104,50072),
(104,50080),(104,50081),(104,50082),(104,50083),(104,50084),
(104,50110),(104,50111),(104,50112),(104,50140);

-- 定价管理员(105)
INSERT INTO sys_role_menu (role_id, menu_id) VALUES
(105,50000),(105,50010),(105,50050),(105,50051),
(105,50090),(105,50091),(105,50092),(105,50093),
(105,50110),(105,50111),(105,50140);

-- 供应链计划员(106)
INSERT INTO sys_role_menu (role_id, menu_id) VALUES
(106,50000),(106,50010),(106,50050),(106,50051),
(106,50080),(106,50081),(106,50082),
(106,50100),(106,50101),(106,50102),(106,50103),
(106,50140);

-- 审批人(107)
INSERT INTO sys_role_menu (role_id, menu_id) VALUES
(107,50000),(107,50010),(107,50050),(107,50051),(107,50052),(107,50054),
(107,50140);

-- 销售运营(108)
INSERT INTO sys_role_menu (role_id, menu_id) VALUES
(108,50000),(108,50010),(108,50070),(108,50071),(108,50072),
(108,50110),(108,50111),(108,50112),(108,50113),(108,50114),
(108,50140);

-- 高层管理者(109)
INSERT INTO sys_role_menu (role_id, menu_id) VALUES
(109,50000),(109,50010),(109,50050),(109,50051),
(109,50070),(109,50071),(109,50072),
(109,50100),(109,50101),(109,50102),(109,50103),
(109,50140);

-- 外部审计(110) — 只读
INSERT INTO sys_role_menu (role_id, menu_id) VALUES
(110,50000),(110,50010),(110,50130),(110,50135),(110,50140);

-- 系统管理员(111) — 全部CPQ菜单
INSERT INTO sys_role_menu (role_id, menu_id)
SELECT 111, menu_id FROM sys_menu WHERE menu_id BETWEEN 50000 AND 50140;

-- ===== ABAC策略数据 =====
DELETE FROM cpq_abac_policy WHERE policy_id BETWEEN 1 AND 8;
INSERT INTO cpq_abac_policy (policy_id, tenant_id, policy_name, policy_type, subject_type, subject_value, attribute_key, attribute_value, status, create_dept, create_by, create_time) VALUES
(1, 1, '销售代表-成本L1',     'COST_VISIBILITY', 'ROLE', 'cpq_sales',       'cost_visibility_level', '1', '0', 103, 1, NOW()),
(2, 1, '售前工程师-成本L2',   'COST_VISIBILITY', 'ROLE', 'cpq_presales',    'cost_visibility_level', '2', '0', 103, 1, NOW()),
(3, 1, '销售经理-成本L2',     'COST_VISIBILITY', 'ROLE', 'cpq_sales_mgr',   'cost_visibility_level', '2', '0', 103, 1, NOW()),
(4, 1, '渠道伙伴-成本L0',     'COST_VISIBILITY', 'ROLE', 'cpq_partner',     'cost_visibility_level', '0', '0', 103, 1, NOW()),
(5, 1, '产品经理-成本L2',     'COST_VISIBILITY', 'ROLE', 'cpq_product_mgr', 'cost_visibility_level', '2', '0', 103, 1, NOW()),
(6, 1, '定价管理员-成本L3',   'COST_VISIBILITY', 'ROLE', 'cpq_pricing_mgr', 'cost_visibility_level', '3', '0', 103, 1, NOW()),
(7, 1, '供应链-成本L2',       'COST_VISIBILITY', 'ROLE', 'cpq_supply_chain','cost_visibility_level', '2', '0', 103, 1, NOW()),
(8, 1, '高管-成本L3',         'COST_VISIBILITY', 'ROLE', 'cpq_executive',   'cost_visibility_level', '3', '0', 103, 1, NOW());
