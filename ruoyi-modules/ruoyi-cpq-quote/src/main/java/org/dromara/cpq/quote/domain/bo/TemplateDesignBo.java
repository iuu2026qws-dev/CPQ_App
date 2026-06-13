package org.dromara.cpq.quote.domain.bo;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.experimental.Accessors;

import java.io.Serial;
import java.io.Serializable;

/**
 * 模板设计保存 BO — 保存/加载模板可视化设计配置
 *
 * @author CPQ Team
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Accessors(chain = true)
public class TemplateDesignBo implements Serializable {
    @Serial private static final long serialVersionUID = 1L;

    /** 模板ID */
    private Long templateId;
    /** 模板设计 JSON (sections, styles, pageSettings) */
    private String templateJson;
    /** 模板名称 */
    private String templateName;
    /** 模板类型 */
    private String templateType;
}
