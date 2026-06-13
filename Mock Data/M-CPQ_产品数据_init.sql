-- =====================================================
-- M-CPQ 产品数据初始化 SQL
-- 企业: 智元机器人（RoboWise Robotics）
-- 数据量: 3产品族 / 10产品线 / 30产品系列 / 100产品
-- 基于: M-CPQ_Product_Data_Architecture V1.2
-- 日期: 2026-06-07
-- =====================================================

SET NAMES utf8mb4;

-- =====================================================
-- 一、产品分类树 (cpq_product_category)
-- 层级: category_level 1=产品族 → 2=产品线 → 3=产品系列
-- schema: category_id, tenant_id, parent_category_id, category_level, category_code, category_name,
--          sort_order, status, del_flag, create_dept, create_by, create_time, update_by, update_time, remark
-- =====================================================

-- === L1: 产品族 (3条, parent_category_id IS NULL, category_level=1) ===

INSERT INTO cpq_product_category (category_id, tenant_id, category_name, category_code, category_level, parent_category_id, sort_order, status, del_flag, create_time, remark) VALUES
(101, '000000', '工业机器人', 'INDUSTRIAL', 1, NULL, 1, '0', '0', NOW(), '面向制造业的工业自动化机器人产品族'),
(102, '000000', '家用机器人', 'HOME', 1, NULL, 2, '0', '0', NOW(), '面向消费市场的家用服务机器人产品族'),
(103, '000000', '具身智能机器人', 'EMBODIED_AI', 1, NULL, 3, '0', '0', NOW(), '融合AI大模型的具身智能机器人产品族');

-- === L2: 产品线 (10条, parent_category_id→L1, category_level=2) ===

INSERT INTO cpq_product_category (category_id, tenant_id, category_name, category_code, category_level, parent_category_id, sort_order, status, del_flag, create_time, remark) VALUES
-- 工业机器人子线
(201, '000000', '焊接机器人', 'WELDING', 2, 101, 1, '0', '0', NOW(), '弧焊/点焊/激光焊接自动化'),
(202, '000000', '搬运与码垛机器人', 'MATERIAL_HANDLING', 2, 101, 2, '0', '0', NOW(), '物料搬运/码垛/AGV自动导引'),
(203, '000000', '协作机器人', 'COBOT', 2, 101, 3, '0', '0', NOW(), '人机协作/安全协作/精密装配'),
(204, '000000', '喷涂与涂装机器人', 'PAINTING', 2, 101, 4, '0', '0', NOW(), '精密喷涂/自动涂装/密封涂胶'),
-- 家用机器人物子线
(205, '000000', '清洁机器人', 'CLEANING', 2, 102, 1, '0', '0', NOW(), '扫地/拖地/商用清洁'),
(206, '000000', '教育与编程机器人', 'EDUCATION', 2, 102, 2, '0', '0', NOW(), 'STEM教育/编程学习/搭建'),
(207, '000000', '陪伴与服务机器人', 'COMPANION', 2, 102, 3, '0', '0', NOW(), '宠物陪伴/智能陪护/养老辅助'),
-- 具身智能子线
(208, '000000', '人形机器人', 'HUMANOID', 2, 103, 1, '0', '0', NOW(), '双足/轮式/全尺寸人形机器人'),
(209, '000000', '商用服务机器人', 'COMMERCIAL_SERVICE', 2, 103, 2, '0', '0', NOW(), '接待/配送/零售服务'),
(210, '000000', '特种作业机器人', 'SPECIAL_OPS', 2, 103, 3, '0', '0', NOW(), '巡检/救援/水下/高危作业');

-- === L3: 产品系列 (30条, parent_category_id→L2, category_level=3) ===

INSERT INTO cpq_product_category (category_id, tenant_id, category_name, category_code, category_level, parent_category_id, sort_order, status, del_flag, create_time, remark) VALUES
-- 焊接机器人系列 (201)
(301, '000000', 'ARC弧焊系列', 'ARC_SERIES', 3, 201, 1, '0', '0', NOW(), '6轴弧焊机器人，适配MIG/MAG/TIG工艺'),
(302, '000000', 'SPOT点焊系列', 'SPOT_SERIES', 3, 201, 2, '0', '0', NOW(), '伺服点焊机器人，车身焊接专用'),
(303, '000000', 'LASER激光焊接系列', 'LASER_SERIES', 3, 201, 3, '0', '0', NOW(), '光纤激光焊接，精密钣金/电池焊接'),
-- 搬运与码垛系列 (202)
(304, '000000', 'PAL码垛系列', 'PAL_SERIES', 3, 202, 1, '0', '0', NOW(), '4轴高速码垛，食品饮料/化工行业'),
(305, '000000', 'AGV自动导引系列', 'AGV_SERIES', 3, 202, 2, '0', '0', NOW(), '激光SLAM导航，仓库/产线物流'),
(306, '000000', 'HEAVY重载系列', 'HEAVY_SERIES', 3, 202, 3, '0', '0', NOW(), '重载搬运（500kg-2T），铸造/重工行业'),
-- 协作机器人系列 (203)
(307, '000000', 'COBOT通用协作系列', 'COBOT_SERIES', 3, 203, 1, '0', '0', NOW(), '6轴/7轴协作臂，3-20kg负载'),
(308, '000000', 'PREC精密装配系列', 'PREC_SERIES', 3, 203, 2, '0', '0', NOW(), '±0.02mm重复精度，3C电子/半导体'),
(309, '000000', 'SAFE力控协作系列', 'SAFE_SERIES', 3, 203, 3, '0', '0', NOW(), '内置力矩传感器，打磨/抛光/力控装配'),
-- 喷涂系列 (204)
(310, '000000', 'PAINT精密喷涂系列', 'PAINT_SERIES', 3, 204, 1, '0', '0', NOW(), '防爆喷涂机器人，汽车/家具行业'),
(311, '000000', 'COAT自动涂装系列', 'COAT_SERIES', 3, 204, 2, '0', '0', NOW(), '粉末/电泳涂装，家电/五金行业'),
(312, '000000', 'SEAL涂胶密封系列', 'SEAL_SERIES', 3, 204, 3, '0', '0', NOW(), '自动涂胶/点胶，汽车玻璃/电子封装'),
-- 清洁机器人系列 (205)
(313, '000000', 'SWEEP扫拖一体系列', 'SWEEP_SERIES', 3, 205, 1, '0', '0', NOW(), '扫拖一体+LDS激光导航，家用清洁'),
(314, '000000', 'NAVI视觉导航系列', 'NAVI_SERIES', 3, 205, 2, '0', '0', NOW(), 'AI视觉避障+3D结构光，高端家用'),
(315, '000000', 'DEEP商用清洁系列', 'DEEP_SERIES', 3, 205, 3, '0', '0', NOW(), '大容量水箱，商场/写字楼/酒店'),
-- 教育机器人系列 (206)
(316, '000000', 'STEM科教启蒙系列', 'STEM_SERIES', 3, 206, 1, '0', '0', NOW(), '模块化搭建+图形化编程，6-12岁'),
(317, '000000', 'CODE编程进阶系列', 'CODE_SERIES', 3, 206, 2, '0', '0', NOW(), 'Python/C++编程+传感器扩展，12-18岁'),
(318, '000000', 'BUILD创意搭建系列', 'BUILD_SERIES', 3, 206, 3, '0', '0', NOW(), '金属结构件+Arduino/RPi主板，创客教育'),
-- 陪伴机器人系列 (207)
(319, '000000', 'PET仿生宠物系列', 'PET_SERIES', 3, 207, 1, '0', '0', NOW(), 'AI仿生宠物犬/猫，情感交互'),
(320, '000000', 'COMP智能陪护系列', 'COMP_SERIES', 3, 207, 2, '0', '0', NOW(), '语音交互+健康监测，老人/儿童陪护'),
(321, '000000', 'ELDER养老辅助系列', 'ELDER_SERIES', 3, 207, 3, '0', '0', NOW(), '跌倒检测+紧急呼叫+用药提醒，养老机构'),
-- 人形机器人系列 (208)
(322, '000000', 'BIPED双足人形系列', 'BIPED_SERIES', 3, 208, 1, '0', '0', NOW(), '双足行走+灵巧手操作，通用人形平台'),
(323, '000000', 'WHEEL轮式人形系列', 'WHEEL_SERIES', 3, 208, 2, '0', '0', NOW(), '轮式底盘+上半身人形，移动操作一体'),
(324, '000000', 'HUMANOID全尺寸系列', 'HUMANOID_SERIES', 3, 208, 3, '0', '0', NOW(), '1.7m全尺寸人形，全身60+自由度'),
-- 商用服务系列 (209)
(325, '000000', 'RECEPTION智能接待系列', 'RECEPTION_SERIES', 3, 209, 1, '0', '0', NOW(), '多轮对话+自主导航，展厅/酒店/政务'),
(326, '000000', 'DELIVERY物流配送系列', 'DELIVERY_SERIES', 3, 209, 2, '0', '0', NOW(), '多舱室配送+电梯联动，写字楼/医院'),
(327, '000000', 'RETAIL商用零售系列', 'RETAIL_SERIES', 3, 209, 3, '0', '0', NOW(), '商品导购+库存盘点，商超/门店'),
-- 特种作业系列 (210)
(328, '000000', 'INSPECT智能巡检系列', 'INSPECT_SERIES', 3, 210, 1, '0', '0', NOW(), '防爆认证+多光谱，石化/电力/矿山巡检'),
(329, '000000', 'RESCUE应急救援系列', 'RESCUE_SERIES', 3, 210, 2, '0', '0', NOW(), '履带底盘+热成像+远程操控，消防/灾后'),
(330, '000000', 'MARINE水下作业系列', 'MARINE_SERIES', 3, 210, 3, '0', '0', NOW(), '300m防水+机械臂，水下检测/打捞/养殖');


-- =====================================================
-- 二、产品目录 (cpq_product_catalog)
-- schema: catalog_id, tenant_id, catalog_name, catalog_type, effective_date, expiry_date,
--          status, del_flag, create_dept, create_by, create_time, update_by, update_time, remark
-- =====================================================

INSERT INTO cpq_product_catalog (catalog_id, tenant_id, catalog_name, catalog_type, effective_date, expiry_date, status, del_flag, create_time, remark) VALUES
(1, '000000', 'RoboWise 标准产品目录（国内）',   'SALES',   '2026-01-01', '2028-12-31', '0', '0', NOW(), '面向国内直销和渠道的标准销售目录'),
(2, '000000', 'RoboWise 海外产品目录（亚太）',   'SALES',   '2026-01-01', '2028-12-31', '0', '0', NOW(), '亚太区海外销售目录（含CE/FCC认证产品）'),
(3, '000000', 'RoboWise 渠道专用目录',          'CHANNEL', '2026-01-01', '2028-12-31', '0', '0', NOW(), '授权经销商/代理商专用目录');


-- =====================================================
-- 三、可销售产品 (cpq_product_model) —— 100个产品
-- schema: model_id, tenant_id, catalog_id, category_id, model_code, model_name, description,
--          lifecycle_status, successor_model_id, base_price, currency, config_type,
--          min_order_qty, lead_time_days, default_bom_id, thumbnail_url,
--          status, del_flag, create_dept, create_by, create_time, update_by, update_time, remark
-- 生命周期: 大部分为 ACTIVE, 部分 PRE_RELEASE/EOL_ANNOUNCED
-- =====================================================

-- === ARC弧焊系列 (301) — 4个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(1001, '000000', 1, 301, 'RW-ARC-160',  'ARC-160 紧凑型弧焊机器人',     '6轴弧焊机器人，负载6kg，臂展1600mm，适配FANUC焊接电源，适合薄板焊接', 'ACTIVE', 185000.00, 'CNY', 'STANDARD', 1, 30, '0', '0', NOW(), '畅销款，汽车零部件焊接'),
(1002, '000000', 1, 301, 'RW-ARC-200',  'ARC-200 标准型弧焊机器人',     '6轴弧焊机器人，负载8kg，臂展2000mm，双丝焊接支持，中厚板焊接首选', 'ACTIVE', 258000.00, 'CNY', 'STANDARD', 1, 35, '0', '0', NOW(), '工程机械/钢结构焊接'),
(1003, '000000', 1, 301, 'RW-ARC-200P', 'ARC-200P 增强型弧焊机器人',    'ARC-200升级版，增加激光焊缝跟踪+自适应填充，焊接质量提升30%', 'ACTIVE', 328000.00, 'CNY', 'ATO', 1, 40, '0', '0', NOW(), '高要求压力容器/管道焊接'),
(1004, '000000', 1, 301, 'RW-ARC-250',  'ARC-250 大型弧焊机器人',       '6轴弧焊机器人，负载12kg，臂展2500mm，超长臂展适合大型结构件', 'ACTIVE', 398000.00, 'CNY', 'ATO', 1, 45, '0', '0', NOW(), '船舶/桥梁/风电塔筒焊接');

-- === SPOT点焊系列 (302) — 3个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(1005, '000000', 1, 302, 'RW-SPOT-210', 'SPOT-210 伺服点焊机器人',     '伺服焊枪+实时压力控制，焊接电流闭环反馈，适配汽车白车身焊接线', 'ACTIVE', 420000.00, 'CNY', 'STANDARD', 1, 45, '0', '0', NOW(), '汽车主机厂标准选型'),
(1006, '000000', 1, 302, 'RW-SPOT-210D','SPOT-210D 双枪点焊机器人',    '双伺服焊枪配置，双工位同时焊接，节拍提升60%', 'ACTIVE', 580000.00, 'CNY', 'ATO', 1, 50, '0', '0', NOW(), '高产线节拍要求场景'),
(1007, '000000', 1, 302, 'RW-SPOT-160', 'SPOT-160 紧凑型点焊机器人',   '6轴小型点焊，负载50kg，臂展1600mm，适合零部件点焊', 'ACTIVE', 320000.00, 'CNY', 'STANDARD', 1, 35, '0', '0', NOW(), '汽车零部件Tier1供应商');

-- === LASER激光焊接系列 (303) — 3个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(1008, '000000', 1, 303, 'RW-LASER-2K','LASER-2K 光纤激光焊接机器人',  '2kW光纤激光源+摆动焊接头，精密钣金/电池极耳焊接', 'ACTIVE', 520000.00, 'CNY', 'ATO', 1, 40, '0', '0', NOW(), '动力电池PACK焊接标配'),
(1009, '000000', 1, 303, 'RW-LASER-4K','LASER-4K 高功率激光焊接机器人','4kW光纤激光源+双摆焊接头，中厚板深熔焊', 'ACTIVE', 680000.00, 'CNY', 'ATO', 1, 45, '0', '0', NOW(), '船舶厚板/核电焊接'),
(1010, '000000', 1, 303, 'RW-LASER-6K','LASER-6K 超高功率激光焊接系统','6kW光纤激光源+远程焊接头，飞行焊接高速产线', 'ACTIVE', 880000.00, 'CNY', 'ETO', 1, 55, '0', '0', NOW(), '汽车产线飞行焊接');

-- === PAL码垛系列 (304) — 3个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(1011, '000000', 1, 304, 'RW-PAL-120',  'PAL-120 标准码垛机器人',      '4轴码垛专用，负载120kg，臂展2400mm，1200循环/小时', 'ACTIVE', 165000.00, 'CNY', 'STANDARD', 1, 25, '0', '0', NOW(), '食品饮料行业主力机型'),
(1012, '000000', 1, 304, 'RW-PAL-180',  'PAL-180 大负载码垛机器人',    '4轴码垛专用，负载180kg，臂展3100mm，适合化工/建材袋装码垛', 'ACTIVE', 210000.00, 'CNY', 'STANDARD', 1, 30, '0', '0', NOW(), '袋装物料码垛'),
(1013, '000000', 1, 304, 'RW-PAL-060',  'PAL-060 高速码垛机器人',      '4轴高速码垛，负载60kg，1500循环/小时，小包装高速产线', 'ACTIVE', 138000.00, 'CNY', 'STANDARD', 1, 25, '0', '0', NOW(), '日化/制药行业');

-- === AGV自动导引系列 (305) — 4个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(1014, '000000', 1, 305, 'RW-AGV-500',  'AGV-500 潜伏牵引式AGV',       '500kg牵引力，激光SLAM导航±10mm，8h续航，自动充电', 'ACTIVE', 85000.00, 'CNY', 'STANDARD', 1, 20, '0', '0', NOW(), '产线物料配送'),
(1015, '000000', 1, 305, 'RW-AGV-1000', 'AGV-1000 顶升式AGV',         '1000kg负载，顶升行程60mm，货架搬运/产线对接', 'ACTIVE', 128000.00, 'CNY', 'ATO', 1, 25, '0', '0', NOW(), '仓库货架搬运'),
(1016, '000000', 1, 305, 'RW-AGV-2000', 'AGV-2000 重载AGV',           '2000kg负载，双舵轮驱动，适合重型模具/设备搬运', 'ACTIVE', 220000.00, 'CNY', 'ATO', 1, 35, '0', '0', NOW(), '重工行业'),
(1017, '000000', 1, 305, 'RW-AGV-FORK', 'AGV-FORK 无人叉车AGV',       '1.5T举升，4m举升高度，视觉+激光复合导航，无人化仓储', 'ACTIVE', 280000.00, 'CNY', 'ATO', 1, 35, '0', '0', NOW(), '立体仓库自动存取');

-- === HEAVY重载系列 (306) — 3个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(1018, '000000', 1, 306, 'RW-HVY-500',  'HEAVY-500 重载搬运机器人',    '6轴重载搬运，负载500kg，臂展2800mm，铸造/锻造上下料', 'ACTIVE', 460000.00, 'CNY', 'ATO', 1, 50, '0', '0', NOW(), '铸造行业'),
(1019, '000000', 1, 306, 'RW-HVY-1000', 'HEAVY-1000 超重载搬运机器人', '6轴超重载，负载1000kg，臂展3200mm，大型铸件/模具搬运', 'ACTIVE', 680000.00, 'CNY', 'ETO', 1, 60, '0', '0', NOW(), '工程机械/船舶'),
(1020, '000000', 1, 306, 'RW-HVY-2000', 'HEAVY-2000 巨型搬运机器人',   '4轴巨型搬运，负载2000kg，臂展4000mm，专为超大件设计', 'PRE_RELEASE', 980000.00, 'CNY', 'ETO', 1, 75, '0', '0', NOW(), '2026Q4正式发布');

-- === COBOT通用协作系列 (307) — 4个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(1021, '000000', 1, 307, 'RW-CB-03',    'CoBot-03 桌面协作机器人',     '6轴桌面协作臂，负载3kg，臂展580mm，即插即用，无需安全围栏', 'ACTIVE', 48000.00, 'CNY', 'STANDARD', 1, 10, '0', '0', NOW(), '实验室/教育/轻型装配'),
(1022, '000000', 1, 307, 'RW-CB-05',    'CoBot-05 标准协作机器人',     '6轴协作臂，负载5kg，臂展900mm，碰撞检测<0.5N，人机安全协作', 'ACTIVE', 68000.00, 'CNY', 'STANDARD', 1, 15, '0', '0', NOW(), '最畅销协作机型'),
(1023, '000000', 1, 307, 'RW-CB-10',    'CoBot-10 大负载协作机器人',   '6轴协作臂，负载10kg，臂展1300mm，IP54防护', 'ACTIVE', 88000.00, 'CNY', 'ATO', 1, 20, '0', '0', NOW(), '机床上下料/包装/检测'),
(1024, '000000', 1, 307, 'RW-CB-20',    'CoBot-20 超大负载协作机器人', '6轴协作臂，负载20kg，臂展1700mm，码垛/搬运专用', 'ACTIVE', 128000.00, 'CNY', 'ATO', 1, 25, '0', '0', NOW(), '重载协作场景');

-- === PREC精密装配系列 (308) — 3个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(1025, '000000', 1, 308, 'RW-PREC-3C',  'PREC-3C 电子装配协作机器人',  '±0.02mm重复精度，视觉引导+力控，3C电子产品精密装配', 'ACTIVE', 98000.00, 'CNY', 'ATO', 1, 25, '0', '0', NOW(), '手机/手表/耳机装配'),
(1026, '000000', 1, 308, 'RW-PREC-SEMI','PREC-SEMI 半导体协作机器人',   '±0.01mm超精密，ISO Class 5洁净室认证，晶圆搬运/封装', 'ACTIVE', 188000.00, 'CNY', 'ETO', 1, 40, '0', '0', NOW(), '半导体前道/后道设备'),
(1027, '000000', 1, 308, 'RW-PREC-LAB', 'PREC-LAB 实验室自动化机器人',  '液体处理+微孔板搬运，适配各品牌移液工作站', 'ACTIVE', 135000.00, 'CNY', 'ATO', 1, 30, '0', '0', NOW(), '药企/基因检测实验室');

-- === SAFE力控协作系列 (309) — 3个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(1028, '000000', 1, 309, 'RW-SAFE-GRD','SAFE-GRD 力控打磨协作机器人',  '内置6维力矩传感器，恒力控制±0.5N，自适应曲面打磨', 'ACTIVE', 115000.00, 'CNY', 'ATO', 1, 25, '0', '0', NOW(), '汽车/卫浴/3C打磨'),
(1029, '000000', 1, 309, 'RW-SAFE-POL', 'SAFE-POL 力控抛光协作机器人', '力矩+视觉双反馈，镜面抛光Ra≤0.02μm', 'ACTIVE', 138000.00, 'CNY', 'ATO', 1, 30, '0', '0', NOW(), '模具/五金抛光'),
(1030, '000000', 1, 309, 'RW-SAFE-ASM', 'SAFE-ASM 力控装配协作机器人', '力位混合控制，精密轴孔装配间隙<5μm', 'ACTIVE', 128000.00, 'CNY', 'ATO', 1, 30, '0', '0', NOW(), 'RV减速器/谐波装配');

-- === PAINT精密喷涂系列 (310) — 3个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(1031, '000000', 1, 310, 'RW-PAINT-6',  'PAINT-6 防爆喷涂机器人',     'ATEX防爆认证，6轴喷涂专用，臂展1800mm，油漆/涂料', 'ACTIVE', 320000.00, 'CNY', 'ATO', 1, 40, '0', '0', NOW(), '汽车涂装线'),
(1032, '000000', 1, 310, 'RW-PAINT-6H', 'PAINT-6H 空心手腕喷涂机器人','空心手腕设计，管路内置无缠绕，臂展2000mm', 'ACTIVE', 380000.00, 'CNY', 'ATO', 1, 45, '0', '0', NOW(), '复杂曲面喷涂'),
(1033, '000000', 1, 310, 'RW-PAINT-RAIL','PAINT-RAIL 龙门式喷涂机器人','龙门架+7轴机器人，超大工件（>10m）整体喷涂', 'ACTIVE', 580000.00, 'CNY', 'ETO', 1, 60, '0', '0', NOW(), '风电叶片/船体喷涂');

-- === COAT自动涂装系列 (311) — 3个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(1034, '000000', 1, 311, 'RW-COAT-PWD', 'COAT-PWD 粉末涂装机器人',     '静电粉末喷涂，上粉率>95%，膜厚均匀±5μm', 'ACTIVE', 280000.00, 'CNY', 'STANDARD', 1, 35, '0', '0', NOW(), '家电/五金粉末涂装'),
(1035, '000000', 1, 311, 'RW-COAT-ED',  'COAT-ED 电泳涂装机器人',      '阴极电泳涂装，盐雾试验>1000h，防腐底漆专用', 'ACTIVE', 350000.00, 'CNY', 'ATO', 1, 40, '0', '0', NOW(), '汽车零部件电泳'),
(1036, '000000', 1, 311, 'RW-COAT-AUTO','COAT-AUTO 自动化涂装工作站',  '集成前处理→喷涂→烘干的一体化涂装工作站', 'ACTIVE', 680000.00, 'CNY', 'ETO', 1, 55, '0', '0', NOW(), '中小件全自动涂装');

-- === SEAL涂胶密封系列 (312) — 3个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(1037, '000000', 1, 312, 'RW-SEAL-GLS', 'SEAL-GLS 玻璃涂胶机器人',     '恒温供胶+视觉引导，胶宽精度±0.5mm，汽车风挡/天窗', 'ACTIVE', 290000.00, 'CNY', 'ATO', 1, 35, '0', '0', NOW(), '汽车玻璃涂胶'),
(1038, '000000', 1, 312, 'RW-SEAL-EP',  'SEAL-EP 电子封装点胶机器人',  '精密点胶±0.1mm，喷射/螺杆/针筒多阀体支持', 'ACTIVE', 180000.00, 'CNY', 'ATO', 1, 30, '0', '0', NOW(), 'PCB/芯片封装点胶'),
(1039, '000000', 1, 312, 'RW-SEAL-BAT', 'SEAL-BAT 电池密封涂胶机器人',  'AB双组份涂胶+视觉检测，动力电池PACK密封', 'ACTIVE', 250000.00, 'CNY', 'ATO', 1, 35, '0', '0', NOW(), '动力电池密封');

-- === SWEEP扫拖一体系列 (313) — 4个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(1040, '000000', 1, 313, 'RW-SWEEP-S1', 'SweepBot S1 扫拖一体机器人',  'LDS激光导航+电控水箱，3000Pa吸力，5200mAh电池', 'ACTIVE', 2999.00, 'CNY', 'STANDARD', 1, 3, '0', '0', NOW(), '家用入门款'),
(1041, '000000', 1, 313, 'RW-SWEEP-S1P','SweepBot S1 Pro 旗舰扫拖机器人','双旋转拖布+自动洗拖布基站，5000Pa吸力，AI脏污识别', 'ACTIVE', 4999.00, 'CNY', 'STANDARD', 1, 5, '0', '0', NOW(), '家用旗舰款，热销'),
(1042, '000000', 1, 313, 'RW-SWEEP-S1M','SweepBot S1 Max 全能扫拖机器人','自动集尘+洗拖布+烘干+上下水，全链路自动化', 'ACTIVE', 6999.00, 'CNY', 'STANDARD', 1, 7, '0', '0', NOW(), '高端全自动清洁'),
(1043, '000000', 1, 313, 'RW-SWEEP-MINI','SweepBot Mini 迷你扫拖机器人', '超薄7.5cm机身，适合低矮家具底部清洁', 'EOL_ANNOUNCED', 1999.00, 'CNY', 'STANDARD', 1, 3, '0', '0', NOW(), '2026Q3停产，替代为S2系列');

-- === NAVI视觉导航系列 (314) — 3个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(1044, '000000', 1, 314, 'RW-NAVI-V1',  'NaviBot V1 AI视觉扫地机器人',  'RGB-D深度相机+AI物体识别，避障率99%，宠物粪便识别', 'ACTIVE', 5999.00, 'CNY', 'STANDARD', 1, 7, '0', '0', NOW(), 'AI视觉避障旗舰'),
(1045, '000000', 1, 314, 'RW-NAVI-V1U', 'NaviBot V1 Ultra 3D结构光版',  'dToF激光雷达+3D结构光+RGB三摄融合，毫米级地图', 'ACTIVE', 7999.00, 'CNY', 'ATO', 1, 10, '0', '0', NOW(), '顶级家用清洁机器人'),
(1046, '000000', 1, 314, 'RW-NAVI-V1W', 'NaviBot V1 Wet 湿拖增强版',    'V1基础上增加自动补水+热水洗拖布(60°C)', 'ACTIVE', 6999.00, 'CNY', 'ATO', 1, 7, '0', '0', NOW(), '深度湿拖场景');

-- === DEEP商用清洁系列 (315) — 3个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(1047, '000000', 1, 315, 'RW-DEEP-800', 'DeepClean 800 商用洗地机器人', '800mm洗地宽度，60L清水+65L污水，4h续航，商场写字楼适用', 'ACTIVE', 58800.00, 'CNY', 'ATO', 1, 15, '0', '0', NOW(), '商业清洁主力'),
(1048, '000000', 1, 315, 'RW-DEEP-1200','DeepClean 1200 大型商用洗地机', '1200mm超宽洗地，100L大容量水箱，8h超长续航', 'ACTIVE', 88000.00, 'CNY', 'ATO', 1, 20, '0', '0', NOW(), '机场/展馆/工厂'),
(1049, '000000', 1, 315, 'RW-DEEP-DIS','DeepClean DIS 消毒洗地一体',    '洗地+紫外线UV-C消毒二合一，医院/学校/养老院适用', 'ACTIVE', 78000.00, 'CNY', 'ATO', 1, 15, '0', '0', NOW(), '医疗/教育行业');

-- === STEM科教启蒙系列 (316) — 4个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(1050, '000000', 1, 316, 'RW-STEM-K1',  'EduBot STEM-K1 入门套件',     '100+积木模块+主控+2电机+图形化编程App，6-8岁', 'ACTIVE', 599.00, 'CNY', 'STANDARD', 1, 3, '0', '0', NOW(), '入门畅销款'),
(1051, '000000', 1, 316, 'RW-STEM-K2',  'EduBot STEM-K2 进阶套件',     '300+模块+主控+4电机+10传感器+Scratch编程，8-12岁', 'ACTIVE', 1299.00, 'CNY', 'STANDARD', 1, 5, '0', '0', NOW(), 'K12教育主力款'),
(1052, '000000', 1, 316, 'RW-STEM-K2C', 'EduBot STEM-K2C 课堂套装',    '6套K2+教师指导书+课程教案PPT+收纳箱，班级教学', 'ACTIVE', 6999.00, 'CNY', 'STANDARD', 1, 7, '0', '0', NOW(), '学校/培训机构'),
(1053, '000000', 1, 316, 'RW-STEM-K3',  'EduBot STEM-K3 竞赛套件',     'VEX/IQ竞赛级套件+铝合金结构+高精度编码电机', 'ACTIVE', 2999.00, 'CNY', 'ATO', 1, 10, '0', '0', NOW(), '机器人竞赛专用');

-- === CODE编程进阶系列 (317) — 3个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(1054, '000000', 1, 317, 'RW-CODE-PY',  'CodeBot Python 编程机器人',    'RPi CM4主控+Python编程+摄像头+语音模块，12-16岁', 'ACTIVE', 2499.00, 'CNY', 'STANDARD', 1, 7, '0', '0', NOW(), 'Python AI入门'),
(1055, '000000', 1, 317, 'RW-CODE-CPP', 'CodeBot C++ 高级编程机器人',   'Jetson Nano主控+C++/ROS编程+激光雷达+SLAM，16-18岁', 'ACTIVE', 4999.00, 'CNY', 'ATO', 1, 10, '0', '0', NOW(), 'ROS机器人开发学习'),
(1056, '000000', 1, 317, 'RW-CODE-AI',  'CodeBot AI 人工智能教学平台',  '集成视觉/语音/NLP教学案例+Jupyter Notebook+云端训练', 'PRE_RELEASE', 8999.00, 'CNY', 'ATO', 1, 15, '0', '0', NOW(), '2026Q4发布，高校AI教学');

-- === BUILD创意搭建系列 (318) — 3个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(1057, '000000', 1, 318, 'RW-BUILD-MK', 'MakerBot 创客套件',            '铝合金结构件200+块+Arduino Mega+面包板+传感器套件', 'ACTIVE', 1599.00, 'CNY', 'STANDARD', 1, 5, '0', '0', NOW(), '创客空间标配'),
(1058, '000000', 1, 318, 'RW-BUILD-IOT','MakerBot IoT 物联网套件',      'ESP32主控+WiFi/BLE+温湿度/气体/PM2.5传感器+云平台', 'ACTIVE', 1899.00, 'CNY', 'STANDARD', 1, 5, '0', '0', NOW(), '物联网教学/科创'),
(1059, '000000', 1, 318, 'RW-BUILD-PRO','MakerBot Pro 专业创客平台',   'CNC加工铝合金件+RPi5+ROS2+机械臂套件+3D打印扩展', 'ACTIVE', 5999.00, 'CNY', 'ATO', 1, 10, '0', '0', NOW(), '高校实验室/专业创客');

-- === PET仿生宠物系列 (319) — 4个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(1060, '000000', 1, 319, 'RW-PET-DOG',  'PetBot Dog 仿生机器狗',        '12自由度+语音交互+人脸识别+自主避障，续航2h', 'ACTIVE', 3999.00, 'CNY', 'STANDARD', 1, 5, '0', '0', NOW(), '儿童陪伴/家庭娱乐'),
(1061, '000000', 1, 319, 'RW-PET-DOGP', 'PetBot Dog Pro 智能机器狗',    '20自由度+视觉SLAM+情感引擎+App远程互动', 'ACTIVE', 6999.00, 'CNY', 'ATO', 1, 7, '0', '0', NOW(), '高端AI宠物'),
(1062, '000000', 1, 319, 'RW-PET-CAT',  'PetBot Cat 仿生机器猫',        '拟真毛皮+动态平衡尾巴+呼噜声模拟+激光追踪游戏', 'ACTIVE', 3299.00, 'CNY', 'STANDARD', 1, 5, '0', '0', NOW(), '猫爱好者/小空间家庭'),
(1063, '000000', 1, 319, 'RW-PET-MINI', 'PetBot Mini 迷你宠物机器人',   '桌面级5cm高，USB充电，办公室/宿舍桌面陪伴', 'ACTIVE', 299.00, 'CNY', 'STANDARD', 1, 3, '0', '0', NOW(), '潮流桌面玩具');

-- === COMP智能陪护系列 (320) — 3个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(1064, '000000', 1, 320, 'RW-COMP-CHD', 'CareBot Child 儿童陪护机器人', 'AI语音对话+故事/儿歌内容库+家长远程视频+护眼屏幕', 'ACTIVE', 2599.00, 'CNY', 'STANDARD', 1, 7, '0', '0', NOW(), '3-10岁儿童陪护'),
(1065, '000000', 1, 320, 'RW-COMP-ELD', 'CareBot Elder 老人陪护机器人', '跌倒检测+用药提醒+紧急呼叫+视频通话+健康数据监测', 'ACTIVE', 4999.00, 'CNY', 'ATO', 1, 10, '0', '0', NOW(), '独居老人/养老社区'),
(1066, '000000', 1, 320, 'RW-COMP-PRO', 'CareBot Pro 专业陪护机器人',   '医疗级健康监测(血压/血氧/心电)+AI慢病管理+医生连线', 'PRE_RELEASE', 8999.00, 'CNY', 'ATO', 1, 15, '0', '0', NOW(), '2026Q4医疗器械认证');

-- === ELDER养老辅助系列 (321) — 3个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(1067, '000000', 1, 321, 'RW-ELD-WALK', 'ElderBot Walk 助行机器人',      '智能助行器+激光避障+电动助力+GPS定位+跌倒自动报警', 'ACTIVE', 8999.00, 'CNY', 'ATO', 1, 15, '0', '0', NOW(), '康复医院/养老院'),
(1068, '000000', 1, 321, 'RW-ELD-LIFT', 'ElderBot Lift 移位护理机器人',  '电动移位机+称重+转运，200kg承重，减少护工体力负担', 'ACTIVE', 12800.00, 'CNY', 'STANDARD', 1, 20, '0', '0', NOW(), '养老机构专业设备'),
(1069, '000000', 1, 321, 'RW-ELD-BED',  'ElderBot Bed 智能护理床机器人', '自动翻身+离床报警+生命体征监测+远程看护', 'ACTIVE', 25800.00, 'CNY', 'ATO', 1, 25, '0', '0', NOW(), '失能老人护理');

-- === BIPED双足人形系列 (322) — 4个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(1070, '000000', 1, 322, 'RW-BPD-S',    'Biped-S 小型双足机器人',       '40cm高，23自由度，IMU+足底力传感器，ROS2/Isaac Sim开发', 'ACTIVE', 29800.00, 'CNY', 'STANDARD', 1, 15, '0', '0', NOW(), '科研/教育平台'),
(1071, '000000', 1, 322, 'RW-BPD-M',    'Biped-M 中型双足机器人',       '80cm高，30自由度，视觉SLAM+全身运动规划，开源SDK', 'ACTIVE', 69800.00, 'CNY', 'ATO', 1, 25, '0', '0', NOW(), '高校实验室首选'),
(1072, '000000', 1, 322, 'RW-BPD-L',    'Biped-L 大型双足机器人',       '140cm高，40自由度，10kg双臂负载，灵巧手操作', 'ACTIVE', 168000.00, 'CNY', 'ETO', 1, 40, '0', '0', NOW(), '科研机构/军方'),
(1073, '000000', 1, 322, 'RW-BPD-PRO',  'Biped-Pro 专业双足平台',       '170cm高，60+自由度，5指灵巧手，全身触觉传感器，大模型接入', 'PRE_RELEASE', 388000.00, 'CNY', 'ETO', 1, 55, '0', '0', NOW(), '2026Q3发布，具身智能研究');

-- === WHEEL轮式人形系列 (323) — 3个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(1074, '000000', 1, 323, 'RW-WHL-S',    'WheelBot-S 轮式人形服务机器人', '轮式底盘+上半身双臂+10寸触控屏+语音交互，展厅/银行', 'ACTIVE', 58000.00, 'CNY', 'ATO', 1, 20, '0', '0', NOW(), '商用服务旗舰'),
(1075, '000000', 1, 323, 'RW-WHL-M',    'WheelBot-M 轮式人形操作机器人', '全向轮底盘+20kg双臂负载+视觉定位，仓储/产线操作', 'ACTIVE', 88000.00, 'CNY', 'ATO', 1, 25, '0', '0', NOW(), '物流/制造复合操作'),
(1076, '000000', 1, 323, 'RW-WHL-AGI',  'WheelBot-AGI 轮式通用智能平台', '集成LLM/VLM大模型+记忆系统+自主学习，研究平台', 'ACTIVE', 158000.00, 'CNY', 'ETO', 1, 35, '0', '0', NOW(), 'AGI/具身智能研究');

-- === HUMANOID全尺寸系列 (324) — 3个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(1077, '000000', 1, 324, 'RW-HMD-G1',   'Humano G1 通用人形机器人',     '170cm/55kg，全身49自由度，双臂7kg负载，5km/h行走', 'ACTIVE', 298000.00, 'CNY', 'ETO', 1, 55, '0', '0', NOW(), '通用人形平台'),
(1078, '000000', 1, 324, 'RW-HMD-G1P',  'Humano G1 Pro 灵巧操作人形',   'G1基础上+5指灵巧手(12自由度/指)+触觉阵列+力控', 'ACTIVE', 498000.00, 'CNY', 'ETO', 1, 65, '0', '0', NOW(), '精密操作/科研'),
(1079, '000000', 1, 324, 'RW-HMD-G1E',  'Humano G1 Explore 探索版',     'G1 Pro+多模态大模型+自主任务规划+长期记忆+工具使用', 'PRE_RELEASE', 698000.00, 'CNY', 'ETO', 1, 75, '0', '0', NOW(), '2026Q3发布，AGI探索平台');

-- === RECEPTION智能接待系列 (325) — 4个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(1080, '000000', 1, 325, 'RW-RECP-LITE','ReceptionBot Lite 轻量接待机器人','10寸屏+语音对话+自主导航+打印小票，适用于中小门店', 'ACTIVE', 19800.00, 'CNY', 'STANDARD', 1, 10, '0', '0', NOW(), '餐饮/零售/酒店'),
(1081, '000000', 1, 325, 'RW-RECP-STD','ReceptionBot Std 标准接待机器人', '双臂挥手+人脸识别+多轮对话+展厅导览+数据看板', 'ACTIVE', 38800.00, 'CNY', 'ATO', 1, 15, '0', '0', NOW(), '政务大厅/企业展厅'),
(1082, '000000', 1, 325, 'RW-RECP-PRO','ReceptionBot Pro 专业接待机器人', '全息投影+多语种同声传译+VIP识别+情感计算', 'ACTIVE', 68800.00, 'CNY', 'ATO', 1, 20, '0', '0', NOW(), '国际会议/高端酒店'),
(1083, '000000', 1, 325, 'RW-RECP-K12', 'ReceptionBot K12 校园接待机器人','卡通外观+安全教育+晨检辅助+访客管理+家校互通', 'ACTIVE', 25800.00, 'CNY', 'ATO', 1, 12, '0', '0', NOW(), '中小学/幼儿园');

-- === DELIVERY物流配送系列 (326) — 4个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(1084, '000000', 1, 326, 'RW-DELV-1D',  'DeliverBot 1D 单舱配送机器人', '单舱30L+电梯联动+4G/5G通信+自动回充，写字楼/酒店', 'ACTIVE', 12800.00, 'CNY', 'STANDARD', 1, 10, '0', '0', NOW(), '楼宇配送入门'),
(1085, '000000', 1, 326, 'RW-DELV-4D',  'DeliverBot 4D 四舱配送机器人', '四舱独立控温+最大载重50kg+电梯联动+多机调度', 'ACTIVE', 25800.00, 'CNY', 'ATO', 1, 15, '0', '0', NOW(), '医院/写字楼标准'),
(1086, '000000', 1, 326, 'RW-DELV-OPEN','DeliverBot Open 开放道路配送车', 'L4自动驾驶+200L货舱+60km续航，园区/校园末端配送', 'ACTIVE', 58000.00, 'CNY', 'ATO', 1, 25, '0', '0', NOW(), '开放道路末端配送'),
(1087, '000000', 1, 326, 'RW-DELV-MED', 'DeliverBot Med 医疗物资配送',    '4舱+温控(-20°C~60°C)+UV消毒+HIS系统对接', 'ACTIVE', 32800.00, 'CNY', 'ATO', 1, 20, '0', '0', NOW(), '医院药品/标本/器械配送');

-- === RETAIL商用零售系列 (327) — 3个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(1088, '000000', 1, 327, 'RW-RTL-GUID','RetailBot Guide 智能导购机器人',  '商品数据库+语音导购+AR试妆/试穿+库存查询+扫码支付', 'ACTIVE', 35800.00, 'CNY', 'ATO', 1, 15, '0', '0', NOW(), '美妆/服装/3C门店'),
(1089, '000000', 1, 327, 'RW-RTL-INV', 'RetailBot INV 智能盘点机器人',   'RFID读取+视觉识别+货架巡检+缺货预警+自动补货建议', 'ACTIVE', 45800.00, 'CNY', 'ATO', 1, 20, '0', '0', NOW(), '商超/仓储零售'),
(1090, '000000', 1, 327, 'RW-RTL-ALL', 'RetailBot ALL 全场景零售方案',   '导购+盘点+促销+客流动线分析+数据中台，一站式零售AI', 'ACTIVE', 88000.00, 'CNY', 'ETO', 1, 30, '0', '0', NOW(), '新零售智慧门店');

-- === INSPECT智能巡检系列 (328) — 4个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(1091, '000000', 1, 328, 'RW-INSP-PET','InspectBot Petro 石化巡检机器人',  'Exd IIC T6防爆+多光谱(可见光/红外/声学)+气体检测', 'ACTIVE', 188000.00, 'CNY', 'ATO', 1, 35, '0', '0', NOW(), '石油/化工/燃气'),
(1092, '000000', 1, 328, 'RW-INSP-PWR','InspectBot Power 电力巡检机器人', '紫外+红外+可见光三光融合+局部放电检测+SF6泄漏', 'ACTIVE', 168000.00, 'CNY', 'ATO', 1, 35, '0', '0', NOW(), '变电站/输电线路'),
(1093, '000000', 1, 328, 'RW-INSP-MINE','InspectBot Mine 矿山巡检机器人', 'MA矿用防爆+激光甲烷遥测+巷道3D建模', 'ACTIVE', 218000.00, 'CNY', 'ATO', 1, 40, '0', '0', NOW(), '煤矿/非煤矿山'),
(1094, '000000', 1, 328, 'RW-INSP-TUN', 'InspectBot Tunnel 隧道巡检机器人','轨道式+裂缝识别+形变监测+漏水检测+500m巡航', 'ACTIVE', 148000.00, 'CNY', 'ETO', 1, 40, '0', '0', NOW(), '地铁/公路/缆线隧道');

-- === RESCUE应急救援系列 (329) — 3个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(1095, '000000', 1, 329, 'RW-RESC-FIR','RescueBot Fire 消防侦察机器人',   '800°C耐高温+热成像+有毒气体检测+水炮联动+2km遥控', 'ACTIVE', 258000.00, 'CNY', 'ETO', 1, 45, '0', '0', NOW(), '消防/危化品事故'),
(1096, '000000', 1, 329, 'RW-RESC-COL','RescueBot Collapse 坍塌救援机器人','蛇形/履带可变形+生命探测雷达+双向语音+物资递送', 'ACTIVE', 328000.00, 'CNY', 'ETO', 1, 50, '0', '0', NOW(), '地震/矿难/建筑坍塌'),
(1097, '000000', 1, 329, 'RW-RESC-AIR', 'RescueBot Air 空中救援机器人',   '系留无人机+4K图传+抛投装置+照明+喊话+中继通信', 'ACTIVE', 198000.00, 'CNY', 'ATO', 1, 30, '0', '0', NOW(), '洪涝/山岳/灾害现场');

-- === MARINE水下作业系列 (330) — 3个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(1098, '000000', 1, 330, 'RW-MAR-300',  'MarineBot 300 水下检测机器人',   'ROV缆控+4K摄像+声呐成像+300m深度+2轴机械手', 'ACTIVE', 198000.00, 'CNY', 'ATO', 1, 40, '0', '0', NOW(), '水下结构检测/管道'),
(1099, '000000', 1, 330, 'RW-MAR-1000', 'MarineBot 1000 深海作业机器人',  'ROV+1000m耐压+5功能机械手+样本采集+光纤通信', 'ACTIVE', 580000.00, 'CNY', 'ETO', 1, 60, '0', '0', NOW(), '深海科考/油气'),
(1100, '000000', 1, 330, 'RW-MAR-AUV',  'MarineBot AUV 自主水下机器人',   'AUV自主航行+侧扫声呐+多波束测深+48h续航+3000m', 'ACTIVE', 980000.00, 'CNY', 'ETO', 1, 75, '0', '0', NOW(), '海洋测绘/军事');


-- =====================================================
-- 四、产品替代关系 (cpq_product_supersession)
-- schema: supersession_id (AUTO_INCREMENT), tenant_id, original_model_id, replacement_model_id,
--          supersession_type, condition_expr, price_impact_pct, effective_date,
--          status, del_flag, create_dept, create_by, create_time, update_by, update_time, remark
-- =====================================================

INSERT INTO cpq_product_supersession (supersession_id, tenant_id, original_model_id, replacement_model_id, supersession_type, condition_expr, price_impact_pct, effective_date, status, del_flag, create_time, remark) VALUES
(1, '000000', 1043, 1040, 'FULL',         NULL,      -33.00, '2026-09-01', '0', '0', NOW(), 'SweepBot Mini停产→S1替代，价格降33%'),
(2, '000000', 1003, 1002, 'CONDITIONAL',  'welding_scenario = "standard_arc"', -21.00, '2026-07-01', '0', '0', NOW(), 'ARC-200P仅在标准电弧焊场景下可降级为ARC-200'),
(3, '000000', 1021, 1022, 'FULL',         NULL,       41.67, '2026-12-31', '0', '0', NOW(), 'CoBot-03逐步退出→CoBot-05替代(覆盖03全部场景)，升价41.67%');


-- =====================================================
-- 五、统计数据
-- =====================================================
-- 产品族(L1):   3条
-- 产品线(L2):   10条
-- 产品系列(L3): 30条
-- 产品:         100条 (model_id 1001-1100)
-- 目录:         3条
-- 替代关系:     3条
-- 生命周期分布:  ACTIVE=94, PRE_RELEASE=5, EOL_ANNOUNCED=1
-- 配置类型分布:  STANDARD=30, ATO=52, ETO=18
-- tenant_id 统一: '000000'
-- =====================================================
