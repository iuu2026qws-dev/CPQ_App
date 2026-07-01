package org.dromara.cpq.crm.domain.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.Date;

@Data
@NoArgsConstructor
public class CpqCrmOpportunityVo {
    private Long opportunityId;
    private String opportunityName;
    private String opportunityCode;
    private Long accountId;
    private String accountName;
    private String stage;
    @JsonFormat(pattern = "yyyy-MM-dd")
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
