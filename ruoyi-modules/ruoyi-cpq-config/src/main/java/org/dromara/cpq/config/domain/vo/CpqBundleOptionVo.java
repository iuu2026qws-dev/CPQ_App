package org.dromara.cpq.config.domain.vo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import org.dromara.cpq.config.domain.CpqBundleOption;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;
import java.math.BigDecimal;

@Data
@AutoMapper(target = CpqBundleOption.class, reverseConvertGenerate = true)
public class CpqBundleOptionVo implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;
    private Long optionId;
    private Long optionGroupId;
    private Long componentModelId;
    private BigDecimal quantity;
    private String unit;
    private String isDefault;
    private String priceModifierType;
    private BigDecimal priceModifierValue;
    private Integer sortOrder;
    private String status;
    private String tenantId;
    private java.util.Date createTime;
    private java.util.Date updateTime;
    private String remark;
}
