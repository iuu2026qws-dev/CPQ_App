package org.dromara.cpq.domain.bo;

import lombok.Data;
import lombok.EqualsAndHashCode;
import io.github.linpeilie.annotations.AutoMapper;
import com.baomidou.mybatisplus.extension.activerecord.Model;
import org.dromara.cpq.domain.CpqProductLifecycleLog;

import java.io.Serial;
import java.util.Date;

/**
 * CPQ 产品生命周期变更日志 BO
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = CpqProductLifecycleLog.class, reverseConvertGenerate = false)
public class CpqProductLifecycleLogBo extends Model<CpqProductLifecycleLog> {

    @Serial
    private static final long serialVersionUID = 1L;

    private Long logId;
    private String tenantId;
    private Long modelId;
    private String fromStatus;
    private String toStatus;
    private String changeReason;
    private Long changeBy;
    private Date changeTime;
}
