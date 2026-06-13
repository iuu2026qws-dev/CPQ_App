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
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_quote")
public class CpqQuote extends TenantEntity {
    @Serial private static final long serialVersionUID = 1L;

    @TableId(value = "quote_id")
    private Long quoteId;
    private String quoteNumber;
    private String opportunityId;
    private Long accountId;
    private String accountName;
    private String quoteType;
    private String currency;
    private BigDecimal subtotal;
    private BigDecimal discountTotal;
    private BigDecimal taxTotal;
    private BigDecimal grandTotal;
    private String status;
    private LocalDate validUntil;
    private Long approvalChainId;
    private Long createdBy;
    private String createdByName;
    private LocalDateTime submittedDate;
    private LocalDateTime wonDate;

    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
