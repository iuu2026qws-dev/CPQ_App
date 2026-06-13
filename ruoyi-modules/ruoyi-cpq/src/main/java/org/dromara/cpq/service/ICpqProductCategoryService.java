package org.dromara.cpq.service;

import org.dromara.cpq.domain.bo.CpqProductCategoryBo;
import org.dromara.cpq.domain.vo.CpqProductCategoryVo;

import java.util.List;

/**
 * CPQ 产品分类 Service 接口
 *
 * @author CPQ Team
 */
public interface ICpqProductCategoryService {

    /**
     * 查询分类扁平列表
     */
    List<CpqProductCategoryVo> selectCategoryList(CpqProductCategoryBo bo);

    /**
     * 查询分类树形结构
     */
    List<CpqProductCategoryVo> selectCategoryTree(CpqProductCategoryBo bo);

    /**
     * 根据ID查询分类
     */
    CpqProductCategoryVo selectCategoryById(Long categoryId);

    /**
     * 按层级查询分类列表（1=产品族, 2=产品线, 3=产品系列）
     */
    List<CpqProductCategoryVo> selectCategoryByLevel(Integer categoryLevel);

    /**
     * 根据父分类ID查询子分类
     */
    List<CpqProductCategoryVo> selectCategoryByParentId(Long parentCategoryId);

    /**
     * 新增分类
     */
    int insertCategory(CpqProductCategoryBo bo);

    /**
     * 修改分类
     */
    int updateCategory(CpqProductCategoryBo bo);

    /**
     * 删除分类（有子节点的不可删除）
     */
    int deleteCategory(Long categoryId);

    /**
     * 校验分类编码唯一性
     */
    boolean checkCategoryCodeUnique(CpqProductCategoryBo bo);
}
