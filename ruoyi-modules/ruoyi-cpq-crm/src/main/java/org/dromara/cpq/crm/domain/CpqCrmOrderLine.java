package org.dromara.cpq.crm.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

import java.math.BigDecimal;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_crm_order_line")
public class CpqCrmOrderLine extends TenantEntity {
    @TableId
    private Long lineId;
    private Long orderId;
    private Integer lineNumber;
    private String sourceType;
    private Long sourceId;
    private String productCode;
    private String productName;
    private Long modelId;
    private BigDecimal quantity;
    private String unit;
    private BigDecimal unitPrice;
    private BigDecimal lineAmount;
    private BigDecimal discountPct;
    private BigDecimal taxRate;
    private String deliverySchedule;
}
