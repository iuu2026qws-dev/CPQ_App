package org.dromara.cpq.pricing.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

import java.io.Serial;
import java.math.BigDecimal;
import java.util.Date;

/**
 * CPQ 定价规则 Domain（rule_type + condition_json + action_json）
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_price_rule")
public class CpqPriceRule extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "price_rule_id")
    private Long priceRuleId;

    private String ruleName;

    private String ruleType;

    private Integer priority;

    private String conditionJson;

    private String actionJson;

    private BigDecimal approvalThreshold;

    private Date effectiveDate;

    private Date expiryDate;

    private String status;

    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
