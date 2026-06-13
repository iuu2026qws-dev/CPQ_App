package org.dromara.cpq.quote.domain.vo;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.experimental.Accessors;

import java.io.Serial;
import java.io.Serializable;
import java.util.List;

/**
 * 模板可用字段 VO — 报价模板设计器字段库
 *
 * @author CPQ Team
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Accessors(chain = true)
public class TemplateFieldVo implements Serializable {
    @Serial private static final long serialVersionUID = 1L;

    /** 字段分类 */
    private String category;
    /** 分类标签 */
    private String categoryLabel;
    /** 该分类下的字段列表 */
    private List<FieldItem> fields;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Accessors(chain = true)
    public static class FieldItem implements Serializable {
        @Serial private static final long serialVersionUID = 1L;
        /** 字段占位符 (如 quote.quoteNumber) */
        private String bindField;
        /** 字段标签 (如 报价编号) */
        private String label;
        /** 字段类型: text/number/date/currency */
        private String fieldType;
        /** 适用区域: header/line/summary */
        private String scope;
    }
}
