package org.dromara.cpq.approval.service.impl;

import cn.hutool.core.bean.BeanUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.cpq.approval.domain.CpqApprovalRecord;
import org.dromara.cpq.approval.domain.bo.CpqApprovalRecordBo;
import org.dromara.cpq.approval.domain.vo.CpqApprovalRecordVo;
import org.dromara.cpq.approval.mapper.CpqApprovalRecordMapper;
import org.dromara.cpq.approval.service.ICpqApprovalRecordService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Service
public class CpqApprovalRecordServiceImpl extends ServiceImpl<CpqApprovalRecordMapper, CpqApprovalRecord> implements ICpqApprovalRecordService {
    @Override public CpqApprovalRecordVo selectById(Long id) { return BeanUtil.toBean(getById(id), CpqApprovalRecordVo.class); }
    @Override public List<CpqApprovalRecordVo> selectByChainId(Long chainId) {
        LambdaQueryWrapper<CpqApprovalRecord> qw = new LambdaQueryWrapper<>();
        qw.eq(CpqApprovalRecord::getChainId, chainId);
        qw.orderByAsc(CpqApprovalRecord::getStepNumber);
        return BeanUtil.copyToList(list(qw), CpqApprovalRecordVo.class);
    }
    @Override public TableDataInfo<CpqApprovalRecordVo> selectPageList(CpqApprovalRecordBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<CpqApprovalRecord> qw = new LambdaQueryWrapper<>();
        qw.eq(bo.getChainId() != null, CpqApprovalRecord::getChainId, bo.getChainId());
        return TableDataInfo.build(BeanUtil.copyToList(page(pageQuery.build(), qw).getRecords(), CpqApprovalRecordVo.class));
    }
    @Override @Transactional public int insert(CpqApprovalRecordBo bo) { return save(BeanUtil.toBean(bo, CpqApprovalRecord.class)) ? 1 : 0; }
}
