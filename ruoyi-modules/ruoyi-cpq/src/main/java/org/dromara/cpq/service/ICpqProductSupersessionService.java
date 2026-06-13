package org.dromara.cpq.service;

import org.dromara.cpq.domain.bo.CpqProductSupersessionBo;
import org.dromara.cpq.domain.vo.CpqProductSupersessionVo;

import java.util.List;

/**
 * CPQ 产品替代关系 Service 接口
 *
 * @author CPQ Team
 */
public interface ICpqProductSupersessionService {

    List<CpqProductSupersessionVo> selectSupersessionList(CpqProductSupersessionBo bo);

    CpqProductSupersessionVo selectSupersessionById(Long supersessionId);

    int insertSupersession(CpqProductSupersessionBo bo);

    int updateSupersession(CpqProductSupersessionBo bo);

    int deleteSupersession(Long supersessionId);

    /**
     * where-used 查询：查找指定产品的所有替代关系（作为被替代产品或替代产品）
     *
     * @param modelId 产品ID
     * @return 包含该产品的所有替代关系（含产品名称）
     */
    List<CpqProductSupersessionVo> whereUsed(Long modelId);

    /**
     * 推荐替代品：查找指定产品当前生效的替代品，按优先级排序
     *
     * @param modelId 产品ID
     * @return 推荐替代品列表（含有效期、价格影响百分比、替代类型）
     */
    List<CpqProductSupersessionVo> recommendReplacement(Long modelId);
}
