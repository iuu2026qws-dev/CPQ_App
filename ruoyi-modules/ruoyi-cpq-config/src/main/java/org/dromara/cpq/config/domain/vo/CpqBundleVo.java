package org.dromara.cpq.config.domain.vo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import org.dromara.cpq.config.domain.CpqBundle;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;

@Data
@AutoMapper(target = CpqBundle.class, reverseConvertGenerate = true)
public class CpqBundleVo implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;
    private Long bundleId;
    private Long modelId;
    private String bundleType;
    private String pricingStrategy;
    private BigDecimal bundleDiscountPct;
    private String isActive;
    private String description;
    private String status;
    private String tenantId;
    private java.util.Date createTime;
    private java.util.Date updateTime;
    private String remark;
}
