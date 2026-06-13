package org.dromara.cpq.pricing.service;

import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.util.ObjectUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.cpq.pricing.domain.CpqChannelPrice;
import org.dromara.cpq.pricing.domain.CpqCurrencyRate;
import org.dromara.cpq.pricing.domain.CpqPriceBook;
import org.dromara.cpq.pricing.domain.CpqPriceBookEntry;
import org.dromara.cpq.pricing.domain.CpqPriceRule;
import org.dromara.cpq.pricing.domain.CpqVolumeTier;
import org.dromara.cpq.pricing.mapper.CpqChannelPriceMapper;
import org.dromara.cpq.pricing.mapper.CpqCurrencyRateMapper;
import org.dromara.cpq.pricing.mapper.CpqPriceBookEntryMapper;
import org.dromara.cpq.pricing.mapper.CpqPriceBookMapper;
import org.dromara.cpq.pricing.mapper.CpqPriceRuleMapper;
import org.dromara.cpq.pricing.mapper.CpqVolumeTierMapper;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;

/**
 * CPQ 定价引擎 — 六阶段定价流水线
 * <p>
 * Phase 1: 获取基础价 — PriceBook.Lookup(Product, Region)
 * Phase 2: BOM 成本累加 — Sum(SBOM_Line.price * qty)
 * Phase 3: 多维定价覆盖 — Contract > Channel > Regional > List
 * Phase 4: 阶梯定价应用 — VolumeTier.Lookup(qty) → 单价调整
 * Phase 5: 折扣应用 — Discount = min(RequestedDiscount, MaxAllowedDiscount)
 * Phase 6: 净价计算 — NetPrice = AdjustedPrice * (1 - Discount), CostCheck
 * <p>
 * 对应设计文档：CPQ_后端功能设计.md §5.2 PricingEngineService
 * CPQ_阶段三_技术实现层.md §3.2 定价引擎（六阶段流水线）
 *
 * @author CPQ Team
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class PricingEngineService {

    private final CpqPriceBookMapper priceBookMapper;
    private final CpqPriceBookEntryMapper priceBookEntryMapper;
    private final CpqPriceRuleMapper priceRuleMapper;
    private final CpqVolumeTierMapper volumeTierMapper;
    private final CpqChannelPriceMapper channelPriceMapper;
    private final CpqCurrencyRateMapper currencyRateMapper;

    /**
     * 定价结果
     */
    public static class PriceResult {
        private BigDecimal basePrice = BigDecimal.ZERO;
        private BigDecimal bomCost = BigDecimal.ZERO;
        private BigDecimal bestMatchPrice = BigDecimal.ZERO;
        private BigDecimal tierAdjustedPrice = BigDecimal.ZERO;
        private BigDecimal discountPct = BigDecimal.ZERO;
        private BigDecimal netPrice = BigDecimal.ZERO;
        private boolean needsApproval;
        private String approvalReason;
        private String pricingDetail;

        public BigDecimal getBasePrice() { return basePrice; }
        public void setBasePrice(BigDecimal v) { this.basePrice = v; }
        public BigDecimal getBomCost() { return bomCost; }
        public void setBomCost(BigDecimal v) { this.bomCost = v; }
        public BigDecimal getBestMatchPrice() { return bestMatchPrice; }
        public void setBestMatchPrice(BigDecimal v) { this.bestMatchPrice = v; }
        public BigDecimal getTierAdjustedPrice() { return tierAdjustedPrice; }
        public void setTierAdjustedPrice(BigDecimal v) { this.tierAdjustedPrice = v; }
        public BigDecimal getDiscountPct() { return discountPct; }
        public void setDiscountPct(BigDecimal v) { this.discountPct = v; }
        public BigDecimal getNetPrice() { return netPrice; }
        public void setNetPrice(BigDecimal v) { this.netPrice = v; }
        public boolean isNeedsApproval() { return needsApproval; }
        public void setNeedsApproval(boolean v) { this.needsApproval = v; }
        public String getApprovalReason() { return approvalReason; }
        public void setApprovalReason(String v) { this.approvalReason = v; }
        public String getPricingDetail() { return pricingDetail; }
        public void setPricingDetail(String v) { this.pricingDetail = v; }

        @Override
        public String toString() {
            return String.format("PriceResult{base=%.2f, bomCost=%.2f, bestMatch=%.2f, tierAdj=%.2f, discount=%.2f%%, net=%.2f, needsApproval=%s}",
                basePrice, bomCost, bestMatchPrice, tierAdjustedPrice, discountPct, netPrice, needsApproval);
        }
    }

    // ==================== 六阶段定价流水线 ====================

    /**
     * 计算最终价格（完整六阶段流水线）。
     *
     * @param productModelId    产品模型 ID
     * @param variantId         变体 ID（可选，NULL=模型级定价）
     * @param quantity          数量
     * @param region            区域
     * @param channelId         渠道 ID
     * @param requestedDiscount 申请的折扣率（0.00~1.00）
     * @param bomCost           BOM 成本（外部传入，由 BomExplosionService 计算）
     * @param currency          目标币种
     * @return 定价结果
     */
    public PriceResult calculatePrice(Long productModelId, Long variantId, BigDecimal quantity,
                                      String region, Long channelId, BigDecimal requestedDiscount,
                                      BigDecimal bomCost, String currency) {
        long start = System.currentTimeMillis();
        log.info("===== 六阶段定价流水线开始 =====");
        log.info("productModelId: {}, variantId: {}, qty: {}, region: {}, channel: {}, discount: {}, bomCost: {}, currency: {}",
            productModelId, variantId, quantity, region, channelId, requestedDiscount, bomCost, currency);

        PriceResult result = new PriceResult();
        StringBuilder detail = new StringBuilder();

        // Phase 1: 获取基础价
        result.setBasePrice(getBasePrice(productModelId, variantId));
        detail.append("Phase1 listPrice=").append(result.getBasePrice()).append("; ");
        log.info("[Phase 1] 基础价: {}", result.getBasePrice());

        // Phase 2: BOM 成本（外部传入）
        result.setBomCost(bomCost != null ? bomCost : BigDecimal.ZERO);
        detail.append("Phase2 bomCost=").append(result.getBomCost()).append("; ");

        // Phase 3: 多维定价覆盖
        result.setBestMatchPrice(getBestPrice(productModelId, variantId, region, channelId, result.getBasePrice()));
        detail.append("Phase3 bestMatch=").append(result.getBestMatchPrice()).append("; ");
        log.info("[Phase 3] 多维匹配价: {}", result.getBestMatchPrice());

        // Phase 4: 阶梯定价
        result.setTierAdjustedPrice(applyVolumeTier(productModelId, quantity, result.getBestMatchPrice()));
        detail.append("Phase4 tierAdj=").append(result.getTierAdjustedPrice()).append("; ");
        log.info("[Phase 4] 阶梯调整价: {}", result.getTierAdjustedPrice());

        // Phase 5: 折扣应用
        BigDecimal maxDiscount = getMaxDiscount(productModelId, channelId);
        BigDecimal appliedDiscount = applyDiscount(requestedDiscount, maxDiscount, result);
        detail.append("Phase5 discount=").append(appliedDiscount)
            .append(" (req=").append(requestedDiscount)
            .append(", max=").append(maxDiscount).append("); ");
        log.info("[Phase 5] 折扣: {} (申请: {}, 最大: {})", appliedDiscount, requestedDiscount, maxDiscount);

        // Phase 6: 净价计算 + 成本底线检查
        result.setNetPrice(calculateNetPrice(result.getTierAdjustedPrice(), appliedDiscount));
        checkCostFloor(result);
        detail.append("Phase6 netPrice=").append(result.getNetPrice())
            .append(" needsApproval=").append(result.isNeedsApproval());

        if (result.isNeedsApproval()) {
            detail.append(" reason=").append(result.getApprovalReason());
        }

        result.setPricingDetail(detail.toString());
        log.info("===== 定价流水线完成，结果: {}, 耗时: {}ms =====",
            result, System.currentTimeMillis() - start);
        return result;
    }

    // ==================== Phase 1: 获取基础价 ====================

    private BigDecimal getBasePrice(Long productModelId, Long variantId) {
        LambdaQueryWrapper<CpqPriceBookEntry> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CpqPriceBookEntry::getModelId, productModelId);

        if (variantId != null) {
            wrapper.eq(CpqPriceBookEntry::getVariantId, variantId);
        }
        wrapper.orderByAsc(CpqPriceBookEntry::getListPrice);

        List<CpqPriceBookEntry> entries = priceBookEntryMapper.selectList(wrapper);
        if (CollUtil.isEmpty(entries)) {
            throw new ServiceException("未找到产品 " + productModelId + " 的价格条目");
        }
        return entries.get(0).getListPrice();
    }

    // ==================== Phase 3: 多维定价覆盖 ====================

    public BigDecimal getBestPrice(Long productModelId, Long variantId, String region,
                                   Long channelId, BigDecimal fallbackPrice) {
        // 1. 渠道价格（最高优先级）
        if (channelId != null) {
            LambdaQueryWrapper<CpqChannelPrice> chWrapper = new LambdaQueryWrapper<>();
            chWrapper.eq(CpqChannelPrice::getModelId, productModelId);
            if (variantId != null) {
                chWrapper.eq(CpqChannelPrice::getVariantId, variantId);
            }
            chWrapper.eq(CpqChannelPrice::getStatus, "0");
            List<CpqChannelPrice> channelPrices = channelPriceMapper.selectList(chWrapper);
            for (CpqChannelPrice cp : channelPrices) {
                if (isActive(cp.getEffectiveDate(), cp.getExpiryDate())) {
                    log.debug("Match channelPrice: {} = {}", cp.getChannelCode(), cp.getChannelListPrice());
                    return cp.getChannelListPrice();
                }
            }
        }

        // 2. 区域定价（价格手册条目中的 regionCode 维度）
        if (region != null) {
            LambdaQueryWrapper<CpqPriceBookEntry> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(CpqPriceBookEntry::getModelId, productModelId);
            wrapper.eq(CpqPriceBookEntry::getRegionCode, region);
            if (variantId != null) {
                wrapper.eq(CpqPriceBookEntry::getVariantId, variantId);
            }
            List<CpqPriceBookEntry> regional = priceBookEntryMapper.selectList(wrapper);
            if (CollUtil.isNotEmpty(regional)) {
                return regional.get(0).getListPrice();
            }
        }

        // 3. 回落：目录价
        return fallbackPrice;
    }

    // ==================== Phase 4: 阶梯定价 ====================

    public BigDecimal applyVolumeTier(Long productModelId, BigDecimal quantity, BigDecimal basePrice) {
        if (quantity == null || quantity.compareTo(BigDecimal.ZERO) <= 0) {
            return basePrice;
        }

        // 查询产品价格条目的阶梯定价（通过 priceBookEntryId 关联）
        LambdaQueryWrapper<CpqPriceBookEntry> entryWrapper = new LambdaQueryWrapper<>();
        entryWrapper.eq(CpqPriceBookEntry::getModelId, productModelId);
        List<CpqPriceBookEntry> entries = priceBookEntryMapper.selectList(entryWrapper);
        if (CollUtil.isEmpty(entries)) {
            return basePrice;
        }

        // 取第一个条目的阶梯定价
        LambdaQueryWrapper<CpqVolumeTier> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CpqVolumeTier::getPriceBookEntryId, entries.get(0).getEntryId());
        wrapper.orderByAsc(CpqVolumeTier::getMinQuantity);

        List<CpqVolumeTier> tiers = volumeTierMapper.selectList(wrapper);
        if (CollUtil.isEmpty(tiers)) {
            return basePrice;
        }

        // 匹配最优阶梯
        CpqVolumeTier bestTier = null;
        for (CpqVolumeTier tier : tiers) {
            BigDecimal minQty = tier.getMinQuantity() != null ? tier.getMinQuantity() : BigDecimal.ZERO;
            BigDecimal maxQty = tier.getMaxQuantity() != null ? tier.getMaxQuantity() : new BigDecimal("999999");
            if (quantity.compareTo(minQty) >= 0 && quantity.compareTo(maxQty) <= 0) {
                bestTier = tier;
                break;
            }
        }

        if (bestTier != null && bestTier.getUnitPrice() != null) {
            log.debug("Match volumeTier: minQty={}, maxQty={}, unitPrice={}",
                bestTier.getMinQuantity(), bestTier.getMaxQuantity(), bestTier.getUnitPrice());
            return bestTier.getUnitPrice();
        }

        return basePrice;
    }

    // ==================== Phase 5: 折扣应用 ====================

    public BigDecimal applyDiscount(BigDecimal requestedDiscount, BigDecimal maxDiscount, PriceResult result) {
        BigDecimal safeMax = maxDiscount != null ? maxDiscount : BigDecimal.ZERO;
        BigDecimal safeReq = requestedDiscount != null ? requestedDiscount : BigDecimal.ZERO;

        if (safeReq.compareTo(safeMax) > 0) {
            // 超出最大折扣 → 触发审批
            result.setNeedsApproval(true);
            result.setApprovalReason(String.format(
                "申请折扣 %.1f%% 超出最大允许折扣 %.1f%%，需审批",
                safeReq.multiply(new BigDecimal("100")),
                safeMax.multiply(new BigDecimal("100"))));
            result.setDiscountPct(safeMax); // 暂时应用最大折扣，审批后可能调整
            return safeMax;
        }

        result.setDiscountPct(safeReq);
        return safeReq;
    }

    /**
     * 获取产品/渠道的最大允许折扣率
     */
    public BigDecimal getMaxDiscount(Long productModelId, Long channelId) {
        // 查定价规则中的折扣限制（ruleType=DISCOUNT_LIMIT）
        LambdaQueryWrapper<CpqPriceRule> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CpqPriceRule::getRuleType, "DISCOUNT_LIMIT");
        wrapper.eq(CpqPriceRule::getStatus, "0");
        List<CpqPriceRule> rules = priceRuleMapper.selectList(wrapper);

        if (CollUtil.isNotEmpty(rules)) {
            // 从 conditionJson 或 actionJson 中提取 maxDiscount
            for (CpqPriceRule rule : rules) {
                String condition = rule.getConditionJson();
                if (condition != null && condition.contains("maxDiscount")) {
                    try {
                        String value = condition.replaceAll("[{}\"]", "").replace("maxDiscount:", "").trim();
                        return new BigDecimal(value);
                    } catch (Exception e) {
                        log.warn("解析最大折扣规则失败: {}", condition);
                    }
                }
            }
        }

        // 默认：最大 20% 折扣
        return new BigDecimal("0.20");
    }

    // ==================== Phase 6: 净价计算 ====================

    private BigDecimal calculateNetPrice(BigDecimal tierAdjustedPrice, BigDecimal discountPct) {
        if (tierAdjustedPrice == null) return BigDecimal.ZERO;
        if (discountPct == null) discountPct = BigDecimal.ZERO;

        return tierAdjustedPrice.multiply(BigDecimal.ONE.subtract(discountPct))
            .setScale(2, RoundingMode.HALF_UP);
    }

    private void checkCostFloor(PriceResult result) {
        // 如果净价低于 BOM 成本，需要审批
        if (result.getBomCost().compareTo(BigDecimal.ZERO) > 0
            && result.getNetPrice().compareTo(result.getBomCost()) < 0) {
            result.setNeedsApproval(true);
            String reason = String.format("净价 %.2f 低于成本 %.2f，触发成本审批",
                result.getNetPrice(), result.getBomCost());
            result.setApprovalReason(
                result.getApprovalReason() != null
                    ? result.getApprovalReason() + "; " + reason
                    : reason);
        }
    }

    // ==================== 工具方法 ====================

    private boolean isActive(java.util.Date effectiveDate, java.util.Date expiryDate) {
        LocalDate today = LocalDate.now();
        if (effectiveDate != null) {
            LocalDate eff = new java.sql.Date(effectiveDate.getTime()).toLocalDate();
            if (today.isBefore(eff)) return false;
        }
        if (expiryDate != null) {
            LocalDate exp = new java.sql.Date(expiryDate.getTime()).toLocalDate();
            if (today.isAfter(exp)) return false;
        }
        return true;
    }
}
