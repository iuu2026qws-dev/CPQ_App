package org.dromara.cpq.crm.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

import java.math.BigDecimal;
import java.util.Date;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_crm_order")
public class CpqCrmOrder extends TenantEntity {
    @TableId
    private Long orderId;
    private String orderNumber;
    private String orderName;
    private Long contractId;
    private Long accountId;
    private Long quoteId;
    private String orderType;
    private String status;
    private Date orderDate;
    private BigDecimal totalAmount;
    private String currency;
    private Date deliveryDate;
    private String shippingAddress;
    private String billingAddress;
    private Long ownerId;
    private String description;
}
