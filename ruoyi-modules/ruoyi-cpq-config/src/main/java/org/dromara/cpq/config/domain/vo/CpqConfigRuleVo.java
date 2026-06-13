package org.dromara.cpq.config.domain.vo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import org.dromara.cpq.config.domain.CpqConfigRule;

import java.io.Serial;
import java.io.Serializable;
import java.util.Date;
import java.util.Date;

@Data
@AutoMapper(target = CpqConfigRule.class, reverseConvertGenerate = true)
public class CpqConfigRuleVo implements Serializable {
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
    private String tenantId;
    private java.util.Date createTime;
    private java.util.Date updateTime;
    private String remark;
}
