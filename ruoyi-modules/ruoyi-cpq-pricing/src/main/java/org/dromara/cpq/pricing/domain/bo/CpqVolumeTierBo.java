package org.dromara.cpq.pricing.domain.bo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;
import org.dromara.cpq.pricing.domain.CpqVolumeTier;

import java.io.Serial;
import java.math.BigDecimal;

@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = CpqVolumeTier.class, reverseConvertGenerate = false)
public class CpqVolumeTierBo extends TenantEntity {
    @Serial
    private static final long serialVersionUID = 1L;
    private Long tierId;
    private Long priceBookEntryId;
    private BigDecimal minQuantity;
    private BigDecimal maxQuantity;
    private BigDecimal unitPrice;
    private Integer sortOrder;
}
