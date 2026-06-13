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
@TableName("cpq_quote_template")
public class CpqQuoteTemplate extends TenantEntity {
    @Serial private static final long serialVersionUID = 1L;

    @TableId(value = "template_id")
    private Long templateId;
    private String templateName;
    private String templateType;
    private String templateContent;
    private String templateJson;
    private String isDefault;
    private String status;

    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
