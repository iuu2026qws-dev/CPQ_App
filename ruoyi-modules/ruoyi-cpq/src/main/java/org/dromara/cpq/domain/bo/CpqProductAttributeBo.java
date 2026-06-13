package org.dromara.cpq.domain.bo;

import lombok.Data;
import lombok.EqualsAndHashCode;
import io.github.linpeilie.annotations.AutoMapper;
import org.dromara.common.tenant.core.TenantEntity;
import org.dromara.cpq.domain.CpqProductAttribute;

import java.io.Serial;

/**
 * CPQ 产品属性 BO
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = CpqProductAttribute.class, reverseConvertGenerate = false)
public class CpqProductAttributeBo extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    private Long attributeId;
    /** 所属产品ID */
    private Long modelId;
    /** 属性分类(Feature Category) */
    private String attrCategory;
    /** 属性名称(Feature) */
    private String attrName;
    /** 属性默认值(Option) */
    private String attrValue;
    /** 是否可配置 */
    private String isConfigurable;
    /** 是否必选 */
    private String isRequired;
    /** 显示顺序 */
    private Integer displayOrder;
    /** 数据类型: STRING/NUMBER/BOOLEAN/ENUM */
    private String dataType;
    /** 可选项列表(JSON, data_type=ENUM时使用) */
    private String optionValues;
    private Integer sortOrder;
}
