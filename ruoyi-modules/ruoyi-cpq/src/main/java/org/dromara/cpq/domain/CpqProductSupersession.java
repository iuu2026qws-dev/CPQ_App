package org.dromara.cpq.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

import java.io.Serial;
import java.math.BigDecimal;
import java.util.Date;

/**
 * CPQ 产品替代关系（对齐设计文档 cpq_product_supersession）
 * D01 产品数据域
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_product_supersession")
public class CpqProductSupersession extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "supersession_id")
    private Long supersessionId;

    private Long originalModelId;
    private Long replacementModelId;
    private String supersessionType;
    private String conditionExpr;
    private BigDecimal priceImpactPct;
    private Date effectiveDate;
    private String status;

    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
