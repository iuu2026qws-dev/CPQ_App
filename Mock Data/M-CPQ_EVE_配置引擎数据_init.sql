-- =====================================================
-- M-CPQ 配置引擎种子数据 — 亿纬锂能（EVE Energy）
-- 基于：M-CPQ_EVE_产品数据_init.sql（model_id: 2001-2200）
-- 覆盖产品：LF120L(2009 ATO) / LVI-5.0(2063 STD) / HVI-40.0(2091 ATO)
--           CTP-30K(2058 ATO) / LF280K(2019 STD) / CR2032(2150 STD)
-- 日期：2026-07-01
-- 可重复执行（幂等）: 先清理EVE专属配置数据再导入
-- 依赖：M-CPQ_EVE_产品数据_init.sql 需先执行
-- =====================================================

SET NAMES utf8mb4;

-- =====================================================
-- 【幂等清理】删除已有的EVE配置数据
-- =====================================================
-- 清理属性映射（mapping_id 13001-13099，按model_id范围更安全）
DELETE FROM cpq_attribute_mapping WHERE tenant_id = '000000' AND model_id BETWEEN 2001 AND 2200;
-- 清理配置规则（rule_id 22001-22015，按model_id范围更安全）
DELETE FROM cpq_config_rule WHERE tenant_id = '000000' AND model_id BETWEEN 2001 AND 2200;
-- 清理属性选项（option_id 12001-12199，按model_id范围更安全）
DELETE FROM cpq_attribute_option WHERE tenant_id = '000000' AND model_id BETWEEN 2001 AND 2200;

-- =====================================================
-- 一、属性选项值 (cpq_attribute_option)
-- =====================================================

-- === 产品 2019: LF280K 标准电芯 (STANDARD) — 可选规格属性 ===
INSERT INTO cpq_attribute_option (option_id, tenant_id, model_id, attr_name, option_code, option_label, option_value, is_default, sort_order, del_flag, create_time, remark) VALUES
(12001, '000000', 2019, '极柱类型', 'M6_SINGLE', 'M6单极柱（标准）', 'M6_SINGLE', '1', 1, '0', NOW(), '标准M6螺柱，通用连接'),
(12002, '000000', 2019, '极柱类型', 'M6_DUAL', 'M6双极柱（冗余）', 'M6_DUAL', '0', 2, '0', NOW(), '双极柱并联，接触可靠性+50%'),
(12003, '000000', 2019, '极柱类型', 'M8_REINF', 'M8加强极柱', 'M8_REINF', '0', 3, '0', NOW(), 'M8大截面极柱，大电流场景'),
(12004, '000000', 2019, '防爆阀类型', 'STD', '标准防爆阀', 'STD', '1', 1, '0', NOW(), '标准开启压力0.8MPa'),
(12005, '000000', 2019, '防爆阀类型', 'HV', '高压防爆阀（1.2MPa）', 'HV', '0', 2, '0', NOW(), '适用于高海拔/高温环境'),
(12006, '000000', 2019, '防爆阀类型', 'DUAL', '双防爆阀（冗余）', 'DUAL', '0', 3, '0', NOW(), '核电/军工级安全冗余'),
(12007, '000000', 2019, '极耳材质', 'AL', '标准铝合金极耳', 'AL', '1', 1, '0', NOW(), '标准铝合金，成本最优'),
(12008, '000000', 2019, '极耳材质', 'CU_AL', '铜铝复合极耳', 'CU_AL', '0', 2, '0', NOW(), '导电率+30%，适合高倍率'),
(12009, '000000', 2019, '包装方式', 'TRAY', '标准托盘包装（240片/托）', 'TRAY', '1', 1, '0', NOW(), '标准物流包装'),
(12010, '000000', 2019, '包装方式', 'BOX', '防静电周转箱（96片/箱）', 'BOX', '0', 2, '0', NOW(), '高价值客户精密包装'),
(12011, '000000', 2019, '包装方式', 'PALLET', '真空木箱托盘（48片/托）', 'PALLET', '0', 3, '0', NOW(), '海运出口长途包装');

-- === 产品 2009: LF120L 可配置电芯 (ATO) ===
INSERT INTO cpq_attribute_option (option_id, tenant_id, model_id, attr_name, option_code, option_label, option_value, is_default, sort_order, del_flag, create_time, remark) VALUES
(12021, '000000', 2009, '容量等级', '120AH', '120Ah 标准容量', '120AH', '1', 1, '0', NOW(), '标称120Ah，1C持续放电'),
(12022, '000000', 2009, '容量等级', '125AH', '125Ah 升级容量', '125AH', '0', 2, '0', NOW(), '筛选B品提升，+12%价格'),
(12023, '000000', 2009, '容量等级', '130AH', '130Ah 极限容量', '130AH', '0', 3, '0', NOW(), '极优A品，+25%价格'),
(12024, '000000', 2009, '循环等级', 'STD_5000', '5000次循环（标准）', 'STD_5000', '1', 1, '0', NOW(), '标准工况5000次@80%SOH'),
(12025, '000000', 2009, '循环等级', 'LONG_6000', '6000次循环（长寿命）', 'LONG_6000', '0', 2, '0', NOW(), '长寿命配方，+15%价格'),
(12026, '000000', 2009, '循环等级', 'ULTRA_8000', '8000次循环（超长寿命）', 'ULTRA_8000', '0', 3, '0', NOW(), '极致寿命配方，+30%价格'),
(12027, '000000', 2009, '极柱类型', 'M6_STD', 'M6标准极柱', 'M6_STD', '1', 1, '0', NOW(), '标准规格'),
(12028, '000000', 2009, '极柱类型', 'M8_LARGE', 'M8加强极柱', 'M8_LARGE', '0', 2, '0', NOW(), '大电流场景'),
(12029, '000000', 2009, '极柱类型', 'LASER_WELD', '激光焊接端子', 'LASER_WELD', '0', 3, '0', NOW(), '激光焊Pack集成，免螺栓'),
(12030, '000000', 2009, '认证', 'GB_ONLY', '国标认证（GB）', 'GB_ONLY', '1', 1, '0', NOW(), 'GB/T 31484/31486'),
(12031, '000000', 2009, '认证', 'GB_CB', '国标+CB认证', 'GB_CB', '0', 2, '0', NOW(), '含IEC 62619'),
(12032, '000000', 2009, '认证', 'GB_UL', '国标+UL认证（出口北美）', 'GB_UL', '0', 3, '0', NOW(), '含UL 1973/UL 9540A，+12%价格'),
(12033, '000000', 2009, '认证', 'GB_CE', '国标+CE认证（出口欧洲）', 'GB_CE', '0', 4, '0', NOW(), '含CE/IEC认证，+8%价格'),
(12034, '000000', 2009, '工作温度', 'STD', '标准温域（0°C~55°C）', 'STD', '1', 1, '0', NOW(), '标准电解液配方'),
(12035, '000000', 2009, '工作温度', 'WIDE', '宽温域（-20°C~55°C）', 'WIDE', '0', 2, '0', NOW(), '低温电解液，+10%价格'),
(12036, '000000', 2009, '工作温度', 'ULTRA', '超宽温域（-30°C~65°C）', 'ULTRA', '0', 3, '0', NOW(), '特种电解液+加热膜预留，+25%价格');

-- === 产品 2063: LVI-5.0 标准壁挂储能 (STANDARD) — 可选外观/安装属性 ===
INSERT INTO cpq_attribute_option (option_id, tenant_id, model_id, attr_name, option_code, option_label, option_value, is_default, sort_order, del_flag, create_time, remark) VALUES
(12041, '000000', 2063, '外壳颜色', 'WHITE', '极地白', 'WHITE', '1', 1, '0', NOW(), '标准色，家用场景'),
(12042, '000000', 2063, '外壳颜色', 'GRAY', '工业灰', 'GRAY', '0', 2, '0', NOW(), '商用场景，防污耐脏'),
(12043, '000000', 2063, '外壳颜色', 'BLACK', '曜石黑', 'BLACK', '0', 3, '0', NOW(), '高端定制色'),
(12044, '000000', 2063, '通信协议', 'CAN', 'CAN 2.0B', 'CAN', '1', 1, '0', NOW(), '标准CAN总线通信'),
(12045, '000000', 2063, '通信协议', 'RS485', 'RS485 MODBUS', 'RS485', '0', 2, '0', NOW(), '工业Modbus协议'),
(12046, '000000', 2063, '通信协议', 'DUAL', 'CAN+RS485 双协议', 'DUAL', '0', 3, '0', NOW(), '双通信接口，兼容性强'),
(12047, '000000', 2063, '安装支架', 'WALL_STD', '标准壁挂支架', 'WALL_STD', '1', 1, '0', NOW(), '标准壁挂安装件'),
(12048, '000000', 2063, '安装支架', 'WALL_SWIVEL', '可旋转壁挂支架', 'WALL_SWIVEL', '0', 2, '0', NOW(), '±15°角度调节'),
(12049, '000000', 2063, '安装支架', 'FLOOR_STAND', '落地支架', 'FLOOR_STAND', '0', 3, '0', NOW(), '不适合壁挂时使用'),
(12050, '000000', 2063, '加热功能', 'NONE', '无加热', 'NONE', '1', 1, '0', NOW(), '标准配置，5°C以上环境'),
(12051, '000000', 2063, '加热功能', 'SELF_HEAT', '自加热膜', 'SELF_HEAT', '0', 2, '0', NOW(), '0°C以下环境自动加热，+5%价格');

-- === 产品 2091: HVI-40.0 高压壁挂储能 (ATO) ===
INSERT INTO cpq_attribute_option (option_id, tenant_id, model_id, attr_name, option_code, option_label, option_value, is_default, sort_order, del_flag, create_time, remark) VALUES
(12061, '000000', 2091, '电池模组数', 'MOD10', '10个模组（40.96kWh）', 'MOD10', '1', 1, '0', NOW(), '标准10模组配置'),
(12062, '000000', 2091, '电池模组数', 'MOD8', '8个模组（32.77kWh）', 'MOD8', '0', 2, '0', NOW(), '减配版，-20%价格'),
(12063, '000000', 2091, '电池模组数', 'MOD12', '12个模组（49.15kWh）', 'MOD12', '0', 3, '0', NOW(), '增配版，+20%价格'),
(12064, '000000', 2091, '逆变器匹配', 'SOLAR_8K', '适配8kW混合逆变器', 'SOLAR_8K', '1', 1, '0', NOW(), '标准户用光伏配置'),
(12065, '000000', 2091, '逆变器匹配', 'SOLAR_15K', '适配15kW混合逆变器', 'SOLAR_15K', '0', 2, '0', NOW(), '大功率光伏/三相家庭'),
(12066, '000000', 2091, '逆变器匹配', 'SOLAR_25K', '适配25kW商用逆变器', 'SOLAR_25K', '0', 3, '0', NOW(), '小型商业/农场光伏'),
(12067, '000000', 2091, 'BMS功能', 'BASIC', '基础BMS（均衡+保护）', 'BASIC', '1', 1, '0', NOW(), '标准BMS功能'),
(12068, '000000', 2091, 'BMS功能', 'ADVANCED', '高级BMS（SOx估算+寿命预测）', 'ADVANCED', '0', 2, '0', NOW(), '含SOC/SOH/SOP估算+AI预测，+8%价格'),
(12069, '000000', 2091, 'BMS功能', 'PREMIUM', '旗舰BMS（云平台+OTA+数字孪生）', 'PREMIUM', '0', 3, '0', NOW(), '云端BMS+远程OTA+数字孪生，+15%价格'),
(12070, '000000', 2091, '防护等级', 'IP55', 'IP55 标准户外', 'IP55', '1', 1, '0', NOW(), '防尘+低压喷水，常规户外'),
(12071, '000000', 2091, '防护等级', 'IP65', 'IP65 加强防护', 'IP65', '0', 2, '0', NOW(), '防尘+高压水冲洗，沿海/多雨'),
(12072, '000000', 2091, '防护等级', 'IP67', 'IP67 最高防护', 'IP67', '0', 3, '0', NOW(), '防尘+短时浸泡，海岛/洪水区，+10%价格'),
(12073, '000000', 2091, '电网标准', 'CN_GB', '国网标准', 'CN_GB', '1', 1, '0', NOW(), 'GB/T 34120/34133，国内用'),
(12074, '000000', 2091, '电网标准', 'EU_VDE', 'VDE-AR-N 4105（德国）', 'EU_VDE', '0', 2, '0', NOW(), '德国/欧洲并网认证'),
(12075, '000000', 2091, '电网标准', 'UK_G99', 'G99（英国）', 'UK_G99', '0', 3, '0', NOW(), '英国并网标准'),
(12076, '000000', 2091, '电网标准', 'US_UL', 'UL 1741SA/IEEE 1547（美国）', 'US_UL', '0', 4, '0', NOW(), '北美并网标准');

-- === 产品 2058: CTP-30K 电池包 (ATO) ===
INSERT INTO cpq_attribute_option (option_id, tenant_id, model_id, attr_name, option_code, option_label, option_value, is_default, sort_order, del_flag, create_time, remark) VALUES
(12081, '000000', 2058, '电芯选型', 'LF100L', 'LF100L 100Ah 标准电芯', 'LF100L', '1', 1, '0', NOW(), '300串100Ah=30kWh'),
(12082, '000000', 2058, '电芯选型', 'LF100LA', 'LF100LA 100Ah 长寿命电芯', 'LF100LA', '0', 2, '0', NOW(), '8000次循环，+8%价格'),
(12083, '000000', 2058, '电芯选型', 'LF120L', 'LF120L 120Ah 大容量电芯', 'LF120L', '0', 3, '0', NOW(), '300串120Ah=36kWh，+18%价格'),
(12084, '000000', 2058, 'BMS选型', 'BMS_BASIC', '基础BMS（被动均衡）', 'BMS_BASIC', '1', 1, '0', NOW(), '100mA被动均衡'),
(12085, '000000', 2058, 'BMS选型', 'BMS_ACTIVE', '主动均衡BMS（2A均衡电流）', 'BMS_ACTIVE', '0', 2, '0', NOW(), '2A主动均衡，+15%价格'),
(12086, '000000', 2058, 'BMS选型', 'BMS_AI', '智能AI BMS（云平台+预警）', 'BMS_AI', '0', 3, '0', NOW(), '含4G通信+云平台，+25%价格'),
(12087, '000000', 2058, '冷却方式', 'AIR_COOL', '强制风冷', 'AIR_COOL', '1', 1, '0', NOW(), '标准风冷，低成本'),
(12088, '000000', 2058, '冷却方式', 'LIQUID_COOL', '液冷板冷却', 'LIQUID_COOL', '0', 2, '0', NOW(), '液冷板，适用高倍率/高温，+20%价格'),
(12089, '000000', 2058, '冷却方式', 'REFRIG', '压缩机制冷', 'REFRIG', '0', 3, '0', NOW(), '主动制冷，严苛热环境，+35%价格'),
(12090, '000000', 2058, '认证', 'GB', '国标认证', 'GB', '1', 1, '0', NOW(), 'GB/T标准'),
(12091, '000000', 2058, '认证', 'GB_ECE', '国标+ECE R100（出口）', 'GB_ECE', '0', 2, '0', NOW(), '含UN ECE R100，+15%价格'),
(12092, '000000', 2058, '防水等级', 'IP54', 'IP54 基本防水', 'IP54', '1', 1, '0', NOW(), '标准防护'),
(12093, '000000', 2058, '防水等级', 'IP67', 'IP67 全防水', 'IP67', '0', 2, '0', NOW(), '涉水/高湿场景，+10%价格');

-- === 产品 2150: CR2032 扣式电池 (STANDARD) — 可选包装属性 ===
INSERT INTO cpq_attribute_option (option_id, tenant_id, model_id, attr_name, option_code, option_label, option_value, is_default, sort_order, del_flag, create_time, remark) VALUES
(12101, '000000', 2150, '包装', 'BLISTER_5', '5粒吸塑卡装', 'BLISTER_5', '1', 1, '0', NOW(), '零售标准包装'),
(12102, '000000', 2150, '包装', 'BLISTER_10', '10粒吸塑卡装', 'BLISTER_10', '0', 2, '0', NOW(), '家庭装'),
(12103, '000000', 2150, '包装', 'TRAY_20', '20粒工业托盘装', 'TRAY_20', '0', 3, '0', NOW(), '工业客户批量包装，单价更低'),
(12104, '000000', 2150, '包装', 'REEL_2000', '2000粒编带卷装', 'REEL_2000', '0', 4, '0', NOW(), 'SMT自动化产线专用');


-- =====================================================
-- 二、配置规则 (cpq_config_rule)
-- =====================================================

-- === 产品 2019: LF280K 约束规则 ===
INSERT INTO cpq_config_rule (rule_id, tenant_id, rule_name, rule_type, model_id, condition_expr, action_expr, error_message, severity, priority, effective_date, status, del_flag, create_time, remark) VALUES
(22001, '000000', '双极柱需铜铝复合极耳', 'VALIDATION', 2019,
 '{"attr":"极柱类型","op":"EQUALS","value":"M6_DUAL"}',
 '{"require":{"attr":"极耳材质","value":"CU_AL"}}',
 '双极柱冗余配置需要铜铝复合极耳以承载双倍电流负载', 'ERROR', 100, '2025-01-01', '0', '0', NOW(), '极柱-极耳匹配'),
(22002, '000000', '双防爆阀建议真空包装', 'SELECTION', 2019,
 '{"attr":"防爆阀类型","op":"EQUALS","value":"DUAL"}',
 '{"recommend":{"attr":"包装方式","value":"PALLET"}}',
 NULL, 'INFO', 50, '2025-01-01', '0', '0', NOW(), '军工级产品建议真空木箱包装'),
(22003, '000000', '大电流M8建议铜铝极耳', 'VALIDATION', 2019,
 '{"attr":"极柱类型","op":"EQUALS","value":"M8_REINF"}',
 '{"require":{"attr":"极耳材质","value":"CU_AL"}}',
 'M8加强极柱用于大电流场景必须使用铜铝复合极耳', 'ERROR', 90, '2025-01-01', '0', '0', NOW(), '大电流安全要求');

-- === 产品 2009: LF120L 约束规则 ===
INSERT INTO cpq_config_rule (rule_id, tenant_id, rule_name, rule_type, model_id, condition_expr, action_expr, error_message, severity, priority, effective_date, status, del_flag, create_time, remark) VALUES
(22004, '000000', 'UL认证需超宽温域', 'VALIDATION', 2009,
 '{"attr":"认证","op":"EQUALS","value":"GB_UL"}',
 '{"require":{"attr":"工作温度","in":["WIDE","ULTRA"]}}',
 '北美市场(UL认证)必须支持低温运行(-20°C以下)', 'ERROR', 100, '2025-01-01', '0', '0', NOW(), '北美低温要求'),
(22005, '000000', '极限容量需长寿命配方', 'VALIDATION', 2009,
 '{"attr":"容量等级","op":"EQUALS","value":"130AH"}',
 '{"require":{"attr":"循环等级","in":["LONG_6000","ULTRA_8000"]}}',
 '130Ah极限容量电芯需匹配长寿命配方，不可用标准配方', 'ERROR', 90, '2025-01-01', '0', '0', NOW(), '容量-寿命匹配'),
(22006, '000000', '激光焊端子不能选M6/M8', 'VALIDATION', 2009,
 '{"attr":"极柱类型","op":"EQUALS","value":"LASER_WELD"}',
 '{"forbid":{"attr":"极柱类型","in":["M6_STD","M8_LARGE"]}}',
 '激光焊接端子与螺栓型极柱互斥，请二选一', 'ERROR', 100, '2025-01-01', '0', '0', NOW(), '端子类型互斥'),
(22007, '000000', '超宽温域推荐出口认证', 'SELECTION', 2009,
 '{"attr":"工作温度","op":"EQUALS","value":"ULTRA"}',
 '{"recommend":{"attr":"认证","in":["GB_CE","GB_UL"]}}',
 NULL, 'INFO', 40, '2025-01-01', '0', '0', NOW(), '超宽温域电芯高价值，推荐配套出口认证');

-- === 产品 2091: HVI-40.0 约束规则 ===
INSERT INTO cpq_config_rule (rule_id, tenant_id, rule_name, rule_type, model_id, condition_expr, action_expr, error_message, severity, priority, effective_date, status, del_flag, create_time, remark) VALUES
(22008, '000000', '海外电网需高级BMS', 'VALIDATION', 2091,
 '{"attr":"电网标准","op":"in","value":["EU_VDE","UK_G99","US_UL"]}',
 '{"require":{"attr":"BMS功能","in":["ADVANCED","PREMIUM"]}}',
 '海外并网标准要求高级BMS功能（SOx估算+保护策略）', 'ERROR', 100, '2025-01-01', '0', '0', NOW(), '海外合规要求'),
(22009, '000000', 'IP67需高级BMS', 'VALIDATION', 2091,
 '{"attr":"防护等级","op":"EQUALS","value":"IP67"}',
 '{"require":{"attr":"BMS功能","value":"PREMIUM"}}',
 'IP67全密封环境温控压力大，需旗舰BMS含数字孪生', 'ERROR', 90, '2025-01-01', '0', '0', NOW(), '密封环境热管理'),
(22010, '000000', '12模组需适配25kW逆变器', 'VALIDATION', 2091,
 '{"attr":"电池模组数","op":"EQUALS","value":"MOD12"}',
 '{"require":{"attr":"逆变器匹配","value":"SOLAR_25K"}}',
 '12模组49kWh配置功率高，必须适配25kW以上逆变器', 'WARNING', 80, '2025-01-01', '0', '0', NOW(), '功率匹配建议'),
(22011, '000000', '旗舰BMS推荐云平台', 'SELECTION', 2091,
 '{"attr":"BMS功能","op":"EQUALS","value":"PREMIUM"}',
 '{"recommend":{"attr":"逆变器匹配","value":"SOLAR_25K"}}',
 NULL, 'INFO', 30, '2025-01-01', '0', '0', NOW(), '旗舰级建议配大功率逆变器');

-- === 产品 2058: CTP-30K 约束规则 ===
INSERT INTO cpq_config_rule (rule_id, tenant_id, rule_name, rule_type, model_id, condition_expr, action_expr, error_message, severity, priority, effective_date, status, del_flag, create_time, remark) VALUES
(22012, '000000', '液冷需主动均衡BMS', 'VALIDATION', 2058,
 '{"attr":"冷却方式","op":"EQUALS","value":"LIQUID_COOL"}',
 '{"require":{"attr":"BMS选型","in":["BMS_ACTIVE","BMS_AI"]}}',
 '液冷系统温度梯度大，需要主动均衡BMS', 'ERROR', 100, '2025-01-01', '0', '0', NOW(), '热管理-BMS匹配'),
(22013, '000000', '压缩机制冷需AI BMS', 'VALIDATION', 2058,
 '{"attr":"冷却方式","op":"EQUALS","value":"REFRIG"}',
 '{"require":{"attr":"BMS选型","value":"BMS_AI"}}',
 '压缩机制冷需智能热管理算法，必须AI BMS', 'ERROR', 90, '2025-01-01', '0', '0', NOW(), '智能热管理要求'),
(22014, '000000', '出口认证需主动均衡', 'SELECTION', 2058,
 '{"attr":"认证","op":"EQUALS","value":"GB_ECE"}',
 '{"recommend":{"attr":"BMS选型","value":"BMS_ACTIVE"}}',
 NULL, 'INFO', 50, '2025-01-01', '0', '0', NOW(), '出口产品推荐主动均衡'),
(22015, '000000', 'IP67+长寿命电芯兼容', 'VALIDATION', 2058,
 '{"and":[{"attr":"防水等级","op":"EQUALS","value":"IP67"},{"attr":"电芯选型","op":"EQUALS","value":"LF120L"}]}',
 '{"forbid":true}',
 'IP67密封环境+120Ah大电芯=热管理不兼容，请选择100Ah电芯', 'ERROR', 90, '2025-01-01', '0', '0', NOW(), '密封空间热容限制');


-- =====================================================
-- 三、属性→物料映射 (cpq_attribute_mapping)
-- =====================================================

-- === 产品 2019: LF280K 属性→物料 ===
INSERT INTO cpq_attribute_mapping (mapping_id, tenant_id, model_id, attr_name, attr_value, material_code, sbom_line_id, sort_order, del_flag, create_time, remark) VALUES
(13001, '000000', 2019, '极柱类型', 'M6_SINGLE', 'TERMINAL-M6-SINGLE-280K', NULL, 1, '0', NOW(), 'M6单极柱总成'),
(13002, '000000', 2019, '极柱类型', 'M6_DUAL', 'TERMINAL-M6-DUAL-280K', NULL, 2, '0', NOW(), 'M6双极柱总成'),
(13003, '000000', 2019, '极柱类型', 'M8_REINF', 'TERMINAL-M8-REINF-280K', NULL, 3, '0', NOW(), 'M8加强极柱'),
(13004, '000000', 2019, '防爆阀类型', 'STD', 'VENT-STD-0.8MPA', NULL, 1, '0', NOW(), '标准0.8MPa防爆阀'),
(13005, '000000', 2019, '防爆阀类型', 'HV', 'VENT-HV-1.2MPA', NULL, 2, '0', NOW(), '高压1.2MPa防爆阀'),
(13006, '000000', 2019, '防爆阀类型', 'DUAL', 'VENT-DUAL-280K', NULL, 3, '0', NOW(), '双防爆阀组件'),
(13007, '000000', 2019, '极耳材质', 'AL', 'TAB-AL-STD-280K', NULL, 1, '0', NOW(), '标准铝极耳'),
(13008, '000000', 2019, '极耳材质', 'CU_AL', 'TAB-CUAL-COMP-280K', NULL, 2, '0', NOW(), '铜铝复合极耳');

-- === 产品 2009: LF120L 属性→物料 ===
INSERT INTO cpq_attribute_mapping (mapping_id, tenant_id, model_id, attr_name, attr_value, material_code, sbom_line_id, sort_order, del_flag, create_time, remark) VALUES
(13011, '000000', 2009, '容量等级', '120AH', 'CELL-LF120L-120AH', NULL, 1, '0', NOW(), '120Ah标准电芯本体'),
(13012, '000000', 2009, '容量等级', '125AH', 'CELL-LF120L-125AH', NULL, 2, '0', NOW(), '125Ah升级电芯本体'),
(13013, '000000', 2009, '容量等级', '130AH', 'CELL-LF120L-130AH', NULL, 3, '0', NOW(), '130Ah极限电芯本体'),
(13014, '000000', 2009, '循环等级', 'STD_5000', 'ELE-SOLUTION-STD-LF120L', NULL, 1, '0', NOW(), '标准电解液配方'),
(13015, '000000', 2009, '循环等级', 'LONG_6000', 'ELE-SOLUTION-LONG-LF120L', NULL, 2, '0', NOW(), '长寿命电解液配方'),
(13016, '000000', 2009, '循环等级', 'ULTRA_8000', 'ELE-SOLUTION-ULTRA-LF120L', NULL, 3, '0', NOW(), '超长寿命电解液配方');

-- === 产品 2091: HVI-40.0 属性→物料 ===
INSERT INTO cpq_attribute_mapping (mapping_id, tenant_id, model_id, attr_name, attr_value, material_code, sbom_line_id, sort_order, del_flag, create_time, remark) VALUES
(13021, '000000', 2091, '电池模组数', 'MOD10', 'MOD-HVI-4K-STD', NULL, 1, '0', NOW(), '4kWh高压模组×10'),
(13022, '000000', 2091, '电池模组数', 'MOD8', 'MOD-HVI-4K-STD', NULL, 2, '0', NOW(), '4kWh高压模组×8'),
(13023, '000000', 2091, '电池模组数', 'MOD12', 'MOD-HVI-4K-STD', NULL, 3, '0', NOW(), '4kWh高压模组×12'),
(13024, '000000', 2091, 'BMS功能', 'BASIC', 'BMS-HVI-BASIC-V3', NULL, 1, '0', NOW(), '基础BMS控制板'),
(13025, '000000', 2091, 'BMS功能', 'ADVANCED', 'BMS-HVI-ADV-V3', NULL, 2, '0', NOW(), '高级BMS（SOx+AI）'),
(13026, '000000', 2091, 'BMS功能', 'PREMIUM', 'BMS-HVI-PREMIUM-V3', NULL, 3, '0', NOW(), '旗舰BMS（云平台+OTA）'),
(13027, '000000', 2091, '防护等级', 'IP55', 'ENCLOSURE-HVI-IP55', NULL, 1, '0', NOW(), 'IP55壳体套件'),
(13028, '000000', 2091, '防护等级', 'IP65', 'ENCLOSURE-HVI-IP65', NULL, 2, '0', NOW(), 'IP65壳体套件'),
(13029, '000000', 2091, '防护等级', 'IP67', 'ENCLOSURE-HVI-IP67', NULL, 3, '0', NOW(), 'IP67密封壳体套件'),
(13030, '000000', 2091, '逆变器匹配', 'SOLAR_8K', 'INVERTER-HYBRID-8K', NULL, 1, '0', NOW(), '8kW混合逆变器'),
(13031, '000000', 2091, '逆变器匹配', 'SOLAR_15K', 'INVERTER-HYBRID-15K', NULL, 2, '0', NOW(), '15kW混合逆变器'),
(13032, '000000', 2091, '逆变器匹配', 'SOLAR_25K', 'INVERTER-HYBRID-25K', NULL, 3, '0', NOW(), '25kW商用逆变器');

-- === 产品 2058: CTP-30K 属性→物料 ===
INSERT INTO cpq_attribute_mapping (mapping_id, tenant_id, model_id, attr_name, attr_value, material_code, sbom_line_id, sort_order, del_flag, create_time, remark) VALUES
(13035, '000000', 2058, '电芯选型', 'LF100L', 'CELL-LF100L-BULK', NULL, 1, '0', NOW(), 'LF100L 100Ah批量电芯'),
(13036, '000000', 2058, '电芯选型', 'LF100LA', 'CELL-LF100LA-BULK', NULL, 2, '0', NOW(), 'LF100LA 100Ah长寿命批量'),
(13037, '000000', 2058, '电芯选型', 'LF120L', 'CELL-LF120L-BULK', NULL, 3, '0', NOW(), 'LF120L 120Ah批量'),
(13038, '000000', 2058, 'BMS选型', 'BMS_BASIC', 'BMS-CTP30K-BASIC', NULL, 1, '0', NOW(), '基础BMS控制板'),
(13039, '000000', 2058, 'BMS选型', 'BMS_ACTIVE', 'BMS-CTP30K-ACTIVE', NULL, 2, '0', NOW(), '主动均衡BMS板'),
(13040, '000000', 2058, 'BMS选型', 'BMS_AI', 'BMS-CTP30K-AI-4G', NULL, 3, '0', NOW(), 'AI智能BMS+4G通信'),
(13041, '000000', 2058, '冷却方式', 'AIR_COOL', 'COOL-FAN-CTP30K', NULL, 1, '0', NOW(), '风冷散热组件'),
(13042, '000000', 2058, '冷却方式', 'LIQUID_COOL', 'COOL-PLATE-CTP30K', NULL, 2, '0', NOW(), '液冷板组件'),
(13043, '000000', 2058, '冷却方式', 'REFRIG', 'COOL-COMPRESSOR-CTP30K', NULL, 3, '0', NOW(), '压缩机制冷组件');
