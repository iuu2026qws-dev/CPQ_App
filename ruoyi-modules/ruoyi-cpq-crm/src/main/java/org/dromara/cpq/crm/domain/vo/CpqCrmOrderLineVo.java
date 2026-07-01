package org.dromara.cpq.crm.domain.vo;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
public class CpqCrmOrderLineVo {
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
