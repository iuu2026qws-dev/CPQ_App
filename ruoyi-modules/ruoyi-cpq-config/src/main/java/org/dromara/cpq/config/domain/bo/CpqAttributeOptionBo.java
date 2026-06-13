package org.dromara.cpq.config.domain.bo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;
import org.dromara.cpq.config.domain.CpqAttributeOption;

import java.io.Serial;

@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = CpqAttributeOption.class, reverseConvertGenerate = false)
public class CpqAttributeOptionBo extends TenantEntity {
    @Serial
    private static final long serialVersionUID = 1L;
    private Long optionId;
    private Long modelId;
    private String attrName;
    private String optionCode;
    private String optionLabel;
    private String optionValue;
    private String isDefault;
    private Integer sortOrder;
}
