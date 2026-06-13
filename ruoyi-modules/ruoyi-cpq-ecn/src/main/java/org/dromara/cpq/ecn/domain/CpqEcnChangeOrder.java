package org.dromara.cpq.ecn.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

@Data @EqualsAndHashCode(callSuper = true) @TableName("cpq_ecn_change_order")
public class CpqEcnChangeOrder extends TenantEntity {
    @TableId private Long changeOrderId;
    private String ecnNumber;
    private String title;
    private String reason;
    private String changeType;
    private String severity;
    private String affectedProducts;
    private String status;
    private Long originatorId;
    private String originatorName;
    @TableLogic(value = "0", delval = "2") private String delFlag;
}
