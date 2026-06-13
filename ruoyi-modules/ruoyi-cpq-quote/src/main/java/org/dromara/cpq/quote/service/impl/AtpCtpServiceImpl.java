package org.dromara.cpq.quote.service.impl;

import cn.hutool.core.date.DateUtil;
import cn.hutool.core.util.RandomUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.cpq.quote.mapper.CpqQuoteLineItemMapper;
import org.dromara.cpq.quote.service.IAtpCtpService;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

/**
 * ATP/CTP 交期引擎服务实现
 * <p>
 * 当前阶段：模拟实现（基于规则推算），后续可对接 WMS/MES/ERP 真实数据源。
 * </p>
 * <p>三级检查逻辑：
 * 1. 库存 ATP — 模拟成品库存查询
 * 2. 物料 ATP — 模拟物料齐套检查
 * 3. 产能 ATP — 模拟产能排产检查
 * </p>
 *
 * @author CPQ Team
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AtpCtpServiceImpl implements IAtpCtpService {

    private final CpqQuoteLineItemMapper lineItemMapper;

    @Override
    public AtpResult checkAtp(Long productId, int quantity) {
        log.info("checkAtp: productId={}, quantity={}", productId, quantity);

        List<String> warnings = new ArrayList<>();
        int inventoryStock = simulateInventory(productId);
        int materialAvailable = simulateMaterial(productId);
        int capacityAvailable = simulateCapacity(productId);

        boolean inventoryOk = inventoryStock >= quantity;
        boolean materialOk = materialAvailable >= quantity;
        boolean capacityOk = capacityAvailable >= quantity;

        if (!inventoryOk) warnings.add("库存不足：需求" + quantity + "，库存" + inventoryStock);
        if (!materialOk) warnings.add("物料不足：需求" + quantity + "，可用" + materialAvailable);
        if (!capacityOk) warnings.add("产能不足：需求" + quantity + "，可用" + capacityAvailable);

        String bottleneck = !inventoryOk ? "库存" : !materialOk ? "物料" : !capacityOk ? "产能" : "无";
        int available = Math.min(inventoryStock, Math.min(materialAvailable, capacityAvailable));
        int estimatedDays = quantity <= available ? 3 + (quantity / 10) : 14 + (quantity - available) / 5;

        return new AtpResult(
            inventoryOk && materialOk && capacityOk,
            available, quantity, inventoryStock, materialAvailable, capacityAvailable,
            bottleneck, warnings, estimatedDays
        );
    }

    @Override
    public CtpResult calculateCtp(Long productId, int quantity, String targetDate) {
        log.info("calculateCtp: productId={}, quantity={}, targetDate={}", productId, quantity, targetDate);

        int capacityRemaining = simulateCapacity(productId);
        int materialReadinessDays = 2 + (quantity / 20);
        int bottleneckProcessDays = 3 + (quantity / 15);
        int totalDays = materialReadinessDays + bottleneckProcessDays + 1; // +1 buffer
        boolean feasible = capacityRemaining >= quantity;

        String deliveryDate = DateUtil.format(
            DateUtil.offsetDay(DateUtil.date(), totalDays), "yyyy-MM-dd");

        List<CtpMilestone> milestones = new ArrayList<>();
        milestones.add(new CtpMilestone("订单确认", 0, "ON_TRACK", "订单已接收"));
        milestones.add(new CtpMilestone("物料齐套", materialReadinessDays,
            materialReadinessDays <= 3 ? "ON_TRACK" : "AT_RISK",
            "预计" + materialReadinessDays + "天完成物料齐套"));
        milestones.add(new CtpMilestone("瓶颈工序", materialReadinessDays + bottleneckProcessDays / 2,
            feasible ? "ON_TRACK" : "AT_RISK",
            "关键工序排产中"));
        milestones.add(new CtpMilestone("生产完成", materialReadinessDays + bottleneckProcessDays,
            feasible ? "ON_TRACK" : "DELAYED",
            feasible ? "预计按期完成" : "产能不足，可能延期"));
        milestones.add(new CtpMilestone("品质检验", totalDays - 1, "ON_TRACK", "成品检验"));
        milestones.add(new CtpMilestone("发货", totalDays, "ON_TRACK", "预计发货日"));

        return new CtpResult(feasible, totalDays, deliveryDate,
            capacityRemaining, materialReadinessDays, bottleneckProcessDays, milestones);
    }

    @Override
    public Map<Long, AtpResult> batchCheckAtp(Map<Long, Integer> items) {
        log.info("batchCheckAtp: items={}", items.size());
        Map<Long, AtpResult> results = new LinkedHashMap<>();
        for (Map.Entry<Long, Integer> e : items.entrySet()) {
            results.put(e.getKey(), checkAtp(e.getKey(), e.getValue()));
        }
        return results;
    }

    @Override
    public List<AlternativeRecommendation> recommendAlternative(Long productId, int quantity) {
        log.info("recommendAlternative: productId={}, quantity={}", productId, quantity);
        // 模拟推荐替代产品
        List<AlternativeRecommendation> alternatives = new ArrayList<>();
        alternatives.add(new AlternativeRecommendation(
            productId + 100, "替代产品A（升级版）", quantity + 10,
            5, "性能更优，库存充足", new BigDecimal("500.00")));
        alternatives.add(new AlternativeRecommendation(
            productId + 200, "替代产品B（标准版）", quantity,
            8, "功能等效，成本更低", new BigDecimal("-300.00")));
        alternatives.add(new AlternativeRecommendation(
            productId + 300, "替代产品C（精简版）", quantity * 2,
            3, "库存充裕，交期最短", new BigDecimal("-800.00")));
        return alternatives;
    }

    // ===== 模拟数据方法（后续对接真实系统） =====

    private int simulateInventory(Long productId) {
        return 50 + (int)(productId % 10) * 20 + RandomUtil.randomInt(0, 30);
    }

    private int simulateMaterial(Long productId) {
        return 40 + (int)(productId % 8) * 15 + RandomUtil.randomInt(0, 25);
    }

    private int simulateCapacity(Long productId) {
        return 30 + (int)(productId % 6) * 25 + RandomUtil.randomInt(0, 35);
    }
}
