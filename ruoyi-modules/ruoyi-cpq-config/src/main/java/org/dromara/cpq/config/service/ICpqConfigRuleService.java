package org.dromara.cpq.config.service;

import org.dromara.cpq.config.domain.CpqConfigRule;
import org.dromara.cpq.config.domain.vo.CpqConfigRuleVo;
import org.dromara.cpq.config.domain.bo.CpqConfigRuleBo;

import java.util.List;

public interface ICpqConfigRuleService {
    List<CpqConfigRuleVo> selectList(CpqConfigRuleBo bo);
    CpqConfigRuleVo selectById(Long id);
    Boolean insert(CpqConfigRuleBo bo);
    Boolean update(CpqConfigRuleBo bo);
    Boolean delete(Long id);
}
