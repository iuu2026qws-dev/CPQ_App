package org.dromara.cpq.quote.domain.bo;

import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
public class CpqQuoteBo implements Serializable {
    @Serial private static final long serialVersionUID = 1L;
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
    private String remark;
}
