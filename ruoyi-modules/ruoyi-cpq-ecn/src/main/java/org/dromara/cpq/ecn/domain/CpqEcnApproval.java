package org.dromara.cpq.ecn.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data; import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;
import java.util.Date;

@Data @EqualsAndHashCode(callSuper = true) @TableName("cpq_ecn_approval")
public class CpqEcnApproval extends TenantEntity {
    @TableId private Long ecnApprovalId;
    private Long changeOrderId;
    private Long approvalChainId;
    private Long approverId;
    private String approverName;
    private Integer stepNumber;
    private String action;
    private String comment;
    private Date actionTime;
    @TableLogic(value = "0", delval = "2") private String delFlag;
}
