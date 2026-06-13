package org.dromara.cpq.pricing.domain.bo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;
import org.dromara.cpq.pricing.domain.CpqPriceBookEntry;

import java.io.Serial;
import java.math.BigDecimal;
import java.util.Date;

@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = CpqPriceBookEntry.class, reverseConvertGenerate = false)
public class CpqPriceBookEntryBo extends TenantEntity {
    @Serial
    private static final long serialVersionUID = 1L;
    private Long entryId;
    private Long priceBookId;
    private Long modelId;
    private Long variantId;
    private String itemCode;
    private String regionCode;
    private String channelCode;
    private BigDecimal listPrice;
    private BigDecimal costPrice;
    private BigDecimal minPrice;
    private Date effectiveDate;
    private Date expiryDate;
    private String status;
}
