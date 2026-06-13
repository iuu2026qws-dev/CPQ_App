# Sprint 1 架构重构 — 修改方案

> 版本：V2.0 | 日期：2026-06-06  
> 目的：汇总 Sprint 1 两大架构变更的完整修改方案  
> V2.0 变更：新增「产品分类独立树表」改造方案（V1.0 仅含捆绑包改造）

---

## 变更 A：产品捆绑 — SBOM行隐式表达 → 独立三表建模

| 影响对象 | 影响级别 | 说明 |
|---------|:---:|------|
| `cpq_product_model.config_type` | **高** | 新增 `BUNDLE` 枚举值 |
| `CPQ_后端功能设计.md` | **高** | DDL、表清单、代码生成计划、Sprint 规划同步 |
| `CPQ_前端门户设计.md` | **中** | 新增捆绑包管理页面规格 |
| `sql/cpq_d01_product.sql` | **中** | `config_type` 注释修改 + 新增3张捆绑表DDL |
| `CpqProductModel.java` (Domain) | **低** | `config_type` 字段注释修改 |
| `model/index.vue` (前端) | **低** | `configTypeOptions` 增加 BUNDLE 选项 |
| `model.ts` (前端API) | **低** | 接口注释同步 |

---

## 变更 B：产品分类 — 内联字符串字段 → 独立层级树表（V2.0 新增）

### B1. 变更影响范围总览

| 影响对象 | 影响级别 | 说明 |
|---------|:---:|------|
| `cpq_product_model` 表结构 | **高** | 删除 `product_line`/`product_family`/`product_series`，新增 `category_id` |
| `cpq_product_category` 新表 | **高** | 新增自引用层级树表（14字段，3索引） |
| `CpqProductModel.java` | **高** | 字段变更：3个 String → 1个 Long FK |
| `CpqProductModelBo.java` | **高** | 同上 |
| `CpqProductModelVo.java` | **高** | 同上 + 新增 category path 展示字段 |
| `CpqProductModelServiceImpl.java` | **中** | 新增分类名称 enrich 逻辑 |
| `model/index.vue` (前端) | **高** | 3个文本输入 → 3级级联 lookup 选择器 |
| `model.ts` (前端API) | **中** | 接口类型变更 |
| `CPQ_后端功能设计.md` | **高** | D01 8表→9表、product_model DDL 更新、权限更新 |
| `CPQ_前端门户设计.md` | **高** | 新增 ProductCategory.vue 页面、表单改为级联 lookup |
| `M-CPQ_产品数据架构.md` | **高** | §二产品域重写、§九.1设计决策重写、ER图更新 |
| `sql/cpq_d01_product.sql` | **高** | 新增 category 表 DDL、product_model DDL 重写 |

### B2. 数据库变更摘要

**cpq_product_category 新表**：
- 自引用层级树（`parent_category_id` 为 NULL = L1根节点）
- `category_level` 标识层级：1=产品线、2=产品族、3=产品系列
- 唯一索引：`(tenant_id, category_code)`

**cpq_product_model 字段变更**：
- 删除：`product_line VARCHAR(100)`, `product_family VARCHAR(100)`, `product_series VARCHAR(100)`
- 新增：`category_id BIGINT NOT NULL` → FK → `cpq_product_category`
- 索引变更：`idx_product_line` 删除，新增 `idx_category`

### B3. 前端表单变更摘要

**产品模型表单（model/index.vue）**：
- 旧：3个 `<el-input>` 文本输入框（产品线L1/产品族L2/产品系列L3）
- 新：3级级联 `<el-select>` + `filterable` + `remote` lookup 选择器
  - 第1级：加载所有 L1 产品线
  - 第2级：根据选中 L1 动态加载 L2 产品族
  - 第3级：根据选中 L2 动态加载 L3 产品系列
  - 最终存储值：选中的 L3 `category_id`

**新增产品分类管理页（category/index.vue）**：
- 树形表格展示三级分类层级结构
- 支持新增/编辑/删除分类节点
- 有子节点的分类不可删除

### B4. Java 代码变更摘要

**新增文件**：
- `CpqProductCategory.java` — Domain 实体
- `CpqProductCategoryBo.java` — 业务对象
- `CpqProductCategoryVo.java` — 展示对象
- `CpqProductCategoryMapper.java` — MyBatis Mapper
- `ICpqProductCategoryService.java` — Service 接口
- `CpqProductCategoryServiceImpl.java` — Service 实现
- `CpqProductCategoryController.java` — REST Controller

**修改文件**：
- `CpqProductModel.java` — 删除 `productLine`/`productFamily`/`productSeries`，新增 `categoryId`
- `CpqProductModelBo.java` — 同上
- `CpqProductModelVo.java` — 同上 + 新增 `categoryPath` 展示字段
- `CpqProductModelServiceImpl.java` — 新增 `enrichCategoryPath` 方法

---

## 二、设计文档修改方案

### 2.1 CPQ_后端功能设计.md 修改

**修改点 1 — §4.2 D01 表清单，`cpq_product_model.config_type` 注释**：

旧：
```sql
config_type VARCHAR(20) DEFAULT 'STANDARD' COMMENT '配置类型: STANDARD/ATO/CTO/ETO',
```

改为：
```sql
config_type VARCHAR(20) DEFAULT 'STANDARD' COMMENT '配置类型: STANDARD/ATO/CTO/ETO/BUNDLE',
```

**修改点 2 — §4.2 表清单，`cpq_product_model` 枚举值完整定义附近，加一条注释说明 BUNDLE**：

在 `cpq_product_model` DDL 定义之后，添加注释行：
```
-- config_type=BUNDLE 时，该产品为捆绑包。捆绑包的具体选项通过 cpq_bundle/cpq_bundle_option_group/cpq_bundle_option 三表定义。
-- 捆绑包自身不直接挂 SBOM（default_bom_id=NULL），其组件产品的 BOM 递归展开。
```

**修改点 3 — §4.2 新增「产品捆绑域（3张表）」章节**（插入在 D03 配置数据域之前）：

```sql
#### Bundle — 产品捆绑域（3张表）

**cpq_bundle（捆绑包定义）**：
```sql
CREATE TABLE cpq_bundle (
    bundle_id               BIGINT       NOT NULL AUTO_INCREMENT COMMENT '捆绑包ID',
    tenant_id               VARCHAR(20)  DEFAULT '000000' COMMENT '租户ID',
    model_id                BIGINT       NOT NULL COMMENT '捆绑包产品ID(FK→cpq_product_model)',
    bundle_type             VARCHAR(20)  NOT NULL COMMENT '捆绑类型: FIXED/CONFIGURABLE/SOLUTION',
    pricing_strategy        VARCHAR(20)  NOT NULL COMMENT '定价策略: BUNDLE_PRICE/SUM_COMPONENTS',
    bundle_discount_pct     DECIMAL(5,2) COMMENT '捆绑折扣率(%)',
    is_active               CHAR(1)      DEFAULT '1' COMMENT '是否启用(1是 0否)',
    description             VARCHAR(1000) COMMENT '捆绑描述',
    del_flag                CHAR(1)      DEFAULT '0',
    create_dept             BIGINT,
    create_by               BIGINT,
    create_time             DATETIME,
    update_by               BIGINT,
    update_time             DATETIME,
    remark                  VARCHAR(500),
    PRIMARY KEY (bundle_id),
    UNIQUE KEY uk_model (tenant_id, model_id),
    INDEX idx_active (tenant_id, is_active)
) ENGINE=InnoDB COMMENT='CPQ产品捆绑包';
```

**cpq_bundle_option_group（捆绑选项组）**：
```sql
CREATE TABLE cpq_bundle_option_group (
    option_group_id     BIGINT       NOT NULL AUTO_INCREMENT COMMENT '选项组ID',
    tenant_id           VARCHAR(20)  DEFAULT '000000' COMMENT '租户ID',
    bundle_id           BIGINT       NOT NULL COMMENT '捆绑包ID',
    group_name          VARCHAR(100) NOT NULL COMMENT '选项组名称',
    group_code          VARCHAR(50)  COMMENT '选项组编码',
    min_selections      INT          DEFAULT 0 COMMENT '最少选择数',
    max_selections      INT          DEFAULT 1 COMMENT '最多选择数',
    is_required         CHAR(1)      DEFAULT '1' COMMENT '是否必选(1是 0否)',
    sort_order          INT          DEFAULT 0,
    del_flag            CHAR(1)      DEFAULT '0',
    create_dept         BIGINT,
    create_by           BIGINT,
    create_time         DATETIME,
    update_by           BIGINT,
    update_time         DATETIME,
    remark              VARCHAR(500),
    PRIMARY KEY (option_group_id),
    INDEX idx_bundle (tenant_id, bundle_id)
) ENGINE=InnoDB COMMENT='CPQ捆绑选项组';
```

**cpq_bundle_option（捆绑选项）**：
```sql
CREATE TABLE cpq_bundle_option (
    option_id               BIGINT         NOT NULL AUTO_INCREMENT COMMENT '选项ID',
    tenant_id               VARCHAR(20)    DEFAULT '000000' COMMENT '租户ID',
    option_group_id         BIGINT         NOT NULL COMMENT '选项组ID',
    component_model_id      BIGINT         NOT NULL COMMENT '组件产品ID(FK→cpq_product_model)',
    quantity                DECIMAL(12,4)  DEFAULT 1 COMMENT '默认数量',
    unit                    VARCHAR(10)    DEFAULT 'PCS' COMMENT '单位',
    is_default              CHAR(1)        DEFAULT '0' COMMENT '是否默认选中',
    price_modifier_type     VARCHAR(20)    DEFAULT 'NONE' COMMENT '价格调整类型: NONE/FIXED_AMOUNT/PERCENT/INCLUDE',
    price_modifier_value    DECIMAL(18,2)  COMMENT '价格调整数值',
    sort_order              INT            DEFAULT 0,
    del_flag                CHAR(1)        DEFAULT '0',
    create_dept             BIGINT,
    create_by               BIGINT,
    create_time             DATETIME,
    update_by               BIGINT,
    update_time             DATETIME,
    remark                  VARCHAR(500),
    PRIMARY KEY (option_id),
    INDEX idx_group (tenant_id, option_group_id),
    INDEX idx_component (tenant_id, component_model_id)
) ENGINE=InnoDB COMMENT='CPQ捆绑选项';
```
```

**修改点 4 — §4.2 全量表清单总表**：

- D01 从「8张表」不变（捆绑独立为 Bundle 域）
- 新增一行：「**Bundle（产品捆绑域）** | 3张表 | cpq_bundle, cpq_bundle_option_group, cpq_bundle_option」

**修改点 5 — §5.1 代码生成顺序**：

在 S3（ruoyi-cpq-config）之前增加一行：

| 批次 | 模块 | 表清单 | 预计生成文件 |
|:---:|------|-------|:----------:|
| S2.5 | ruoyi-cpq-bundle | cpq_bundle, cpq_bundle_option_group, cpq_bundle_option | 3表 × 12文件/表 = 36文件 |

**修改点 6 — §5.2 手写核心 Service**：

在 ConfigEngineService 的 guidedSelling() 方法描述中补充：「支持引导式捆绑方案推荐（展示 is_active=1 的捆绑包列表）」。

**修改点 7 — §6.1 Sprint 规划**：

Sprint 3 描述改为：「D02定价+D03配置+Bundle捆绑代码生成」。

---

### 2.2 CPQ_前端门户设计.md 修改

**修改点 1 — §3.1 菜单体系，在「产品管理」下增加捆绑管理菜单**：

```sql
-- 在 50084 替代品管理之后增加：
(50085, '捆绑包管理', 50080, 5, 'bundle', 'product/BundleManager', NULL, NULL, 1, 0, 'C', '0', '0', 'cpq:product:catalog', '#', NULL, 1, NOW()),
```

**修改点 2 — §8.1 关键页面设计规格，新增捆绑包管理页面**：

```markdown
#### 捆绑包管理页面 (BundleManager.vue)

**页面定位**：产品经理管理捆绑包（创建/编辑/查看捆绑包、配置选项组和选项）。

**布局**：左侧捆绑包列表（可搜索/筛选），右侧选项组和选项的嵌套编辑区。

**核心功能**：
1. 捆绑包列表（表格 / 卡片视图切换）
   - 显示：捆绑包名称、捆绑类型(FIXED/CONFIGURABLE/SOLUTION)、定价策略、折扣率、状态
   - 操作：新建、编辑、删除、启用/停用

2. 新建/编辑捆绑包弹窗
   - 选择捆绑包产品（从 `cpq_product_model` 中筛选 `config_type=BUNDLE` 的产品，或在此直接创建）
   - 选择捆绑类型、定价策略、设置折扣率
   - 描述

3. 选项组管理（在选中捆绑包后展开）
   - 新增选项组：组名、编码、最少/最多选择数、是否必选、排序
   - 拖拽排序

4. 选项管理（在选项组下）
   - 新增选项：选择组件产品（从 cpq_product_model 中搜索）、数量、是否默认、价格调整
   - 拖拽排序

**路由**：`/product/bundle`
**权限**：`cpq:product:catalog`
```

**修改点 3 — §8.1 ConfigTree 组件，产品树节点增加捆绑包标识**：

在产品树节点描述中增加：「`config_type=BUNDLE` 的产品节点显示捆绑包图标（如 📦），点击展开捆绑选项组和组件」。

**修改点 4 — 附录A 阶段二 P0功能→前端组件映射表**：

新增行：「捆绑包管理 | BundleManager.vue | 产品管理 → 捆绑包管理」。

---

## 三、Sprint 1 已完成代码修改方案

### 3.1 数据库 DDL 修改

**文件**：`sql/cpq_d01_product.sql`

**修改 A**：`cpq_product_model` 表 `config_type` 字段注释

```sql
-- 旧（第47行）
config_type VARCHAR(20) DEFAULT 'STANDARD' COMMENT '配置类型: STANDARD/ATO/CTO/ETO',
-- 新
config_type VARCHAR(20) DEFAULT 'STANDARD' COMMENT '配置类型: STANDARD/ATO/CTO/ETO/BUNDLE',
```

**修改 B**：文件末尾新增3张捆绑表 DDL（在 ABAC 策略表之后、删除旧表之前）：

见 §2.1 修改点3 的 DDL。

---

### 3.2 后端 Java 代码修改

**文件 1**：`ruoyi-modules/ruoyi-cpq/.../domain/CpqProductModel.java`（第72行）

```java
// 旧
/** 配置类型: STANDARD/ATO/CTO/ETO */
// 新
/** 配置类型: STANDARD/ATO/CTO/ETO/BUNDLE */
```

**文件 2**：`ruoyi-modules/ruoyi-cpq/.../domain/bo/CpqProductModelBo.java`

找到 `configType` 字段注释，同步修改为 `/** 配置类型: STANDARD/ATO/CTO/ETO/BUNDLE */`。

**文件 3**：`ruoyi-modules/ruoyi-cpq/.../domain/vo/CpqProductModelVo.java`

找到 `configType` 字段注释，同步修改为 `/** 配置类型: STANDARD/ATO/CTO/ETO/BUNDLE */`。

---

### 3.3 前端代码修改

**文件 1**：`ruoyi-ui/src/views/cpq/model/index.vue`（第60-64行）

```typescript
// 旧
const configTypeOptions = [
  { label: '标准品', value: 'STANDARD' },
  { label: 'ATO', value: 'ATO' },
  { label: 'CTO', value: 'CTO' },
  { label: 'ETO', value: 'ETO' }
];
// 新
const configTypeOptions = [
  { label: '标准品', value: 'STANDARD' },
  { label: 'ATO', value: 'ATO' },
  { label: 'CTO', value: 'CTO' },
  { label: 'ETO', value: 'ETO' },
  { label: '捆绑包', value: 'BUNDLE' }
];
```

**文件 2**：`ruoyi-ui/src/api/cpq/model.ts`

找到 `CpqProductModel` 接口中 `configType` 字段的注释，同步修改为 `/** 配置类型: STANDARD/ATO/CTO/ETO/BUNDLE */`。

---

### 3.4 修改执行顺序

| 顺序 | 步骤 | 影响范围 | 验证方式 |
|:---:|------|---------|---------|
| 1 | 修改 `CpqProductModel.java` Domain 注释 | 仅注释，无功能影响 | 编译通过即可 |
| 2 | 修改 `CpqProductModelBo.java` 注释 | 同上 | 编译通过 |
| 3 | 修改 `CpqProductModelVo.java` 注释 | 同上 | 编译通过 |
| 4 | 修改 `model/index.vue` configTypeOptions | 前端下拉选项增加 BUNDLE | 页面加载正常，下拉可看到新选项 |
| 5 | 修改 `model.ts` API 注释 | 仅注释 | 编译通过 |
| 6 | 修改 `cpq_d01_product.sql` DDL | DDL 注释+新增3表 | SQL 可执行 |
| 7 | 执行 ALTER TABLE 修改已有 DB 注释 | DB | `SHOW CREATE TABLE cpq_product_model` |
| 8 | 执行 CREATE TABLE 新增3张捆绑表 | DB（可选，可等 Sprint 3） | `SHOW TABLES LIKE 'cpq_bundle%'` |

**建议**：步骤 1-5 立即执行（零风险），步骤 6-8 可选择性执行。捆绑表 DDL 在 Sprint 3 执行也不影响当前功能。

---

## 四、不需要修改的部分

以下文件和代码**不需要修改**，避免过度设计：

| 文件 | 原因 |
|------|------|
| `CpqProductCatalog` 全套 | 目录与捆绑无关 |
| `CpqProductSupersession` 全套 | 替代关系无需变动。未来可扩展：捆绑包 ↔ 替代捆绑包，但这是 Sprint 3+ 的功能 |
| `CpqProductModelMapper.xml` | config_type 是 VARCHAR 字段，无枚举约束，存入 BUNDLE 自然支持 |
| `CpqProductModelServiceImpl` | 无 config_type 相关校验逻辑，自然兼容 |
| `CpqProductModelController` | 无需变更 |
| `supersession/index.vue` | 无需变更 |
| `catalog/index.vue` | 无需变更 |
| `catalog.ts` API | 无需变更 |
| `supersession.ts` API | 无需变更 |

---

## 五、Sprint 3 捆绑域完整开发任务（提前规划）

以下任务在 **Sprint 3** 执行，此处提前列出以便设计文档对齐：

### 5.1 后端（ruoyi-cpq-bundle 模块）

- [ ] **S3.3.1** `cpq_bundle` — Domain/Bo/Vo/Mapper/Service/Controller CRUD
- [ ] **S3.3.2** `cpq_bundle_option_group` — Domain/Bo/Vo/Mapper/Service/Controller CRUD
- [ ] **S3.3.3** `cpq_bundle_option` — Domain/Bo/Vo/Mapper/Service/Controller CRUD

### 5.2 前端（cpq-portal / ruoyi-ui）

- [ ] **BundleManager.vue** — 捆绑包管理页面（列表+选项组+选项三级嵌套编辑）
- [ ] **bundle.ts API** — 捆绑包/选项组/选项 API 接口层

### 5.3 引擎集成

- [ ] **ConfigEngineService.guidedSelling()** — 支持推荐 is_active=1 的捆绑包列表
- [ ] **PricingEngineService** — 支持 BUNDLE_PRICE 和 SUM_COMPONENTS 两种捆绑定价策略
- [ ] **QuoteGenerateService** — 报价单展开捆绑包为逐行组件（捆绑包标题行 + 组件明细行）

---

## 六、总结

| 类别 | 修改量 | 风险 |
|------|:---:|:---:|
| 设计文档 | 后端设计 7处 + 前端设计 4处 | 无 |
| DDL SQL | 1处注释修改 + 3张新表DDL | 低（注释修改安全，新表不影响现有功能） |
| Java 代码 | 3处注释修改 | 零（纯注释） |
| 前端代码 | 1处下拉选项扩展 + 1处注释 | 零（仅 UI 扩展） |
| **合计** | **约 20 处修改** | **总体零风险** |
