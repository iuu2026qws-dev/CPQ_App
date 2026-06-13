package org.dromara.cpq.pricing.service;

import org.dromara.cpq.pricing.domain.bo.CpqVolumeTierBo;
import org.dromara.cpq.pricing.domain.vo.CpqVolumeTierVo;

import java.util.List;

public interface ICpqVolumeTierService {
    List<CpqVolumeTierVo> selectVolumeTierList(CpqVolumeTierBo bo);
    CpqVolumeTierVo selectVolumeTierById(Long tierId);
    int insertVolumeTier(CpqVolumeTierBo bo);
    int updateVolumeTier(CpqVolumeTierBo bo);
    int deleteVolumeTier(Long tierId);
}
