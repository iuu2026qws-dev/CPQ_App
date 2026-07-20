# CPQ 定价规则引擎完善 — 详细设计方案

> 版本：v1.0 | 日期：2026-07-16 | 作者：码农
> 关联任务：CPQAPP-005

---

## 1. 概述

### 1.1 背景（代码审查结论）

经逐行审查 `PricingEngineService.java` 及全代码库 cross-reference 验证，结论如下：

```
定价引擎六阶段流水线：已实现 ✅
ConfiguratorController 调用 PricingEngineService：已接入 ✅
cpq_price_rule 表：有数据，后端 CRUD 正常 ✅
前端管理页面 PriceRuleConfig.vue：能录入能存 ✅

问题是：定价规则表中的数据，定价引擎只用了 5% ⚠️
```

**现有引擎中使用定价规则的位置：只有 Phase 5 的 `getMaxDiscount()`**

```java
// 当前的 Phase 5 —— 只做了一件事：
wrapper.eq(CpqPriceRule::getRuleType, "DISCOUNT_LIMIT");  // 只查这一种规则
// 用字符串替换硬解析 JSON：
String value = condition.replaceAll("[{}\" ]", "")
    .replace("maxDiscount:", "").trim();  // 不是 JSON 解析器
// actionJson：从未被任何规则类型使用
```

**四种规则类型实际状态：**

| 规则类型 | 前端录入 | 写入 DB | 引擎读取 | 实际效果 |
|---------|:--:|:--:|:--:|------|
| DISCOUNT_LIMIT | — | — | ✅ Phase 5 | 折扣上限管控生效 |
| DISCOUNT | ✅ | ✅ | ❌ | 不生效（折扣走的是请求参数 requestDiscount） |
| MARKUP | ✅ | ✅ | ❌ | 不生效 |
| PROMOTION | ✅ | ✅ | ❌ | 不生效 |
| CONTRACT | ✅ | ✅ | ❌ | 不生效（合同价走的是渠道价格表） |

### 1.2 目标

使 `cpq_price_rule` 表中的所有规则类型在定价流水线中完整生效：

1. 用 Gson/Jackson 标准 JSON 解析替换字符串替换，统一 conditionJson/actionJson 的字段语义
2. DISCOUNT 规则：Phase 5 接入 conditionJson（客户/区域/渠道/数量区间匹配）→ 执行 actionJson 折扣计算
3. MARKUP 规则：Phase 3 多维定价阶段叠加区域/渠道加价
4. PROMOTION 规则：Phase 4 阶梯定价之后叠加促销折扣/满减
5. CONTRACT 规则：Phase 3 作为最高优先级价格覆盖（高于渠道价/区域价）
6. 规则优先级排序 + 多规则命中时的冲突解决策略

### 1.3 不可变约束

- **不改现有前端页面**。`PriceRuleConfig.vue` 当前用 free-form JSON textarea 录入，引擎只需兼容现有字段名
- **不修改 ConfiguratorController 调用签名**。`complete()` 方法签名保持不变
- **不改 cpq_price_rule 表结构**。现有字段足够
- **向后兼容**。没有配置规则时，定价流水线行为与当前完全一致（仅使用 priceBook + requestDiscount）

---

## 2. conditionJson / actionJson 字段语义定义

> **关键认知**：当前前端 `PriceRuleConfig.vue` 是自由 JSON textarea，没有固定 schema。
> 本次方案的核心交付物之一是**明确 conditionJson 和 actionJson 的标准字段定义**，
> 使规则条目可被引擎可靠解析。

### 2.1 conditionJson 通用结构

```json
{
  "product_ids": [1001, 1002],     // 适用产品列表，空=全部产品
  "regions": ["华南", "华东"],       // 适用区域，空=全部区域
  "channels": ["直销", "分销"],      // 适用渠道，空=全部渠道
  "customer_types": ["VIP", "普通"],  // 客户类型，空=全部
  "quantity_range": {              // 数量区间
    "min": 1,
    "max": 100
  },
  "date_range": {                  // 可选，规则级日期范围覆盖
    "start": "2026-01-01",
    "end": "2026-12-31"
  },
  "custom": {                      // 扩展字段
    "min_order_amount": 100000
  }
}
```

**匹配逻辑**：conditionJson 中每个字段都是 AND 关系。字段值为数组时是 OR 关系（如 `regions: ["华南","华东"]` → 华南 OR 华东命中）。

### 2.2 四种规则类型的 actionJson 定义

#### DISCOUNT（折扣规则）

```json
{
  "adjustment_type": "DISCOUNT_PERCENT",   // DISCOUNT_PERCENT | DISCOUNT_FIXED | FLOOR_PRICE
  "adjustment_value": 15,                  // 百分比折扣=15% off，固定折扣=金额，底价=最低单价
  "adjustment_unit": "PERCENT",            // PERCENT | CNY | USD
  "stackable": false,                      // 是否可与其他折扣叠加
  "approval_trigger": "auto"               // auto=超审批阈值自动触发审批 | manual=仅提示
}
```

#### MARKUP（加价规则）

```json
{
  "adjustment_type": "MARKUP_PERCENT",     // MARKUP_PERCENT | MARKUP_FIXED | REGION_SURCHARGE
  "adjustment_value": 5,                   // 百分比加价=5%，固定加价=金额
  "adjustment_unit": "PERCENT",            // PERCENT | CNY
  "apply_to": "ALL"                        // ALL | BASE_PRICE_ONLY | TIER_PRICE_ONLY
}
```

#### PROMOTION（促销规则）

```json
{
  "adjustment_type": "PROMOTION_DISCOUNT",  // PROMOTION_DISCOUNT | BUY_X_GET_Y | THRESHOLD_REDUCTION
  "adjustment_value": 20,                   // 折扣百分比 / 满减金额
  "adjustment_unit": "PERCENT",             // PERCENT | CNY
  "min_quantity": 10,                       // 最少购买数量触发条件
  "gift_product_id": null,                  // BUY_X_GET_Y 时的赠品ID
  "stackable": false
}
```

#### CONTRACT（合同价规则）

```json
{
  "adjustment_type": "CONTRACT_PRICE",       // CONTRACT_PRICE | CONTRACT_DISCOUNT
  "adjustment_value": 850.00,               // 合同固定价（元）或合同折扣百分比
  "adjustment_unit": "CNY",                 // CNY | PERCENT
  "contract_ref": "HT-2026-0034",           // 合同编号（追溯）
  "override_all": true                      // true=合同价覆盖所有其他规则
}
```

---

## 3. 架构设计

### 3.1 改造后的定价流水线

```
用户配置产品 → ConfiguratorController.complete()
    │
    ▼
┌─ PricingEngineService.calculatePrice() ──────────────────────────────┐
│                                                                      │
│  Phase 1: 获取基础价（PriceBookEntry.listPrice）                      │
│      │                                                               │
│      ▼                                                               │
│  Phase 2: BOM 成本累加（外部传入）                                     │
│      │                                                               │
│      ▼                                                               │
│  Phase 3: 多维定价覆盖                                                │
│      │  ① CONTRACT 规则覆盖（最高优先级）  ← 【新增接入】              │
│      │  ② 渠道价（CpqChannelPrice）                                  │
│      │  ③ 区域价（PriceBookEntry.regionCode）                        │
│      │  ④ MARKUP 规则叠加               ← 【新增接入】               │
│      │  ⑤ 目录价（fallback）                                        │
│      ▼                                                               │
│  Phase 4: 阶梯定价（VolumeTier）                                      │
│      │                                                               │
│      ▼                                                               │
│  Phase 4.5: 促销规则                ← 【新增阶段】                     │
│      │  PROMOTION 规则叠加（折扣/满减/买赠）                           │
│      ▼                                                               │
│  Phase 5: 折扣应用                                                    │
│      │  ① DISCOUNT 规则计算折扣率     ← 【新增接入】                   │
│      │  ② DISCOUNT_LIMIT 规则校验上限 ← 【已有，JSON解析升级】         │
│      │  ③ requestedDiscount 作为手工协商折扣覆盖                     │
│      ▼                                                               │
│  Phase 6: 净价计算 + 成本底线检查（不变）                              │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### 3.2 新增/修改类图

```
┌─────────────────────────────────────────────────────────────┐
│                 PricingEngineService (修改)                   │
│  - priceRuleMapper: CpqPriceRuleMapper                       │
│  - ruleExecutor: PriceRuleExecutor (新增)                    │
│                                                              │
│  + calculatePrice(...) : PriceResult                         │
│  + getBestPrice(...) : BigDecimal     [改: 接入CONTRACT/MARKUP] │
│  + applyDiscount(...) : BigDecimal    [改: 接入DISCOUNT规则]   │
│  + applyPromotions(...) : BigDecimal  [新增]                  │
└─────────────────────────────────────────────────────────────┘
        │
        │ 依赖
        ▼
┌─────────────────────────────────────────────────────────────┐
│                   PriceRuleExecutor (新增)                    │
│                                                              │
│  + executeRules(ruleType, context) : List<RuleResult>        │
│  - conditionParser: ConditionParser                          │
│  - actionParser: ActionParser                                │
│  - resolveConflict(results) : RuleResult                     │
└─────────────────────────────────────────────────────────────┘
        │
        ├──────────────────────────────────────┐
        ▼                                      ▼
┌──────────────────────┐    ┌──────────────────────┐
│   ConditionParser     │    │    ActionParser       │
│   (新增)              │    │    (新增)              │
│                       │    │                       │
│ + matches(            │    │ + parseAction(        │
│     conditionJson,    │    │     actionJson)       │
│     context)          │    │     : ActionDef       │
│     : boolean         │    │                       │
│                       │    │ + getAdjustmentValue( │
│ - matchProduct()      │    │     actionDef,        │
│ - matchRegion()       │    │     basePrice)        │
│ - matchChannel()      │    │     : BigDecimal       │
│ - matchQuantity()     │    │                       │
│ - matchCustom()       │    │                       │
└──────────────────────┘    └──────────────────────┘
```

### 3.3 规则加载策略

```
Phase 3 开始时一次性加载所有生效规则：
    WHERE tenant_id = ? 
      AND status = '0'
      AND effective_date <= today()
      AND (expiry_date IS NULL OR expiry_date >= today())
    ORDER BY rule_type, priority DESC

规则缓存到 Map<RuleType, List<CpqPriceRule>>，各阶段按需取用。
不引入 Redis 缓存（避免多实例脏读），每次 calculatePrice 调用重新加载。
```

---

## 4. 各阶段实现细节

### 4.1 Phase 3 改造：getBestPrice() — 接入 CONTRACT + MARKUP

**改造前的逻辑链**：
```
ChannelPrice → RegionalPrice → ListPrice
```

**改造后的逻辑链**：
```
① CONTRACT 规则匹配？
  → 命中：直接返回合同价，跳过后续所有定价逻辑
  → 未命中：继续

② ChannelPrice 存在？
  → 命中：price = channelPrice
  → 未命中：继续

③ RegionalPrice 存在？
  → 命中：price = regionalPrice
  → 未命中：price = fallbackPrice

④ MARKUP 规则匹配？
  → 遍历 MARKUP 规则列表（按 priority DESC）
  → ConditionParser.matches(rule.conditionJson, context) 为 true？
    → actionJson 中 adjustmentType = MARKUP_PERCENT：
      price = price * (1 + adjustmentValue/100)
    → actionJson 中 adjustmentType = MARKUP_FIXED：
      price = price + adjustmentValue
  → 未命中任何规则：price 不变

⑤ 返回 price
```

**伪代码**：
```java
public BigDecimal getBestPrice(..., PricingContext ctx) {
    // ① CONTRACT 规则（最高优先级，直接覆盖）
    List<CpqPriceRule> contractRules = getRulesByType("CONTRACT");
    for (CpqPriceRule rule : contractRules) {
        if (conditionParser.matches(rule.getConditionJson(), ctx)) {
            ActionDef action = actionParser.parse(rule.getActionJson());
            return action.getAdjustmentValue(); // 直接返回合同价
        }
    }

    BigDecimal price = fallbackPrice;

    // ② 渠道价
    // ...existing logic...

    // ③ 区域价
    // ...existing logic...

    // ④ MARKUP 规则叠加
    List<CpqPriceRule> markupRules = getRulesByType("MARKUP");
    for (CpqPriceRule rule : markupRules) {
        if (conditionParser.matches(rule.getConditionJson(), ctx)) {
            ActionDef action = actionParser.parse(rule.getActionJson());
            price = applyMarkup(price, action);
        }
    }

    return price;
}
```

### 4.2 Phase 4.5 新增：applyPromotions() — 接入 PROMOTION

**位置**：Phase 4（阶梯定价）之后、Phase 5（折扣）之前。

**原因**：促销通常基于"阶梯调整后的价格 × 采购数量"来计算（如满减、买赠），
不应在阶梯定价之前执行。

**逻辑**：
```
遍历 PROMOTION 规则列表（按 priority DESC）
  → ConditionParser.matches(rule.conditionJson, ctx) 为 true？
    → adjustmentType = PROMOTION_DISCOUNT：
      price = price * (1 - adjustmentValue/100)
    → adjustmentType = BUY_X_GET_Y：
      总价不变，但标记赠品（前端展示用）
    → adjustmentType = THRESHOLD_REDUCTION：
      if totalAmount >= threshold → totalAmount -= reductionAmount
```

**伪代码**：
```java
public PromotionResult applyPromotions(BigDecimal basePrice, BigDecimal quantity, 
                                        PricingContext ctx) {
    List<CpqPriceRule> promoRules = getRulesByType("PROMOTION");
    BigDecimal adjustedPrice = basePrice;
    String promoDesc = null;
    Long giftProductId = null;

    for (CpqPriceRule rule : promoRules) {
        if (!conditionParser.matches(rule.getConditionJson(), ctx)) continue;

        ActionDef action = actionParser.parse(rule.getActionJson());
        switch (action.getAdjustmentType()) {
            case "PROMOTION_DISCOUNT":
                adjustedPrice = adjustedPrice.multiply(
                    BigDecimal.ONE.subtract(action.getAdjustmentValue().divide(HUNDRED)));
                promoDesc = "促销折扣 " + action.getAdjustmentValue() + "%";
                break;
            case "THRESHOLD_REDUCTION":
                BigDecimal total = adjustedPrice.multiply(quantity);
                if (total.compareTo(action.getThreshold()) >= 0) {
                    adjustedPrice = total.subtract(action.getAdjustmentValue())
                        .divide(quantity, 2, RoundingMode.HALF_UP);
                    promoDesc = "满减 " + action.getAdjustmentValue() + "元";
                }
                break;
            case "BUY_X_GET_Y":
                giftProductId = action.getGiftProductId();
                promoDesc = "买赠活动";
                break;
        }
    }

    return new PromotionResult(adjustedPrice, promoDesc, giftProductId);
}
```

### 4.3 Phase 5 改造：applyDiscount() — 接入 DISCOUNT 规则 + JSON 解析升级

**改造前**：
```
getMaxDiscount() → 查 DISCOUNT_LIMIT 规则 → 字符串替换取 maxDiscount
applyDiscount()  → min(requestedDiscount, maxDiscount)
```

**改造后**：
```
① 加载 DISCOUNT 规则列表（ruleType=DISCOUNT）
② ConditionParser 匹配 → 提取 actionJson 中的折扣率
③ 多规则命中 → 按 priority DESC 取第一个 / 叠加策略
④ 计算折扣后的单价
⑤ DISCOUNT_LIMIT 规则校验：如果折扣超过上限 → 触发审批
⑥ 如果有 requestedDiscount（手工协商折扣）→ 以手工折扣覆盖规则折扣
   （手工折扣 > 规则折扣，但仍受 DISCOUNT_LIMIT 上限约束）
```

**伪代码**：
```java
public DiscountResult applyDiscount(BigDecimal tierPrice, BigDecimal requestedDiscount,
                                     PricingContext ctx) {
    // ① 从 DISCOUNT 规则计算折扣率
    BigDecimal ruleDiscount = BigDecimal.ZERO;
    List<CpqPriceRule> discountRules = getRulesByType("DISCOUNT");
    for (CpqPriceRule rule : discountRules) {
        if (conditionParser.matches(rule.getConditionJson(), ctx)) {
            ActionDef action = actionParser.parse(rule.getActionJson());
            if ("DISCOUNT_PERCENT".equals(action.getAdjustmentType())) {
                ruleDiscount = action.getAdjustmentValue().divide(HUNDRED);
            } else if ("DISCOUNT_FIXED".equals(action.getAdjustmentType())) {
                ruleDiscount = action.getAdjustmentValue()
                    .divide(tierPrice, 4, RoundingMode.HALF_UP);
            }
            break; // 取第一个命中规则（priority 已排序）
        }
    }

    // ② 手工折扣覆盖规则折扣（如果手工折扣更大）
    BigDecimal effectiveDiscount = ruleDiscount;
    if (requestedDiscount != null && requestedDiscount.compareTo(ruleDiscount) > 0) {
        effectiveDiscount = requestedDiscount;
    }

    // ③ DISCOUNT_LIMIT 规则校验
    BigDecimal maxDiscount = getMaxDiscount(ctx);  // 改为标准 JSON 解析
    if (effectiveDiscount.compareTo(maxDiscount) > 0) {
        result.setNeedsApproval(true);
        result.setApprovalReason("申请折扣 " + effectiveDiscount.multiply(HUNDRED) 
            + "% 超出上限 " + maxDiscount.multiply(HUNDRED) + "%");
        effectiveDiscount = maxDiscount;
    }

    return new DiscountResult(effectiveDiscount, ruleDiscount, 
        ruleDiscount.compareTo(BigDecimal.ZERO) > 0 ? "DISCOUNT" : null);
}
```

### 4.4 getMaxDiscount() — JSON 解析升级

**改造前（3 行）**：
```java
String value = condition.replaceAll("[{}\" ]", "").replace("maxDiscount:", "").trim();
return new BigDecimal(value);
```

**改造后**：
```java
public BigDecimal getMaxDiscount(PricingContext ctx) {
    List<CpqPriceRule> limitRules = getRulesByType("DISCOUNT_LIMIT");
    for (CpqPriceRule rule : limitRules) {
        if (conditionParser.matches(rule.getConditionJson(), ctx)) {
            JsonNode condition = mapper.readTree(rule.getConditionJson());
            if (condition.has("max_discount") || condition.has("maxDiscount")) {
                String val = condition.has("max_discount") 
                    ? condition.get("max_discount").asText()
                    : condition.get("maxDiscount").asText();
                return new BigDecimal(val);
            }
        }
    }
    // 默认：20% 折扣上限
    return new BigDecimal("0.20");
}
```

### 4.5 规则冲突解决策略

当同一规则类型有多个规则同时命中时：

```
1. 按 priority DESC 排序（priority 越大优先级越高）
2. 取第一个命中规则的 actionJson 执行（除非 actionJson.stackable=true）
3. stackable=true → 按 priority 顺序依次叠加
```

| 规则类型 | 冲突策略 | 理由 |
|---------|---------|------|
| CONTRACT | 取第一个命中（最高 priority） | 一个产品不应有多个合同价 |
| MARKUP | 默认叠加（所有命中的加价累加） | 区域加价+渠道加价需叠加 |
| PROMOTION | 取第一个命中 | 促销通常互斥 |
| DISCOUNT | 取第一个命中 | 折扣通常取最优 |
| DISCOUNT_LIMIT | 取最严格的（最小 maxDiscount） | 风控原则 |

### 4.6 PricingContext — 规则匹配上下文

将所有匹配条件封装为上下文对象，避免每个匹配函数重复传参：

```java
public class PricingContext {
    private Long productModelId;
    private Long variantId;
    private String region;
    private String channel;
    private String customerType;
    private BigDecimal quantity;
    private BigDecimal orderAmount;
    private LocalDate pricingDate;
    // getters/setters...
}
```

---

## 5. 代码结构

### 5.1 新增文件

| 文件 | 路径 | 职责 |
|------|------|------|
| `PriceRuleExecutor.java` | `ruoyi-cpq-pricing/.../service/` | 规则执行器：加载规则 → 条件匹配 → 动作执行 → 冲突解决 |
| `ConditionParser.java` | `ruoyi-cpq-pricing/.../service/` | 条件解析器：解析 conditionJson 与 PricingContext 做匹配 |
| `ActionParser.java` | `ruoyi-cpq-pricing/.../service/` | 动作解析器：解析 actionJson 提取调整类型/值/单位 |
| `ActionDef.java` | `ruoyi-cpq-pricing/.../domain/` | 动作定义 VO：adjustmentType, adjustmentValue, adjustmentUnit, stackable 等 |
| `PricingContext.java` | `ruoyi-cpq-pricing/.../domain/` | 定价上下文 VO：封装所有匹配条件 |
| `PromotionResult.java` | `ruoyi-cpq-pricing/.../domain/` | 促销结果 VO：adjustedPrice, promoDesc, giftProductId |
| `DiscountResult.java` | `ruoyi-cpq-pricing/.../domain/` | 折扣结果 VO：effectiveDiscount, ruleDiscount, ruleName |

### 5.2 修改文件

| 文件 | 改动内容 | 工时 |
|------|---------|:--:|
| `PricingEngineService.java` | Phase 3 接入 CONTRACT + MARKUP；新增 Phase 4.5 PROMOTION；Phase 5 接入 DISCOUNT + JSON 解析升级；注入 PriceRuleExecutor | 1.5 天 |
| `PricingEngineController.java` | 测试用例更新（增加规则相关测试参数） | 0.25 天 |
| `ConfiguratorController.java` | `complete()` 中传递客户类型等上下文参数给 `calculatePrice()` | 0.25 天 |

### 5.3 不改的文件

| 文件 | 原因 |
|------|------|
| `CpqPriceRule.java` (Domain) | 现有字段足够 |
| `CpqPriceRuleMapper.java` | 现有查询方法够用 |
| `CpqPriceRuleController.java` | CRUD 逻辑不变 |
| `CpqPriceRuleServiceImpl.java` | CRUD 逻辑不变 |
| `PriceRuleConfig.vue` | 前端页面不变，仅需引导用户按约定 JSON schema 填写 |
| 数据库表 `cpq_price_rule` | 不改 DDL |

---

## 6. 研发计划（合计 3 天）

| 阶段 | 内容 | 产出 | 工时 |
|:--:|------|------|:--:|
| 1 | **JSON 解析器开发** | ConditionParser.java + ActionParser.java + ActionDef.java + PricingContext.java | 0.5 天 |
| 2 | **规则执行器开发** | PriceRuleExecutor.java（加载/匹配/冲突解决） | 0.5 天 |
| 3 | **Phase 3 改造** | getBestPrice() 接入 CONTRACT + MARKUP | 0.5 天 |
| 4 | **Phase 4.5 新增 + Phase 5 改造** | applyPromotions() + applyDiscount() 改造 + JSON 解析升级 | 0.5 天 |
| 5 | **ConfiguratorController 联调** | PricingContext 传递 + 端到端定价验证 | 0.25 天 |
| 6 | **测试验证** | 单元测试 + Playwright E2E（配置规则 → 选品 → 查看最终价验证规则生效） | 0.25 天 |
| — | **文档** | 本文档 + API 变更说明 | 0.25 天 |
| | | **合计** | **2.75 天 → 3 天** |

---

## 7. 测试策略

### 7.1 单元测试

| 测试类 | 覆盖内容 |
|--------|---------|
| `ConditionParserTest` | 各种 conditionJson 组合的匹配/不匹配场景 |
| `ActionParserTest` | 四种规则类型的 actionJson 解析 |
| `PriceRuleExecutorTest` | 多规则命中时的冲突解决 |
| `PricingEngineServiceTest` | 端到端六阶段流水线（mock mapper） |

### 7.2 集成测试（Playwright E2E）

```
场景 1：CONTRACT 规则生效
  1. 在 PriceRuleConfig 创建 CONTRACT 规则：conditionJson={product_ids:[测试产品ID]}, actionJson={adjustment_type:"CONTRACT_PRICE",adjustment_value:500,adjustment_unit:"CNY"}
  2. 进入 Configurator 选该产品 → complete
  3. 验证：返回 netPrice = 500（合同价直接覆盖）

场景 2：MARKUP 规则叠加
  1. 创建 MARKUP 规则：region=华南, 加价 5%
  2. 选产品（华南区域）→ complete
  3. 验证：bestMatchPrice = 基础价 × 1.05

场景 3：PROMOTION 促销折扣
  1. 创建 PROMOTION 规则：满 10 件折扣 20%
  2. 选产品，quantity=10 → complete
  3. 验证：tierAdjustedPrice 之后叠加了 20% 促销折扣

场景 4：DISCOUNT 规则 + DISCOUNT_LIMIT 上限
  1. 创建 DISCOUNT 规则：折扣 25%
  2. DISCOUNT_LIMIT 默认上限 20%
  3. 验证：最终折扣 = 20%，needsApproval=true
```

### 7.3 回归测试

- 无规则配置时，定价流水线行为与改动前完全一致
- `PricingEngineController` 测试端点行为不变
- `ConfiguratorController.complete()` 返回格式不变（PriceResult 增加 promoDesc 字段，非破坏性）

---

## 8. 风险与注意事项

### 8.1 技术风险

| 风险 | 等级 | 缓解措施 |
|------|:--:|------|
| 现有生产环境 cpq_price_rule 表数据格式与标准 schema 不兼容 | 🟡 中 | ActionParser 对无法解析的 actionJson 返回 null 并 log.warn，不阻断流水线 |
| CONTRACT 规则覆盖后跳过渠道价/区域价，可能导致价格低于预期 | 🟡 中 | CONTRACT 规则必须显式设置 `override_all:true`；且计为最高优先级，定价管理员需知晓 |
| 多规则命中时叠加策略与客户期望不一致 | 🟢 低 | 默认取最高优先级不叠加，MARKUP 例外需产品确认 |
| 扫描所有 DISCOUNT 规则而非仅 DISCOUNT_LIMIT 增加查询耗时 | 🟢 低 | 一次性加载所有规则（~ 十几条），无性能问题 |

### 8.2 业务确认项（需产品经理确认）

1. **conditionJson 中的字段名是否与 CRM 主数据对齐？** 如 `customer_types` 的取值需要与 CRM 中客户分类字段一一对应
2. **MARKUP 规则是否需要叠加？** 还是与 DISCOUNT 一样取最高优先级命中？
3. **手工折扣（requestedDiscount）与 DISCOUNT 规则的关系**：当前方案是手工折扣覆盖规则折扣，是否正确？
4. **PROMOTION 的满减阈值是基于"单价×数量"还是"阶梯调整价×数量"？** 当前方案是后者

---

## 9. 附录

### 9.1 与现有定价模块设计文档的对齐

| 设计文档 PRC-ID | 功能 | CPQAPP-005 接入点 |
|------|------|------|
| PRC-001 | 基础价格手册管理 | 不受影响 |
| PRC-002 | 多维定价（渠道>区域>目录） | Phase 3 改造，CONTRACT + MARKUP 插入管道 |
| PRC-003 | 折扣阈值管控 | Phase 5 DISCOUNT 规则 + DISCOUNT_LIMIT 升级 |
| PRC-004 | 阶梯定价 | 不受影响（Phase 4 不变） |
| PRC-005 | 促销定价 | Phase 4.5 新增 PROMOTION 规则 |
| PRC-006 | 合同定价 | Phase 3 CONTRACT 规则接入 |

### 9.2 API 变更说明

**PricingEngineController**（测试端点，无破坏性变更）：
```bash
# 现有调用方式不变：
POST /cpq/engine/pricing/calculate?productModelId=1&quantity=10&...
# 新增可选参数（测试用）：
&customerType=VIP    # 客户类型，用于规则匹配
&orderAmount=500000  # 订单金额，用于满减促销匹配
```

**ConfiguratorController**（生产端点，无破坏性变更）：
- `complete()` 方法签名不变
- `PriceResult` 新增非破坏性字段：`promoDesc: String`, `giftProductId: Long`

### 9.3 参考

- CSP 执行引擎设计方案：`CPQ_CSP执行引擎_设计方案.md`（同为"有数据无引擎"问题的解决案例）
- PricingEngineService 当前代码：`ruoyi-cpq-pricing/.../service/PricingEngineService.java`
- 定价规则管理页面：`cpq-portal/src/views/pricing/PriceRuleConfig.vue`
- 后端功能设计文档：`CPQ_后端功能设计.md` §5.2 定价引擎
