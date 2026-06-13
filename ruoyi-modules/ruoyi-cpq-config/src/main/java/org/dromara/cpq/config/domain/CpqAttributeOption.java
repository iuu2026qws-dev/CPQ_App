package org.dromara.cpq.config.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

import java.io.Serial;

/**
 * CPQ 属性选项 Domain
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_attribute_option")
public class CpqAttributeOption extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "option_id")
    private Long optionId;

    private Long modelId;
    private String attrName;
    private String optionCode;
    private String optionLabel;
    private String optionValue;
    private String isDefault;
    private Integer sortOrder;


    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
