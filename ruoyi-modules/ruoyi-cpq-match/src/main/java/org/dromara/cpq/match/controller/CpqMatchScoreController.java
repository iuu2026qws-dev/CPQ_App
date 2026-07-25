package org.dromara.cpq.match.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.cpq.match.domain.vo.MatchScoreRequest;
import org.dromara.cpq.match.domain.vo.MatchScoreResponse;
import org.dromara.cpq.match.engine.ScoringEngine;
import org.dromara.common.core.domain.R;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * CPQ 评分匹配控制器
 * POST /cpq/match/score  — 执行评分匹配
 * GET  /cpq/match/weights/{categoryId} — 查询产品线评分模型
 */
@Slf4j
@RestController
@RequestMapping("/cpq/match")
@RequiredArgsConstructor
public class CpqMatchScoreController {

    private final ScoringEngine scoringEngine;
    private final JdbcTemplate jdbcTemplate;

    /**
     * 评分匹配：输入需求 → 返回 Top10
     */
    @PostMapping("/score")
    public R<MatchScoreResponse> score(@RequestBody MatchScoreRequest request) {
        try {
            if (request.getCategoryId() == null) {
                return R.fail("产品线ID不能为空");
            }
            log.info("[MatchScore] categoryId={}, requirements={}", request.getCategoryId(), request.getRequirements());
            MatchScoreResponse response = scoringEngine.score(request);
            log.info("[MatchScore] 匹配完成, 推荐{}款产品, 阈值通过={}", response.getTotalScored(), response.getThresholdPassed());
            return R.ok(response);
        } catch (RuntimeException e) {
            log.error("[MatchScore] 评分失败: {}", e.getMessage());
            return R.fail(e.getMessage());
        } catch (Exception e) {
            log.error("[MatchScore] 评分引擎异常", e);
            return R.fail("评分引擎不可用");
        }
    }

    /**
     * 查询指定产品线的评分模型（维度+算法+权重）
     */
    @GetMapping("/weights/{categoryId}")
    public R<List<Map<String, Object>>> getWeights(@PathVariable Long categoryId) {
        List<Map<String, Object>> weights = jdbcTemplate.queryForList(
            "SELECT dimension_code, dimension_name, score_type, score_formula, dim_weight, sort_order " +
            "FROM cpq_scoring_weight WHERE tenant_id='000000' AND category_id=? AND status='0' AND del_flag='0' " +
            "ORDER BY sort_order", categoryId);
        return R.ok(weights);
    }
}
