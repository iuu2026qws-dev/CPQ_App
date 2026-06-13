package org.dromara.cpq.service.impl;

import cn.hutool.core.util.ObjectUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.common.core.utils.MapstructUtils;
import org.dromara.cpq.domain.CpqAbacPolicy;
import org.dromara.cpq.domain.bo.CpqAbacPolicyBo;
import org.dromara.cpq.domain.vo.CpqAbacPolicyVo;
import org.dromara.cpq.mapper.CpqAbacPolicyMapper;
import org.dromara.cpq.service.ICpqAbacPolicyService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * CPQ ABAC策略 Service 实现
 *
 * @author CPQ Team
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CpqAbacPolicyServiceImpl implements ICpqAbacPolicyService {

    private final CpqAbacPolicyMapper baseMapper;

    @Override
    public List<CpqAbacPolicyVo> selectPolicyList(CpqAbacPolicyBo bo) {
        log.info("查询ABAC策略列表，参数: {}", bo);
        LambdaQueryWrapper<CpqAbacPolicy> wrapper = new LambdaQueryWrapper<>();
        if (StrUtil.isNotBlank(bo.getPolicyName())) {
            wrapper.like(CpqAbacPolicy::getPolicyName, bo.getPolicyName());
        }
        if (StrUtil.isNotBlank(bo.getPolicyType())) {
            wrapper.eq(CpqAbacPolicy::getPolicyType, bo.getPolicyType());
        }
        if (StrUtil.isNotBlank(bo.getSubjectType())) {
            wrapper.eq(CpqAbacPolicy::getSubjectType, bo.getSubjectType());
        }
        wrapper.orderByAsc(CpqAbacPolicy::getPolicyType, CpqAbacPolicy::getSubjectType);
        return MapstructUtils.convert(baseMapper.selectList(wrapper), CpqAbacPolicyVo.class);
    }

    @Override
    public CpqAbacPolicyVo selectPolicyById(Long policyId) {
        log.info("查询ABAC策略，ID: {}", policyId);
        CpqAbacPolicy policy = baseMapper.selectById(policyId);
        if (ObjectUtil.isNull(policy)) {
            throw new ServiceException("ABAC策略不存在");
        }
        return MapstructUtils.convert(policy, CpqAbacPolicyVo.class);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertPolicy(CpqAbacPolicyBo bo) {
        log.info("新增ABAC策略，参数: {}", bo);
        CpqAbacPolicy policy = MapstructUtils.convert(bo, CpqAbacPolicy.class);
        return baseMapper.insert(policy);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updatePolicy(CpqAbacPolicyBo bo) {
        log.info("修改ABAC策略，参数: {}", bo);
        CpqAbacPolicy policy = MapstructUtils.convert(bo, CpqAbacPolicy.class);
        return baseMapper.updateById(policy);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deletePolicy(Long policyId) {
        log.info("删除ABAC策略，ID: {}", policyId);
        return baseMapper.deleteById(policyId);
    }
}
