package org.dromara.cpq.domain.vo;

import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.List;

/**
 * CPQ SBOM 行 VO
 *
 * @author CPQ Team
 */
@Data
public class CpqSbomLineVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    private Long sbomLineId;
    private Long sbomHeaderId;
    private Long parentLineId;
    /** BOM树层级深度 */
    private Integer level;
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

    /** 单价（关联定价引擎填充） */
    private BigDecimal unitPrice;
    /** 成本价（ABAC脱敏后填充） */
    private BigDecimal costPrice;

    /** 子行（用于树形展开） */
    private List<CpqSbomLineVo> children;
}
