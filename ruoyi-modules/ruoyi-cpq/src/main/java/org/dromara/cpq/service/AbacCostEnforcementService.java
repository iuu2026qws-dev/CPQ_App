package org.dromara.cpq.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.*;

/**
 * ABAC 成本可见性执行引擎（S18.4）
 * 
 * 根据 RBAC 角色 + ABAC 策略，对报价/定价API响应进行四级成本脱敏：
 *   L3 完整成本 — 高管/审计/定价经理/管理员
 *   L2 毛利+物料成本 — 销售经理/产品经理
 *   L1 销售价+毛利率% — 销售代表/售前
 *   L0 仅协议价 — 渠道伙伴/运营/供应链
 *
 * @author CPQ Team
 * @since 2026-06-09
 */
@Slf4j
@Service
public class AbacCostEnforcementService {

    /**
     * 成本可见性级别
     */
    public enum CostLevel {
        L0, L1, L2, L3
    }

    private static final Map<String, CostLevel> ROLE_COST_MAP = new LinkedHashMap<>();
    static {
        ROLE_COST_MAP.put("executive", CostLevel.L3);
        ROLE_COST_MAP.put("auditor", CostLevel.L3);
        ROLE_COST_MAP.put("pricing_manager", CostLevel.L3);
        ROLE_COST_MAP.put("admin", CostLevel.L3);
        ROLE_COST_MAP.put("superadmin", CostLevel.L3);
        ROLE_COST_MAP.put("sales_manager", CostLevel.L2);
        ROLE_COST_MAP.put("product_manager", CostLevel.L2);
        ROLE_COST_MAP.put("sales_rep", CostLevel.L1);
        ROLE_COST_MAP.put("presales", CostLevel.L1);
        ROLE_COST_MAP.put("default", CostLevel.L1);
        ROLE_COST_MAP.put("channel_partner", CostLevel.L0);
        ROLE_COST_MAP.put("operations", CostLevel.L0);
        ROLE_COST_MAP.put("supply_chain", CostLevel.L0);
    }

    /**
     * 根据用户角色推导成本可见级别（优先取最高级别）
     */
    public CostLevel getUserCostLevel(List<String> roles) {
        if (roles == null || roles.isEmpty()) {
            return CostLevel.L0;
        }
        return roles.stream()
                .map(r -> ROLE_COST_MAP.getOrDefault(r.toLowerCase(), CostLevel.L0))
                .max(Comparator.comparingInt(Enum::ordinal))
                .orElse(CostLevel.L0);
    }

    /**
     * 根据用户角色推导成本可见级别（从角色数组）
     */
    public CostLevel getUserCostLevel(String[] roles) {
        if (roles == null || roles.length == 0) {
            return CostLevel.L0;
        }
        return getUserCostLevel(Arrays.asList(roles));
    }

    /**
     * 对报价行项目的成本字段进行脱敏
     * <p>
     * 成本字段约定：
     *   L3: unitCost, materialCost, laborCost, overheadCost, bomCost, totalCost — 全部可见
     *   L2: materialCost, grossMargin, salesPrice, grossMarginPct — 可见
     *   L1: salesPrice, grossMarginPct — 可见
     *   L0: 以上全部隐藏（仅 agreementPrice 可见）
     */
    public Map<String, Object> enforceLineItem(Map<String, Object> lineItem, CostLevel level) {
        if (lineItem == null) return null;

        Map<String, Object> masked = new LinkedHashMap<>(lineItem);

        if (level.ordinal() < CostLevel.L3.ordinal()) {
            maskField(masked, "unitCost");
            maskField(masked, "laborCost");
            maskField(masked, "overheadCost");
            maskField(masked, "bomCost");
            maskField(masked, "totalCost");
        }
        if (level.ordinal() < CostLevel.L2.ordinal()) {
            maskField(masked, "materialCost");
            maskField(masked, "grossMargin");
        }
        if (level.ordinal() < CostLevel.L1.ordinal()) {
            maskField(masked, "salesPrice");
            maskField(masked, "grossMarginPct");
            maskField(masked, "discountedPrice");
        }

        return masked;
    }

    /**
     * 对报价行项目列表整体执行成本脱敏
     */
    public List<Map<String, Object>> enforceLineItems(List<Map<String, Object>> items, CostLevel level) {
        if (items == null) return null;
        List<Map<String, Object>> result = new ArrayList<>(items.size());
        for (Map<String, Object> item : items) {
            result.add(enforceLineItem(item, level));
        }
        return result;
    }

    private void maskField(Map<String, Object> map, String field) {
        if (map.containsKey(field)) {
            map.put(field, null);
        }
    }
}
