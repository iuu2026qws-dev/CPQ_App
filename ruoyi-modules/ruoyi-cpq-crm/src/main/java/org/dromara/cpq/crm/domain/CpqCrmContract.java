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
@TableName("cpq_crm_contract")
public class CpqCrmContract extends TenantEntity {
    @TableId
    private Long contractId;
    private String contractNumber;
    private String contractName;
    private Long accountId;
    private Long opportunityId;
    private String contractType;
    private String status;
    private Date startDate;
    private Date endDate;
    private BigDecimal totalAmount;
    private Date signedDate;
    private String signingParty;
    private String paymentTerms;
    private Long ownerId;
    private String description;
}
