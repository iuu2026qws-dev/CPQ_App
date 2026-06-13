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
import org.dromara.cpq.config.domain.CpqAttributeMapping;
import org.dromara.cpq.config.domain.bo.CpqAttributeMappingBo;
import org.dromara.cpq.config.domain.vo.CpqAttributeMappingVo;
import org.dromara.cpq.config.mapper.CpqAttributeMappingMapper;
import org.dromara.cpq.config.service.ICpqAttributeMappingService;

import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Service
public class CpqAttributeMappingServiceImpl implements ICpqAttributeMappingService {

    private final CpqAttributeMappingMapper mapper;

    @Override
    public List<CpqAttributeMappingVo> selectList(CpqAttributeMappingBo bo) {
        LambdaQueryWrapper<CpqAttributeMapping> qw = Wrappers.lambdaQuery();
        // query by status = '0' (normal), del_flag will be filtered by @TableLogic
        // Add query conditions from BO if needed
        qw.orderByDesc(CpqAttributeMapping::getCreateTime);
        return mapper.selectVoList(qw);
    }

    @Override
    public CpqAttributeMappingVo selectById(Long id) {
        return mapper.selectVoById(id);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean insert(CpqAttributeMappingBo bo) {
        CpqAttributeMapping entity = MapstructUtils.convert(bo, CpqAttributeMapping.class);
        int rows = mapper.insert(entity);
        return rows > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean update(CpqAttributeMappingBo bo) {
        CpqAttributeMapping existing = mapper.selectById(bo.getMappingId());
        if (ObjectUtil.isNull(existing)) {
            throw new RuntimeException("记录不存在");
        }
        CpqAttributeMapping entity = MapstructUtils.convert(bo, CpqAttributeMapping.class);
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
