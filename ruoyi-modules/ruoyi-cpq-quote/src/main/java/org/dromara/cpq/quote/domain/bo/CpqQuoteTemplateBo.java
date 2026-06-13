package org.dromara.cpq.quote.domain.bo;

import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serial;
import java.io.Serializable;

@Data
@NoArgsConstructor
public class CpqQuoteTemplateBo implements Serializable {
    @Serial private static final long serialVersionUID = 1L;
    private Long templateId;
    private String templateName;
    private String templateType;
    private String templateContent;
    private String templateJson;
    private String isDefault;
    private String status;
    private String remark;
}
