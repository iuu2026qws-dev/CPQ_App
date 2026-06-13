package org.dromara.cpq.domain.bo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;
import org.dromara.cpq.domain.CpqProductCategory;

import java.io.Serial;

/**
 * CPQ 产品分类 BO
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = CpqProductCategory.class, reverseConvertGenerate = false)
public class CpqProductCategoryBo extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    private Long categoryId;
    private Long parentCategoryId;
    private Integer categoryLevel;
    private String categoryCode;
    private String categoryName;
    private Integer sortOrder;
    private String status;
}
