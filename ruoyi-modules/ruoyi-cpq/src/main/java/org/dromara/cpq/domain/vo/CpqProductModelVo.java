package org.dromara.cpq.domain.vo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import org.dromara.cpq.domain.CpqProductModel;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

/**
 * CPQ 可销售产品 VO（对齐设计文档 cpq_product_model）
 *
 * @author CPQ Team
 */
@Data
@AutoMapper(target = CpqProductModel.class, reverseConvertGenerate = true)
public class CpqProductModelVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    private Long modelId;
    private Long catalogId;
    private Long categoryId;
    /** 分类路径（L1 > L2 > L3 拼接展示用） */
    private String categoryPath;
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
    private String tenantId;

    /** 所属目录名称（关联查询） */
    private String catalogName;
    private Date createTime;
    private Date updateTime;
    private String remark;
}
