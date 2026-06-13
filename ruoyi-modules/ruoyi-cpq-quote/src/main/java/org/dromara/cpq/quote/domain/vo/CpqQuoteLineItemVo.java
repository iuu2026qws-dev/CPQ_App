package org.dromara.cpq.quote.domain.vo;

import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
public class CpqQuoteLineItemVo implements Serializable {
    @Serial private static final long serialVersionUID = 1L;
    private Long lineId;
    private Long quoteId;
    private Long parentLineId;
    private Integer lineNumber;
    private Long modelId;
    private Long sbomLineId;
    private String itemType;
    private String itemCode;
    private String itemName;
    private BigDecimal quantity;
    private String unit;
    private BigDecimal listPrice;
    private BigDecimal unitPrice;
    private BigDecimal discountPct;
    private BigDecimal discountAmount;
    private BigDecimal netPrice;
    private BigDecimal lineTotal;
    private String configurationJson;
    private String customRequirements;
    private Integer deliveryDays;
    private String atpStatus;
    private Integer sortOrder;
    private String delFlag;
}
