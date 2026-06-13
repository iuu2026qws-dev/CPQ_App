package org.dromara.cpq.quote.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import org.dromara.common.tenant.core.TenantEntity;

import java.io.Serial;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_quote_line_item")
public class CpqQuoteLineItem extends TenantEntity {
    @Serial private static final long serialVersionUID = 1L;

    @TableId(value = "line_id")
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

    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
