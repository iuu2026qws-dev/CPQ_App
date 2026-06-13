package org.dromara.cpq.config.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

import java.io.Serial;
import java.math.BigDecimal;
import java.math.BigDecimal;

/**
 * CPQ 捆绑选项 Domain
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_bundle_option")
public class CpqBundleOption extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "option_id")
    private Long optionId;

    private Long optionGroupId;
    private Long componentModelId;
    private BigDecimal quantity;
    private String unit;
    private String isDefault;
    private String priceModifierType;
    private BigDecimal priceModifierValue;
    private Integer sortOrder;

    private String status;

    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
