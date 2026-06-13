package org.dromara.cpq.config.service;

import org.dromara.cpq.config.domain.CpqBundleOptionGroup;
import org.dromara.cpq.config.domain.vo.CpqBundleOptionGroupVo;
import org.dromara.cpq.config.domain.bo.CpqBundleOptionGroupBo;

import java.util.List;

public interface ICpqBundleOptionGroupService {
    List<CpqBundleOptionGroupVo> selectList(CpqBundleOptionGroupBo bo);
    CpqBundleOptionGroupVo selectById(Long id);
    Boolean insert(CpqBundleOptionGroupBo bo);
    Boolean update(CpqBundleOptionGroupBo bo);
    Boolean delete(Long id);
}
