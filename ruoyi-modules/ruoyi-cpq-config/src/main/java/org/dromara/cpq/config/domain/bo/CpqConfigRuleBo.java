package org.dromara.cpq.config.domain.bo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;
import org.dromara.cpq.config.domain.CpqConfigRule;

import java.io.Serial;
import java.util.Date;
import java.util.Date;

@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = CpqConfigRule.class, reverseConvertGenerate = false)
public class CpqConfigRuleBo extends TenantEntity {
    @Serial
    private static final long serialVersionUID = 1L;
    private Long ruleId;
    private String ruleName;
    private String ruleType;
    private Long modelId;
    private String conditionExpr;
    private String actionExpr;
    private String errorMessage;
    private String severity;
    private Integer priority;
    private Date effectiveDate;
    private Date expiryDate;
    private String status;
}
