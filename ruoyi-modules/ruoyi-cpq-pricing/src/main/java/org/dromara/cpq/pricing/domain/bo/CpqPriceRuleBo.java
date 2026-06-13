package org.dromara.cpq.pricing.domain.bo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;
import org.dromara.cpq.pricing.domain.CpqPriceRule;

import java.io.Serial;
import java.math.BigDecimal;
import java.util.Date;

@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = CpqPriceRule.class, reverseConvertGenerate = false)
public class CpqPriceRuleBo extends TenantEntity {
    @Serial
    private static final long serialVersionUID = 1L;
    private Long priceRuleId;
    private String ruleName;
    private String ruleType;
    private Integer priority;
    private String conditionJson;
    private String actionJson;
    private BigDecimal approvalThreshold;
    private Date effectiveDate;
    private Date expiryDate;
    private String status;
}
