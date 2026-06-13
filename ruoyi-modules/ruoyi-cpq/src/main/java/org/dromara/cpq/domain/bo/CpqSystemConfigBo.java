package org.dromara.cpq.domain.bo;

import lombok.Data;
import lombok.EqualsAndHashCode;
import io.github.linpeilie.annotations.AutoMapper;
import org.dromara.common.tenant.core.TenantEntity;
import org.dromara.cpq.domain.CpqSystemConfig;

import java.io.Serial;

/**
 * CPQ 系统参数 BO
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = CpqSystemConfig.class, reverseConvertGenerate = false)
public class CpqSystemConfigBo extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    private Long configId;
    private String configKey;
    private String configValue;
    private String configType;
    private String tenantId;
}
