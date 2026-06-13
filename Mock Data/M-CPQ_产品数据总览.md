# M-CPQ 产品数据总览

> **企业**: 智元机器人（RoboWise Robotics）  
> **数据量**: 3产品族 / 10产品线 / 30产品系列 / 100产品  
> **SQL文件**: `M-CPQ_产品数据_init.sql`  
> **日期**: 2026-06-07

---

## 一、产品分类层级树

```
RoboWise Robotics 产品体系
│
├── 📦 工业机器人 (INDUSTRIAL)              ← L1 产品族
│   ├── 🔧 焊接机器人 (WELDING)             ← L2 产品线
│   │   ├── ARC弧焊系列 (ARC_SERIES)        ← L3 产品系列 (4款)
│   │   ├── SPOT点焊系列 (SPOT_SERIES)                 (3款)
│   │   └── LASER激光焊接系列 (LASER_SERIES)           (3款)
│   ├── 📦 搬运与码垛机器人 (MATERIAL_HANDLING)
│   │   ├── PAL码垛系列 (PAL_SERIES)                   (3款)
│   │   ├── AGV自动导引系列 (AGV_SERIES)               (4款)
│   │   └── HEAVY重载系列 (HEAVY_SERIES)               (3款)
│   ├── 🤝 协作机器人 (COBOT)
│   │   ├── COBOT通用协作系列 (COBOT_SERIES)           (4款)
│   │   ├── PREC精密装配系列 (PREC_SERIES)             (3款)
│   │   └── SAFE力控协作系列 (SAFE_SERIES)             (3款)
│   └── 🎨 喷涂与涂装机器人 (PAINTING)
│       ├── PAINT精密喷涂系列 (PAINT_SERIES)            (3款)
│       ├── COAT自动涂装系列 (COAT_SERIES)              (3款)
│       └── SEAL涂胶密封系列 (SEAL_SERIES)              (3款)
│
├── 🏠 家用机器人 (HOME)                    ← L1 产品族
│   ├── 🧹 清洁机器人 (CLEANING)            ← L2 产品线
│   │   ├── SWEEP扫拖一体系列 (SWEEP_SERIES)           (4款)
│   │   ├── NAVI视觉导航系列 (NAVI_SERIES)             (3款)
│   │   └── DEEP商用清洁系列 (DEEP_SERIES)              (3款)
│   ├── 📚 教育与编程机器人 (EDUCATION)
│   │   ├── STEM科教启蒙系列 (STEM_SERIES)              (4款)
│   │   ├── CODE编程进阶系列 (CODE_SERIES)             (3款)
│   │   └── BUILD创意搭建系列 (BUILD_SERIES)            (3款)
│   └── 💝 陪伴与服务机器人 (COMPANION)
│       ├── PET仿生宠物系列 (PET_SERIES)                (4款)
│       ├── COMP智能陪护系列 (COMP_SERIES)              (3款)
│       └── ELDER养老辅助系列 (ELDER_SERIES)            (3款)
│
└── 🤖 具身智能机器人 (EMBODIED_AI)         ← L1 产品族
    ├── 🚶 人形机器人 (HUMANOID)             ← L2 产品线
    │   ├── BIPED双足人形系列 (BIPED_SERIES)            (4款)
    │   ├── WHEEL轮式人形系列 (WHEEL_SERIES)            (3款)
    │   └── HUMANOID全尺寸系列 (HUMANOID_SERIES)        (3款)
    ├── 🏢 商用服务机器人 (COMMERCIAL_SERVICE)
    │   ├── RECEPTION智能接待系列 (RECEPTION_SERIES)    (4款)
    │   ├── DELIVERY物流配送系列 (DELIVERY_SERIES)      (4款)
    │   └── RETAIL商用零售系列 (RETAIL_SERIES)          (3款)
    └── ⚠️ 特种作业机器人 (SPECIAL_OPS)
        ├── INSPECT智能巡检系列 (INSPECT_SERIES)        (4款)
        ├── RESCUE应急救援系列 (RESCUE_SERIES)           (3款)
        └── MARINE水下作业系列 (MARINE_SERIES)           (3款)
```

---

## 二、数据统计

| 维度 | 数量 |
|------|:---:|
| 产品族 (L1) | 3 |
| 产品线 (L2) | 10 |
| 产品系列 (L3) | 30 |
| 产品 (L4) | 100 |
| 产品目录 | 3 |
| 替代关系 | 3 |

### 生命周期分布

| 状态 | 数量 | 典型产品 |
|------|:---:|---------|
| ACTIVE | 94 | 大多数在售产品 |
| PRE_RELEASE | 5 | HEAVY-2000, CodeBot AI, CareBot Pro, Biped-Pro, Humano G1 Explore |
| EOL_ANNOUNCED | 1 | SweepBot Mini（2026Q3停产） |

### 配置类型分布

| 类型 | 数量 | 说明 |
|------|:---:|------|
| STANDARD | 30 | 标准配置，固定SKU |
| ATO | 52 | 按订单装配，属性可配置 |
| ETO | 18 | 按订单设计，高度定制 |

### 价格区间

| 产品族 | 价格区间 |
|--------|---------|
| 工业机器人 | ¥48,000 - ¥980,000 |
| 家用机器人 | ¥299 - ¥25,800 |
| 具身智能机器人 | ¥12,800 - ¥980,000 |

---

## 三、产品ID编号规则

| 范围 | 用途 |
|:------|------|
| 101-103 | L1 产品族 |
| 201-210 | L2 产品线 |
| 301-330 | L3 产品系列 |
| 1001-1100 | L4 产品 |
| 1-3 | 产品目录 |

---

## 四、每个产品的固定属性（三字段）

所有100个产品均通过 `category_id` FK 关联到 `cpq_product_category`，向上遍历树即可获得：

| 属性 | 来源 | 示例（RW-ARC-160） |
|------|------|-------------------|
| **所属产品族** | `category_id→parent→parent.category_name` | 工业机器人 |
| **所属产品线** | `category_id→parent.category_name` | 焊接机器人 |
| **所属产品系列** | `category_id.category_name` | ARC弧焊系列 |

通过 SQL 查询获取：`SELECT c3.category_name AS series, c1.category_name AS line, c2.category_name AS family FROM cpq_product_model pm JOIN cpq_product_category c3 ON pm.category_id = c3.category_id JOIN cpq_product_category c1 ON c3.parent_category_id = c1.category_id JOIN cpq_product_category c2 ON c1.parent_category_id = c2.category_id WHERE pm.model_id = 1001;`
