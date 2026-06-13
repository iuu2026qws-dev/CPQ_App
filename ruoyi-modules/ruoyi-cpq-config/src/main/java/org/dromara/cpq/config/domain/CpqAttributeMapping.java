package org.dromara.cpq.config.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

import java.io.Serial;

/**
 * CPQ 属性映射 Domain
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_attribute_mapping")
public class CpqAttributeMapping extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "mapping_id")
    private Long mappingId;

    private Long modelId;
    private String attrName;
    private String attrValue;
    private String materialCode;
    private Long sbomLineId;
    private String conditionExpr;
    private Integer sortOrder;


    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
