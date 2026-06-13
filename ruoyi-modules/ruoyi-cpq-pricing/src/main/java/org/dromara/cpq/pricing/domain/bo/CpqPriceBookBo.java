package org.dromara.cpq.pricing.domain.bo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;
import org.dromara.cpq.pricing.domain.CpqPriceBook;

import java.io.Serial;
import java.math.BigDecimal;
import java.util.Date;

@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = CpqPriceBook.class, reverseConvertGenerate = false)
public class CpqPriceBookBo extends TenantEntity {
    @Serial
    private static final long serialVersionUID = 1L;
    private Long priceBookId;
    private String bookName;
    private String bookType;
    private String currency;
    private Date effectiveDate;
    private Date expiryDate;
    private Integer priority;
    private String status;
}
