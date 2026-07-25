package org.dromara.cpq.match.engine;

import com.alibaba.fastjson.JSONObject;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.cpq.match.domain.vo.*;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 6种评分算法分发器，输出原始分+差异说明
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class GenericDimensionScorer {

    private static final BigDecimal DEFAULT_SCORE = BigDecimal.valueOf(100);

    public ScoredDimensionVO score(
            String dimensionCode, String scoreType,
            JSONObject formula, List<String> attrValues,
            MatchRequirements requirements) {

        return switch (scoreType) {
            case "RANGE_COVER" -> rangeCover(dimensionCode, formula, attrValues, requirements);
            case "ENUM_HIERARCHY" -> enumHierarchy(formula, attrValues, requirements);
            case "NUMERIC_SCALE" -> numericScale(formula, attrValues, requirements);
            case "ENUM_MATCH" -> enumMatch(formula, attrValues, requirements);
            case "CERT_CHAIN" -> certChain(formula, attrValues, requirements);
            case "BONUS_COMPOSITE" -> bonusComposite(formula, attrValues, requirements);
            default -> ScoredDimensionVO.builder()
                .rawScore(DEFAULT_SCORE).detail("未知算法").difference("").build();
        };
    }

    // ── RANGE_COVER ──────────────────────────────────────

    private ScoredDimensionVO rangeCover(String dimCode, JSONObject formula,
                                         List<String> attrValues, MatchRequirements req) {
        BigDecimal tolerance = formula.getBigDecimal("tolerance");
        if (tolerance == null) tolerance = BigDecimal.valueOf(5);

        if ("SIZE_MATCH".equals(dimCode)) {
            return sizeRangeCover(tolerance, attrValues, req);
        } else if ("TEMP_MATCH".equals(dimCode)) {
            return tempRangeCover(tolerance, attrValues, req);
        }
        return ScoredDimensionVO.builder().rawScore(DEFAULT_SCORE).detail("未知RANGE维度").difference("").build();
    }

    private ScoredDimensionVO sizeRangeCover(BigDecimal tolerance, List<String> attrValues, MatchRequirements req) {
        if (req.getDimensions() == null || req.getDimensions().isEmpty()) {
            return ScoredDimensionVO.builder().rawScore(DEFAULT_SCORE).detail("尺寸需求未提供").difference("").build();
        }
        BigDecimal reqL = req.getDimensions().get("length");
        BigDecimal reqW = req.getDimensions().get("width");
        BigDecimal reqH = req.getDimensions().get("height");
        if (reqL == null && reqW == null && reqH == null) {
            return ScoredDimensionVO.builder().rawScore(DEFAULT_SCORE).detail("尺寸需求为空").difference("").build();
        }

        BigDecimal prodL = parseAttr(attrValues.size() > 0 ? attrValues.get(0) : null);
        BigDecimal prodW = parseAttr(attrValues.size() > 1 ? attrValues.get(1) : null);
        BigDecimal prodH = parseAttr(attrValues.size() > 2 ? attrValues.get(2) : null);
        if (prodL == null || prodW == null || prodH == null) {
            return ScoredDimensionVO.builder().rawScore(BigDecimal.ZERO).detail("产品尺寸数据缺失").difference("").build();
        }

        // 计算尺寸偏差：长宽高各自偏差百分比取平均
        double devL = reqL != null && reqL.doubleValue() > 0 ? Math.abs(reqL.doubleValue() - prodL.doubleValue()) / reqL.doubleValue() * 100 : 0;
        double devW = reqW != null && reqW.doubleValue() > 0 ? Math.abs(reqW.doubleValue() - prodW.doubleValue()) / reqW.doubleValue() * 100 : 0;
        double devH = reqH != null && reqH.doubleValue() > 0 ? Math.abs(reqH.doubleValue() - prodH.doubleValue()) / reqH.doubleValue() * 100 : 0;
        double avgDev = (devL + devW + devH) / 3.0;

        BigDecimal score = BigDecimal.valueOf(Math.max(0, 100 - avgDev * (100 / tolerance.doubleValue())));
        score = score.min(BigDecimal.valueOf(100)).setScale(2, RoundingMode.HALF_UP);

        String diff = avgDev > tolerance.doubleValue()
            ? String.format("尺寸偏差%.1f%%（超出容差%.0f%%）", avgDev, tolerance)
            : String.format("尺寸偏差%.1f%%（容差内）", avgDev);
        String detail = String.format("需求L%.1f×W%.1f×H%.1f vs 产品L%.1f×W%.1f×H%.1f",
            reqL != null ? reqL : 0, reqW != null ? reqW : 0, reqH != null ? reqH : 0,
            prodL, prodW, prodH);
        return ScoredDimensionVO.builder().rawScore(score).detail(detail).difference(diff).build();
    }

    private ScoredDimensionVO tempRangeCover(BigDecimal tolerance, List<String> attrValues, MatchRequirements req) {
        if (req.getTempMin() == null && req.getTempMax() == null) {
            return ScoredDimensionVO.builder().rawScore(DEFAULT_SCORE).detail("温度需求未提供").difference("").build();
        }

        BigDecimal prodLow = parseAttr(attrValues.size() > 0 ? attrValues.get(0) : null);
        BigDecimal prodHigh = parseAttr(attrValues.size() > 1 ? attrValues.get(1) : null);
        if (prodLow == null || prodHigh == null) {
            return ScoredDimensionVO.builder().rawScore(BigDecimal.ZERO).detail("产品温度数据缺失").difference("").build();
        }

        BigDecimal reqLow = req.getTempMin() != null ? req.getTempMin() : BigDecimal.valueOf(-100);
        BigDecimal reqHigh = req.getTempMax() != null ? req.getTempMax() : BigDecimal.valueOf(200);

        boolean lowCover = prodLow.compareTo(reqLow) <= 0;
        boolean highCover = prodHigh.compareTo(reqHigh) >= 0;

        if (lowCover && highCover) {
            return ScoredDimensionVO.builder().rawScore(BigDecimal.valueOf(100))
                .detail(String.format("产品[%.0f,%.0f]完全覆盖需求[%.0f,%.0f]", prodLow, prodHigh, reqLow, reqHigh))
                .difference("").build();
        }

        BigDecimal lowPenalty = lowCover ? BigDecimal.ZERO
            : BigDecimal.valueOf(Math.min(50, reqLow.subtract(prodLow).abs().doubleValue() * 2));
        BigDecimal highPenalty = highCover ? BigDecimal.ZERO
            : BigDecimal.valueOf(Math.min(50, prodHigh.subtract(reqHigh).abs().doubleValue() * 2));

        BigDecimal score = BigDecimal.valueOf(100).subtract(lowPenalty).subtract(highPenalty);
        score = score.max(BigDecimal.ZERO);

        StringBuilder diff = new StringBuilder();
        if (!lowCover) diff.append(String.format("低温差%.0f℃ ", reqLow.subtract(prodLow).abs()));
        if (!highCover) diff.append(String.format("高温差%.0f℃", prodHigh.subtract(reqHigh).abs()));

        return ScoredDimensionVO.builder().rawScore(score)
            .detail(String.format("需求[%.0f,%.0f] vs 产品[%.0f,%.0f]", reqLow, reqHigh, prodLow, prodHigh))
            .difference(diff.toString().trim()).build();
    }

    // ── ENUM_HIERARCHY ──────────────────────────────────

    private ScoredDimensionVO enumHierarchy(JSONObject formula, List<String> attrValues, MatchRequirements req) {
        if (req.getUsageType() == null || req.getUsageType().isEmpty()) {
            return ScoredDimensionVO.builder().rawScore(DEFAULT_SCORE).detail("用途未提供").difference("").build();
        }
        JSONObject hierarchy = formula.getJSONObject("hierarchy");
        if (hierarchy == null) return ScoredDimensionVO.builder().rawScore(BigDecimal.valueOf(50)).detail("层级配置缺失").difference("").build();

        String reqUsage = req.getUsageType();
        String prodUsage = attrValues.isEmpty() ? "" : attrValues.get(0);

        String reqCat = findCategory(hierarchy, reqUsage);
        String prodCat = findCategory(hierarchy, prodUsage);

        BigDecimal score; String detail; String difference;
        if (reqCat == null) {
            score = BigDecimal.valueOf(50);
            detail = String.format("需求'%s'未在分类中", reqUsage);
            difference = "";
        } else if (reqCat.equals(prodCat)) {
            score = reqUsage.equals(prodUsage) ? BigDecimal.valueOf(100) : BigDecimal.valueOf(80);
            detail = String.format("同大类[%s]: 需求'%s' vs 产品'%s'", reqCat, reqUsage, prodUsage);
            difference = reqUsage.equals(prodUsage) ? "" : "同大类不同细分";
        } else {
            score = BigDecimal.valueOf(30);
            detail = String.format("需求大类[%s] vs 产品大类[%s]", reqCat, prodCat);
            difference = String.format("需求'%s' ≠ 产品'%s'", reqCat, prodCat);
        }
        return ScoredDimensionVO.builder().rawScore(score).detail(detail).difference(difference).build();
    }

    private String findCategory(JSONObject hierarchy, String usage) {
        if (usage == null || usage.isEmpty()) return null;
        // 1. 直接匹配大类名（如 "工业" 直接等于大类名）
        if (hierarchy.containsKey(usage)) return usage;
        // 2. 在子项中查找
        for (String cat : hierarchy.keySet()) {
            var arr = hierarchy.getJSONArray(cat);
            if (arr != null && arr.toJavaList(String.class).contains(usage)) return cat;
        }
        return null;
    }

    // ── NUMERIC_SCALE ────────────────────────────────────

    private ScoredDimensionVO numericScale(JSONObject formula, List<String> attrValues, MatchRequirements req) {
        if (req.getLifeCycleYears() == null) {
            return ScoredDimensionVO.builder().rawScore(DEFAULT_SCORE).detail("寿命需求未提供").difference("").build();
        }
        BigDecimal reqLife = req.getLifeCycleYears();
        BigDecimal prodLife = parseAttr(attrValues.isEmpty() ? null : attrValues.get(0));
        if (prodLife == null) return ScoredDimensionVO.builder().rawScore(BigDecimal.ZERO).detail("产品寿命数据缺失").difference("").build();

        String direction = formula.getString("direction");
        if ("gte".equals(direction)) {
            if (prodLife.compareTo(reqLife) >= 0) {
                return ScoredDimensionVO.builder().rawScore(BigDecimal.valueOf(100))
                    .detail(String.format("产品%.0f >= 需求%.0f", prodLife, reqLife)).difference("").build();
            }
            BigDecimal ratio = prodLife.divide(reqLife, 4, RoundingMode.HALF_UP);
            BigDecimal score = ratio.multiply(BigDecimal.valueOf(100)).min(BigDecimal.valueOf(100));
            return ScoredDimensionVO.builder().rawScore(score)
                .detail(String.format("产品%.0f / 需求%.0f", prodLife, reqLife))
                .difference(String.format("寿命不足(%.0f%%)", ratio.multiply(BigDecimal.valueOf(100)))).build();
        }
        return ScoredDimensionVO.builder().rawScore(DEFAULT_SCORE).detail("未知方向").difference("").build();
    }

    // ── ENUM_MATCH ───────────────────────────────────────

    private ScoredDimensionVO enumMatch(JSONObject formula, List<String> attrValues, MatchRequirements req) {
        if (req.getSealLevel() == null || req.getSealLevel().isEmpty()) {
            return ScoredDimensionVO.builder().rawScore(DEFAULT_SCORE).detail("密封等级未提供").difference("").build();
        }
        JSONObject rankMap = formula.getJSONObject("rankMap");
        if (rankMap == null) return ScoredDimensionVO.builder().rawScore(BigDecimal.valueOf(50)).detail("排名配置缺失").difference("").build();

        String reqSeal = req.getSealLevel().toUpperCase();
        String prodSeal = attrValues.isEmpty() ? "NONE" : attrValues.get(0).toUpperCase();

        int reqRank = rankMap.getInteger(reqSeal) != null ? rankMap.getInteger(reqSeal) : 0;
        int prodRank = rankMap.getInteger(prodSeal) != null ? rankMap.getInteger(prodSeal) : 0;

        BigDecimal score; String difference;
        if (prodRank >= reqRank) {
            score = BigDecimal.valueOf(100);
            difference = prodRank > reqRank ? String.format("产品'%s'高于需求'%s'", prodSeal, reqSeal) : "";
        } else if (reqRank == 0) {
            score = BigDecimal.valueOf(50);
            difference = String.format("需求'%s'未识别", reqSeal);
        } else {
            double pct = (double) prodRank / reqRank;
            score = BigDecimal.valueOf(Math.max(10, pct * 100));
            difference = String.format("产品'%s'不满足需求'%s'", prodSeal, reqSeal);
        }
        return ScoredDimensionVO.builder().rawScore(score)
            .detail(String.format("需求'%s'(rank=%d) vs 产品'%s'(rank=%d)", reqSeal, reqRank, prodSeal, prodRank))
            .difference(difference).build();
    }

    // ── CERT_CHAIN ───────────────────────────────────────

    private ScoredDimensionVO certChain(JSONObject formula, List<String> attrValues, MatchRequirements req) {
        if (req.getRequiredCertifications() == null || req.getRequiredCertifications().isEmpty()) {
            return ScoredDimensionVO.builder().rawScore(DEFAULT_SCORE).detail("认证需求未提供").difference("").build();
        }
        String prodCertsStr = attrValues.isEmpty() ? "" : attrValues.get(0);
        Set<String> prodCerts = prodCertsStr.isEmpty() ? Set.of()
            : Arrays.stream(prodCertsStr.split(",")).map(String::trim).collect(Collectors.toSet());

        List<String> reqCerts = req.getRequiredCertifications();
        long total = reqCerts.size();
        long covered = reqCerts.stream().filter(prodCerts::contains).count();
        List<String> missing = reqCerts.stream().filter(c -> !prodCerts.contains(c)).toList();

        BigDecimal score = total == 0 ? DEFAULT_SCORE
            : BigDecimal.valueOf(covered).multiply(BigDecimal.valueOf(100))
                .divide(BigDecimal.valueOf(total), 2, RoundingMode.HALF_UP);

        return ScoredDimensionVO.builder().rawScore(score)
            .detail(String.format("需要%d项, 产品覆盖%d项", total, covered))
            .difference(missing.isEmpty() ? "" : "缺少: " + String.join(",", missing)).build();
    }

    // ── BONUS_COMPOSITE ──────────────────────────────────

    private ScoredDimensionVO bonusComposite(JSONObject formula, List<String> attrValues, MatchRequirements req) {
        BigDecimal moq = parseAttr(attrValues.size() > 0 ? attrValues.get(0) : null);
        BigDecimal leadTime = parseAttr(attrValues.size() > 1 ? attrValues.get(1) : null);
        BigDecimal stock = parseAttr(attrValues.size() > 2 ? attrValues.get(2) : null);

        BigDecimal score = BigDecimal.valueOf(70);
        if (moq != null && moq.compareTo(BigDecimal.valueOf(500)) <= 0) score = score.add(BigDecimal.TEN);
        if (moq != null && moq.compareTo(BigDecimal.valueOf(200)) <= 0) score = score.add(BigDecimal.TEN);
        if (leadTime != null && leadTime.compareTo(BigDecimal.valueOf(7)) <= 0) score = score.add(BigDecimal.valueOf(5));
        if (leadTime != null && leadTime.compareTo(BigDecimal.valueOf(5)) <= 0) score = score.add(BigDecimal.valueOf(5));
        if (stock != null && stock.compareTo(BigDecimal.valueOf(10000)) >= 0) score = score.add(BigDecimal.valueOf(5));
        if (stock != null && stock.compareTo(BigDecimal.valueOf(100000)) >= 0) score = score.add(BigDecimal.valueOf(5));
        score = score.min(BigDecimal.valueOf(100));

        return ScoredDimensionVO.builder().rawScore(score)
            .detail(String.format("MOQ=%s,交期=%s天,库存=%s", moq, leadTime, stock != null ? stock.longValue() : "N/A"))
            .difference("").build();
    }

    private BigDecimal parseAttr(String val) {
        if (val == null || val.isEmpty()) return null;
        try { return new BigDecimal(val.trim()); }
        catch (NumberFormatException e) { return null; }
    }
}
