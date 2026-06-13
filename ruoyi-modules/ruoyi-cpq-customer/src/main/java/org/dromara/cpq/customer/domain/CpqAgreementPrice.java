package org.dromara.cpq.customer.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;
import java.math.BigDecimal;
import java.util.Date;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_agreement_price")
public class CpqAgreementPrice extends TenantEntity {
    @TableId private Long agreementId;
    private Long accountId;
    private Long modelId;
    private String itemCode;
    private BigDecimal agreementPrice;
    private BigDecimal discountPct;
    private Date effectiveDate;
    private Date expiryDate;
    private String status;
    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
