package org.dromara.cpq.approval.domain.vo;

import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serial;
import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
public class CpqApprovalRecordVo implements Serializable {
    @Serial private static final long serialVersionUID = 1L;
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
