package org.dromara.cpq.approval.service.impl;

import cn.hutool.core.bean.BeanUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.cpq.approval.domain.CpqApprovalChain;
import org.dromara.cpq.approval.domain.bo.CpqApprovalChainBo;
import org.dromara.cpq.approval.domain.vo.CpqApprovalChainVo;
import org.dromara.cpq.approval.mapper.CpqApprovalChainMapper;
import org.dromara.cpq.approval.service.ICpqApprovalChainService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Service
public class CpqApprovalChainServiceImpl extends ServiceImpl<CpqApprovalChainMapper, CpqApprovalChain> implements ICpqApprovalChainService {
    @Override public CpqApprovalChainVo selectById(Long id) { return BeanUtil.toBean(getById(id), CpqApprovalChainVo.class); }
    @Override public List<CpqApprovalChainVo> selectList(CpqApprovalChainBo bo) {
        LambdaQueryWrapper<CpqApprovalChain> qw = new LambdaQueryWrapper<>();
        qw.eq(bo.getQuoteId() != null, CpqApprovalChain::getQuoteId, bo.getQuoteId());
        return BeanUtil.copyToList(list(qw), CpqApprovalChainVo.class);
    }
    @Override public TableDataInfo<CpqApprovalChainVo> selectPageList(CpqApprovalChainBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<CpqApprovalChain> qw = new LambdaQueryWrapper<>();
        qw.eq(bo.getQuoteId() != null, CpqApprovalChain::getQuoteId, bo.getQuoteId());
        return TableDataInfo.build(BeanUtil.copyToList(page(pageQuery.build(), qw).getRecords(), CpqApprovalChainVo.class));
    }
    @Override @Transactional public int insert(CpqApprovalChainBo bo) { return save(BeanUtil.toBean(bo, CpqApprovalChain.class)) ? 1 : 0; }
    @Override @Transactional public int update(CpqApprovalChainBo bo) { return updateById(BeanUtil.toBean(bo, CpqApprovalChain.class)) ? 1 : 0; }
    @Override @Transactional public int deleteById(Long id) { return removeById(id) ? 1 : 0; }
}
