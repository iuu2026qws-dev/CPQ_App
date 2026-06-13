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
 * CPQ 价格手册条目 Domain
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_price_book_entry")
public class CpqPriceBookEntry extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "entry_id")
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

    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
