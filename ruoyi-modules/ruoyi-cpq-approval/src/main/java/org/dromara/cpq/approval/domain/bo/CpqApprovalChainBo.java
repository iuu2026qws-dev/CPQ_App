package org.dromara.cpq.approval.domain.bo;

import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serial;
import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
public class CpqApprovalChainBo implements Serializable {
    @Serial private static final long serialVersionUID = 1L;
    private Long chainId;
    private Long quoteId;
    private Long ruleId;
    private Integer currentStep;
    private Integer totalSteps;
    private String status;
    private Long submittedBy;
    private LocalDateTime submittedTime;
    private LocalDateTime completedTime;
    private Integer slaHours;
}
