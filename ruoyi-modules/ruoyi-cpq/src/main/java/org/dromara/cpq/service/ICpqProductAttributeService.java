package org.dromara.cpq.service;

import org.dromara.cpq.domain.bo.CpqProductAttributeBo;
import org.dromara.cpq.domain.vo.CpqProductAttributeVo;

import java.util.List;

/**
 * CPQ 产品属性 Service 接口
 *
 * @author CPQ Team
 */
public interface ICpqProductAttributeService {

    List<CpqProductAttributeVo> selectAttributeList(CpqProductAttributeBo bo);

    List<CpqProductAttributeVo> selectAttributeByModelId(Long modelId);

    CpqProductAttributeVo selectAttributeById(Long attributeId);

    int insertAttribute(CpqProductAttributeBo bo);

    int updateAttribute(CpqProductAttributeBo bo);

    int deleteAttribute(Long attributeId);

    /**
     * 按分类查询属性（用于属性模板/属性集分组）
     */
    List<CpqProductAttributeVo> selectAttributeByCategory(Long modelId, String attrCategory);
}
