package org.dromara.cpq.match.domain.vo;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MatchScoreResponse {
    private Long resultId;
    private String sessionId;
    private List<RecommendationVO> recommendations;
    private BigDecimal threshold;
    private Boolean thresholdPassed;
    private Boolean suggestDiy;
    private Integer totalScored;
}
