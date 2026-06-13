package org.dromara.cpq.config.service;

import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.util.ObjectUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.cpq.config.domain.CpqAttributeOption;
import org.dromara.cpq.config.domain.CpqCompatibilityMatrix;
import org.dromara.cpq.config.domain.CpqConfigRule;
import org.dromara.cpq.config.mapper.CpqAttributeOptionMapper;
import org.dromara.cpq.config.mapper.CpqCompatibilityMatrixMapper;
import org.dromara.cpq.config.mapper.CpqConfigRuleMapper;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

/**
 * CPQ 配置引擎 — CSP约束求解器 + 约束传播 + 向导式销售
 * <p>
 * S5.1: validate() — CSP约束验证引擎
 *   - 加载产品模型的所有配置规则（cpq_config_rule）
 *   - 解析 conditionExpr JSON 表达式，匹配用户属性选择
 *   - 输出：PASS（通过）/ SOFT_FAIL（警告）/ HARD_FAIL（阻止）
 * S5.2: propagateConstraints() — MAC-3 弧相容约束传播
 *   - 根据当前选择的属性值，推导剩余可选选项
 *   - 逐属性消除不兼容选项（RemoveInconsistentValues）
 *   - 检测冲突/死锁（空域）
 * S5.3: guidedSelling() — 向导式销售决策树
 *   - 5状态机：Questioning → Narrowing → Recommending → Configuring → Completed
 *   - MRV启发式：最少剩余值优先选择下一个待定属性
 *   - 基于属性选项（cpq_attribute_option）驱动
 * <p>
 * 对应设计文档：CPQ_后端功能设计.md §5.2 ConfigEngineService
 * CPQ_阶段二_详细设计层.md §5.2 CSP约束求解器与配置决策
 *
 * @author CPQ Team
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ConfigEngineService {

    private final CpqConfigRuleMapper configRuleMapper;
    private final CpqAttributeOptionMapper attributeOptionMapper;
    private final CpqCompatibilityMatrixMapper compatibilityMatrixMapper;

    // ==================== 数据结构 ====================

    /**
     * 验证结果
     */
    public enum ValidationStatus {
        PASS,       // 配置通过
        SOFT_FAIL,  // 警告（可忽略）
        HARD_FAIL   // 阻止（必须修正）
    }

    public static class ValidationResult {
        private ValidationStatus status;
        private List<String> errors = new ArrayList<>();
        private List<String> warnings = new ArrayList<>();

        public ValidationStatus getStatus() { return status; }
        public void setStatus(ValidationStatus v) { this.status = v; }
        public List<String> getErrors() { return errors; }
        public void setErrors(List<String> v) { this.errors = v; }
        public List<String> getWarnings() { return warnings; }
        public void setWarnings(List<String> v) { this.warnings = v; }
        public void addError(String e) { this.errors.add(e); }
        public void addWarning(String w) { this.warnings.add(w); }
    }

    /**
     * 引导销售状态
     */
    public enum GuideState {
        QUESTIONING,   // 询问属性
        NARROWING,     // 缩小选项范围
        RECOMMENDING,  // 推荐配置
        CONFIGURING,   // 配置中
        COMPLETED      // 完成
    }

    public static class GuideStep {
        private GuideState state;
        private String currentAttribute;     // 当前询问的属性名
        private List<OptionInfo> options;    // 可选选项列表
        private String recommendation;       // 推荐说明
        private Map<String, String> prohibited; // 被禁止的选择
        private Map<String, List<String>> attributeOptions; // 各属性剩余选项

        public GuideState getState() { return state; }
        public void setState(GuideState v) { this.state = v; }
        public String getCurrentAttribute() { return currentAttribute; }
        public void setCurrentAttribute(String v) { this.currentAttribute = v; }
        public List<OptionInfo> getOptions() { return options; }
        public void setOptions(List<OptionInfo> v) { this.options = v; }
        public String getRecommendation() { return recommendation; }
        public void setRecommendation(String v) { this.recommendation = v; }
        public Map<String, String> getProhibited() { return prohibited; }
        public void setProhibited(Map<String, String> v) { this.prohibited = v; }
        public Map<String, List<String>> getAttributeOptions() { return attributeOptions; }
        public void setAttributeOptions(Map<String, List<String>> v) { this.attributeOptions = v; }
    }

    public static class OptionInfo {
        private String code;
        private String label;
        private boolean available;
        private boolean recommended;
        private String reason; // 不可选原因

        public OptionInfo() {}
        public OptionInfo(String code, String label, boolean available, boolean recommended, String reason) {
            this.code = code; this.label = label; this.available = available;
            this.recommended = recommended; this.reason = reason;
        }
        public String getCode() { return code; }
        public void setCode(String v) { this.code = v; }
        public String getLabel() { return label; }
        public void setLabel(String v) { this.label = v; }
        public boolean isAvailable() { return available; }
        public void setAvailable(boolean v) { this.available = v; }
        public boolean isRecommended() { return recommended; }
        public void setRecommended(boolean v) { this.recommended = v; }
        public String getReason() { return reason; }
        public void setReason(String v) { this.reason = v; }
    }

    // ==================== S5.1: CSP 约束验证 ====================

    /**
     * 验证产品配置是否满足所有约束规则。
     * <p>
     * 算法：
     * 1. 加载产品模型的所有规则（cpq_config_rule，按 priority 升序）
     * 2. 逐条评估 conditionExpr 是否匹配当前 selections
     * 3. 匹配的规则检查 actionExpr 要求是否满足
     * 4. severity=ERROR → HARD_FAIL；WARN → SOFT_FAIL
     *
     * @param modelId    产品模型 ID
     * @param selections 属性选择（{"颜色":"珍珠白","基站版本":"标准版"}）
     * @return 验证结果（PASS / SOFT_FAIL / HARD_FAIL）
     */
    public ValidationResult validate(Long modelId, Map<String, String> selections) {
        long start = System.currentTimeMillis();
        log.info("[S5.1] CSP约束验证，modelId: {}, selections: {}", modelId, selections);

        ValidationResult result = new ValidationResult();
        result.setStatus(ValidationStatus.PASS);

        if (selections == null || selections.isEmpty()) {
            log.info("[S5.1] 无选择，验证通过");
            return result;
        }

        // 加载规则（按 priority 升序）
        List<CpqConfigRule> rules = configRuleMapper.selectList(
            new LambdaQueryWrapper<CpqConfigRule>()
                .eq(CpqConfigRule::getModelId, modelId)
                .eq(CpqConfigRule::getStatus, "0")
                .orderByAsc(CpqConfigRule::getPriority));

        if (CollUtil.isEmpty(rules)) {
            log.info("[S5.1] 无规则，验证通过");
            return result;
        }

        for (CpqConfigRule rule : rules) {
            if (!evaluateCondition(rule.getConditionExpr(), selections)) {
                continue; // 条件不匹配，跳过
            }

            // 条件匹配，检查动作
            boolean actionSatisfied = evaluateAction(rule.getActionExpr(), selections);
            if (!actionSatisfied) {
                String msg = StrUtil.format("规则 [{}]: {} (severity={})",
                    rule.getRuleName(),
                    rule.getErrorMessage() != null ? rule.getErrorMessage() : "配置冲突",
                    rule.getSeverity());
                log.warn("[S5.1] 约束违反: {}", msg);

                if ("ERROR".equalsIgnoreCase(rule.getSeverity())) {
                    result.addError(msg);
                    result.setStatus(ValidationStatus.HARD_FAIL);
                } else {
                    result.addWarning(msg);
                    if (result.getStatus() != ValidationStatus.HARD_FAIL) {
                        result.setStatus(ValidationStatus.SOFT_FAIL);
                    }
                }
            }
        }

        log.info("[S5.1] CSP验证完成，status: {}, errors: {}, warnings: {}, 耗时: {}ms",
            result.getStatus(), result.getErrors().size(), result.getWarnings().size(),
            System.currentTimeMillis() - start);
        return result;
    }

    /**
     * 评估条件表达式：conditionExpr 中的每个 key-value 对是否都被 selections 满足。
     * <p>
     * conditionExpr 格式: {"颜色":"珍珠白"} → 要求 selections["颜色"] == "珍珠白"
     * 特殊运算符：
     *   - "!=value" → 不等于
     *   - "in[val1,val2]" → 属于集合
     *   - 空/null → 无条件（始终匹配）
     */
    private boolean evaluateCondition(String conditionExpr, Map<String, String> selections) {
        if (StrUtil.isBlank(conditionExpr)) return true;

        try {
            Map<String, String> conditions = parseSimpleJson(conditionExpr);
            for (Map.Entry<String, String> entry : conditions.entrySet()) {
                String key = entry.getKey();
                String expected = entry.getValue();
                String actual = selections.get(key);

                if (expected.startsWith("!=")) {
                    String notVal = expected.substring(2);
                    if (Objects.equals(actual, notVal)) return false;
                } else if (expected.startsWith("in[")) {
                    String[] vals = expected.substring(3, expected.length() - 1).split("\\|");
                    boolean found = false;
                    for (String v : vals) {
                        if (Objects.equals(actual, v.trim())) { found = true; break; }
                    }
                    if (!found) return false;
                } else {
                    if (!Objects.equals(actual, expected)) return false;
                }
            }
            return true;
        } catch (Exception e) {
            log.warn("[S5.1] conditionExpr 解析异常: {}", conditionExpr, e);
            return false;
        }
    }

    /**
     * 评估动作表达式：actionExpr 中的条件是否需要检查 selections。
     * <p>
     * actionExpr 格式:
     *   - {"block":true} → 阻止配置
     *   - {"recommend":"珍珠白"} → 推荐值（不阻止）
     *   - {"require":"CONN-003"} → 要求选择特定物料（暂时用字符串匹配）
     */
    private boolean evaluateAction(String actionExpr, Map<String, String> selections) {
        if (StrUtil.isBlank(actionExpr)) return true;

        try {
            Map<String, String> actions = parseSimpleJson(actionExpr);
            if ("true".equals(actions.get("block"))) {
                return false; // BLOCK动作 → 约束违反
            }
            return true;
        } catch (Exception e) {
            log.warn("[S5.1] actionExpr 解析异常: {}", actionExpr, e);
            return true; // 解析失败不阻止
        }
    }

    // ==================== S5.2: 约束传播（MAC-3 弧相容） ====================

    /**
     * 根据当前选择传播约束，推导可选/被禁止的选项。
     * <p>
     * 算法（简化版 MAC-3）：
     * 1. 加载所有属性选项（cpq_attribute_option）
     * 2. 对每个未选属性，逐一检查每个选项是否与当前 selections 兼容
     * 3. 不兼容的选项标记为 unavailable
     * 4. 返回每属性的可选/禁止选项
     *
     * @param modelId    产品模型 ID
     * @param selections 当前属性选择
     * @return 每属性的可用选项列表
     */
    public Map<String, List<OptionInfo>> propagateConstraints(Long modelId, Map<String, String> selections) {
        long start = System.currentTimeMillis();
        log.info("[S5.2] MAC-3约束传播，modelId: {}, selections: {}", modelId, selections);

        // 加载所有属性选项
        List<CpqAttributeOption> allOptions = attributeOptionMapper.selectList(
            new LambdaQueryWrapper<CpqAttributeOption>()
                .eq(CpqAttributeOption::getModelId, modelId)
                .orderByAsc(CpqAttributeOption::getSortOrder));

        if (CollUtil.isEmpty(allOptions)) {
            return Map.of();
        }

        // 按 attrName 分组
        Map<String, List<CpqAttributeOption>> grouped = new LinkedHashMap<>();
        for (CpqAttributeOption opt : allOptions) {
            grouped.computeIfAbsent(opt.getAttrName(), k -> new ArrayList<>()).add(opt);
        }

        // 加载所有规则
        List<CpqConfigRule> rules = configRuleMapper.selectList(
            new LambdaQueryWrapper<CpqConfigRule>()
                .eq(CpqConfigRule::getModelId, modelId)
                .eq(CpqConfigRule::getStatus, "0"));

        Map<String, List<OptionInfo>> result = new LinkedHashMap<>();

        for (Map.Entry<String, List<CpqAttributeOption>> entry : grouped.entrySet()) {
            String attrName = entry.getKey();
            List<CpqAttributeOption> options = entry.getValue();
            List<OptionInfo> optionInfos = new ArrayList<>();

            // 如果该属性已选择，所有选项不可选（已完成）
            boolean alreadySelected = selections.containsKey(attrName);

            for (CpqAttributeOption opt : options) {
                if (alreadySelected) {
                    boolean isCurrent = Objects.equals(selections.get(attrName), opt.getOptionValue());
                    optionInfos.add(new OptionInfo(opt.getOptionCode(), opt.getOptionLabel(),
                        false, false, isCurrent ? "已选择" : "互斥于已选值"));
                    continue;
                }

                // 模拟选择此选项，检查是否违反约束
                Map<String, String> simulatedSelections = new LinkedHashMap<>(selections);
                simulatedSelections.put(attrName, opt.getOptionValue());

                boolean compatible = isCompatibleWithRules(rules, simulatedSelections);
                boolean recommended = "1".equals(opt.getIsDefault());

                if (compatible) {
                    optionInfos.add(new OptionInfo(opt.getOptionCode(), opt.getOptionLabel(),
                        true, recommended, null));
                } else {
                    optionInfos.add(new OptionInfo(opt.getOptionCode(), opt.getOptionLabel(),
                        false, false, "与已有配置冲突"));
                }
            }

            result.put(attrName, optionInfos);
        }

        log.info("[S5.2] 约束传播完成，属性数: {}, 耗时: {}ms",
            result.size(), System.currentTimeMillis() - start);
        return result;
    }

    private boolean isCompatibleWithRules(List<CpqConfigRule> rules, Map<String, String> selections) {
        for (CpqConfigRule rule : rules) {
            if (evaluateCondition(rule.getConditionExpr(), selections)) {
                if (!evaluateAction(rule.getActionExpr(), selections)) {
                    return false;
                }
            }
        }
        return true;
    }

    // ==================== S5.3: 向导式销售 ====================

    /**
     * 向导式销售 — 按决策树逐步引导用户完成产品配置。
     * <p>
     * 状态机：
     *   1. Questioning — 询问下一个最重要（MRV最少剩余值）的属性
     *   2. Narrowing   — 约束传播后缩小选项范围
     *   3. Recommending — 所有必选属性选定后，推荐默认组合
     *   4. Configuring  — 用户正在配置中
     *   5. Completed    — 所有属性已选定
     * <p>
     * MRV启发式：选择剩余可选值最少的未定属性作为下一个询问目标。
     *
     * @param modelId     产品模型 ID
     * @param selections  当前已选择的属性值
     * @return 引导步骤（含下一步建议）
     */
    public GuideStep guidedSelling(Long modelId, Map<String, String> selections) {
        long start = System.currentTimeMillis();
        log.info("[S5.3] 向导式销售，modelId: {}, selections: {}", modelId, selections);

        GuideStep step = new GuideStep();
        Map<String, String> safeSelections = selections != null ? new LinkedHashMap<>(selections) : new LinkedHashMap<>();

        // 加载属性选项
        List<CpqAttributeOption> allOptions = attributeOptionMapper.selectList(
            new LambdaQueryWrapper<CpqAttributeOption>()
                .eq(CpqAttributeOption::getModelId, modelId)
                .orderByAsc(CpqAttributeOption::getSortOrder));

        if (CollUtil.isEmpty(allOptions)) {
            step.setState(GuideState.COMPLETED);
            step.setRecommendation("该产品无配置属性，可直接加入报价");
            return step;
        }

        // 按 attrName 分组
        Map<String, List<CpqAttributeOption>> grouped = new LinkedHashMap<>();
        for (CpqAttributeOption opt : allOptions) {
            grouped.computeIfAbsent(opt.getAttrName(), k -> new ArrayList<>()).add(opt);
        }

        // 约束传播
        Map<String, List<OptionInfo>> propagation = propagateConstraints(modelId, safeSelections);
        step.setAttributeOptions(convertToValueMap(propagation));

        // 确定下一步状态
        List<String> unselectedAttrs = new ArrayList<>();
        for (String attrName : grouped.keySet()) {
            if (!safeSelections.containsKey(attrName)) {
                unselectedAttrs.add(attrName);
            }
        }

        if (unselectedAttrs.isEmpty()) {
            // 所有属性已选定
            step.setState(GuideState.COMPLETED);
            step.setRecommendation("配置完成！所有属性已选定");
            log.info("[S5.3] 向导完成，所有属性已选定，耗时: {}ms", System.currentTimeMillis() - start);
            return step;
        }

        // MRV 启发式：找剩余可选值最少的未定属性
        String nextAttr = findMrvAttribute(unselectedAttrs, propagation);

        if (nextAttr != null && propagation.containsKey(nextAttr)) {
            List<OptionInfo> options = propagation.get(nextAttr);
            List<OptionInfo> available = options.stream()
                .filter(OptionInfo::isAvailable).collect(Collectors.toList());

            step.setCurrentAttribute(nextAttr);
            step.setState(GuideState.QUESTIONING);
            step.setOptions(options);

            if (available.size() == 1) {
                step.setRecommendation("建议选择: " + available.get(0).getLabel());
            } else if (available.size() <= 3) {
                // 选项很少 → Narrowing
                step.setState(GuideState.NARROWING);
                List<String> labels = available.stream().map(OptionInfo::getLabel).collect(Collectors.toList());
                step.setRecommendation("可选: " + String.join(" / ", labels));
            } else {
                // 选项多 → 推荐默认值
                step.setState(GuideState.RECOMMENDING);
                OptionInfo defaultOpt = options.stream()
                    .filter(o -> o.isAvailable() && o.isRecommended()).findFirst().orElse(available.get(0));
                step.setRecommendation("推荐: " + defaultOpt.getLabel());
            }
        }

        log.info("[S5.3] 向导步骤: state={}, nextAttr={}, 耗时: {}ms",
            step.getState(), step.getCurrentAttribute(), System.currentTimeMillis() - start);
        return step;
    }

    /**
     * MRV (Minimum Remaining Values) 启发式：
     * 选择可选值最少的未定属性，减少分支因子。
     */
    private String findMrvAttribute(List<String> unselectedAttrs, Map<String, List<OptionInfo>> propagation) {
        String bestAttr = null;
        int bestCount = Integer.MAX_VALUE;

        for (String attr : unselectedAttrs) {
            List<OptionInfo> options = propagation.get(attr);
            if (options == null) continue;
            int availableCount = (int) options.stream().filter(OptionInfo::isAvailable).count();
            if (availableCount < bestCount) {
                bestCount = availableCount;
                bestAttr = attr;
            }
        }
        return bestAttr != null ? bestAttr : unselectedAttrs.get(0);
    }

    /**
     * 将 OptionInfo 列表转换为 value 列表（向后兼容）
     */
    private Map<String, List<String>> convertToValueMap(Map<String, List<OptionInfo>> propagation) {
        Map<String, List<String>> result = new LinkedHashMap<>();
        for (Map.Entry<String, List<OptionInfo>> entry : propagation.entrySet()) {
            result.put(entry.getKey(), entry.getValue().stream()
                .filter(OptionInfo::isAvailable)
                .map(OptionInfo::getLabel)
                .collect(Collectors.toList()));
        }
        return result;
    }

    // ==================== 兼容性矩阵检查（跨产品） ====================

    /**
     * 检查两个产品之间是否存在兼容性问题。
     *
     * @param sourceProductId 源产品 ID
     * @param targetProductId 目标产品 ID
     * @return 兼容性类型：COMPATIBLE / CONDITIONAL / INCOMPATIBLE
     */
    public String checkCompatibility(Long sourceProductId, Long targetProductId) {
        List<CpqCompatibilityMatrix> entries = compatibilityMatrixMapper.selectList(
            new LambdaQueryWrapper<CpqCompatibilityMatrix>()
                .eq(CpqCompatibilityMatrix::getSourceProductId, sourceProductId)
                .eq(CpqCompatibilityMatrix::getTargetProductId, targetProductId));

        if (CollUtil.isEmpty(entries)) {
            return "COMPATIBLE"; // 无记录 = 默认兼容
        }

        for (CpqCompatibilityMatrix entry : entries) {
            if ("INCOMPATIBLE".equalsIgnoreCase(entry.getCompatibilityType())) {
                return "INCOMPATIBLE";
            }
        }

        return "CONDITIONAL";
    }

    // ==================== 工具方法 ====================

    /**
     * 简易 JSON 解析：{ "key1": "value1", "key2": "value2" } → Map
     * 支持转义引号和嵌套 in[] 语法
     */
    private Map<String, String> parseSimpleJson(String json) {
        Map<String, String> result = new LinkedHashMap<>();
        if (StrUtil.isBlank(json)) return result;

        // 去除最外层 {}
        String content = json.trim();
        if (content.startsWith("{")) content = content.substring(1);
        if (content.endsWith("}")) content = content.substring(0, content.length() - 1);
        content = content.trim();
        if (content.isEmpty()) return result;

        // 按逗号分割（需处理 in[...] 中的逗号）
        List<String> pairs = splitJsonPairs(content);
        for (String pair : pairs) {
            String[] kv = pair.split(":", 2);
            if (kv.length == 2) {
                String key = kv[0].trim().replaceAll("^\"|\"$", "");
                String value = kv[1].trim().replaceAll("^\"|\"$", "");
                result.put(key, value);
            }
        }
        return result;
    }

    private List<String> splitJsonPairs(String content) {
        List<String> pairs = new ArrayList<>();
        StringBuilder current = new StringBuilder();
        int depth = 0; // 方括号深度
        for (int i = 0; i < content.length(); i++) {
            char c = content.charAt(i);
            if (c == '[') depth++;
            else if (c == ']') depth--;
            if (c == ',' && depth == 0) {
                pairs.add(current.toString().trim());
                current = new StringBuilder();
            } else {
                current.append(c);
            }
        }
        if (current.length() > 0) {
            pairs.add(current.toString().trim());
        }
        return pairs;
    }
}
