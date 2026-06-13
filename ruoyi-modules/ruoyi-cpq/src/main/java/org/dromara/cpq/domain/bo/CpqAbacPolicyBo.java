package org.dromara.cpq.domain.bo;

import lombok.Data;
import lombok.EqualsAndHashCode;
import io.github.linpeilie.annotations.AutoMapper;
import org.dromara.common.tenant.core.TenantEntity;
import org.dromara.cpq.domain.CpqAbacPolicy;

import java.io.Serial;

/**
 * CPQ ABAC策略 BO
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = CpqAbacPolicy.class, reverseConvertGenerate = false)
public class CpqAbacPolicyBo extends TenantEntity {

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
}
