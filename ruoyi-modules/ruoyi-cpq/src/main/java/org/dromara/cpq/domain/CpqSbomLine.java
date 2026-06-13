package org.dromara.cpq.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

import java.io.Serial;
import java.math.BigDecimal;

/**
 * CPQ SBOM 行项目（对齐设计文档 cpq_sbom_line）
 * D01 产品数据域
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_sbom_line")
public class CpqSbomLine extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "sbom_line_id")
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

    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
