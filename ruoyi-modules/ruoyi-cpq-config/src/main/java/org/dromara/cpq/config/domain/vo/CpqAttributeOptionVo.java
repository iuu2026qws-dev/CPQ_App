package org.dromara.cpq.config.domain.vo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import org.dromara.cpq.config.domain.CpqAttributeOption;

import java.io.Serial;
import java.io.Serializable;

@Data
@AutoMapper(target = CpqAttributeOption.class, reverseConvertGenerate = true)
public class CpqAttributeOptionVo implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;
    private Long optionId;
    private Long modelId;
    private String attrName;
    private String optionCode;
    private String optionLabel;
    private String optionValue;
    private String isDefault;
    private Integer sortOrder;
    private String tenantId;
    private java.util.Date createTime;
    private java.util.Date updateTime;
    private String remark;
}
