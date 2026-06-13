package org.dromara.cpq.domain.vo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import org.dromara.cpq.domain.CpqSystemConfig;

import java.io.Serial;
import java.io.Serializable;
import java.util.Date;

/**
 * CPQ 系统参数 VO
 *
 * @author CPQ Team
 */
@Data
@AutoMapper(target = CpqSystemConfig.class, reverseConvertGenerate = true)
public class CpqSystemConfigVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    private Long configId;
    private String configKey;
    private String configValue;
    private String configType;
    private String tenantId;
    private Date createTime;
    private Date updateTime;
    private String remark;
}
