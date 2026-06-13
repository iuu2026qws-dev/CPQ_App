package org.dromara.cpq.quote.service;

import com.baomidou.mybatisplus.extension.service.IService;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.cpq.quote.domain.CpqSolutionDocument;
import org.dromara.cpq.quote.domain.bo.CpqSolutionDocumentBo;
import org.dromara.cpq.quote.domain.vo.CpqSolutionDocumentVo;
import java.util.List;

public interface ICpqSolutionDocumentService extends IService<CpqSolutionDocument> {
    CpqSolutionDocumentVo selectById(Long id);
    List<CpqSolutionDocumentVo> selectList(CpqSolutionDocumentBo bo);
    TableDataInfo<CpqSolutionDocumentVo> selectPageList(CpqSolutionDocumentBo bo, PageQuery pageQuery);
    int insert(CpqSolutionDocumentBo bo);
    int update(CpqSolutionDocumentBo bo);
    int deleteById(Long id);
    int deleteByIds(Long[] ids);
}
