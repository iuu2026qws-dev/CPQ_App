package org.dromara.cpq.approval.domain.bo;

import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
public class CpqApprovalRuleBo implements Serializable {
    @Serial private static final long serialVersionUID = 1L;
    private Long ruleId;
    private String ruleName;
    private String triggerType;
    private String triggerScene;
    private BigDecimal triggerValue;
    private String approvalChainJson;
    private String flowCode;
    private Integer priority;
    private Integer slaHours;
    private String status;
    private String remark;
}
