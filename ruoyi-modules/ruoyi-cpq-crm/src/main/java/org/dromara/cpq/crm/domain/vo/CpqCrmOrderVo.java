package org.dromara.cpq.crm.domain.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.Date;

@Data
@NoArgsConstructor
public class CpqCrmOrderVo {
    private Long orderId;
    private String orderNumber;
    private String orderName;
    private Long contractId;
    private String contractNumber;
    private Long accountId;
    private String accountName;
    private Long quoteId;
    private String orderType;
    private String status;
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date orderDate;
    private BigDecimal totalAmount;
    private String currency;
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date deliveryDate;
    private String shippingAddress;
    private String billingAddress;
    private Long ownerId;
    private String description;
}
