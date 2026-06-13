package org.dromara.cpq.quote.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import org.dromara.common.tenant.core.TenantEntity;

import java.io.Serial;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_config_snapshot")
public class CpqConfigSnapshot extends TenantEntity {
    @Serial private static final long serialVersionUID = 1L;

    @TableId(value = "snapshot_id")
    private Long snapshotId;
    private Long quoteId;
    private Long modelId;
    private String snapshotHash;
    private String selectionsJson;
    private String bomJson;
    private String ruleVersion;
    private String priceVersion;
    private String productVersion;
    private LocalDateTime snapshotTime;
}
