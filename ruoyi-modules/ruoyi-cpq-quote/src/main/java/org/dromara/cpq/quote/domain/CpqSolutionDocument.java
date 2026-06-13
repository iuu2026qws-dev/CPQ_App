package org.dromara.cpq.quote.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import org.dromara.common.tenant.core.TenantEntity;

import java.io.Serial;

@Data
@NoArgsConstructor
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_solution_document")
public class CpqSolutionDocument extends TenantEntity {
    @Serial private static final long serialVersionUID = 1L;

    @TableId(value = "document_id")
    private Long documentId;
    private Long quoteId;
    private String documentType;
    private String documentName;
    private String documentContent;
    private String documentJson;
    private Integer version;
    private String status;

    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
