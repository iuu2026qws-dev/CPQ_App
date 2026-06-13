# M-CPQ 产品数据架构全视图

> 版本：V1.3 | 日期：2026-06-07
> 基于：产品及配置相关概念.txt + CPQ深度研究报告 V2.0 + CPQ后端功能设计 + 业界CPQ最佳实践
> 目的：完整呈现产品→配置→BOM→捆绑→定价→规则→属性→生命周期的逻辑关系和数据结构
> V1.3 变更：新增产品变体实体化设计（cpq_product_variant），将 L5 层的属性组合从「配置快照内嵌」提升为「独立持久化实体」，重构 L5/L6 分层逻辑。变体 = 产品型号 × 属性值组合 → 确定的可售卖 SKU，每个产品可有多个变体（如不同颜色/配置），每条变体有独立编码、价格、默认标记。变体数据同步串联定价域：价格手册条目和渠道价格均增加 variant_id FK，定价可从模型级延伸到变体级。
> V1.2 变更：产品分类从「内联字符串字段」改为「独立层级树表」（cpq_product_category），cpq_product_model 用 category_id FK 替代 product_line/product_family/product_series
> V1.1 变更：产品捆绑从「SBOM行隐式表达」改为「独立三表建模」（cpq_bundle / cpq_bundle_option_group / cpq_bundle_option）

---

## 一、总体架构：九大数据域全景图

```
                              ┌─────────────────────────────────┐
                              │        D07 系统数据域            │
                              │  租户/用户/角色/ABAC策略/审计    │
                              └──────────────┬──────────────────┘
                                             │ 贯穿所有域
    ┌────────────┐  ┌──────────┐  ┌──────────┴──────┐  ┌──────────────┐
    │ D06 客户   │  │ D01 产品  │  │  D03 配置引擎   │  │ D08 集成域   │
    │ 渠道域     │  │ 数据域   │  │  规则+约束       │  │ CRM/ERP/PLM  │
    │ 客户/渠道  │  │          │  │                  │  │ 连接器       │
    │ 协议价/区域│  │  ★核心★  │  │  变体BOM/属性    │  │              │
    └─────┬──────┘  └────┬─────┘  │  映射/兼容矩阵   │  └──────┬───────┘
          │              │        └────────┬─────────┘         │
          │              │                │                    │
          ▼              ▼                ▼                    ▼
    ┌─────────────────────────────────────────────────────────────┐
    │                   D02 定价数据域                             │
    │   价格手册 → 价格条目 → 定价规则 → 阶梯价 → 渠道价 → 汇率    │
    └─────────────────────────┬───────────────────────────────────┘
                              │
                              ▼
    ┌─────────────────────────────────────────────────────────────┐
    │                   D04 报价数据域                             │
    │   报价单 → 行项目 → 配置快照 → 版本 → 模板 → 方案文档        │
    └─────────────────────────┬───────────────────────────────────┘
                              │
                              ▼
    ┌─────────────────────────────────────────────────────────────┐
    │                   D05 审批数据域                             │
    │   审批规则 → 审批链 → 审批记录 → 审批矩阵                    │
    └─────────────────────────────────────────────────────────────┘

    数据流方向：客户选择产品 → 配置规则约束 → BOM展开 → 定价引擎计算 →
               报价单生成 → 审批流转 → 集成下发
```

---

## 二、D01 产品数据域（核心）—— 完整逻辑架构

```
                            ┌───────────────────────────────┐
                            │  cpq_product_category         │
                            │  (产品分类 — 层级树)          │
                            │                               │
                            │  ★ 自引用树结构               │
                            │  parent_category_id (自引用)  │
                            │                               │
                            │  category_level =             │
                            │    1 = 产品线(L2)             │
                            │    2 = 产品族(L1)             │
                            │    3 = 产品系列(L3)           │
                            │                               │
                            │  例:                          │
                            │  L1(产品族): DMR数字对讲机    │
                            │    ├─ L2(产品线): 手持终端    │
                            │    │   └─ L3(产品系列): PD700系列 │
                            │    └─ L2(产品线): 车载终端    │
                            │        └─ L3(产品系列): MD650系列 │
                            └──────────────┬────────────────┘
                                           │ N:1 (产品指向L3叶子节点)
                                           │
    ┌──────────────────────────────────────┼───────────────────────────┐
    │                                      ▼                           │
    │  ┌─────────────────────────────────────────────────────────┐    │
    │  │               cpq_product_model (可销售产品)             │    │
    │  │  ┌───────────────────────────────────────────────────┐  │    │
    │  │  │ 五层产品结构                                       │  │    │
    │  │  │                                                    │  │    │
    │  │  │ L1-L3 → category_id FK → cpq_product_category     │  │    │
    │  │  │         (通过树向上遍历获取L1/L2名称)              │  │    │
    │  │  │ L4     → model_code                               │  │    │
    │  │  │ L5     → SBOM物料清单展开 = 配置实例               │  │    │
    │  │  └───────────────────────────────────────────────────┘  │    │
    │  │                                                          │    │
    │  │  核心字段:                                                │    │
    │  │  - category_id (FK→cpq_product_category, L3节点)         │    │
    │  │  - model_code (UK), model_name, description             │    │
    │  │  - lifecycle_status (8状态状态机)                        │    │
    │  │  - successor_model_id (自引用→替代品)                    │    │
    │  │  - base_price, currency, config_type                     │    │
    │  │  - min_order_qty, lead_time_days                        │    │
    │  │  - default_bom_id → cpq_sbom_header                      │    │
    │  └────────────┬───┬───────┬──────┬───────────────────────────┘    │
    │               │   │       │      │                                │
    │               │   │ 1:N   │ 1:N  │ 1:1 (默认BOM)                  │
    │               │   │       │      │                                │
    │               │   │       │      │                                │
    │    ┌──────────┘   │       │      └──────────────┐                 │
    │    │ 1:N          │       │                     │                 │
    │    ▼              │       │                     │                 │
    │  ┌────────────────┴─┐     │                     │                 │
    │  │ cpq_product_     │     │                     │                 │
    │  │ variant          │     │                     │                 │
    │  │ (产品变体)       │     │                     │                 │
    │  │                  │     │                     │                 │
    │  │ ★ L5 实体化      │     │                     │                 │
    │  │ model_id (FK)    │     │                     │                 │
    │  │ variant_code (UK)│     │                     │                 │
    │  │ variant_name     │     │                     │                 │
    │  │ attributes (JSON)│     │                     │                 │
    │  │   {"颜色":"白"}   │     │                     │                 │
    │  │ base_price       │     │                     │                 │
    │  │ is_default (0/1) │     │                     │                 │
    │  │ default_bom_id   │     │                     │                 │
    │  │   → 确定型BOM    │     │                     │                 │
    │  │                  │     │                     │                 │
    │  │ ★ 唯一约束：      │     │                     │                 │
    │  │ uk_model_attrs:  │     │                     │                 │
    │  │ (model_id,       │     │                     │                 │
    │  │  attributes)      │     │                     │                 │
    │  └────────┬─────────┘     │                     │                 │
    │           │               │                     │                 │
    │           │               │                     │                 │
    │           ▼               ▼                     ▼                 │
    │  ┌───────────────┐  ┌────────────────────┐  ┌────────────────┐  │
    │  │ cpq_product_  │  │ cpq_product_       │  │ cpq_sbom_      │  │
    │  │ attribute     │  │ lifecycle_log      │  │ header         │  │
    │  │ (产品属性)    │  │ (生命周期日志)     │  │ (销售BOM头)    │  │
    │  │               │  │                    │  │                │  │
    │  │ - attr_category│  │ - from_status      │  │ - sbom_name    │  │
    │  │ - attr_name   │  │ - to_status        │  │ - sbom_version │  │
    │  │ - attr_value  │  │ - change_reason    │  │                │  │
    │  │ - data_type   │  │ - change_time      │  │                │  │
    │  │ - option_vals │  │                    │  │                │  │
    │  │   (JSON枚举)  │  │ 记录8态迁移全历史  │  │                │  │
    │  │               │  │                    │  │                │  │
    │  │ 可配置/必选/   │  └────────────────────┘  └───────┬────────┘  │
    │  │ 显示顺序      │                                    │ 1:N       │
    │  └───────────────┘                                    ▼           │
    │                                              ┌────────────────┐  │
    │                                              │ cpq_sbom_line  │  │
    │                                              │ (销售BOM行)    │  │
    │                                              │                │  │
    │                                              │ ★ 递归树形结构  │  │
    │                                              │ parent_line_id │  │
    │                                              │   (自引用FK)   │  │
    │                                              │                │  │
    │                                              │ - item_code    │  │
    │                                              │ - item_name    │  │
    │                                              │ - item_type    │  │
    │                                              │   HOST/        │  │
    │                                              │   ACCESSORY/   │  │
    │                                              │   SERVICE/     │  │
    │                                              │   LICENSE/     │  │
    │                                              │   SOFTWARE/    │  │
    │                                              │   PACKAGE      │  │
    │                                              │ - quantity     │  │
    │                                              │ - unit         │  │
    │                                              │                │  │
    │                                              │ ★ 高级BOM特性:  │  │
    │                                              │ - is_phantom   │  │
    │                                              │   (虚项)       │  │
    │                                              │ - is_replaceable│  │
    │                                              │ - replacement  │  │
    │                                              │   _group       │  │
    │                                              │ - min_qty/     │  │
    │                                              │   max_qty      │  │
    │                                              │ - price_impact │  │
    │                                              └───────┬────────┘  │
    │                                                      │           │
    │                                                      │ 展开转换  │
    │                                                      ▼           │
    │                                              ┌────────────────┐  │
    │                                              │ cpq_mbom_line  │  │
    │                                              │ (制造BOM行)    │  │
    │                                              │                │  │
    │                                              │ ★ SBOM→MBOM    │  │
    │                                              │ sbom_line_id   │  │
    │                                              │   → 来源追溯   │  │
    │                                              │                │  │
    │                                              │ - material_code│  │
    │                                              │ - material_type│  │
    │                                              │   RAW/SEMI/    │  │
    │                                              │   FINISHED/    │  │
    │                                              │   PACKAGE      │  │
    │                                              │ - plant        │  │
    │                                              │ - storage_loc  │  │
    │                                              │ - cost_component│  │
    │                                              │ - substitute_  │  │
    │                                              │   group/priority│  │
    │                                              │ - moq/lead_time│  │
    │                                              └────────────────┘  │
    │                                                                  │
    │  ┌──────────────────────────────────────────────────────────┐    │
    │  │         cpq_product_supersession (产品替代关系)          │    │
    │  │                                                          │    │
    │  │  original_model_id ──→ replacement_model_id              │    │
    │  │                                                          │    │
    │  │  supersession_type:                                      │    │
    │  │    FULL         完全替代 (新代旧)                        │    │
    │  │    CONDITIONAL  条件替代 (满足条件时才替代)              │    │
    │  │    SPLIT        拆分替代 (旧产品拆为多个新产品)          │    │
    │  │    AGGREGATE    聚合替代 (多个旧产品合并为一个新产品)    │    │
    │  │                                                          │    │
    │  │  condition_expr (条件表达式, CONDITIONAL类型时)          │    │
    │  │  price_impact_pct (替代价格影响百分比)                   │    │
    │  └──────────────────────────────────────────────────────────┘    │
    └──────────────────────────────────────────────────────────────────┘
```

---

## 三、生命周期状态机（8状态）

```
    CONCEPT ──→ DESIGN ──→ PRE_RELEASE ──→ ACTIVE
       │                                     │
       │                              ┌──────┴──────┐
       │                              │             │
       │                         EOL_ANNOUNCED      │
       │                              │             │
       │                         LAST_TIME_BUY      │
       │                              │             │
       │                         DISCONTINUED       │
       │                              │             │
       └──────────────────────────────┴─────────────┘
                                              │
                                          ARCHIVED

    每次状态变更 → cpq_product_lifecycle_log 记录 (from_status, to_status, reason)
    历史全链可审计，支持合规审查和变更回放
```

---

## 四、D03 配置规则引擎 —— 保证配置合法性

```
    cpq_product_model ─────────────────┐
                                       │
    ┌──────────────────────────────────┼─────────────────────────┐
    │                        配置规则域                           │
    │                                                            │
    │  ┌────────────────────┐   ┌───────────────────────────┐   │
    │  │ cpq_config_rule    │   │ cpq_variant_bom           │   │
    │  │ (配置规则)         │   │ (变体BOM / 150% BOM)     │   │
    │  │                    │   │                           │   │
    │  │ - rule_type:       │   │ ★ 一条SBOM行对应多个      │   │
    │  │   VALIDATION       │   │   可选物料变体            │   │
    │  │   (阻止错误组合)   │   │                           │   │
    │  │   SELECTION        │   │ - sbom_line_id → 来源行  │   │
    │  │   (自动添加推荐)   │   │ - variant_material_code   │   │
    │  │   ALERT            │   │ - selection_condition     │   │
    │  │   (通知销售)       │   │   (触发条件表达式)        │   │
    │  │   VISIBILITY       │   │ - is_default              │   │
    │  │   (隐藏无关项)     │   │                           │   │
    │  │                    │   │ ★ 150% BOM: 把全平台     │   │
    │  │ - rule_expression  │   │   可能的变体全部列出，    │   │
    │  │   (规则表达式)     │   │   CSP求解后过滤为100%    │   │
    │  └────────┬───────────┘   └───────────────────────────┘   │
    │           │                                               │
    │           │ 引用                                          │
    │           ▼                                               │
    │  ┌────────────────────┐   ┌───────────────────────────┐   │
    │  │ cpq_attribute_     │   │ cpq_compatibility_matrix  │   │
    │  │ mapping            │   │ (兼容性矩阵)              │   │
    │  │ (属性→物料映射)    │   │                           │   │
    │  │                    │   │ ★ 跨产品间的互斥/依赖     │   │
    │  │ attr_name          │   │   关系声明                │   │
    │  │   option_value     │   │                           │   │
    │  │     → material_code│   │ - source_product_id       │   │
    │  │     → sbom_line_id │   │ - target_product_id       │   │
    │  │                    │   │ - compatibility_type:     │   │
    │  │ ★ 选了"钛合金外壳" │   │   MUTUAL_EXCLUSIVE 互斥  │   │
    │  │   → 自动匹配       │   │   DEPENDENCY       依赖  │   │
    │  │   "钛合金散热方案" │   │   REQUIRES         前置  │   │
    │  └────────────────────┘   └───────────────────────────┘   │
    │                                                            │
    │  ┌────────────────────┐                                   │
    │  │ cpq_attribute_     │   ★ ConfigEngineService:           │
    │  │ option             │     - validate() 全量校验           │
    │  │ (选项值定义)       │     - propagateConstraints() 传播   │
    │  │                    │     - guidedSelling() 向导式配置    │
    │  │ - option_code      │                                    │
    │  │ - option_label     │                                    │
    │  │ - sort_order       │                                    │
    │  └────────────────────┘                                    │
    └────────────────────────────────────────────────────────────┘
```

---

## 五、D02 定价引擎 —— 产品与价格解耦

```
    ┌────────────────────────────────────────────────────────┐
    │                    定价数据域                           │
    │                                                        │
    │  ┌──────────────────────┐                              │
    │  │ cpq_price_book       │  ★ 价格手册 = 定价维度容器   │
    │  │ (价格手册)           │                              │
    │  │                      │  例: 零售价手册 / 渠道价手册  │
    │  │ - book_name          │      东盟区价手册 / 2026促销  │
    │  │ - book_type          │                              │
    │  │   STANDARD/CHANNEL/  │      ┌───────────────┐       │
    │  │   PROMOTION/REGION   │      │ 产品A         │       │
    │  │ - currency           │      │ 零售价: ¥100  │       │
    │  │ - start_date/end_date│      │ 渠道价: ¥80   │       │
    │  └──────────┬───────────┘      │ 东盟区: $12   │       │
    │             │ 1:N              │ 促销价: ¥70   │       │
    │             ▼                  └───────────────┘       │
    │  ┌──────────────────────┐                              │
    │  │ cpq_price_book_entry │  ★ 价格条目 = 产品+变体+手册+价格 │
    │  │ (价格手册条目)       │                              │
    │  │                      │  关键维度:                    │
    │  │ - price_book_id (FK) │  - product_model_id → 产品   │
    │  │ - product_model_id   │  - variant_id → 变体(NULL=    │
    │  │ - variant_id (FK)    │    模型级定价, 非NULL=      │
    │  │ - list_price         │    变体级定价)               │
    │  │ - cost_price (成本)  │  - term_months → 合同期限    │
    │  │ - currency           │  - min_qty/max_qty → 数量    │
    │  │ - term_months        │  - region → 区域             │
    │  │ - min_qty/max_qty    │                              │
    │  │                      │  ★ 成本字段受ABAC保护:       │
    │  │                      │    L0渠道不可见, L3高管全可见 │
    │  └──────────┬───────────┘                              │
    │             │                                          │
    │             │ 关联                                     │
    │             ▼                                          │
    │  ┌──────────────────────┐  ┌──────────────────────┐   │
    │  │ cpq_price_rule       │  │ cpq_volume_tier       │   │
    │  │ (定价规则)           │  │ (阶梯定价)            │   │
    │  │                      │  │                       │   │
    │  │ - rule_type:         │  │ - price_book_entry_id │   │
    │  │   DISCOUNT (折扣)    │  │ - min_quantity        │   │
    │  │   MARKUP (加成)      │  │ - max_quantity        │   │
    │  │   PROMOTION (促销)   │  │ - unit_price          │   │
    │  │ - rule_expression    │  │                       │   │
    │  │ - priority           │  │ ★ 100个以下 ¥100     │   │
    │  │ - approval_required  │  │   100-500个 ¥85      │   │
    │  │   (超折扣需审批)     │  │   500+个 ¥70         │   │
    │  └──────────────────────┘  └──────────────────────┘   │
    │                                                        │
    │  ┌──────────────────────┐  ┌──────────────────────┐   │
    │  │ cpq_channel_price    │  │ cpq_currency_rate     │   │
    │  │ (渠道价格)           │  │ (汇率)                │   │
    │  │                      │  │                       │   │
    │  │ 渠道客户专属定价     │  │ 多币种报价支持        │   │
    │  │ - variant_id (FK)    │  └──────────────────────┘   │
    │  │   NULL=模型级定价    │                             │
    │  └──────────────────────┘                             │
    └────────────────────────────────────────────────────────┘

    ★ 定价流水线 (PricingEngineService):
      Phase 1: 基价查询 (选价格手册→匹配条目→取listPrice)
      Phase 2: 阶梯折扣 (根据quantity匹配volumeTier)
      Phase 3: 渠道折扣 (检查channelPrice)
      Phase 4: 促销规则 (应用 price_rule ∩ promotion)
      Phase 5: 币种转换 (查currency_rate)
      Phase 6: 审批触发 (折扣>阈值→发起审批)
```

---

## 六、产品捆绑（Bundle）—— 组合销售模型

### 6.1 捆绑包与产品表的关系

捆绑包使用三张独立表：`cpq_bundle`（捆绑包定义）、`cpq_bundle_option_group`（选项组）、`cpq_bundle_option`（选项）。捆绑包本身也是产品，需要在 `cpq_product_model` 中注册为一条记录（`config_type = BUNDLE`），而捆绑的各个组件也是产品（指向独立的 `cpq_product_model` 记录，各自有自己的 BOM/定价/生命周期）。

```
    ┌─────────────────────────────────────────────────────────────────┐
    │                 cpq_product_model (产品表)                      │
    │                                                                 │
    │  ┌───────────────────────────┐    ┌───────────────────────────┐ │
    │  │ model_id: P-001           │    │ model_id: P-100           │ │
    │  │ model_code: "ENT_IT_SUITE"│    │ model_code: "CLOUD_BASIC" │ │
    │  │ model_name: "中小企业IT方案"│   │ model_name: "云服务器基础版" │ │
    │  │ config_type: BUNDLE       │    │ config_type: STANDARD     │ │
    │  │ ★ 角色: 捆绑包（也是产品）  │    │ ★ 角色: 组件产品（独立产品）│ │
    │  └───────┬───────────────────┘    └───────────┬───────────────┘ │
    │          │                                    ▲                  │
    │          │ cpq_bundle.model_id → P-001        │ component_       │
    │          │                                    │ model_id → P-100 │
    │          │         ┌──────────────────────────┘                  │
    │          │         │    ┌───────────────────────────┐            │
    │          │         │    │ model_id: P-200           │            │
    │          │         │    │ model_code: "EMAIL_100U"  │            │
    │          │         │    │ model_name: "企业邮箱100用户"│            │
    │          │         │    │ config_type: STANDARD     │            │
    │          │         │    │ ★ 角色: 组件产品          │            │
    │          │         │    └───────────────────────────┘            │
    │          │         │    ┌───────────────────────────┐            │
    │          │         │    │ model_id: P-300           │            │
    │          │         │    │ model_code: "FW_BASIC"    │            │
    │          │         │    │ model_name: "网络安全防火墙"│            │
    │          │         │    │ config_type: STANDARD     │            │
    │          │         │    │ ★ 角色: 组件产品          │            │
    │          │         │    └───────────────────────────┘            │
    └──────────┼─────────┼────────────────────────────────────────────┘
               │         │
               ▼         ▼
```

### 6.2 捆绑包三表结构

```
    ┌─────────────────────────────────────────────────────────────────┐
    │ cpq_bundle (捆绑包定义)                                         │
    │                                                                 │
    │ - bundle_id (PK)                                                │
    │ - model_id (FK → cpq_product_model) ← 捆绑包本身的产品ID         │
    │ - bundle_type:                                                  │
    │     FIXED         固定组合 (不可选，组件全部标配)                │
    │     CONFIGURABLE  可配置组合 (有选项组，客户可按需选配)          │
    │     SOLUTION      方案型组合 (跨多个BOM头的完整方案)             │
    │ - pricing_strategy:                                             │
    │     BUNDLE_PRICE    捆绑定价 (整体定价，折扣率独立计算)          │
    │     SUM_COMPONENTS  组件价格求和 (各组件分别定价后累加)          │
    │ - bundle_discount_pct (捆绑折扣率，如 16.7% 折扣)               │
    │ - is_active / description                                       │
    └──────────┬──────────────────────────────────────────────────────┘
               │ 1:N
               ▼
    ┌─────────────────────────────────────────────────────────────────┐
    │ cpq_bundle_option_group (捆绑选项组)                            │
    │                                                                 │
    │ - option_group_id (PK)                                          │
    │ - bundle_id (FK)                                                │
    │ - group_name ("GPU选项" / "存储方案" / "维保等级")              │
    │ - group_code                                                    │
    │ - min_selections (该组最少选几个，0=完全可选)                    │
    │ - max_selections (该组最多选几个)                               │
    │ - is_required (整组是否必选，1=至少选一个)                      │
    │ - sort_order                                                    │
    └──────────┬──────────────────────────────────────────────────────┘
               │ 1:N
               ▼
    ┌─────────────────────────────────────────────────────────────────┐
    │ cpq_bundle_option (捆绑选项)                                    │
    │                                                                 │
    │ - option_id (PK)                                                │
    │ - option_group_id (FK)                                          │
    │ - component_model_id (FK → cpq_product_model) ← 组件是独立产品  │
    │ - quantity (默认数量) / unit                                    │
    │ - is_default (是否默认选中)                                     │
    │ - price_modifier_type (价格调整类型)                             │
    │     NONE          不调整                                       │
    │     FIXED_AMOUNT  固定金额 (+/-)                               │
    │     PERCENT       百分比调整 (+/-)                             │
    │     INCLUDE       已含在捆绑包总价中                           │
    │ - price_modifier_value (调整数值)                               │
    │ - sort_order                                                    │
    └─────────────────────────────────────────────────────────────────┘
```

### 6.3 捆绑示例

```
    捆绑包: "中小企业IT方案" (BUNDLE_PRICE, ¥50,000)
    ├── Option Group 1: "计算资源" (必选, 最少1, 最多1)
    │   ├── 云服务器基础版 (P-100, is_default=1) [无价格调整，已含]
    │   └── 云服务器高性能版 (P-101) [+¥10,000]
    │
    ├── Option Group 2: "GPU加速" (可选, 最少0, 最多2)
    │   ├── GPU A100 单卡 (P-200) [+¥8,000/卡]
    │   └── GPU H100 单卡 (P-201) [+¥15,000/卡]
    │
    └── Option Group 3: "维保服务" (必选, 最少1, 最多1)
        ├── 1年标准维保 (P-300, is_default=1) [已含]
        ├── 3年标准维保 (P-301) [+¥12,000]
        └── 3年金牌维保 (P-302) [+¥30,000]

    示例报价:
      基础捆绑价: ¥50,000
      + GPU H100 × 2: +¥30,000
      + 3年金牌维保: +¥30,000
      ─────────────────────
      最终报价: ¥110,000
```

### 6.4 捆绑与 BOM 的关系

捆绑包的组件产品各自拥有独立的 BOM（通过 `cpq_product_model.default_bom_id → cpq_sbom_header → cpq_sbom_line`）。报价时，引擎递归展开：捆绑包 → 选项组件产品 → 各组件产品的 SBOM 行。

### 6.5 与业界对照

| M-CPQ | Salesforce CPQ | Oracle CPQ | SAP CPQ |
|-------|---------------|------------|---------|
| cpq_product_model (config_type=BUNDLE) | Product2 (IsBundle=TRUE) | Configurable Model | Configurable Product |
| cpq_bundle_option_group | ProductFeature | Option Class | Option Group |
| cpq_bundle_option (component_model_id) | ProductOption (指向其他Product2) | Option → BOM Mapping | Option Item |
| 捆绑定价 (pricing_strategy) | Bundle Price / Sum Components | Pricing Rule on Model | Package Pricing |

---

## 七、属性模板 / 属性集 —— 数据规范化

```
    属性模板概念 (由 cpq_product_attribute 实现):

    ┌──────────────────────────────────────────────────┐
    │   属性集 "服务器配置模板"                          │
    │                                                   │
    │   ┌─────────────────────────────────────────┐    │
    │   │ attr_category = "计算资源"               │    │
    │   │ ├─ attr_name = "CPU型号"                │    │
    │   │ │  data_type=ENUM                       │    │
    │   │ │  option_values=["Xeon-Gold",          │    │
    │   │ │    "Xeon-Platinum", "EPYC"]           │    │
    │   │ │  is_configurable=1, is_required=1     │    │
    │   │ │                                       │    │
    │   │ ├─ attr_name = "内存容量"               │    │
    │   │ │  data_type=ENUM                       │    │
    │   │ │  option_values=["64GB","128GB",       │    │
    │   │ │    "256GB","512GB"]                   │    │
    │   │ │  is_configurable=1, is_required=1     │    │
    │   │ │                                       │    │
    │   │ └─ attr_name = "GPU加速"                │    │
    │   │    data_type=BOOLEAN                    │    │
    │   │    is_configurable=1, is_required=0     │    │
    │   └─────────────────────────────────────────┘    │
    │                                                   │
    │   ┌─────────────────────────────────────────┐    │
    │   │ attr_category = "存储配置"               │    │
    │   │ ├─ attr_name = "系统盘类型"              │    │
    │   │ │  option_values=["SSD","NVMe"]         │    │
    │   │ │                                       │    │
    │   │ ├─ attr_name = "系统盘容量"              │    │
    │   │ │  data_type=NUMBER, unit="GB"          │    │
    │   │ │                                       │    │
    │   │ └─ attr_name = "数据盘数量"              │    │
    │   │    min=0, max=24                        │    │
    │   └─────────────────────────────────────────┘    │
    │                                                   │
    │  ★ 同属一个 product_line 的产品                      │
    │    可复用相同的属性模板(通过 attr_category 分组)     │
    └──────────────────────────────────────────────────┘

    与 cpq_attribute_mapping 的协作:

    用户选择 "CPU型号=Xeon-Platinum" + "内存容量=512GB"
              │
              ▼
    cpq_attribute_mapping:
    (model_id, attr_name="CPU型号", option_value="Xeon-Platinum")
      → material_code="Xeon-8480+"
      → sbom_line_id=42 (匹配到对应的SBOM物料行)
    (model_id, attr_name="内存容量", option_value="512GB")
      → material_code="MEM-DDR5-512G"
      → sbom_line_id=58
```

---

## 八、完整数据关系总图（ER视角）

```
    ┌──────────────────────────────┐    ┌──────────────────────────┐
    │  cpq_product_category        │    │  cpq_product_catalog      │
    │  (产品分类 — 层级树)         │    │  (目录)                   │
    │                              │    └──────────┬───────────────┘
    │  ★ self-ref tree             │               │ 1:N
    │  parent_category_id          │               │
    │  category_level (1/2/3)      │               │
    └──────────┬───────────────────┘               │
               │ N:1                               │
               ▼                                   ▼
    ┌─────────────────────────────────────────────────────────┐
    │                 cpq_product_model (产品)                 │
    │  ┌─────────────────────────────────────────────────┐    │
    │  │ category_id → L3叶子节点  + model_code (L4)       │    │
    │  │ model_name / description                         │    │
    │  │ lifecycle_status (8态) + successor_model_id (自引用)│    │
    │  │ config_type (STANDARD/ATO/CTO/ETO/BUNDLE)        │    │
    │  │ base_price / currency / default_bom_id           │    │
    │  └─────────────────────────────────────────────────┘    │
    └──┬────────┬─────────┬─────────┬──────────┬──────────────┐
       │1:N     │1:N      │1:N      │N:N       │1:N            │
       ▼        ▼         ▼         ▼          ▼               │
    ┌──────┐ ┌──────┐ ┌────────┐ ┌────────┐ ┌──────────────┐  │
    │变体  │ │属性  │ │生命周期│ │替代关系│ │价格手册条目  │  │
    │varia-│ │attr  │ │日志    │ │super   │ │(D02定价域)  │  │
    │nt    │ │ibute │ │life-   │ │session │ │price_book    │  │
    │      │ │      │ │cycle   │ │        │ │entry         │  │
    │★L5  │ │      │ │log     │ │        │ │              │  │
    │实体化│ │      │ │        │ │        │ │- variant_id  │  │
    └──┬───┘ └──┬───┘ └────────┘ └────────┘ └──────┬───────┘  │
       │        │                                   │          │
       │        │                                   │          │
       │        │ (通过attr_mapping映射物料+BOM行)   │          │
       │        └───────────────┐                   │          │
       │                        │                   │          │
       │             ┌──────────┘                   │          │
       │             ▼ 1:1 (变体→确定型BOM)          │          │
       │       ┌──────────────┐                     │          │
       │       │ cpq_sbom_    │                     │          │
       │       │ header       │                     │          │
       │       │ (销售BOM头)  │                     │          │
       │       └──────┬───────┘                     │          │
       │              │ 1:N                         │          │
       │              ▼                             │          │
       │       ┌──────────────┐                     │          │
       │       │ cpq_sbom_line│ ← parent_line_id    │          │
       │       │ (销售BOM行)  │    (递归树)          │          │
       │       └──────┬───────┘                     │          │
       │              │ 展开转换                     │          │
       │              ▼                             │          │
       │       ┌──────────────┐                     │          │
       └──────→│ cpq_mbom_line│ ← SBOM→MBOM         │          │
    (variant   │ (制造BOM行)  │   全链路贯通         │          │
     default   └──────────────┘                     │          │
     _bom_id)                                       │          │
       │                                            │          │
       │ 1:N (variant_id → entry/channel)           │          │
       └────────────────────────────────────────────┘          │
     mapping映射)   └──────────────┘

    定价域 (D02):
      cpq_price_book ──1:N──→ cpq_price_book_entry ←── cpq_price_rule
                                    │  (entry 包含 variant_id → 变体级/模型级定价)
                                    ├── cpq_volume_tier
                                    ├── cpq_channel_price (含 variant_id)
                                    └── cpq_currency_rate

    变体域 (D01, 新增):
      cpq_product_variant ──N:1──→ cpq_product_model (model_id)
      cpq_product_variant ──1:N──→ cpq_price_book_entry (variant_id, NULL=模型级)
      cpq_product_variant ──1:N──→ cpq_channel_price (variant_id, NULL=模型级)
      cpq_product_variant ──1:1──→ cpq_sbom_header (default_bom_id, 确定型BOM)

    产品捆绑 (Bundle):
      cpq_bundle ──→ cpq_product_model (model_id, 捆绑包自身)
      cpq_bundle ──1:N──→ cpq_bundle_option_group
      cpq_bundle_option_group ──1:N──→ cpq_bundle_option
      cpq_bundle_option ──→ cpq_product_model (component_model_id, 组件产品)

    配置域 (D03):
      cpq_config_rule ──→ cpq_product_model
      cpq_variant_bom ──→ cpq_sbom_line
      cpq_attribute_mapping ──→ cpq_sbom_line
      cpq_compatibility_matrix ──→ cpq_product_model × 2
      cpq_attribute_option

    报价域 (D04):
      cpq_quote ──1:N──→ cpq_quote_line_item ←── cpq_config_snapshot
      cpq_quote_version
      cpq_quote_template
      cpq_solution_document

    审批域 (D05):
      cpq_approval_rule → cpq_approval_chain → cpq_approval_record
      cpq_approval_matrix
```

---

## 九、关键设计决策与说明

### 9.1 为什么产品分类从内联字段改为独立树表？

V1.0 将 L1-L3 作为 `cpq_product_model` 的字符串字段（product_line/product_family/product_series）。V1.2 改为独立 `cpq_product_category` 自引用层级树表 + `cpq_product_model.category_id` FK。原因如下：

1. **数据质量**：内联字符串方案无法阻止输入不一致（如"DMR对讲机" vs "DMR数字对讲机"），独立表通过 FK 约束强制引用已定义的分类值。

2. **分类统一管理**：产品分类有独立生命周期（新增产品族、调整产品线归属等），独立表让分类管理员可以增删改分类，不影响产品数据。而字符串字段方式下，改一个产品族名称需要 UPDATE 所有关联产品。

3. **前端 Lookup 交互**：产品模型表单需要三级级联选择器（L1→L2→L3），独立表提供标准 API（获取树/子节点），配合前端 `el-select` 级联 lookup，实现结构化选择而非文本输入。

4. **扩展性**：后续可以为分类节点挂载默认属性模板、默认定价规则、默认审批策略等（category → defaultConfig），独立表方案天然支持。

5. **与业界对齐**：Salesforce CPQ 的 Product2 通过 `Family` picklist 字段区分分类，Oracle CPQ 有独立的 Category 管理模块，SAP 使用 Classification System。独立分类管理是 CPQ 行业标准。

**表设计**：`cpq_product_category` 采用单表自引用树，`parent_category_id` 为 NULL 表示 L1 根节点，`category_level`（1/2/3）加速层级查询。产品通过 `category_id` 指向 L3 叶子节点，向上遍历即可获取 L1/L2 完整路径。

### 9.2 为什么 BOM 不用 JSON 字段而用行表？

行业中有两种 BOM 建模方式：JSON 大字段（灵活但不可查询）和行表（可索引+可关联+可追溯）。制造业 CPQ 选择了行表，原因是：
- SBOM 行需要 `WHERE is_phantom / is_replaceable / replacement_group` 查询
- MBOM 行需要按 `plant / storage_location / substitute_group` 查询
- BOM 展开需要递归 CTE，依赖 `parent_line_id` 索引

### 9.3 产品捆绑为何单独建表？

经过对比分析，决定将产品捆绑从「通过 SBOM 行字段隐式表达」改为「独立三表建模」，原因如下：

1. **语义清晰**：捆绑包组件是独立可销售产品（`component_model_id → cpq_product_model`），而非物料。SBOM 行（`cpq_sbom_line.item_code`）挂的是物料编码，无法直接引用产品。独立建表后，`cpq_bundle_option.component_model_id` 显式指向产品表，语义一目了然。

2. **组件产品有独立 BOM/定价/生命周期**：捆绑组件是完整的独立产品（各有 SBOM、价格手册条目、生命周期状态），通过独立的产品 ID 引用，定价引擎可自然递归展开。若通过 SBOM 行表达，需额外在 SBOM 行中关联产品 ID，造成概念混杂。

3. **捆绑专属能力**：`cpq_bundle` 表可定义 `pricing_strategy`（捆绑定价 vs 组件求和）、`bundle_discount_pct`（整体折扣率），`cpq_bundle_option_group` 可定义 `min_selections`/`max_selections`（选项组的选配数量约束），这些都是捆绑领域的原生语义，放在 SBOM 行上会污染 BOM 模型。

4. **引导式销售**：配置器需要展示「推荐方案」（如方案A/方案B/方案C），每个方案是一个捆绑包。独立 `cpq_bundle` 表让查询推荐方案变得简单高效（`SELECT * FROM cpq_bundle WHERE is_active=1`），而不是从几十万个产品中筛选特定 SBOM 结构的记录。

5. **跨 SBOM 头捆绑**：一个捆绑包可能包含多个不同 SBOM 头的组件（如硬件 BOM+软件 BOM+服务 BOM），独立建表后不受单一 SBOM 头的限制。

**与 Salesforce CPQ 对齐**：这正是 Salesforce CPQ 的 `Product2(IsBundle) → ProductFeature → ProductOption(→Product2)` 三层模型，是业界验证过的成熟模式。

### 9.4 L5/L6 的处理方式（V1.3 更新：变体实体化）

V1.2 及之前的设计中，L5/L6 不创建独立实体表，而是通过报价时的「配置快照」记录。V1.3 将 L5 层从快照内嵌提升为独立持久化实体 `cpq_product_variant`：

- L4 (`model_code`) = `cpq_product_model` 的一条记录
- L5 (产品变体) = 产品型号 × 属性值组合 → `cpq_product_variant`（独立表，持久化）
- L6 (产品编码/SKU) = 报价行项目中的具体 SKU 实例（含变体引用 + 完整 SBOM 实例）

**为什么把 L5 实体化（从快照提升为独立表）？**

1. **定价粒度提升**：价格手册条目和渠道价格可以通过 `variant_id` FK 实现变体级定价（如「白色款 ¥4999」vs「黑色款 ¥4999」vs「银色限量 ¥5299」），而非只能模型级定价。`variant_id=NULL` 保持模型级定价兼容。

2. **默认推荐**：每个产品至少有一个 `is_default='1'` 的默认变体，前端 Lookup 组件自动选中推荐配置，减少销售人员的配置步骤。这对 STANDARD 和 ATO 产品尤为关键——销售不需要记住所有配置组合，系统自动推荐最畅销/最常用配置。

3. **配置合法性前置**：变体在管理后台预先创建，确保只有经过审核的属性组合才能被销售选择（而非让销售在报价时随意组合属性）。这对 ArcBot ARC-200P 这种 ATO 产品尤为重要——颜色+焊缝跟踪的组合必须经过工程验证。

4. **与定价/渠道域的天然关联**：变体作为独立实体，自然成为价格手册条目和渠道价格表的外键目标。查询价格条目列表时，通过批量 `variant_id` 查询一次获得 `variantCode`/`variantName`，前端列表直接展示「哪个变体卖多少钱」。

5. **删除保护**：删除变体前检查 `cpq_price_book_entry` 和 `cpq_channel_price` 是否有引用，有引用时阻止删除并提示，防止定价数据悬挂。

**变体与 config_type 的关系**：
- STANDARD 产品：变体为必选（如 ARC-160 的黄色/蓝色/灰色），VariantLookup 强制用户选择
- ATO 产品：变体为可选（如 ARC-200P 的颜色+焊缝跟踪组合），VariantLookup 提供建议但不强制
- CTO/ETO 产品：不创建变体（因为配置是运行时唯一确定的），VariantLookup 不显示选择器
- BUNDLE 产品：不创建变体（捆绑包自身的定价由组合决定），VariantLookup 不显示选择器

### 9.5 变体与属性模板的关系

`cpq_product_attribute` 定义产品有哪些可配置属性（如「颜色」「通信方式」「防护等级」）及每个属性的枚举值。`cpq_product_variant` 是这些属性的具体取值组合（如 `{"颜色":"珍珠白","通信方式":"WiFi 6"}`）。

属性模板 = 属性的菜单（有哪些菜可以点），变体 = 已经配好的套餐（厨师推荐的固定搭配）。属性模板给 CTO/ETO 产品提供动态配置能力，变体给 STANDARD/ATO 产品提供预置的快捷选择。

### 9.6 变体命名的行业依据

关于「变体」vs「配置实例」的命名选择：

经调研 SAP CPQ（变式配置/物料变体）、Oracle CPQ、Salesforce CPQ、锋巢CPQ（产品变型）、Microsoft（产品配置）、Odoo（产品变体）等主流 CPQ 系统的术语体系，「变体」（Variant）是 CPQ 行业的通用标准术语。SAP 中文社区使用「物料变体」，锋巢CPQ 官方术语词典定义为「产品变型（Variant）：同一产品族下因参数不同而形成的具体产品规格」。本系统采用「产品变体」作为正式术语，与行业对齐。

---

## 十、Sprint 交付节奏与当前状态

| Sprint | 交付内容 | 涉及表 | 状态 |
|:------:|---------|-------|:---:|
| **S1** | 产品分类+目录+产品模型+替代品 CRUD | category/catalog/model/supersession (4表) | ✅ 已完成 |
| **S2a** | 产品变体实体化：变体 CRUD + 定价域变体串联 + 前端 VariantManager/VariantLookup | variant, price_book_entry(alter), channel_price(alter) (1新表+2表改造）| ✅ 已完成 |
| **S2b** | SBOM/MBOM/属性/生命周期 CRUD + 核心引擎 | sbom_header/line, mbom_line, attribute, lifecycle_log (5表) | 待开始 |
| **S3** | 定价域(6表) + 配置域(5表) + 捆绑域(3表) CRUD + 配置/定价引擎 | price_book系列, config_rule系列, bundle/option_group/option | 待开始 |
| **S4** | 报价域(6表) + 审批域(4表) | quote系列, approval系列 | 待开始 |
| **S5** | 客户渠道域(4表) + 集成域(3表) + ATP引擎 | account/channel, integration系列 | 待开始 |
| **S6** | 集成测试 + 部署 | 全量 | 待开始 |

---

## 十一、总结

| 维度 | 设计要点 |
|------|---------|
| **产品层级** | L1-L3 通过 cpq_product_category 层级树管理，L4 为 model_code，L5 为 cpq_product_variant（独立实体），L6 为报价行项目中的 SKU 实例 |
| **分类管理** | 独立 cpq_product_category 自引用树表，category_id FK 替代内联字符串，数据质量有保障 |
| **变体** | cpq_product_variant 将 L5 属性组合实体化，每个产品有多个独立编码的变体（如不同颜色/配置），支持默认推荐、变体级定价、删除引用保护。VariantLookup 根据 config_type 自动决定是否必选 |
| **BOM** | 两层结构：SBOM（销售视角）+ MBOM（制造视角），递归树形 + 行表建模。变体通过 default_bom_id 关联确定型 SBOM |
| **捆绑** | 独立三表建模（bundle/option_group/option），捆绑包自身是产品，组件也是独立产品，对齐 Salesforce CPQ 三层模型 |
| **属性模板** | cpq_product_attribute 按 attr_category 分组实现属性集。属性模板定义可配置维度（菜单），变体提供预置组合（套餐） |
| **配置规则** | 4种规则类型(VALIDATION/SELECTION/ALERT/VISIBILITY) + 兼容性矩阵 + 属性映射 |
| **定价引擎** | 产品-价格解耦，6阶段定价流水线，ABAC成本可见性控制。价格条目/渠道价格通过 variant_id 支持变体级定价（NULL=模型级） |
| **生命周期** | 8状态状态机，每次变更全日志记录 |
| **替代关系** | 4种替代类型(FULL/CONDITIONAL/SPLIT/AGGREGATE)，支持条件表达式 |

---

## 十二、产品变体（cpq_product_variant）详细设计

### 12.1 表结构

```sql
CREATE TABLE cpq_product_variant (
    variant_id       BIGINT         NOT NULL COMMENT '变体ID',
    tenant_id        VARCHAR(20)    DEFAULT '000000' COMMENT '租户ID',
    model_id         BIGINT         NOT NULL COMMENT '所属产品型号ID(FK→cpq_product_model)',
    variant_code     VARCHAR(100)   NOT NULL COMMENT '变体编码(如 RW-SWEEP-S1P-WHT)',
    variant_name     VARCHAR(200)   NOT NULL COMMENT '变体名称(如 SweepBot S1 Pro 白色款)',
    attributes       TEXT           NOT NULL COMMENT '属性值集合(JSON): {"颜色":"珍珠白","基站版本":"标准洗拖布基站"}',
    default_bom_id   BIGINT         DEFAULT NULL COMMENT '此变体对应的确定SBOM Header ID(FK→cpq_sbom_header)',
    base_price       DECIMAL(18,2)  DEFAULT NULL COMMENT '变体基础价(可继承model.base_price或覆盖)',
    thumbnail_url    VARCHAR(500)   DEFAULT NULL COMMENT '变体缩略图',
    is_default       CHAR(1)        DEFAULT '0' COMMENT '是否默认变体(0否 1是)',
    status           CHAR(1)        DEFAULT '0' COMMENT '状态(0正常 1停用)',
    del_flag         CHAR(1)        DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept      BIGINT         DEFAULT NULL,
    create_by        BIGINT         DEFAULT NULL,
    create_time      DATETIME       DEFAULT NULL,
    update_by        BIGINT         DEFAULT NULL,
    update_time      DATETIME       DEFAULT NULL,
    remark           VARCHAR(500)   DEFAULT NULL,
    PRIMARY KEY (variant_id),
    UNIQUE KEY uk_variant_code (tenant_id, variant_code),
    UNIQUE KEY uk_model_attrs (tenant_id, model_id, attributes(255)),
    INDEX idx_model (tenant_id, model_id),
    INDEX idx_default (tenant_id, model_id, is_default)
) ENGINE=InnoDB COMMENT='CPQ产品变体(型号+属性组合→确定的可售卖SKU)';
```

### 12.2 关键约束与索引说明

| 约束/索引 | 说明 |
|-----------|------|
| `uk_variant_code` | 租户内变体编码全局唯一 |
| `uk_model_attrs` | 同一产品型号下，属性组合不可重复（防止重复创建"白色+标准基站"等相同组合） |
| `idx_model` | 按产品型号查询变体列表的常用索引 |
| `idx_default` | 查询产品的默认变体，供 VariantLookup 自动选中 |

### 12.3 与定价域的关联

价格手册条目表 `cpq_price_book_entry` 和渠道价格表 `cpq_channel_price` 均增加了 `variant_id` 字段：

```sql
ALTER TABLE cpq_price_book_entry ADD COLUMN variant_id BIGINT DEFAULT NULL 
    COMMENT '变体ID(FK→cpq_product_variant, NULL=模型级定价)';
ALTER TABLE cpq_channel_price ADD COLUMN variant_id BIGINT DEFAULT NULL
    COMMENT '变体ID(FK→cpq_product_variant, NULL=模型级定价)';
```

定价级别判定逻辑：
- `variant_id IS NULL` → 模型级定价（适用于变体尚未创建的旧数据或对价格无差异的产品）
- `variant_id IS NOT NULL` → 变体级定价（如白色款 ¥4999 vs 全能基站版 ¥5999）

前端查询价格条目/渠道价格列表时，后端通过 JdbcTemplate 批量查询关联变体的 `variantCode` 和 `variantName`，将结果 enrich 到返回的 VO 中，前端直接展示。

### 12.4 删除保护机制

删除变体前，Service 层检查以下引用：
1. `cpq_price_book_entry` 中是否有 `variant_id = 目标变体ID` 的记录
2. `cpq_channel_price` 中是否有 `variant_id = 目标变体ID` 的记录

若存在任一引用，抛出业务异常阻止删除，提示用户先清理关联的定价数据。

### 12.5 前端组件架构

**VariantManager.vue**（变体管理组件）：
- 嵌入在产品目录页的表格展开行中
- 展示当前产品的所有变体列表（编码、名称、属性 JSON 格式化显示、价格、默认标记）
- 提供新增/编辑弹窗（表单包含编码、名称、属性JSON、价格、缩略图、是否默认），支持编辑和删除
- 弹窗使用 `append-to-body` 防止被表格展开行的 overflow 裁剪

**VariantLookup.vue**（变体选择器）：
- 嵌入在价格手册条目和渠道价格的新增/编辑弹窗中
- 根据产品的 `configType` 自动决定显示模式：
  - STANDARD: 显示 el-select，强制选择
  - ATO: 显示 el-select，可选择
  - CTO/ETO/BUNDLE: 隐藏选择器，显示提示文本
- 选项显示格式：「编码 - 名称 [默认] ¥价格」
- 选中后 emit `select` 事件，父组件自动填充物料编码和目录价

### 12.6 变体与产品层级的最终映射

```
L1(产品族) ──→ cpq_product_category (category_level=1)
    └─ L2(产品线) ──→ cpq_product_category (category_level=2, parent→L1)
        └─ L3(产品系列) ──→ cpq_product_category (category_level=3, parent→L2)
            └─ L4(产品型号) ──→ cpq_product_model (category_id→L3, model_code)

L5(产品变体) ──→ cpq_product_variant (model_id→L4, attributes=JSON属性组合)
    └─ is_default='1' → 推荐配置（VariantLookup 自动选中）
    └─ variant_code → 唯一物料编码（用于定价/报价/订单）
    └─ base_price → 变体基础价（定价引擎的基准）

L6(SKU实例) ──→ 报价行项目/订单行项目中的具体实例
    └─ variant_id → 指向 L5 变体
    └─ quantity → 数量
    └─ final_price → 经定价引擎计算后的最终价格
```
