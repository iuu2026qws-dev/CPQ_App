-- =============================================
-- CPQ 变体BOM种子数据 — 亿纬锂能 HVI-40.0 (2091)
-- 目的：让BOM预览根据属性选择动态变化
-- 可重复执行（幂等）: 先清理EVE变体数据再导入
-- 依赖：M-CPQ_EVE_ATO配置与BOM数据_init.sql 需先执行
-- =============================================

SET NAMES utf8mb4;

-- =============================================
-- 【幂等清理】删除已有的EVE变体BOM数据
-- =============================================
DELETE FROM cpq_variant_bom WHERE model_id IN (2009, 2058, 2091);

-- =============================================
-- Step 2: 插入变体BOM条件

-- === HVI-40.0 (2091) 变体BOM ===

-- 当防护等级=IP67时，额外包含IP67密封套件
INSERT INTO cpq_variant_bom (variant_id, tenant_id, model_id, sbom_line_id, material_code, quantity, effectivity_condition, is_default, sort_order, del_flag, create_time) 
VALUES
(2074301001, '000000', 2091, 2074203005, 'ENCLOSURE-HVI-IP67', 1.0000, '{"防护等级":"IP67"}', '0', 1, '0', NOW());

-- 当防护等级=IP65时，换用IP65壳体
INSERT INTO cpq_variant_bom (variant_id, tenant_id, model_id, sbom_line_id, material_code, quantity, effectivity_condition, is_default, sort_order, del_flag, create_time) 
VALUES
(2074301002, '000000', 2091, 2074203005, 'ENCLOSURE-HVI-IP65', 1.0000, '{"防护等级":"IP65"}', '0', 2, '0', NOW());

-- 当BMS功能=ADVANCED时，换用高级BMS
INSERT INTO cpq_variant_bom (variant_id, tenant_id, model_id, sbom_line_id, material_code, quantity, effectivity_condition, is_default, sort_order, del_flag, create_time) 
VALUES
(2074301003, '000000', 2091, 2074203003, 'BMS-HVI-ADV-V3', 1.0000, '{"BMS功能":"ADVANCED"}', '0', 3, '0', NOW());

-- 当BMS功能=PREMIUM时，换用旗舰BMS+OTA激活许可
INSERT INTO cpq_variant_bom (variant_id, tenant_id, model_id, sbom_line_id, material_code, quantity, effectivity_condition, is_default, sort_order, del_flag, create_time) 
VALUES
(2074301004, '000000', 2091, 2074203003, 'BMS-HVI-PREMIUM-V3', 1.0000, '{"BMS功能":"PREMIUM"}', '0', 4, '0', NOW());

-- 当逆变器匹配=15kW时，换用15kW逆变器
INSERT INTO cpq_variant_bom (variant_id, tenant_id, model_id, sbom_line_id, material_code, quantity, effectivity_condition, is_default, sort_order, del_flag, create_time) 
VALUES
(2074301005, '000000', 2091, 2074203004, 'PCS-HYBRID-15K', 1.0000, '{"逆变器匹配":"SOLAR_15K"}', '0', 5, '0', NOW());

-- 当逆变器匹配=25kW时，换用25kW逆变器
INSERT INTO cpq_variant_bom (variant_id, tenant_id, model_id, sbom_line_id, material_code, quantity, effectivity_condition, is_default, sort_order, del_flag, create_time) 
VALUES
(2074301006, '000000', 2091, 2074203004, 'PCS-HYBRID-25K', 1.0000, '{"逆变器匹配":"SOLAR_25K"}', '0', 6, '0', NOW());

-- 当电池模组数=MOD8时，模组数量变为8
INSERT INTO cpq_variant_bom (variant_id, tenant_id, model_id, sbom_line_id, material_code, quantity, effectivity_condition, is_default, sort_order, del_flag, create_time) 
VALUES
(2074301007, '000000', 2091, 2074203002, 'MOD-HVI-4K-STD', 8.0000, '{"电池模组数":"MOD8"}', '0', 7, '0', NOW()),
(2074301008, '000000', 2091, 2074203002, 'MOD-HVI-4K-STD', 12.0000, '{"电池模组数":"MOD12"}', '0', 8, '0', NOW());

-- 当消防方案=FM200时，换用FM200消防模块
INSERT INTO cpq_variant_bom (variant_id, tenant_id, model_id, sbom_line_id, material_code, quantity, effectivity_condition, is_default, sort_order, del_flag, create_time) 
VALUES
(2074301009, '000000', 2091, 2074203008, 'FIRE-FM200', 1.0000, '{"消防方案":"FM200"}', '0', 9, '0', NOW());

-- 当消防方案=高压细水雾时，换用细水雾消防模块
INSERT INTO cpq_variant_bom (variant_id, tenant_id, model_id, sbom_line_id, material_code, quantity, effectivity_condition, is_default, sort_order, del_flag, create_time) 
VALUES
(2074301010, '000000', 2091, 2074203008, 'FIRE-WATER-MIST', 1.0000, '{"消防方案":"WATER_MIST"}', '0', 10, '0', NOW());


-- =============================================
-- === CTP-30K (2058) 变体BOM ===

-- 当BMS=主动均衡时，替换为主动均衡BMS
INSERT INTO cpq_variant_bom (variant_id, tenant_id, model_id, sbom_line_id, material_code, quantity, effectivity_condition, is_default, sort_order, del_flag, create_time) 
VALUES
(2074302001, '000000', 2058, 2074202003, 'BMS-CTP30K-ACTIVE', 1.0000, '{"BMS选型":"BMS_ACTIVE"}', '0', 1, '0', NOW());

-- 当BMS=AI时，替换为AI BMS
INSERT INTO cpq_variant_bom (variant_id, tenant_id, model_id, sbom_line_id, material_code, quantity, effectivity_condition, is_default, sort_order, del_flag, create_time) 
VALUES
(2074302002, '000000', 2058, 2074202003, 'BMS-CTP30K-AI-4G', 1.0000, '{"BMS选型":"BMS_AI"}', '0', 2, '0', NOW());

-- 当电芯=LF100LA时，替换电芯批号
INSERT INTO cpq_variant_bom (variant_id, tenant_id, model_id, sbom_line_id, material_code, quantity, effectivity_condition, is_default, sort_order, del_flag, create_time) 
VALUES
(2074302003, '000000', 2058, 2074202002, 'CELL-LF100LA-300PCS', 300.0000, '{"电芯选型":"LF100LA"}', '0', 3, '0', NOW());

-- 当电芯=LF120L时，替换电芯批号（300片=36kWh）
INSERT INTO cpq_variant_bom (variant_id, tenant_id, model_id, sbom_line_id, material_code, quantity, effectivity_condition, is_default, sort_order, del_flag, create_time) 
VALUES
(2074302004, '000000', 2058, 2074202002, 'CELL-LF120L-300PCS', 300.0000, '{"电芯选型":"LF120L"}', '0', 4, '0', NOW());

-- 当冷却=液冷时，替换为液冷板
INSERT INTO cpq_variant_bom (variant_id, tenant_id, model_id, sbom_line_id, material_code, quantity, effectivity_condition, is_default, sort_order, del_flag, create_time) 
VALUES
(2074302005, '000000', 2058, 2074202004, 'COOL-PLATE-CTP30K', 1.0000, '{"冷却方式":"LIQUID_COOL"}', '0', 5, '0', NOW());

-- 当冷却=压缩机制冷时，替换为压缩机制冷组件
INSERT INTO cpq_variant_bom (variant_id, tenant_id, model_id, sbom_line_id, material_code, quantity, effectivity_condition, is_default, sort_order, del_flag, create_time) 
VALUES
(2074302006, '000000', 2058, 2074202004, 'COOL-COMP-CTP30K', 1.0000, '{"冷却方式":"REFRIG"}', '0', 6, '0', NOW());

-- 当防水=IP67时，额外包含密封套件
INSERT INTO cpq_variant_bom (variant_id, tenant_id, model_id, sbom_line_id, material_code, quantity, effectivity_condition, is_default, sort_order, del_flag, create_time) 
VALUES
(2074302007, '000000', 2058, 2074202008, 'SEAL-GASKET-IP67', 1.0000, '{"防水等级":"IP67"}', '0', 7, '0', NOW());


-- =============================================
-- === LF120L (2009) 变体BOM — 极柱/容量/循环条件 ===

-- 当极柱=M8时，换用M8极柱
INSERT INTO cpq_variant_bom (variant_id, tenant_id, model_id, sbom_line_id, material_code, quantity, effectivity_condition, is_default, sort_order, del_flag, create_time) 
VALUES
(2074303001, '000000', 2009, 2074201003, 'TERMINAL-M8-120L', 2.0000, '{"极柱类型":"M8_LARGE"}', '0', 1, '0', NOW());

-- 当极柱=激光焊接端子时，换用激光焊端子（替换螺栓端子，数量1个焊接面）
INSERT INTO cpq_variant_bom (variant_id, tenant_id, model_id, sbom_line_id, material_code, quantity, effectivity_condition, is_default, sort_order, del_flag, create_time) 
VALUES
(2074303002, '000000', 2009, 2074201003, 'TERMINAL-LASER-WELD', 1.0000, '{"极柱类型":"LASER_WELD"}', '0', 2, '0', NOW());

-- 当循环=长寿命时，替换电解液配方
INSERT INTO cpq_variant_bom (variant_id, tenant_id, model_id, sbom_line_id, material_code, quantity, effectivity_condition, is_default, sort_order, del_flag, create_time) 
VALUES
(2074303003, '000000', 2009, 2074201005, 'ELE-LYTE-LONG-120L', 1.0000, '{"循环等级":"LONG_6000"}', '0', 3, '0', NOW());

-- 当循环=超长寿命时，替换电解液配方
INSERT INTO cpq_variant_bom (variant_id, tenant_id, model_id, sbom_line_id, material_code, quantity, effectivity_condition, is_default, sort_order, del_flag, create_time) 
VALUES
(2074303004, '000000', 2009, 2074201005, 'ELE-LYTE-ULTRA-120L', 1.0000, '{"循环等级":"ULTRA_8000"}', '0', 4, '0', NOW());

-- 当壳体=黑色时，替换壳体物料
INSERT INTO cpq_variant_bom (variant_id, tenant_id, model_id, sbom_line_id, material_code, quantity, effectivity_condition, is_default, sort_order, del_flag, create_time) 
VALUES
(2074303005, '000000', 2009, 2074201006, 'SHELL-AL-BLACK-120L', 1.0000, '{"壳体颜色":"BLACK_SHELL"}', '0', 5, '0', NOW());

-- 当壳体=银灰时，替换壳体物料
INSERT INTO cpq_variant_bom (variant_id, tenant_id, model_id, sbom_line_id, material_code, quantity, effectivity_condition, is_default, sort_order, del_flag, create_time) 
VALUES
(2074303006, '000000', 2009, 2074201006, 'SHELL-AL-SILVER-120L', 1.0000, '{"壳体颜色":"SILVER_SHELL"}', '0', 6, '0', NOW());


-- =============================================
-- 验证查询
-- =============================================
SELECT '=== EVE 变体BOM数据已创建 ===' AS status;
SELECT 'HVI-40.0 (2091)' AS product, COUNT(*) AS variant_count FROM cpq_variant_bom WHERE model_id = 2091 AND del_flag = '0'
UNION ALL
SELECT 'CTP-30K (2058)', COUNT(*) FROM cpq_variant_bom WHERE model_id = 2058 AND del_flag = '0'
UNION ALL
SELECT 'LF120L (2009)', COUNT(*) FROM cpq_variant_bom WHERE model_id = 2009 AND del_flag = '0';

-- =============================================
-- 变体BOM统计
-- =============================================
-- HVI-40.0 (2091): 10个变体条件
-- CTP-30K (2058):  7个变体条件
-- LF120L (2009):   6个变体条件
-- 总计: 23个变体BOM条件
-- =============================================
