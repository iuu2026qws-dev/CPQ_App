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
@TableName("cpq_migration_task")
public class CpqMigrationTask extends TenantEntity {
    @TableId
    private Long taskId;
    private String taskName;
    private String sourceSystem;
    private String targetModule;
    private String taskStatus;
    private Integer totalRecords;
    private Integer processedRecords;
    private Integer failedRecords;
    private String filePath;
    private LocalDateTime startedAt;
    private LocalDateTime completedAt;
    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
