package org.dromara.cpq.approval.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import org.dromara.common.tenant.core.TenantEntity;

import java.io.Serial;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_approval_chain")
public class CpqApprovalChain extends TenantEntity {
    @Serial private static final long serialVersionUID = 1L;

    @TableId(value = "chain_id")
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
