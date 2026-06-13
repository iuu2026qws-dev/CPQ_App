package org.dromara.cpq.approval.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import org.dromara.common.tenant.core.TenantEntity;

import java.io.Serial;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_approval_record")
public class CpqApprovalRecord extends TenantEntity {
    @Serial private static final long serialVersionUID = 1L;

    @TableId(value = "record_id")
    private Long recordId;
    private Long chainId;
    private Integer stepNumber;
    private Long approverId;
    private String approverName;
    private String action;
    private String comment;
    private LocalDateTime actionTime;
    private LocalDateTime slaDeadline;
}
