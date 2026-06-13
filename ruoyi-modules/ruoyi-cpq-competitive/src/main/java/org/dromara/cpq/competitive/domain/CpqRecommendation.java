package org.dromara.cpq.competitive.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import java.time.LocalDate;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_recommendation")
public class CpqRecommendation extends TenantEntity {
    @TableId
    private Long recommendationId;
    private String scenario;
    private Long ourProductId;
    private Long competitorProductId;
    private String strategyType;
    private String strategyDesc;
    private Integer priority;
    private LocalDate effectiveFrom;
    private LocalDate effectiveTo;
    private String status;
    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
