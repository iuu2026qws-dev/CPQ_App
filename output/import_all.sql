-- ============================================================
-- POC ER微型电池 数据导入 SQL
-- 生成: 2026-07-24 15:31:55
-- 分类: category_id=507 (锂亚硫酰氯电池)
-- 类目: catalog_id=11 (EVE 标准产品目录)
-- 用法: mysql -h 8.148.208.235 -P 3306 -u root -p Ruoyi_CPQ < import_all.sql
-- ============================================================

SET NAMES utf8mb4;

-- 1. 导入产品型号
LOAD DATA LOCAL INFILE 'output/cpq_product_model.csv'
INTO TABLE cpq_product_model
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(model_id, tenant_id, catalog_id, category_id, model_code, model_name,
 description, lifecycle_status, config_type, base_price, currency,
 min_order_qty, lead_time_days, status, del_flag, create_time);

-- 2. 导入产品属性
LOAD DATA LOCAL INFILE 'output/cpq_product_attribute.csv'
INTO TABLE cpq_product_attribute
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(attribute_id, tenant_id, model_id, attr_category, attr_name,
 attr_value, is_configurable, is_required, display_order,
 data_type, sort_order, del_flag, create_time);

-- 3. 导入 SBOM 头
LOAD DATA LOCAL INFILE 'output/cpq_sbom_header.csv'
INTO TABLE cpq_sbom_header
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(sbom_header_id, tenant_id, model_id, sbom_name,
 sbom_version, status, del_flag, create_time);

-- 4. 导入 SBOM 行
LOAD DATA LOCAL INFILE 'output/cpq_sbom_line.csv'
INTO TABLE cpq_sbom_line
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(sbom_line_id, tenant_id, sbom_header_id, parent_line_id,
 line_number, item_code, item_name, item_type, quantity,
 unit, is_required, is_replaceable, sort_order, del_flag, create_time);

-- 5. 导入维度属性映射（跳过已存在的，避免主键冲突）
LOAD DATA LOCAL INFILE 'output/cpq_dimension_attr_mapping.csv'
INTO TABLE cpq_dimension_attr_mapping
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(mapping_id, tenant_id, dimension_code, product_attr_category,
 product_attr_name, mapping_role, sort_order, status, del_flag);

-- ============================================================
-- 验证
-- ============================================================
SELECT '=== 导入验证 ===' AS '';
SELECT '成品型号数 (>=6001)' AS 检查项, COUNT(*) AS 数量 FROM cpq_product_model WHERE model_id >= 6001 AND del_flag = '0'
UNION ALL
SELECT '电芯属性数', COUNT(*) FROM cpq_product_attribute WHERE attr_category = '电芯规格' AND model_id >= 6001 AND del_flag = '0'
UNION ALL
SELECT '成品属性数', COUNT(*) FROM cpq_product_attribute WHERE attr_category = '成品规格' AND model_id >= 6001 AND del_flag = '0'
UNION ALL
SELECT '防护属性数', COUNT(*) FROM cpq_product_attribute WHERE attr_category = '防护信息' AND model_id >= 6001 AND del_flag = '0'
UNION ALL
SELECT 'SBOM头数', COUNT(*) FROM cpq_sbom_header WHERE model_id >= 6001 AND del_flag = '0'
UNION ALL
SELECT 'SBOM行数(电芯)', COUNT(*) FROM cpq_sbom_line sl JOIN cpq_sbom_header sh ON sl.sbom_header_id = sh.sbom_header_id WHERE sh.model_id >= 6001 AND sl.item_type = 'HOST' AND sl.del_flag = '0'
UNION ALL
SELECT 'SBOM行数(插头线)', COUNT(*) FROM cpq_sbom_line sl JOIN cpq_sbom_header sh ON sl.sbom_header_id = sh.sbom_header_id WHERE sh.model_id >= 6001 AND sl.item_type = 'ACCESSORY' AND sl.del_flag = '0';

-- 成品→电芯 BOM 关联（前20条）
SELECT pm.model_code AS 成品编码, pm.model_name AS 成品描述,
       sl.item_code AS 电芯, sl.quantity AS 电芯数量,
       sl2.item_code AS 插头线
FROM cpq_product_model pm
JOIN cpq_sbom_header sh ON sh.model_id = pm.model_id AND sh.del_flag = '0'
LEFT JOIN cpq_sbom_line sl ON sl.sbom_header_id = sh.sbom_header_id AND sl.item_type = 'HOST' AND sl.del_flag = '0'
LEFT JOIN cpq_sbom_line sl2 ON sl2.sbom_header_id = sh.sbom_header_id AND sl2.item_type = 'ACCESSORY' AND sl2.del_flag = '0'
WHERE pm.model_id >= 6001 AND pm.del_flag = '0'
ORDER BY pm.model_code;
