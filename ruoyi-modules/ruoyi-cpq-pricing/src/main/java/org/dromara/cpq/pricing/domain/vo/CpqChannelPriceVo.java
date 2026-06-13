package org.dromara.cpq.pricing.domain.vo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import org.dromara.cpq.pricing.domain.CpqChannelPrice;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

@Data
@AutoMapper(target = CpqChannelPrice.class, reverseConvertGenerate = true)
public class CpqChannelPriceVo implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;
    private Long channelPriceId;
    private String channelCode;
    private Long modelId;
    private Long variantId;
    private String variantCode;
    private String variantName;
    private BigDecimal channelListPrice;
    private BigDecimal channelDiscountPct;
    private Date effectiveDate;
    private Date expiryDate;
    private String status;
    private String tenantId;
    private Date createTime;
    private Date updateTime;
    private String remark;
}
