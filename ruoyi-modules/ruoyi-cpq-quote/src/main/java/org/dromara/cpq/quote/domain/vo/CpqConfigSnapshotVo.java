package org.dromara.cpq.quote.domain.vo;

import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serial;
import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
public class CpqConfigSnapshotVo implements Serializable {
    @Serial private static final long serialVersionUID = 1L;
    private Long snapshotId;
    private Long quoteId;
    private Long modelId;
    private String snapshotHash;
    private String selectionsJson;
    private String bomJson;
    private String ruleVersion;
    private String priceVersion;
    private String productVersion;
    private LocalDateTime snapshotTime;
}
