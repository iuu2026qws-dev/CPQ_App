package org.dromara.cpq.config.service;

import org.dromara.cpq.config.domain.CpqAttributeOption;
import org.dromara.cpq.config.domain.vo.CpqAttributeOptionVo;
import org.dromara.cpq.config.domain.bo.CpqAttributeOptionBo;

import java.util.List;

public interface ICpqAttributeOptionService {
    List<CpqAttributeOptionVo> selectList(CpqAttributeOptionBo bo);
    CpqAttributeOptionVo selectById(Long id);
    Boolean insert(CpqAttributeOptionBo bo);
    Boolean update(CpqAttributeOptionBo bo);
    Boolean delete(Long id);
}
