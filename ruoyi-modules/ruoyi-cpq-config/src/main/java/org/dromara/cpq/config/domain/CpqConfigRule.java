package org.dromara.cpq.config.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

import java.io.Serial;
import java.util.Date;
import java.util.Date;

/**
 * CPQ 配置规则 Domain
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_config_rule")
public class CpqConfigRule extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "rule_id")
    private Long ruleId;

    private String ruleName;
    private String ruleType;
    private Long modelId;
    private String conditionExpr;
    private String actionExpr;
    private String errorMessage;
    private String severity;
    private Integer priority;
    private Date effectiveDate;
    private Date expiryDate;

    private String status;

    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
