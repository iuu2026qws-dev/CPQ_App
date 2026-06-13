package org.dromara.cpq.quote.service.impl;

import cn.hutool.core.bean.BeanUtil;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.cpq.quote.domain.CpqSolutionDocument;
import org.dromara.cpq.quote.domain.bo.CpqSolutionDocumentBo;
import org.dromara.cpq.quote.domain.vo.CpqSolutionDocumentVo;
import org.dromara.cpq.quote.mapper.CpqSolutionDocumentMapper;
import org.dromara.cpq.quote.service.ICpqSolutionDocumentService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.Arrays;
import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Service
public class CpqSolutionDocumentServiceImpl extends ServiceImpl<CpqSolutionDocumentMapper, CpqSolutionDocument> implements ICpqSolutionDocumentService {
    @Override public CpqSolutionDocumentVo selectById(Long id) { return BeanUtil.toBean(getById(id), CpqSolutionDocumentVo.class); }
    @Override public List<CpqSolutionDocumentVo> selectList(CpqSolutionDocumentBo bo) { return BeanUtil.copyToList(list(), CpqSolutionDocumentVo.class); }
    @Override public TableDataInfo<CpqSolutionDocumentVo> selectPageList(CpqSolutionDocumentBo bo, PageQuery pageQuery) { return TableDataInfo.build(BeanUtil.copyToList(page(pageQuery.build()).getRecords(), CpqSolutionDocumentVo.class)); }
    @Override @Transactional public int insert(CpqSolutionDocumentBo bo) { return save(BeanUtil.toBean(bo, CpqSolutionDocument.class)) ? 1 : 0; }
    @Override @Transactional public int update(CpqSolutionDocumentBo bo) { return updateById(BeanUtil.toBean(bo, CpqSolutionDocument.class)) ? 1 : 0; }
    @Override @Transactional public int deleteById(Long id) { return removeById(id) ? 1 : 0; }
    @Override @Transactional public int deleteByIds(Long[] ids) { return removeByIds(Arrays.asList(ids)) ? 1 : 0; }
}
