package org.dromara.cpq.quote.service.impl;

import cn.hutool.core.bean.BeanUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.cpq.quote.domain.CpqConfigSnapshot;
import org.dromara.cpq.quote.domain.bo.CpqConfigSnapshotBo;
import org.dromara.cpq.quote.domain.vo.CpqConfigSnapshotVo;
import org.dromara.cpq.quote.mapper.CpqConfigSnapshotMapper;
import org.dromara.cpq.quote.service.ICpqConfigSnapshotService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Service
public class CpqConfigSnapshotServiceImpl extends ServiceImpl<CpqConfigSnapshotMapper, CpqConfigSnapshot> implements ICpqConfigSnapshotService {
    @Override public CpqConfigSnapshotVo selectById(Long id) { return BeanUtil.toBean(getById(id), CpqConfigSnapshotVo.class); }
    @Override public List<CpqConfigSnapshotVo> selectList(CpqConfigSnapshotBo bo) {
        LambdaQueryWrapper<CpqConfigSnapshot> qw = new LambdaQueryWrapper<>();
        qw.eq(bo.getQuoteId() != null, CpqConfigSnapshot::getQuoteId, bo.getQuoteId());
        return BeanUtil.copyToList(list(qw), CpqConfigSnapshotVo.class);
    }
    @Override public TableDataInfo<CpqConfigSnapshotVo> selectPageList(CpqConfigSnapshotBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<CpqConfigSnapshot> qw = new LambdaQueryWrapper<>();
        qw.eq(bo.getQuoteId() != null, CpqConfigSnapshot::getQuoteId, bo.getQuoteId());
        return TableDataInfo.build(BeanUtil.copyToList(page(pageQuery.build(), qw).getRecords(), CpqConfigSnapshotVo.class));
    }
    @Override @Transactional public int insert(CpqConfigSnapshotBo bo) { return save(BeanUtil.toBean(bo, CpqConfigSnapshot.class)) ? 1 : 0; }
    @Override @Transactional public int update(CpqConfigSnapshotBo bo) { return updateById(BeanUtil.toBean(bo, CpqConfigSnapshot.class)) ? 1 : 0; }
    @Override @Transactional public int deleteById(Long id) { return removeById(id) ? 1 : 0; }
    @Override @Transactional public int deleteByIds(Long[] ids) { return removeByIds(Arrays.asList(ids)) ? 1 : 0; }
}
