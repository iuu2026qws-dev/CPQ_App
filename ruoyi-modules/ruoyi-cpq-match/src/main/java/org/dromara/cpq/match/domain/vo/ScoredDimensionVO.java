package org.dromara.cpq.match.domain.vo;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ScoredDimensionVO {
    public BigDecimal rawScore;
    public String detail;
    public String difference;
}
