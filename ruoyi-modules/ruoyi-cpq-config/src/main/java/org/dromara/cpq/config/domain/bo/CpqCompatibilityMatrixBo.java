package org.dromara.cpq.config.domain.bo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;
import org.dromara.cpq.config.domain.CpqCompatibilityMatrix;

import java.io.Serial;

@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = CpqCompatibilityMatrix.class, reverseConvertGenerate = false)
public class CpqCompatibilityMatrixBo extends TenantEntity {
    @Serial
    private static final long serialVersionUID = 1L;
    private Long matrixId;
    private Long sourceProductId;
    private Long targetProductId;
    private String compatibilityType;
    private String conditionDesc;
}
