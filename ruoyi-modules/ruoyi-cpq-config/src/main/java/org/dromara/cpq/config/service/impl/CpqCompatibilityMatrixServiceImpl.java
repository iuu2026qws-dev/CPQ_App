package org.dromara.cpq.config.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.util.ObjectUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.utils.MapstructUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.dromara.cpq.config.domain.CpqCompatibilityMatrix;
import org.dromara.cpq.config.domain.bo.CpqCompatibilityMatrixBo;
import org.dromara.cpq.config.domain.vo.CpqCompatibilityMatrixVo;
import org.dromara.cpq.config.mapper.CpqCompatibilityMatrixMapper;
import org.dromara.cpq.config.service.ICpqCompatibilityMatrixService;

import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Service
public class CpqCompatibilityMatrixServiceImpl implements ICpqCompatibilityMatrixService {

    private final CpqCompatibilityMatrixMapper mapper;

    @Override
    public List<CpqCompatibilityMatrixVo> selectList(CpqCompatibilityMatrixBo bo) {
        LambdaQueryWrapper<CpqCompatibilityMatrix> qw = Wrappers.lambdaQuery();
        // query by status = '0' (normal), del_flag will be filtered by @TableLogic
        // Add query conditions from BO if needed
        qw.orderByDesc(CpqCompatibilityMatrix::getCreateTime);
        return mapper.selectVoList(qw);
    }

    @Override
    public CpqCompatibilityMatrixVo selectById(Long id) {
        return mapper.selectVoById(id);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean insert(CpqCompatibilityMatrixBo bo) {
        CpqCompatibilityMatrix entity = MapstructUtils.convert(bo, CpqCompatibilityMatrix.class);
        int rows = mapper.insert(entity);
        return rows > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean update(CpqCompatibilityMatrixBo bo) {
        CpqCompatibilityMatrix existing = mapper.selectById(bo.getMatrixId());
        if (ObjectUtil.isNull(existing)) {
            throw new RuntimeException("记录不存在");
        }
        CpqCompatibilityMatrix entity = MapstructUtils.convert(bo, CpqCompatibilityMatrix.class);
        int rows = mapper.updateById(entity);
        return rows > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean delete(Long id) {
        int rows = mapper.deleteById(id);
        return rows > 0;
    }
}
