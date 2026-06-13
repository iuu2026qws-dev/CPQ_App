-- ===========================================
-- CPQ 菜单路径修正（2026-06-06）
-- 目的：将已有前端页面的菜单 component 指向实际文件路径
-- 执行前请先备份 sys_menu 表
-- ===========================================

-- 50081：产品目录 → component 指向 cpq/catalog
UPDATE sys_menu SET component = 'cpq/catalog' WHERE menu_id = 50081;

-- 50082：产品模型（原名 BOM管理）→ component 指向 cpq/model，菜单名改为「产品模型」，path 改为 model
UPDATE sys_menu SET menu_name = '产品模型', path = 'model', component = 'cpq/model' WHERE menu_id = 50082;

-- 50084：替代品管理 → component 指向 cpq/supersession
UPDATE sys_menu SET component = 'cpq/supersession' WHERE menu_id = 50084;

-- ===========================================
-- 验证
-- ===========================================
-- 执行后检查：
SELECT menu_id, menu_name, path, component FROM sys_menu WHERE menu_id IN (50081, 50082, 50084);
-- 预期结果：
-- 50081 | 产品目录   | catalog       | cpq/catalog
-- 50082 | 产品模型   | model         | cpq/model
-- 50084 | 替代品管理 | supersession  | cpq/supersession
