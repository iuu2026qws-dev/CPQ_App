package org.dromara.cpq.config.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

import java.io.Serial;

/**
 * CPQ 兼容性矩阵 Domain
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_compatibility_matrix")
public class CpqCompatibilityMatrix extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "matrix_id")
    private Long matrixId;

    private Long sourceProductId;
    private Long targetProductId;
    private String compatibilityType;
    private String conditionDesc;


    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
