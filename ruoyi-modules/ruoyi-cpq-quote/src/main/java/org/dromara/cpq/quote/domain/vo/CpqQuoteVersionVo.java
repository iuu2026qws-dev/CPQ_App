package org.dromara.cpq.quote.domain.vo;

import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serial;
import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
public class CpqQuoteVersionVo implements Serializable {
    @Serial private static final long serialVersionUID = 1L;
    private Long versionId;
    private Long quoteId;
    private Integer versionNumber;
    private String versionJson;
    private String versionNote;
    private Long createdBy;
    private LocalDateTime createdTime;
}
