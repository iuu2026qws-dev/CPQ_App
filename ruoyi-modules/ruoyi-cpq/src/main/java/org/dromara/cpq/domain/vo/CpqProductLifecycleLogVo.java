package org.dromara.cpq.domain.vo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import org.dromara.cpq.domain.CpqProductLifecycleLog;

import java.io.Serial;
import java.io.Serializable;
import java.util.Date;

/**
 * CPQ 产品生命周期变更日志 VO
 *
 * @author CPQ Team
 */
@Data
@AutoMapper(target = CpqProductLifecycleLog.class, reverseConvertGenerate = true)
public class CpqProductLifecycleLogVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    private Long logId;
    private Long modelId;
    private String fromStatus;
    private String toStatus;
    private String changeReason;
    private Long changeBy;
    private Date changeTime;
    private String tenantId;
}
