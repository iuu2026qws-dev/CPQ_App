package org.dromara.cpq.config.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

import java.io.Serial;
import java.math.BigDecimal;

/**
 * CPQ 捆绑包 Domain
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_bundle")
public class CpqBundle extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "bundle_id")
    private Long bundleId;

    private Long modelId;
    private String bundleType;
    private String pricingStrategy;
    private BigDecimal bundleDiscountPct;
    private String isActive;
    private String description;

    private String status;

    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
