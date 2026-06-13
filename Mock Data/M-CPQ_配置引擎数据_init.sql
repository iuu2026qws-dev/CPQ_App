-- =====================================================
-- M-CPQ 配置引擎种子数据（D03数据域）
-- 基于：M-CPQ 产品数据（model_id: 1001-1100）
-- 用途：为 cpq_attribute_option / cpq_config_rule / cpq_attribute_mapping 提供演示数据
-- 覆盖产品：RW-ARC-160 (1001, STANDARD)，RW-PAL-150 (1021, STANDARD)，RW-COBOT-T5 (1041, ATO)
-- 日期：2026-06-13
-- =====================================================

SET NAMES utf8mb4;

-- =====================================================
-- 一、属性选项值 (cpq_attribute_option)
-- =====================================================

-- --- 产品 1001: RW-ARC-160 紧凑型弧焊机器人 (STANDARD) ---
INSERT INTO cpq_attribute_option (option_id, tenant_id, model_id, attr_name, option_code, option_label, option_value, is_default, sort_order, del_flag, create_time, remark) VALUES
(10001, '000000', 1001, '颜色', 'WHITE', '珍珠白', 'WHITE', '1', 1, '0', NOW(), '标准色，无附加费'),
(10002, '000000', 1001, '颜色', 'YELLOW', '工业黄', 'YELLOW', '0', 2, '0', NOW(), '警示色，适合焊接车间'),
(10003, '000000', 1001, '颜色', 'GRAY', '石墨灰', 'GRAY', '0', 3, '0', NOW(), '防污耐脏，推荐'),
(10004, '000000', 1001, '颜色', 'BLACK', '曜石黑', 'BLACK', '0', 4, '0', NOW(), '高端定制色，+1,500'),
(10005, '000000', 1001, '基站版本', 'BASIC', '标准版', 'BASIC', '1', 1, '0', NOW(), '基础控制器，支持MIG/MAG'),
(10006, '000000', 1001, '基站版本', 'PRO', '专业版', 'PRO', '0', 2, '0', NOW(), '高级控制器，支持MIG/MAG/TIG，带焊缝追踪'),
(10007, '000000', 1001, '基站版本', 'ULTRA', '旗舰版', 'ULTRA', '0', 3, '0', NOW(), '全功能控制器，支持所有焊接工艺+自动编程+AI视觉'),
(10008, '000000', 1001, '焊接工艺', 'MIG', 'MIG焊', 'MIG', '1', 1, '0', NOW(), '熔化极惰性气体保护焊'),
(10009, '000000', 1001, '焊接工艺', 'MAG', 'MAG焊', 'MAG', '0', 2, '0', NOW(), '熔化极活性气体保护焊'),
(10010, '000000', 1001, '焊接工艺', 'TIG', 'TIG焊', 'TIG', '0', 3, '0', NOW(), '钨极惰性气体保护焊（需专业版以上）'),
(10011, '000000', 1001, '防护等级', 'IP54', 'IP54 标准防护', 'IP54', '1', 1, '0', NOW(), '标准粉尘/水雾防护'),
(10012, '000000', 1001, '防护等级', 'IP65', 'IP65 加强防护', 'IP65', '0', 2, '0', NOW(), '高压水冲洗防护，适合严苛环境'),
(10013, '000000', 1001, '防护等级', 'IP67', 'IP67 全密封防护', 'IP67', '0', 3, '0', NOW(), '防尘防水，适合极端环境'),
(10014, '000000', 1001, '通信协议', 'ETHERCAT', 'EtherCAT', 'ETHERCAT', '1', 1, '0', NOW(), '工业以太网，实时性高'),
(10015, '000000', 1001, '通信协议', 'PROFINET', 'PROFINET', 'PROFINET', '0', 2, '0', NOW(), '西门子生态兼容'),
(10016, '000000', 1001, '通信协议', 'ETHERTCP', 'EtherNet/IP', 'ETHERTCP', '0', 3, '0', NOW(), '罗克韦尔生态兼容'),
(10017, '000000', 1001, '焊枪', 'TORCH_300A', '300A标准焊枪', 'TORCH_300A', '1', 1, '0', NOW(), '额定300A，适合薄板焊接'),
(10018, '000000', 1001, '焊枪', 'TORCH_500A', '500A加强焊枪', 'TORCH_500A', '0', 2, '0', NOW(), '额定500A，适合中厚板焊接'),
(10019, '000000', 1001, '焊枪', 'TORCH_WATER', '水冷焊枪', 'TORCH_WATER', '0', 3, '0', NOW(), '水冷系统，适合长时间连续焊接');

-- --- 产品 1021: RW-PAL-150 高速码垛机器人 (STANDARD) ---
INSERT INTO cpq_attribute_option (option_id, tenant_id, model_id, attr_name, option_code, option_label, option_value, is_default, sort_order, del_flag, create_time, remark) VALUES
(10201, '000000', 1021, '颜色', 'WHITE', '珍珠白', 'WHITE', '1', 1, '0', NOW(), '标准色'),
(10202, '000000', 1021, '颜色', 'GRAY', '石墨灰', 'GRAY', '0', 2, '0', NOW(), '防污耐脏'),
(10203, '000000', 1021, '臂展', 'ARM_2500', '2500mm', 'ARM_2500', '1', 1, '0', NOW(), '标准臂展'),
(10204, '000000', 1021, '臂展', 'ARM_3200', '3200mm', 'ARM_3200', '0', 2, '0', NOW(), '加长臂展，适合大托盘'),
(10205, '000000', 1021, '负载', 'LOAD_150', '150kg', 'LOAD_150', '1', 1, '0', NOW(), '标准负载'),
(10206, '000000', 1021, '负载', 'LOAD_200', '200kg', 'LOAD_200', '0', 2, '0', NOW(), '加强负载'),
(10207, '000000', 1021, '夹具类型', 'CLAMP_STD', '标准夹爪', 'CLAMP_STD', '1', 1, '0', NOW(), '通用纸箱抓取'),
(10208, '000000', 1021, '夹具类型', 'CLAMP_VACUUM', '真空吸盘', 'CLAMP_VACUUM', '0', 2, '0', NOW(), '适合平整表面'),
(10209, '000000', 1021, '夹具类型', 'CLAMP_FORK', '叉式夹具', 'CLAMP_FORK', '0', 3, '0', NOW(), '适合托盘底层'),
(10210, '000000', 1021, '防护等级', 'IP54', 'IP54', 'IP54', '1', 1, '0', NOW(), '标准防护'),
(10211, '000000', 1021, '防护等级', 'IP65', 'IP65', 'IP65', '0', 2, '0', NOW(), '防水加强，食品饮料行业推荐');

-- --- 产品 1041: RW-COBOT-T5 五轴协作机器人 (ATO) ---
INSERT INTO cpq_attribute_option (option_id, tenant_id, model_id, attr_name, option_code, option_label, option_value, is_default, sort_order, del_flag, create_time, remark) VALUES
(10401, '000000', 1041, '颜色', 'WHITE', '珍珠白', 'WHITE', '1', 1, '0', NOW(), '标准色'),
(10402, '000000', 1041, '颜色', 'BLUE', '科技蓝', 'BLUE', '0', 2, '0', NOW(), '协作机器人专属配色'),
(10403, '000000', 1041, '负载', 'LOAD_5', '5kg', 'LOAD_5', '1', 1, '0', NOW(), '标准负载'),
(10404, '000000', 1041, '负载', 'LOAD_8', '8kg', 'LOAD_8', '0', 2, '0', NOW(), '加强负载'),
(10405, '000000', 1041, '末端工具', 'TOOL_GRIPPER', '电动夹爪', 'TOOL_GRIPPER', '1', 1, '0', NOW(), '标准两指夹爪'),
(10406, '000000', 1041, '末端工具', 'TOOL_VACUUM', '真空吸盘', 'TOOL_VACUUM', '0', 2, '0', NOW(), '适合精密元器件'),
(10407, '000000', 1041, '末端工具', 'TOOL_SCREW', '螺丝锁付', 'TOOL_SCREW', '0', 3, '0', NOW(), '自动螺丝锁付'),
(10408, '000000', 1041, '末端工具', 'TOOL_CAMERA', '视觉检测', 'TOOL_CAMERA', '0', 4, '0', NOW(), 'AI视觉引导+质检'),
(10409, '000000', 1041, '安全配置', 'SAFE_BASIC', '基础安全', 'SAFE_BASIC', '1', 1, '0', NOW(), '力矩传感器+碰撞检测'),
(10410, '000000', 1041, '安全配置', 'SAFE_ADVANCED', '高级安全', 'SAFE_ADVANCED', '0', 2, '0', NOW(), '力矩+激光扫描+安全区域'),
(10411, '000000', 1041, '控制器', 'CTRL_STD', '标准控制器', 'CTRL_STD', '1', 1, '0', NOW(), '基础示教器'),
(10412, '000000', 1041, '控制器', 'CTRL_TOUCH', '触屏控制器', 'CTRL_TOUCH', '0', 2, '0', NOW(), '10寸触屏+拖拽编程');


-- =====================================================
-- 二、配置规则 (cpq_config_rule)
-- =====================================================

-- --- 产品 1001: RW-ARC-160 约束规则 ---
INSERT INTO cpq_config_rule (rule_id, tenant_id, rule_name, rule_type, model_id, condition_expr, action_expr, error_message, severity, priority, effective_date, status, del_flag, create_time, remark) VALUES
(20001, '000000', 'TIG工艺需要专业版以上', 'VALIDATION', 1001,
 '{"attr":"焊接工艺","op":"EQUALS","value":"TIG"}',
 '{"require":{"attr":"基站版本","in":["PRO","ULTRA"]}}',
 'TIG焊接工艺需要专业版(PRO)或旗舰版(ULTRA)基站，标准版不支持TIG', 'ERROR', 100, '2025-01-01', '0', '0', NOW(), 'TIG=精密焊接，需要高级控制器支持'),
(20002, '000000', '水冷焊枪需要专业版以上', 'VALIDATION', 1001,
 '{"attr":"焊枪","op":"EQUALS","value":"TORCH_WATER"}',
 '{"require":{"attr":"基站版本","in":["PRO","ULTRA"]}}',
 '水冷焊枪需要专业版(PRO)或旗舰版(ULTRA)基站支持', 'ERROR', 90, '2025-01-01', '0', '0', NOW(), '水冷系统由高级控制器管理'),
(20003, '000000', '工业黄推荐焊接车间', 'ALERT', 1001,
 '{"attr":"颜色","op":"EQUALS","value":"YELLOW"}',
 '{"recommend":{"attr":"防护等级","value":"IP65"}}',
 '工业黄配色通常用于焊接车间，建议选择IP65加强防护', 'INFO', 50, '2025-01-01', '0', '0', NOW(), '警示色一般提升防护等级'),
(20004, '000000', 'TIG焊接推荐高防护', 'SELECTION', 1001,
 '{"attr":"焊接工艺","op":"EQUALS","value":"TIG"}',
 '{"recommend":{"attr":"防护等级","value":"IP65"}}',
 NULL, 'WARNING', 40, '2025-01-01', '0', '0', NOW(), 'TIG焊接精度要求高，推荐加强防护'),
(20005, '000000', '300A焊枪不能配旗舰版', 'VALIDATION', 1001,
 '{"and":[{"attr":"焊枪","op":"EQUALS","value":"TORCH_300A"},{"attr":"基站版本","op":"EQUALS","value":"ULTRA"}]}',
 '{"forbid":true}',
 '旗舰版(ULTRA)基站不支持300A标准焊枪，请选用500A加强焊枪或水冷焊枪', 'ERROR', 80, '2025-01-01', '0', '0', NOW(), '旗舰版控制器功率输出不匹配300A焊枪');

-- --- 产品 1021: RW-PAL-150 约束规则 ---
INSERT INTO cpq_config_rule (rule_id, tenant_id, rule_name, rule_type, model_id, condition_expr, action_expr, error_message, severity, priority, effective_date, status, del_flag, create_time, remark) VALUES
(20006, '000000', '真空吸盘需平整表面', 'ALERT', 1021,
 '{"attr":"夹具类型","op":"EQUALS","value":"CLAMP_VACUUM"}',
 '{"alert":"请确认被搬运物品表面平整且无孔洞，否则真空吸盘可能失效"}',
 '真空吸盘只适合平整表面物品，请确认适用场景', 'WARNING', 60, '2025-01-01', '0', '0', NOW(), '透气表面会导致吸力不足'),
(20007, '000000', '200kg负载推荐加长臂展', 'SELECTION', 1021,
 '{"attr":"负载","op":"EQUALS","value":"LOAD_200"}',
 '{"recommend":{"attr":"臂展","value":"ARM_3200"}}',
 NULL, 'INFO', 30, '2025-01-01', '0', '0', NOW(), '重负载+长臂展是典型化工行业组合'),
(20008, '000000', '食品行业防护要求', 'VALIDATION', 1021,
 '{"attr":"夹具类型","op":"EQUALS","value":"CLAMP_VACUUM"}',
 '{"require":{"attr":"防护等级","value":"IP65"}}',
 '食品饮料行业使用真空吸盘时，必须选择IP65防护等级', 'ERROR', 70, '2025-01-01', '0', '0', NOW(), '食品安全法规要求');

-- --- 产品 1041: RW-COBOT-T5 约束规则 ---
INSERT INTO cpq_config_rule (rule_id, tenant_id, rule_name, rule_type, model_id, condition_expr, action_expr, error_message, severity, priority, effective_date, status, del_flag, create_time, remark) VALUES
(20009, '000000', '视觉检测需高级安全', 'VALIDATION', 1041,
 '{"attr":"末端工具","op":"EQUALS","value":"TOOL_CAMERA"}',
 '{"require":{"attr":"安全配置","value":"SAFE_ADVANCED"}}',
 '视觉检测工具移动范围大，需要高级安全配置（激光扫描+安全区域）', 'ERROR', 90, '2025-01-01', '0', '0', NOW(), 'AI视觉=大范围移动=额外安全需求'),
(20010, '000000', '螺丝锁付需要触屏控制器', 'SELECTION', 1041,
 '{"attr":"末端工具","op":"EQUALS","value":"TOOL_SCREW"}',
 '{"recommend":{"attr":"控制器","value":"CTRL_TOUCH"}}',
 NULL, 'INFO', 40, '2025-01-01', '0', '0', NOW(), '螺丝锁付参数复杂，触屏控制器更方便调节扭矩/速度'),
(20011, '000000', '8kg负载力控', 'ALERT', 1041,
 '{"attr":"负载","op":"EQUALS","value":"LOAD_8"}',
 '{"alert":"8kg配置在高速运动时末端精度会下降约0.05mm，如需要高精度请保持5kg配置"}',
 '提示：8kg负载会轻微影响精度', 'WARNING', 50, '2025-01-01', '0', '0', NOW(), '惯量影响末端精度');


-- =====================================================
-- 三、属性→物料映射 (cpq_attribute_mapping)
-- =====================================================

-- --- 产品 1001: RW-ARC-160 属性→物料 ---
INSERT INTO cpq_attribute_mapping (mapping_id, tenant_id, model_id, attr_name, attr_value, material_code, sbom_line_id, sort_order, del_flag, create_time, remark) VALUES
(30001, '000000', 1001, '颜色', 'WHITE', 'PAINT-WHITE-RAL9016', NULL, 1, '0', NOW(), 'RAL9016 交通白，机器人外壳喷涂'),
(30002, '000000', 1001, '颜色', 'YELLOW', 'PAINT-YELLOW-RAL1023', NULL, 2, '0', NOW(), 'RAL1023 交通黄，工业警示色'),
(30003, '000000', 1001, '颜色', 'GRAY', 'PAINT-GRAY-RAL7045', NULL, 3, '0', NOW(), 'RAL7045 电视灰，防污涂层'),
(30004, '000000', 1001, '颜色', 'BLACK', 'PAINT-BLACK-RAL9005', NULL, 4, '0', NOW(), 'RAL9005 墨黑，特殊定制+1,500'),
(30005, '000000', 1001, '基站版本', 'BASIC', 'CTRL-ARC-BASIC-V3', NULL, 1, '0', NOW(), '基础控制器 V3，2个焊机接口'),
(30006, '000000', 1001, '基站版本', 'PRO', 'CTRL-ARC-PRO-V3', NULL, 2, '0', NOW(), '专业控制器 V3，4个焊机接口+焊缝追踪'),
(30007, '000000', 1001, '基站版本', 'ULTRA', 'CTRL-ARC-ULTRA-V3', NULL, 3, '0', NOW(), '旗舰控制器 V3，8个焊机接口+AI视觉+自动编程'),
(30008, '000000', 1001, '焊枪', 'TORCH_300A', 'TORCH-MIG-300A-ABI', NULL, 1, '0', NOW(), '300A MIG/MAG焊枪，空冷'),
(30009, '000000', 1001, '焊枪', 'TORCH_500A', 'TORCH-MIG-500A-ABI', NULL, 2, '0', NOW(), '500A MIG/MAG焊枪，空冷加强'),
(30010, '000000', 1001, '焊枪', 'TORCH_WATER', 'TORCH-TIG-W500-ABI', NULL, 3, '0', NOW(), '水冷TIG焊枪，500A，循环水冷系统'),
(30011, '000000', 1001, '防护等级', 'IP54', 'SEAL-IP54-STD', NULL, 1, '0', NOW(), 'IP54密封套件'),
(30012, '000000', 1001, '防护等级', 'IP65', 'SEAL-IP65-ADV', NULL, 2, '0', NOW(), 'IP65加强密封+高压水冲洗'),
(30013, '000000', 1001, '防护等级', 'IP67', 'SEAL-IP67-FULL', NULL, 3, '0', NOW(), 'IP67全密封套件+灌封处理'),
(30014, '000000', 1001, '通信协议', 'ETHERCAT', 'COMM-ECAT-MOD', NULL, 1, '0', NOW(), 'EtherCAT通信模块'),
(30015, '000000', 1001, '通信协议', 'PROFINET', 'COMM-PNET-MOD', NULL, 2, '0', NOW(), 'PROFINET通信模块'),
(30016, '000000', 1001, '通信协议', 'ETHERTCP', 'COMM-EIP-MOD', NULL, 3, '0', NOW(), 'EtherNet/IP通信模块');

-- --- 产品 1021: RW-PAL-150 属性→物料 ---
INSERT INTO cpq_attribute_mapping (mapping_id, tenant_id, model_id, attr_name, attr_value, material_code, sbom_line_id, sort_order, del_flag, create_time, remark) VALUES
(30201, '000000', 1021, '臂展', 'ARM_2500', 'ARM-PAL-STD-2500', NULL, 1, '0', NOW(), '标准码垛机械臂 2500mm'),
(30202, '000000', 1021, '臂展', 'ARM_3200', 'ARM-PAL-LONG-3200', NULL, 2, '0', NOW(), '加长码垛机械臂 3200mm'),
(30203, '000000', 1021, '负载', 'LOAD_150', 'MOTOR-PAL-150KG', NULL, 1, '0', NOW(), '150kg负载伺服电机'),
(30204, '000000', 1021, '负载', 'LOAD_200', 'MOTOR-PAL-200KG', NULL, 2, '0', NOW(), '200kg负载伺服电机（加强）'),
(30205, '000000', 1021, '夹具类型', 'CLAMP_STD', 'GRIPPER-STD-150', NULL, 1, '0', NOW(), '标准夹爪150型'),
(30206, '000000', 1021, '夹具类型', 'CLAMP_VACUUM', 'GRIPPER-VAC-8CH', NULL, 2, '0', NOW(), '真空吸盘 8通道'),
(30207, '000000', 1021, '夹具类型', 'CLAMP_FORK', 'GRIPPER-FORK-150', NULL, 3, '0', NOW(), '叉式夹具150型');

-- --- 产品 1041: RW-COBOT-T5 属性→物料 ---
INSERT INTO cpq_attribute_mapping (mapping_id, tenant_id, model_id, attr_name, attr_value, material_code, sbom_line_id, sort_order, del_flag, create_time, remark) VALUES
(30401, '000000', 1041, '末端工具', 'TOOL_GRIPPER', 'EOAT-GRIPPER-T5', NULL, 1, '0', NOW(), '电动夹爪T5型'),
(30402, '000000', 1041, '末端工具', 'TOOL_VACUUM', 'EOAT-VACUUM-T5', NULL, 2, '0', NOW(), '真空吸盘T5型'),
(30403, '000000', 1041, '末端工具', 'TOOL_SCREW', 'EOAT-SCREW-T5', NULL, 3, '0', NOW(), '螺丝锁付T5型'),
(30404, '000000', 1041, '末端工具', 'TOOL_CAMERA', 'EOAT-CAMERA-AI', NULL, 4, '0', NOW(), 'AI视觉检测套件'),
(30405, '000000', 1041, '安全配置', 'SAFE_BASIC', 'SAFE-TORQUE-T5', NULL, 1, '0', NOW(), '基础安全：力矩传感器'),
(30406, '000000', 1041, '安全配置', 'SAFE_ADVANCED', 'SAFE-LASER-T5', NULL, 2, '0', NOW(), '高级安全：力矩+激光扫描器+安全PLC'),
(30407, '000000', 1041, '控制器', 'CTRL_STD', 'CTRL-COBOT-STD', NULL, 1, '0', NOW(), '标准示教器'),
(30408, '000000', 1041, '控制器', 'CTRL_TOUCH', 'CTRL-COBOT-TOUCH', NULL, 2, '0', NOW(), '10寸触屏示教器');
