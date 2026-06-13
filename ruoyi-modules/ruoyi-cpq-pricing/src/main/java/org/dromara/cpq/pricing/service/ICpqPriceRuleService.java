package org.dromara.cpq.pricing.service;

import org.dromara.cpq.pricing.domain.bo.CpqPriceRuleBo;
import org.dromara.cpq.pricing.domain.vo.CpqPriceRuleVo;

import java.util.List;

public interface ICpqPriceRuleService {
    List<CpqPriceRuleVo> selectPriceRuleList(CpqPriceRuleBo bo);
    CpqPriceRuleVo selectPriceRuleById(Long priceRuleId);
    int insertPriceRule(CpqPriceRuleBo bo);
    int updatePriceRule(CpqPriceRuleBo bo);
    int deletePriceRule(Long priceRuleId);
}
