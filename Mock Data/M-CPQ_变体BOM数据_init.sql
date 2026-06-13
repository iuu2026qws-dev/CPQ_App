-- =============================================
-- CPQ 变体BOM种子数据 — ARC-200P (1003)
-- 目的：让BOM预览根据属性选择动态变化
-- 依赖：M-CPQ_ATO配置与BOM数据_init.sql 已执行
-- =============================================

-- Step 1: 将激光焊缝跟踪系统标记为非必选（默认不包含，仅在选择焊缝跟踪时生效）
UPDATE cpq_sbom_line 
SET is_required = '0' 
WHERE sbom_header_id = 2064100001 
  AND item_code = 'MAT-SEAM-TRACK'
  AND del_flag = '0';

-- Step 2: 插入变体BOM条件 — 当焊缝跟踪=激光时，包含激光焊缝跟踪系统
INSERT INTO cpq_variant_bom (variant_id, tenant_id, model_id, sbom_line_id, material_code, quantity, effectivity_condition, is_default, sort_order, del_flag, create_time) 
VALUES
(2064301001, '000000', 1003, 2064201005, 'MAT-SEAM-TRACK', 1.0000, '{"焊缝跟踪":"LASER"}', '0', 1, '0', NOW()),
(2064301002, '000000', 1003, 2064201005, 'MAT-SEAM-TRACK', 1.0000, '{"焊缝跟踪":"ARC"}',  '0', 2, '0', NOW());

-- 验证
SELECT '=== 变体BOM数据已创建 ===' AS status;
SELECT variant_id, model_id, material_code, effectivity_condition FROM cpq_variant_bom WHERE model_id = 1003 AND del_flag = '0';
SELECT line_number, item_code, item_name, is_required 
FROM cpq_sbom_line 
WHERE sbom_header_id = 2064100001 AND del_flag = '0'
ORDER BY line_number;
