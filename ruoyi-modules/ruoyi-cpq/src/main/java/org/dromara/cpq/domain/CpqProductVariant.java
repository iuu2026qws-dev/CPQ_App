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
 * CPQ 产品变体（型号+属性组合→确定的可售卖SKU）
 *
 * @author CPQ Team
 */
@Data
@NoArgsConstructor
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_product_variant")
public class CpqProductVariant extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /** 变体ID */
    @TableId(value = "variant_id")
    private Long variantId;

    /** 所属产品型号ID（FK→cpq_product_model） */
    private Long modelId;

    /** 变体编码（如 RW-SWEEP-S1P-WHT） */
    private String variantCode;

    /** 变体名称（如 SweepBot S1 Pro 白色款） */
    private String variantName;

    /** 属性值集合 JSON：{"颜色":"白色", "通信方式":"5G"} */
    private String attributes;

    /** 此变体对应的确定 SBOM Header ID */
    private Long defaultBomId;

    /** 变体基础价（可继承 model.base_price 或覆盖） */
    private BigDecimal basePrice;

    /** 变体缩略图 */
    private String thumbnailUrl;

    /** 是否默认变体（0=否 1=是） */
    private String isDefault;

    /** 状态（0=正常 1=停用） */
    private String status;

    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
