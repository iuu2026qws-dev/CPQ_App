package org.dromara.cpq.domain.bo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;
import org.dromara.cpq.domain.CpqProductVariant;

import java.io.Serial;
import java.math.BigDecimal;

@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = CpqProductVariant.class, reverseConvertGenerate = false)
public class CpqProductVariantBo extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    private Long variantId;
    private Long modelId;
    private String variantCode;
    private String variantName;
    private String attributes;
    private Long defaultBomId;
    private BigDecimal basePrice;
    private String thumbnailUrl;
    private String isDefault;
    private String status;
}
