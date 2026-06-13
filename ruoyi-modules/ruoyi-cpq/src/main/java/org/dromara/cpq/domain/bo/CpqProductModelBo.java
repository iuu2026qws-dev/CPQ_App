package org.dromara.cpq.domain.bo;

import lombok.Data;
import lombok.EqualsAndHashCode;
import io.github.linpeilie.annotations.AutoMapper;
import org.dromara.common.tenant.core.TenantEntity;
import org.dromara.cpq.domain.CpqProductModel;

import java.io.Serial;
import java.math.BigDecimal;

/**
 * CPQ 可销售产品 BO（对齐设计文档 cpq_product_model）
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = CpqProductModel.class, reverseConvertGenerate = false)
public class CpqProductModelBo extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    private Long modelId;
    private Long catalogId;
    private Long categoryId;
    private String modelCode;
    private String modelName;
    private String description;
    private String lifecycleStatus;
    private Long successorModelId;
    private BigDecimal basePrice;
    private String currency;
    private Integer minOrderQty;
    private Integer leadTimeDays;
    /** 配置类型: STANDARD/ATO/CTO/ETO/BUNDLE */
    private String configType;
    private Long defaultBomId;
    private String thumbnailUrl;
    private String status;
}
