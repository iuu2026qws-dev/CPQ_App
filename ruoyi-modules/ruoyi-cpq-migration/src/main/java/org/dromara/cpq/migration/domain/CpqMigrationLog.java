package org.dromara.cpq.migration.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import java.time.LocalDateTime;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_migration_log")
public class CpqMigrationLog extends TenantEntity {
    @TableId
    private Long logId;
    private Long taskId;
    private Integer rowIndex;
    private String logLevel;
    private String message;
    private String rawDataJson;
    private LocalDateTime logTime;
    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
