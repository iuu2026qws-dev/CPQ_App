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
import org.dromara.cpq.config.domain.CpqVariantBom;
import org.dromara.cpq.config.domain.bo.CpqVariantBomBo;
import org.dromara.cpq.config.domain.vo.CpqVariantBomVo;
import org.dromara.cpq.config.mapper.CpqVariantBomMapper;
import org.dromara.cpq.config.service.ICpqVariantBomService;

import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Service
public class CpqVariantBomServiceImpl implements ICpqVariantBomService {

    private final CpqVariantBomMapper mapper;

    @Override
    public List<CpqVariantBomVo> selectList(CpqVariantBomBo bo) {
        LambdaQueryWrapper<CpqVariantBom> qw = Wrappers.lambdaQuery();
        // query by status = '0' (normal), del_flag will be filtered by @TableLogic
        // Add query conditions from BO if needed
        qw.orderByDesc(CpqVariantBom::getCreateTime);
        return mapper.selectVoList(qw);
    }

    @Override
    public CpqVariantBomVo selectById(Long id) {
        return mapper.selectVoById(id);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean insert(CpqVariantBomBo bo) {
        CpqVariantBom entity = MapstructUtils.convert(bo, CpqVariantBom.class);
        int rows = mapper.insert(entity);
        return rows > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean update(CpqVariantBomBo bo) {
        CpqVariantBom existing = mapper.selectById(bo.getVariantId());
        if (ObjectUtil.isNull(existing)) {
            throw new RuntimeException("记录不存在");
        }
        CpqVariantBom entity = MapstructUtils.convert(bo, CpqVariantBom.class);
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
