package org.dromara.cpq.pricing.service;

import org.dromara.cpq.pricing.domain.bo.CpqChannelPriceBo;
import org.dromara.cpq.pricing.domain.vo.CpqChannelPriceVo;

import java.util.List;

public interface ICpqChannelPriceService {
    List<CpqChannelPriceVo> selectChannelPriceList(CpqChannelPriceBo bo);
    CpqChannelPriceVo selectChannelPriceById(Long channelPriceId);
    int insertChannelPrice(CpqChannelPriceBo bo);
    int updateChannelPrice(CpqChannelPriceBo bo);
    int deleteChannelPrice(Long channelPriceId);
}
