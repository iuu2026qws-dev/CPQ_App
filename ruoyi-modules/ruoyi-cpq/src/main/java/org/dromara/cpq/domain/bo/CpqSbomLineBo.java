package org.dromara.cpq.domain.bo;

import lombok.Data;
import lombok.EqualsAndHashCode;
import io.github.linpeilie.annotations.AutoMapper;
import org.dromara.common.tenant.core.TenantEntity;
import org.dromara.cpq.domain.CpqSbomLine;

import java.io.Serial;
import java.math.BigDecimal;

/**
 * CPQ SBOM 行 BO
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = CpqSbomLine.class, reverseConvertGenerate = false)
public class CpqSbomLineBo extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    private Long sbomLineId;
    private Long sbomHeaderId;
    private Long parentLineId;
    private Integer lineNumber;
    private String itemCode;
    private String itemName;
    private String itemType;
    private BigDecimal quantity;
    private String unit;
    private String isRequired;
    private String isReplaceable;
    private String replacementGroup;
    private String isPhantom;
    private BigDecimal minQty;
    private BigDecimal maxQty;
    private String priceImpact;
    private Integer leadTimeDays;
    private Integer sortOrder;
}
