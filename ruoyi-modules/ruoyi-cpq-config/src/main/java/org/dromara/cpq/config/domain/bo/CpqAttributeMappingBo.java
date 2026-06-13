package org.dromara.cpq.config.domain.bo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;
import org.dromara.cpq.config.domain.CpqAttributeMapping;

import java.io.Serial;

@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = CpqAttributeMapping.class, reverseConvertGenerate = false)
public class CpqAttributeMappingBo extends TenantEntity {
    @Serial
    private static final long serialVersionUID = 1L;
    private Long mappingId;
    private Long modelId;
    private String attrName;
    private String attrValue;
    private String materialCode;
    private Long sbomLineId;
    private String conditionExpr;
    private Integer sortOrder;
}
