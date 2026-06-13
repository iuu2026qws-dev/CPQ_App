package org.dromara.cpq.quote.service;

import com.baomidou.mybatisplus.extension.service.IService;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.cpq.quote.domain.CpqQuoteVersion;
import org.dromara.cpq.quote.domain.bo.CpqQuoteVersionBo;
import org.dromara.cpq.quote.domain.vo.CpqQuoteVersionVo;
import java.util.List;

public interface ICpqQuoteVersionService extends IService<CpqQuoteVersion> {
    CpqQuoteVersionVo selectById(Long id);
    List<CpqQuoteVersionVo> selectList(CpqQuoteVersionBo bo);
    TableDataInfo<CpqQuoteVersionVo> selectPageList(CpqQuoteVersionBo bo, PageQuery pageQuery);
    int insert(CpqQuoteVersionBo bo);
    int deleteById(Long id);
}
