package org.dromara.cpq.approval.domain.bo;

import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serial;
import java.io.Serializable;

@Data
@NoArgsConstructor
public class CpqApprovalMatrixBo implements Serializable {
    @Serial private static final long serialVersionUID = 1L;
    private Long matrixId;
    private String dimensionType;
    private String dimensionValue;
    private String flowCode;
    private String approverRole;
    private String approverIds;
    private Integer minApprovals;
    private String status;
    private String remark;
}
