package org.dromara.cpq.service.impl;

import cn.hutool.core.util.ObjectUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.common.core.utils.MapstructUtils;
import org.dromara.cpq.domain.CpqProductCategory;
import org.dromara.cpq.domain.bo.CpqProductCategoryBo;
import org.dromara.cpq.domain.vo.CpqProductCategoryVo;
import org.dromara.cpq.mapper.CpqProductCategoryMapper;
import org.dromara.cpq.service.ICpqProductCategoryService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * CPQ 产品分类 Service 实现
 *
 * @author CPQ Team
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CpqProductCategoryServiceImpl implements ICpqProductCategoryService {

    private final CpqProductCategoryMapper baseMapper;

    @Override
    public List<CpqProductCategoryVo> selectCategoryList(CpqProductCategoryBo bo) {
        log.info("查询CPQ产品分类列表，参数: {}", bo);
        LambdaQueryWrapper<CpqProductCategory> wrapper = new LambdaQueryWrapper<>();
        if (ObjectUtil.isNotNull(bo.getCategoryName())) {
            wrapper.like(CpqProductCategory::getCategoryName, bo.getCategoryName());
        }
        if (ObjectUtil.isNotNull(bo.getCategoryCode())) {
            wrapper.like(CpqProductCategory::getCategoryCode, bo.getCategoryCode());
        }
        if (ObjectUtil.isNotNull(bo.getCategoryLevel())) {
            wrapper.eq(CpqProductCategory::getCategoryLevel, bo.getCategoryLevel());
        }
        if (ObjectUtil.isNotNull(bo.getStatus())) {
            wrapper.eq(CpqProductCategory::getStatus, bo.getStatus());
        }
        wrapper.orderByAsc(CpqProductCategory::getCategoryLevel)
               .orderByAsc(CpqProductCategory::getSortOrder)
               .orderByAsc(CpqProductCategory::getCategoryId);
        List<CpqProductCategory> list = baseMapper.selectList(wrapper);
        List<CpqProductCategoryVo> voList = MapstructUtils.convert(list, CpqProductCategoryVo.class);

        // enrich parentCategoryName
        enrichParentName(voList, list);

        return voList;
    }

    @Override
    public List<CpqProductCategoryVo> selectCategoryTree(CpqProductCategoryBo bo) {
        long start = System.currentTimeMillis();
        log.info("查询CPQ产品分类树，参数: {}", bo);
        List<CpqProductCategoryVo> allList = selectCategoryList(bo);
        List<CpqProductCategoryVo> tree = buildTree(allList);
        log.info("产品分类树构建完成，根节点数: {}, 耗时: {}ms", tree.size(), System.currentTimeMillis() - start);
        return tree;
    }

    @Override
    public CpqProductCategoryVo selectCategoryById(Long categoryId) {
        log.info("查询CPQ产品分类，ID: {}", categoryId);
        CpqProductCategory category = baseMapper.selectById(categoryId);
        if (ObjectUtil.isNull(category)) {
            throw new ServiceException("产品分类不存在");
        }
        CpqProductCategoryVo vo = MapstructUtils.convert(category, CpqProductCategoryVo.class);

        // enrich parent name
        if (ObjectUtil.isNotNull(category.getParentCategoryId())) {
            CpqProductCategory parent = baseMapper.selectById(category.getParentCategoryId());
            if (ObjectUtil.isNotNull(parent)) {
                vo.setParentCategoryName(parent.getCategoryName());
            }
        }

        return vo;
    }

    @Override
    public List<CpqProductCategoryVo> selectCategoryByLevel(Integer categoryLevel) {
        log.info("按层级查询CPQ产品分类，层级: {}", categoryLevel);
        LambdaQueryWrapper<CpqProductCategory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CpqProductCategory::getCategoryLevel, categoryLevel)
               .orderByAsc(CpqProductCategory::getSortOrder);
        List<CpqProductCategory> list = baseMapper.selectList(wrapper);
        return MapstructUtils.convert(list, CpqProductCategoryVo.class);
    }

    @Override
    public List<CpqProductCategoryVo> selectCategoryByParentId(Long parentCategoryId) {
        log.info("按父分类查询子分类，parentId: {}", parentCategoryId);
        LambdaQueryWrapper<CpqProductCategory> wrapper = new LambdaQueryWrapper<>();
        if (ObjectUtil.isNull(parentCategoryId)) {
            wrapper.isNull(CpqProductCategory::getParentCategoryId);
        } else {
            wrapper.eq(CpqProductCategory::getParentCategoryId, parentCategoryId);
        }
        wrapper.orderByAsc(CpqProductCategory::getSortOrder);
        List<CpqProductCategory> list = baseMapper.selectList(wrapper);
        return MapstructUtils.convert(list, CpqProductCategoryVo.class);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertCategory(CpqProductCategoryBo bo) {
        log.info("新增CPQ产品分类，参数: {}", bo);
        if (!checkCategoryCodeUnique(bo)) {
            throw new ServiceException("产品分类编码已存在");
        }
        // 产品族（level=1）分类没有父节点
        if (ObjectUtil.equal(bo.getCategoryLevel(), 1)) {
            bo.setParentCategoryId(null);
        }
        CpqProductCategory category = MapstructUtils.convert(bo, CpqProductCategory.class);
        return baseMapper.insert(category);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updateCategory(CpqProductCategoryBo bo) {
        log.info("修改CPQ产品分类，参数: {}", bo);
        if (!checkCategoryCodeUnique(bo)) {
            throw new ServiceException("产品分类编码已存在");
        }
        CpqProductCategory category = MapstructUtils.convert(bo, CpqProductCategory.class);
        return baseMapper.updateById(category);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteCategory(Long categoryId) {
        log.info("删除CPQ产品分类，ID: {}", categoryId);
        // 检查是否有子分类
        long childCount = baseMapper.selectCount(new LambdaQueryWrapper<CpqProductCategory>()
            .eq(CpqProductCategory::getParentCategoryId, categoryId));
        if (childCount > 0) {
            throw new ServiceException("该分类下存在子分类，无法删除");
        }
        return baseMapper.deleteById(categoryId);
    }

    @Override
    public boolean checkCategoryCodeUnique(CpqProductCategoryBo bo) {
        return !baseMapper.exists(new LambdaQueryWrapper<CpqProductCategory>()
            .eq(CpqProductCategory::getCategoryCode, bo.getCategoryCode())
            .ne(ObjectUtil.isNotNull(bo.getCategoryId()), CpqProductCategory::getCategoryId, bo.getCategoryId()));
    }

    /**
     * 构建分类树
     */
    private List<CpqProductCategoryVo> buildTree(List<CpqProductCategoryVo> allList) {
        Map<Long, List<CpqProductCategoryVo>> childrenMap = allList.stream()
            .filter(vo -> ObjectUtil.isNotNull(vo.getParentCategoryId()))
            .collect(Collectors.groupingBy(CpqProductCategoryVo::getParentCategoryId));

        List<CpqProductCategoryVo> roots = new ArrayList<>();
        for (CpqProductCategoryVo vo : allList) {
            if (ObjectUtil.isNull(vo.getParentCategoryId())) {
                roots.add(vo);
            }
            List<CpqProductCategoryVo> children = childrenMap.get(vo.getCategoryId());
            if (children != null) {
                vo.setChildren(children);
            }
        }
        return roots;
    }

    /**
     * 为 VO 列表 enrich 父分类名称
     */
    private void enrichParentName(List<CpqProductCategoryVo> voList, List<CpqProductCategory> entityList) {
        Map<Long, String> nameMap = entityList.stream()
            .collect(Collectors.toMap(CpqProductCategory::getCategoryId, CpqProductCategory::getCategoryName, (a, b) -> a));
        for (CpqProductCategoryVo vo : voList) {
            if (ObjectUtil.isNotNull(vo.getParentCategoryId())) {
                vo.setParentCategoryName(nameMap.get(vo.getParentCategoryId()));
            }
        }
    }
}
