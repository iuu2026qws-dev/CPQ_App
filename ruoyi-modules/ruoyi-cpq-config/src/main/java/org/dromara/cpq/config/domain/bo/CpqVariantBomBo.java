package org.dromara.cpq.config.domain.bo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;
import org.dromara.cpq.config.domain.CpqVariantBom;

import java.io.Serial;
import java.math.BigDecimal;

@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = CpqVariantBom.class, reverseConvertGenerate = false)
public class CpqVariantBomBo extends TenantEntity {
    @Serial
    private static final long serialVersionUID = 1L;
    private Long variantId;
    private Long modelId;
    private Long sbomLineId;
    private String materialCode;
    private BigDecimal quantity;
    private String effectivityCondition;
    private String isDefault;
    private Integer sortOrder;
}
