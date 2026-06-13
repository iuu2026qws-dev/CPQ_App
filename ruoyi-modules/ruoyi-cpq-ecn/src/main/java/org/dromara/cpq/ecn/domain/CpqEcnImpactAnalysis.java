package org.dromara.cpq.ecn.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data; import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

@Data @EqualsAndHashCode(callSuper = true) @TableName("cpq_ecn_impact_analysis")
public class CpqEcnImpactAnalysis extends TenantEntity {
    @TableId private Long impactId;
    private Long changeOrderId;
    private Long changeItemId;
    private Integer propagationLevel;
    private String affectedEntityType;
    private Long affectedEntityId;
    private String affectedEntityName;
    private String impactDescription;
    private String severity;
    private String remediation;
    @TableLogic(value = "0", delval = "2") private String delFlag;
}
