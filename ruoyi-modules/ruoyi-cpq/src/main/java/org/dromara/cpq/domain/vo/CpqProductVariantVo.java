package org.dromara.cpq.domain.vo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import org.dromara.cpq.domain.CpqProductVariant;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

@Data
@AutoMapper(target = CpqProductVariant.class, reverseConvertGenerate = true)
public class CpqProductVariantVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    private Long variantId;
    private Long modelId;
    private String variantCode;
    private String variantName;
    private String attributes;
    private Long defaultBomId;
    private BigDecimal basePrice;
    private String thumbnailUrl;
    private String isDefault;
    private String status;
    private String tenantId;
    private Date createTime;
    private Date updateTime;
    private String remark;
}
