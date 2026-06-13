package org.dromara.cpq.pricing.domain.vo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import org.dromara.cpq.pricing.domain.CpqPriceRule;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

@Data
@AutoMapper(target = CpqPriceRule.class, reverseConvertGenerate = true)
public class CpqPriceRuleVo implements Serializable {
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
    private String tenantId;
    private Date createTime;
    private Date updateTime;
    private String remark;
}
