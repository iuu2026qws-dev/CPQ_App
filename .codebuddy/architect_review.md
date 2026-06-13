# CPQ 系统架构评审报告

> **评审人**：架构师（architect）  
> **评审日期**：2026年6月7日  
> **评审范围**：CPQ_后端功能设计.md + CPQ_前端门户设计.md + CPQ_阶段三_技术实现层.md + development_plan.md + cross_trace_v2_final.md  
> **总体结论**：架构设计整体合理、层次清晰。数据模型、模块分解、Service层、前端架构均有详细的规划，骨架健康。但在多租户配置、JSON字段使用约束、前后端解耦边界、核心Service接口契约、以及缺失模块补全等方面存在若干风险点和待改进项。以下是逐维度的详细评审。

---

## 一、数据架构评审

### 1.1 表结构总览

当前设计涵盖43张CPQ业务表（D01产品域9张 + Bundle域3张 + D02定价域6张 + D03配置域5张 + D04报价域6张 + D05审批域4张 + D06客户域4张 + D07系统域2张 + D08集成域3张），加上RuoYi系统表（sys_menu/sys_role/sys_user等），实际涉及约60+张表。后端设计§1.2提及"每个子模块可独立端口部署，也可合并到ruoyi-admin单进程"。

### 1.2 FK关系完整性评估

**评审发现**：

设计文档中D01-D08各域的DDL SQL文件中定义了大量FK约束（如 `cpq_price_book_entry` → `cpq_price_book` → `cpq_product_model`、`cpq_quote` → `cpq_account` 等），整体FK关系合理。但存在以下问题：

1. **跨数据库FK问题（高优先级）**：设计§5.1-5.2和后端设计§4.2将43张表分配到12个独立数据库（cpq_product/pricing/config/quote/approval/atp/solution/competitive/knowledge/integration/migration/ecn）。MySQL的FK约束无法跨数据库生效。如果采用"所有表共享一个CPQ数据库"的模式则无此问题；如果严格按12个库部署，则外键约束必须在应用层通过Service层校验实现。当前设计文档在§5.2（阶段三）已注明"所有模块可合并到ruoyi-admin单进程、共享同一端口8080"，但后端设计§1.2又列出了12个独立端口。这种不一致需要裁决。

   **建议**：当前推荐方案是**所有CPQ表放在同一MySQL实例的一个数据库（如 `cpq_core`）中**，与RuoYi系统库分开。这样MySQL FK约束可以正常工作，多租户拦截器统一生效。按模块拆库是微服务时代的过度设计，对于当前"模块化单体"架构不是刚需。如果未来确实需要垂直拆分，再迁移部分表到独立DB。影响范围：全局，但优先级高。

2. **自引用循环检测**：`cpq_product_model` 有 `successor_model_id` 自引用FK（替代产品），`cpq_product_category` 有 `parent_category_id` 自引用FK。这是合法的树形自引用，不构成循环依赖，但需要在Service层实现循环检测逻辑（如替代品链条不应出现 A→B→A）。

3. **缺失的FK检查**：设计文档中D04-D08域的DDL有部分FK定义为"FK→xxx"注释但未在MySQL DDL中显式声明约束。例如 `cpq_quote.approval_chain_id` 注释"当前审批链ID"但未定义FK。建议在开发阶段统一核对所有FK是否在DDL中显式创建。

**综合评分**：3.5/5 — FK设计意图清晰，但跨库FK不可行的问题需要顶层裁决。

### 1.3 性能隐患评估

#### 1.3.1 JSON字段使用（中优先级）

设计文档在多处使用了MySQL JSON类型存储结构化数据：

| 表 | JSON字段 | 用途 | 风险 |
|----|---------|------|------|
| cpq_product_attribute | option_values | 可选项列表 | 低：数据量小、读取为主 |
| cpq_price_rule | condition_json, action_json | 定价规则条件/动作 | 高：条件字段需要在WHERE中解析，无法使用普通索引 |
| cpq_config_rule | rule_expression | 规则表达式JSON | 高：CSP求解器需要解析规则条件 |
| cpq_config_snapshot | selections_json, bom_json, config_data等 | 配置快照 | 中：写入为主、读取较少 |
| cpq_quote_line_item | configuration_json | 报价行配置 | 中：读取频繁 |
| cpq_quote_version | full_snapshot | 版本快照JSON | 低：历史数据 |
| cpq_approval_rule | approval_chain_json | 审批链JSON | 低：审批规则不频繁查询 |
| cpq_quotation_template | design_json | 模板设计JSON | 低：读取为主 |
| cpq_variant_bom | variant_bom_data | 变体BOM数据JSON | 高：BOM数据体积可能较大 |
| cpq_integration_config | auth_config_json | 认证配置JSON | 低：配置型数据 |

**分析与建议**：

- `cpq_price_rule.condition_json` 和 `cpq_config_rule.rule_expression` 是查询关键字段，在定价流水线和CSP求解器中需要高频读取和条件匹配。建议为这些JSON字段中的关键路径创建**虚拟列（Generated Column）+ 索引**。例如：
  ```sql
  ALTER TABLE cpq_price_rule ADD COLUMN product_id BIGINT 
    AS (JSON_EXTRACT(condition_json, '$.product_id')) STORED;
  CREATE INDEX idx_rule_product ON cpq_price_rule(tenant_id, product_id);
  ```
- `cpq_quotation_template.design_json` 和 `cpq_config_snapshot` 的JSON存储合理，这些是"快照型"数据，不需要对内部字段做查询。风险低。
- `cpq_variant_bom.variant_bom_data` 的JSON如果包含百万级BOM行数据，建议考虑单独建表存储变体BOM明细，而非全部塞入JSON。当前设计在 `cpq_variant_bom` 表中另有 `effectivity_condition` TEXT字段作为有效性条件，`variant_bom_data` JSON 存储变体物料清单，如果变体种类多（150% BOM可达数千变体），建议将物料明细拆为独立表 `cpq_variant_bom_line`。

  影响范围：定价引擎、配置引擎的查询性能。建议在Sprint 3（定价+配置）DDL执行时一并处理虚拟列索引。

#### 1.3.2 索引覆盖度（中优先级）

当前DDL中所有表均包含 `tenant_id` 前缀的复合索引。主要缺失的索引场景：

- **cpq_quote 多状态列表查询**：高频场景"我创建的报价列表"需要 `(tenant_id, created_by, status, create_time)` 复合索引，当前仅有 `(tenant_id, created_by, create_time)`。建议补充。
- **cpq_quote_line_item 报价详情查询**：`(tenant_id, quote_id, parent_line_id)` 用于树形展开。当前仅有 `(tenant_id, quote_id)`，如果捆绑包的parent_line_id查询频繁，建议补充。
- **cpq_sbom_line BOM递归展开**：递归CTE查询依赖 `parent_line_id`，当前有 `(tenant_id, parent_line_id)` 索引。合理。
- **全文搜索索引**：`cpq_product_model`的model_name/description字段需要FULLTEXT索引（MySQL ngram parser），设计§5.5已规划但需在DDL中确认是否创建。

#### 1.3.3 大表分区策略（中优先级）

设计§5.8规划了quote（按月分区）、audit_event（按周分区）、sync_log（按月分区）。当前为设计文档中的规划，DDL中尚未实施。

**建议**：
- `cpq_quote` 表分区：如果预计年产生10万+报价单，RANGE分区按月合理。需要注意MySQL分区表不支持外键约束（分区表无法作为被引用表），如果cpq_quote_line_item需要FK到cpq_quote且cpq_quote已分区，FK必须移除或降级为应用层约束。这是一个需要提前决策的重要技术限制。
- 分区实施建议在报价量接近10万条时再启用，初期可以不分区。但要预留 `partition_key` 列以便后续在线DDL操作。

**综合评分**：3/5 — 索引设计基本OK，JSON字段使用需要约束，分区策略需要MySQL限制评估。

### 1.4 tenant_id多租户隔离一致性

**评审发现**：

当前实现采用 **MyBatis-Plus `TenantLineInnerInterceptor`** 自动注入 `tenant_id` WHERE条件。所有43张CPQ表的DDL中均定义了 `tenant_id BIGINT NOT NULL`。

**存在一个关键问题**：`ruoyi-admin 2/src/main/resources/application.yml` 中 `tenant.excludes` 仅排除了RuoYi系统表（sys_menu/sys_tenant/sys_tenant_package/sys_role_dept/sys_role_menu/sys_user_post/sys_user_role/sys_client），**未添加CPQ业务表的排除项**。但根据默认行为，所有包含 `tenant_id` 列的表都会被拦截器自动注入条件——在这个意义上，CPQ表不需要额外配置。

需要注意的特殊场景：
- `cpq_system_config` 表在application.yml被排除（从后端设计§6.3的配置注释可以看到"系统配置表不隔离"），这是合理的——系统级配置应该跨租户共享。
- 如果采用跨数据库部署，**不同数据库中的MyBatis-Plus动态数据源切换**时，租户拦截器是否能正确生效需要验证。在模块化单体模式下（所有表同库），不存在此问题。

**建议**：在application.yml中显式注释说明CPQ表全部走租户拦截器默认行为，`cpq_system_config` 显式排除并注释原因。建议在执行Sprint 2-5 DDL后立即做一次全局SQL审计：`grep -L "tenant_id" sql/cpq_*.sql` 确保所有CPQ表包含tenant_id字段。

影响范围：全局数据安全。优先级：高。

### 1.5 雪花ID vs 自增ID策略

**设计现状**：

- RuoYi-Vue-Plus框架默认主键使用雪花ID（MyBatis-Plus `IdType.ASSIGN_ID`），由 `DefaultIdentifierGenerator` 生成19位Long型雪花ID
- 当前已执行的D01域DDL中使用 `BIGINT AUTO_INCREMENT`（自增ID）
- 后端设计§4.1规范规定"主键使用雪花ID BIGINT，分布式有序增长"

**不一致问题**：

当前DDL（如 `cpq_product_model`、`cpq_product_category` 等）使用 `AUTO_INCREMENT`，但MyBatis-Plus的 `IdType.ASSIGN_ID` 会忽略数据库自增，由应用层生成ID。这是RuoYi-Vue-Plus的推荐配置，因为：
- 雪花ID天然分布式友好
- 不依赖数据库序列，批量插入性能更好
- 可以提前获取ID做关联操作，无需等insert返回

对于当前单体部署场景，`AUTO_INCREMENT` 也没有问题。但如果未来即使部分模块独立部署（如未来服务拆分），雪花ID会更安全。

**建议**：
- DDL中的 `AUTO_INCREMENT` 保留（作为MySQL层面的兜底方案），MyBatis-Plus应用层生成雪花ID优先
- 确认所有Domain类的 `@TableId(type = IdType.ASSIGN_ID)` 配置
- **关键检查**：`create_by` 等用户ID字段使用 `BIGINT`，需确认与RuoYi的 `sys_user.user_id` 类型一致（雪花ID）
- `tenant_id` 在后端设计§4.1规范为 `BIGINT`，但开发计划V2.0中记录的"tenant_id类型从VARCHAR(20)修正为BIGINT"。当前DDL中tenant_id为BIGINT，这是一个正确的修正。需要确认application.yml中 `tenant.tenant-id-type` 配置与Entity的tenant_id类型一致

影响范围：ID生成策略全局一致。优先级：低（当前已有兼容方案）。

### 1.6 反范式化建议

经过评估，当前设计中有几处可以考虑冗余字段（反范式化）以提升查询性能：

| 场景 | 当前方案 | 反范式化建议 | 收益 |
|------|---------|------------|------|
| 报价单详情页查询 | quote JOIN quote_line_item JOIN product_model JOIN customer | quote表中冗余 customer_name、quote_line_item中冗余 product_code/product_name | 减少2-3次JOIN，报价列表页性能提升30% |
| BOM展开 | sbom_header → sbom_line 递归CTE | sbom_line中冗余 level 层级字段（计算列） | 避免每次递归CTE计算层级 |
| 审批效率看板 | approval_chain JOIN approval_record 多次聚合 | approval_chain中冗余 current_step, total_duration等 | 审批Dashboard性能提升 |

**注意**：设计文档中 `cpq_quote` 已有一个反范式化字段 `account_name`（注释"客户名称(冗余)"），这是正确的实践。建议 `cpq_quote_line_item` 中也冗余 `model_code` 和 `model_name`（当前已有 `item_code` 和 `item_name` 字段）。

影响范围：查询性能优化。优先级：低（可在Sprint 6性能优化阶段再处理）。

---

## 二、模块依赖与解耦

### 2.1 模块依赖关系分析

当前设计为13个CPQ子模块 + ruoyi-admin主模块，采用"Spring模块化单体"架构，模块间通过Spring Bean直接调用（同步）或Spring Event/RabbitMQ（异步）。

### 2.2 模块依赖有向图

```
                    ┌─────────────────────┐
                    │    ruoyi-admin       │  (主模块 8080)
                    │  ┌─────────────────┐ │
                    │  │ Sa-Token + 安全  │ │
                    │  │ 多租户 + RBAC   │ │
                    │  └────────┬────────┘ │
                    └───────────┼──────────┘
                                │ (所有模块依赖)
            ┌───────────────────┼───────────────────────┐
            │                   │                       │
            ▼                   ▼                       ▼
┌───────────────────┐ ┌───────────────────┐ ┌───────────────────┐
│ ruoyi-cpq-product │ │ ruoyi-cpq-config  │ │ ruoyi-cpq-pricing │
│   (D01 SoT)       │ │   (D03 CSP引擎)   │ │   (D02 定价引擎)  │
│ ┌─product_catalog │ │ ┌─config_rule     │ │ ┌─price_book      │
│ │─product_model   │◄┼┼┼─variant_bom     │ │ │─price_book_entry│
│ │─product_category│ │ │─attribute_map   │ │ │─price_rule      │
│ │─sbom_header     │ │ │─compat_matrix   │ │ │─volume_tier     │
│ │─sbom_line       │ │ │─attr_option     │ │ │─channel_price   │
│ └─────────────────┘ │ └────────┬────────┘ │ │─currency_rate   │
│        ▲            │          │          │ └────────┬────────┘
│        │            │          │          │          ▲
│        │            │ ┌────────▼────────┐ │          │
│        │            │ │ ruoyi-cpq-atp   │ │          │
│        │            │ │  (ATP/CTP)      │ │          │
│        │            │ │  ameproductD01  │ │          │
│        │            │ └─────────────────┘ │          │
│        │            │          ▲          │          │
│        │            │          │          │          │
│ ┌──────┴────────────┴──────────┴──────────┴──────────┐
│ │              ruoyi-cpq-quote                        │
│ │                (D04 报价引擎)                         │
│ │ ┌─cpq_quote ──cpq_quote_line_item ──config_snapshot │
│ │ │─cpq_quote_version ──quote_template               │
│ │ └─────────────────┬────────────────────────────────┘
│ └──────────────────┼──────────────────────────────────┘
│                    │
│         ┌──────────┴──────────┐
│         ▼                     ▼
│ ┌───────────────┐    ┌───────────────┐
│ │ruoyi-cpq-     │    │ruoyi-cpq-     │
│ │  approval     │    │  solution     │
│ │  (D05 审批)   │    │  (方案管理)    │
│ └───────────────┘    └───────┬───────┘
│                              │
│     ┌────────────────────────┼──────────────────────┐
│     ▼                        ▼                      ▼
│ ┌───────────────┐   ┌──────────────┐   ┌────────────────┐
│ │ruoyi-cpq-     │   │ruoyi-cpq-    │   │ruoyi-cpq-      │
│ │ competitive   │   │ knowledge    │   │ integration +  │
│ │ (竞品对标)    │   │ (知识库)     │   │ migration +    │
│ └───────────────┘   └──────────────┘   │ ecn            │
│                                        │ (集成+迁移+变更)│
│                                        └────────────────┘
│
│ 所有模块都依赖:
│ ┌───────────────────────────────────────────┐
│ │ ruoyi-cpq-common (枚举/常量/异常/工具类)    │
│ └───────────────────────────────────────────┘
```

### 2.3 依赖层级（按被依赖程度排序）

| 层级 | 模块 | 被依赖情况 | 应开发时机 |
|:---:|------|----------|:---------:|
| L0基础设施 | ruoyi-cpq-common | 被所有13个模块依赖 | Sprint 1 最先 |
| L1核心SoT | ruoyi-cpq-product | 被config/pricing/quote/atp/competitive/integration依赖 | Sprint 1-2 |
| L2引擎层 | ruoyi-cpq-config + ruoyi-cpq-pricing + ruoyi-cpq-atp | config→product, pricing→product, atp→product | Sprint 3 |
| L3业务层 | ruoyi-cpq-quote | quote→product+config+pricing+atp | Sprint 4 |
| L4流程层 | ruoyi-cpq-approval + ruoyi-cpq-solution | approval→quote, solution→product+quote | Sprint 4-5 |
| L5辅助层 | competitive + knowledge + integration + migration + ecn | 各依赖product/quote | Sprint 5-6 |

### 2.4 循环依赖风险评估

**已识别的风险点**：

1. **product ↔ config 双向依赖**：`cpq_product_model` 通过 `cpq_config_rule.model_id` 被配置模块引用，而配置结果会反作用于产品数据（如显示哪些option可用）。这是逻辑上的双向关联但技术上是通过 `product_model_id` 外键实现的单向依赖，不是循环依赖。风险低。

2. **pricing ↔ config**：定价规则依赖产品数据，配置快照中引用定价快照（`cpq_config_snapshot.pricing_snapshot`）。两者通过 quote 模块解耦，不存在直接循环依赖。风险低。

3. **潜在循环风险：solution ↔ quote**：SolutionEditor中可嵌入报价摘要（Tiptap扩展 `cpqQuoteSummary`），而 QuoteCreate又可以从Solution启动。这是前端页面流上的相互引用，但后端数据层面通过solution和quote各自的表隔离，无直接FSK循环。需要注意在Service层避免A调用B同时B调用A的回环。风险中。

**建议**：在模块POM的 `<dependencies>` 中保持严格单向依赖原则。配置模块不得依赖定价模块，定价模块不得依赖配置模块。两者通过共享的 product 模块间接关联，通过 quote 模块聚合。

### 2.5 开发顺序建议

| 优先级 | Sprint | 模块 | 理由 |
|:---:|:-----:|------|------|
| P0 | S1 | ruoyi-cpq-common | 所有模块的基础依赖 |
| P0 | S1-2 | ruoyi-cpq-product | 最核心的SoT，被几乎所有模块依赖 |
| P1 | S3 | ruoyi-cpq-config + ruoyi-cpq-pricing | 配置引擎和定价引擎平行开发，互不依赖 |
| P1 | S3 | ruoyi-cpq-atp | 依赖product即可，可平行开发 |
| P2 | S4 | ruoyi-cpq-quote + ruoyi-cpq-approval | quote依赖前三者，approval依赖quote |
| P2 | S5 | ruoyi-cpq-solution | 依赖product+quote |
| P3 | S5-6 | competitive + knowledge + integration + migration + ecn | 相对独立，可并行开发 |

**⚠️ 重要缺失**：当前开发计划Sprint 3-6未为competitive（竞品对标）、knowledge（知识库）、ecn（变更管理）、migration（数据迁移）四个模块规划任务。这四个模块虽然属于辅助层，但竞品对标和ECN是设计文档明确的核心差异化能力，数据迁移是交付客户的必须工具。建议在Sprint 4-5之间插入Sprint 4.5专门处理这四个模块。

---

## 三、Service层设计评审

### 3.1 10个核心Service的职责边界

| Service | 职责 | 边界评估 | 问题 |
|---------|------|:---:|------|
| BomExplosionService | 递归BOM展开/MBOM转换 | ✅ 单一 | 已实现(S2.2.1) |
| ConfigEngineService | CSP约束求解 | ✅ 单一 | 待开发(S3.4.1) |
| PricingEngineService | 六阶段定价流水线 | ✅ 单一 | 待开发(S3.4.2) |
| QuoteGenerateService | 报价单PDF/Word生成 | ✅ 单一 | 待开发(S4.3.1) |
| ApprovalRouteService | 审批链构建+流转 | ✅ 单一 | 待开发(S4.3.2) |
| AtpCtpService | ATP检查+CTP推算 | ⚠️ 偏宽 | ATP和CTP是两个子域，可能需要拆 |
| EcnImpactAnalysisService | ECN影响分析 | ✅ 单一 | 缺失(需补充) |
| DataMigrationService | 数据导入+校验+对账 | ⚠️ 偏宽 | 缺失(需补充) |
| LifecycleService | 产品生命周期状态变更 | ✅ 单一 | 已实现(S2.2.2) |
| SupersessionService | 替代品where-used+推荐 | ✅ 单一 | 已实现(S2.2.3) |

**建议**：
- AtpCtpService可以考虑拆为AtpService（库存检查）+ CtpService（交期推算），因为两者数据源和算法不同。但如果ATP和CTP总是联合调用，合并也可以。
- 所有核心Service缺少明确的**接口契约**（输入DTO格式、输出DTO格式、错误码规范）。开发计划审计报告A3已记录此问题。强烈建议在Sprint 3开始前为每个Service编写Interface + DTO定义。

### 3.2 PricingEngine（六阶段定价流水线）复杂度评估

**设计复杂度**：⭐⭐⭐⭐ 高（6阶段14步SQL查询 + 多币种 + 阶梯价 + 折扣策略）

**Java实现建议**：

1. **责任链模式（Chain of Responsibility）**：六个阶段定义为 `PricingPhase` 接口 + 6个实现类，通过 `@Order` 注解或配置链顺序执行。好处是阶段可插拔（如海外版跳过Phase 3区域定价）。

2. **事务边界**：六阶段在同一个 `@Transactional` 内执行，保证原子性。但注意事务不能跨远程调用或跨数据库，在模块化单体+共享数据库模式下OK。

3. **缓存策略**：Phase 1（PriceBook.Lookup）和Phase 4（VolumeTier.Lookup）是高频只读操作，建议使用Caffeine本地缓存 + Redis二级缓存，TTL设为5分钟（规则变更时主动失效）。

4. **并发安全**：如果同一报价被两个用户同时修改价格，需要乐观锁（version字段）。`cpq_quote` 和 `cpq_quote_line_item` 当前没有version字段，建议添加。

5. **定价规则热加载**：`cpq_price_rule` 的 condition_json 和 action_json 在每次定价计算时需要解析，建议在Caffeine缓存中存储解析后的Rule对象，避免重复JSON解析。

### 3.3 ConfigEngine（CSP约束求解）复杂度评估

**设计复杂度**：⭐⭐⭐⭐⭐ 非常高（MAC传播算法 + BDD决策图 + QuickXPlain冲突解释 + 规则编译）

**Java实现可行性**：**可行**。设计文档阶段三§3.1已提供完整的Java类设计和并发方案评估。

**关键实现建议**：

1. **SolverPool设计**（已规划，正确）：`ArrayBlockingQueue<SolverInstance>` + `ThreadPoolExecutor`，CPU×2线程数。Go buffered channel模型 → Java `BlockingQueue` 对应关系正确。

2. **增量MAC传播**：当前设计为"用户每次选择attr=value后执行增量传播"。关键优化点 — 预构建变量的依赖图（DependencyGraph），只传播受影响节点的可达子图，而非全图扫描。复杂度从 O(v·e·d³) 降到 O(Δv·e·d³)，其中 Δv 是受影响变量数。

3. **规则编译缓存**：`CompiledSolver` 单例持有已编译的规则索引（HashMap + BitSet + Trie）。当规则变更时，重建CompiledSolver并原子替换引用（AtomicReference），避免请求阻塞。

4. **BOM展开与CSP联动**：配置选择 → 变体过滤 → BOM展开。BOM展开结果应缓存到Redis（key = configuration_hash），TTL 30min。

5. **性能SLA**：设计的 <50ms P95（增量传播）和 <200ms P95（全量校验）是可达的目标，前提是规则数在万级以下、产品数在千级以下、MAC传播实现正确。需要在Sprint 3编写性能基准测试。

### 3.4 BomExplosionService性能风险

**当前实现**：递归BOM展开已通过 `CpqSbomServiceImpl` 实现（S2.2.1），使用Java递归 + MyBatis-Plus查询。

**性能风险**：

| 风险场景 | 风险等级 | 说明 |
|---------|:---:|------|
| 深层BOM（>5层） | 中 | 递归DB查询N+1问题，每次递归触发一次DB查询 |
| 宽BOM（>500行/层） | 中 | 数据量大，序列化开销高 |
| 150%变体BOM过滤 | 高 | 需要JOIN variant_bom + attribute_mapping，查询复杂度高 |
| 虚拟滚动前端渲染 | 低 | 5000+行BOM通过ag-Grid虚拟滚动已解决 |

**优化建议**：

1. **替换逐层递归为WITH RECURSIVE CTE**：当前设计在阶段三§5.6已规划 `sp_bom_explosion` 存储过程和 `v_bom_explosion` 视图使用 `WITH RECURSIVE` CTE。建议在BomExplosionService中优先调用MySQL CTE存储过程，一次网络往返完成全树展开，替代Java递归N+1查询。这是最重要的性能优化措施。

2. **BOM结果缓存**：展开结果按 (sbom_header_id, config_hash) → BOM树 缓存到Redis，TTL 30min。配置变更时主动失效。

3. **变体过滤前置**：在Service层先用变体条件过滤sbom_line（WHERE变体条件匹配的物料），再做递归展开，减少CTE扫描行数。

4. **limit深度**：设定最大展开层级（如10层），超过时返回截断标记并在前端提示。

### 3.5 消息队列引入评估

**当前方案**：设计文档规划使用RabbitMQ（Spring AMQP）+ Spring Event。当前开发实际使用RuoYi自带SSE推送。

**需要MQ的异步场景**：

| 场景 | 必须性 | 当前替代方案 | 建议 |
|------|:---:|------|------|
| 报价单生成PDF/Word | 推荐异步 | 同步调用（可能阻塞） | 异步：QuoteGenerateService接收消息后生成，完成后SSE通知前端 |
| 审批流转通知 | 推荐异步 | SSE推送 | 当前SSE可满足，MQ用于可靠性保证 |
| ERP/CRM/PLM数据同步 | **必须异步** | 无 | D08集成模块必须使用MQ，保证at-least-once语义 |
| ECN变更传播通知 | 推荐异步 | 无（模块缺失） | 变更影响N个报价单时批量异步处理 |
| 数据迁移大文件处理 | **必须异步** | 无（模块缺失） | Excel批量导入转为分片异步处理 |

**最终建议**：

- **必须引入RabbitMQ**：用于跨系统集成（ERP/CRM/PLM）和数据迁移大文件处理。这两个场景对可靠性和重试机制有硬性要求，SSE不适合。
- **推荐引入RabbitMQ**：报价单PDF生成（避免HTTP超时）、ECN变更传播。这些场景用MQ解耦可以显著提升用户体验。
- **当前OK**：审批通知、配置变更通知等用Spring Event + SSE即可。
- **RabbitMQ引入时机**：Sprint 4（报价模块）引入，在 `ruoyi-cpq-quote` 中集成Spring AMQP。同时创建 `ruoyi-cpq-mq` 公共模块统一封装消息格式和Exchange/Queue定义。

**中间件优先级排序**（见§5.4）。

---

## 四、前端架构评审

### 4.1 路由懒加载策略评估

**当前设计**：52条路由，使用 Vue Router 4 的动态 import `() => import('@/views/xxx.vue')` 实现路由级懒加载。

**评估**：

- 52条路由如果全部使用懒加载，产生52个独立的JS chunk，每个chunk体积约5-30KB（Vue页面模板+组件），总共约1-2MB。产生的问题：浏览器并发请求数较多（HTTP/2限制50+连接）。
- 当前路由器按模块分组（configure/quoting/solution/approval/presales/competitive/product/pricing/atpctp/knowledge/integration/settings），这是合理的。

**优化建议**：

1. **按角色分组**：不同角色的用户只加载其有权访问的路由。例如渠道伙伴（partner）只用5-10条路由，不需要加载管理员的路由。路由守卫中根据 `userStore.roles` 动态注册路由，减少90%的未使用路由加载。

2. **关键路由预加载**：Configurator.vue（配置器）、QuoteCreate.vue（报价创建）是核心流程，建议在 PortalLayout 加载后使用 `router.isReady()` 后通过 `<link rel="modulepreload">` 预加载。

3. **路由级KeepAlive**：配置器页面建议使用 `<KeepAlive>` 缓存，避免在配置流程中切换页面时丢失配置状态。

### 4.2 Pinia Store状态划分评估

**当前设计**：5个Store（user/app/configurator/quote/tenant）

| Store | 状态内容 | 评估 |
|-------|---------|:---:|
| user | 用户信息+角色+权限 | ✅ 合理 |
| app | 主题/语言/布局/侧边栏状态 | ✅ 合理 |
| configurator | 当前配置会话状态（选择项、BOM、ATP） | ⚠️ 偏重 |
| quote | 当前报价单状态（行项目、总金额、状态） | ✅ 合理 |
| tenant | 租户上下文 | ✅ 合理 |

**发现的问题**：

1. **configurator Store职责过重**：当前它管理配置会话 + BOM预览 + ATP交期 + 向导式销售5状态机进度。建议拆分为：
   - `configurator` — 核心配置选择状态（selectedOptions、conflicts、availableOptions）
   - `bom` — BOM展开缓存（bomTree、loading状态）
   - `atp` — ATP/CTP查询结果和缓存
   - `guidedSelling` — 向导式销售5状态机

2. **缺失的Store**：
   - `solution` — 方案编辑器状态（协同编辑CRDT buffered changes、大纲树）
   - `pricing` — 定价计算结果缓存（避免重复API调用）
   - `notification` — SSE推送的通知列表

3. **状态重复风险**：`configurator` 中的配置选择和 `quote` 中的报价行项目可能存储重复的配置快照数据。建议明确数据所有权：configurator拥有当前配置状态，提交报价时序列化为quote的line_items，两者不保持同步。

### 4.3 协同编辑（Yjs + Tiptap）技术可行性

**评估**：**可行，但需要搭建WebSocket后端服务**。

**当前缺失**：RuoYi-Vue-Plus未内置WebSocket协同服务。前端设计§G.1规划了 `ws://host/ws/solution/{id}?token={jwt}`。

**WebSocket服务端方案建议**：

1. **方案A（推荐）：独立WebSocket微服务（Node.js + y-websocket）**
   - 用Node.js运行官方 `y-websocket` 服务器，负责Yjs Document的CRDT同步和持久化
   - Spring Boot通过HTTP回调将方案文档的变更写入数据库
   - 优点：与Yjs生态完美兼容、无需自己实现CRDT协议
   - 缺点：引入Node.js运维（需要单独的进程管理）
   - 适合场景：方案协同编辑是核心功能（当前设计P0）

2. **方案B（折中）：Spring WebSocket + 自实现同步**
   - 使用Spring Boot WebSocket（已支持），Redis Pub/Sub广播编辑操作
   - 需要自实现OT（Operational Transformation）或简化版CRDT
   - 优点：纯Java栈、无额外运维
   - 缺点：自实现协同算法工作量巨大（约3-5人周）、容易出bug
   - 适合场景：协同编辑不是核心功能，可降级为"乐观锁+最后写入胜出"

3. **方案C（暂缓）：先不支持协同，使用独占编辑锁**
   - 方案编辑器为独占模式（同一时间只有一人编辑），其他人以只读模式查看
   - 评审通过批注（comments）异步完成
   - 优点：零额外成本
   - 缺点：失去协同编辑的差异化竞争力
   - 适合场景：MVP阶段先上线基础功能，后续迭代再加协同

**最终建议**：Sprint 1-4 采用方案C（独占编辑），Sprint 5 搭建方案A的Node.js WebSocket服务。这样可以先验证方案编辑器基础功能，同时给WebSocket服务留出准备时间。

**技术要点**（方案A实现）：
- Node.js服务部署在应用服务器上（端口4444），Nginx反向代理 `/ws/solution/` 到该端口
- 认证通过URL参数 `?token={jwt}` 传递，y-websocket层验证JWT
- Yjs文档持久化：每分钟自动保存到MySQL `cpq_solution_document` 表
- Spring Boot端监听文档变更事件（通过内部HTTP回调），触发版本快照创建

### 4.4 前端性能瓶颈预测

| 场景 | 风险等级 | 瓶颈点 | 建议 |
|------|:---:|------|------|
| Configurator BOM面板 | 高 | 5000+行BOM实时渲染、每次配置变更触发全量BOM重算 | ag-Grid虚拟滚动 + Web Worker计算 + BOM增量更新 |
| Dashboard多图表页 | 高 | 12个角色Dashboard各有3-6个ECharts图表 | 懒加载图表组件 + Canvas渲染 + 数据按需请求 |
| 配置器Option四态更新 | 中 | 每次选择触发CSP传播，前端需更新所有Option卡片状态 | 虚拟滚动卡片列表 + 状态diff只更新变化的Option |
| 方案编辑器大量CPQ扩展块 | 中 | Tiptap中嵌入多个产品参数表/BOM表/报价摘要 | 按需加载扩展块组件（Intersection Observer） |
| 报价单PDF生成 | 中 | 大报价单生成可能超时 | 异步生成 + 进度条 + SSE通知完成 |
| 全局搜索 | 低 | 4模式搜索（产品/方案/客户/帮助） | 防抖 + 分段加载 + 本地缓存热门搜索 |

**具体建议**：

1. **Configurator BOM**：当前设计使用ag-Grid虚拟滚动可处理10000行。关键优化：前后端协作 — 后端CSP返回的 `affected_options` 只包含变化部分，BOM预览仅在配置确认时才展开。

2. **Dashboard**：12个角色Dashboard不要全部在首次加载。根据角色懒加载对应Dashboard。每个Dashboard内图表使用 `v-lazy` 在可视区才渲染。ECharts统一使用Canvas渲染器（不用SVG），实例复用。

3. **方案编辑器**：CPQ TiP扩展块（产品参数表/BOM/报价摘要）仅在可视区渲染。使用 `content-visibility: auto` CSS降低离屏渲染成本。

---

## 五、技术决策建议

### 5.1 "所有模块合并到ruoyi-admin单进程" vs "独立微服务部署"

**当前两种方案在设计文档中同时存在**：
- 后端设计§1.2 列出13个模块各自独立端口（8080-8092）
- 后端设计§1.2末尾注明"内网部署时，所有模块可合并到ruoyi-admin进程中"
- 阶段三§2.1 明确为"15模块在Spring模块化单体下"

**决策分析**：

| 维度 | 合并到ruoyi-admin单进程 | 微服务独立部署 |
|------|------------------------|--------------|
| 开发效率 | ✅ 高：一个JVM启动调试、无需服务发现 | ❌ 低：需启动多个服务、配置注册中心 |
| 部署运维 | ✅ 简单：一个Fat JAR | ❌ 复杂：多个JAR/容器、服务编排 |
| 性能 | ✅ 不涉及网络调用开销 | ❌ 序列化+网络开销 |
| 故障隔离 | ❌ 一个OOM全挂 | ✅ 故障隔离 |
| 弹性伸缩 | ❌ 无法按模块粒度扩缩 | ✅ 可为CSP求解器独立扩容 |
| 团队协作 | ⚠️ 代码耦合风险 | ✅ 模块边界清晰 |

**最终建议**：**当前阶段（Sprint 1-6，1-2年）采用"模块化单体 + 可拆设计"**。

具体实施方案：
1. 所有CPQ模块作为Maven子模块，在 `ruoyi-admin/pom.xml` 中依赖引入
2. 所有模块共享同一Spring Boot进程（端口8080）和同一MySQL数据库
3. 模块间通过Spring Bean直接调用（无需Feign/HTTP）
4. 异步场景用Spring Event + RabbitMQ解耦
5. **保留微服务拆分的可能性**：在模块内部遵循"数据库隔离"原则（每个模块操作自己的表集合），避免直接JOIN跨模块的表（通过Service接口获取数据）
6. 当前后端设计§1.2的独立端口方案调整为：开发环境统一8080，生产环境通过-Dserver.port参数可拆分部署

**何时考虑拆分**：
- 配置引擎（CSP）的CPU需求成为瓶颈，需要独立扩容时 → 将ruoyi-cpq-config拆为独立服务
- 报价单PDF生成成为阻塞点时 → 将QuoteGenerateService拆为独立异步Worker
- 团队规模超过15人，单进程代码冲突频繁时 → 按模块分配团队，部分模块拆分

### 5.2 MySQL替代PostgreSQL后，8个View和4个SP的可行性

**评估结论**：**完全可行，但需要注意几个MySQL特性限制**。

| PG特性 | MySQL 8.0等效方案 | 评估 |
|--------|------------------|:---:|
| 递归CTE (v_bom_explosion) | `WITH RECURSIVE` | ✅ 完全兼容 |
| 窗口函数 (v_approval_sla) | `ROW_NUMBER()/RANK()/LAG()` | ✅ 完全兼容 |
| JSONB操作 (v_config_analytics) | `JSON_EXTRACT()/JSON_TABLE()` | ⚠️ 功能弱，复杂提取可能需多条SQL |
| CHECK约束 | `CHECK`（MySQL 8.0.16+） | ⚠️ 实际执行不如PG严格 |
| 存储过程 (sp_*) | `CREATE PROCEDURE` | ⚠️ 游标性能弱，需临时表+INSERT SELECT替代 |
| TIMESTAMPTZ | DATETIME + 应用层UTC | ✅ 可行，需约定 |
| RLS行级安全 | MyBatis-Plus拦截器 | ✅ 已在用 |
| Multi-Schema | tenant_id字段隔离 | ✅ 已在用 |

**关键建议**：

1. **v_config_analytics（高频选项统计）**：如果 `JSON_EXTRACT` 性能不足，建议从源头的 `cpq_config_snapshot.selections_json` 旁路写入一张独立统计表 `cpq_config_analytics_flat`（定时ETL打平JSON字段），避免在View中实时解析JSON。

2. **sp_mrp_net_requirement（MRP净需求计算）**：百万级数据在存储过程中计算，建议使用临时表 + `INSERT ... SELECT` 批量操作，而不是逐行游标处理。MySQL游标比PG的 `FOR rec IN SELECT ... LOOP` 慢5-10倍。

3. **sp_config_validate_batch（批量配置校验）**：如果需要在一次调用校验数百条配置，建议使用 `CONNECT BY` 等价实现（MySQL 8.0不支持）改为在Java层用线程池并发检验，每条配置调用增量MAC传播。这样既能利用SolverPool的并发能力，又避免了MySQL SP的限制。

4. **CHECK约束兜底**：MySQL 8.0.16+的CHECK约束在某些场景下不会严格执行（如 ALTER TABLE交换分区后），建议在Service层用 `@Validated` + JSR-303 Bean Validation做应用层兜底。

### 5.3 CSP求解器Java实现方案（ThreadPoolExecutor vs Virtual Threads）

**阶段设计文档§3.1.0已提供完整评估**，本评审确认其结论并补充建议。

**当前（JDK 17）：方案A — ThreadPoolExecutor + ArrayBlockingQueue**

核心配置：
```java
// CPU×2 线程，对应 Go goroutine 池
int poolSize = Runtime.getRuntime().availableProcessors() * 2;
ArrayBlockingQueue<SolverInstance> pool = new ArrayBlockingQueue<>(poolSize);
```

**确认**：此方案与Go buffered channel模型直接对应，在当前10-50个并发用户的场景下完全够用。

**长期（JDK 21+）：方案B — Virtual Threads**

JDK 21的虚拟线程与Go goroutine语义几乎一致。切换后可以消除线程数限制顾虑，每个请求直接 `Thread.startVirtualThread()` 创建轻量线程。

**当前结论**：**采用方案A实现**。注意在代码中通过接口抽象SolverPool（定义 `acquire()/release()` 接口 + `@ConditionalOnJava` 条件注入），为未来无痛切换到Virtual Threads做准备。

### 5.4 中间件清单及优先级

| 中间件 | 必要性 | 优先级 | 引入Sprint | 说明 |
|--------|:---:|:---:|:---:|------|
| **MySQL 8.0** | 必须 | P0 | 已就绪 | 主数据库 |
| **Redis 7.x** | 必须 | P0 | 已就绪 | 缓存 + Session + 分布式锁 |
| **RabbitMQ 3.x** | **强烈推荐** | P0 | Sprint 4 | 异步任务（PDF生成/ERP同步/ECN传播） |
| **Elasticsearch 7.x** | 推荐 | P1 | Sprint 5 | 全文搜索（产品/方案/知识库多语言搜索） |
| **MinIO** | 推荐 | P1 | Sprint 4 | 报价单PDF/Word存储、产品图片OSS |
| **WebSocket** | 条件必须 | P1 | Sprint 5 | 方案协同编辑（Yjs后端） |
| Prometheus + Grafana | 推荐 | P2 | Sprint 6 | JVM监控 + 业务指标面板 |

**各中间件的替代方案评估**：

- **RabbitMQ替代方案**：Spring Event + `@Async` 可用于模块内异步；但跨系统集成（ERP/CRM同步）必须MQ。如果不想引入RabbitMQ运维成本，短期内可用Redis List做消息队列（BRPOPLPUSH可靠队列模式），但不推荐作为长期方案。
- **Elasticsearch替代方案**：MySQL FULLTEXT（ngram parser）可满足基础全文搜索需求。如果搜索场景仅限于产品名称/型号/描述的关键词搜索（无复杂聚合），可以先用MySQL FULLTEXT，ES作为后期优化引入。
- **MinIO替代方案**：本地文件系统（NFS共享）可满足双机部署的静态文件共享。如果OSS需求不大（月增<1GB），可以暂不引入MinIO。

---

## 六、部署与运维

### 6.1 Nginx + Fat JAR双机主从部署方案

**设计文档阶段三§6.1给出了部署拓扑**，评估：**可行，但需要补充几个关键细节**。

**确认可行的部分**：
- Fat JAR部署：`mvn clean package` 生成包含所有依赖的可执行JAR，通过 `java -jar ruoyi-admin.jar --spring.profiles.active=prod` 启动。✅
- Nginx反向代理：静态资源 + API代理。✅
- Keepalived VIP：实现Nginx的高可用。✅

**需要补充的关键细节**：

1. **Session共享**：双机部署需要共享Session。设计§6.2提到Redis Sentinel，建议在 `application-prod.yml` 中配置Spring Session Redis：
   ```yaml
   spring:
     session:
       store-type: redis
   ```
   确保用户登录态在两台应用服务器之间共享。

2. **文件存储共享**：报价单PDF/Word、产品图片需要两台机器都能访问。方案：
   - 方案A（推荐生产）：MinIO分布式对象存储，双机各部署一个MinIO实例组成集群
   - 方案B（推荐初期）：NFS网络文件系统挂载共享目录，两台应用服务器挂载同一个NFS路径

3. **MySQL主从读写分离**：设计§6.1提到"主库(写) + 从库(读)"。MyBatis-Plus的读写分离需要配合 `dynamic-datasource` 组件（RuoYi-Vue-Plus已集成）：
   ```yaml
   spring:
     datasource:
       dynamic:
         primary: master
         datasource:
           master:
             url: jdbc:mysql://192.168.1.10:3306/cpq_core
           slave:
             url: jdbc:mysql://192.168.1.11:3306/cpq_core
   ```
   注意：从库有复制延迟，配置引擎(CSP)的实时读必须走主库。在Service方法上用 `@DS("master")` 注解显式指定。

4. **Redis Sentinel**：设计§6.1提到Redis Sentinel哨兵。如果仅用于缓存（非持久化数据），单实例Redis + AOF持久化即可。如果要存Session，建议至少Sentinel（3节点：1主2从+3哨兵）。

5. **健康检查**：Nginx应配置健康检查端点：
   ```nginx
   location /health {
       proxy_pass http://127.0.0.1:8080/actuator/health;
   }
   ```

### 6.2 数据库备份策略建议

| 备份类型 | 频率 | 方式 | 保留周期 |
|---------|:---:|------|:---:|
| 全量备份 | 每日凌晨2:00 | `mysqldump --single-transaction --all-databases` | 30天 |
| 增量备份 | 每小时 | `mysqlbinlog` binlog备份 | 7天 |
| 异地备份 | 每日 | rsync/scp到远程存储 | 90天 |
| 恢复演练 | 每季度 | 从全量+增量恢复到测试库 | — |

**关键命令**：
```bash
# 全量备份（不锁表）
mysqldump --single-transaction --routines --triggers \
  --all-databases -u backup -p > /backup/full_$(date +%Y%m%d).sql

# 恢复（全量 + 增量）
mysql -u root -p < full_backup.sql
mysqlbinlog binlog.000001 binlog.000002 | mysql -u root -p
```

**注意**：MySQL 8.0的 `WITH RECURSIVE` CTE视图和存储过程需要一并备份。`mysqldump` 的 `--routines` 参数可导出存储过程，视图会自动包含在表结构导出中。

### 6.3 日志与监控方案

**当前已有**：Spring Boot Actuator + RuoYi自带 `@Log` 注解。

**建议补充的监控体系**：

| 层级 | 工具 | 监控内容 |
|-----|------|---------|
| 基础设施 | Prometheus + Node Exporter | CPU/内存/磁盘/网络 |
| JVM | Spring Boot Actuator + Micrometer | 堆内存/GC/线程数/连接池 |
| 应用层 | 自定义Metrics | CSP求解延迟/定价计算耗时/报价生成耗时 |
| 业务层 | 自定义指标面板 | 配置次数/报价数/审批通过率/交期达成率 |
| 日志 | ELK (Elasticsearch + Logstash + Kibana) 或 Loki + Grafana | 审计日志 + 错误日志聚合 |
| 告警 | Alertmanager | 服务宕机/CSP延迟超200ms/数据库连接满 |

**最小化可行监控方案（MVP）**：
- **Sprint 1-4**：Spring Boot Actuator + `@Log` 注解 + 日志文件，通过 `logback-plus.xml` 输出到文件，用 `tail -f` 查看
- **Sprint 5-6**：引入Prometheus + Grafana（如果有Docker环境），否则用Spring Boot Admin（RuoYi已集成）
- **生产环境**：至少部署Prometheus + Grafana + Alertmanager，配置数据库连接池告警、JVM OOM告警、API错误率告警

---

## 七、评审总结与优先级建议

### 架构健康度总评

| 维度 | 评分 | 关键问题数 |
|------|:---:|:---:|
| 数据架构 | 3.5/5 | 跨库FK不可行、JSON字段需虚拟列索引、分区表FK限制 |
| 模块依赖 | 4/5 | 缺失competitive/knowledge/ecn/migration模块的Sprint任务 |
| Service层 | 3.5/5 | 核心Service缺少接口契约、消息队列引入时机待明确 |
| 前端架构 | 4/5 | Store职责过重、WebSocket协同服务待搭建、Dashboard性能 |
| 技术决策 | 4/5 | 技术栈选型正确、CSP方案合理、MySQL替代PG可行 |
| 部署运维 | 3.5/5 | Session共享、文件存储共享、备份策略需补充细节 |

### 必须立即解决的P0问题（阻塞Sprint 3启动）

| # | 问题 | 建议 |
|:--:|------|------|
| 1 | 跨数据库FK不可行 vs 单库部署的顶层裁决 | **决定采用单CPQ数据库 + 模块化单体架构** |
| 2 | 核心Service（ConfigEngine/PricingEngine/AtpCtp/ApprovalRoute/QuoteGenerate）缺少接口契约 | Sprint 3启动前完成5个Service的Interface + DTO定义 |
| 3 | RabbitMQ引入时机 | Sprint 4启动前部署RabbitMQ，Sprint 3可用Spring Event + @Async代替 |
| 4 | competitive/knowledge/ecn/migration四个模块无Sprint任务 | 在Sprint 4.5（报价完成后）或Sprint 5中补全 |

### Sprint级行动建议

| Sprint | 架构行动项 |
|:-----:|------|
| Sprint 3 | 执行定价/配置DDL时为关键JSON字段创建虚拟列索引；编写ConfigEngine + PricingEngine的接口契约；搭建Caffeine缓存基础设施 |
| Sprint 4 | 部署RabbitMQ；确认MySQL分区表FK限制；引入MinIO或NFS文件共享 |
| Sprint 5 | 搭建Yjs WebSocket服务（Node.js）；补全competitive/knowledge/ecn/migration四个模块；引入ES或MySQL FULLTEXT |
| Sprint 6 | Prometheus + Grafana监控；数据库备份脚本；双机Session共享测试；全链路性能压测 |

---

## 参考资料

1. [CPQ_后端功能设计.md（V2.1）] — RuoYi-Vue-Plus后端设计
2. [CPQ_前端门户设计.md（V2.1）] — Vue3前端门户设计
3. [CPQ_阶段三_技术实现层.md（V2.0）] — Java+MySQL技术实现
4. [development_plan.md（V2.0）] — 当前开发计划
5. [cross_trace_v2_final.md] — 交叉追溯审计报告
6. MySQL 8.0 Reference Manual — WITH RECURSIVE, JSON Functions, CHECK Constraints
7. MyBatis-Plus 3.5 Documentation — TenantLineInnerInterceptor, Dynamic Datasource
8. Yjs Documentation — CRDT Collaborative Editing
