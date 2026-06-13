package org.dromara.cpq.config.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

import java.io.Serial;

/**
 * CPQ 捆绑选项组 Domain
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_bundle_option_group")
public class CpqBundleOptionGroup extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "option_group_id")
    private Long optionGroupId;

    private Long bundleId;
    private String groupName;
    private String groupCode;
    private Integer minSelections;
    private Integer maxSelections;
    private String isRequired;
    private Integer sortOrder;

    private String status;

    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
