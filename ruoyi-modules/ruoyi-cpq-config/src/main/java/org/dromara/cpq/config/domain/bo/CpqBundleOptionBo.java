package org.dromara.cpq.config.domain.bo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;
import org.dromara.cpq.config.domain.CpqBundleOption;

import java.io.Serial;
import java.math.BigDecimal;
import java.math.BigDecimal;

@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = CpqBundleOption.class, reverseConvertGenerate = false)
public class CpqBundleOptionBo extends TenantEntity {
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
}
