package org.dromara.cpq.config.service;

import org.dromara.cpq.config.domain.CpqAttributeMapping;
import org.dromara.cpq.config.domain.vo.CpqAttributeMappingVo;
import org.dromara.cpq.config.domain.bo.CpqAttributeMappingBo;

import java.util.List;

public interface ICpqAttributeMappingService {
    List<CpqAttributeMappingVo> selectList(CpqAttributeMappingBo bo);
    CpqAttributeMappingVo selectById(Long id);
    Boolean insert(CpqAttributeMappingBo bo);
    Boolean update(CpqAttributeMappingBo bo);
    Boolean delete(Long id);
}
