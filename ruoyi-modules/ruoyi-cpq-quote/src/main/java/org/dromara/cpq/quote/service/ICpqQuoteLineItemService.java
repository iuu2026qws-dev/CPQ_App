package org.dromara.cpq.quote.service;

import com.baomidou.mybatisplus.extension.service.IService;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.cpq.quote.domain.CpqQuoteLineItem;
import org.dromara.cpq.quote.domain.bo.CpqQuoteLineItemBo;
import org.dromara.cpq.quote.domain.vo.CpqQuoteLineItemVo;
import java.util.List;

public interface ICpqQuoteLineItemService extends IService<CpqQuoteLineItem> {
    CpqQuoteLineItemVo selectById(Long id);
    List<CpqQuoteLineItemVo> selectList(CpqQuoteLineItemBo bo);
    TableDataInfo<CpqQuoteLineItemVo> selectPageList(CpqQuoteLineItemBo bo, PageQuery pageQuery);
    int insert(CpqQuoteLineItemBo bo);
    int update(CpqQuoteLineItemBo bo);
    int deleteById(Long id);
    int deleteByIds(Long[] ids);
}
