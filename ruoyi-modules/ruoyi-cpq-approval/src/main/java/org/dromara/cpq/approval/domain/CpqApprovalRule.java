package org.dromara.cpq.approval.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import org.dromara.common.tenant.core.TenantEntity;

import java.io.Serial;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_approval_rule")
public class CpqApprovalRule extends TenantEntity {
    @Serial private static final long serialVersionUID = 1L;

    @TableId(value = "rule_id")
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

    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
