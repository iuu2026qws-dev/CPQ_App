package org.dromara.cpq.match.engine;

import com.alibaba.fastjson.JSON;
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
 * 评分引擎：按产品线加载维度配置 → 逐产品打分 → 过滤排序 → Top N 推荐
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ScoringEngine {

    private final JdbcTemplate jdbcTemplate;
    private final GenericDimensionScorer scorer;

    // ── 公开入口 ──────────────────────────────────────────

    public MatchScoreResponse score(MatchScoreRequest request) {
        Long categoryId = request.getCategoryId();
        String tenantId = "000000";

        // 1. 加载该产品线的所有维度配置（算法+参数+权重）
        List<Map<String, Object>> weightRows = jdbcTemplate.queryForList(
            "SELECT dimension_code, dimension_name, score_type, score_formula, dim_weight, sort_order " +
            "FROM cpq_scoring_weight WHERE tenant_id=? AND category_id=? AND status='0' AND del_flag='0' " +
            "ORDER BY sort_order", tenantId, categoryId);
        if (weightRows.isEmpty()) throw new RuntimeException("该产品线未配置评分维度");

        // 2. 加载维度→属性映射
        List<String> dimensionCodes = weightRows.stream()
            .map(r -> (String) r.get("dimension_code")).toList();
        String inClause = String.join(",", dimensionCodes.stream().map(s -> "'" + s + "'").toList());
        List<Map<String, Object>> mappingRows = jdbcTemplate.queryForList(
            "SELECT dimension_code, product_attr_category, product_attr_name, mapping_role " +
            "FROM cpq_dimension_attr_mapping WHERE tenant_id=? AND dimension_code IN (" + inClause + ") " +
            "AND status='0' AND del_flag='0'", tenantId);
        Map<String, List<Map<String, Object>>> mappingsByDim = new HashMap<>();
        for (Map<String, Object> row : mappingRows) {
            mappingsByDim.computeIfAbsent((String) row.get("dimension_code"), k -> new ArrayList<>()).add(row);
        }

        // 3. 加载该分类及所有子分类下的产品（支持父类配置+子类产品）
        List<Long> categoryIds = resolveCategoryIds(categoryId, tenantId);
        String catIdPlaceholders = categoryIds.stream().map(String::valueOf).collect(Collectors.joining(","));
        List<Map<String, Object>> products = jdbcTemplate.queryForList(
            "SELECT model_id, model_code, model_name, base_price, min_order_qty, lead_time_days, image_url " +
            "FROM cpq_product_model WHERE category_id IN (" + catIdPlaceholders + ") AND status='0' AND del_flag='0'");
        if (products.isEmpty()) return emptyResult(request, "产品线无可用标品");

        // 4. 加载阈值配置
        BigDecimal threshold = getConfig("DEFAULT_THRESHOLD", BigDecimal.valueOf(70));
        int topN = getConfig("TOP_N_COUNT", BigDecimal.valueOf(10)).intValue();
        int maxRematch = getConfig("MAX_REMATCH_ROUNDS", BigDecimal.valueOf(2)).intValue();

        // 5. 批量加载所有产品属性（一次查询）
        List<Long> allModelIds = products.stream().map(p -> (Long) p.get("model_id")).toList();
        Map<Long, Map<String, String>> allAttrs = loadAllProductAttrs(allModelIds);

        // 6. 逐产品评分
        List<ProductScore> scored = new ArrayList<>();
        for (Map<String, Object> product : products) {
            Long modelId = (Long) product.get("model_id");
            Map<String, String> modelAttrs = allAttrs.getOrDefault(modelId, Map.of());

            BigDecimal totalScore = BigDecimal.ZERO;
            List<DimensionScoreVO> dimScores = new ArrayList<>();
            BigDecimal weightSum = BigDecimal.ZERO;

            for (Map<String, Object> wRow : weightRows) {
                String dimCode = (String) wRow.get("dimension_code");
                String dimName = (String) wRow.get("dimension_name");
                String scoreType = (String) wRow.get("score_type");
                String scoreFormula = (String) wRow.get("score_formula");
                BigDecimal dimWeight = (BigDecimal) wRow.get("dim_weight");
                weightSum = weightSum.add(dimWeight);

                JSONObject formula = JSON.parseObject(scoreFormula);

                // 按映射获取产品属性值
                List<Map<String, Object>> mappings = mappingsByDim.getOrDefault(dimCode, List.of());
                List<String> attrValues = new ArrayList<>();
                for (Map<String, Object> m : mappings) {
                    String cat = (String) m.get("product_attr_category");
                    String name = (String) m.get("product_attr_name");
                    String key = cat + "::" + name;
                    String val = modelAttrs.get(key);
                    if (val != null) attrValues.add(val);
                }

                ScoredDimensionVO result = scorer.score(dimCode, scoreType, formula, attrValues, request.getRequirements());
                BigDecimal weighted = result.rawScore.multiply(dimWeight).divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP);
                totalScore = totalScore.add(weighted);

                dimScores.add(DimensionScoreVO.builder()
                    .dimensionCode(dimCode).dimensionName(dimName)
                    .rawScore(result.rawScore).weight(dimWeight).weighted(weighted)
                    .detail(result.detail).difference(result.difference).build());
            }

            // 权重归一化
            if (weightSum.compareTo(BigDecimal.ZERO) > 0
                && Math.abs(weightSum.doubleValue() - 100.0) > 1) {
                totalScore = totalScore.multiply(BigDecimal.valueOf(100)).divide(weightSum, 2, RoundingMode.HALF_UP);
            }

            scored.add(new ProductScore(product, totalScore, dimScores));
        }

        // 6. 排序 → 过滤 < 阈值 → Top N
        scored.sort((a, b) -> b.totalScore.compareTo(a.totalScore));
        List<ProductScore> qualified = scored.stream()
            .filter(s -> s.totalScore.compareTo(threshold) >= 0)
            .limit(topN)
            .toList();

        boolean thresholdPassed = !qualified.isEmpty();

        // 7. 构建响应
        int rank = 0;
        List<RecommendationVO> recommendations = new ArrayList<>();
        for (ProductScore s : qualified) {
            rank++;
            RecommendationVO vo = buildRecommendation(s, rank);
            recommendations.add(vo);
        }

        // 8. 保存审计记录
        Long resultId = System.currentTimeMillis() % 10000000;
        String sessionId = UUID.randomUUID().toString();
        String reqJson = JSON.toJSONString(request);
        String scoredJson = JSON.toJSONString(recommendations);
        jdbcTemplate.update(
            "INSERT INTO cpq_match_result (result_id, tenant_id, session_id, category_id, " +
            "requirement_json, scored_json, threshold_passed, suggest_diy) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
            resultId, tenantId, sessionId, categoryId,
            reqJson, scoredJson,
            thresholdPassed ? "1" : "0",
            thresholdPassed ? "0" : "1"
        );

        return MatchScoreResponse.builder()
            .resultId(resultId)
            .sessionId(sessionId)
            .recommendations(recommendations)
            .threshold(threshold)
            .thresholdPassed(thresholdPassed)
            .suggestDiy(!thresholdPassed)
            .totalScored(recommendations.size())
            .build();
    }

    // ── 私有辅助 ──────────────────────────────────────────

    /** 递归获取指定分类及所有子分类的ID列表 */
    private List<Long> resolveCategoryIds(Long categoryId, String tenantId) {
        Set<Long> ids = new LinkedHashSet<>();
        ids.add(categoryId);
        collectSubCategoryIds(categoryId, tenantId, ids);
        return new ArrayList<>(ids);
    }

    private void collectSubCategoryIds(Long parentId, String tenantId, Set<Long> result) {
        List<Map<String, Object>> children = jdbcTemplate.queryForList(
            "SELECT category_id FROM cpq_product_category WHERE parent_category_id=? AND tenant_id=? AND status='0' AND del_flag='0'",
            parentId, tenantId);
        for (Map<String, Object> child : children) {
            Long childId = (Long) child.get("category_id");
            if (result.add(childId)) {
                collectSubCategoryIds(childId, tenantId, result);
            }
        }
    }

    private RecommendationVO buildRecommendation(ProductScore s, int rank) {
        Map<String, Object> p = s.product;
        Long modelId = (Long) p.get("model_id");

        // 收集核心参数
        Map<String, Object> coreParams = new LinkedHashMap<>();
        coreParams.put("modelCode", p.get("model_code"));
        coreParams.put("modelName", p.get("model_name"));

        // 收集差异点
        List<String> diffs = new ArrayList<>();
        for (DimensionScoreVO ds : s.dimScores) {
            if (ds.getDifference() != null && !ds.getDifference().isEmpty()) {
                diffs.add(ds.getDimensionName() + ": " + ds.getDifference());
            }
        }

        // ★ 取标准价格（基准价格）
        BigDecimal basePrice = (BigDecimal) p.getOrDefault("base_price", BigDecimal.ZERO);
        PriceRange priceRange = PriceRange.builder()
            .min(basePrice.setScale(2, RoundingMode.HALF_UP))
            .max(basePrice.setScale(2, RoundingMode.HALF_UP))
            .build();

        // AI 选型理由
        StringBuilder aiReason = new StringBuilder("综合匹配度");
        BigDecimal sc = s.totalScore.setScale(1, RoundingMode.HALF_UP);
        if (sc.compareTo(BigDecimal.valueOf(90)) >= 0) aiReason.append("极高");
        else if (sc.compareTo(BigDecimal.valueOf(80)) >= 0) aiReason.append("优秀");
        else if (sc.compareTo(BigDecimal.valueOf(70)) >= 0) aiReason.append("良好");
        else aiReason.append("一般");
        aiReason.append("(").append(sc).append("分)");

        return RecommendationVO.builder()
            .rank(rank)
            .modelId(modelId)
            .modelCode((String) p.get("model_code"))
            .modelName((String) p.get("model_name"))
            .imageUrl((String) p.get("image_url"))
            .coreParams(coreParams)
            .matchDifferences(String.join("; ", diffs))
            .priceRange(priceRange)
            .aiReason(aiReason.toString())
            .basePrice(basePrice)
            .moq(((Number) p.getOrDefault("min_order_qty", 0)).intValue())
            .leadTimeDays(((Number) p.getOrDefault("lead_time_days", 0)).intValue())
            .stockQty(0)
            .totalScore(s.totalScore.setScale(2, RoundingMode.HALF_UP))
            .dimensionScores(s.dimScores)
            .build();
    }

    /** 批量加载产品属性（避免N+1查询） */
    private Map<Long, Map<String, String>> loadAllProductAttrs(List<Long> modelIds) {
        if (modelIds.isEmpty()) return Map.of();
        String idsStr = modelIds.stream().map(String::valueOf).collect(Collectors.joining(","));
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(
            "SELECT model_id, attr_category, attr_name, attr_value FROM cpq_product_attribute " +
            "WHERE model_id IN (" + idsStr + ") AND del_flag='0'");
        Map<Long, Map<String, String>> result = new LinkedHashMap<>();
        for (Map<String, Object> row : rows) {
            Long mid = (Long) row.get("model_id");
            String key = row.get("attr_category") + "::" + row.get("attr_name");
            result.computeIfAbsent(mid, k -> new LinkedHashMap<>()).put(key, (String) row.get("attr_value"));
        }
        return result;
    }

    private BigDecimal getConfig(String key, BigDecimal defaultVal) {
        try {
            List<Map<String, Object>> rows = jdbcTemplate.queryForList(
                "SELECT config_value FROM cpq_match_config WHERE tenant_id='000000' " +
                "AND config_key=? AND status='0' AND del_flag='0'", key);
            if (!rows.isEmpty()) {
                return new BigDecimal((String) rows.get(0).get("config_value"));
            }
        } catch (Exception e) {
            log.warn("读取配置{}失败: {}", key, e.getMessage());
        }
        return defaultVal;
    }

    private MatchScoreResponse emptyResult(MatchScoreRequest request, String msg) {
        return MatchScoreResponse.builder()
            .sessionId(UUID.randomUUID().toString())
            .recommendations(List.of())
            .threshold(BigDecimal.valueOf(70))
            .thresholdPassed(false)
            .suggestDiy(true)
            .totalScored(0)
            .build();
    }

    // ── 内部类 ────────────────────────────────────────────

    static class ProductScore {
        Map<String, Object> product;
        BigDecimal totalScore;
        List<DimensionScoreVO> dimScores;

        ProductScore(Map<String, Object> p, BigDecimal s, List<DimensionScoreVO> d) {
            this.product = p; this.totalScore = s; this.dimScores = d;
        }
    }
}
