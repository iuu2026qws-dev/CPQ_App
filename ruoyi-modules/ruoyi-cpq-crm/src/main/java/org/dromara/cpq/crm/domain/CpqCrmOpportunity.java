package org.dromara.cpq.crm.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

import java.math.BigDecimal;
import java.util.Date;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_crm_opportunity")
public class CpqCrmOpportunity extends TenantEntity {
    @TableId
    private Long opportunityId;
    private String opportunityName;
    private String opportunityCode;
    private Long accountId;
    private String stage;
    private Date closeDate;
    private BigDecimal amount;
    private BigDecimal probability;
    private String opportunityType;
    private String leadSource;
    private String nextStep;
    private Long ownerId;
    private String contactName;
    private String contactPhone;
    private String description;
    private String isClosed;
    private String closedReason;
}
