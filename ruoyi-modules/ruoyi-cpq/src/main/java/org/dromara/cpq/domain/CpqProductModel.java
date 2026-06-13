package org.dromara.cpq.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import org.dromara.common.tenant.core.TenantEntity;

import java.io.Serial;
import java.math.BigDecimal;

/**
 * CPQ 可销售产品模型（对齐设计文档 cpq_product_model）
 * D01 产品数据域 — 核心实体
 *
 * @author CPQ Team
 */
@Data
@NoArgsConstructor
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_product_model")
public class CpqProductModel extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /** 产品ID */
    @TableId(value = "model_id")
    private Long modelId;

    /** 所属目录ID */
    private Long catalogId;

    /** 产品分类ID（FK→cpq_product_category，指向L3产品系列） */
    private Long categoryId;

    /** 产品编码/型号(L4) */
    private String modelCode;

    /** 产品名称 */
    private String modelName;

    /** 产品描述 */
    private String description;

    /** 生命周期: CONCEPT/DESIGN/PRE_RELEASE/ACTIVE/EOL_ANNOUNCED/LAST_TIME_BUY/DISCONTINUED/ARCHIVED */
    private String lifecycleStatus;

    /** 替代产品ID(自引用) */
    private Long successorModelId;

    /** 基础目录价 */
    private BigDecimal basePrice;

    /** 币种 */
    private String currency;

    /** 最小起订量 */
    private Integer minOrderQty;

    /** 标准交期(天) */
    private Integer leadTimeDays;

    /** 配置类型: STANDARD/ATO/CTO/ETO/BUNDLE（BUNDLE=捆绑包产品） */
    private String configType;

    /** 默认SBOM Header ID */
    private Long defaultBomId;

    /** 产品缩略图(OSS路径) */
    private String thumbnailUrl;

    /** 状态(0=正常 1=停用) */
    private String status;

    /** 删除标志 */
    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
