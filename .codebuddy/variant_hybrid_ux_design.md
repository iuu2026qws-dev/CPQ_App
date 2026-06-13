# CPQ 混合架构 — 变体级定价 UI/UX 详细设计

> 版本：V1.1 | 日期：2026-06-07
> 基于：M-CPQ_Product_Data_Architecture.md V1.2 + 混合架构共识（路线 A+B 共存）
> 目标：完整定义变体管理、产品 Lookup、价格条目表单、渠道价格表单的 UI 与交互
> V1.1 变更：所有示例数据统一为智元机器人（RoboWise Robotics）产品数据

---

## 一、架构概览

### 1.1 混合架构核心原则

价格手册条目（`cpq_price_book_entry`）+ 渠道价格（`cpq_channel_price`）的产品引用分为两条路径：

- **模型级定价**（CTO/ETO）：entry.model_id → cpq_product_model，entry.variant_id = NULL。定价规则动态计算价格
- **变体级定价**（STANDARD/ATO）：entry.model_id → cpq_product_model，entry.variant_id → cpq_product_variant。每个变体独立定价

同一条 entry 记录同时有 model_id（必填，便于回溯到型号）和 variant_id（可空，指向具体变体）。

> **本文所有产品示例均使用智元机器人（RoboWise Robotics）产品数据**，覆盖工业机器人、家用机器人、具身智能机器人三个产品族，100 个产品型号（model_id 1001-1100）。

### 1.2 新增实体：cpq_product_variant

```sql
CREATE TABLE cpq_product_variant (
    variant_id       BIGINT         NOT NULL COMMENT '变体ID',
    tenant_id        VARCHAR(20)    DEFAULT '000000',
    model_id         BIGINT         NOT NULL COMMENT '所属产品型号ID(FK→cpq_product_model)',
    variant_code     VARCHAR(100)   NOT NULL COMMENT '变体编码(如 RW-SWEEP-S1-WHT)',
    variant_name     VARCHAR(200)   NOT NULL COMMENT '变体名称(如 SweepBot S1 白色款)',
    attributes       TEXT           NOT NULL COMMENT '属性值集合(JSON): {"attr_name":"attr_value", ...}',
    default_bom_id   BIGINT         DEFAULT NULL COMMENT '此变体对应的确定SBOM Header ID(FK→cpq_sbom_header)',
    base_price       DECIMAL(18,2)  DEFAULT NULL COMMENT '变体基础价(可继承model.base_price或覆盖)',
    thumbnail_url    VARCHAR(500)   DEFAULT NULL COMMENT '变体缩略图',
    is_default       CHAR(1)        DEFAULT '0' COMMENT '是否默认变体',
    status           CHAR(1)        DEFAULT '0' COMMENT '状态(0正常 1停用)',
    del_flag         CHAR(1)        DEFAULT '0',
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='CPQ产品变体(型号+属性组合→确定的可售卖SKU)';
```

约束：唯一键 `uk_model_attrs` 确保同一型号下，同一属性值组合只有一个变体。

### 1.3 现有表字段变更

**cpq_price_book_entry**：
```sql
ALTER TABLE cpq_price_book_entry ADD COLUMN variant_id BIGINT DEFAULT NULL COMMENT '变体ID(FK→cpq_product_variant, NULL=模型级定价)';
ALTER TABLE cpq_price_book_entry ADD INDEX idx_variant (tenant_id, variant_id);
```

**cpq_channel_price**：
```sql
ALTER TABLE cpq_channel_price ADD COLUMN variant_id BIGINT DEFAULT NULL COMMENT '变体ID(FK→cpq_product_variant, NULL=模型级定价)';
ALTER TABLE cpq_channel_price ADD INDEX idx_variant (tenant_id, variant_id);
```

---

## 二、变体管理页面（嵌入产品模型管理）

### 2.1 页面布局

变体管理不单独建菜单，作为产品模型列表页（`/cpq/model`）的一个**行内展开区域**，点击模型行的「变体」按钮展开。

```
┌─────────────────────────────────────────────────────────────┐
│  产品模型                                    [+新增模型]    │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ 搜索: [model_code] [model_name] [config_type ▼] [搜索]│  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────┬─────────────────┬──────────┬────────┬───────┐ │
│  │编码      │名称             │配置类型  │生命周期 │操作   │ │
│  ├──────────┼─────────────────┼──────────┼────────┼───────┤ │
│  │RW-SWEEP- │SweepBot S1 Pro  │STANDARD  │ACTIVE  │编辑   │ │
│  │  S1P     │  旗舰扫拖机器人 │         [变体管理 ▼]      │ │
│  │          │                 │[已展开]  │变体(3)▾│删除   │ │
│  │          │ ┌─────────────────────────────────────────┐ │ │
│  │          │ │ 变体列表                      [+新增变体]│ │ │
│  │          │ │ ┌─────────────┬──────────┬───┬───┬────┐ │ │ │
│  │          │ │ │变体编码     │变体名称  │价格│默认│操作│ │ │ │
│  │          │ │ │RW-SWEEP-S1P │S1 Pro    │ ¥ │ ● │编辑│ │ │ │
│  │          │ │ │-WHT         │白色款    │4999│   │删除│ │ │ │
│  │          │ │ │RW-SWEEP-S1P │S1 Pro    │ ¥ │ ○ │编辑│ │ │ │
│  │          │ │ │-BLK         │黑色款    │4999│   │删除│ │ │ │
│  │          │ │ │RW-SWEEP-S1P │S1 Pro    │ ¥ │ ○ │编辑│ │ │ │
│  │          │ │ │-SLV         │银色限量  │5299│   │删除│ │ │ │
│  │          │ │ └─────────────┴──────────┴───┴───┴────┘ │ │ │
│  │          │ └─────────────────────────────────────────┘ │ │
│  │          │                                             │ │
│  ├──────────┼─────────────────┼──────────┼────────┼───────┤ │
│  │RW-HMD-G1 │Humano G1        │ETO       │ACTIVE  │编辑   │ │
│  │          │  通用人形机器人  │          │        │删除   │ │
│  │          │                 │          │        │变体(-)│ │
│  └──────────┴─────────────────┴──────────┴────────┴───────┘ │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 交互规则

- STANDARD/ATO 产品：操作列显示「变体(N)」按钮，点击展开/收起变体子表。N 为已有变体数量
- ETO/BUNDLE 产品：操作列显示「变体(-)」，灰色禁用，tooltip 提示「ETO产品为定制化设计，使用定价规则+手工报价，无需预定义变体」
- 变体子表内支持：新增变体（打开变体对话框）、编辑、删除、设默认
- config_type 变更保护：如果产品从 ATO 改为 ETO，且已有变体数据，弹窗警告「该产品下有 N 个变体，改为 ETO 后将无法在价格手册中按变体定价。现有变体数据将保留但不再生效。是否继续？」

### 2.3 变体对话框

```
┌──────────────────────────────────────────┐
│  新增变体 — CoBot-10（大负载协作机器人）  │
│                                          │
│  ┌────────────────────────────────────┐  │
│  │ 变体编码 *                         │  │
│  │ [RW-CB-10-5KG-IP65_____________]  │  │
│  │ (系统自动生成: 型号编码-属性值缩写) │  │
│  └────────────────────────────────────┘  │
│  ┌────────────────────────────────────┐  │
│  │ 变体名称 *                         │  │
│  │ [CoBot-10 5kg负载 IP65防护______]  │  │
│  └────────────────────────────────────┘  │
│  ┌────────────────────────────────────┐  │
│  │ 属性配置                           │  │
│  │ ┌──────────┬─────────────────────┐ │  │
│  │ │ 额定负载 │ [5kg           ▼]  │ │  │
│  │ │ 防护等级 │ [IP65          ▼]  │ │  │
│  │ │ 末端工具 │ [二指夹爪      ▼]  │ │  │
│  │ │ 通信接口 │ [EtherCAT      ▼]  │ │  │
│  │ └──────────┴─────────────────────┘ │  │
│  │ (属性列表来自 cpq_product_attr)    │  │
│  └────────────────────────────────────┘  │
│  ┌────────────────────────────────────┐  │
│  │ 基础价格                           │  │
│  │ [88000.00___________________] CNY  │  │
│  │ (默认继承 model.base_price: ¥88K)  │  │
│  └────────────────────────────────────┘  │
│  ┌────────────────────────────────────┐  │
│  │ 关联 BOM                           │  │
│  │ [CB-10-SBOM-v1.0__________ 选择]  │  │
│  │ (可选, 用于此变体的专属SBOM)       │  │
│  └────────────────────────────────────┘  │
│                                          │
│           [取消]          [确定]         │
└──────────────────────────────────────────┘
```

关键交互：
- 「变体编码」默认自动生成（型号编码-属性值简称拼接），用户可手动修改
- 「属性配置」根据该产品的 `cpq_product_attribute`（`is_configurable=1`）动态渲染属性下拉框。每个属性取 `option_values` JSON 数组作为下拉选项。「属性集」（attr_category）以分组形式展示
- 「基础价格」默认填入 `model.base_price`，用户可覆盖
- 「关联 BOM」是可选字段，远程搜索该型号下的 SBOM Header。不选则使用 model.default_bom_id

---

## 三、价格手册条目表单 —— 产品 Lookup 核心设计

这是本次设计最核心的部分。

### 3.1 表单字段变化

**修改前**（当前代码）：
```
产品ID:   [el-input-number, 手动输入数字ID]
物料编码: [el-input, 手动输入]
```

**修改后**（混合架构）：
```
产品选择:  [远程搜索 select: 型号编码 - 型号名称]  (必填)
变体选择:  [级联 select: 变体编码 - 变体名称]      (条件必填, 仅 STANDARD/ATO 显示)
物料编码:  [el-input, 只读, 自动填充]              (选变体填充 variant_code, 否则留空)
```

### 3.2 产品选择器行为（Model Lookup）

```
┌────────────────────────────────────────────────────────────┐
│  产品选择 *                                                 │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ 🔍 搜索产品名称或编码...                               │ │
│  └────────────────────────────────────────────────────────┘ │
│  选中: RW-SWEEP-S1P - SweepBot S1 Pro 旗舰扫拖机器人        │
│        (STANDARD)                                           │
│                                                             │
│  下拉选项示例（智元机器人产品）:                             │
│  ┌────────────────────────────────────────────────────┐     │
│  │ RW-SWEEP-S1P - SweepBot S1 Pro 旗舰扫拖 STANDARD  │     │
│  │ RW-NAVI-V1U - NaviBot V1 Ultra 3D结构光   ATO     │     │
│  │ RW-HMD-G1 - Humano G1 通用人形机器人      ETO     │     │
│  │ RW-CB-10 - CoBot-10 大负载协作机器人      ATO     │     │
│  │ RW-RESC-FIR - RescueBot Fire 消防侦察     ETO     │     │
│  └────────────────────────────────────────────────────┘     │
└────────────────────────────────────────────────────────────┘
```

实现方式（复用 SupersessionManager.vue 的远程搜索模式）：
- 使用 `el-select` with `remote` + `filterable` + `remote-method`
- 调用 `GET /cpq/product/model/search?keyword=xxx`
- 选项 label：`${modelCode} - ${modelName}`，suffix 显示 config_type 标签
- 选项 value：modelId

### 3.3 变体选择器行为（Variant Lookup）— 关键交互

**状态 A：未选产品**
- 变体选择器灰色禁用，placeholder：「请先选择产品」

**状态 B：选了 STANDARD 产品**
- 变体选择器出现，调用 `GET /cpq/product/variant/list?modelId=xxx` 加载变体列表
- placeholder：「请选择变体（可选）」
- STANDARD 必选变体（因为 STANDARD 产品的变体就是可售卖 SKU）

**状态 C：选了 ATO 产品**
- 变体选择器出现，加载变体列表
- placeholder：「请选择变体」
- ATO 产品建议必选变体（如果产品有变体定义）

**状态 D：选了 CTO/ETO 产品**
- 变体选择器不出现。如果之前选过变体，清除 variant_id
- 提示文字：「此产品为 CTO/ETO 类型，通过定价规则计算配置后的价格」

**状态 E：选了 BUNDLE 产品**
- 变体选择器不出现。如果之前选过变体，清除 variant_id
- 提示文字：「捆绑包通过组件选择和定价规则确定价格」

### 3.4 变体选中后的连锁反应

当用户选择变体后，自动执行：
1. `entryForm.itemCode` ← `variant.variant_code`（变体编码自动填入物料编码）
2. `entryForm.listPrice` ← `variant.base_price`（变体基础价自动填入目录价）
3. 如果 variant.default_bom_id 有值，暂存供后续 BOM 展开使用

### 3.5 完整交互流程图

```
用户点击「新增条目」
  │
  ├─ 打开对话框
  │    ├─ 产品选择: 空（远程搜索 select）
  │    ├─ 变体选择: 隐藏（灰色占位）
  │    ├─ 物料编码: 空
  │    ├─ 目录价: 0
  │    └─ 其他字段: 默认值
  │
  ├─ 用户在「产品选择」中搜索并选中一个产品
  │    │
  │    ├─ config_type = STANDARD / ATO ?
  │    │    ├─ 是 → 显示变体选择器，加载变体列表
  │    │    │       │
  │    │    │       ├─ 用户选择变体
  │    │    │       │    ├─ 物料编码 ← variant.variant_code
  │    │    │       │    └─ 目录价 ← variant.base_price
  │    │    │       │
  │    │    │       └─ 用户不选变体 (STANDARD 则校验提示)
  │    │    │            └─ ElMessage.warning('标准产品建议选择具体变体')
  │    │    │
  │    │    └─ 否（CTO/ETO/BUNDLE）→ 隐藏变体选择器
  │    │         └─ 清除 variant_id，显示类型提示文字
  │    │
  │    └─ 回到表单，用户填写其他字段
  │
  ├─ 用户点击「确定」
  │    ├─ STANDARD/ATO 且未选变体 → 提示选择变体
  │    ├─ 校验通过 → 提交 { model_id, variant_id, item_code, list_price, ... }
  │    └─ 提交成功 → 关闭对话框，刷新列表
```

---

## 四、条目列表展示变化

### 4.1 表头变化

**修改前**：
| 物料编码 | 产品ID | 目录价 | 成本价 | 最低价 | 区域 | 渠道 | 状态 | 操作 |

**修改后**：
| 产品 | 变体 | 物料编码 | 目录价 | 成本价 | 最低价 | 区域 | 渠道 | 状态 | 操作 |

### 4.2 各列渲染逻辑

**「产品」列**（替代「产品ID」）：
- 数据来源：后端 join 返回 `modelCode` + `modelName`
- 渲染：`<span>{{ row.modelCode }} - {{ row.modelName }}</span>`
- 点击可跳转到产品模型详情（预留）

**「变体」列**（新增）：
- variant_id 有值 → 显示 `variant_code - variant_name`
- variant_id NULL → 显示灰色文字「模型级定价」
- tooltip 显示 config_type 说明

**「物料编码」列**（保留，语义调整）：
- variant_id 有值 → 显示 variant_code（变体编码，即确定 SKU 编码）
- variant_id NULL → 显示 item_code（如果有）或 `-`
- 列标题建议改为「SKU / 物料编码」

### 4.3 行颜色/标记

- 变体级定价行：正常颜色，无额外标记
- 模型级定价行（variant_id = NULL）：行首增加蓝色竖线标记或小圆点，hover 时 tooltip 显示「此条目为模型级定价，通过定价规则计算产品价格」，帮助用户区分两种定价模式

---

## 五、渠道价格表单同样的改造

渠道价格（`ChannelPriceList.vue`）的「产品ID」字段存在同样问题，做同样的改造：

### 5.1 表单变化

**修改前**：
```
产品ID: [el-input-number, 手动输入数字ID]
```

**修改后**：
```
产品选择: [远程搜索 select: 型号编码 - 型号名称]
变体选择: [级联 select: 变体编码 - 变体名称] (条件显示)
渠道目录价: [el-input-number: 选变体后自动填入 base_price]
```

逻辑与价格手册条目完全一致，复用同一套 ModelLookup + VariantLookup 组件。

### 5.2 列表变化

| 修改前 | 修改后 |
|--------|--------|
| 渠道代码 | 渠道代码 |
| 产品ID | **产品**（modelCode - modelName） |
| 渠道目录价 | 渠道目录价 |
| 折扣率(%) | 折扣率(%) |
| -- | **变体**（variant_code 或「模型级」） |

---

## 六、四种配置类型完整场景矩阵

> 智元机器人产品数据：STANDARD=30, ATO=52, ETO=18，无 CTO 和 BUNDLE 类型产品（BUNDLE 为预留类型）。

| 场景 | 产品类型 | 变体选择器 | 变体必选？ | 定价方式 | 示例 |
|------|---------|-----------|-----------|---------|------|
| S1 | STANDARD | 显示，加载变体列表 | 是 | 变体 base_price | SweepBot S1 Pro 白色款 → ¥4,999 |
| S2 | ATO | 显示，加载变体列表 | 建议是 | 变体 base_price | NaviBot V1 Ultra 5G版 → ¥8,499 |
| S3 | CTO | 隐藏 | N/A | 定价规则动态计算 | （当前数据无CTO产品） |
| S4 | ETO | 隐藏 | N/A | 定价规则+手工报价 | Humano G1 Pro 定制灵巧操作人形 |
| S5 | BUNDLE | 隐藏 | N/A | 组件定价+捆绑规则 | 教育机器人教室套装（6×STEM-K2+教案） |

**注意**：场景 S1 和 S2 下如果产品还没有定义任何变体：
- 对话框仍然可以打开，变体选择器显示为 disabled + 提示文字「该产品尚未定义变体，请先在产品模型中创建变体」
- 确定按钮 disabled（变体必选的场景下）或允许跳过（如果不是必选）

---

## 七、前端组件架构

### 7.1 新建可复用组件

```
src/components/cpq/
├── ModelLookup.vue          # 产品型号远程搜索选择器（通用）
├── VariantLookup.vue        # 变体级联选择器（依赖选中型号）
└── VariantManager.vue       # 变体管理内嵌组件（用于产品模型行展开）
```

### 7.2 ModelLookup.vue 规格

**Props**：
| 属性 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| modelValue | number \| null | 是 | null | v-model 绑定的 modelId |
| placeholder | string | 否 | '搜索产品名称或编码' | 输入框占位符 |
| disabled | boolean | 否 | false | 是否禁用 |
| filterConfigType | string[] | 否 | [] | 筛选特定配置类型, 如 ['STANDARD','ATO'] |
| size | string | 否 | 'default' | 组件尺寸 |

**Emits**：
| 事件 | 参数 | 说明 |
|------|------|------|
| update:modelValue | modelId: number | v-model 双向绑定 |
| select | model: CpqProductModelVo | 选中产品时触发，带完整产品信息（含 config_type） |
| clear | - | 清除选择时触发 |

**内部实现**：
- 使用 `el-select` remote + filterable
- 调用 `GET /cpq/product/model/search?keyword=xxx`
- 格式化选项为 `modelCode - modelName`，尾部显示 config_type 标签
- `select` 事件传递完整 model 对象（调用方从中获取 config_type 决定后续交互）

### 7.3 VariantLookup.vue 规格

**Props**：
| 属性 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| modelValue | number \| null | 是 | null | v-model 绑定的 variantId |
| modelId | number \| null | 是 | null | 所属产品型号ID |
| required | boolean | 否 | false | 是否必选 |
| disabled | boolean | 否 | false | 手动禁用 |
| placeholder | string | 否 | '请选择变体' | 占位符 |
| size | string | 否 | 'default' | 尺寸 |

**计算属性**：
- `showVariantSelector`：根据 modelId 查询到的产品 config_type 决定是否显示
- `isDisabled`：当 modelId 为空或 config_type 为 CTO/ETO 时返回 true
- `hintText`：当隐藏时显示对应的提示文字

**Emits**：
| 事件 | 参数 | 说明 |
|------|------|------|
| update:modelValue | variantId: number | v-model 双向绑定 |
| select | variant: CpqProductVariantVo | 选中变体时触发，带完整信息（含 base_price, variant_code） |

**内部实现**：
- 监听 modelId 变化，有值时调 `GET /cpq/product/variant/list?modelId=xxx` 加载变体
- modelId 为空时变体列表清空
- `select` 事件携带完整变体对象，调用方自动填充 base_price 和 item_code

### 7.4 在 PriceBookList.vue 中使用

```vue
<!-- 条目对话框表单（片段） -->
<el-form-item label="产品选择" required>
  <ModelLookup
    v-model="entryForm.modelId"
    @select="onModelSelected"
  />
</el-form-item>

<el-form-item v-if="variantSelectorVisible" label="变体选择" :required="variantRequired">
  <VariantLookup
    v-model="entryForm.variantId"
    :model-id="entryForm.modelId"
    :required="variantRequired"
    @select="onVariantSelected"
  />
</el-form-item>
<div v-else-if="entryForm.modelId" class="variant-hint">
  {{ variantHintText }}
</div>

<el-form-item label="物料编码">
  <el-input v-model="entryForm.itemCode" :disabled="true" placeholder="选择变体后自动填充" />
</el-form-item>

<el-form-item label="目录价">
  <el-input-number v-model="entryForm.listPrice" :min="0" :precision="2" />
</el-form-item>
```

```typescript
// script setup 中的关键方法
const variantSelectorVisible = ref(false)
const variantRequired = ref(false)
const variantHintText = ref('')

const onModelSelected = (model: CpqProductModelVo) => {
  entryForm.variantId = undefined  // 清空变体
  entryForm.itemCode = ''          // 清空物料编码

  const ct = model.configType
  if (ct === 'STANDARD' || ct === 'ATO') {
    variantSelectorVisible.value = true
    variantRequired.value = (ct === 'STANDARD')
    variantHintText.value = ''
  } else {
    variantSelectorVisible.value = false
    variantRequired.value = false
    variantHintText.value = ct === 'CTO' ? 'CTO产品通过定价规则计算配置后的价格'
                          : ct === 'ETO' ? 'ETO产品为定制报价，价格在报价时确定'
                          : '捆绑包通过组件选择和定价规则确定价格'
  }
}

const onVariantSelected = (variant: CpqProductVariantVo) => {
  entryForm.itemCode = variant.variantCode   // 自动填入物料编码
  entryForm.listPrice = variant.basePrice     // 自动填入目录价
}
```

### 7.5 ChannelPriceList.vue 改造

与 PriceBookList.vue 完全相同的模式，复用 `ModelLookup` + `VariantLookup`。差异点：
- 渠道价格没有 itemCode 字段，选变体后自动填入 `channelListPrice`（= variant.base_price）
- 表单布局 label-width 从 120px 改为 90px 以保持间距

---

## 八、API 模块设计

### 8.1 新增 API 文件：`src/api/cpq/variant.ts`

```typescript
import request from '@/utils/request'

export interface CpqProductVariantVo {
  variantId: number
  modelId: number
  variantCode: string
  variantName: string
  attributes: Record<string, string>  // JSON object
  defaultBomId?: number
  basePrice: number
  thumbnailUrl?: string
  isDefault: string
  status: string
  // ... 标准审计字段
}

export interface CpqProductVariantBo {
  modelId: number
  variantCode: string
  variantName: string
  attributes: Record<string, string>
  defaultBomId?: number
  basePrice?: number
  status?: string
}

// 获取某个型号的所有变体
export function getVariantList(modelId: number) {
  return request.get<CpqProductVariantVo[]>('/cpq/product/variant/list', {
    params: { modelId }
  })
}

// 新增变体
export function addVariant(data: CpqProductVariantBo) {
  return request.post('/cpq/product/variant', data)
}

// 更新变体
export function updateVariant(data: CpqProductVariantBo & { variantId: number }) {
  return request.put('/cpq/product/variant', data)
}

// 删除变体
export function deleteVariant(variantId: number) {
  return request.delete(`/cpq/product/variant/${variantId}`)
}
```

### 8.2 扩展现有 API：`src/api/cpq/product.ts`

```typescript
// 已有 search 接口，ModelLookup 直接使用
// GET /cpq/product/model/search?keyword=xxx
```

### 8.3 后端 VO 变更

- `CpqPriceBookEntryVo`：新增 `modelCode`、`modelName`、`configType`、`variantCode`、`variantName`（通过 join 查询自动填充，Mapper XML 或 MyBatis-Plus @TableField(exist=false) + Service 层 enrich）
- `CpqChannelPriceVo`：同上
- `CpqProductModelVo.search`：返回字段确保包含 `configType`（用于 ModelLookup 的 select 事件）

---

## 九、实施计划

### 阶段 1：基础产品 Lookup（当前 Sprint 立即执行）
- 创建 `ModelLookup.vue` 通用组件
- 修改 `PriceBookList.vue` 条目表单（产品字段改为远程搜索）
- 修改 `ChannelPriceList.vue` 渠道价格表单
- 修改列表展示（产品ID → 产品名称+编码）
- 后端 VO 增加 join 字段（modelCode/modelName）
- **不做** variant_id 相关内容（保持 NULL）

### 阶段 2：变体实体化（Sprint 3）
- 执行 `cpq_product_variant` DDL + ALTER TABLE entry/channel_price
- 创建 `VariantManager.vue` 内嵌组件（产品模型行展开）
- 创建 `VariantLookup.vue` 通用组件
- 修改 `PriceBookList.vue` 和 `ChannelPriceList.vue` 增加变体选择
- 后端新增 CpqProductVariant 全套 CRUD（Domain/Bo/Vo/Mapper/Service/Controller）
- 种子数据：SweepBot S1P 的 3 个变体（白/黑/银）、CoBot-10 的 4 个变体（负载×防护等级组合）、NaviBot V1 Ultra 的 2 个变体（WiFi/5G通信）

### 阶段 3：定价联动（Sprint 5）
- 报价流程中根据选中变体自动带出价格和 BOM
- 变体级定价与定价规则的优先级处理（变体价 > 规则计算价？待定）

---

## 十、边界情况与异常处理

| 场景 | 处理 |
|------|------|
| STANDARD 产品无变体 | 变体选择器显示「暂无变体，请先去产品模型创建」+ 确定按钮 disabled |
| 选中产品后切换为 ETO | 变体选择器消失，自动清除 variant_id 和 item_code，提示用户 |
| 编辑已有条目时产品已变更类型 | 以当前产品最新状态为准，重新决定是否显示变体选择器 |
| 删除变体但已有条目引用 | 后端校验：有 entry 引用时禁止删除，提示「该变体被 N 个价格条目引用，无法删除」 |
| 产品 config_type 修改 | 前端弹窗确认（见 §2.3），后端允许修改但保留变体数据（标记为不可用） |
| 网络异常 | ModelLookup 搜索失败时显示「搜索失败，请重试」，不阻塞其他字段操作 |
| 变体列表为空 | 显示「该产品尚未定义变体」空状态，不报错 |

---

## 十一、UI 设计原则总结

1. **渐进揭示**：变体选择器根据产品类型动态出现/隐藏，CTO/ETO 用户不受干扰
2. **自动填充**：选变体自动带出物料编码和价格，减少手动输入错误
3. **明确反馈**：每种 config_type 显示不同的提示文字，让用户理解为什么有/没有变体选择器
4. **可复用**：ModelLookup + VariantLookup 作为通用组件，价格手册/渠道价格/未来报价页面共享同一套交互
5. **向后兼容**：阶段 1 不做 variant_id，现有数据和功能不受影响；阶段 2 通过 ALTER TABLE + NULLABLE 字段平滑引入
