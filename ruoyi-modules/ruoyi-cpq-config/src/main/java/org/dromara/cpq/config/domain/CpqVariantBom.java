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
 * CPQ 变体BOM Domain
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_variant_bom")
public class CpqVariantBom extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "variant_id")
    private Long variantId;

    private Long modelId;
    private Long sbomLineId;
    private String materialCode;
    private BigDecimal quantity;
    private String effectivityCondition;
    private String isDefault;
    private Integer sortOrder;


    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
