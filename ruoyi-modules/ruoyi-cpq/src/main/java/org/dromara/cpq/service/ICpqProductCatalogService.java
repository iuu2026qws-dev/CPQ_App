package org.dromara.cpq.service;

import org.dromara.cpq.domain.bo.CpqProductCatalogBo;
import org.dromara.cpq.domain.vo.CpqProductCatalogVo;

import java.util.List;

/**
 * CPQ 产品目录 Service 接口
 *
 * @author CPQ Team
 */
public interface ICpqProductCatalogService {

    List<CpqProductCatalogVo> selectCatalogList(CpqProductCatalogBo bo);

    CpqProductCatalogVo selectCatalogById(Long catalogId);

    int insertCatalog(CpqProductCatalogBo bo);

    int updateCatalog(CpqProductCatalogBo bo);

    int deleteCatalog(Long catalogId);

    boolean checkCatalogNameUnique(CpqProductCatalogBo bo);
}
