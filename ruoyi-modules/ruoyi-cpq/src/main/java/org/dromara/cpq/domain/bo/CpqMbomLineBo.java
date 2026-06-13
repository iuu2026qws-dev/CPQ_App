package org.dromara.cpq.domain.bo;

import lombok.Data;
import lombok.EqualsAndHashCode;
import io.github.linpeilie.annotations.AutoMapper;
import org.dromara.common.tenant.core.TenantEntity;
import org.dromara.cpq.domain.CpqMbomLine;

import java.io.Serial;
import java.math.BigDecimal;

/**
 * CPQ MBOM 行 BO
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = CpqMbomLine.class, reverseConvertGenerate = false)
public class CpqMbomLineBo extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    private Long mbomLineId;
    private Long sbomLineId;
    private Long modelId;
    private Long parentMbomLineId;
    private Integer lineNumber;
    private String materialCode;
    private String materialDesc;
    private String materialType;
    private BigDecimal quantity;
    private String unit;
    private String plant;
    private String storageLocation;
    private String requirementType;
    private String substituteGroup;
    private Integer substitutePriority;
    private String costComponent;
    private Integer leadTimeDays;
    private BigDecimal moq;
    private Integer sortOrder;
}
