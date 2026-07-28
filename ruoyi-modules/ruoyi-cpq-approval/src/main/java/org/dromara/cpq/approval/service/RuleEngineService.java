package org.dromara.cpq.approval.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.cpq.approval.enums.ApprovalScene;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.Map;

/**
 * 审批规则匹配引擎 — 根据业务场景和上下文匹配最高优先级的审批规则
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class RuleEngineService {
    private final JdbcTemplate jdbc;

    /**
     * 匹配审批规则
     * @param scene 业务场景
     * @param context 业务上下文（如 discountTotal, grandTotal 等）
     * @return 匹配的规则 Map，包含 rule_id, rule_name, flow_code, approval_chain_json 等；未匹配返回 null
     */
    public Map<String, Object> match(ApprovalScene scene, Map<String, Object> context) {
        // 1. 查询该场景下所有启用的规则，按优先级降序
        var rules = jdbc.queryForList(
            "SELECT * FROM cpq_approval_rule WHERE tenant_id='000000' AND trigger_scene=? AND status='0' AND del_flag='0' ORDER BY priority DESC",
            scene.name());

        // 2. 遍历规则，匹配触发条件
        for (var rule : rules) {
            String triggerType = (String) rule.get("trigger_type");
            if (evaluateTrigger(triggerType, rule, context)) {
                return rule;
            }
        }
        return null;
    }

    /** 评估单条规则的触发条件 */
    private boolean evaluateTrigger(String triggerType, Map<String, Object> rule, Map<String, Object> context) {
        // 支持 triggerType: DISCOUNT_EXCEED, MARGIN_BELOW, AMOUNT_ABOVE, NEW_CONFIG, CUSTOM_PART,
        //   FIRST_ORDER, EXPORT_CONTROL, CROSS_REGION, PROCESS_CONFIRM (始终触发)
        return switch (triggerType) {
            case "PROCESS_CONFIRM" -> true; // 工艺确认始终触发
            case "DISCOUNT_EXCEED" -> compareValue(rule, context, "discountTotal");
            case "AMOUNT_ABOVE" -> compareValue(rule, context, "grandTotal");
            case "MARGIN_BELOW" -> marginBelow(rule, context);
            case "FIRST_ORDER" -> true; // 简化：有规则就触发
            case "CUSTOM_PART" -> context.containsKey("hasCustomPart") && Boolean.TRUE.equals(context.get("hasCustomPart"));
            case "EXPORT_CONTROL" -> context.containsKey("hasExportControl") && Boolean.TRUE.equals(context.get("hasExportControl"));
            default -> false;
        };
    }

    private boolean compareValue(Map<String, Object> rule, Map<String, Object> context, String key) {
        var triggerValue = (BigDecimal) rule.get("trigger_value");
        if (triggerValue == null) return true;
        Object val = context.get(key);
        if (val == null) return false;
        double d = val instanceof Number n ? n.doubleValue() : Double.parseDouble(val.toString());
        return d > triggerValue.doubleValue();
    }

    private boolean marginBelow(Map<String, Object> rule, Map<String, Object> context) {
        // 利润率低于阈值时触发
        var triggerValue = (BigDecimal) rule.get("trigger_value");
        if (triggerValue == null) return true;
        Object margin = context.get("marginRate");
        if (margin == null) return false;
        double m = margin instanceof Number n ? n.doubleValue() : Double.parseDouble(margin.toString());
        return m < triggerValue.doubleValue();
    }
}
