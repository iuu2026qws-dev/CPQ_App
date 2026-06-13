package org.dromara.cpq.integration.domain;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_integration_config")
public class CpqIntegrationConfig extends TenantEntity {
    @TableId
    private Long configId;
    private String systemType;
    private String systemName;
    private String endpointUrl;
    private String authType;
    private String authConfigJson;
    private String syncDirection;
    private String syncFrequency;
    private Integer timeoutSeconds;
    private Integer retryTimes;
    private String status;
    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
