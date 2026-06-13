package org.dromara.cpq.migration.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;

import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_migration_mapping")
public class CpqMigrationMapping extends TenantEntity {
    @TableId
    private Long mappingId;
    private Long taskId;
    private String sourceField;
    private String targetField;
    private String transformRule;
    private String defaultValue;
    private String isRequired;
    private Integer sortOrder;
    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
