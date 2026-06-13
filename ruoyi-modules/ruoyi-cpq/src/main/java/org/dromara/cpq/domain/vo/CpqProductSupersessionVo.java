package org.dromara.cpq.domain.vo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import org.dromara.cpq.domain.CpqProductSupersession;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

/**
 * CPQ 产品替代关系 VO
 *
 * @author CPQ Team
 */
@Data
@AutoMapper(target = CpqProductSupersession.class, reverseConvertGenerate = true)
public class CpqProductSupersessionVo implements Serializable {

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
    private String tenantId;

    /** 关联的产品名称 */
    private String originalModelName;
    private String originalModelCode;
    private String replacementModelName;
    private String replacementModelCode;
    private Date createTime;
}
