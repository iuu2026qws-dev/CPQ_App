package org.dromara.cpq.domain.vo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import org.dromara.cpq.domain.CpqAbacPolicy;

import java.io.Serial;
import java.io.Serializable;
import java.util.Date;

/**
 * CPQ ABAC策略 VO
 *
 * @author CPQ Team
 */
@Data
@AutoMapper(target = CpqAbacPolicy.class, reverseConvertGenerate = true)
public class CpqAbacPolicyVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    private Long policyId;
    private String policyName;
    private String policyType;
    private String subjectType;
    private String subjectValue;
    private String attributeKey;
    private String attributeValue;
    private String status;
    private String tenantId;
    private Date createTime;
    private Date updateTime;
    private String remark;
}
