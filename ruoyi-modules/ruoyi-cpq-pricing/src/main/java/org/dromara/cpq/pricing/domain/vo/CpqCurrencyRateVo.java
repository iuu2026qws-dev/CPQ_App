package org.dromara.cpq.pricing.domain.vo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import org.dromara.cpq.pricing.domain.CpqCurrencyRate;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

@Data
@AutoMapper(target = CpqCurrencyRate.class, reverseConvertGenerate = true)
public class CpqCurrencyRateVo implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;
    private Long rateId;
    private String fromCurrency;
    private String toCurrency;
    private BigDecimal exchangeRate;
    private Date effectiveDate;
    private String status;
    private String tenantId;
    private Date createTime;
    private Date updateTime;
    private String remark;
}
