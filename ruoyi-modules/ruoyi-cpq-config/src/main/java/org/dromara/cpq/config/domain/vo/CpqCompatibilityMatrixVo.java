package org.dromara.cpq.config.domain.vo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import org.dromara.cpq.config.domain.CpqCompatibilityMatrix;

import java.io.Serial;
import java.io.Serializable;

@Data
@AutoMapper(target = CpqCompatibilityMatrix.class, reverseConvertGenerate = true)
public class CpqCompatibilityMatrixVo implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;
    private Long matrixId;
    private Long sourceProductId;
    private Long targetProductId;
    private String compatibilityType;
    private String conditionDesc;
    private String tenantId;
    private java.util.Date createTime;
    private java.util.Date updateTime;
    private String remark;
}
