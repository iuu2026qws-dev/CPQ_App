package org.dromara.cpq.crm.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

import java.util.Date;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_crm_activity")
public class CpqCrmActivity extends TenantEntity {
    @TableId
    private Long activityId;
    private Long opportunityId;
    private Long accountId;
    private String activityType;
    private String subject;
    private Date activityDate;
    private String activityTime;
    private Integer durationMinutes;
    private String participants;
    private String result;
    private String nextPlan;
    private Long ownerId;
}
