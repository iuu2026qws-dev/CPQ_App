package org.dromara.cpq.service;

import org.dromara.cpq.domain.bo.CpqProductVariantBo;
import org.dromara.cpq.domain.vo.CpqProductVariantVo;

import java.util.List;

public interface ICpqProductVariantService {

    /**
     * 查询某个产品型号的所有变体列表
     */
    List<CpqProductVariantVo> selectVariantListByModelId(Long modelId);

    /**
     * 查询变体详情
     */
    CpqProductVariantVo selectVariantById(Long variantId);

    /**
     * 新增变体
     */
    int insertVariant(CpqProductVariantBo bo);

    /**
     * 修改变体
     */
    int updateVariant(CpqProductVariantBo bo);

    /**
     * 删除变体（检查是否有价格条目引用）
     */
    int deleteVariant(Long variantId);

    /**
     * 批量查询变体（按ID列表）
     */
    List<CpqProductVariantVo> selectVariantByIds(List<Long> variantIds);
}
