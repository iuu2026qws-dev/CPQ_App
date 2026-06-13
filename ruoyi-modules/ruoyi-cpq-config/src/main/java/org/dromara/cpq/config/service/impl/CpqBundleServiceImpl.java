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
import org.dromara.cpq.config.domain.CpqBundle;
import org.dromara.cpq.config.domain.bo.CpqBundleBo;
import org.dromara.cpq.config.domain.vo.CpqBundleVo;
import org.dromara.cpq.config.mapper.CpqBundleMapper;
import org.dromara.cpq.config.service.ICpqBundleService;

import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Service
public class CpqBundleServiceImpl implements ICpqBundleService {

    private final CpqBundleMapper mapper;

    @Override
    public List<CpqBundleVo> selectList(CpqBundleBo bo) {
        LambdaQueryWrapper<CpqBundle> qw = Wrappers.lambdaQuery();
        // query by status = '0' (normal), del_flag will be filtered by @TableLogic
        qw.eq(CpqBundle::getStatus, "0");
        // Add query conditions from BO if needed
        qw.orderByDesc(CpqBundle::getCreateTime);
        return mapper.selectVoList(qw);
    }

    @Override
    public CpqBundleVo selectById(Long id) {
        return mapper.selectVoById(id);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean insert(CpqBundleBo bo) {
        CpqBundle entity = MapstructUtils.convert(bo, CpqBundle.class);
        int rows = mapper.insert(entity);
        return rows > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean update(CpqBundleBo bo) {
        CpqBundle existing = mapper.selectById(bo.getBundleId());
        if (ObjectUtil.isNull(existing)) {
            throw new RuntimeException("记录不存在");
        }
        CpqBundle entity = MapstructUtils.convert(bo, CpqBundle.class);
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
