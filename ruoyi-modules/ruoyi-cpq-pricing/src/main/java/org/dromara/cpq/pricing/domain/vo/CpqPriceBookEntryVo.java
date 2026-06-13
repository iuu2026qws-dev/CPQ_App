package org.dromara.cpq.pricing.domain.vo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import org.dromara.cpq.pricing.domain.CpqPriceBookEntry;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

@Data
@AutoMapper(target = CpqPriceBookEntry.class, reverseConvertGenerate = true)
public class CpqPriceBookEntryVo implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;
    private Long entryId;
    private Long priceBookId;
    private Long modelId;
    private Long variantId;
    private String variantCode;
    private String variantName;
    private String itemCode;
    private String regionCode;
    private String channelCode;
    private BigDecimal listPrice;
    private BigDecimal costPrice;
    private BigDecimal minPrice;
    private Date effectiveDate;
    private Date expiryDate;
    private String status;
    private String tenantId;
    private String bookName;
    private Date createTime;
    private Date updateTime;
    private String remark;
}
