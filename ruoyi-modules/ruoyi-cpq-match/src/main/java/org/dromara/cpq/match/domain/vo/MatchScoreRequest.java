package org.dromara.cpq.match.domain.vo;

import lombok.Data;

@Data
public class MatchScoreRequest {
    private Long categoryId;
    private MatchRequirements requirements;
}
