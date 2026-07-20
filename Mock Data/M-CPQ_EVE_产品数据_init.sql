-- =====================================================
-- M-CPQ 产品数据初始化 SQL — 亿纬锂能（EVE Energy）
-- 企业: 惠州亿纬锂能股份有限公司
-- 数据量: 3产品族 / 10产品线 / 30产品系列 / 200产品
-- 基于: M-CPQ_Product_Data_Architecture V1.2
-- 日期: 2026-07-01
-- 可重复执行（幂等）: 先清理EVE专属数据再导入
-- =====================================================

SET NAMES utf8mb4;

-- =====================================================
-- 【幂等清理】删除已有的EVE数据，确保可重复执行
-- =====================================================
-- 清理替代关系
DELETE FROM cpq_product_supersession WHERE tenant_id = '000000' AND supersession_id BETWEEN 4001 AND 4005;
-- 清理产品（model_id 2001-2200）
DELETE FROM cpq_product_model WHERE tenant_id = '000000' AND model_id BETWEEN 2001 AND 2200;
-- 清理产品目录（catalog_id 11-13）
DELETE FROM cpq_product_catalog WHERE tenant_id = '000000' AND catalog_id BETWEEN 11 AND 13;
-- 清理产品分类（category_id: L1=401-403, L2=501-510, L3=601-630）
DELETE FROM cpq_product_category WHERE tenant_id = '000000' AND category_id BETWEEN 401 AND 630;

-- =====================================================
-- 一、产品分类树 (cpq_product_category)
-- 层级: category_level 1=产品族 → 2=产品线 → 3=产品系列
-- schema: category_id, tenant_id, parent_category_id, category_level, category_code, category_name,
--          sort_order, status, del_flag, create_dept, create_by, create_time, update_by, update_time, remark
-- =====================================================

-- === L1: 产品族 (3条) ===

INSERT INTO cpq_product_category (category_id, tenant_id, category_name, category_code, category_level, parent_category_id, sort_order, status, del_flag, create_time, remark) VALUES
(401, '000000', '动力储能电芯', 'POWER_CELLS', 1, NULL, 1, '0', '0', NOW(), '锂离子电芯产品族，覆盖动力电池、储能电芯、圆柱电芯'),
(402, '000000', '户用储能系统', 'HOME_ENERGY', 1, NULL, 2, '0', '0', NOW(), '户用及工商业储能系统，覆盖低压/高压/便携储能'),
(403, '000000', '物联网电池方案', 'IOT_BATTERY', 1, NULL, 3, '0', '0', NOW(), '锂原电池及物联网供电解决方案，覆盖智能表计/安防/追踪');

-- === L2: 产品线 (10条) ===

INSERT INTO cpq_product_category (category_id, tenant_id, category_name, category_code, category_level, parent_category_id, sort_order, status, del_flag, create_time, remark) VALUES
-- 动力储能电芯子线
(501, '000000', '方形磷酸铁锂电芯', 'PRISMATIC_LFP', 2, 401, 1, '0', '0', NOW(), '方形铝壳LFP电芯，覆盖动力/储能场景'),
(502, '000000', '圆柱电芯', 'CYLINDRICAL', 2, 401, 2, '0', '0', NOW(), '圆柱型LFP/NCM电芯，覆盖轻型动力/消费电子'),
(503, '000000', '电芯模组与系统', 'CELL_MODULE', 2, 401, 3, '0', '0', NOW(), '电芯模组、电池包及定制化系统集成'),
-- 户用储能系统子线
(504, '000000', '低压储能系统', 'LOW_VOLTAGE_ESS', 2, 402, 1, '0', '0', NOW(), '48V/51.2V低压户用储能，壁挂/堆叠/机架式'),
(505, '000000', '高压储能系统', 'HIGH_VOLTAGE_ESS', 2, 402, 2, '0', '0', NOW(), '200-800V高压储能，户用大容量/工商业场景'),
(506, '000000', '便携式储能', 'PORTABLE_ESS', 2, 402, 3, '0', '0', NOW(), '便携户外电源，移动应急储能'),
-- 物联网电池方案子线
(507, '000000', '锂亚硫酰氯电池', 'LI_SOCL2_ER', 2, 403, 1, '0', '0', NOW(), 'Li-SOCl₂一次电池，长寿命宽温域，适用于长周期IoT设备'),
(508, '000000', '锂锰电池', 'LI_MNO2_CR', 2, 403, 2, '0', '0', NOW(), 'Li-MnO₂一次/二次电池，高功率输出，适用消费IoT'),
(509, '000000', '物联网电源组合方案', 'IOT_POWER_SOLUTION', 2, 403, 3, '0', '0', NOW(), '电池+电容/充电管理/BMS集成方案包'),
(510, '000000', '工商业储能系统', 'CI_ESS', 2, 402, 4, '0', '0', NOW(), '工商业储能柜/集装箱储能系统');

-- === L3: 产品系列 (30条) ===

INSERT INTO cpq_product_category (category_id, tenant_id, category_name, category_code, category_level, parent_category_id, sort_order, status, del_flag, create_time, remark) VALUES
-- 方形磷酸铁锂电芯系列 (501)
(601, '000000', '小型动力电芯系列 (50-120Ah)', 'LFP_SMALL', 3, 501, 1, '0', '0', NOW(), '50-120Ah方形LFP，面向乘用车/轻型商用车/户储'),
(602, '000000', '中型储能电芯系列 (200-230Ah)', 'LFP_MID', 3, 501, 2, '0', '0', NOW(), '200-230Ah方形LFP，面向工商业储能/UPS'),
(603, '000000', '大容量储能电芯系列 (280-306Ah)', 'LFP_LARGE', 3, 501, 3, '0', '0', NOW(), '280+Ah大方形LFP电芯，面向大型储能电站'),
(604, '000000', '超大容量电芯系列 (500Ah+)', 'LFP_XL', 3, 501, 4, '0', '0', NOW(), '500Ah+超大容量LFP，面向超高能量密度储能'),
-- 圆柱电芯系列 (502)
(605, '000000', '圆柱磷酸铁锂系列', 'CYL_LFP', 3, 502, 1, '0', '0', NOW(), '32140/40135/46800等圆柱LFP，轻型动力/便携储能'),
(606, '000000', '圆柱三元锂系列', 'CYL_NCM', 3, 502, 2, '0', '0', NOW(), '18650/21700圆柱NCM，高能量密度消费电子/工具'),
(607, '000000', '全极耳大圆柱系列', 'CYL_FULLTAB', 3, 502, 3, '0', '0', NOW(), '全极耳结构46系列大圆柱，面向中高端乘用车/商用车'),
-- 电芯模组与系统系列 (503)
(608, '000000', 'VDA标准模组系列', 'MOD_VDA', 3, 503, 1, '0', '0', NOW(), 'VDA标准尺寸电池模组，面向商用车/储能集成'),
(609, '000000', 'CTP电池包系列', 'MOD_CTP', 3, 503, 2, '0', '0', NOW(), 'Cell-to-Pack无模组方案，高成组效率'),
-- 低压储能系统系列 (504)
(610, '000000', 'LVI壁挂储能系列', 'LVI_WALL', 3, 504, 1, '0', '0', NOW(), '48V/51.2V LVI低压壁挂式储能电池包'),
(611, '000000', 'LVI堆叠储能系列', 'LVI_STACK', 3, 504, 2, '0', '0', NOW(), '模块化堆叠式低压储能，灵活扩容'),
(612, '000000', 'LVI机架储能系列', 'LVI_RACK', 3, 504, 3, '0', '0', NOW(), '19英寸机架式低压储能，数据中心/通信基站'),
-- 高压储能系统系列 (505)
(613, '000000', 'HVI高压壁挂系列', 'HVI_WALL', 3, 505, 1, '0', '0', NOW(), '200-800V高压壁挂储能，大容量户用/小型工商业'),
(614, '000000', 'HVI高压电池箱系列', 'HVI_BOX', 3, 505, 2, '0', '0', NOW(), '高压电池簇/箱体，工商业储能'),
-- 便携式储能系列 (506)
(615, '000000', '便携应急电源系列', 'PLW_PORTABLE', 3, 506, 1, '0', '0', NOW(), '便携式户外电源，500W-3000W输出'),
(616, '000000', '便携专业电源系列', 'PLW_PRO', 3, 506, 2, '0', '0', NOW(), '专业级移动储能，大功率工业/户外作业'),
-- 锂亚硫酰氯电池系列 (507)
(617, '000000', 'ER微型电池系列 (1/2AA)', 'ER_MINI', 3, 507, 1, '0', '0', NOW(), 'ER14250等1/2AA尺寸，适用于小型传感器/卡片终端'),
(618, '000000', 'ER标准型电池系列 (AA/A)', 'ER_STD', 3, 507, 2, '0', '0', NOW(), 'ER14505/ER18505等AA/A尺寸，适用于智能表计/安防'),
(619, '000000', 'ER大容量电池系列 (C/D)', 'ER_LARGE', 3, 507, 3, '0', '0', NOW(), 'ER26500/ER34615等C/D尺寸，适用追踪器/远传终端'),
(620, '000000', 'ER+SPC复合电容系列', 'ER_SPC', 3, 507, 4, '0', '0', NOW(), '锂亚电池+超级电容脉冲，适用NB-IoT/无线远传'),
-- 锂锰电池系列 (508)
(621, '000000', 'CR圆柱电池系列', 'CR_CYL', 3, 508, 1, '0', '0', NOW(), 'CR123A/CR2/CR14505等圆柱锂锰电池，高功率安防'),
(622, '000000', 'CR扣式电池系列', 'CR_BTN', 3, 508, 2, '0', '0', NOW(), 'CR2032/CR2025/CR2450等扣式锂锰，电子标签/遥控器'),
(623, '000000', 'CR-HP高功率电池系列', 'CR_HP', 3, 508, 3, '0', '0', NOW(), '高倍率锂锰电池，适用于电子烟/无人机/医疗设备'),
-- 物联网电源组合方案系列 (509)
(624, '000000', '智能表计电源方案', 'IOT_METER', 3, 509, 1, '0', '0', NOW(), '智能电表/水表/燃气表专用电池组及电源方案'),
(625, '000000', '智能安防电源方案', 'IOT_SECURITY', 3, 509, 2, '0', '0', NOW(), '智能门锁/监控/报警器专用电源方案'),
(626, '000000', 'GPS追踪定位电源方案', 'IOT_TRACKER', 3, 509, 3, '0', '0', NOW(), '冷链追踪/资产追踪/车载定位专用电源'),
-- 工商业储能系统系列 (510)
(627, '000000', '户外储能柜系列', 'CI_OUTDOOR', 3, 510, 1, '0', '0', NOW(), '200kWh-1MWh户外柜式储能系统，IP55户外部署'),
(628, '000000', '集装箱储能系列', 'CI_CONTAINER', 3, 510, 2, '0', '0', NOW(), '20/40尺集装箱储能，MWh级大型储能电站'),
(629, '000000', '工商业一体机系列', 'CI_ALLINONE', 3, 510, 3, '0', '0', NOW(), '光储充一体机，工商业园区综合能源'),
(630, '000000', '光储逆变器系列', 'PCS_INVERTER', 3, 505, 3, '0', '0', NOW(), '储能逆变器/PCS，适配高压储能系统');


-- =====================================================
-- 二、产品目录 (cpq_product_catalog)
-- =====================================================

INSERT INTO cpq_product_catalog (catalog_id, tenant_id, catalog_name, catalog_type, effective_date, expiry_date, status, del_flag, create_time, remark) VALUES
(11, '000000', 'EVE 标准产品目录（国内）',    'SALES',   '2026-01-01', '2028-12-31', '0', '0', NOW(), '面向国内直销和渠道的电芯/储能/IoT标准销售目录'),
(12, '000000', 'EVE 海外产品目录（全球）',    'SALES',   '2026-01-01', '2028-12-31', '0', '0', NOW(), '面向海外市场的出口目录（含UN38.3/IEC/UL认证产品）'),
(13, '000000', 'EVE 大客户定制目录',          'CHANNEL', '2026-01-01', '2028-12-31', '0', '0', NOW(), '面向战略合作伙伴/整车厂的定制电芯与模组目录');


-- =====================================================
-- 三、可销售产品 (cpq_product_model) — 200个产品
-- model_id: 2001-2200
-- =====================================================

-- === 小型动力电芯系列 (601) — 10个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(2001, '000000', 11, 601, 'EVE-LF50K',   'LF50K 3.2V 50Ah 方形磷酸铁锂电芯',   '车规级LFP电芯，标称容量50Ah，适用于乘用车动力电池/两轮车换电/小型储能', 'ACTIVE', 158.00, 'CNY', 'STANDARD', 100, 15, '0', '0', NOW(), '乘用车入门级标准电芯'),
(2002, '000000', 11, 601, 'EVE-LF60',    'LF60 3.2V 60Ah 方形磷酸铁锂电芯',    '标称容量60Ah，能量密度160Wh/kg，适用轻卡/小型储能系统', 'ACTIVE', 185.00, 'CNY', 'STANDARD', 100, 15, '0', '0', NOW(), '轻卡动力电池标配'),
(2003, '000000', 11, 601, 'EVE-LF75',    'LF75 3.2V 75Ah 方形磷酸铁锂电芯',    '标称容量75Ah，3500次循环@80%SOH，适用物流车/低速电动车', 'ACTIVE', 225.00, 'CNY', 'STANDARD', 100, 15, '0', '0', NOW(), '物流车主力电芯'),
(2004, '000000', 11, 601, 'EVE-LF80',    'LF80 3.2V 80Ah 方形磷酸铁锂电芯',    '标称容量80Ah，1C持续充放，适用电动叉车/AGV/工程机械', 'ACTIVE', 240.00, 'CNY', 'STANDARD', 100, 15, '0', '0', NOW(), '工业车辆专用'),
(2005, '000000', 11, 601, 'EVE-LF90K',   'LF90K 3.2V 90Ah 方形磷酸铁锂电芯',   '车规级90Ah，能量密度170Wh/kg，适用A0/A00级乘用车', 'ACTIVE', 268.00, 'CNY', 'STANDARD', 100, 15, '0', '0', NOW(), 'A00级乘用车主力电芯'),
(2006, '000000', 11, 601, 'EVE-LF100L',  'LF100L 3.2V 100Ah 方形磷酸铁锂电芯',  '100Ah长循环型，6000次循环@80%SOH，户用储能/基站备电首选', 'ACTIVE', 295.00, 'CNY', 'STANDARD', 50, 15, '0', '0', NOW(), '户储电芯标杆产品'),
(2007, '000000', 11, 601, 'EVE-LF100LA', 'LF100LA 3.2V 100Ah 长寿命增强型电芯', '100Ah超长循环，8000次循环@80%SOH，铝壳加强封装', 'ACTIVE', 325.00, 'CNY', 'STANDARD', 50, 20, '0', '0', NOW(), '极致长寿命，10年+设计'),
(2008, '000000', 11, 601, 'EVE-LF105',   'LF105 3.2V 105Ah 方形磷酸铁锂电芯',   '标称容量105Ah，标准乘用车尺寸，适用网约车/出租车换电', 'ACTIVE', 310.00, 'CNY', 'STANDARD', 100, 15, '0', '0', NOW(), '换电车型标准电芯'),
(2009, '000000', 11, 601, 'EVE-LF120L',  'LF120L 3.2V 120Ah 方形磷酸铁锂电芯',  '标称容量120Ah，1C充放，适用中型储能/商用车辅电', 'ACTIVE', 360.00, 'CNY', 'ATO', 50, 20, '0', '0', NOW(), '中型储能高性价比电芯'),
(2010, '000000', 11, 601, 'EVE-LF120L-HP','LF120L-HP 3.2V 120Ah 高功率型电芯', '120Ah+2C持续放电，适用混合动力/功率型储能调频', 'ACTIVE', 420.00, 'CNY', 'ATO', 50, 25, '0', '0', NOW(), '功率型储能用');

-- === 中型储能电芯系列 (602) — 8个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(2011, '000000', 11, 602, 'EVE-LF202',   'LF202 3.22V 202Ah 方形磷酸铁锂电芯',  '标称容量202Ah，3.22V平台，适用中巴/轻卡/户储/便携储能', 'ACTIVE', 580.00, 'CNY', 'STANDARD', 50, 20, '0', '0', NOW(), '200Ah级主力电芯，应用广泛'),
(2012, '000000', 11, 602, 'EVE-LF202-HV', 'LF202-HV 3.22V 202Ah 高压平台电芯',  'LF202升级版，3.25V平台电压，能量密度+3%', 'ACTIVE', 610.00, 'CNY', 'STANDARD', 50, 20, '0', '0', NOW(), '高压平台选型'),
(2013, '000000', 11, 602, 'EVE-LF210',   'LF210 3.2V 210Ah 方形磷酸铁锂电芯',  '标称容量210Ah，5000次循环，适用工商业储能/UPS备电', 'ACTIVE', 610.00, 'CNY', 'STANDARD', 50, 20, '0', '0', NOW(), '工商业储能中坚力量'),
(2014, '000000', 11, 602, 'EVE-LF230',   'LF230 3.2V 230Ah 方形磷酸铁锂电芯',  '标称容量230Ah，铝壳封装，IP67防护，适用严苛户外储能', 'ACTIVE', 670.00, 'CNY', 'ATO', 50, 25, '0', '0', NOW(), '户外储能严苛环境'),
(2015, '000000', 11, 602, 'EVE-LF230-CE', 'LF230-CE 3.2V 230Ah CE认证出口型电芯', 'LF230海外版，CE/IEC62619认证，出口欧洲储能市场', 'ACTIVE', 710.00, 'CNY', 'STANDARD', 50, 25, '0', '0', NOW(), '欧洲市场认证产品'),
(2016, '000000', 11, 602, 'EVE-LF230-UL', 'LF230-UL 3.2V 230Ah UL认证出口型电芯', 'LF230北美版，UL1973/UL9540A认证，出口北美储能市场', 'ACTIVE', 740.00, 'CNY', 'STANDARD', 50, 30, '0', '0', NOW(), '北美市场认证产品'),
(2017, '000000', 11, 602, 'EVE-LF240',   'LF240 3.2V 240Ah 方形磷酸铁锂电芯',  '标称容量240Ah，新一代230Ah升级，能量密度185Wh/kg', 'PRE_RELEASE', 700.00, 'CNY', 'ATO', 50, 30, '0', '0', NOW(), '2026Q4正式发布，替代LF230'),
(2018, '000000', 11, 602, 'EVE-LF200M',  'LF200M 3.2V 200Ah 轻型模组电芯',      '轻薄化200Ah电芯，高成组效率，专为模组集成优化', 'ACTIVE', 600.00, 'CNY', 'ATO', 100, 20, '0', '0', NOW(), '模组集成专用设计');

-- === 大容量储能电芯系列 (603) — 10个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(2019, '000000', 11, 603, 'EVE-LF280K',  'LF280K 3.2V 280Ah 方形磷酸铁锂电芯', '280Ah长循环型，8000次循环@80%SOH，大型储能电站主力电芯', 'ACTIVE', 820.00, 'CNY', 'STANDARD', 50, 25, '0', '0', NOW(), '280Ah标杆产品，全球出货量领先'),
(2020, '000000', 11, 603, 'EVE-LF280K-V2','LF280K-V2 3.2V 280Ah 第二代增强电芯', 'LF280K迭代版，内阻降低15%，循环提升至10000次', 'ACTIVE', 880.00, 'CNY', 'STANDARD', 50, 25, '0', '0', NOW(), '第二代280Ah旗舰'),
(2021, '000000', 11, 603, 'EVE-LF280N',  'LF280N 3.2V 280Ah 钠离子复合电芯',   '280Ah钠锂复合体系，低成本储能专用，-30°C可用', 'PRE_RELEASE', 680.00, 'CNY', 'ATO', 100, 35, '0', '0', NOW(), '2026Q4钠离子产品线首发'),
(2022, '000000', 11, 603, 'EVE-LF304',   'LF304 3.2V 304Ah 方形磷酸铁锂电芯', '304Ah大容量，能量密度185Wh/kg，下一代280Ah迭代方向', 'ACTIVE', 890.00, 'CNY', 'STANDARD', 50, 25, '0', '0', NOW(), '300Ah级主流产品'),
(2023, '000000', 11, 603, 'EVE-LF304-HV', 'LF304-HV 3.25V 304Ah 高压平台电芯',  'LF304高压版，3.25V平台，系统能量密度+2%', 'ACTIVE', 920.00, 'CNY', 'ATO', 50, 25, '0', '0', NOW(), '高压储能系统首选'),
(2024, '000000', 11, 603, 'EVE-LF306',   'LF306 3.2V 306Ah 方形磷酸铁锂电芯', '306Ah极致容量，能量密度188Wh/kg，5MWh+储能系统', 'ACTIVE', 950.00, 'CNY', 'ATO', 50, 30, '0', '0', NOW(), '5MWh以上储能系统'),
(2025, '000000', 11, 603, 'EVE-MB31',    'MB31 3.2V 314Ah Mr.Big平台电芯',     'Mr.Big平台314Ah，创新叠片工艺，体积能量密度大幅提升', 'ACTIVE', 980.00, 'CNY', 'ATO', 50, 30, '0', '0', NOW(), 'Mr.Big平台首个量产电芯'),
(2026, '000000', 11, 603, 'EVE-MB56',    'MB56 3.2V 560Ah Mr.Big超大容量电芯', 'Mr.Big平台560Ah，叠片+铝壳一体成型，极致成本', 'PRE_RELEASE', 1680.00, 'CNY', 'ETO', 10, 45, '0', '0', NOW(), '标准化量产验证中'),
(2027, '000000', 11, 603, 'EVE-LF280C',  'LF280C 3.2V 280Ah 成本优化型电芯',    '280Ah成本优化版，牺牲5%循环寿命，价格下降15%', 'ACTIVE', 700.00, 'CNY', 'STANDARD', 100, 25, '0', '0', NOW(), '极高性价比大容量电芯'),
(2028, '000000', 11, 603, 'EVE-LF280P',  'LF280P 3.2V 280Ah 功率型储能电芯',    '280Ah功率增强型，2C持续放电，适用调频/电网支撑', 'ACTIVE', 880.00, 'CNY', 'ATO', 50, 30, '0', '0', NOW(), '电力调频专用');

-- === 超大容量电芯系列 (604) — 5个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(2029, '000000', 11, 604, 'EVE-LF500',   'LF500 3.2V 500Ah 方形磷酸铁锂电芯',  '500Ah超大容量，单电芯1.6kWh，大幅降低Pack成本', 'ACTIVE', 1420.00, 'CNY', 'ETO', 10, 45, '0', '0', NOW(), '超大容量先行产品'),
(2030, '000000', 11, 604, 'EVE-LF560K',  'LF560K 3.2V 560Ah Mr.Big极致容量电芯', '560Ah超大容量，直径71mm超大极柱，叠片工艺', 'PRE_RELEASE', 1650.00, 'CNY', 'ETO', 10, 55, '0', '0', NOW(), '标志性产品Mr.Big'),
(2031, '000000', 11, 604, 'EVE-LF628',   'LF628 3.2V 628Ah 超大容量电芯终极版','628Ah极限容量，单电芯2kWh+，瞄准下一代8MWh储能系统', 'PRE_RELEASE', 1980.00, 'CNY', 'ETO', 5, 60, '0', '0', NOW(), '2026Q4开始送样'),
(2032, '000000', 11, 604, 'EVE-LF560K-EX', 'LF560K-EX 3.2V 560Ah 出口定制版',  '560Ah出口版，可选UN38.3/IEC/UL全套认证包', 'PRE_RELEASE', 1780.00, 'CNY', 'ETO', 10, 55, '0', '0', NOW(), '海外市场定制'),
(2033, '000000', 11, 604, 'EVE-LF700',   'LF700 3.2V 700Ah 下一代原型电芯',   '研发阶段700Ah电芯，固态电解质预研，面向2027年', 'PRE_RELEASE', 0.00, 'CNY', 'ETO', 1, 90, '0', '0', NOW(), '研发中，仅供参考');

-- === 圆柱磷酸铁锂系列 (605) — 8个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(2034, '000000', 11, 605, 'EVE-32140-15','32140-15Ah 3.2V 圆柱磷酸铁锂电芯',  '32mm×140mm，15Ah，适用于两轮车换电/便携储能', 'ACTIVE', 48.00, 'CNY', 'STANDARD', 200, 10, '0', '0', NOW(), '两轮车换电标准电芯'),
(2035, '000000', 11, 605, 'EVE-32140-20','32140-20Ah 3.2V 圆柱磷酸铁锂电芯',  '32mm×140mm，20Ah，高容量版，适用三轮车/AGV', 'ACTIVE', 62.00, 'CNY', 'STANDARD', 200, 10, '0', '0', NOW(), '三轮车/物流机器人'),
(2036, '000000', 11, 605, 'EVE-40135-20','40135-20Ah(C40) 3.2V 圆柱磷酸铁锂电芯','40mm×135mm，20Ah，标准化C40平台，适用轻型电动车', 'ACTIVE', 65.00, 'CNY', 'STANDARD', 200, 10, '0', '0', NOW(), 'C40标准化平台'),
(2037, '000000', 11, 605, 'EVE-40135-25','40135-25Ah 3.2V 圆柱磷酸铁锂电芯',  '40mm×135mm，25Ah，C40平台高容量版', 'ACTIVE', 78.00, 'CNY', 'STANDARD', 200, 10, '0', '0', NOW(), 'C40高容量升级'),
(2038, '000000', 11, 605, 'EVE-46145-35','46145-35Ah 3.2V 圆柱磷酸铁锂电芯',  '46mm×145mm，35Ah，适用微面/小型物流车', 'ACTIVE', 105.00, 'CNY', 'STANDARD', 100, 15, '0', '0', NOW(), '微面动力电池'),
(2039, '000000', 11, 605, 'EVE-46800-30','46800-30Ah 3.2V 圆柱磷酸铁锂电芯',  '46mm×80mm，30Ah，适用乘用车/储能模组', 'ACTIVE', 92.00, 'CNY', 'ATO', 100, 15, '0', '0', NOW(), '46系列标准尺寸'),
(2040, '000000', 11, 605, 'EVE-32700-6', '32700-6Ah 3.2V 圆柱磷酸铁锂电芯',    '32mm×70mm，6Ah，标准32700尺寸，太阳能路灯/户外设备', 'ACTIVE', 18.00, 'CNY', 'STANDARD', 500, 7, '0', '0', NOW(), '光伏储能小电芯'),
(2041, '000000', 11, 605, 'EVE-26700-4', '26700-4Ah 3.2V 圆柱磷酸铁锂电芯',    '26mm×70mm，4Ah，适用电动工具/小型储能', 'ACTIVE', 12.00, 'CNY', 'STANDARD', 500, 7, '0', '0', NOW(), '消费级小电芯');

-- === 圆柱三元锂系列 (606) — 5个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(2042, '000000', 11, 606, 'EVE-18650-3.5','INR18650-3.5Ah 3.6V 三元圆柱电芯',  '18650标准尺寸，3.5Ah，高能量密度，适用消费电子/电动工具', 'ACTIVE', 8.50, 'CNY', 'STANDARD', 1000, 7, '0', '0', NOW(), '消费电子通用电芯'),
(2043, '000000', 11, 606, 'EVE-21700-5', 'INR21700-5Ah 3.6V 三元圆柱电芯',     '21700标准尺寸，5Ah，高能量密度，适用电动工具/吸尘器', 'ACTIVE', 15.00, 'CNY', 'STANDARD', 500, 10, '0', '0', NOW(), '21700平台主销型号'),
(2044, '000000', 11, 606, 'EVE-21700-5P', 'INR21700-5P 3.6V 高功率三元电芯',    '21700高功率版，10A持续放电，适用园林工具/无人机', 'ACTIVE', 18.00, 'CNY', 'STANDARD', 500, 10, '0', '0', NOW(), '高功率21700'),
(2045, '000000', 11, 606, 'EVE-26650-5', 'INR26650-5Ah 3.6V 三元圆柱电芯',     '26650标准尺寸，5Ah，大直径高容量，适用特种工具/照明', 'ACTIVE', 20.00, 'CNY', 'STANDARD', 200, 10, '0', '0', NOW(), '26650工业级电芯'),
(2046, '000000', 11, 606, 'EVE-18650-2.6','ICR18650-2.6Ah 3.7V 钴酸锂圆柱电芯', '18650钴酸锂体系，2.6Ah，超高能量密度，消费数码', 'EOL_ANNOUNCED', 6.50, 'CNY', 'STANDARD', 1000, 7, '0', '0', NOW(), '逐步替代为NCM体系');

-- === 全极耳大圆柱系列 (607) — 6个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(2047, '000000', 11, 607, 'EVE-46120-30','46系列全极耳-30Ah 大圆柱磷酸铁锂电芯', '46120全极耳结构，30Ah，内阻<1mΩ，适用HEV/快充BEV', 'ACTIVE', 95.00, 'CNY', 'ATO', 100, 20, '0', '0', NOW(), '全极耳技术HEV专用'),
(2048, '000000', 11, 607, 'EVE-4695-35', '4695全极耳-35Ah 大圆柱三元锂电芯',   '4695全极耳NCM，35Ah，3C快充15分钟80%，乘用车BEV', 'ACTIVE', 118.00, 'CNY', 'ATO', 100, 20, '0', '0', NOW(), '乘用车快充电芯'),
(2049, '000000', 11, 607, 'EVE-46120-NCM','46120全极耳-28Ah 大圆柱NCM电芯',     '46120全极耳NCM，28Ah，兼顾能量与功率，适用插混/增程', 'ACTIVE', 105.00, 'CNY', 'ATO', 100, 20, '0', '0', NOW(), 'PHEV/EREV优选'),
(2050, '000000', 11, 607, 'EVE-46120-HP', '46120全极耳-25Ah 超高功率型电芯',    '46120全极耳，25Ah，持续10C放电，适用12V启停/48V轻混', 'ACTIVE', 110.00, 'CNY', 'ATO', 100, 25, '0', '0', NOW(), '启停/轻混专用'),
(2051, '000000', 11, 607, 'EVE-4695-40', '4695全极耳-40Ah 大容量圆柱电芯',     '4695全极耳，40Ah，极致容量，适用大型储能/电动重卡', 'PRE_RELEASE', 138.00, 'CNY', 'ETO', 100, 30, '0', '0', NOW(), '2026Q4量产验证'),
(2052, '000000', 11, 607, 'EVE-46120-LFP','46120全极耳-32Ah 大圆柱LFP电芯',     '46120全极耳LFP体系，32Ah，极致安全，适用储能/商用', 'ACTIVE', 98.00, 'CNY', 'ATO', 100, 20, '0', '0', NOW(), 'LFP全极耳商用化');

-- === VDA标准模组系列 (608) — 5个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(2053, '000000', 11, 608, 'EVE-MOD-VDA355','VDA355标准模组 12S1P LF280K',   'VDA355尺寸，12串LF280K，10.7kWh，适用商用车/储能', 'ACTIVE', 12800.00, 'CNY', 'ATO', 10, 30, '0', '0', NOW(), '商用车标准模组'),
(2054, '000000', 11, 608, 'EVE-MOD-VDA390','VDA390标准模组 16S1P LF100L',   'VDA390尺寸，16串LF100L，5.12kWh，适用A级乘用车', 'ACTIVE', 6200.00, 'CNY', 'STANDARD', 20, 25, '0', '0', NOW(), '乘用车标准模组'),
(2055, '000000', 11, 608, 'EVE-MOD-1P48S', '1P48S标准模组 LF304储能专用',     '1并48串LF304，46.7kWh，适用大型储能集装箱', 'ACTIVE', 51000.00, 'CNY', 'ATO', 5, 35, '0', '0', NOW(), '储能系统核心模组'),
(2056, '000000', 11, 608, 'EVE-MOD-2P24S', '2P24S标准模组 LF100L 两并型',     '2并24串LF100L，15.4kWh，适用工商业储能柜', 'ACTIVE', 18500.00, 'CNY', 'ATO', 10, 30, '0', '0', NOW(), '工商业储能主力模组'),
(2057, '000000', 11, 608, 'EVE-MOD-CUS',  '定制化模组（需定义串并数及电芯型号）', '支持灵活配置串并数/电芯/BMS，面向OEM定制需求', 'ACTIVE', 0.00, 'CNY', 'ETO', 1, 45, '0', '0', NOW(), '模组定制化服务');

-- === CTP电池包系列 (609) — 5个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(2058, '000000', 11, 609, 'EVE-CTP-30K',  'CTP-30kWh 磷酸铁锂电池包',          '30kWh CTP方案，LF100L电芯，适用于轻型商用车/物流车', 'ACTIVE', 32000.00, 'CNY', 'ATO', 5, 35, '0', '0', NOW(), '轻型商用车CTP包'),
(2059, '000000', 11, 609, 'EVE-CTP-50K',  'CTP-50kWh 磷酸铁锂电池包',          '50kWh CTP方案，LF120L电芯，适用于A级乘用车', 'ACTIVE', 51000.00, 'CNY', 'ATO', 5, 35, '0', '0', NOW(), 'A级乘用车CTP包'),
(2060, '000000', 11, 609, 'EVE-CTP-80K',  'CTP-80kWh 大容量磷酸铁锂电池包',     '80kWh CTP方案，LF230电芯，适用于B级乘用车/中客', 'ACTIVE', 80000.00, 'CNY', 'ATO', 5, 40, '0', '0', NOW(), '长续航乘用车CTP包'),
(2061, '000000', 11, 609, 'EVE-CTP-S100', 'CTP-S100 储能CTP电池包(100kWh)',    '100kWh CTP储能包，LF280K电芯，IP55户外直装', 'ACTIVE', 95000.00, 'CNY', 'ATO', 3, 40, '0', '0', NOW(), '储能CTP标准化包'),
(2062, '000000', 11, 609, 'EVE-CTP-C300', 'CTP-C300 商用车CTP电池包(300kWh)',  '300kWh CTP商用车包，LF306电芯，适用重卡/矿卡', 'ACTIVE', 290000.00, 'CNY', 'ETO', 1, 50, '0', '0', NOW(), '重卡/矿卡专用');

-- === LVI壁挂储能系列 (610) — 12个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(2063, '000000', 11, 610, 'EVE-LVI-5.0',  'EVE-LVI-5.0 5.12kWh 低压壁挂储能',    '51.2V 100Ah，内置LF100LA电芯，壁挂式，IP65，适用户用光伏配储', 'ACTIVE', 4500.00, 'CNY', 'STANDARD', 1, 10, '0', '0', NOW(), '低压壁挂入门款，热销全球'),
(2064, '000000', 11, 610, 'EVE-LVI-5.0-P','EVE-LVI-5.0-P 5.12kWh 加强版壁挂储能', '51.2V 100Ah，IP67户外加强，支持-20°C~55°C工作，含加热膜', 'ACTIVE', 5200.00, 'CNY', 'STANDARD', 1, 10, '0', '0', NOW(), '寒冷/高温地区适用'),
(2065, '000000', 11, 610, 'EVE-LVW-5.0',  'EVE-LVW-5.0 5.12kWh 超薄壁挂储能',    '51.2V 100Ah，超薄设计仅12cm，适用安装空间受限场景', 'ACTIVE', 4800.00, 'CNY', 'STANDARD', 1, 12, '0', '0', NOW(), '空间受限场景'),
(2066, '000000', 11, 610, 'EVE-LVI-10.0', 'EVE-LVI-10.0 10.24kWh 低压壁挂储能',  '51.2V 200Ah(2P16S)，两倍LVI-5.0容量一体式设计', 'ACTIVE', 8200.00, 'CNY', 'STANDARD', 1, 12, '0', '0', NOW(), '中等容量家庭'),
(2067, '000000', 11, 610, 'EVE-LVI-10.0-P','EVE-LVI-10.0-P 10.24kWh 加强版壁挂储能','51.2V 200Ah，IP67户外+加热膜+防盐雾，海岛/高海拔适用', 'ACTIVE', 9200.00, 'CNY', 'ATO', 1, 15, '0', '0', NOW(), '极端环境增强'),
(2068, '000000', 11, 610, 'EVE-LVI-15.0', 'EVE-LVI-15.0 15.36kWh 低压壁挂储能',  '51.2V 300Ah(3P16S)，大容量家庭储能，可实现全屋备电', 'ACTIVE', 11800.00, 'CNY', 'STANDARD', 1, 15, '0', '0', NOW(), '大户型全屋备电'),
(2069, '000000', 11, 610, 'EVE-LVI-20.0', 'EVE-LVI-20.0 20.48kWh 低压壁挂储能',  '51.2V 400Ah(4P16S)，超大家庭/小型商业储能', 'ACTIVE', 15200.00, 'CNY', 'ATO', 1, 15, '0', '0', NOW(), '超大容量壁挂储能'),
(2070, '000000', 11, 610, 'EVE-LVI-25.0', 'EVE-LVI-25.0 25.6kWh 低压壁挂储能',  '51.2V 500Ah(5P16S)，最大容量一体式壁挂，小型商业应用', 'ACTIVE', 18500.00, 'CNY', 'ATO', 1, 20, '0', '0', NOW(), '低压壁挂旗舰款'),
(2071, '000000', 11, 610, 'EVE-LVW-10.0', 'EVE-LVW-10.0 10.24kWh 超薄壁挂储能',  '51.2V 200Ah，超薄双模组设计，厚度仅14cm', 'ACTIVE', 8800.00, 'CNY', 'STANDARD', 1, 12, '0', '0', NOW(), '超薄大容量'),
(2072, '000000', 11, 610, 'EVE-LVI-7.5',  'EVE-LVI-7.5 7.68kWh 低压壁挂储能',    '51.2V 150Ah，中小户型黄金容量', 'ACTIVE', 6300.00, 'CNY', 'STANDARD', 1, 10, '0', '0', NOW(), '中小户型最佳配比'),
(2073, '000000', 11, 610, 'EVE-LVI-3.0',  'EVE-LVI-3.0 3.07kWh 低压紧凑壁挂储能', '51.2V 60Ah，公寓/小户型/阳台光伏', 'ACTIVE', 2800.00, 'CNY', 'STANDARD', 1, 10, '0', '0', NOW(), '最小容量入门'),
(2074, '000000', 11, 610, 'EVE-LVI-10.0-UL','EVE-LVI-10.0-UL 10.24kWh UL认证版',  '北美版10.24kWh，UL1973/UL9540A全套认证', 'ACTIVE', 9200.00, 'CNY', 'STANDARD', 1, 20, '0', '0', NOW(), '北美市场专属');

-- === LVI堆叠储能系列 (611) — 8个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(2075, '000000', 11, 611, 'EVE-STACK-B5K',  'Stack-B5K 5.12kWh 基础堆叠模块',   '51.2V 100Ah基础堆叠模块，支持2-6个并机，灵活扩容', 'ACTIVE', 4200.00, 'CNY', 'STANDARD', 1, 10, '0', '0', NOW(), '堆叠式基础单元'),
(2076, '000000', 11, 611, 'EVE-STACK-B10K', 'Stack-B10K 10.24kWh 堆叠储能系统','2×B5K模块+底座+BMS控制器，10.24kWh完整系统', 'ACTIVE', 8600.00, 'CNY', 'STANDARD', 1, 10, '0', '0', NOW(), '2模块基础系统'),
(2077, '000000', 11, 611, 'EVE-STACK-B15K', 'Stack-B15K 15.36kWh 堆叠储能系统','3×B5K模块，15.36kWh堆叠系统，中等家庭', 'ACTIVE', 12300.00, 'CNY', 'STANDARD', 1, 12, '0', '0', NOW(), '3模块标准系统'),
(2078, '000000', 11, 611, 'EVE-STACK-B20K', 'Stack-B20K 20.48kWh 堆叠储能系统','4×B5K模块，20.48kWh大容量堆叠系统', 'ACTIVE', 16000.00, 'CNY', 'STANDARD', 1, 12, '0', '0', NOW(), '4模块大容量系统'),
(2079, '000000', 11, 611, 'EVE-STACK-B25K', 'Stack-B25K 25.6kWh 堆叠储能系统', '5×B5K模块，25.6kWh超大容量堆叠', 'ACTIVE', 19800.00, 'CNY', 'ATO', 1, 15, '0', '0', NOW(), '5模块超大容量'),
(2080, '000000', 11, 611, 'EVE-STACK-B30K', 'Stack-B30K 30.72kWh 堆叠旗舰储能', '6×B5K模块，30.72kWh最大堆叠配置，小型商业', 'ACTIVE', 23500.00, 'CNY', 'ATO', 1, 15, '0', '0', NOW(), '6模块旗舰堆叠'),
(2081, '000000', 11, 611, 'EVE-STACK-BASE', 'Stack-BASE 堆叠储能底座+BMS',     '堆叠系统底座+主控BMS+并联通信单元（不含电池模块）', 'ACTIVE', 1200.00, 'CNY', 'STANDARD', 1, 7, '0', '0', NOW(), '系统基础设施'),
(2082, '000000', 11, 611, 'EVE-STACK-EX5K','Stack-EX5K 5.12kWh 扩展电池模块',   '不独立销售，与现有堆叠系统并联扩容，需同系统B5K模块', 'ACTIVE', 4000.00, 'CNY', 'STANDARD', 1, 7, '0', '0', NOW(), '扩展模块专用');

-- === LVI机架储能系列 (612) — 6个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(2083, '000000', 11, 612, 'EVE-RACK-5K',   'Rack-5K 5.12kWh 机架式储能模块',   '19英寸4U机架式，51.2V 100Ah，适用数据中心/通信基站', 'ACTIVE', 4800.00, 'CNY', 'STANDARD', 1, 10, '0', '0', NOW(), '机架式基础模块'),
(2084, '000000', 11, 612, 'EVE-RACK-10K',  'Rack-10K 10.24kWh 机架式储能系统',  '19英寸7U机架式，51.2V 200Ah，双模块容量', 'ACTIVE', 9000.00, 'CNY', 'STANDARD', 1, 12, '0', '0', NOW(), '高密度机架式'),
(2085, '000000', 11, 612, 'EVE-RACK-15K',  'Rack-15K 15.36kWh 机架式储能系统',  '19英寸10U机架式，51.2V 300Ah，三模块容量', 'ACTIVE', 12800.00, 'CNY', 'ATO', 1, 15, '0', '0', NOW(), '通信基站主力型号'),
(2086, '000000', 11, 612, 'EVE-RACK-48V',  'Rack-48V 48V机架式通信储能',         '48V 200Ah机架式，专为中国通信基站后备电源设计', 'ACTIVE', 7800.00, 'CNY', 'STANDARD', 1, 12, '0', '0', NOW(), '通信基站专用'),
(2087, '000000', 11, 612, 'EVE-RACK-HV',   'Rack-HV 高压机架式储能',          '384V 100Ah机架式高压储能，适用大型数据中心UPS', 'ACTIVE', 35000.00, 'CNY', 'ETO', 1, 30, '0', '0', NOW(), '数据中心高压UPS'),
(2088, '000000', 11, 612, 'EVE-RACK-CAB',  'Rack-CAB 标准机柜集成方案',        '含机柜+配电+消防+环控的全套机架式储能集成方案', 'ACTIVE', 18000.00, 'CNY', 'ETO', 1, 30, '0', '0', NOW(), '全套集成交付');

-- === HVI高压壁挂系列 (613) — 8个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(2089, '000000', 11, 613, 'EVE-HVI-20.0',  'EVE-HVI-20.0 20.48kWh 高压壁挂储能',  '204.8V 100Ah，堆叠内置，适用三相家庭/小型商业', 'ACTIVE', 21000.00, 'CNY', 'ATO', 1, 15, '0', '0', NOW(), '高压入门'),
(2090, '000000', 11, 613, 'EVE-HVI-30.0',  'EVE-HVI-30.0 30.72kWh 高压壁挂储能',  '307.2V 100Ah，大容量高压户储，全屋三相备电', 'ACTIVE', 30500.00, 'CNY', 'ATO', 1, 20, '0', '0', NOW(), '高性能户储'),
(2091, '000000', 11, 613, 'EVE-HVI-40.0',  'EVE-HVI-40.0 40.96kWh 高压壁挂储能',  '409.6V 100Ah，标志性高压产品，适用大户型/小型商业', 'ACTIVE', 39800.00, 'CNY', 'ATO', 1, 20, '0', '0', NOW(), 'HVI旗舰产品'),
(2092, '000000', 11, 613, 'EVE-HVI-60.0',  'EVE-HVI-60.0 61.44kWh 高压壁挂储能',  '614.4V 100Ah，极致容量高压储能，别墅/商业场景', 'ACTIVE', 58000.00, 'CNY', 'ATO', 1, 25, '0', '0', NOW(), '最大容量HVI'),
(2093, '000000', 11, 613, 'EVE-HVI-50.0',  'EVE-HVI-50.0 51.2kWh 高压壁挂储能',   '512V 100Ah，别墅级储能，支持并网/离网无缝切换', 'ACTIVE', 49000.00, 'CNY', 'ATO', 1, 25, '0', '0', NOW(), '别墅级储能'),
(2094, '000000', 11, 613, 'EVE-HVI-15.0',  'EVE-HVI-15.0 15.36kWh 高压壁挂储能',  '153.6V 100Ah，入门级高压，单相高端家庭', 'ACTIVE', 16500.00, 'CNY', 'STANDARD', 1, 15, '0', '0', NOW(), '高压入门款'),
(2095, '000000', 11, 613, 'EVE-HVI-25.0',  'EVE-HVI-25.0 25.6kWh 高压壁挂储能',   '256V 100Ah，中级高压，中小商业/大户型', 'ACTIVE', 26000.00, 'CNY', 'ATO', 1, 15, '0', '0', NOW(), '中型高压储能'),
(2096, '000000', 11, 613, 'EVE-HVI-10.0',  'EVE-HVI-10.0 10.24kWh 高压壁挂储能',  '102.4V 100Ah，最紧凑高压储能，公寓/联排', 'ACTIVE', 12000.00, 'CNY', 'STANDARD', 1, 15, '0', '0', NOW(), '最紧凑高压');

-- === HVI高压电池箱系列 (614) — 5个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(2097, '000000', 11, 614, 'EVE-HVBOX-50K',  'HVBox-50K 50kWh 高压电池箱',     '500V 100Ah高压电池箱，LF280K电芯，适用工商业储能基础单元', 'ACTIVE', 46000.00, 'CNY', 'ATO', 2, 30, '0', '0', NOW(), '工商业储能基础单元'),
(2098, '000000', 11, 614, 'EVE-HVBOX-100K', 'HVBox-100K 100kWh 高压电池箱',  '750V 135Ah高压电池箱，LF304电芯，大型工商业储能', 'ACTIVE', 88000.00, 'CNY', 'ATO', 2, 35, '0', '0', NOW(), '100kWh级工商业单元'),
(2099, '000000', 11, 614, 'EVE-HVBOX-200K', 'HVBox-200K 200kWh 高压电池箱',  '800V 250Ah高压电池箱，LF306电芯，最大单体电池箱', 'PRE_RELEASE', 168000.00, 'CNY', 'ETO', 1, 45, '0', '0', NOW(), '2026Q4发布'),
(2100, '000000', 11, 614, 'EVE-HVCLS-500K', 'HVCluster-500K 500kWh 高压电池簇', '5×HVBox-100K集成电池簇，含高压控制柜+BMS', 'ACTIVE', 420000.00, 'CNY', 'ETO', 1, 45, '0', '0', NOW(), '电池簇级产品'),
(2101, '000000', 11, 614, 'EVE-HVCLS-1000K','HVCluster-1000K 1MWh 高压电池簇', '10×HVBox-100K集成电池簇，含PCS+EMS+温控', 'ACTIVE', 800000.00, 'CNY', 'ETO', 1, 55, '0', '0', NOW(), 'MWh级电池簇');

-- === 便携应急电源系列 (615) — 10个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(2102, '000000', 11, 615, 'EVE-PS300',   'Portable 300 296Wh 便携应急电源',    '296Wh/300W输出，AC+DC+USB-C，5.5kg，户外露营入门', 'ACTIVE', 899.00, 'CNY', 'STANDARD', 1, 5, '0', '0', NOW(), '户外入门款'),
(2103, '000000', 11, 615, 'EVE-PS500',   'Portable 500 518Wh 便携应急电源',    '518Wh/500W输出(峰值1000W)，AC×2+USB-C×2+车充输出', 'ACTIVE', 1499.00, 'CNY', 'STANDARD', 1, 5, '0', '0', NOW(), '主流露营款'),
(2104, '000000', 11, 615, 'EVE-PS1000',  'Portable 1000 1024Wh 便携应急电源',   '1024Wh/1000W输出(峰值2000W)，LFP电芯，2500次循环', 'ACTIVE', 2699.00, 'CNY', 'STANDARD', 1, 7, '0', '0', NOW(), '家庭应急热销款'),
(2105, '000000', 11, 615, 'EVE-PS1500',  'Portable 1500 1536Wh 便携应急电源',   '1536Wh/1500W输出，UPS功能<10ms切换，家庭关键设备备电', 'ACTIVE', 3899.00, 'CNY', 'ATO', 1, 7, '0', '0', NOW(), '家庭备电主力'),
(2106, '000000', 11, 615, 'EVE-PS2000',  'Portable 2000 2048Wh 便携应急电源',   '2048Wh/2000W输出(峰值4000W)，30A RV插座，房车/露营车', 'ACTIVE', 5299.00, 'CNY', 'ATO', 1, 10, '0', '0', NOW(), '房车/露营车专用'),
(2107, '000000', 11, 615, 'EVE-PS3000',  'Portable 3000 3072Wh 便携应急电源',   '3072Wh/3000W输出，可扩展电池包至6144Wh，移动施工', 'ACTIVE', 7499.00, 'CNY', 'ATO', 1, 10, '0', '0', NOW(), '施工/户外作业'),
(2108, '000000', 11, 615, 'EVE-PS500-S', 'Portable 500S 512Wh 太阳能便携电源', '512Wh/500W+100W太阳能充电，折叠太阳能板套装', 'ACTIVE', 1999.00, 'CNY', 'STANDARD', 1, 7, '0', '0', NOW(), '太阳能露营套装'),
(2109, '000000', 11, 615, 'EVE-PS-BP1K', 'PS-BP1K 1024Wh 扩展电池包',         '与PS1000/PS1500搭配使用，即插即用扩容', 'ACTIVE', 1999.00, 'CNY', 'STANDARD', 1, 5, '0', '0', NOW(), '扩容配件'),
(2110, '000000', 11, 615, 'EVE-PS-BP2K', 'PS-BP2K 2048Wh 扩展电池包',         '与PS2000/PS3000搭配使用，大容量扩容', 'ACTIVE', 3899.00, 'CNY', 'STANDARD', 1, 7, '0', '0', NOW(), '大容量扩容'),
(2111, '000000', 11, 615, 'EVE-PS-800',  'Portable 800 800Wh 便携应急电源',    '800Wh/800W输出，黄金容量，兼顾便携与续航', 'ACTIVE', 2199.00, 'CNY', 'STANDARD', 1, 7, '0', '0', NOW(), '黄金容量款');

-- === 便携专业电源系列 (616) — 4个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(2112, '000000', 11, 616, 'EVE-PRO-5K',  'ProPower 5K 5120Wh 专业移动储能',    '5120Wh/5000W输出，三相380V输出，施工现场/影视拍摄', 'ACTIVE', 12900.00, 'CNY', 'ATO', 1, 15, '0', '0', NOW(), '专业施工现场'),
(2113, '000000', 11, 616, 'EVE-PRO-10K', 'ProPower 10K 10240Wh 专业移动储能',  '10240Wh/10000W输出，400V三相，支持并机至30kWh', 'ACTIVE', 23900.00, 'CNY', 'ATO', 1, 20, '0', '0', NOW(), '大型施工/活动'),
(2114, '000000', 11, 616, 'EVE-PRO-3K',  'ProPower 3K 3072Wh 工程巡检电源',    '3072Wh/3000W，IP67防护，10m跌落防护，电力巡检专用', 'ACTIVE', 8800.00, 'CNY', 'ATO', 1, 12, '0', '0', NOW(), '电力巡检专用'),
(2115, '000000', 11, 616, 'EVE-PRO-SOLAR', 'ProPower Solar 5120Wh 光储移动电站', '5120Wh+2kWp光伏输入+5kW逆变，离网移动光储电站', 'ACTIVE', 18500.00, 'CNY', 'ETO', 1, 20, '0', '0', NOW(), '离网光储一体');

-- === ER微型电池系列 (617) — 8个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(2116, '000000', 11, 617, 'EVE-ER14250',  'ER14250 3.6V 1/2AA 锂亚硫酰氯电池', '1200mAh，1/2AA尺寸，-55°C~+85°C宽温域，适用RFID/传感器', 'ACTIVE', 3.50, 'CNY', 'STANDARD', 500, 5, '0', '0', NOW(), '微型IoT传感器标配'),
(2117, '000000', 11, 617, 'EVE-ER14250-H','ER14250-H 3.6V 1/2AA 高温型锂亚电池', '1100mAh，+125°C耐温，适用于井下/发动机舱高温环境', 'ACTIVE', 5.50, 'CNY', 'STANDARD', 200, 7, '0', '0', NOW(), '高温特种应用'),
(2118, '000000', 11, 617, 'EVE-ER14250-P','ER14250-P 3.6V 1/2AA 脉冲增强型', '1200mAh+SPC脉冲电容，支持500mA脉冲电流，NB-IoT终端', 'ACTIVE', 6.50, 'CNY', 'STANDARD', 200, 7, '0', '0', NOW(), 'NB-IoT无线终端'),
(2119, '000000', 11, 617, 'EVE-ER14335',  'ER14335 3.6V 2/3AA 锂亚硫酰氯电池', '1650mAh，2/3AA尺寸，适用水表/热量表/医疗设备', 'ACTIVE', 4.00, 'CNY', 'STANDARD', 400, 5, '0', '0', NOW(), '智能表计主力型号'),
(2120, '000000', 11, 617, 'EVE-ER14335-P','ER14335-P 3.6V 2/3AA 脉冲增强型', '1650mAh+SPC，支持800mA脉冲，LoRaWAN节点', 'ACTIVE', 7.00, 'CNY', 'STANDARD', 200, 7, '0', '0', NOW(), 'LoRa无线远传'),
(2121, '000000', 11, 617, 'EVE-ER14250-EX','ER14250-EX 3.6V 1/2AA 本安防爆型', '1200mAh，Ex ia IIC T4防爆认证，煤矿/化工安全仪表', 'ACTIVE', 8.00, 'CNY', 'STANDARD', 200, 10, '0', '0', NOW(), '防爆安全仪表'),
(2122, '000000', 11, 617, 'EVE-ER10450',  'ER10450 3.6V AAA 锂亚硫酰氯电池',    '800mAh，AAA尺寸，最小锂亚电池，穿戴设备/电子标签', 'ACTIVE', 3.00, 'CNY', 'STANDARD', 500, 5, '0', '0', NOW(), '微型IoT设备'),
(2123, '000000', 11, 617, 'EVE-ER10280',  'ER10280 3.6V 2/3AAA 锂亚硫酰氯电池', '600mAh，2/3AAA超小尺寸，卡片终端/eSIM标签', 'ACTIVE', 2.80, 'CNY', 'STANDARD', 500, 5, '0', '0', NOW(), '卡片终端专用');

-- === ER标准型电池系列 (618) — 8个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(2124, '000000', 11, 618, 'EVE-ER14505',  'ER14505 3.6V AA 锂亚硫酰氯电池',     '2700mAh，AA尺寸，通用型，适用智能电表/安防/工业控制', 'ACTIVE', 4.50, 'CNY', 'STANDARD', 300, 5, '0', '0', NOW(), '销量最大IoT电池'),
(2125, '000000', 11, 618, 'EVE-ER14505-P','ER14505-P 3.6V AA 脉冲增强型',     '2700mAh+SPC，支持1A脉冲，GPRS/NB-IoT智能电表', 'ACTIVE', 7.50, 'CNY', 'STANDARD', 200, 7, '0', '0', NOW(), '智能电表通信专用'),
(2126, '000000', 11, 618, 'EVE-ER14505-H','ER14505-H 3.6V AA 高温型',         '2400mAh，+150°C耐温，适用油井/地热/高温工业', 'ACTIVE', 7.00, 'CNY', 'STANDARD', 100, 10, '0', '0', NOW(), '油田井下专用'),
(2127, '000000', 11, 618, 'EVE-ER17335',  'ER17335 3.6V 2/3A 锂亚硫酰氯电池',   '2100mAh，2/3A尺寸，适用燃气表/热量表/数据记录仪', 'ACTIVE', 5.00, 'CNY', 'STANDARD', 300, 5, '0', '0', NOW(), '燃气表主流型号'),
(2128, '000000', 11, 618, 'EVE-ER17335-P','ER17335-P 3.6V 2/3A 脉冲增强型',   '2100mAh+SPC，燃气表无线远传NB-IoT', 'ACTIVE', 8.00, 'CNY', 'STANDARD', 200, 7, '0', '0', NOW(), '无线远传燃气表'),
(2129, '000000', 11, 618, 'EVE-ER18505',  'ER18505 3.6V A 锂亚硫酰氯电池',      '4000mAh，A尺寸大容量，适用安防主机/环境监测站', 'ACTIVE', 6.00, 'CNY', 'STANDARD', 200, 7, '0', '0', NOW(), '安防/监测大容量'),
(2130, '000000', 11, 618, 'EVE-ER18505-P','ER18505-P 3.6V A 脉冲增强型',      '4000mAh+SPC，支持2A脉冲，4G DTU/边缘计算终端', 'ACTIVE', 9.50, 'CNY', 'STANDARD', 100, 10, '0', '0', NOW(), '4G终端大脉冲'),
(2131, '000000', 11, 618, 'EVE-ER14505-EX','ER14505-EX 3.6V AA 本安防爆型',    '2700mAh，Ex ia认证，煤矿安全监控/可燃气体检测', 'ACTIVE', 9.00, 'CNY', 'STANDARD', 200, 10, '0', '0', NOW(), '煤矿安全监控');

-- === ER大容量电池系列 (619) — 6个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(2132, '000000', 11, 619, 'EVE-ER26500',  'ER26500 3.6V C 锂亚硫酰氯电池',      '8500mAh，C尺寸大容量，适用GPS追踪器/浮标/远传终端', 'ACTIVE', 8.50, 'CNY', 'STANDARD', 100, 7, '0', '0', NOW(), '追踪器/海洋浮标'),
(2133, '000000', 11, 619, 'EVE-ER26500-P','ER26500-P 3.6V C 脉冲增强型',      '8500mAh+SPC，车载GPS/冷链追踪卫星通信', 'ACTIVE', 12.00, 'CNY', 'STANDARD', 100, 7, '0', '0', NOW(), '卫星通信追踪'),
(2134, '000000', 11, 619, 'EVE-ER34615',  'ER34615 3.6V D 锂亚硫酰氯电池',      '19000mAh，D尺寸超大容量，适用海洋浮标/远程气象站', 'ACTIVE', 15.00, 'CNY', 'STANDARD', 50, 10, '0', '0', NOW(), '海洋/气象观测'),
(2135, '000000', 11, 619, 'EVE-ER34615-P','ER34615-P 3.6V D 脉冲增强型',      '19000mAh+大SPC，适用边境监控/卫星通信终端', 'ACTIVE', 22.00, 'CNY', 'STANDARD', 50, 10, '0', '0', NOW(), '边境监控/卫星终端'),
(2136, '000000', 11, 619, 'EVE-ER34615-H','ER34615-H 3.6V D 高温型',         '17000mAh，+150°C耐温，油田深井/地热监测', 'ACTIVE', 25.00, 'CNY', 'STANDARD', 50, 15, '0', '0', NOW(), '超高温井下'),
(2137, '000000', 11, 619, 'EVE-ER34615M', 'ER34615M 3.6V D 中倍率型',          '19000mAh，支持50mA持续输出，适用无线中继/数据采集器', 'ACTIVE', 16.00, 'CNY', 'STANDARD', 50, 10, '0', '0', NOW(), '无线中继站');

-- === ER+SPC复合电容系列 (620) — 5个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(2138, '000000', 11, 620, 'EVE-CSP-AA',   'EVE-CSP-AA ER14505+SPC1520 复合电池组','ER14505(2700mAh)+SPC1520(15F)集成封装，GPRS电表标准方案', 'ACTIVE', 12.00, 'CNY', 'STANDARD', 100, 10, '0', '0', NOW(), 'GPRS智能电表标配'),
(2139, '000000', 11, 620, 'EVE-CSP-2AA',  'EVE-CSP-2AA ER14505×2+SPC 双电池组', '双ER14505(5400mAh)+SPC，长续航NB-IoT/4G电表', 'ACTIVE', 22.00, 'CNY', 'STANDARD', 100, 10, '0', '0', NOW(), '4G智能电表长续航'),
(2140, '000000', 11, 620, 'EVE-CSP-C',    'EVE-CSP-C ER26500+SPC 复合电池组',  'ER26500(8500mAh)+SPC，冷链追踪/车载定位标准方案', 'ACTIVE', 16.00, 'CNY', 'STANDARD', 50, 10, '0', '0', NOW(), '冷链追踪标配'),
(2141, '000000', 11, 620, 'EVE-CSP-D',    'EVE-CSP-D ER34615+SPC 复合电池组',  'ER34615(19000mAh)+大SPC，海洋浮标/卫星遥测', 'ACTIVE', 28.00, 'CNY', 'STANDARD', 20, 15, '0', '0', NOW(), '海洋卫星遥测'),
(2142, '000000', 11, 620, 'EVE-CSP-METER', 'EVE-CSP-METER 智能表计复合电源包',  'ER14505+SPC+BMS+密封壳体，一体化智能表计电源方案', 'ACTIVE', 18.00, 'CNY', 'ATO', 500, 15, '0', '0', NOW(), '表计厂商一体化方案');

-- === CR圆柱电池系列 (621) — 7个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(2143, '000000', 11, 621, 'EVE-CR123A',  'CR123A 3.0V 锂锰圆柱电池',           '1550mAh，3.0V，适用安防摄像头/烟感/智能门锁', 'ACTIVE', 4.50, 'CNY', 'STANDARD', 200, 5, '0', '0', NOW(), '安防/门锁标配'),
(2144, '000000', 11, 621, 'EVE-CR123A-HP','CR123A-HP 3.0V 高功率锂锰电池',      '1400mAh，支持3A脉冲，LED闪光灯/安防报警主机', 'ACTIVE', 5.50, 'CNY', 'STANDARD', 200, 5, '0', '0', NOW(), '闪光灯/报警器'),
(2145, '000000', 11, 621, 'EVE-CR2',      'CR2 3.0V 锂锰圆柱电池',             '850mAh，超紧凑尺寸，适用微型相机/测距仪/激光笔', 'ACTIVE', 4.00, 'CNY', 'STANDARD', 300, 5, '0', '0', NOW(), '相机/测距仪'),
(2146, '000000', 11, 621, 'EVE-CR14505',  'CR14505 3.0V AA 锂锰电池',          '2000mAh，AA标准尺寸锂锰，适用工业仪表/传感器', 'ACTIVE', 4.00, 'CNY', 'STANDARD', 200, 5, '0', '0', NOW(), '工业传感器'),
(2147, '000000', 11, 621, 'EVE-CR17450',  'CR17450 3.0V A 锂锰电池',           '3000mAh，高容量工业级，适用医疗设备/工业控制', 'ACTIVE', 6.00, 'CNY', 'STANDARD', 100, 7, '0', '0', NOW(), '医疗/工控'),
(2148, '000000', 11, 621, 'EVE-CR17505',  'CR17505 3.0V 加长型锂锰电池',       '3500mAh，A+尺寸，适用大型仪表/数据记录仪', 'ACTIVE', 7.00, 'CNY', 'STANDARD', 100, 7, '0', '0', NOW(), '数据记录仪'),
(2149, '000000', 11, 621, 'EVE-CR123A-UL', 'CR123A-UL 3.0V UL认证出口型',      '1550mAh，UL认证，北美安防市场专用', 'ACTIVE', 5.50, 'CNY', 'STANDARD', 200, 7, '0', '0', NOW(), '北美安防出口');

-- === CR扣式电池系列 (622) — 8个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(2150, '000000', 11, 622, 'EVE-CR2032',  'CR2032 3.0V 锂锰扣式电池',          '240mAh，20mm×3.2mm，最大销量扣式电池，主板/遥控器', 'ACTIVE', 0.80, 'CNY', 'STANDARD', 1000, 3, '0', '0', NOW(), '全球销量最大扣式电池'),
(2151, '000000', 11, 622, 'EVE-CR2025',  'CR2025 3.0V 锂锰扣式电池',          '170mAh，20mm×2.5mm，超薄扣式，遥控器/电子标签', 'ACTIVE', 0.70, 'CNY', 'STANDARD', 1000, 3, '0', '0', NOW(), '超薄遥控器专用'),
(2152, '000000', 11, 622, 'EVE-CR2016',  'CR2016 3.0V 锂锰扣式电池',          '90mAh，20mm×1.6mm，极薄扣式，超薄卡片/钥匙', 'ACTIVE', 0.60, 'CNY', 'STANDARD', 1000, 3, '0', '0', NOW(), '超薄卡片/智能钥匙'),
(2153, '000000', 11, 622, 'EVE-CR2450',  'CR2450 3.0V 锂锰大扣式电池',        '620mAh，24mm×5.0mm，大容量扣式，医疗设备/传感器', 'ACTIVE', 1.50, 'CNY', 'STANDARD', 500, 5, '0', '0', NOW(), '医疗/工业传感器'),
(2154, '000000', 11, 622, 'EVE-CR2430',  'CR2430 3.0V 锂锰扣式电池',          '300mAh，24mm×3.0mm，中容量扣式，TPMS/GPS模块', 'ACTIVE', 1.20, 'CNY', 'STANDARD', 500, 5, '0', '0', NOW(), '胎压监测/GPS'),
(2155, '000000', 11, 622, 'EVE-CR2477',  'CR2477 3.0V 锂锰超大扣式电池',      '1000mAh，24mm×7.7mm，最大扣式容量，工业物联网', 'ACTIVE', 2.50, 'CNY', 'STANDARD', 200, 7, '0', '0', NOW(), '最大容量扣式电池'),
(2156, '000000', 11, 622, 'EVE-CR1632',  'CR1632 3.0V 锂锰小扣式电池',        '140mAh，16mm×3.2mm，紧凑扣式，汽车钥匙/手表', 'ACTIVE', 0.65, 'CNY', 'STANDARD', 1000, 3, '0', '0', NOW(), '汽车钥匙/智能手表'),
(2157, '000000', 11, 622, 'EVE-CR1220',  'CR1220 3.0V 锂锰微型扣式电池',      '40mAh，12mm×2.0mm，超微型扣式，蓝牙标签/耳温枪', 'ACTIVE', 0.45, 'CNY', 'STANDARD', 1000, 3, '0', '0', NOW(), '蓝牙低功耗标签');

-- === CR-HP高功率电池系列 (623) — 5个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(2158, '000000', 11, 623, 'EVE-CR18505-HP','CR18505-HP 3.0V 高功率工业电池',    '3800mAh+5A脉冲，适用电动工具控制器/气动隔膜阀', 'ACTIVE', 9.00, 'CNY', 'STANDARD', 100, 7, '0', '0', NOW(), '工业控制/气动阀'),
(2159, '000000', 11, 623, 'EVE-CR26500-HP','CR26500-HP 3.0V 超大功率电池',      '6000mAh+10A脉冲，适用机场照明/应急广播', 'ACTIVE', 14.00, 'CNY', 'STANDARD', 50, 10, '0', '0', NOW(), '应急照明/广播'),
(2160, '000000', 11, 623, 'EVE-CR34615-HP','CR34615-HP 3.0V 超大容量高功率',    '12000mAh+15A脉冲，军用通信/航空应急', 'ACTIVE', 28.00, 'CNY', 'STANDARD', 20, 15, '0', '0', NOW(), '军工/航空专用'),
(2161, '000000', 11, 623, 'EVE-CR2-HP',    'CR2-HP 3.0V 高功率型',              '780mAh+2A脉冲，高端相机闪光灯/高速连拍', 'ACTIVE', 5.00, 'CNY', 'STANDARD', 200, 5, '0', '0', NOW(), '相机闪光灯'),
(2162, '000000', 11, 623, 'EVE-CR123A-HV', 'CR123A-HV 3.3V 高压锂锰电池',      '1500mAh，3.3V高压平台，新一代高能锂锰', 'PRE_RELEASE', 6.00, 'CNY', 'STANDARD', 200, 10, '0', '0', NOW(), '2026Q4发布');

-- === 智能表计电源方案 (624) — 6个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(2163, '000000', 11, 624, 'EVE-METER-SMART','SmartMeter-PK 智能电表电源方案包',  'ER14505+SPC+BMS+密封壳体+连接器，支持GPRS/4G通信电表', 'ACTIVE', 25.00, 'CNY', 'ATO', 500, 15, '0', '0', NOW(), '电表厂商一站式采购'),
(2164, '000000', 11, 624, 'EVE-METER-WATER','WaterMeter-PK 智能水表电源方案包','ER14335+SPC+密封+防水连接器，支持LoRa/NB-IoT远传水表', 'ACTIVE', 20.00, 'CNY', 'ATO', 500, 12, '0', '0', NOW(), '远传水表方案'),
(2165, '000000', 11, 624, 'EVE-METER-GAS', 'GasMeter-PK 智能燃气表电源方案包','ER17335+SPC+本安密封+防爆壳，支持无线远传燃气表', 'ACTIVE', 28.00, 'CNY', 'ATO', 500, 15, '0', '0', NOW(), '燃气表本安方案'),
(2166, '000000', 11, 624, 'EVE-METER-HEAT','HeatMeter-PK 热量表电源方案包',    'ER14335+SPC+IP68防水密封，供暖热量表超长寿命', 'ACTIVE', 22.00, 'CNY', 'STANDARD', 300, 12, '0', '0', NOW(), '供暖热量表'),
(2167, '000000', 11, 624, 'EVE-METER-IOT', 'IoTMeter-PK 多表合一LoRaWAN方案',   'ER18505+SPC+LoRa模块集成+太阳能辅助，多表集抄', 'ACTIVE', 35.00, 'CNY', 'ATO', 200, 20, '0', '0', NOW(), '多表合一集抄'),
(2168, '000000', 11, 624, 'EVE-METER-EX',  'ExMeter-PK 防爆表计电源方案包',    'ER14505-EX+SPC+Ex ia认证壳体，煤矿/危化品环境表计', 'ACTIVE', 38.00, 'CNY', 'ATO', 200, 20, '0', '0', NOW(), '危化品/煤矿表计');

-- === 智能安防电源方案 (625) — 5个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(2169, '000000', 11, 625, 'EVE-SEC-LOCK',  'SmartLock-PK 智能门锁电源方案',      '4×CR123A+锂亚备份+低功耗BMS，指纹/人脸门锁18个月续航', 'ACTIVE', 18.00, 'CNY', 'ATO', 200, 10, '0', '0', NOW(), '智能门锁标配'),
(2170, '000000', 11, 625, 'EVE-SEC-CAM',  'SmartCam-PK 安防摄像头电源方案',     '4×CR123A-HP+大容量ER26500备份，户外无线摄像头', 'ACTIVE', 28.00, 'CNY', 'ATO', 100, 12, '0', '0', NOW(), '户外无线监控'),
(2171, '000000', 11, 625, 'EVE-SEC-ALARM','Alarm-PK 无线报警器电源方案',        '2×ER18505+SPC+太阳能充电管理，户外报警柱/周界', 'ACTIVE', 32.00, 'CNY', 'ATO', 100, 15, '0', '0', NOW(), '户外无线报警'),
(2172, '000000', 11, 625, 'EVE-SEC-SMOKE','SmokeDetector-PK 烟感电源方案',      'CR123A×1+10年设计寿命，独立式/联网式烟感探测器', 'ACTIVE', 12.00, 'CNY', 'STANDARD', 500, 7, '0', '0', NOW(), '10年寿命烟感'),
(2173, '000000', 11, 625, 'EVE-SEC-GATE', 'GateWay-PK 智能网关电源方案',       'ER34615+SPC+太阳能+超级电容，LoRa/4G网关长续航', 'ACTIVE', 45.00, 'CNY', 'ATO', 50, 15, '0', '0', NOW(), 'IoT网关长续航');

-- === GPS追踪定位电源方案 (626) — 4个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(2174, '000000', 11, 626, 'EVE-TRK-COLD',  'ColdChain-PK 冷链追踪电源方案',     'ER26500+SPC+低温BMS(-40°C)，支持4G+GPS冷链追踪标签', 'ACTIVE', 32.00, 'CNY', 'ATO', 100, 12, '0', '0', NOW(), '冷链物流追踪'),
(2175, '000000', 11, 626, 'EVE-TRK-ASSET', 'AssetTrack-PK 资产追踪电源方案',   'ER34615+SPC+太阳能辅助，2年续航，集装箱/重资产追踪', 'ACTIVE', 48.00, 'CNY', 'ATO', 50, 15, '0', '0', NOW(), '集装箱/资产追踪'),
(2176, '000000', 11, 626, 'EVE-TRK-VEH',  'VehicleTrack-PK 车载定位电源方案',  'ER34615+OBD取电备份+超级电容，车载OBD追踪器', 'ACTIVE', 38.00, 'CNY', 'ATO', 100, 12, '0', '0', NOW(), '车载OBD追踪'),
(2177, '000000', 11, 626, 'EVE-TRK-PET',  'PetTrack-PK 宠物/人员追踪电源方案', 'CR2450+低功耗BLE，30天续航，宠物项圈/儿童手表追踪', 'ACTIVE', 12.00, 'CNY', 'STANDARD', 500, 7, '0', '0', NOW(), '宠物/儿童定位');

-- === 户外储能柜系列 (627) — 6个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(2178, '000000', 11, 627, 'EVE-CI-200K',   'CI-Cab200 200kWh 户外储能柜',      '200kWh(5×HVBox-50K)，IP55户外直装，含PCS+EMS+消防+空调', 'ACTIVE', 280000.00, 'CNY', 'ETO', 1, 45, '0', '0', NOW(), '中小工商业储能'),
(2179, '000000', 11, 627, 'EVE-CI-500K',   'CI-Cab500 500kWh 户外储能柜',      '500kWh(HVCluster-500K一体柜)，含250kW PCS+EMS+温控消防', 'ACTIVE', 650000.00, 'CNY', 'ETO', 1, 55, '0', '0', NOW(), '工商业储能主力'),
(2180, '000000', 11, 627, 'EVE-CI-750K',   'CI-Cab750 750kWh 户外储能柜',      '750kWh，350kW PCS，工业园区/商业综合体备电+峰谷套利', 'ACTIVE', 950000.00, 'CNY', 'ETO', 1, 60, '0', '0', NOW(), '园区级工商业储能'),
(2181, '000000', 11, 627, 'EVE-CI-1M',     'CI-Cab1000 1MWh 户外储能柜',       '1MWh，500kW PCS，适用于中型工厂/商业园区/充电站', 'ACTIVE', 1250000.00, 'CNY', 'ETO', 1, 65, '0', '0', NOW(), '1MWh级工商业'),
(2182, '000000', 11, 627, 'EVE-CI-200K-AIO','CI-Cab200-AIO 光储充一体柜',     '200kWh储能+100kW光伏逆变+120kW充电桩，园区光储充', 'ACTIVE', 380000.00, 'CNY', 'ETO', 1, 50, '0', '0', NOW(), '光储充一体化'),
(2183, '000000', 11, 627, 'EVE-CI-HV',     'CI-Cab-HV 高压直挂储能柜',        '800V直流母线，200kWh，支持直流微电网，数据中心/DVR', 'PRE_RELEASE', 320000.00, 'CNY', 'ETO', 1, 60, '0', '0', NOW(), '2026Q4高压直挂方案');

-- === 集装箱储能系列 (628) — 5个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(2184, '000000', 11, 628, 'EVE-CONT-2.5M', 'Container-2.5M 2.5MWh 20尺储能集装箱', '20尺标准集装箱，2.5MWh(LF280K电芯)，含PCS/EMS/消防/空调', 'ACTIVE', 2800000.00, 'CNY', 'ETO', 1, 75, '0', '0', NOW(), '大型储能电站基础单元'),
(2185, '000000', 11, 628, 'EVE-CONT-5M',  'Container-5M 5MWh 40尺储能集装箱',    '40尺高柜，5MWh(LF306电芯)，2500kW PCS，大型储能电站', 'ACTIVE', 5300000.00, 'CNY', 'ETO', 1, 90, '0', '0', NOW(), '5MWh级大型储能'),
(2186, '000000', 11, 628, 'EVE-CONT-3.5M', 'Container-3.5M 3.5MWh 高密度储能箱', '20尺高柜，3.5MWh(MB31电芯)，高密度设计，节省土地', 'ACTIVE', 3900000.00, 'CNY', 'ETO', 1, 80, '0', '0', NOW(), '高密度储能方案'),
(2187, '000000', 11, 628, 'EVE-CONT-1M',  'Container-1M 1MWh 10尺储能箱',        '10尺小型储能箱，1MWh，适用海岛/矿区/偏远地区微电网', 'ACTIVE', 1280000.00, 'CNY', 'ETO', 1, 60, '0', '0', NOW(), '微电网/偏远地区'),
(2188, '000000', 11, 628, 'EVE-CONT-8M',  'Container-8M 8MWh 45尺超大储能箱',   '45尺定制箱体，8MWh(MB56/Mr.Big电芯)，下一代超大容量', 'PRE_RELEASE', 8600000.00, 'CNY', 'ETO', 1, 100, '0', '0', NOW(), '下一代超大型储能');

-- === 工商业一体机系列 (629) — 6个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(2189, '000000', 11, 629, 'EVE-AIO-50K',   'AllinOne-50K 50kW/100kWh 工商业一体机','50kW PCS+100kWh储能，含并离网切换，适用小型工厂/农场', 'ACTIVE', 185000.00, 'CNY', 'ETO', 1, 45, '0', '0', NOW(), '小型工商业一体'),
(2190, '000000', 11, 629, 'EVE-AIO-100K',  'AllinOne-100K 100kW/200kWh 工商业一体机','100kW PCS+200kWh储能，中型工厂/商场削峰填谷', 'ACTIVE', 340000.00, 'CNY', 'ETO', 1, 50, '0', '0', NOW(), '中型工商业主流'),
(2191, '000000', 11, 629, 'EVE-AIO-250K',  'AllinOne-250K 250kW/500kWh 工商业一体机','250kW PCS+500kWh，大型工厂/工业园区综合能源', 'ACTIVE', 800000.00, 'CNY', 'ETO', 1, 60, '0', '0', NOW(), '大型工商业储能'),
(2192, '000000', 11, 629, 'EVE-AIO-SOLAR', 'AllinOne-Solar 光储充一体化站',       '100kW光伏+200kWh储能+120kW充电+EMS云平台', 'ACTIVE', 480000.00, 'CNY', 'ETO', 1, 55, '0', '0', NOW(), '光储充一体化'),
(2193, '000000', 11, 629, 'EVE-AIO-HVPS',  'AllinOne-HVPS 高压电源保障系统',      '500kW/1MWh UPS级电源保障，数据中心/半导体工厂/医院', 'ACTIVE', 1800000.00, 'CNY', 'ETO', 1, 70, '0', '0', NOW(), '关键负荷电源保障'),
(2194, '000000', 11, 629, 'EVE-AIO-VPP',   'AllinOne-VPP 虚拟电厂聚合终端',     '含VPP控制器+通信网关+可调PCS，接入电网调度/电力交易', 'PRE_RELEASE', 250000.00, 'CNY', 'ETO', 1, 60, '0', '0', NOW(), '虚拟电厂接入');

-- === 光储逆变器系列 (630) — 6个产品 ===
INSERT INTO cpq_product_model (model_id, tenant_id, catalog_id, category_id, model_code, model_name, description, lifecycle_status, base_price, currency, config_type, min_order_qty, lead_time_days, status, del_flag, create_time, remark) VALUES
(2195, '000000', 11, 630, 'EVE-PCS-50K',  'PCS-50K 50kW 储能逆变器',           '50kW三相储能逆变器，支持并网/离网切换，适配工商业储能', 'ACTIVE', 28000.00, 'CNY', 'STANDARD', 1, 15, '0', '0', NOW(), '工商业储能标配PCS'),
(2196, '000000', 11, 630, 'EVE-PCS-100K', 'PCS-100K 100kW 储能逆变器',         '100kW三相储能PCS，支持多机并联至500kW', 'ACTIVE', 52000.00, 'CNY', 'ATO', 1, 20, '0', '0', NOW(), '中型储能PCS'),
(2197, '000000', 11, 630, 'EVE-PCS-250K', 'PCS-250K 250kW 储能逆变器',         '250kW三相储能PCS，支持并机至2.5MW，大型储能', 'ACTIVE', 120000.00, 'CNY', 'ATO', 1, 25, '0', '0', NOW(), '大型储能PCS'),
(2198, '000000', 11, 630, 'EVE-PCS-500K', 'PCS-500K 500kW 大功率储能逆变器',   '500kW三相PCS，支持并机至5MW，直流侧1500V', 'ACTIVE', 230000.00, 'CNY', 'ETO', 1, 30, '0', '0', NOW(), '大型电站PCS'),
(2199, '000000', 11, 630, 'EVE-HYBRID-8K','Hybrid-8K 8kW 户用混合逆变器',     '8kW单相混合逆变器，光伏+储能+电网三端口，适配LVI系列', 'ACTIVE', 7800.00, 'CNY', 'STANDARD', 1, 10, '0', '0', NOW(), '户用混合逆变器'),
(2200, '000000', 11, 630, 'EVE-HYBRID-15K','Hybrid-15K 15kW 户用混合逆变器',    '15kW三相混合逆变器，适配HVI系列高压储能', 'ACTIVE', 13800.00, 'CNY', 'ATO', 1, 12, '0', '0', NOW(), '高压户用逆变器');


-- =====================================================
-- 四、产品替代关系 (cpq_product_supersession)
-- =====================================================

INSERT INTO cpq_product_supersession (supersession_id, tenant_id, original_model_id, replacement_model_id, supersession_type, condition_expr, price_impact_pct, effective_date, status, del_flag, create_time, remark) VALUES
(4001, '000000', 2046, 2042, 'FULL',         NULL,  30.77, '2026-12-31', '0', '0', NOW(), '钴酸锂18650(ICR)逐步退出，NCM18650替代'),
(4002, '000000', 2009, 2010, 'CONDITIONAL',  '{"application":"high_power_storage"}', 16.67, '2026-09-01', '0', '0', NOW(), '功率型储能场景下LF120L需升级为HP版本'),
(4003, '000000', 2019, 2020, 'FULL',         NULL,   7.32, '2027-01-01', '0', '0', NOW(), 'LF280K-V2全面替代LF280K，循环寿命提升25%'),
(4004, '000000', 2011, 2017, 'FULL',         NULL,  20.69, '2027-06-01', '0', '0', NOW(), 'LF240替代LF202，能量密度+15%'),
(4005, '000000', 2063, 2064, 'CONDITIONAL',  '{"environment":"outdoor_extreme"}', 15.56, '2026-09-01', '0', '0', NOW(), '户外极端环境(IP67+加热)场景LVI-5.0升级为P版');


-- =====================================================
-- 五、统计数据
-- =====================================================
-- 产品族(L1):   3条
-- 产品线(L2):   10条
-- 产品系列(L3): 30条
-- 产品:         200条 (model_id 2001-2200)
-- 目录:         3条
-- 替代关系:     5条
-- 生命周期分布:  ACTIVE=186, PRE_RELEASE=12, EOL_ANNOUNCED=2
-- 配置类型分布:  STANDARD=108, ATO=58, ETO=34
-- tenant_id 统一: '000000'
-- =====================================================
