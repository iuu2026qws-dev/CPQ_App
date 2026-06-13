package org.dromara.cpq.config.domain.bo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;
import org.dromara.cpq.config.domain.CpqBundle;

import java.io.Serial;
import java.math.BigDecimal;

@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = CpqBundle.class, reverseConvertGenerate = false)
public class CpqBundleBo extends TenantEntity {
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
}
