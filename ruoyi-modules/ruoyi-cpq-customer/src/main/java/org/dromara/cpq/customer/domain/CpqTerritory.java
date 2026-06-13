package org.dromara.cpq.customer.domain;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_territory")
public class CpqTerritory extends TenantEntity {
    @TableId private Long territoryId;
    private String territoryName;
    private String territoryCode;
    @TableField("parent_territory_id")
    private Long parentId;
    @TableField("region")
    private String regionLevel;
    private String status;
    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
