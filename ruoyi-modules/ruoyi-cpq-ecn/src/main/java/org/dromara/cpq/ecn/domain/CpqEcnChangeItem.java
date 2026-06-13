package org.dromara.cpq.ecn.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data; import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

@Data @EqualsAndHashCode(callSuper = true) @TableName("cpq_ecn_change_item")
public class CpqEcnChangeItem extends TenantEntity {
    @TableId private Long itemId;
    private Long changeOrderId;
    private String entityType;
    private Long entityId;
    private String entityName;
    private String changeDescription;
    private String oldValue;
    private String newValue;
    private Integer sortOrder;
    @TableLogic(value = "0", delval = "2") private String delFlag;
}
