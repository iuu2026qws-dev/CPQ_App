package org.dromara.cpq.customer.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_channel")
public class CpqChannel extends TenantEntity {
    @TableId private Long channelId;
    private String channelName;
    private String channelCode;
    private String channelType;
    private Long partnerId;
    private String region;
    private String status;
    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
