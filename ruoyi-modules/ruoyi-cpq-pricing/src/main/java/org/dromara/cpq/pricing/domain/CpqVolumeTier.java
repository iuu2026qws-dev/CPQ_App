package org.dromara.cpq.pricing.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

import java.io.Serial;
import java.math.BigDecimal;

/**
 * CPQ 阶梯定价 Domain
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_volume_tier")
public class CpqVolumeTier extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "tier_id")
    private Long tierId;

    private Long priceBookEntryId;

    private BigDecimal minQuantity;

    private BigDecimal maxQuantity;

    private BigDecimal unitPrice;

    private Integer sortOrder;

    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
