package org.dromara.cpq.pricing.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

import java.io.Serial;
import java.math.BigDecimal;
import java.util.Date;

/**
 * CPQ 汇率 Domain
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_currency_rate")
public class CpqCurrencyRate extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "rate_id")
    private Long rateId;

    private String fromCurrency;

    private String toCurrency;

    private BigDecimal exchangeRate;

    private Date effectiveDate;

    private String status;

    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
