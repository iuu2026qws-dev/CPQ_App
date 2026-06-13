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
 * CPQ 价格手册 Domain
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_price_book")
public class CpqPriceBook extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "price_book_id")
    private Long priceBookId;

    private String bookName;

    private String bookType;

    private String currency;

    private Date effectiveDate;

    private Date expiryDate;

    private Integer priority;

    private String status;

    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
