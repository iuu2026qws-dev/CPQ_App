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
import org.dromara.cpq.config.domain.CpqBundleOption;
import org.dromara.cpq.config.domain.bo.CpqBundleOptionBo;
import org.dromara.cpq.config.domain.vo.CpqBundleOptionVo;
import org.dromara.cpq.config.mapper.CpqBundleOptionMapper;
import org.dromara.cpq.config.service.ICpqBundleOptionService;

import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Service
public class CpqBundleOptionServiceImpl implements ICpqBundleOptionService {

    private final CpqBundleOptionMapper mapper;

    @Override
    public List<CpqBundleOptionVo> selectList(CpqBundleOptionBo bo) {
        LambdaQueryWrapper<CpqBundleOption> qw = Wrappers.lambdaQuery();
        // query by status = '0' (normal), del_flag will be filtered by @TableLogic
        qw.eq(CpqBundleOption::getStatus, "0");
        // Add query conditions from BO if needed
        qw.orderByDesc(CpqBundleOption::getCreateTime);
        return mapper.selectVoList(qw);
    }

    @Override
    public CpqBundleOptionVo selectById(Long id) {
        return mapper.selectVoById(id);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean insert(CpqBundleOptionBo bo) {
        CpqBundleOption entity = MapstructUtils.convert(bo, CpqBundleOption.class);
        int rows = mapper.insert(entity);
        return rows > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean update(CpqBundleOptionBo bo) {
        CpqBundleOption existing = mapper.selectById(bo.getOptionId());
        if (ObjectUtil.isNull(existing)) {
            throw new RuntimeException("记录不存在");
        }
        CpqBundleOption entity = MapstructUtils.convert(bo, CpqBundleOption.class);
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
