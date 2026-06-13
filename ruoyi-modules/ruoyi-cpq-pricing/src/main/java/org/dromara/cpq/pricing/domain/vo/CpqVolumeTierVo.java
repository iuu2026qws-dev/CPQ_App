package org.dromara.cpq.pricing.domain.vo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import org.dromara.cpq.pricing.domain.CpqVolumeTier;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

@Data
@AutoMapper(target = CpqVolumeTier.class, reverseConvertGenerate = true)
public class CpqVolumeTierVo implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;
    private Long tierId;
    private Long priceBookEntryId;
    private BigDecimal minQuantity;
    private BigDecimal maxQuantity;
    private BigDecimal unitPrice;
    private Integer sortOrder;
    private String tenantId;
    private Date createTime;
    private Date updateTime;
    private String remark;
}
