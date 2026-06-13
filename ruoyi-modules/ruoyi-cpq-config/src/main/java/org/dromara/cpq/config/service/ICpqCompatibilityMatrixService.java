package org.dromara.cpq.config.service;

import org.dromara.cpq.config.domain.CpqCompatibilityMatrix;
import org.dromara.cpq.config.domain.vo.CpqCompatibilityMatrixVo;
import org.dromara.cpq.config.domain.bo.CpqCompatibilityMatrixBo;

import java.util.List;

public interface ICpqCompatibilityMatrixService {
    List<CpqCompatibilityMatrixVo> selectList(CpqCompatibilityMatrixBo bo);
    CpqCompatibilityMatrixVo selectById(Long id);
    Boolean insert(CpqCompatibilityMatrixBo bo);
    Boolean update(CpqCompatibilityMatrixBo bo);
    Boolean delete(Long id);
}
