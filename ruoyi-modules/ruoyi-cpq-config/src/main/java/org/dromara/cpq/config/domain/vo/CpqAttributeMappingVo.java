package org.dromara.cpq.config.domain.vo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import org.dromara.cpq.config.domain.CpqAttributeMapping;

import java.io.Serial;
import java.io.Serializable;

@Data
@AutoMapper(target = CpqAttributeMapping.class, reverseConvertGenerate = true)
public class CpqAttributeMappingVo implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;
    private Long mappingId;
    private Long modelId;
    private String attrName;
    private String attrValue;
    private String materialCode;
    private Long sbomLineId;
    private String conditionExpr;
    private Integer sortOrder;
    private String tenantId;
    private java.util.Date createTime;
    private java.util.Date updateTime;
    private String remark;
}
