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
import org.dromara.cpq.config.domain.CpqConfigRule;
import org.dromara.cpq.config.domain.bo.CpqConfigRuleBo;
import org.dromara.cpq.config.domain.vo.CpqConfigRuleVo;
import org.dromara.cpq.config.mapper.CpqConfigRuleMapper;
import org.dromara.cpq.config.service.ICpqConfigRuleService;

import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Service
public class CpqConfigRuleServiceImpl implements ICpqConfigRuleService {

    private final CpqConfigRuleMapper mapper;

    @Override
    public List<CpqConfigRuleVo> selectList(CpqConfigRuleBo bo) {
        LambdaQueryWrapper<CpqConfigRule> qw = Wrappers.lambdaQuery();
        // query by status = '0' (normal), del_flag will be filtered by @TableLogic
        qw.eq(CpqConfigRule::getStatus, "0");
        // Add query conditions from BO if needed
        qw.orderByDesc(CpqConfigRule::getCreateTime);
        return mapper.selectVoList(qw);
    }

    @Override
    public CpqConfigRuleVo selectById(Long id) {
        return mapper.selectVoById(id);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean insert(CpqConfigRuleBo bo) {
        CpqConfigRule entity = MapstructUtils.convert(bo, CpqConfigRule.class);
        int rows = mapper.insert(entity);
        return rows > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean update(CpqConfigRuleBo bo) {
        CpqConfigRule existing = mapper.selectById(bo.getRuleId());
        if (ObjectUtil.isNull(existing)) {
            throw new RuntimeException("记录不存在");
        }
        CpqConfigRule entity = MapstructUtils.convert(bo, CpqConfigRule.class);
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
