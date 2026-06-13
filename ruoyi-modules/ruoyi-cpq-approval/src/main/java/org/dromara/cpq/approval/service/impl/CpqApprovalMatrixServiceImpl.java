package org.dromara.cpq.approval.service.impl;

import cn.hutool.core.bean.BeanUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.utils.StringUtils;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.cpq.approval.domain.CpqApprovalMatrix;
import org.dromara.cpq.approval.domain.bo.CpqApprovalMatrixBo;
import org.dromara.cpq.approval.domain.vo.CpqApprovalMatrixVo;
import org.dromara.cpq.approval.mapper.CpqApprovalMatrixMapper;
import org.dromara.cpq.approval.service.ICpqApprovalMatrixService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.Arrays;
import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Service
public class CpqApprovalMatrixServiceImpl extends ServiceImpl<CpqApprovalMatrixMapper, CpqApprovalMatrix> implements ICpqApprovalMatrixService {
    @Override public CpqApprovalMatrixVo selectById(Long id) { return BeanUtil.toBean(getById(id), CpqApprovalMatrixVo.class); }
    @Override public List<CpqApprovalMatrixVo> selectList(CpqApprovalMatrixBo bo) {
        LambdaQueryWrapper<CpqApprovalMatrix> qw = new LambdaQueryWrapper<>();
        qw.eq(StringUtils.isNotBlank(bo.getDimensionType()), CpqApprovalMatrix::getDimensionType, bo.getDimensionType());
        return BeanUtil.copyToList(list(qw), CpqApprovalMatrixVo.class);
    }
    @Override public TableDataInfo<CpqApprovalMatrixVo> selectPageList(CpqApprovalMatrixBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<CpqApprovalMatrix> qw = new LambdaQueryWrapper<>();
        qw.eq(StringUtils.isNotBlank(bo.getDimensionType()), CpqApprovalMatrix::getDimensionType, bo.getDimensionType());
        return TableDataInfo.build(BeanUtil.copyToList(page(pageQuery.build(), qw).getRecords(), CpqApprovalMatrixVo.class));
    }
    @Override @Transactional public int insert(CpqApprovalMatrixBo bo) { return save(BeanUtil.toBean(bo, CpqApprovalMatrix.class)) ? 1 : 0; }
    @Override @Transactional public int update(CpqApprovalMatrixBo bo) { return updateById(BeanUtil.toBean(bo, CpqApprovalMatrix.class)) ? 1 : 0; }
    @Override @Transactional public int deleteById(Long id) { return removeById(id) ? 1 : 0; }
    @Override @Transactional public int deleteByIds(Long[] ids) { return removeByIds(Arrays.asList(ids)) ? 1 : 0; }
}
