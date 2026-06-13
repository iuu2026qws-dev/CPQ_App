package org.dromara.cpq.pricing.domain.bo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;
import org.dromara.cpq.pricing.domain.CpqChannelPrice;

import java.io.Serial;
import java.math.BigDecimal;
import java.util.Date;

@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = CpqChannelPrice.class, reverseConvertGenerate = false)
public class CpqChannelPriceBo extends TenantEntity {
    @Serial
    private static final long serialVersionUID = 1L;
    private Long channelPriceId;
    private String channelCode;
    private Long modelId;
    private Long variantId;
    private BigDecimal channelListPrice;
    private BigDecimal channelDiscountPct;
    private Date effectiveDate;
    private Date expiryDate;
    private String status;
}
