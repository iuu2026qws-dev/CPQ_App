package org.dromara.cpq.crm.domain.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;

@Data
@NoArgsConstructor
public class CpqCrmActivityVo {
    private Long activityId;
    private Long opportunityId;
    private Long accountId;
    private String activityType;
    private String subject;
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date activityDate;
    private String activityTime;
    private Integer durationMinutes;
    private String participants;
    private String result;
    private String nextPlan;
    private Long ownerId;
}
