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
import org.dromara.cpq.config.domain.CpqBundleOptionGroup;
import org.dromara.cpq.config.domain.bo.CpqBundleOptionGroupBo;
import org.dromara.cpq.config.domain.vo.CpqBundleOptionGroupVo;
import org.dromara.cpq.config.mapper.CpqBundleOptionGroupMapper;
import org.dromara.cpq.config.service.ICpqBundleOptionGroupService;

import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Service
public class CpqBundleOptionGroupServiceImpl implements ICpqBundleOptionGroupService {

    private final CpqBundleOptionGroupMapper mapper;

    @Override
    public List<CpqBundleOptionGroupVo> selectList(CpqBundleOptionGroupBo bo) {
        LambdaQueryWrapper<CpqBundleOptionGroup> qw = Wrappers.lambdaQuery();
        // query by status = '0' (normal), del_flag will be filtered by @TableLogic
        qw.eq(CpqBundleOptionGroup::getStatus, "0");
        // Add query conditions from BO if needed
        qw.orderByDesc(CpqBundleOptionGroup::getCreateTime);
        return mapper.selectVoList(qw);
    }

    @Override
    public CpqBundleOptionGroupVo selectById(Long id) {
        return mapper.selectVoById(id);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean insert(CpqBundleOptionGroupBo bo) {
        CpqBundleOptionGroup entity = MapstructUtils.convert(bo, CpqBundleOptionGroup.class);
        int rows = mapper.insert(entity);
        return rows > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean update(CpqBundleOptionGroupBo bo) {
        CpqBundleOptionGroup existing = mapper.selectById(bo.getOptionGroupId());
        if (ObjectUtil.isNull(existing)) {
            throw new RuntimeException("记录不存在");
        }
        CpqBundleOptionGroup entity = MapstructUtils.convert(bo, CpqBundleOptionGroup.class);
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
