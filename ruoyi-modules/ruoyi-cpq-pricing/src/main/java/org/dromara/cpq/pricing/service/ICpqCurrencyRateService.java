package org.dromara.cpq.pricing.service;

import org.dromara.cpq.pricing.domain.bo.CpqCurrencyRateBo;
import org.dromara.cpq.pricing.domain.vo.CpqCurrencyRateVo;

import java.util.List;

public interface ICpqCurrencyRateService {
    List<CpqCurrencyRateVo> selectCurrencyRateList(CpqCurrencyRateBo bo);
    CpqCurrencyRateVo selectCurrencyRateById(Long rateId);
    int insertCurrencyRate(CpqCurrencyRateBo bo);
    int updateCurrencyRate(CpqCurrencyRateBo bo);
    int deleteCurrencyRate(Long rateId);
}
