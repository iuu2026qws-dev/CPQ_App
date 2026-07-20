# CPQ CSP 约束求解引擎 — 完整设计方案

> 版本：v1.0 | 日期：2026-07-16 | 作者：码农
> 关联任务：CPQAPP-004

---

## 1. 概述

### 1.1 背景

`cpq_config_rule` 表已建好，管理页面能 CRUD，但销售在 Configurator 中选属性时，规则完全不生效。数据被存储后从未被读取、解析和执行。

### 1.2 目标

实现完整的规则执行管线，使 `cpq_config_rule` 表中的规则在配置器中实时生效。

### 1.3 核心约束

- 每次属性选择变化后，必须在 **100ms 内**返回约束传播结果
- 支持增量更新：只重算受影响的规则，不全量重算
- 前端 Configurator 现有代码不需要改——它已经在调 `POST /cpq/configure/propagate`，只是后端返回的是桩数据

---

## 2. 架构设计

### 2.1 整体管线

```
用户选择属性
    │
    ▼
POST /cpq/configure/propagate?modelId={id}
    │  payload: { selections: { "颜色":"珍珠白", "功率":5 } }
    ▼
┌──────────────────────────────────────────────────────┐
│                 RuleEngine（新增）                    │
│                                                      │
│  ① RuleLoader.load(modelId)                          │
│       │  WHERE model_id=? AND status='0'             │
│       │  AND effective_date <= today()               │
│       │  AND (expiry_date IS NULL OR ...)            │
│       │  ORDER BY priority DESC                      │
│       ▼                                              │
│  ② ConditionEvaluator.evaluate(rule, selections)      │
│       │  解析 conditionExpr JSON                      │
│       │  递归比对 selections                          │
│       │  支持 AND/OR 嵌套                            │
│       ▼                                              │
│  ③ ActionExecutor.execute(rule)                      │
│       │  VALIDATION → conflicts[]                    │
│       │  ALERT → warnings[]                          │
│       │  VISIBILITY → hiddenAttrs[]                  │
│       │  SELECTION → suggestions[]                   │
│       ▼                                              │
│  ④ ConstraintPropagator.propagate(results)            │
│       │  MAC-3 算法：当一个选项被禁用后               │
│       │  → 向前传播到依赖该选项的其他规则              │
│       │  → 递归重新评估                              │
│       ▼                                              │
│  ⑤ 组装响应                                          │
│       {                                              │
│         attributeStates: { "颜色":"available", ... }, │
│         conflicts: [...],                             │
│         warnings: [...],                              │
│         suggestions: [...]                            │
│       }                                              │
└──────────────────────────────────────────────────────┘
    │
    ▼
前端 Configurator 更新 OptionCard 状态
    ✓ 可用 / ⚠ 冲突 / ✗ 禁用 / ⊘ 隐藏
```

### 2.2 模块层次

```
ruoyi-modules/ruoyi-cpq-config/
└── src/main/java/org/dromara/cpq/config/
    ├── controller/
    │   └── ConfiguratorController.java          ← 修改：接入 RuleEngine
    ├── engine/                                   ← 新增目录
    │   ├── RuleEngine.java                       ← 入口 + 管线编排
    │   ├── RuleLoader.java                       ← 加载有效规则
    │   ├── ConditionEvaluator.java               ← 条件表达式解析器
    │   ├── ActionExecutor.java                   ← 动作表达式执行器
    │   ├── ConstraintPropagator.java             ← MAC-3 约束传播
    │   └── model/                                ← 引擎内部数据模型
    │       ├── ParsedCondition.java
    │       ├── ParsedAction.java
    │       ├── PropagationResult.java
    │       └── AttributeState.java
    └── service/
        └── ICpqConfigRuleService.java            ← 已有，RuleLoader 调用
```

---

## 3. 核心组件详细设计

### 3.1 RuleEngine（入口 + 管线编排）

```java
@Service
public class RuleEngine {

    private final RuleLoader ruleLoader;
    private final ConditionEvaluator conditionEvaluator;
    private final ActionExecutor actionExecutor;
    private final ConstraintPropagator constraintPropagator;

    /**
     * 完整的规则评估管线
     *
     * @param modelId     产品ID
     * @param selections  用户当前选择的属性值 Map<attrName, value>
     * @param allAttrNames 该产品全部属性名（用于 VISIBILITY 反向计算）
     * @return PropagationResult 包含 conflicts / warnings / suggestions / attributeStates
     */
    public PropagationResult propagate(
            Long modelId,
            Map<String, Object> selections,
            List<String> allAttrNames) {

        // 1. 加载有效规则
        List<CpqConfigRule> rules = ruleLoader.loadEffectiveRules(modelId);

        // 2. 逐条评估
        List<PropagationResult.Conflict> conflicts = new ArrayList<>();
        List<PropagationResult.Warning> warnings = new ArrayList<>();
        List<PropagationResult.Suggestion> suggestions = new ArrayList<>();
        Set<String> hiddenAttrs = new HashSet<>();

        for (CpqConfigRule rule : rules) {
            // 条件不匹配 → 跳过
            if (!conditionEvaluator.evaluate(rule.getConditionExpr(), selections)) {
                continue;
            }

            // 根据规则类型执行动作
            ParsedAction action = ParsedAction.from(rule.getActionExpr(), rule.getRuleType());
            ActionResult result = actionExecutor.execute(action, allAttrNames);

            switch (rule.getRuleType()) {
                case "VALIDATION":
                    if (result.conflict != null) {
                        result.conflict.setRuleName(rule.getRuleName());
                        result.conflict.setMessage(rule.getErrorMessage());
                        result.conflict.setSeverity(rule.getSeverity());
                        conflicts.add(result.conflict);
                    }
                    break;
                case "ALERT":
                    if (result.warning != null) {
                        result.warning.setRuleName(rule.getRuleName());
                        result.warning.setMessage(rule.getErrorMessage());
                        warnings.add(result.warning);
                    }
                    break;
                case "VISIBILITY":
                    hiddenAttrs.addAll(result.hiddenAttributes);
                    break;
                case "SELECTION":
                    if (result.suggestion != null) {
                        result.suggestion.setRuleName(rule.getRuleName());
                        suggestions.add(result.suggestion);
                    }
                    break;
            }
        }

        // 3. MAC-3 约束传播
        PropagationResult result = PropagationResult.builder()
            .conflicts(conflicts)
            .warnings(warnings)
            .suggestions(suggestions)
            .build();

        result = constraintPropagator.propagate(result, rules, selections, allAttrNames);

        // 4. 计算属性状态
        Map<String, String> attributeStates = computeAttributeStates(
            allAttrNames, hiddenAttrs, conflicts, result);

        result.setAttributeStates(attributeStates);
        return result;
    }

    /**
     * 计算每个属性的最终状态
     */
    private Map<String, String> computeAttributeStates(
            List<String> allAttrNames,
            Set<String> hiddenAttrs,
            List<PropagationResult.Conflict> conflicts,
            PropagationResult result) {

        Map<String, String> states = new HashMap<>();

        Set<String> conflictingAttrs = conflicts.stream()
            .flatMap(c -> c.getTargetAttrs().stream())
            .collect(Collectors.toSet());

        Set<String> disabledAttrs = result.getDisabledAttributes() != null
            ? result.getDisabledAttributes()
            : Collections.emptySet();

        for (String attrName : allAttrNames) {
            if (hiddenAttrs.contains(attrName)) {
                states.put(attrName, "hidden");
            } else if (conflictingAttrs.contains(attrName)) {
                states.put(attrName, "conflict");
            } else if (disabledAttrs.contains(attrName)) {
                states.put(attrName, "disabled");
            } else {
                states.put(attrName, "available");
            }
        }

        return states;
    }
}
```

### 3.2 RuleLoader（规则加载）

```java
@Component
public class RuleLoader {

    private final ICpqConfigRuleService ruleService;

    /**
     * 加载指定产品的所有有效规则
     * 优先使用产品专属规则，回退到全局规则
     */
    public List<CpqConfigRule> loadEffectiveRules(Long modelId) {
        LocalDate today = LocalDate.now();

        // 1. 加载该产品的专属规则
        List<CpqConfigRule> modelRules = ruleService.lambdaQuery()
            .eq(CpqConfigRule::getModelId, modelId)
            .eq(CpqConfigRule::getStatus, "0")
            .le(CpqConfigRule::getEffectiveDate, today)
            .and(w -> w.isNull(CpqConfigRule::getExpiryDate)
                       .or().ge(CpqConfigRule::getExpiryDate, today))
            .orderByDesc(CpqConfigRule::getPriority)
            .list();

        // 2. 加载全局规则（model_id IS NULL）
        List<CpqConfigRule> globalRules = ruleService.lambdaQuery()
            .isNull(CpqConfigRule::getModelId)
            .eq(CpqConfigRule::getStatus, "0")
            .le(CpqConfigRule::getEffectiveDate, today)
            .and(w -> w.isNull(CpqConfigRule::getExpiryDate)
                       .or().ge(CpqConfigRule::getExpiryDate, today))
            .orderByDesc(CpqConfigRule::getPriority)
            .list();

        // 3. 合并：产品专属优先级高于全局
        List<CpqConfigRule> all = new ArrayList<>(modelRules);
        all.addAll(globalRules);
        all.sort(Comparator.comparing(CpqConfigRule::getPriority).reversed());

        return all;
    }
}
```

### 3.3 ConditionEvaluator（条件表达式解析器）

```java
@Component
public class ConditionEvaluator {

    private static final ObjectMapper mapper = new ObjectMapper();

    /**
     * 解析 conditionExpr JSON 并与当前 selections 比对
     *
     * conditionExpr 支持三种结构：
     *
     * 1. 原子条件：{"attr_name":"颜色","op":"eq","value":"珍珠白"}
     * 2. AND 组合：{"and": [条件1, 条件2, ...]}
     * 3. OR 组合： {"or":  [条件1, 条件2, ...]}
     *
     * AND/OR 支持任意层级嵌套。
     */
    public boolean evaluate(String conditionExpr, Map<String, Object> selections) {
        try {
            JsonNode root = mapper.readTree(conditionExpr);
            return evaluateNode(root, selections);
        } catch (Exception e) {
            log.warn("解析条件表达式失败: {}", conditionExpr, e);
            return false;
        }
    }

    private boolean evaluateNode(JsonNode node, Map<String, Object> selections) {
        // AND 组合
        if (node.has("and")) {
            JsonNode children = node.get("and");
            if (!children.isArray() || children.size() == 0) return false;
            for (JsonNode child : children) {
                if (!evaluateNode(child, selections)) return false;
            }
            return true;
        }

        // OR 组合
        if (node.has("or")) {
            JsonNode children = node.get("or");
            if (!children.isArray() || children.size() == 0) return false;
            for (JsonNode child : children) {
                if (evaluateNode(child, selections)) return true;
            }
            return false;
        }

        // 原子条件
        return evaluateAtomic(node, selections);
    }

    /**
     * 原子条件比较
     *
     * 支持的操作符：
     *   eq      等于
     *   neq     不等于
     *   gt      大于
     *   gte     大于等于
     *   lt      小于
     *   lte     小于等于
     *   in      在列表中（value 为数组）
     *   notIn   不在列表中
     *   contains 包含（字符串）
     *   exists  属性已被选择（无需 value）
     *   notExists 属性未被选择
     */
    private boolean evaluateAtomic(JsonNode node, Map<String, Object> selections) {
        String attrName = node.get("attr_name").asText();
        String op = node.get("op").asText();

        // exists / notExists 不依赖 value
        if ("exists".equals(op)) return selections.containsKey(attrName);
        if ("notExists".equals(op)) return !selections.containsKey(attrName);

        // 用户还没选这个属性 → 条件不满足
        if (!selections.containsKey(attrName)) return false;

        Object selectedValue = selections.get(attrName);
        JsonNode expectedValue = node.get("value");

        if (expectedValue == null) return false;

        switch (op) {
            case "eq":
                return valuesEqual(selectedValue, expectedValue);
            case "neq":
                return !valuesEqual(selectedValue, expectedValue);
            case "gt":
                return compareNumbers(selectedValue, expectedValue) > 0;
            case "gte":
                return compareNumbers(selectedValue, expectedValue) >= 0;
            case "lt":
                return compareNumbers(selectedValue, expectedValue) < 0;
            case "lte":
                return compareNumbers(selectedValue, expectedValue) <= 0;
            case "in":
                if (!expectedValue.isArray()) return false;
                for (JsonNode item : expectedValue) {
                    if (valuesEqual(selectedValue, item)) return true;
                }
                return false;
            case "notIn":
                if (!expectedValue.isArray()) return false;
                for (JsonNode item : expectedValue) {
                    if (valuesEqual(selectedValue, item)) return false;
                }
                return true;
            case "contains":
                return selectedValue.toString().contains(expectedValue.asText());
            default:
                log.warn("未知操作符: {}", op);
                return false;
        }
    }

    private boolean valuesEqual(Object selected, JsonNode expected) {
        String s1 = selected.toString().trim();
        String s2 = expected.isNumber() ? expected.asText() : expected.asText().trim();
        // 数值比较：先试数字
        try {
            double d1 = Double.parseDouble(s1);
            double d2 = Double.parseDouble(s2);
            return Math.abs(d1 - d2) < 0.0001;
        } catch (NumberFormatException e) {
            return s1.equalsIgnoreCase(s2);
        }
    }

    private int compareNumbers(Object selected, JsonNode expected) {
        double d1 = Double.parseDouble(selected.toString());
        double d2 = expected.asDouble();
        return Double.compare(d1, d2);
    }
}
```

### 3.4 ActionExecutor（动作执行器）

```java
@Component
public class ActionExecutor {

    private static final ObjectMapper mapper = new ObjectMapper();

    /**
     * 根据规则类型执行动作
     */
    public ActionResult execute(ParsedAction action, List<String> allAttrNames) {
        switch (action.getRuleType()) {
            case "VALIDATION":
                return executeValidation(action);
            case "ALERT":
                return executeAlert(action);
            case "VISIBILITY":
                return executeVisibility(action);
            case "SELECTION":
                return executeSelection(action);
            default:
                log.warn("未知规则类型: {}", action.getRuleType());
                return ActionResult.empty();
        }
    }

    /**
     * VALIDATION — 硬校验
     *
     * actionExpr 格式：
     *   {"action":"DISABLE_OPTION","target_attr":"功率","value":"10W"}
     *   {"action":"REQUIRE_ATTR","target_attr":"防爆认证"}
     *   {"action":"BLOCK","message":"..."}
     */
    private ActionResult executeValidation(ParsedAction action) {
        ActionResult result = ActionResult.empty();

        if ("DISABLE_OPTION".equals(action.getActionName())) {
            result.setConflict(PropagationResult.Conflict.builder()
                .targetAttrs(List.of(action.getTargetAttr()))
                .disabledValue(String.valueOf(action.getValue()))
                .build());
        } else if ("REQUIRE_ATTR".equals(action.getActionName())) {
            result.setConflict(PropagationResult.Conflict.builder()
                .targetAttrs(List.of(action.getTargetAttr()))
                .reason("必须同时选择 " + action.getTargetAttr())
                .build());
        } else if ("BLOCK".equals(action.getActionName())) {
            result.setConflict(PropagationResult.Conflict.builder()
                .targetAttrs(Collections.emptyList())
                .reason(action.getMessage())
                .build());
        }

        return result;
    }

    /**
     * VISIBILITY — 显示/隐藏
     *
     * actionExpr 格式：
     *   {"action":"HIDE","target_attrs":["镍含量","钴含量"]}
     *   {"action":"SHOW","target_attrs":["加密方式"]}
     */
    private ActionResult executeVisibility(ParsedAction action) {
        ActionResult result = ActionResult.empty();

        if ("HIDE".equals(action.getActionName())) {
            result.setHiddenAttributes(action.getTargetAttrs());
        } else if ("SHOW".equals(action.getActionName())) {
            // SHOW 是 HIDE 的反向：所有属性中，不在这列表里的隐藏
            // 实际执行时，SHOW 先收集 visibleAttrs，在 computeAttributeStates 时处理
            result.setVisibleAttributes(action.getTargetAttrs());
        }

        return result;
    }

    /**
     * SELECTION — 推荐/默认值
     *
     * actionExpr 格式：
     *   {"action":"SET_DEFAULT","target_attr":"循环寿命等级","value":"8000次@80%SOH"}
     *   {"action":"RECOMMEND","target_attr":"电池","value":"BL2500","reason":"续航提升30%"}
     */
    private ActionResult executeSelection(ParsedAction action) {
        ActionResult result = ActionResult.empty();

        if ("SET_DEFAULT".equals(action.getActionName()) || "RECOMMEND".equals(action.getActionName())) {
            result.setSuggestion(PropagationResult.Suggestion.builder()
                .targetAttr(action.getTargetAttr())
                .value(String.valueOf(action.getValue()))
                .reason(action.getReason())
                .isDefault("SET_DEFAULT".equals(action.getActionName()))
                .build());
        }

        return result;
    }

    /**
     * ALERT — 警告
     *
     * actionExpr 格式：
     *   {"action":"ALERT","severity":"WARNING","message":"产能不足"}
     */
    private ActionResult executeAlert(ParsedAction action) {
        ActionResult result = ActionResult.empty();
        result.setWarning(PropagationResult.Warning.builder()
            .severity(action.getSeverity() != null ? action.getSeverity() : "WARNING")
            .build());
        return result;
    }
}
```

### 3.5 ConstraintPropagator（MAC-3 约束传播）

```java
@Component
public class ConstraintPropagator {

    /**
     * MAC-3 约束传播算法
     *
     * 核心逻辑：当一个属性的某个选项被 DISABLE_OPTION 禁用后，
     * 需要检查是否有其他规则的条件引用了这个属性值。
     * 如果有，重新评估这些规则，可能产生新的禁用/隐藏/冲突。
     *
     * @param result      第一轮评估结果
     * @param rules       全部有效规则
     * @param selections  当前用户选择
     * @param allAttrNames 全部属性名
     * @return 传播后的最终结果
     */
    public PropagationResult propagate(
            PropagationResult result,
            List<CpqConfigRule> rules,
            Map<String, Object> selections,
            List<String> allAttrNames) {

        // 收集本轮被禁用的 (attr, value) 对
        Set<AttrValuePair> disabledPairs = new HashSet<>();
        for (PropagationResult.Conflict conflict : result.getConflicts()) {
            for (String targetAttr : conflict.getTargetAttrs()) {
                if (conflict.getDisabledValue() != null) {
                    disabledPairs.add(new AttrValuePair(targetAttr, conflict.getDisabledValue()));
                }
            }
        }

        if (disabledPairs.isEmpty()) return result;

        // 工作队列：待重新评估的规则
        Queue<CpqConfigRule> workQueue = new LinkedList<>();

        // 找到条件中引用了被禁用属性的规则
        for (CpqConfigRule rule : rules) {
            // 已评估过的规则跳过（避免死循环）
            if (!result.getEvaluatedRuleIds().add(rule.getRuleId())) continue;

            for (AttrValuePair pair : disabledPairs) {
                if (conditionReferencesAttr(rule.getConditionExpr(), pair.attrName)) {
                    workQueue.add(rule);
                    break;
                }
            }
        }

        // MAC-3 迭代
        int maxIterations = 50; // 防止无限循环
        int iterations = 0;

        while (!workQueue.isEmpty() && iterations < maxIterations) {
            iterations++;
            CpqConfigRule rule = workQueue.poll();

            // 重新评估
            // ...（复用 ConditionEvaluator + ActionExecutor）

            Set<AttrValuePair> newDisabledPairs = extractNewDisabledPairs(result, disabledPairs);
            if (!newDisabledPairs.isEmpty()) {
                disabledPairs.addAll(newDisabledPairs);

                // 把引用新禁用属性的规则加入队列
                for (CpqConfigRule r : rules) {
                    if (result.getEvaluatedRuleIds().contains(r.getRuleId())) continue;
                    for (AttrValuePair pair : newDisabledPairs) {
                        if (conditionReferencesAttr(r.getConditionExpr(), pair.attrName)) {
                            workQueue.add(r);
                            break;
                        }
                    }
                }
            }
        }

        if (iterations >= maxIterations) {
            log.warn("MAC-3 约束传播达到最大迭代次数，可能存在循环依赖");
        }

        return result;
    }

    /**
     * 检查条件表达式是否引用了指定属性名
     */
    private boolean conditionReferencesAttr(String conditionExpr, String attrName) {
        // 简单实现：检查 JSON 字符串中是否出现该属性名
        return conditionExpr != null && conditionExpr.contains("\"attr_name\":\"" + attrName + "\"");
    }

    private static class AttrValuePair {
        final String attrName;
        final String value;
        // constructor + equals + hashCode ...
    }
}
```

### 3.6 ParsedAction（动作解析）

```java
@Data
public class ParsedAction {

    private String ruleType;       // VALIDATION / SELECTION / ALERT / VISIBILITY
    private String actionName;     // HIDE / SHOW / SET_DEFAULT / RECOMMEND / DISABLE_OPTION / BLOCK / ALERT / REQUIRE_ATTR
    private String targetAttr;     // 目标属性名（单数）
    private List<String> targetAttrs; // 目标属性名列表（复数，VISIBILITY 用）
    private Object value;          // 值
    private String reason;         // 推荐理由
    private String message;        // 提示信息
    private String severity;       // 严重级别

    /**
     * 从 actionExpr JSON 字符串解析
     */
    public static ParsedAction from(String actionExpr, String ruleType) {
        try {
            JsonNode node = new ObjectMapper().readTree(actionExpr);
            ParsedAction action = new ParsedAction();
            action.setRuleType(ruleType);
            action.setActionName(node.has("action") ? node.get("action").asText() : null);

            if (node.has("target_attr")) {
                action.setTargetAttr(node.get("target_attr").asText());
            }
            if (node.has("target_attrs") && node.get("target_attrs").isArray()) {
                List<String> attrs = new ArrayList<>();
                for (JsonNode attr : node.get("target_attrs")) {
                    attrs.add(attr.asText());
                }
                action.setTargetAttrs(attrs);
            }
            if (node.has("value")) {
                action.setValue(parseValue(node.get("value")));
            }
            if (node.has("reason")) {
                action.setReason(node.get("reason").asText());
            }
            if (node.has("message")) {
                action.setMessage(node.get("message").asText());
            }
            if (node.has("severity")) {
                action.setSeverity(node.get("severity").asText());
            }

            return action;
        } catch (Exception e) {
            log.error("解析 actionExpr 失败: {}", actionExpr, e);
            throw new RuntimeException("无效的动作表达式", e);
        }
    }

    private static Object parseValue(JsonNode valueNode) {
        if (valueNode.isNumber()) return valueNode.numberValue();
        if (valueNode.isBoolean()) return valueNode.booleanValue();
        return valueNode.asText();
    }
}
```

---

## 4. ConfiguratorController 改造

### 4.1 propagate() 方法（替换桩代码）

```java
@PostMapping("/propagate")
public R<PropagationResult> propagateConstraints(
        @RequestParam Long modelId,
        @RequestBody Map<String, Object> body) {

    @SuppressWarnings("unchecked")
    Map<String, Object> selections = (Map<String, Object>) body.get("selections");

    // 获取该产品的全部属性名
    List<String> allAttrNames = attributeService.getAttrNamesByModelId(modelId);

    // 执行规则引擎
    PropagationResult result = ruleEngine.propagate(modelId, selections, allAttrNames);

    return R.ok(result);
}
```

### 4.2 validate() 方法（替换桩代码）

```java
@PostMapping("/validate")
public R<PropagationResult> validate(
        @RequestParam Long modelId,
        @RequestBody Map<String, Object> body) {

    @SuppressWarnings("unchecked")
    Map<String, Object> selections = (Map<String, Object>) body.get("selections");

    List<String> allAttrNames = attributeService.getAttrNamesByModelId(modelId);

    // validate 比 propagate 更严格：只报告 ERROR 级别的冲突
    PropagationResult result = ruleEngine.propagate(modelId, selections, allAttrNames);

    // 过滤掉非 ERROR 的冲突
    List<PropagationResult.Conflict> errors = result.getConflicts().stream()
        .filter(c -> "ERROR".equals(c.getSeverity()))
        .collect(Collectors.toList());
    result.setConflicts(errors);

    return R.ok(result);
}
```

---

## 5. 数据模型

### 5.1 PropagationResult（返回给前端）

```java
@Data
@Builder
public class PropagationResult {

    /** 每个属性的最终状态：available / conflict / disabled / hidden */
    private Map<String, String> attributeStates;

    /** 冲突列表（VALIDATION 规则触发） */
    private List<Conflict> conflicts;

    /** 警告列表（ALERT 规则触发） */
    private List<Warning> warnings;

    /** 推荐列表（SELECTION 规则触发） */
    private List<Suggestion> suggestions;

    /** 已评估的规则ID集合（用于 MAC-3 去重） */
    @JsonIgnore
    private Set<Long> evaluatedRuleIds;

    /** 被禁用的属性列表（MAC-3 传播用） */
    @JsonIgnore
    private Set<String> disabledAttributes;

    @Data
    @Builder
    public static class Conflict {
        private String ruleName;
        private List<String> targetAttrs;
        private String disabledValue;
        private String message;
        private String reason;
        private String severity;
    }

    @Data
    @Builder
    public static class Warning {
        private String ruleName;
        private String message;
        private String severity;
    }

    @Data
    @Builder
    public static class Suggestion {
        private String ruleName;
        private String targetAttr;
        private String value;
        private String reason;
        private boolean isDefault;  // true=自动填充，false=仅推荐
    }
}
```

### 5.2 ActionResult（引擎内部使用）

```java
@Data
public class ActionResult {
    private PropagationResult.Conflict conflict;
    private PropagationResult.Warning warning;
    private PropagationResult.Suggestion suggestion;
    private List<String> hiddenAttributes;
    private List<String> visibleAttributes;

    public static ActionResult empty() { return new ActionResult(); }
}
```

---

## 6. 前后端交互协议

### 6.1 请求

```
POST /cpq/configure/propagate?modelId={productModelId}
Content-Type: application/json

{
  "selections": {
    "化学体系": "磷酸铁锂(LFP)",
    "标称电压": "3.2V",
    "额定容量": 280
  }
}
```

### 6.2 响应

```json
{
  "code": 200,
  "data": {
    "attributeStates": {
      "化学体系": "available",
      "标称电压": "available",
      "额定容量": "available",
      "镍含量": "hidden",
      "钴含量": "hidden",
      "循环寿命等级": "available",
      "防爆认证": "available"
    },
    "conflicts": [],
    "warnings": [
      {
        "ruleName": "大容量提醒",
        "message": "LF280K 当前月产能约8000pcs，10000以上的订单建议分批次交付",
        "severity": "WARNING"
      }
    ],
    "suggestions": [
      {
        "ruleName": "大容量选长循环",
        "targetAttr": "循环寿命等级",
        "value": "8000次@80%SOH",
        "reason": "大容量储能场景对循环寿命要求高",
        "isDefault": true
      }
    ]
  }
}
```

### 6.3 前端对接（无需改代码）

前端 `Configurator.vue` 和 `useConfiguratorStore` 已有的代码逻辑：

```typescript
// store 中已有的 propagate 调用
async function refreshPropagation() {
  const res = await request.post('/cpq/configure/propagate', {
    selections: currentSelections.value
  }, { params: { modelId: modelId.value } })

  // 更新属性状态 — 只需确保 res.attributeStates 的 key 与前端一致
  attributeStates.value = res.attributeStates || {}
  conflicts.value = res.conflicts || []
  warnings.value = res.warnings || []
  suggestions.value = res.suggestions || []
}
```

**只要后端返回的 `attributeStates` key 与前端的属性名一致，前端无需任何修改。**

---

## 7. 开发计划

| 阶段 | 内容 | 工时 | 产出 |
|:--:|------|:--:|------|
| 1 | `ParsedAction` + `PropagationResult` + `ActionResult` 数据模型 | 0.5 天 | 引擎内部模型 |
| 2 | `RuleLoader` — 加载有效规则 | 0.5 天 | 可按 modelId + 日期过滤 |
| 3 | `ConditionEvaluator` — JSON 解析 + 条件匹配（含 AND/OR 嵌套） | 1 天 | 10 种操作符全覆盖 |
| 4 | `ActionExecutor` — 四种规则类型的动作执行 | 1 天 | VALIDATION/SELECTION/ALERT/VISIBILITY |
| 5 | `ConstraintPropagator` — MAC-3 增量传播 | 1 天 | 避免全量重算 |
| 6 | `RuleEngine.run()` — 管线编排 | 0.5 天 | 串联全部组件 |
| 7 | `ConfiguratorController` 接入 + 前后端联调 | 0.5 天 | 替换桩代码 |
| 8 | Playwright E2E 测试 | 0.5 天 | 验证规则生效 |
| **合计** | | **5.5 天** | |

---

## 8. 测试策略

### 8.1 单元测试

```java
@Test
public void testConditionEvaluator_Atomic() {
    ConditionEvaluator eval = new ConditionEvaluator();
    Map<String, Object> selections = Map.of("颜色", "珍珠白", "功率", 5);
    
    // eq 匹配
    assertTrue(eval.evaluate(
        "{\"attr_name\":\"颜色\",\"op\":\"eq\",\"value\":\"珍珠白\"}", selections));
    // neq 不匹配
    assertFalse(eval.evaluate(
        "{\"attr_name\":\"颜色\",\"op\":\"eq\",\"value\":\"金属灰\"}", selections));
}

@Test
public void testConditionEvaluator_AndOr() {
    ConditionEvaluator eval = new ConditionEvaluator();
    Map<String, Object> selections = Map.of("化学体系", "磷酸铁锂", "容量", 280);
    
    // AND: 两个都满足 → true
    String andExpr = "{\"and\":[{\"attr_name\":\"化学体系\",\"op\":\"eq\",\"value\":\"磷酸铁锂\"},{\"attr_name\":\"容量\",\"op\":\"gte\",\"value\":280}]}";
    assertTrue(eval.evaluate(andExpr, selections));
    
    // OR: 任一满足 → true
    String orExpr = "{\"or\":[{\"attr_name\":\"容量\",\"op\":\"gt\",\"value\":300},{\"attr_name\":\"化学体系\",\"op\":\"eq\",\"value\":\"磷酸铁锂\"}]}";
    assertTrue(eval.evaluate(orExpr, selections));
}
```

### 8.2 集成测试（Playwright E2E）

```
测试用例：配置规则端到端验证

前置条件：
  1. 通过 ConfigRuleManager 录入一条规则：
     类型=VISIBILITY, 条件=化学体系=磷酸铁锂, 动作=HIDE 镍含量、钴含量
  2. 产品 EVE-LF280K 有属性 化学体系、镍含量、钴含量

测试步骤：
  1. 打开 /configure → 搜索 EVE-LF280K → 点击进入配置器
  2. 观察：属性列表包含 镍含量 和 钴含量（尚未选化学体系）
  3. 选择 化学体系 = 磷酸铁锂(LFP)
  4. 验证：镍含量 和 钴含量 从属性列表中消失（被隐藏）
  5. 截图确认
```

---

## 9. 风险与注意事项

| 风险 | 缓解措施 |
|------|---------|
| JSON 格式错误导致引擎崩溃 | ConditionEvaluator + ActionExecutor 全部 try-catch，解析失败返回 false/empty |
| 大量规则时性能不足 | MAC-3 增量传播 + 规则按 priority 索引 + 预加载缓存 |
| 前端属性名与后端规则中引用的不一致 | 统一使用 `cpq_attribute_option.attr_name` 作为唯一标识 |
| 循环依赖导致死循环 | MAC-3 迭代上限 50 次 + 日志告警 |
| 旧规则数据（conditionExpr 为空 {}） | `{}` 作为条件恒为 true → 规则总是生效，符合预期 |
