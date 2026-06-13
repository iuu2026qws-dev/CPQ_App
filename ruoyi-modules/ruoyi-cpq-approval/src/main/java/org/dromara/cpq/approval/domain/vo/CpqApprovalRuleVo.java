package org.dromara.cpq.approval.domain.vo;

import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
public class CpqApprovalRuleVo implements Serializable {
    @Serial private static final long serialVersionUID = 1L;
    private Long ruleId;
    private String ruleName;
    private String triggerType;
    private BigDecimal triggerValue;
    private String approvalChainJson;
    private Integer priority;
    private String status;
}
