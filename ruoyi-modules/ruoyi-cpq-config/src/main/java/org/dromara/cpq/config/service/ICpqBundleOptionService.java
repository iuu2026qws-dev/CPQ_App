package org.dromara.cpq.config.service;

import org.dromara.cpq.config.domain.CpqBundleOption;
import org.dromara.cpq.config.domain.vo.CpqBundleOptionVo;
import org.dromara.cpq.config.domain.bo.CpqBundleOptionBo;

import java.util.List;

public interface ICpqBundleOptionService {
    List<CpqBundleOptionVo> selectList(CpqBundleOptionBo bo);
    CpqBundleOptionVo selectById(Long id);
    Boolean insert(CpqBundleOptionBo bo);
    Boolean update(CpqBundleOptionBo bo);
    Boolean delete(Long id);
}
