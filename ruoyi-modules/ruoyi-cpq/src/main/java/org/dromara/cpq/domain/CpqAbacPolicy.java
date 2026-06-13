package org.dromara.cpq.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

import java.io.Serial;

/**
 * CPQ ABAC策略
 * 对应 cpq_abac_policy 表，实现基于属性的访问控制（Attribute-Based Access Control）
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_abac_policy")
public class CpqAbacPolicy extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "policy_id", type = IdType.ASSIGN_ID)
    private Long policyId;

    /** 策略名称 */
    private String policyName;

    /** 策略类型: COST_VISIBILITY/REGION_SCOPE/PRODUCT_LINE_SCOPE */
    private String policyType;

    /** 主体类型: ROLE/USER/DEPT */
    private String subjectType;

    /** 主体值(role_key/user_id/dept_id) */
    private String subjectValue;

    /** 属性键: cost_visibility_level/region_list/product_line_list */
    private String attributeKey;

    /** 属性值: 0-3/csv列表/csv列表 */
    private String attributeValue;

    /** 状态(0启用 1停用) */
    private String status;

    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
