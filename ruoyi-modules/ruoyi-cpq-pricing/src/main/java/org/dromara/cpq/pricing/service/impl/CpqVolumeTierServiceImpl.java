package org.dromara.cpq.pricing.service.impl;

import cn.hutool.core.util.ObjectUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.common.core.utils.MapstructUtils;
import org.dromara.cpq.pricing.domain.CpqVolumeTier;
import org.dromara.cpq.pricing.domain.bo.CpqVolumeTierBo;
import org.dromara.cpq.pricing.domain.vo.CpqVolumeTierVo;
import org.dromara.cpq.pricing.mapper.CpqVolumeTierMapper;
import org.dromara.cpq.pricing.service.ICpqVolumeTierService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class CpqVolumeTierServiceImpl implements ICpqVolumeTierService {

    private final CpqVolumeTierMapper baseMapper;

    @Override
    public List<CpqVolumeTierVo> selectVolumeTierList(CpqVolumeTierBo bo) {
        log.info("查询CPQ阶梯定价列表，参数: {}", bo);
        LambdaQueryWrapper<CpqVolumeTier> wrapper = new LambdaQueryWrapper<>();
        if (ObjectUtil.isNotNull(bo.getPriceBookEntryId())) {
            wrapper.eq(CpqVolumeTier::getPriceBookEntryId, bo.getPriceBookEntryId());
        }
        wrapper.orderByAsc(CpqVolumeTier::getSortOrder).orderByAsc(CpqVolumeTier::getMinQuantity);
        List<CpqVolumeTier> list = baseMapper.selectList(wrapper);
        return MapstructUtils.convert(list, CpqVolumeTierVo.class);
    }

    @Override
    public CpqVolumeTierVo selectVolumeTierById(Long tierId) {
        log.info("查询CPQ阶梯定价详情，ID: {}", tierId);
        CpqVolumeTier tier = baseMapper.selectById(tierId);
        if (ObjectUtil.isNull(tier)) {
            throw new ServiceException("阶梯定价不存在");
        }
        return MapstructUtils.convert(tier, CpqVolumeTierVo.class);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertVolumeTier(CpqVolumeTierBo bo) {
        log.info("新增CPQ阶梯定价，参数: {}", bo);
        CpqVolumeTier tier = MapstructUtils.convert(bo, CpqVolumeTier.class);
        return baseMapper.insert(tier);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updateVolumeTier(CpqVolumeTierBo bo) {
        log.info("修改CPQ阶梯定价，参数: {}", bo);
        CpqVolumeTier tier = MapstructUtils.convert(bo, CpqVolumeTier.class);
        return baseMapper.updateById(tier);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteVolumeTier(Long tierId) {
        log.info("删除CPQ阶梯定价，ID: {}", tierId);
        return baseMapper.deleteById(tierId);
    }
}
