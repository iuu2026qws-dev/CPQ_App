package org.dromara.cpq.match.domain.vo;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RecommendationVO {
    private Integer rank;
    private Long modelId;
    private String modelCode;
    private String modelName;
    private String imageUrl;
    private Map<String, Object> coreParams;
    private String matchDifferences;
    private PriceRange priceRange;
    private String aiReason;
    private BigDecimal basePrice;
    private Integer moq;
    private Integer leadTimeDays;
    private Integer stockQty;
    private BigDecimal totalScore;
    private List<DimensionScoreVO> dimensionScores;
}
