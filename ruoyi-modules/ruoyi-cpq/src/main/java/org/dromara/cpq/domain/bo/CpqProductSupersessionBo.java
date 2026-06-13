package org.dromara.cpq.domain.bo;

import lombok.Data;
import lombok.EqualsAndHashCode;
import io.github.linpeilie.annotations.AutoMapper;
import org.dromara.common.tenant.core.TenantEntity;
import org.dromara.cpq.domain.CpqProductSupersession;

import java.io.Serial;
import java.math.BigDecimal;
import java.util.Date;

/**
 * CPQ 产品替代关系 BO（对齐设计文档 cpq_product_supersession）
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = CpqProductSupersession.class, reverseConvertGenerate = false)
public class CpqProductSupersessionBo extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    private Long supersessionId;
    private Long originalModelId;
    private Long replacementModelId;
    private String supersessionType;
    private String conditionExpr;
    private BigDecimal priceImpactPct;
    private Date effectiveDate;
    private String status;
}
