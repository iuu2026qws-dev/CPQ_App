package org.dromara.cpq.config.domain.vo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import org.dromara.cpq.config.domain.CpqVariantBom;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;

@Data
@AutoMapper(target = CpqVariantBom.class, reverseConvertGenerate = true)
public class CpqVariantBomVo implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;
    private Long variantId;
    private Long modelId;
    private Long sbomLineId;
    private String materialCode;
    private BigDecimal quantity;
    private String effectivityCondition;
    private String isDefault;
    private Integer sortOrder;
    private String tenantId;
    private java.util.Date createTime;
    private java.util.Date updateTime;
    private String remark;
}
