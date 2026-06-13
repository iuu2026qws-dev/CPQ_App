package org.dromara.cpq.config.service;

import org.dromara.cpq.config.domain.CpqVariantBom;
import org.dromara.cpq.config.domain.vo.CpqVariantBomVo;
import org.dromara.cpq.config.domain.bo.CpqVariantBomBo;

import java.util.List;

public interface ICpqVariantBomService {
    List<CpqVariantBomVo> selectList(CpqVariantBomBo bo);
    CpqVariantBomVo selectById(Long id);
    Boolean insert(CpqVariantBomBo bo);
    Boolean update(CpqVariantBomBo bo);
    Boolean delete(Long id);
}
