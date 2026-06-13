package org.dromara.cpq.customer.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_account")
public class CpqAccount extends TenantEntity {
    @TableId
    private Long accountId;
    private String accountName;
    private String accountCode;
    private String accountType;
    private String industry;
    private String region;
    private String contactName;
    private String contactPhone;
    private String contactEmail;
    private String address;
    private String taxId;
    private String status;
    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
