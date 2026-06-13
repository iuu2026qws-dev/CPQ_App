-- =====================================================
-- M-CPQ ATO定制配置 + SBOM/BOM 种子数据
-- 适用产品：4个关键ATO + 3个STANDARD补充BOM
-- 日期: 2026-06-13
-- 依赖: M-CPQ_产品数据_init.sql 已导入
-- =====================================================

SET NAMES utf8mb4;

-- =====================================================
-- 一、SBOM 头表（cpq_sbom_header）
-- 为4个ATO产品 + 3个STANDARD产品创建BOM头
-- =====================================================

INSERT INTO cpq_sbom_header (sbom_header_id, tenant_id, model_id, sbom_name, sbom_version, status, del_flag, create_time) VALUES
(2064100001, '000000', 1003, 'ARC-200P 增强型弧焊机器人 SBOM', '1.0', '0', '0', NOW()),
(2064100002, '000000', 1006, 'SPOT-210D 双枪点焊机器人 SBOM', '1.0', '0', '0', NOW()),
(2064100003, '000000', 1008, 'LASER-2K 光纤激光焊接机器人 SBOM', '1.0', '0', '0', NOW()),
(2064100004, '000000', 1023, 'CoBot-10 大负载协作机器人 SBOM', '1.0', '0', '0', NOW()),
(2064100005, '000000', 1002, 'ARC-200 标准型弧焊机器人 SBOM', '1.0', '0', '0', NOW()),
(2064100006, '000000', 1011, 'PAL-120 标准码垛机器人 SBOM', '1.0', '0', '0', NOW()),
(2064100007, '000000', 1021, 'CoBot-03 桌面协作机器人 SBOM', '1.0', '0', '0', NOW());

-- =====================================================
-- 二、SBOM 行表（cpq_sbom_line）
-- =====================================================

-- === ARC-200P (1003, ATO) SBOM行 ===
INSERT INTO cpq_sbom_line (sbom_line_id, sbom_header_id, tenant_id, line_number, item_code, item_name, item_type, quantity, unit, is_required, is_replaceable, replacement_group, is_phantom, price_impact, del_flag, create_time) VALUES
(2064201001, 2064100001, '000000', 10, 'MAT-HOST-ARC200P', 'ARC-200P 弧焊机器人主机', 'HOST', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2064201002, 2064100001, '000000', 20, 'MAT-WELD-PWR-A', 'FANUC 500A 焊接电源', 'ACCESSORY', 1.0000, 'PCS', '1', '1', 'WELD_PWR', '0', 'VARIABLE', '0', NOW()),
(2064201003, 2064100001, '000000', 30, 'MAT-TORCH-500W', '500A 水冷焊枪总成', 'ACCESSORY', 1.0000, 'PCS', '1', '1', 'TORCH', '0', 'VARIABLE', '0', NOW()),
(2064201004, 2064100001, '000000', 40, 'MAT-WIRE-FEED', '双丝送丝机构', 'ACCESSORY', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2064201005, 2064100001, '000000', 50, 'MAT-SEAM-TRACK', '激光焊缝跟踪系统', 'ACCESSORY', 1.0000, 'PCS', '1', '1', 'SEAM_TRACK', '0', 'VARIABLE', '0', NOW()),
(2064201006, 2064100001, '000000', 60, 'MAT-CONTROL-ARC', '弧焊专用控制器', 'HOST', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2064201007, 2064100001, '000000', 70, 'SVC-INSTALL-ARC', '弧焊机器人安装调试服务', 'SERVICE', 1.0000, 'DAY', '0', '0', NULL, '0', 'FIXED', '0', NOW()),
(2064201008, 2064100001, '000000', 80, 'SVC-WARRANTY-3Y', '3年延保服务', 'SERVICE', 1.0000, 'EA', '0', '0', NULL, '0', 'VARIABLE', '0', NOW());

-- === SPOT-210D (1006, ATO) SBOM行 ===
INSERT INTO cpq_sbom_line (sbom_line_id, sbom_header_id, tenant_id, line_number, item_code, item_name, item_type, quantity, unit, is_required, is_replaceable, replacement_group, is_phantom, price_impact, del_flag, create_time) VALUES
(2064202001, 2064100002, '000000', 10, 'MAT-HOST-SPOT210D', 'SPOT-210D 点焊机器人主机', 'HOST', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2064202002, 2064100002, '000000', 20, 'MAT-SERVO-GUN-A', '伺服焊枪A（主焊枪）', 'ACCESSORY', 1.0000, 'PCS', '1', '1', 'GUN_A', '0', 'VARIABLE', '0', NOW()),
(2064202003, 2064100002, '000000', 30, 'MAT-SERVO-GUN-B', '伺服焊枪B（副焊枪）', 'ACCESSORY', 1.0000, 'PCS', '1', '1', 'GUN_B', '0', 'VARIABLE', '0', NOW()),
(2064202004, 2064100002, '000000', 40, 'MAT-WELD-TIMER', '双通道焊接时序控制器', 'ACCESSORY', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2064202005, 2064100002, '000000', 50, 'MAT-TIP-DRESS', '自动修磨器', 'ACCESSORY', 2.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2064202006, 2064100002, '000000', 60, 'MAT-COOL-WATER', '双通道水冷系统', 'ACCESSORY', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2064202007, 2064100002, '000000', 70, 'SVC-INSTALL-SPOT', '点焊线安装调试', 'SERVICE', 1.0000, 'DAY', '0', '0', NULL, '0', 'FIXED', '0', NOW());

-- === LASER-2K (1008, ATO) SBOM行 ===
INSERT INTO cpq_sbom_line (sbom_line_id, sbom_header_id, tenant_id, line_number, item_code, item_name, item_type, quantity, unit, is_required, is_replaceable, replacement_group, is_phantom, price_impact, del_flag, create_time) VALUES
(2064203001, 2064100003, '000000', 10, 'MAT-HOST-LASER2K', 'LASER-2K 激光焊接主机', 'HOST', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2064203002, 2064100003, '000000', 20, 'MAT-LASER-SRC-2K', '2kW 光纤激光源', 'ACCESSORY', 1.0000, 'PCS', '1', '1', 'LASER_SRC', '0', 'VARIABLE', '0', NOW()),
(2064203003, 2064100003, '000000', 30, 'MAT-WOBBLE-HEAD', '摆动焊接头', 'ACCESSORY', 1.0000, 'PCS', '1', '1', 'WELD_HEAD', '0', 'VARIABLE', '0', NOW()),
(2064203004, 2064100003, '000000', 40, 'MAT-CHILLER-5KW', '5kW 工业冷水机', 'ACCESSORY', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2064203005, 2064100003, '000000', 50, 'MAT-FUME-EXT', '激光焊接烟尘净化器', 'ACCESSORY', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2064203006, 2064100003, '000000', 60, 'MAT-SAFETY-ENCL', '激光安全防护罩', 'ACCESSORY', 1.0000, 'PCS', '1', '1', 'SAFETY', '0', 'VARIABLE', '0', NOW()),
(2064203007, 2064100003, '000000', 70, 'LIC-WELD-PROC', '激光焊接工艺数据库许可', 'LICENSE', 1.0000, 'EA', '0', '0', NULL, '0', 'FIXED', '0', NOW());

-- === CoBot-10 (1023, ATO) SBOM行 ===
INSERT INTO cpq_sbom_line (sbom_line_id, sbom_header_id, tenant_id, line_number, item_code, item_name, item_type, quantity, unit, is_required, is_replaceable, replacement_group, is_phantom, price_impact, del_flag, create_time) VALUES
(2064204001, 2064100004, '000000', 10, 'MAT-HOST-CB10', 'CoBot-10 协作机器人主机', 'HOST', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2064204002, 2064100004, '000000', 20, 'MAT-GRIPPER-A', '电动平行夹爪', 'ACCESSORY', 1.0000, 'PCS', '1', '1', 'GRIPPER', '0', 'VARIABLE', '0', NOW()),
(2064204003, 2064100004, '000000', 30, 'MAT-CAM-VISION', '2D视觉引导系统', 'ACCESSORY', 1.0000, 'PCS', '0', '0', NULL, '0', 'VARIABLE', '0', NOW()),
(2064204004, 2064100004, '000000', 40, 'MAT-CONTROL-CB', '协作机器人控制器', 'HOST', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2064204005, 2064100004, '000000', 50, 'MAT-PENDANT', '示教器（触屏）', 'ACCESSORY', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2064204006, 2064100004, '000000', 60, 'SVC-TRAIN-CB', '协作机器人操作培训', 'SERVICE', 1.0000, 'DAY', '0', '0', NULL, '0', 'FIXED', '0', NOW());

-- === ARC-200 (1002, STANDARD) SBOM行 ===
INSERT INTO cpq_sbom_line (sbom_line_id, sbom_header_id, tenant_id, line_number, item_code, item_name, item_type, quantity, unit, is_required, is_replaceable, replacement_group, is_phantom, price_impact, del_flag, create_time) VALUES
(2064205001, 2064100005, '000000', 10, 'MAT-HOST-ARC200', 'ARC-200 弧焊机器人主机', 'HOST', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2064205002, 2064100005, '000000', 20, 'MAT-WELD-PWR-400', 'FANUC 400A 焊接电源', 'ACCESSORY', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2064205003, 2064100005, '000000', 30, 'MAT-TORCH-400A', '400A 气冷焊枪总成', 'ACCESSORY', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2064205004, 2064100005, '000000', 40, 'MAT-WIRE-SINGLE', '单丝送丝机构', 'ACCESSORY', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2064205005, 2064100005, '000000', 50, 'MAT-CONTROL-ARC-M', 'MIG/MAG 焊接控制器', 'HOST', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2064205006, 2064100005, '000000', 60, 'SVC-INSTALL-STD', '标准安装调试服务', 'SERVICE', 1.0000, 'DAY', '0', '0', NULL, '0', 'FIXED', '0', NOW());

-- === PAL-120 (1011, STANDARD) SBOM行 ===
INSERT INTO cpq_sbom_line (sbom_line_id, sbom_header_id, tenant_id, line_number, item_code, item_name, item_type, quantity, unit, is_required, is_replaceable, replacement_group, is_phantom, price_impact, del_flag, create_time) VALUES
(2064206001, 2064100006, '000000', 10, 'MAT-HOST-PAL120', 'PAL-120 码垛机器人主机', 'HOST', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2064206002, 2064100006, '000000', 20, 'MAT-GRIP-PNEU', '气动码垛夹爪', 'ACCESSORY', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2064206003, 2064100006, '000000', 30, 'MAT-PALLET-DISP', '托盘自动分配机', 'ACCESSORY', 1.0000, 'PCS', '0', '0', NULL, '0', 'VARIABLE', '0', NOW()),
(2064206004, 2064100006, '000000', 40, 'MAT-CONVEYOR-2M', '2m 进料输送带', 'ACCESSORY', 1.0000, 'PCS', '0', '0', NULL, '0', 'VARIABLE', '0', NOW()),
(2064206005, 2064100006, '000000', 50, 'MAT-CONTROL-PAL', '码垛专用控制器', 'HOST', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2064206006, 2064100006, '000000', 60, 'SVC-INSTALL-PAL', '码垛线安装调试', 'SERVICE', 1.0000, 'DAY', '0', '0', NULL, '0', 'FIXED', '0', NOW());

-- === CoBot-03 (1021, STANDARD) SBOM行 ===
INSERT INTO cpq_sbom_line (sbom_line_id, sbom_header_id, tenant_id, line_number, item_code, item_name, item_type, quantity, unit, is_required, is_replaceable, replacement_group, is_phantom, price_impact, del_flag, create_time) VALUES
(2064207001, 2064100007, '000000', 10, 'MAT-HOST-CB03', 'CoBot-03 协作机器人主机', 'HOST', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2064207002, 2064100007, '000000', 20, 'MAT-GRIP-MINI', '微型电动夹爪', 'ACCESSORY', 1.0000, 'PCS', '0', '0', NULL, '0', 'VARIABLE', '0', NOW()),
(2064207003, 2064100007, '000000', 30, 'MAT-CONTROL-CB03', '桌面控制器', 'HOST', 1.0000, 'PCS', '1', '0', NULL, '0', 'FIXED', '0', NOW()),
(2064207004, 2064100007, '000000', 40, 'MAT-SUCTION-CUP', '真空吸盘套件', 'ACCESSORY', 1.0000, 'PCS', '0', '0', NULL, '0', 'VARIABLE', '0', NOW()),
(2064207005, 2064100007, '000000', 50, 'SW-ROBOSTUDIO-LT', 'RobotStudio LT 编程软件', 'SOFTWARE', 1.0000, 'EA', '1', '0', NULL, '0', 'FIXED', '0', NOW());

-- =====================================================
-- 三、更新产品 default_bom_id
-- =====================================================

UPDATE cpq_product_model SET default_bom_id = 2064100001 WHERE model_id = 1003;
UPDATE cpq_product_model SET default_bom_id = 2064100002 WHERE model_id = 1006;
UPDATE cpq_product_model SET default_bom_id = 2064100003 WHERE model_id = 1008;
UPDATE cpq_product_model SET default_bom_id = 2064100004 WHERE model_id = 1023;
UPDATE cpq_product_model SET default_bom_id = 2064100005 WHERE model_id = 1002;
UPDATE cpq_product_model SET default_bom_id = 2064100006 WHERE model_id = 1011;
UPDATE cpq_product_model SET default_bom_id = 2064100007 WHERE model_id = 1021;

-- =====================================================
-- 四、ATO 属性选项（cpq_attribute_option）
-- 为 4 个关键 ATO 产品添加可配置属性
-- =====================================================

-- === ARC-200P (1003, ATO) ===
INSERT INTO cpq_attribute_option (option_id, tenant_id, model_id, attr_name, option_code, option_label, option_value, is_default, sort_order, del_flag, create_time, remark) VALUES
(11001, '000000', 1003, '焊接工艺', 'MIG', 'MIG 熔化极气体保护焊', 'MIG', '1', 1, '0', NOW(), 'CO2/Ar+CO2混合气体保护'),
(11002, '000000', 1003, '焊接工艺', 'MAG', 'MAG 活性气体保护焊', 'MAG', '0', 2, '0', NOW(), 'Ar+O2/CO2活性气体'),
(11003, '000000', 1003, '焊接工艺', 'TIG', 'TIG 钨极氩弧焊', 'TIG', '0', 3, '0', NOW(), '精密焊接，适合薄板'),
(11004, '000000', 1003, '焊接工艺', 'SAW', 'SAW 埋弧焊', 'SAW', '0', 4, '0', NOW(), '厚板高效焊接，需配焊剂'),
(11005, '000000', 1003, '焊缝跟踪', 'NONE', '无（手动编程）', 'NONE', '1', 1, '0', NOW(), '依靠示教编程定位'),
(11006, '000000', 1003, '焊缝跟踪', 'LASER', '激光焊缝跟踪', 'LASER', '0', 2, '0', NOW(), '±0.1mm实时跟踪，自动纠偏'),
(11007, '000000', 1003, '焊缝跟踪', 'ARC', '电弧传感跟踪', 'ARC', '0', 3, '0', NOW(), '通过电弧电流反馈跟踪'),
(11008, '000000', 1003, '防护等级', 'IP54', 'IP54 标准防护', 'IP54', '1', 1, '0', NOW(), '防尘防溅水，常规车间'),
(11009, '000000', 1003, '防护等级', 'IP65', 'IP65 加强防护', 'IP65', '0', 2, '0', NOW(), '完全防尘+低压喷水'),
(11010, '000000', 1003, '防护等级', 'IP67', 'IP67 最高防护', 'IP67', '0', 3, '0', NOW(), '防尘+短时浸泡，+8,000'),
(11011, '000000', 1003, '通信协议', 'ETHERCAT', 'EtherCAT 总线', 'ETHERCAT', '1', 1, '0', NOW(), '高速实时总线，标配'),
(11012, '000000', 1003, '通信协议', 'PROFINET', 'PROFINET 工业以太网', 'PROFINET', '0', 2, '0', NOW(), '西门子PLC生态集成'),
(11013, '000000', 1003, '通信协议', 'DUAL', 'EtherCAT + PROFINET 双协议', 'DUAL', '0', 3, '0', NOW(), '双总线通信，+5,000'),
(11014, '000000', 1003, '焊枪选型', 'TORCH-400A', '400A 气冷焊枪', 'TORCH-400A', '1', 1, '0', NOW(), '标准焊枪，适用MIG/MAG'),
(11015, '000000', 1003, '焊枪选型', 'TORCH-500W', '500A 水冷焊枪', 'TORCH-500W', '0', 2, '0', NOW(), '大电流长时间焊接，+12,000'),
(11016, '000000', 1003, '焊枪选型', 'TORCH-TIG-350', '350A TIG专用焊枪', 'TORCH-TIG-350', '0', 3, '0', NOW(), 'TIG工艺专用'),
(11017, '000000', 1003, '焊枪选型', 'TORCH-SAW', 'SAW 埋弧焊枪', 'TORCH-SAW', '0', 4, '0', NOW(), '埋弧焊专用，需配焊剂回收');

-- === SPOT-210D (1006, ATO) ===
INSERT INTO cpq_attribute_option (option_id, tenant_id, model_id, attr_name, option_code, option_label, option_value, is_default, sort_order, del_flag, create_time, remark) VALUES
(11021, '000000', 1006, '焊枪A选型', 'GUN-A-C50', 'C50 标准伺服焊枪', 'GUN-A-C50', '1', 1, '0', NOW(), '50kVA'),
(11022, '000000', 1006, '焊枪A选型', 'GUN-A-C80', 'C80 大功率伺服焊枪', 'GUN-A-C80', '0', 2, '0', NOW(), '80kVA，厚板'),
(11023, '000000', 1006, '焊枪A选型', 'GUN-A-CX', 'CX 轻量化伺服焊枪', 'GUN-A-CX', '0', 3, '0', NOW(), '30kVA，高速薄板'),
(11024, '000000', 1006, '焊枪B选型', 'GUN-B-C50', 'C50 标准伺服焊枪', 'GUN-B-C50', '1', 1, '0', NOW(), '50kVA'),
(11025, '000000', 1006, '焊枪B选型', 'GUN-B-C80', 'C80 大功率伺服焊枪', 'GUN-B-C80', '0', 2, '0', NOW(), '80kVA'),
(11026, '000000', 1006, '焊枪B选型', 'GUN-B-CX', 'CX 轻量化伺服焊枪', 'GUN-B-CX', '0', 3, '0', NOW(), '30kVA'),
(11027, '000000', 1006, '冷却方式', 'AIR', '强制风冷', 'AIR', '1', 1, '0', NOW(), '标准配置'),
(11028, '000000', 1006, '冷却方式', 'WATER', '双通道水冷', 'WATER', '0', 2, '0', NOW(), '高节拍连焊必需，+18,000'),
(11029, '000000', 1006, '控制模式', 'STD', '标准时序控制', 'STD', '1', 1, '0', NOW(), '预压→焊接→保持→休止'),
(11030, '000000', 1006, '控制模式', 'ADAPTIVE', '自适应控制', 'ADAPTIVE', '0', 2, '0', NOW(), '实时电流/压力闭环，+25,000');

-- === LASER-2K (1008, ATO) ===
INSERT INTO cpq_attribute_option (option_id, tenant_id, model_id, attr_name, option_code, option_label, option_value, is_default, sort_order, del_flag, create_time, remark) VALUES
(11041, '000000', 1008, '激光源功率', '2KW', '2kW 标准功率', '2KW', '1', 1, '0', NOW(), '精密钣金/电池极耳焊接'),
(11042, '000000', 1008, '激光源功率', '3KW', '3kW 升级功率', '3KW', '0', 2, '0', NOW(), '中板焊接，+50,000'),
(11043, '000000', 1008, '激光源功率', '4KW', '4kW 高功率', '4KW', '0', 3, '0', NOW(), '厚板深熔焊，+120,000'),
(11044, '000000', 1008, '焊接头', 'WOBBLE', '摆动焊接头', 'WOBBLE', '1', 1, '0', NOW(), '标准配置，适应间隙0.3mm'),
(11045, '000000', 1008, '焊接头', 'DUAL_WOBBLE', '双摆焊接头', 'DUAL_WOBBLE', '0', 2, '0', NOW(), '大间隙0.8mm容差，+30,000'),
(11046, '000000', 1008, '焊接头', 'REMOTE', '远程扫描焊接头', 'REMOTE', '0', 3, '0', NOW(), '飞行焊接高速产线，+60,000'),
(11047, '000000', 1008, '安全防护', 'ENCL-STD', '标准激光防护罩', 'ENCL-STD', '1', 1, '0', NOW(), 'Class 1 安全标准'),
(11048, '000000', 1008, '安全防护', 'ENCL-XL', '加大型防护罩', 'ENCL-XL', '0', 2, '0', NOW(), '大型工件，+15,000'),
(11049, '000000', 1008, '安全防护', 'ROOM', '激光安全房', 'ROOM', '0', 3, '0', NOW(), '整线安全方案，+50,000'),
(11050, '000000', 1008, '冷却系统', 'CHILLER-5KW', '5kW 标准冷水机', 'CHILLER-5KW', '1', 1, '0', NOW(), '适配2kW激光源'),
(11051, '000000', 1008, '冷却系统', 'CHILLER-8KW', '8kW 大冷量冷水机', 'CHILLER-8KW', '0', 2, '0', NOW(), '适配3kW+激光源，+10,000');

-- === CoBot-10 (1023, ATO) ===
INSERT INTO cpq_attribute_option (option_id, tenant_id, model_id, attr_name, option_code, option_label, option_value, is_default, sort_order, del_flag, create_time, remark) VALUES
(11061, '000000', 1023, '末端工具', 'PARALLEL', '电动平行夹爪', 'PARALLEL', '1', 1, '0', NOW(), '行程0-60mm，夹持力200N'),
(11062, '000000', 1023, '末端工具', 'ADAPTIVE', '自适应三指夹爪', 'ADAPTIVE', '0', 2, '0', NOW(), '异形工件，+8,000'),
(11063, '000000', 1023, '末端工具', 'SUCTION', '4区真空吸盘', 'SUCTION', '0', 3, '0', NOW(), '多孔/不规则表面，+5,000'),
(11064, '000000', 1023, '末端工具', 'CHANGER', '快换盘+2工具站', 'CHANGER', '0', 4, '0', NOW(), '多工序快速切换，+12,000'),
(11065, '000000', 1023, '视觉系统', 'NONE', '无视觉', 'NONE', '1', 1, '0', NOW(), '示教编程定位'),
(11066, '000000', 1023, '视觉系统', '2D', '2D 工业相机', '2D', '0', 2, '0', NOW(), '平面定位/读码，+15,000'),
(11067, '000000', 1023, '视觉系统', '3D', '3D 结构光相机', '3D', '0', 3, '0', NOW(), 'Bin-Picking杂乱抓取，+35,000'),
(11068, '000000', 1023, '防护等级', 'IP54', 'IP54 标准协作', 'IP54', '1', 1, '0', NOW(), '常规轻工业环境'),
(11069, '000000', 1023, '防护等级', 'IP65', 'IP65 加强防护', 'IP65', '0', 2, '0', NOW(), '粉尘/水雾环境，+5,000'),
(11070, '000000', 1023, '防护等级', 'IP67', 'IP67 食品级', 'IP67', '0', 3, '0', NOW(), 'FDA认证，+18,000'),
(11071, '000000', 1023, '安装方式', 'TABLE', '台面安装', 'TABLE', '1', 1, '0', NOW(), '标准台面安装底座'),
(11072, '000000', 1023, '安装方式', 'CEILING', '倒挂安装', 'CEILING', '0', 2, '0', NOW(), '天轨倒挂，节省地面空间'),
(11073, '000000', 1023, '安装方式', 'MOBILE', '移动平台安装', 'MOBILE', '0', 3, '0', NOW(), 'AGV移动平台集成，+15,000');

-- =====================================================
-- 五、ATO 配置规则（cpq_config_rule）
-- =====================================================

INSERT INTO cpq_config_rule (rule_id, tenant_id, model_id, rule_name, rule_type, severity, condition_expr, action_expr, error_message, priority, effective_date, status, del_flag, create_time, remark) VALUES
(21001, '000000', 1003, 'TIG需TIG焊枪', 'VALIDATION', 'ERROR', '{"attr":"焊接工艺","op":"eq","value":"TIG"}', '{"require":"焊枪选型","values":["TORCH-TIG-350"]}', 'TIG工艺必须使用TIG专用焊枪', 100, CURDATE(), '0', '0', NOW(), '工艺-焊枪匹配'),
(21002, '000000', 1003, 'SAW需埋弧焊枪', 'VALIDATION', 'ERROR', '{"attr":"焊接工艺","op":"eq","value":"SAW"}', '{"require":"焊枪选型","values":["TORCH-SAW"]}', '埋弧焊必须使用SAW专用焊枪', 100, CURDATE(), '0', '0', NOW(), '工艺-焊枪匹配'),
(21003, '000000', 1003, '激光跟踪推荐', 'SELECTION', 'INFO', '{"attr":"焊接工艺","op":"in","value":["TIG","SAW"]}', '{"suggest":"焊缝跟踪","value":"LASER"}', NULL, 50, CURDATE(), '0', '0', NOW(), '精密工艺推荐激光跟踪'),
(21004, '000000', 1003, '水冷焊枪建议IP65', 'VALIDATION', 'WARNING', '{"attr":"焊枪选型","op":"eq","value":"TORCH-500W"}', '{"suggest":"防护等级","value":"IP65"}', '大功率水冷焊枪建议IP65以上防护', 80, CURDATE(), '0', '0', NOW(), '防护匹配建议'),
(21005, '000000', 1006, 'C80焊枪需水冷', 'VALIDATION', 'ERROR', '{"attr":"焊枪A选型","op":"eq","value":"GUN-A-C80"}', '{"require":"冷却方式","values":["WATER"]}', '大功率伺服焊枪(C80)必须使用水冷', 100, CURDATE(), '0', '0', NOW(), '功率-冷却匹配'),
(21006, '000000', 1006, '双枪同功率推荐', 'SELECTION', 'INFO', '{"attr":"焊枪A选型","op":"neq","value":"焊枪B选型"}', '{"suggest":"焊枪B选型","value":"${焊枪A选型}"}', NULL, 50, CURDATE(), '0', '0', NOW(), '双枪一致性推荐'),
(21007, '000000', 1008, '3kW+需8kW冷水机', 'VALIDATION', 'WARNING', '{"attr":"激光源功率","op":"in","value":["3KW","4KW"]}', '{"suggest":"冷却系统","value":"CHILLER-8KW"}', '3kW以上建议大冷量冷水机', 90, CURDATE(), '0', '0', NOW(), '功率-冷却匹配'),
(21008, '000000', 1008, '远程头需安全房', 'VALIDATION', 'ERROR', '{"attr":"焊接头","op":"eq","value":"REMOTE"}', '{"require":"安全防护","values":["ROOM"]}', '远程扫描焊接头必须配备激光安全房', 100, CURDATE(), '0', '0', NOW(), '远程头安全要求'),
(21009, '000000', 1008, '高功率安全提示', 'ALERT', 'WARNING', '{"attr":"激光源功率","op":"eq","value":"4KW"}', '{"alert":"4kW高功率激光，请确认操作人员已取得激光安全操作证（LSO）"}', NULL, 70, CURDATE(), '0', '0', NOW(), '操作安全提示'),
(21010, '000000', 1023, '3D视觉需IP65+', 'VALIDATION', 'WARNING', '{"attr":"视觉系统","op":"eq","value":"3D"}', '{"suggest":"防护等级","value":"IP65"}', '3D相机对粉尘敏感，建议IP65以上', 80, CURDATE(), '0', '0', NOW(), '视觉-防护匹配'),
(21011, '000000', 1023, '快换盘推荐3D视觉', 'SELECTION', 'INFO', '{"attr":"末端工具","op":"eq","value":"CHANGER"}', '{"suggest":"视觉系统","value":"3D"}', NULL, 50, CURDATE(), '0', '0', NOW(), '多工序需视觉定位'),
(21012, '000000', 1023, '食品级安装建议', 'VALIDATION', 'INFO', '{"attr":"防护等级","op":"eq","value":"IP67"}', '{"suggest":"安装方式","value":"CEILING"}', '食品级(IP67)建议倒挂安装避免积水', 40, CURDATE(), '0', '0', NOW(), '卫生设计建议');

-- =====================================================
-- 六、ATO 属性映射（cpq_attribute_mapping）
-- 属性选项值 → 物料编码映射
-- =====================================================

-- ARC-200P (1003) 映射
INSERT INTO cpq_attribute_mapping (mapping_id, tenant_id, model_id, attr_name, attr_value, material_code, sbom_line_id, del_flag, create_time, remark) VALUES
(31001, '000000', 1003, '焊缝跟踪', 'NONE', 'MAT-CONTROL-ARC', 2064201006, '0', NOW(), '无跟踪=标准控制器'),
(31002, '000000', 1003, '焊缝跟踪', 'LASER', 'MAT-SEAM-TRACK', 2064201005, '0', NOW(), '激光跟踪系统'),
(31003, '000000', 1003, '焊缝跟踪', 'ARC', 'MAT-ARC-SENSE', NULL, '0', NOW(), '电弧传感模块'),
(31004, '000000', 1003, '焊枪选型', 'TORCH-400A', 'MAT-TORCH-STD', NULL, '0', NOW(), '标配焊枪'),
(31005, '000000', 1003, '焊枪选型', 'TORCH-500W', 'MAT-TORCH-500W', 2064201003, '0', NOW(), '水冷焊枪'),
(31006, '000000', 1003, '焊枪选型', 'TORCH-TIG-350', 'MAT-TORCH-TIG', NULL, '0', NOW(), 'TIG焊枪'),
(31007, '000000', 1003, '焊枪选型', 'TORCH-SAW', 'MAT-TORCH-SAW', NULL, '0', NOW(), 'SAW焊枪'),
(31008, '000000', 1003, '防护等级', 'IP54', 'MAT-SEAL-STD', NULL, '0', NOW(), '标准密封'),
(31009, '000000', 1003, '防护等级', 'IP65', 'MAT-SEAL-IP65', NULL, '0', NOW(), '加强密封'),
(31010, '000000', 1003, '防护等级', 'IP67', 'MAT-SEAL-IP67', NULL, '0', NOW(), '最高密封');

-- SPOT-210D (1006) 映射
INSERT INTO cpq_attribute_mapping (mapping_id, tenant_id, model_id, attr_name, attr_value, material_code, sbom_line_id, del_flag, create_time, remark) VALUES
(31011, '000000', 1006, '焊枪A选型', 'GUN-A-C50', 'MAT-SERVO-C50', 2064202002, '0', NOW(), 'C50焊枪A'),
(31012, '000000', 1006, '焊枪A选型', 'GUN-A-C80', 'MAT-SERVO-C80', NULL, '0', NOW(), 'C80焊枪A'),
(31013, '000000', 1006, '焊枪A选型', 'GUN-A-CX', 'MAT-SERVO-CX', NULL, '0', NOW(), 'CX焊枪A'),
(31014, '000000', 1006, '焊枪B选型', 'GUN-B-C50', 'MAT-SERVO-C50', 2064202003, '0', NOW(), 'C50焊枪B'),
(31015, '000000', 1006, '焊枪B选型', 'GUN-B-C80', 'MAT-SERVO-C80', NULL, '0', NOW(), 'C80焊枪B'),
(31016, '000000', 1006, '焊枪B选型', 'GUN-B-CX', 'MAT-SERVO-CX', NULL, '0', NOW(), 'CX焊枪B'),
(31017, '000000', 1006, '冷却方式', 'AIR', 'MAT-FAN-IND', NULL, '0', NOW(), '强制风冷'),
(31018, '000000', 1006, '冷却方式', 'WATER', 'MAT-COOL-DUAL', 2064202006, '0', NOW(), '双通道水冷');

-- LASER-2K (1008) 映射
INSERT INTO cpq_attribute_mapping (mapping_id, tenant_id, model_id, attr_name, attr_value, material_code, sbom_line_id, del_flag, create_time, remark) VALUES
(31019, '000000', 1008, '激光源功率', '2KW', 'MAT-LASER-SRC-2K', 2064203002, '0', NOW(), '2kW源'),
(31020, '000000', 1008, '激光源功率', '3KW', 'MAT-LASER-SRC-3K', NULL, '0', NOW(), '3kW源'),
(31021, '000000', 1008, '激光源功率', '4KW', 'MAT-LASER-SRC-4K', NULL, '0', NOW(), '4kW源'),
(31022, '000000', 1008, '焊接头', 'WOBBLE', 'MAT-WOBBLE-HEAD', 2064203003, '0', NOW(), '标准焊接头'),
(31023, '000000', 1008, '焊接头', 'DUAL_WOBBLE', 'MAT-DUAL-WOBBLE', NULL, '0', NOW(), '双摆头'),
(31024, '000000', 1008, '焊接头', 'REMOTE', 'MAT-REMOTE-HEAD', NULL, '0', NOW(), '远程头'),
(31025, '000000', 1008, '安全防护', 'ENCL-STD', 'MAT-SAFETY-ENCL', 2064203006, '0', NOW(), '标准防护'),
(31026, '000000', 1008, '安全防护', 'ENCL-XL', 'MAT-SAFETY-ENCL-XL', NULL, '0', NOW(), '加大防护'),
(31027, '000000', 1008, '安全防护', 'ROOM', 'MAT-SAFETY-ROOM', NULL, '0', NOW(), '安全房'),
(31028, '000000', 1008, '冷却系统', 'CHILLER-5KW', 'MAT-CHILLER-5KW', 2064203004, '0', NOW(), '标准冷水'),
(31029, '000000', 1008, '冷却系统', 'CHILLER-8KW', 'MAT-CHILLER-8KW', NULL, '0', NOW(), '大冷量');

-- CoBot-10 (1023) 映射
INSERT INTO cpq_attribute_mapping (mapping_id, tenant_id, model_id, attr_name, attr_value, material_code, sbom_line_id, del_flag, create_time, remark) VALUES
(31030, '000000', 1023, '末端工具', 'PARALLEL', 'MAT-GRIP-PARALLEL', 2064204002, '0', NOW(), '标准夹爪'),
(31031, '000000', 1023, '末端工具', 'ADAPTIVE', 'MAT-GRIP-ADAPTIVE', NULL, '0', NOW(), '自适应夹爪'),
(31032, '000000', 1023, '末端工具', 'SUCTION', 'MAT-SUCTION-4ZONE', NULL, '0', NOW(), '真空吸盘'),
(31033, '000000', 1023, '末端工具', 'CHANGER', 'MAT-TOOL-CHANGER', NULL, '0', NOW(), '快换系统'),
(31034, '000000', 1023, '视觉系统', 'NONE', 'MAT-CONTROL-CB-STD', 2064204004, '0', NOW(), '标准控制器'),
(31035, '000000', 1023, '视觉系统', '2D', 'MAT-CAM-2D', 2064204003, '0', NOW(), '2D视觉'),
(31036, '000000', 1023, '视觉系统', '3D', 'MAT-CAM-3D', NULL, '0', NOW(), '3D视觉'),
(31037, '000000', 1023, '防护等级', 'IP54', 'MAT-SEAL-CB-STD', NULL, '0', NOW(), 'IP54密封'),
(31038, '000000', 1023, '防护等级', 'IP65', 'MAT-SEAL-CB-IP65', NULL, '0', NOW(), 'IP65密封'),
(31039, '000000', 1023, '防护等级', 'IP67', 'MAT-SEAL-CB-IP67', NULL, '0', NOW(), 'IP67 FDA'),
(31040, '000000', 1023, '安装方式', 'TABLE', 'MAT-BASE-TABLE', NULL, '0', NOW(), '台面安装'),
(31041, '000000', 1023, '安装方式', 'CEILING', 'MAT-BASE-CEILING', NULL, '0', NOW(), '倒挂安装'),
(31042, '000000', 1023, '安装方式', 'MOBILE', 'MAT-BASE-MOBILE', NULL, '0', NOW(), '移动安装');
