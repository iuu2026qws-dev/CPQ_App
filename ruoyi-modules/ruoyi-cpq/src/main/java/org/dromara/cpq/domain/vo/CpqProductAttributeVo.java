package org.dromara.cpq.domain.vo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import org.dromara.cpq.domain.CpqProductAttribute;

import java.io.Serial;
import java.io.Serializable;
import java.util.Date;

/**
 * CPQ 产品属性 VO
 *
 * @author CPQ Team
 */
@Data
@AutoMapper(target = CpqProductAttribute.class, reverseConvertGenerate = true)
public class CpqProductAttributeVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    private Long attributeId;
    private Long modelId;
    private String attrCategory;
    private String attrName;
    private String attrValue;
    private String isConfigurable;
    private String isRequired;
    private Integer displayOrder;
    private String dataType;
    private String optionValues;
    private Integer sortOrder;
    private String tenantId;
    private Date createTime;
    private Date updateTime;
    private String remark;
}
