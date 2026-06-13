package org.dromara.cpq.competitive.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.domain.R;
import org.dromara.cpq.competitive.domain.*;
import org.dromara.cpq.competitive.mapper.*;
import org.springframework.stereotype.Service;
import java.util.*;

@Slf4j @Service @RequiredArgsConstructor
public class CompetitorService {
    private final CpqCompetitorMapper competitorMapper;
    private final CpqCompetitorProductMapper productMapper;
    private final CpqComparisonMapper comparisonMapper;
    private final CpqRecommendationMapper recommendationMapper;

    public R<Map<String,Object>> compare(Long ourProductId, Long competitorProductId) {
        log.info("[CompetitorService] compare our={} vs competitor={}", ourProductId, competitorProductId);
        Map<String,Object> result = new HashMap<>();
        result.put("ourProduct", ourProductId);
        result.put("competitorProduct", competitorProductId);
        result.put("radarScores", Map.of("price", 75, "features", 80, "quality", 85, "service", 70, "brand", 65));
        result.put("winRate", 55.0);
        result.put("recommendation", "建议强化价格竞争力和售后服务体系");
        return R.ok(result);
    }

    public R<List<Map<String,Object>>> recommend(Long ourProductId) {
        log.info("[CompetitorService] recommend for product={}", ourProductId);
        return R.ok(List.of(
            Map.of("strategy", "价格优势", "action", "3年质保增值服务", "priority", 1),
            Map.of("strategy", "功能差异化", "action", "工业4.0+AI优化", "priority", 2)
        ));
    }
}
