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
 * CPQ 渠道价格 Domain
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_channel_price")
public class CpqChannelPrice extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "channel_price_id")
    private Long channelPriceId;

    private String channelCode;

    private Long modelId;

    private Long variantId;

    private BigDecimal channelListPrice;

    private BigDecimal channelDiscountPct;

    private Date effectiveDate;

    private Date expiryDate;

    private String status;

    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
