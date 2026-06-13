package org.dromara.cpq.pricing.service.impl;

import cn.hutool.core.util.ObjectUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.common.core.utils.MapstructUtils;
import org.dromara.cpq.pricing.domain.CpqCurrencyRate;
import org.dromara.cpq.pricing.domain.bo.CpqCurrencyRateBo;
import org.dromara.cpq.pricing.domain.vo.CpqCurrencyRateVo;
import org.dromara.cpq.pricing.mapper.CpqCurrencyRateMapper;
import org.dromara.cpq.pricing.service.ICpqCurrencyRateService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class CpqCurrencyRateServiceImpl implements ICpqCurrencyRateService {

    private final CpqCurrencyRateMapper baseMapper;

    @Override
    public List<CpqCurrencyRateVo> selectCurrencyRateList(CpqCurrencyRateBo bo) {
        log.info("查询CPQ汇率列表，参数: {}", bo);
        LambdaQueryWrapper<CpqCurrencyRate> wrapper = new LambdaQueryWrapper<>();
        if (ObjectUtil.isNotNull(bo.getFromCurrency())) {
            wrapper.eq(CpqCurrencyRate::getFromCurrency, bo.getFromCurrency());
        }
        if (ObjectUtil.isNotNull(bo.getToCurrency())) {
            wrapper.eq(CpqCurrencyRate::getToCurrency, bo.getToCurrency());
        }
        if (ObjectUtil.isNotNull(bo.getStatus())) {
            wrapper.eq(CpqCurrencyRate::getStatus, bo.getStatus());
        }
        wrapper.orderByDesc(CpqCurrencyRate::getEffectiveDate).orderByDesc(CpqCurrencyRate::getCreateTime);
        List<CpqCurrencyRate> list = baseMapper.selectList(wrapper);
        return MapstructUtils.convert(list, CpqCurrencyRateVo.class);
    }

    @Override
    public CpqCurrencyRateVo selectCurrencyRateById(Long rateId) {
        log.info("查询CPQ汇率详情，ID: {}", rateId);
        CpqCurrencyRate rate = baseMapper.selectById(rateId);
        if (ObjectUtil.isNull(rate)) {
            throw new ServiceException("汇率不存在");
        }
        return MapstructUtils.convert(rate, CpqCurrencyRateVo.class);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertCurrencyRate(CpqCurrencyRateBo bo) {
        log.info("新增CPQ汇率，参数: {}", bo);
        CpqCurrencyRate rate = MapstructUtils.convert(bo, CpqCurrencyRate.class);
        return baseMapper.insert(rate);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updateCurrencyRate(CpqCurrencyRateBo bo) {
        log.info("修改CPQ汇率，参数: {}", bo);
        CpqCurrencyRate rate = MapstructUtils.convert(bo, CpqCurrencyRate.class);
        return baseMapper.updateById(rate);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteCurrencyRate(Long rateId) {
        log.info("删除CPQ汇率，ID: {}", rateId);
        return baseMapper.deleteById(rateId);
    }
}
