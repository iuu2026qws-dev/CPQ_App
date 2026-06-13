package org.dromara.cpq.competitive.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import java.math.BigDecimal;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_competitor_product")
public class CpqCompetitorProduct extends TenantEntity {
    @TableId
    private Long productId;
    private Long competitorId;
    private String productName;
    private String productCode;
    private String category;
    private BigDecimal basePrice;
    private String specsJson;
    private String strengths;
    private String weaknesses;
    private String status;
    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
