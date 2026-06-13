package org.dromara.cpq.integration.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

import java.time.LocalDateTime;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_sync_log")
public class CpqSyncLog extends TenantEntity {
    @TableId
    private Long logId;
    private Long configId;
    private String syncDirection;
    private String syncStatus;
    private Integer recordsTotal;
    private Integer recordsSuccess;
    private Integer recordsFailed;
    private String errorDetail;
    private LocalDateTime syncTime;
    private Integer durationMs;
    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
