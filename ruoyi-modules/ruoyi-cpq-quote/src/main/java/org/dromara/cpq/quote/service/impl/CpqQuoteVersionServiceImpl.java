package org.dromara.cpq.quote.service.impl;

import cn.hutool.core.bean.BeanUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.cpq.quote.domain.CpqQuoteVersion;
import org.dromara.cpq.quote.domain.bo.CpqQuoteVersionBo;
import org.dromara.cpq.quote.domain.vo.CpqQuoteVersionVo;
import org.dromara.cpq.quote.mapper.CpqQuoteVersionMapper;
import org.dromara.cpq.quote.service.ICpqQuoteVersionService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Service
public class CpqQuoteVersionServiceImpl extends ServiceImpl<CpqQuoteVersionMapper, CpqQuoteVersion> implements ICpqQuoteVersionService {
    @Override public CpqQuoteVersionVo selectById(Long id) { return BeanUtil.toBean(getById(id), CpqQuoteVersionVo.class); }
    @Override public List<CpqQuoteVersionVo> selectList(CpqQuoteVersionBo bo) {
        LambdaQueryWrapper<CpqQuoteVersion> qw = new LambdaQueryWrapper<>();
        qw.eq(bo.getQuoteId() != null, CpqQuoteVersion::getQuoteId, bo.getQuoteId());
        qw.orderByDesc(CpqQuoteVersion::getVersionNumber);
        return BeanUtil.copyToList(list(qw), CpqQuoteVersionVo.class);
    }
    @Override public TableDataInfo<CpqQuoteVersionVo> selectPageList(CpqQuoteVersionBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<CpqQuoteVersion> qw = new LambdaQueryWrapper<>();
        qw.eq(bo.getQuoteId() != null, CpqQuoteVersion::getQuoteId, bo.getQuoteId());
        return TableDataInfo.build(BeanUtil.copyToList(page(pageQuery.build(), qw).getRecords(), CpqQuoteVersionVo.class));
    }
    @Override @Transactional public int insert(CpqQuoteVersionBo bo) { return save(BeanUtil.toBean(bo, CpqQuoteVersion.class)) ? 1 : 0; }
    @Override @Transactional public int deleteById(Long id) { return removeById(id) ? 1 : 0; }
}
