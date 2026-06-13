package org.dromara.cpq.competitive.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import java.math.BigDecimal;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_competitor")
public class CpqCompetitor extends TenantEntity {
    @TableId
    private Long competitorId;
    private String competitorName;
    private String competitorCode;
    private String industry;
    private String website;
    private String description;
    private BigDecimal marketShare;
    private String status;
    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
