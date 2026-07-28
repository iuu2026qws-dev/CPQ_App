package org.dromara.cpq.approval.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import org.dromara.common.tenant.core.TenantEntity;

import java.io.Serial;

@Data
@NoArgsConstructor
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_approval_business_snapshot")
public class CpqApprovalBusinessSnapshot extends TenantEntity {
    @Serial private static final long serialVersionUID = 1L;

    @TableId(value = "snapshot_id")
    private Long snapshotId;
    private String scene;
    private Long businessId;
    private String businessSummary;
    private String businessData;
    private Long flowInstanceId;
    private String status;
}
