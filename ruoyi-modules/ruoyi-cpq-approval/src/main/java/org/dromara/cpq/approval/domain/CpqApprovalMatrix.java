package org.dromara.cpq.approval.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import org.dromara.common.tenant.core.TenantEntity;

import java.io.Serial;

@Data
@NoArgsConstructor
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_approval_matrix")
public class CpqApprovalMatrix extends TenantEntity {
    @Serial private static final long serialVersionUID = 1L;

    @TableId(value = "matrix_id")
    private Long matrixId;
    private String dimensionType;
    private String dimensionValue;
    private String flowCode;
    private String approverRole;
    private String approverIds;
    private Integer minApprovals;
    private String status;

    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
