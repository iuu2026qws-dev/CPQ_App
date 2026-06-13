package org.dromara.cpq.quote.mapper;

import org.apache.ibatis.annotations.Select;
import org.dromara.common.mybatis.core.mapper.BaseMapperPlus;
import org.dromara.cpq.quote.domain.CpqQuoteLineItem;
import org.dromara.cpq.quote.domain.vo.CpqQuoteLineItemVo;

import java.util.List;

public interface CpqQuoteLineItemMapper extends BaseMapperPlus<CpqQuoteLineItem, CpqQuoteLineItemVo> {

    /**
     * 获取报价单下最大行号（含软删除行）。
     */
    @Select("SELECT IFNULL(MAX(line_number), 0) FROM cpq_quote_line_item WHERE quote_id = #{quoteId}")
    int selectMaxLineNumber(Long quoteId);

    /**
     * 按产品编码查询包含该产品的报价行（用于ECN影响分析 — 查找受产品变更影响的报价单）
     */
    @Select("SELECT DISTINCT quote_id FROM cpq_quote_line_item WHERE item_code = #{itemCode} AND del_flag = '0'")
    List<Long> selectQuoteIdsByItemCode(String itemCode);

    /**
     * 按SBOM行ID查询包含该BOM行的报价行（用于ECN影响分析 — 查找受BOM变更影响的报价单）
     */
    @Select("SELECT DISTINCT quote_id FROM cpq_quote_line_item WHERE sbom_line_id = #{sbomLineId} AND del_flag = '0'")
    List<Long> selectQuoteIdsBySbomLineId(Long sbomLineId);

    /**
     * 按产品编码批量查询受影响的报价行（用于ECN传播 — 更新报价行状态）
     */
    @Select("SELECT * FROM cpq_quote_line_item WHERE item_code = #{itemCode} AND del_flag = '0'")
    List<CpqQuoteLineItem> selectLineItemsByItemCode(String itemCode);
}
