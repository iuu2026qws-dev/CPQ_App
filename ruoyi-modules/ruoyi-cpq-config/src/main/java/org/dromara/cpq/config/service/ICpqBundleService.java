package org.dromara.cpq.config.service;

import org.dromara.cpq.config.domain.CpqBundle;
import org.dromara.cpq.config.domain.vo.CpqBundleVo;
import org.dromara.cpq.config.domain.bo.CpqBundleBo;

import java.util.List;

public interface ICpqBundleService {
    List<CpqBundleVo> selectList(CpqBundleBo bo);
    CpqBundleVo selectById(Long id);
    Boolean insert(CpqBundleBo bo);
    Boolean update(CpqBundleBo bo);
    Boolean delete(Long id);
}
