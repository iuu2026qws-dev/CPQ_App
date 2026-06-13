package org.dromara.cpq.pricing.domain.bo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;
import org.dromara.cpq.pricing.domain.CpqCurrencyRate;

import java.io.Serial;
import java.math.BigDecimal;
import java.util.Date;

@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = CpqCurrencyRate.class, reverseConvertGenerate = false)
public class CpqCurrencyRateBo extends TenantEntity {
    @Serial
    private static final long serialVersionUID = 1L;
    private Long rateId;
    private String fromCurrency;
    private String toCurrency;
    private BigDecimal exchangeRate;
    private Date effectiveDate;
    private String status;
}
