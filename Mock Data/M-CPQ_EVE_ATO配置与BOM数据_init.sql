-- =====================================================
-- M-CPQ ATO定制配置 + SBOM/BOM 种子数据 — 亿纬锂能
-- 适用产品：5个关键ATO + 3个STANDARD补充BOM
-- 日期: 2026-07-01
-- 可重复执行（幂等）: 先清理EVE ATO数据再导入
-- 依赖: M-CPQ_EVE_产品数据_init.sql + M-CPQ_EVE_配置引擎数据_init.sql 需先执行
-- 注意: 本脚本依赖配置引擎已创建的属性映射（通过UPDATE补充sbom_line_id）
-- =====================================================

SET NAMES utf8mb4;

-- =====================================================
-- 【幂等清理】删除已有的EVE ATO专属数据
-- =====================================================
-- 清理ATO属性映射（仅为新增的消防方案等，mapping_id 13233-13235）
DELETE FROM cpq_attribute_mapping WHERE mapping_id BETWEEN 13233 AND 13235;
-- 清理ATO配置规则（rule_id 23001-23005）
DELETE FROM cpq_config_rule WHERE rule_id BETWEEN 23001 AND 23999;
-- 清理ATO属性选项（option_id 13101-13116）
DELETE FROM cpq_attribute_option WHERE option_id BETWEEN 13101 AND 13199;
-- 清理SBOM行表（按sbom_header_id范围）
DELETE FROM cpq_sbom_line WHERE sbom_header_id BETWEEN 2074100001 AND 2074109999;
-- 清理SBOM头表
DELETE FROM cpq_sbom_header WHERE sbom_header_id BETWEEN 2074100001 AND 2074109999;
-- 清理产品default_bom_id引用
UPDATE cpq_product_model SET default_bom_id = NULL WHERE model_id IN (2009, 2058, 2091, 2019, 2063, 2138, 2184, 2067) AND default_bom_id BETWEEN 2074100001 AND 2074109999;

-- =====================================================
-- 一、SBOM 头表（cpq_sbom_header）
-- 为5个ATO产品 + 3个STANDARD产品创建BOM头
-- =====================================================

INSERT INTO cpq_sbom_header (sbom_header_id, tenant_id, model_id, sbom_name, sbom_version, status, del_flag, create_time) VALUES
(2074100001, '000000', 2009, 'LF120L 可配置磷酸铁锂电芯 SBOM', '1.0', '0', '0', NOW()),
(2074100002, '000000', 2058, 'CTP-30K 电池包 SBOM', '1.0', '0', '0', NOW()),
(2074100003, '000000', 2091, 'HVI-40.0 高压壁挂储能 SBOM', '1.0', '0', '0', NOW()),
(2074100004, '000000', 2019, 'LF280K 大容量储能电芯 SBOM', '1.0', '0', '0', NOW()),
(2074100005, '000000', 2063, 'LVI-5.0 低压壁挂储能 SBOM', '1.0', '0', '0', NOW()),
(2074100006, '000000', 2138, 'CSP-AA 复合电池组 SBOM', '1.0', '0', '0', NOW()),
(2074100007, '000000', 2184, 'Container-2.5M 储能集装箱 SBOM', '1.0', '0', '0', NOW()),
(2074100008, '000000', 2067, 'LVI-10.0-P 加强版壁挂储能 SBOM', '1.0', '0', '0', NOW());

-- =====================================================
-- 二、SBOM 行表（cpq_sbom_line）
-- =====================================================

-- === LF120L (2009, ATO) SBOM行 ===
INSERT INTO cpq_sbom_line (sbom_line_id, sbom_header_id, tenant_id, line_number, item_code, item_name, item_type, quantity, unit, is_required, is_replaceable, replacement_group, is_phantom, price_impact, del_flag, create_time) VALUES
(2074201001, 2074100001, '000000', 10, 'CELL-LF120L-BASE', 'LF120L 电芯本体（未封装）', 'HOST', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074201002, 2074100001, '000000', 20, 'TAB-AL-STD-120L', '标准铝极耳组件', 'ACCESSORY', 1.0000, 'PCS', '1', '1', 'TAB', '0', 'VARIABLE', '0', NOW()),
(2074201003, 2074100001, '000000', 30, 'TERMINAL-M6-120L', 'M6极柱总成', 'ACCESSORY', 2.0000, 'PCS', '1', '1', 'TERMINAL', '0', 'VARIABLE', '0', NOW()),
(2074201004, 2074100001, '000000', 40, 'VENT-STD-120L', '标准防爆阀组件', 'ACCESSORY', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074201005, 2074100001, '000000', 50, 'ELE-LYTE-STD-120L', '标准电解液', 'MATERIAL', 1.0000, 'LOT', '1', '1', 'ELE', '0', 'VARIABLE', '0', NOW()),
(2074201006, 2074100001, '000000', 60, 'SHELL-AL-120L', '铝壳壳体组件', 'ACCESSORY', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074201007, 2074100001, '000000', 70, 'INSULATION-FILM', '绝缘隔离膜', 'MATERIAL', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074201008, 2074100001, '000000', 80, 'CERT-TEST-LAB', '认证检测服务（充放电/环境/安全）', 'SERVICE', 1.0000, 'LOT', '0', '0', NULL, '0', 'VARIABLE', '0', NOW());

-- === CTP-30K (2058, ATO) SBOM行 ===
INSERT INTO cpq_sbom_line (sbom_line_id, sbom_header_id, tenant_id, line_number, item_code, item_name, item_type, quantity, unit, is_required, is_replaceable, replacement_group, is_phantom, price_impact, del_flag, create_time) VALUES
(2074202001, 2074100002, '000000', 10, 'PACK-FRAME-CTP30K', 'CTP-30K 电池包壳体/框架总成', 'HOST', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074202002, 2074100002, '000000', 20, 'CELL-LF100L-300PCS', 'LF100L电芯×300片（30kWh）', 'ACCESSORY', 300.0000, 'PCS', '1', '1', 'CELL', '0', 'VARIABLE', '0', NOW()),
(2074202003, 2074100002, '000000', 30, 'BMS-CTP30K-BASIC', '基础BMS主控板+从板', 'ACCESSORY', 1.0000, 'SET', '1', '1', 'BMS', '0', 'VARIABLE', '0', NOW()),
(2074202004, 2074100002, '000000', 40, 'COOL-FAN-CTP30K', '强制风冷散热组件（风扇+风道）', 'ACCESSORY', 1.0000, 'SET', '1', '1', 'COOL', '0', 'VARIABLE', '0', NOW()),
(2074202005, 2074100002, '000000', 50, 'HARNESS-HV-CTP30K', '高压线束总成', 'ACCESSORY', 1.0000, 'SET', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074202006, 2074100002, '000000', 60, 'CONNECTOR-HV-CTP30K', '高压连接器（2+2+1配置）', 'ACCESSORY', 5.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074202007, 2074100002, '000000', 70, 'FUSE-MCB-CTP30K', 'MSD手动维护开关+熔断器', 'ACCESSORY', 1.0000, 'SET', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074202008, 2074100002, '000000', 80, 'SEAL-GASKET-CTP30K', '密封垫圈套件（含IP防护）', 'ACCESSORY', 1.0000, 'SET', '0', '0', NULL, '0', 'VARIABLE', '0', NOW()),
(2074202009, 2074100002, '000000', 90, 'SVC-TEST-FAT-CTP30K', '出厂测试（FAT/充放电/绝缘/耐压）', 'SERVICE', 1.0000, 'LOT', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074202010, 2074100002, '000000', 100, 'SVC-CERT-CTP30K', '认证测试服务（GB/ECE/UL）', 'SERVICE', 1.0000, 'LOT', '0', '0', NULL, '0', 'VARIABLE', '0', NOW());

-- === HVI-40.0 (2091, ATO) SBOM行 ===
INSERT INTO cpq_sbom_line (sbom_line_id, sbom_header_id, tenant_id, line_number, item_code, item_name, item_type, quantity, unit, is_required, is_replaceable, replacement_group, is_phantom, price_impact, del_flag, create_time) VALUES
(2074203001, 2074100003, '000000', 10, 'CAB-HVI40K-BASE', 'HVI-40.0 高压储能柜体总成', 'HOST', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074203002, 2074100003, '000000', 20, 'MOD-HVI-4K-STD', '4kWh高压电池模组', 'ACCESSORY', 10.0000, 'PCS', '1', '1', 'MOD', '0', 'VARIABLE', '0', NOW()),
(2074203003, 2074100003, '000000', 30, 'BMS-HVI-ADV-V3', '高级BMS控制板（SOx+AI）', 'ACCESSORY', 1.0000, 'PCS', '1', '1', 'BMS', '0', 'VARIABLE', '0', NOW()),
(2074203004, 2074100003, '000000', 40, 'PCS-HYBRID-8K', '8kW混合储能逆变器', 'ACCESSORY', 1.0000, 'PCS', '1', '1', 'INVERTER', '0', 'VARIABLE', '0', NOW()),
(2074203005, 2074100003, '000000', 50, 'ENCLOSURE-HVI-IP55', 'IP55防护外壳', 'ACCESSORY', 1.0000, 'PCS', '1', '1', 'ENCLOSE', '0', 'VARIABLE', '0', NOW()),
(2074203006, 2074100003, '000000', 60, 'HV-CABLE-SET', '高压线缆套件（正/负/通讯线）', 'ACCESSORY', 1.0000, 'SET', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074203007, 2074100003, '000000', 70, 'BREAKER-HVI-80A', '80A高压直流断路器', 'ACCESSORY', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074203008, 2074100003, '000000', 80, 'FIRE-SUPPRESS-HVI', '气溶胶消防模块', 'ACCESSORY', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074203009, 2074100003, '000000', 90, 'EMS-GATEWAY', '能源管理网关（含4G/WiFi）', 'ACCESSORY', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074203010, 2074100003, '000000', 100, 'SVC-INSTALL-HVI', '高压储能安装调试服务', 'SERVICE', 1.0000, 'DAY', '0', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074203011, 2074100003, '000000', 110, 'SVC-WARRANTY-5Y', '5年标准质保服务', 'SERVICE', 1.0000, 'EA', '0', '0', NULL, '0', 'VARIABLE', '0', NOW());

-- === LF280K (2019, STANDARD) SBOM行 ===
INSERT INTO cpq_sbom_line (sbom_line_id, sbom_header_id, tenant_id, line_number, item_code, item_name, item_type, quantity, unit, is_required, is_replaceable, replacement_group, is_phantom, price_impact, del_flag, create_time) VALUES
(2074204001, 2074100004, '000000', 10, 'CELL-LF280K-BASE', 'LF280K 电芯本体（标准配方）', 'HOST', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074204002, 2074100004, '000000', 20, 'TERMINAL-M6-SINGLE', 'M6单极柱总成（正极+负极）', 'ACCESSORY', 2.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074204003, 2074100004, '000000', 30, 'VENT-STD-280K', '标准0.8MPa防爆阀', 'ACCESSORY', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074204004, 2074100004, '000000', 40, 'TAB-AL-STD-280K', '标准铝极耳（正极+负极）', 'ACCESSORY', 2.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074204005, 2074100004, '000000', 50, 'SHELL-AL-280K', '铝壳壳体（含盖板焊接）', 'ACCESSORY', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074204006, 2074100004, '000000', 60, 'INSULATION-SET-280K', '绝缘保护套件', 'MATERIAL', 1.0000, 'SET', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074204007, 2074100004, '000000', 70, 'PACKAGE-TRAY-280K', '240片标准托盘包装', 'PACKAGE', 1.0000, 'LOT', '1', '0', NULL, '0', 'FIXED', '0', NOW());

-- === LVI-5.0 (2063, STANDARD) SBOM行 ===
INSERT INTO cpq_sbom_line (sbom_line_id, sbom_header_id, tenant_id, line_number, item_code, item_name, item_type, quantity, unit, is_required, is_replaceable, replacement_group, is_phantom, price_impact, del_flag, create_time) VALUES
(2074205001, 2074100005, '000000', 10, 'CAB-LVI5K-BASE', 'LVI-5.0 储能主机壳体', 'HOST', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074205002, 2074100005, '000000', 20, 'CELL-LF100LA-16PCS', 'LF100LA电芯×16片（5.12kWh）', 'ACCESSORY', 16.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074205003, 2074100005, '000000', 30, 'BMS-LVI5K-BASIC', 'LVI系列基础BMS板', 'ACCESSORY', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074205004, 2074100005, '000000', 40, 'DC-BREAKER-125A', '125A直流断路器', 'ACCESSORY', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074205005, 2074100005, '000000', 50, 'CAN-MODULE', 'CAN 2.0B通信模块', 'ACCESSORY', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074205006, 2074100005, '000000', 60, 'LED-INDICATOR', 'LED状态指示灯面板', 'ACCESSORY', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074205007, 2074100005, '000000', 70, 'WALL-MOUNT-KIT', '壁挂安装套件', 'ACCESSORY', 1.0000, 'SET', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074205008, 2074100005, '000000', 80, 'PACKAGE-LVI5K', 'LVI-5.0出口包装（纸箱+泡沫+木托）', 'PACKAGE', 1.0000, 'SET', '1', '0', NULL, '0', 'FIXED', '0', NOW());

-- === CSP-AA (2138, STANDARD) SBOM行 ===
INSERT INTO cpq_sbom_line (sbom_line_id, sbom_header_id, tenant_id, line_number, item_code, item_name, item_type, quantity, unit, is_required, is_replaceable, replacement_group, is_phantom, price_impact, del_flag, create_time) VALUES
(2074206001, 2074100006, '000000', 10, 'CELL-ER14505', 'ER14505 锂亚电池 2700mAh', 'HOST', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074206002, 2074100006, '000000', 20, 'SPC1520', 'SPC1520 超级电容 15F', 'ACCESSORY', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074206003, 2074100006, '000000', 30, 'PCB-CSP-AA', 'CSP-AA集成PCB板（含保护电路）', 'ACCESSORY', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074206004, 2074100006, '000000', 40, 'CONNECTOR-JST-2P', 'JST 2P输出连接器含线缆', 'ACCESSORY', 1.0000, 'SET', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074206005, 2074100006, '000000', 50, 'HEAT-SHRINK', '热缩管封装材料', 'MATERIAL', 1.0000, 'SET', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074206006, 2074100006, '000000', 60, 'PACKAGE-CSP-AA', 'CSP-AA工业包装（100只/箱）', 'PACKAGE', 1.0000, 'LOT', '1', '0', NULL, '0', 'FIXED', '0', NOW());

-- === Container-2.5M (2184, STANDARD) SBOM行 ===
INSERT INTO cpq_sbom_line (sbom_line_id, sbom_header_id, tenant_id, line_number, item_code, item_name, item_type, quantity, unit, is_required, is_replaceable, replacement_group, is_phantom, price_impact, del_flag, create_time) VALUES
(2074207001, 2074100007, '000000', 10, 'CONT-20FT-STD', '20尺标准集装箱（含底座）', 'HOST', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074207002, 2074100007, '000000', 20, 'MOD-1P48S-X80', '1P48S储能模组×80组（2.5MWh）', 'ACCESSORY', 80.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074207003, 2074100007, '000000', 30, 'PCS-500K-X5', '500kW PCS逆变器×5台', 'ACCESSORY', 5.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074207004, 2074100007, '000000', 40, 'EMS-CONT-2.5M', 'EMS能源管理系统（含调度通信）', 'ACCESSORY', 1.0000, 'SET', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074207005, 2074100007, '000000', 50, 'TRANSFORMER-3150KVA', '3150kVA升压变压器', 'ACCESSORY', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074207006, 2074100007, '000000', 60, 'HV-SWITCHGEAR', '35kV高压开关柜', 'ACCESSORY', 1.0000, 'SET', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074207007, 2074100007, '000000', 70, 'FIRE-SYSTEM-CONT', '集装箱消防系统（七氟丙烷+烟感+温感）', 'ACCESSORY', 1.0000, 'SET', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074207008, 2074100007, '000000', 80, 'HVAC-CONT-20FT', '20尺集装箱空调系统', 'ACCESSORY', 2.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074207009, 2074100007, '000000', 90, 'CABLE-TRAY-CONT', '集装箱内部电缆桥架', 'ACCESSORY', 1.0000, 'SET', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074207010, 2074100007, '000000', 100, 'SVC-COMMISSION-CONT', '集装箱储能系统调试并网服务', 'SERVICE', 1.0000, 'LOT', '0', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074207011, 2074100007, '000000', 110, 'SVC-WARRANTY-10Y', '10年质保服务（含运维）', 'SERVICE', 1.0000, 'EA', '0', '0', NULL, '0', 'VARIABLE', '0', NOW());

-- === LVI-10.0-P (2067, ATO) SBOM行 ===
INSERT INTO cpq_sbom_line (sbom_line_id, sbom_header_id, tenant_id, line_number, item_code, item_name, item_type, quantity, unit, is_required, is_replaceable, replacement_group, is_phantom, price_impact, del_flag, create_time) VALUES
(2074208001, 2074100008, '000000', 10, 'CAB-LVI10K-BASE', 'LVI-10.0 储能主机壳体（IP67）', 'HOST', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074208002, 2074100008, '000000', 20, 'CELL-LF100LA-32PCS', 'LF100LA电芯×32片（10.24kWh）', 'ACCESSORY', 32.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074208003, 2074100008, '000000', 30, 'BMS-LVI10K-BASIC', 'LVI系列BMS板（双从板）', 'ACCESSORY', 1.0000, 'SET', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074208004, 2074100008, '000000', 40, 'HEAT-PAD-LVI10K', '自加热膜组件（-20°C~55°C）', 'ACCESSORY', 2.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074208005, 2074100008, '000000', 50, 'DC-BREAKER-200A', '200A直流断路器', 'ACCESSORY', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074208006, 2074100008, '000000', 60, 'SEAL-IP67-KIT', 'IP67密封套件（含呼吸阀/密封圈）', 'ACCESSORY', 1.0000, 'SET', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074208007, 2074100008, '000000', 70, 'CAN-RS485-DUAL', 'CAN+RS485双通信模块', 'ACCESSORY', 1.0000, 'SET', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2074208008, 2074100008, '000000', 80, 'PACKAGE-LVI10K', 'LVI-10.0出口包装', 'PACKAGE', 1.0000, 'SET', '1', '0', NULL, '0', 'FIXED', '0', NOW());


-- =====================================================
-- 三、更新产品 default_bom_id
-- =====================================================

UPDATE cpq_product_model SET default_bom_id = 2074100001 WHERE model_id = 2009;
UPDATE cpq_product_model SET default_bom_id = 2074100002 WHERE model_id = 2058;
UPDATE cpq_product_model SET default_bom_id = 2074100003 WHERE model_id = 2091;
UPDATE cpq_product_model SET default_bom_id = 2074100004 WHERE model_id = 2019;
UPDATE cpq_product_model SET default_bom_id = 2074100005 WHERE model_id = 2063;
UPDATE cpq_product_model SET default_bom_id = 2074100006 WHERE model_id = 2138;
UPDATE cpq_product_model SET default_bom_id = 2074100007 WHERE model_id = 2184;
UPDATE cpq_product_model SET default_bom_id = 2074100008 WHERE model_id = 2067;


-- =====================================================
-- 四、ATO 属性选项（cpq_attribute_option）— 额外的BOM导向属性
-- 为LF120L/CTP-30K/HVI-40.0 补充深度可配置属性
-- =====================================================

-- === LF120L (2009, ATO) — 补充BOM级别属性 ===
INSERT INTO cpq_attribute_option (option_id, tenant_id, model_id, attr_name, option_code, option_label, option_value, is_default, sort_order, del_flag, create_time, remark) VALUES
(13101, '000000', 2009, '壳体颜色', 'BLUE_SHELL', '经典蓝壳', 'BLUE_SHELL', '1', 1, '0', NOW(), 'LFP标准蓝铝壳'),
(13102, '000000', 2009, '壳体颜色', 'BLACK_SHELL', '黑色铝壳', 'BLACK_SHELL', '0', 2, '0', NOW(), '客户定制色'),
(13103, '000000', 2009, '壳体颜色', 'SILVER_SHELL', '银灰铝壳', 'SILVER_SHELL', '0', 3, '0', NOW(), '自然铝色，无喷涂'),
(13104, '000000', 2009, '分容匹配', 'MATCH_1PCT', '1%容量匹配', 'MATCH_1PCT', '1', 1, '0', NOW(), '标准匹配±1%'),
(13105, '000000', 2009, '分容匹配', 'MATCH_0.5PCT', '0.5%容量匹配（精密）', 'MATCH_0.5PCT', '0', 2, '0', NOW(), '精密匹配，+5%价格'),
(13106, '000000', 2009, '分容匹配', 'MATCH_0.2PCT', '0.2%容量匹配（军工级）', 'MATCH_0.2PCT', '0', 3, '0', NOW(), '军工级匹配，+15%价格');

-- === HVI-40.0 (2091, ATO) — 补充BOM级别属性 ===
INSERT INTO cpq_attribute_option (option_id, tenant_id, model_id, attr_name, option_code, option_label, option_value, is_default, sort_order, del_flag, create_time, remark) VALUES
(13111, '000000', 2091, '消防方案', 'AEROSOL_STD', '气溶胶灭火（标准）', 'AEROSOL_STD', '1', 1, '0', NOW(), '内置气溶胶消防模块'),
(13112, '000000', 2091, '消防方案', 'FM200', 'FM200/七氟丙烷灭火', 'FM200', '0', 2, '0', NOW(), '精密灭火，适合贵重设备区，+15%价格'),
(13113, '000000', 2091, '消防方案', 'WATER_MIST', '高压细水雾灭火', 'WATER_MIST', '0', 3, '0', NOW(), '持续冷却+灭火，+20%价格'),
(13114, '000000', 2091, '通信方式', '4G', '4G蜂窝网络', '4G', '1', 1, '0', NOW(), '标准4G通信'),
(13115, '000000', 2091, '通信方式', 'WIFI_4G', 'WiFi+4G双模', 'WIFI_4G', '0', 2, '0', NOW(), '家庭WiFi为主+4G备份'),
(13116, '000000', 2091, '通信方式', 'ETHERNET_4G', '以太网+4G双模', 'ETHERNET_4G', '0', 3, '0', NOW(), '有线以太网+4G备份，适合商业');


-- =====================================================
-- 五、ATO 配置规则（cpq_config_rule）— 深度约束
-- =====================================================

INSERT INTO cpq_config_rule (rule_id, tenant_id, rule_name, rule_type, model_id, condition_expr, action_expr, error_message, severity, priority, effective_date, status, del_flag, create_time, remark) VALUES
(23001, '000000', '精密匹配需宽温域', 'VALIDATION', 2009,
 '{"attr":"分容匹配","op":"in","value":["MATCH_0.5PCT","MATCH_0.2PCT"]}',
 '{"require":{"attr":"工作温度","in":["WIDE","ULTRA"]}}',
 '精密匹配电芯通常用于严苛环境，需匹配宽温域配方', 'WARNING', 70, '2025-01-01', '0', '0', NOW(), '匹配-温域一致性'),
(23002, '000000', '军工级匹配需超长寿命', 'VALIDATION', 2009,
 '{"attr":"分容匹配","op":"EQUALS","value":"MATCH_0.2PCT"}',
 '{"require":{"attr":"循环等级","value":"ULTRA_8000"}}',
 '军工级0.2%匹配必须使用8000次超长寿命配方', 'ERROR', 90, '2025-01-01', '0', '0', NOW(), '军工品质一致要求'),
(23003, '000000', 'FM200需以太网通信', 'SELECTION', 2091,
 '{"attr":"消防方案","op":"EQUALS","value":"FM200"}',
 '{"recommend":{"attr":"通信方式","value":"ETHERNET_4G"}}',
 NULL, 'INFO', 40, '2025-01-01', '0', '0', NOW(), '精密消防需高可靠通信'),
(23004, '000000', '细水雾灭火需IP67', 'VALIDATION', 2091,
 '{"attr":"消防方案","op":"EQUALS","value":"WATER_MIST"}',
 '{"require":{"attr":"防护等级","value":"IP67"}}',
 '细水雾灭火系统需IP67全密封壳体防止水侵入电子器件', 'ERROR', 100, '2025-01-01', '0', '0', NOW(), '水消防-防护匹配'),
(23005, '000000', '以太网通信需高级BMS', 'SELECTION', 2091,
 '{"attr":"通信方式","op":"EQUALS","value":"ETHERNET_4G"}',
 '{"recommend":{"attr":"BMS功能","value":"PREMIUM"}}',
 NULL, 'INFO', 60, '2025-01-01', '0', '0', NOW(), '有线通信+旗舰BMS=完整智能方案');


-- =====================================================
-- 六、ATO 属性映射（cpq_attribute_mapping）— BOM级别物料映射
-- =====================================================

-- LF120L (2009) 映射
INSERT INTO cpq_attribute_mapping (mapping_id, tenant_id, model_id, attr_name, attr_value, material_code, sbom_line_id, del_flag, create_time, remark) VALUES
(13201, '000000', 2009, '壳体颜色', 'BLUE_SHELL', 'SHELL-AL-BLUE-120L', 2074201006, '0', NOW(), '蓝铝壳'),
(13202, '000000', 2009, '壳体颜色', 'BLACK_SHELL', 'SHELL-AL-BLACK-120L', NULL, '0', NOW(), '黑铝壳'),
(13203, '000000', 2009, '壳体颜色', 'SILVER_SHELL', 'SHELL-AL-SILVER-120L', NULL, '0', NOW(), '银灰铝壳'),
(13204, '000000', 2009, '分容匹配', 'MATCH_1PCT', 'SERVICE-MATCH-1PCT', NULL, '0', NOW(), '标准1%分容'),
(13205, '000000', 2009, '分容匹配', 'MATCH_0.5PCT', 'SERVICE-MATCH-0.5PCT', NULL, '0', NOW(), '精密0.5%分容'),
(13206, '000000', 2009, '分容匹配', 'MATCH_0.2PCT', 'SERVICE-MATCH-0.2PCT', NULL, '0', NOW(), '军工0.2%分容');

-- CTP-30K (2058) 映射— 更新BOM级关联（配置引擎已创建属性映射，此处仅补 sbom_line_id）
UPDATE cpq_attribute_mapping SET sbom_line_id = 2074202002, material_code = 'CELL-LF100L-300PCS' WHERE tenant_id = '000000' AND model_id = 2058 AND attr_name = '电芯选型' AND attr_value = 'LF100L';
UPDATE cpq_attribute_mapping SET sbom_line_id = NULL, material_code = 'CELL-LF100LA-300PCS' WHERE tenant_id = '000000' AND model_id = 2058 AND attr_name = '电芯选型' AND attr_value = 'LF100LA';
UPDATE cpq_attribute_mapping SET sbom_line_id = NULL, material_code = 'CELL-LF120L-300PCS' WHERE tenant_id = '000000' AND model_id = 2058 AND attr_name = '电芯选型' AND attr_value = 'LF120L';
UPDATE cpq_attribute_mapping SET sbom_line_id = 2074202003, material_code = 'BMS-CTP30K-BASIC' WHERE tenant_id = '000000' AND model_id = 2058 AND attr_name = 'BMS选型' AND attr_value = 'BMS_BASIC';
UPDATE cpq_attribute_mapping SET sbom_line_id = NULL, material_code = 'BMS-CTP30K-ACTIVE' WHERE tenant_id = '000000' AND model_id = 2058 AND attr_name = 'BMS选型' AND attr_value = 'BMS_ACTIVE';
UPDATE cpq_attribute_mapping SET sbom_line_id = NULL, material_code = 'BMS-CTP30K-AI-4G' WHERE tenant_id = '000000' AND model_id = 2058 AND attr_name = 'BMS选型' AND attr_value = 'BMS_AI';
UPDATE cpq_attribute_mapping SET sbom_line_id = 2074202004, material_code = 'COOL-FAN-CTP30K' WHERE tenant_id = '000000' AND model_id = 2058 AND attr_name = '冷却方式' AND attr_value = 'AIR_COOL';
UPDATE cpq_attribute_mapping SET sbom_line_id = NULL, material_code = 'COOL-PLATE-CTP30K' WHERE tenant_id = '000000' AND model_id = 2058 AND attr_name = '冷却方式' AND attr_value = 'LIQUID_COOL';
UPDATE cpq_attribute_mapping SET sbom_line_id = NULL, material_code = 'COOL-COMP-CTP30K' WHERE tenant_id = '000000' AND model_id = 2058 AND attr_name = '冷却方式' AND attr_value = 'REFRIG';

-- HVI-40.0 (2091) 映射— 更新BOM级关联
UPDATE cpq_attribute_mapping SET sbom_line_id = 2074203002, material_code = 'MOD-HVI-4K-QTY10' WHERE tenant_id = '000000' AND model_id = 2091 AND attr_name = '电池模组数' AND attr_value = 'MOD10';
UPDATE cpq_attribute_mapping SET sbom_line_id = NULL, material_code = 'MOD-HVI-4K-QTY8' WHERE tenant_id = '000000' AND model_id = 2091 AND attr_name = '电池模组数' AND attr_value = 'MOD8';
UPDATE cpq_attribute_mapping SET sbom_line_id = NULL, material_code = 'MOD-HVI-4K-QTY12' WHERE tenant_id = '000000' AND model_id = 2091 AND attr_name = '电池模组数' AND attr_value = 'MOD12';
UPDATE cpq_attribute_mapping SET sbom_line_id = 2074203003, material_code = 'BMS-HVI-BASIC-V3' WHERE tenant_id = '000000' AND model_id = 2091 AND attr_name = 'BMS功能' AND attr_value = 'BASIC';
UPDATE cpq_attribute_mapping SET sbom_line_id = NULL, material_code = 'BMS-HVI-ADV-V3' WHERE tenant_id = '000000' AND model_id = 2091 AND attr_name = 'BMS功能' AND attr_value = 'ADVANCED';
UPDATE cpq_attribute_mapping SET sbom_line_id = NULL, material_code = 'BMS-HVI-PREMIUM-V3' WHERE tenant_id = '000000' AND model_id = 2091 AND attr_name = 'BMS功能' AND attr_value = 'PREMIUM';
UPDATE cpq_attribute_mapping SET sbom_line_id = 2074203005, material_code = 'ENCLOSURE-HVI-IP55' WHERE tenant_id = '000000' AND model_id = 2091 AND attr_name = '防护等级' AND attr_value = 'IP55';
UPDATE cpq_attribute_mapping SET sbom_line_id = NULL, material_code = 'ENCLOSURE-HVI-IP65' WHERE tenant_id = '000000' AND model_id = 2091 AND attr_name = '防护等级' AND attr_value = 'IP65';
UPDATE cpq_attribute_mapping SET sbom_line_id = NULL, material_code = 'ENCLOSURE-HVI-IP67' WHERE tenant_id = '000000' AND model_id = 2091 AND attr_name = '防护等级' AND attr_value = 'IP67';
UPDATE cpq_attribute_mapping SET sbom_line_id = 2074203004, material_code = 'PCS-HYBRID-8K' WHERE tenant_id = '000000' AND model_id = 2091 AND attr_name = '逆变器匹配' AND attr_value = 'SOLAR_8K';
UPDATE cpq_attribute_mapping SET sbom_line_id = NULL, material_code = 'PCS-HYBRID-15K' WHERE tenant_id = '000000' AND model_id = 2091 AND attr_name = '逆变器匹配' AND attr_value = 'SOLAR_15K';
UPDATE cpq_attribute_mapping SET sbom_line_id = NULL, material_code = 'PCS-HYBRID-25K' WHERE tenant_id = '000000' AND model_id = 2091 AND attr_name = '逆变器匹配' AND attr_value = 'SOLAR_25K';
-- HVI-40.0 新增消防方案映射（配置引擎中不存在）
INSERT INTO cpq_attribute_mapping (mapping_id, tenant_id, model_id, attr_name, attr_value, material_code, sbom_line_id, del_flag, create_time, remark) VALUES
(13233, '000000', 2091, '消防方案', 'AEROSOL_STD', 'FIRE-AEROSOL-STD', 2074203008, '0', NOW(), '气溶胶消防'),
(13234, '000000', 2091, '消防方案', 'FM200', 'FIRE-FM200', NULL, '0', NOW(), 'FM200消防'),
(13235, '000000', 2091, '消防方案', 'WATER_MIST', 'FIRE-WATER-MIST', NULL, '0', NOW(), '高压细水雾');


-- =====================================================
-- 七、统计数据
-- =====================================================
-- SBOM头表:     8条
-- SBOM行表:     69条
-- ATO属性选项:  补充12条（含壳体颜色/分容匹配/消防方案/通信方式）
-- ATO配置规则:  补充5条
-- ATO属性映射:  更新 21条（与配置引擎共建）+ 新增 3条（消防方案）
-- default_bom_id更新: 8个产品
-- =====================================================
