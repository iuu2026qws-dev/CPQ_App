package org.dromara.cpq.competitive.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_comparison")
public class CpqComparison extends TenantEntity {
    @TableId
    private Long comparisonId;
    private Long ourProductId;
    private Long competitorProductId;
    private String radarDataJson;
    private BigDecimal winRate;
    private BigDecimal priceDiffPct;
    private String comparisonNotes;
    private Long comparedBy;
    private LocalDateTime comparedTime;
    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
