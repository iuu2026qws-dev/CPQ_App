package org.dromara.cpq.quote.domain.bo;

import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serial;
import java.io.Serializable;

@Data
@NoArgsConstructor
public class CpqSolutionDocumentBo implements Serializable {
    @Serial private static final long serialVersionUID = 1L;
    private Long documentId;
    private Long quoteId;
    private String documentType;
    private String documentName;
    private String documentContent;
    private String documentJson;
    private Integer version;
    private String status;
    private String remark;
}
