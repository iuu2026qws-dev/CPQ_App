package org.dromara.cpq.quote.service;

import com.baomidou.mybatisplus.extension.service.IService;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.cpq.quote.domain.CpqQuote;
import org.dromara.cpq.quote.domain.bo.CpqQuoteBo;
import org.dromara.cpq.quote.domain.vo.CpqQuoteVo;

import java.util.List;

public interface ICpqQuoteService extends IService<CpqQuote> {
    CpqQuoteVo selectById(Long id);
    List<CpqQuoteVo> selectList(CpqQuoteBo bo);
    TableDataInfo<CpqQuoteVo> selectPageList(CpqQuoteBo bo, PageQuery pageQuery);
    Long insert(CpqQuoteBo bo);
    int update(CpqQuoteBo bo);
    int deleteById(Long id);
    int deleteByIds(Long[] ids);

    /** 按产品编码查询包含该产品的活跃报价单（用于ECN影响分析L3） */
    List<CpqQuoteVo> selectActiveByItemCode(String itemCode);

    /** 按SBOM行ID查询包含该BOM行的活跃报价单 */
    List<CpqQuoteVo> selectActiveBySbomLineId(Long sbomLineId);

    /** 按状态查询报价单列表（用于ECN传播 — 查找已转ERP的报价单） */
    List<CpqQuoteVo> selectByStatus(String status);

    /** 批量更新报价单状态（用于ECN传播） */
    int batchUpdateStatus(List<Long> quoteIds, String newStatus);
}
