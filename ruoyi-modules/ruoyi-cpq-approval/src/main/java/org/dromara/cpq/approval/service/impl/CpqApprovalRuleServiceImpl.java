package org.dromara.cpq.approval.service.impl;

import cn.hutool.core.bean.BeanUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.utils.StringUtils;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.cpq.approval.domain.CpqApprovalRule;
import org.dromara.cpq.approval.domain.bo.CpqApprovalRuleBo;
import org.dromara.cpq.approval.domain.vo.CpqApprovalRuleVo;
import org.dromara.cpq.approval.mapper.CpqApprovalRuleMapper;
import org.dromara.cpq.approval.service.ICpqApprovalRuleService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.Arrays;
import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Service
public class CpqApprovalRuleServiceImpl extends ServiceImpl<CpqApprovalRuleMapper, CpqApprovalRule> implements ICpqApprovalRuleService {
    @Override public CpqApprovalRuleVo selectById(Long id) { return BeanUtil.toBean(getById(id), CpqApprovalRuleVo.class); }
    @Override public List<CpqApprovalRuleVo> selectList(CpqApprovalRuleBo bo) {
        LambdaQueryWrapper<CpqApprovalRule> qw = new LambdaQueryWrapper<>();
        qw.like(StringUtils.isNotBlank(bo.getRuleName()), CpqApprovalRule::getRuleName, bo.getRuleName());
        qw.eq(StringUtils.isNotBlank(bo.getTriggerType()), CpqApprovalRule::getTriggerType, bo.getTriggerType());
        return BeanUtil.copyToList(list(qw), CpqApprovalRuleVo.class);
    }
    @Override public TableDataInfo<CpqApprovalRuleVo> selectPageList(CpqApprovalRuleBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<CpqApprovalRule> qw = new LambdaQueryWrapper<>();
        qw.eq(StringUtils.isNotBlank(bo.getTriggerType()), CpqApprovalRule::getTriggerType, bo.getTriggerType());
        return TableDataInfo.build(BeanUtil.copyToList(page(pageQuery.build(), qw).getRecords(), CpqApprovalRuleVo.class));
    }
    @Override @Transactional public int insert(CpqApprovalRuleBo bo) { return save(BeanUtil.toBean(bo, CpqApprovalRule.class)) ? 1 : 0; }
    @Override @Transactional public int update(CpqApprovalRuleBo bo) { return updateById(BeanUtil.toBean(bo, CpqApprovalRule.class)) ? 1 : 0; }
    @Override @Transactional public int deleteById(Long id) { return removeById(id) ? 1 : 0; }
    @Override @Transactional public int deleteByIds(Long[] ids) { return removeByIds(Arrays.asList(ids)) ? 1 : 0; }
}
