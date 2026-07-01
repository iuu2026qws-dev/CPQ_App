package org.dromara.cpq.crm.domain.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.Date;

@Data
@NoArgsConstructor
public class CpqCrmContractVo {
    private Long contractId;
    private String contractNumber;
    private String contractName;
    private Long accountId;
    private String accountName;
    private Long opportunityId;
    private String opportunityName;
    private String contractType;
    private String status;
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date startDate;
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date endDate;
    private BigDecimal totalAmount;
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date signedDate;
    private String signingParty;
    private String paymentTerms;
    private Long ownerId;
    private String description;
}
