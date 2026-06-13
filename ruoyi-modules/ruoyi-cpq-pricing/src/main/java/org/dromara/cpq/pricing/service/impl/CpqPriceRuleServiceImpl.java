package org.dromara.cpq.pricing.service.impl;

import cn.hutool.core.util.ObjectUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.common.core.utils.MapstructUtils;
import org.dromara.cpq.pricing.domain.CpqPriceRule;
import org.dromara.cpq.pricing.domain.bo.CpqPriceRuleBo;
import org.dromara.cpq.pricing.domain.vo.CpqPriceRuleVo;
import org.dromara.cpq.pricing.mapper.CpqPriceRuleMapper;
import org.dromara.cpq.pricing.service.ICpqPriceRuleService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class CpqPriceRuleServiceImpl implements ICpqPriceRuleService {

    private final CpqPriceRuleMapper baseMapper;

    @Override
    public List<CpqPriceRuleVo> selectPriceRuleList(CpqPriceRuleBo bo) {
        log.info("查询CPQ定价规则列表，参数: {}", bo);
        LambdaQueryWrapper<CpqPriceRule> wrapper = new LambdaQueryWrapper<>();
        if (ObjectUtil.isNotNull(bo.getRuleName())) {
            wrapper.like(CpqPriceRule::getRuleName, bo.getRuleName());
        }
        if (ObjectUtil.isNotNull(bo.getRuleType())) {
            wrapper.eq(CpqPriceRule::getRuleType, bo.getRuleType());
        }
        if (ObjectUtil.isNotNull(bo.getStatus())) {
            wrapper.eq(CpqPriceRule::getStatus, bo.getStatus());
        }
        wrapper.orderByDesc(CpqPriceRule::getPriority).orderByDesc(CpqPriceRule::getCreateTime);
        List<CpqPriceRule> list = baseMapper.selectList(wrapper);
        return MapstructUtils.convert(list, CpqPriceRuleVo.class);
    }

    @Override
    public CpqPriceRuleVo selectPriceRuleById(Long priceRuleId) {
        log.info("查询CPQ定价规则详情，ID: {}", priceRuleId);
        CpqPriceRule rule = baseMapper.selectById(priceRuleId);
        if (ObjectUtil.isNull(rule)) {
            throw new ServiceException("定价规则不存在");
        }
        return MapstructUtils.convert(rule, CpqPriceRuleVo.class);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertPriceRule(CpqPriceRuleBo bo) {
        log.info("新增CPQ定价规则，参数: {}", bo);
        CpqPriceRule rule = MapstructUtils.convert(bo, CpqPriceRule.class);
        return baseMapper.insert(rule);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updatePriceRule(CpqPriceRuleBo bo) {
        log.info("修改CPQ定价规则，参数: {}", bo);
        CpqPriceRule rule = MapstructUtils.convert(bo, CpqPriceRule.class);
        return baseMapper.updateById(rule);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deletePriceRule(Long priceRuleId) {
        log.info("删除CPQ定价规则，ID: {}", priceRuleId);
        return baseMapper.deleteById(priceRuleId);
    }
}
