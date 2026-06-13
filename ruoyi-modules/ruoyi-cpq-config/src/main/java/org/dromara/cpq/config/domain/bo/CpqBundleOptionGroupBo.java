package org.dromara.cpq.config.domain.bo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;
import org.dromara.cpq.config.domain.CpqBundleOptionGroup;

import java.io.Serial;

@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = CpqBundleOptionGroup.class, reverseConvertGenerate = false)
public class CpqBundleOptionGroupBo extends TenantEntity {
    @Serial
    private static final long serialVersionUID = 1L;
    private Long optionGroupId;
    private Long bundleId;
    private String groupName;
    private String groupCode;
    private Integer minSelections;
    private Integer maxSelections;
    private String isRequired;
    private Integer sortOrder;
    private String status;
}
