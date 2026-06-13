package org.dromara.cpq.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

import java.io.Serial;

/**
 * CPQ 产品属性（对齐设计文档 cpq_product_attribute）
 * D01 产品数据域
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_product_attribute")
public class CpqProductAttribute extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "attribute_id")
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

    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
