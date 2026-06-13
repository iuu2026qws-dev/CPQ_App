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
@TableName("cpq_quote_version")
public class CpqQuoteVersion extends TenantEntity {
    @Serial private static final long serialVersionUID = 1L;

    @TableId(value = "version_id")
    private Long versionId;
    private Long quoteId;
    private Integer versionNumber;
    private String versionJson;
    private String versionNote;
    private Long createdBy;
    private LocalDateTime createdTime;
}
