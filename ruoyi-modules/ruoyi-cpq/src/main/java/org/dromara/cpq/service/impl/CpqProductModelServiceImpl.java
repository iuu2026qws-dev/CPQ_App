package org.dromara.cpq.service.impl;

import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.util.ObjectUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.common.core.utils.MapstructUtils;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.cpq.domain.CpqProductCatalog;
import org.dromara.cpq.domain.CpqProductModel;
import org.dromara.cpq.domain.bo.CpqProductModelBo;
import org.dromara.cpq.domain.vo.CpqProductModelVo;
import org.dromara.cpq.domain.CpqProductCategory;
import org.dromara.cpq.mapper.CpqProductCatalogMapper;
import org.dromara.cpq.mapper.CpqProductCategoryMapper;
import org.dromara.cpq.mapper.CpqProductModelMapper;
import org.dromara.cpq.service.ICpqProductModelService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * CPQ 产品模型 Service 实现
 *
 * @author CPQ Team
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CpqProductModelServiceImpl implements ICpqProductModelService {

    private final CpqProductModelMapper baseMapper;
    private final CpqProductCatalogMapper catalogMapper;
    private final CpqProductCategoryMapper categoryMapper;

    @Override
    public TableDataInfo<CpqProductModelVo> selectPageModelList(CpqProductModelBo bo, PageQuery pageQuery) {
        log.info("分页查询CPQ产品列表，参数: {}", bo);
        LambdaQueryWrapper<CpqProductModel> wrapper = buildQueryWrapper(bo);
        Page<CpqProductModelVo> voPage = baseMapper.selectVoPage(pageQuery.build(), wrapper);
        enrichCatalogNames(voPage.getRecords());
        enrichCategoryPaths(voPage.getRecords());
        return TableDataInfo.build(voPage);
    }

    @Override
    public List<CpqProductModelVo> selectModelList(CpqProductModelBo bo) {
        log.info("查询CPQ产品列表，参数: {}", bo);
        LambdaQueryWrapper<CpqProductModel> wrapper = buildQueryWrapper(bo);
        List<CpqProductModel> list = baseMapper.selectList(wrapper);
        List<CpqProductModelVo> voList = MapstructUtils.convert(list, CpqProductModelVo.class);
        enrichCatalogNames(voList);
        enrichCategoryPaths(voList);
        return voList;
    }

    @Override
    public CpqProductModelVo selectModelById(Long modelId) {
        log.info("查询CPQ产品详情，ID: {}", modelId);
        CpqProductModel model = baseMapper.selectById(modelId);
        if (ObjectUtil.isNull(model)) {
            throw new ServiceException("产品不存在");
        }
        CpqProductModelVo vo = MapstructUtils.convert(model, CpqProductModelVo.class);
        if (ObjectUtil.isNotNull(model.getCatalogId())) {
            CpqProductCatalog catalog = catalogMapper.selectById(model.getCatalogId());
            if (ObjectUtil.isNotNull(catalog)) {
                vo.setCatalogName(catalog.getCatalogName());
            }
        }
        // enrich categoryPath
        if (ObjectUtil.isNotNull(model.getCategoryId())) {
            enrichSingleCategoryPath(vo, model.getCategoryId());
        }
        return vo;
    }

    @Override
    public CpqProductModelVo selectModelByCode(String modelCode) {
        log.info("根据编码查询CPQ产品，编码: {}", modelCode);
        CpqProductModel model = baseMapper.selectOne(new LambdaQueryWrapper<CpqProductModel>()
            .eq(CpqProductModel::getModelCode, modelCode));
        if (ObjectUtil.isNull(model)) {
            return null;
        }
        return MapstructUtils.convert(model, CpqProductModelVo.class);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertModel(CpqProductModelBo bo) {
        log.info("新增CPQ产品，参数: {}", bo);
        if (!checkModelCodeUnique(bo)) {
            throw new ServiceException("产品编码已存在");
        }
        CpqProductModel model = MapstructUtils.convert(bo, CpqProductModel.class);
        return baseMapper.insert(model);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updateModel(CpqProductModelBo bo) {
        log.info("修改CPQ产品，参数: {}", bo);
        if (!checkModelCodeUnique(bo)) {
            throw new ServiceException("产品编码已存在");
        }
        CpqProductModel model = MapstructUtils.convert(bo, CpqProductModel.class);
        return baseMapper.updateById(model);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteModel(Long modelId) {
        log.info("删除CPQ产品，ID: {}", modelId);
        return baseMapper.deleteById(modelId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteModelByIds(Long[] modelIds) {
        log.info("批量删除CPQ产品，IDs: {}", Arrays.toString(modelIds));
        return baseMapper.deleteByIds(Arrays.asList(modelIds));
    }

    @Override
    public boolean checkModelCodeUnique(CpqProductModelBo bo) {
        return !baseMapper.exists(new LambdaQueryWrapper<CpqProductModel>()
            .eq(CpqProductModel::getModelCode, bo.getModelCode())
            .ne(ObjectUtil.isNotNull(bo.getModelId()), CpqProductModel::getModelId, bo.getModelId()));
    }

    @Override
    public List<CpqProductModelVo> searchModels(String keyword, String lifecycleStatus, String configType) {
        log.info("搜索CPQ产品，关键词: {}, 生命周期: {}, configType: {}", keyword, lifecycleStatus, configType);
        LambdaQueryWrapper<CpqProductModel> wrapper = new LambdaQueryWrapper<>();
        wrapper.and(ObjectUtil.isNotEmpty(keyword), w ->
            w.like(CpqProductModel::getModelName, keyword)
             .or().like(CpqProductModel::getModelCode, keyword)
             .or().like(CpqProductModel::getDescription, keyword));
        if (ObjectUtil.isNotEmpty(lifecycleStatus)) {
            wrapper.eq(CpqProductModel::getLifecycleStatus, lifecycleStatus);
        }
        if (ObjectUtil.isNotEmpty(configType)) {
            wrapper.eq(CpqProductModel::getConfigType, configType);
        }
        // 只返回有配置属性的产品（避免用户看到无可配置属性的产品）
        wrapper.inSql(CpqProductModel::getModelId,
            "SELECT DISTINCT model_id FROM cpq_attribute_option WHERE del_flag = '0'");
        wrapper.orderByDesc(CpqProductModel::getCreateTime);
        wrapper.last("LIMIT 50");
        List<CpqProductModel> list = baseMapper.selectList(wrapper);
        return MapstructUtils.convert(list, CpqProductModelVo.class);
    }

    private LambdaQueryWrapper<CpqProductModel> buildQueryWrapper(CpqProductModelBo bo) {
        LambdaQueryWrapper<CpqProductModel> wrapper = new LambdaQueryWrapper<>();
        if (ObjectUtil.isNotNull(bo.getModelName())) {
            wrapper.like(CpqProductModel::getModelName, bo.getModelName());
        }
        if (ObjectUtil.isNotNull(bo.getModelCode())) {
            wrapper.like(CpqProductModel::getModelCode, bo.getModelCode());
        }
        if (ObjectUtil.isNotNull(bo.getCatalogId())) {
            wrapper.eq(CpqProductModel::getCatalogId, bo.getCatalogId());
        }
        if (ObjectUtil.isNotNull(bo.getCategoryId())) {
            wrapper.eq(CpqProductModel::getCategoryId, bo.getCategoryId());
        }
        if (ObjectUtil.isNotNull(bo.getStatus())) {
            wrapper.eq(CpqProductModel::getStatus, bo.getStatus());
        }
        if (ObjectUtil.isNotNull(bo.getLifecycleStatus())) {
            wrapper.eq(CpqProductModel::getLifecycleStatus, bo.getLifecycleStatus());
        }
        wrapper.orderByDesc(CpqProductModel::getCreateTime);
        return wrapper;
    }

    private void enrichCatalogNames(List<CpqProductModelVo> voList) {
        if (CollUtil.isEmpty(voList)) {
            return;
        }
        List<Long> catalogIds = voList.stream()
            .map(CpqProductModelVo::getCatalogId)
            .filter(ObjectUtil::isNotNull)
            .distinct()
            .collect(Collectors.toList());
        if (CollUtil.isNotEmpty(catalogIds)) {
            List<CpqProductCatalog> catalogs = catalogMapper.selectBatchIds(catalogIds);
            Map<Long, String> nameMap = catalogs.stream()
                .collect(Collectors.toMap(CpqProductCatalog::getCatalogId, CpqProductCatalog::getCatalogName));
            voList.forEach(vo -> {
                if (ObjectUtil.isNotNull(vo.getCatalogId())) {
                    vo.setCatalogName(nameMap.get(vo.getCatalogId()));
                }
            });
        }
    }

    /**
     * 批量 enrich 分类路径（L1 > L2 > L3）
     */
    private void enrichCategoryPaths(List<CpqProductModelVo> voList) {
        if (CollUtil.isEmpty(voList)) {
            return;
        }
        long start = System.currentTimeMillis();
        List<Long> categoryIds = voList.stream()
            .map(CpqProductModelVo::getCategoryId)
            .filter(ObjectUtil::isNotNull)
            .distinct()
            .collect(Collectors.toList());
        if (CollUtil.isEmpty(categoryIds)) {
            return;
        }
        // 预加载所有分类
        List<CpqProductCategory> allCategories = categoryMapper.selectBatchIds(categoryIds);
        // 预加载所有父分类（向上递归最多2层）
        List<Long> parentIds = allCategories.stream()
            .map(CpqProductCategory::getParentCategoryId)
            .filter(ObjectUtil::isNotNull)
            .distinct()
            .collect(Collectors.toList());
        List<CpqProductCategory> parentCategories = CollUtil.isNotEmpty(parentIds)
            ? categoryMapper.selectBatchIds(parentIds)
            : List.of();

        Map<Long, String> nameMap = allCategories.stream()
            .collect(Collectors.toMap(CpqProductCategory::getCategoryId, CpqProductCategory::getCategoryName, (a, b) -> a));
        parentCategories.forEach(p -> nameMap.putIfAbsent(p.getCategoryId(), p.getCategoryName()));

        for (CpqProductModelVo vo : voList) {
            if (ObjectUtil.isNotNull(vo.getCategoryId())) {
                enrichSingleCategoryPath(vo, vo.getCategoryId());
            }
        }
        log.info("分类路径批量enrich完成，处理{}条，耗时{}ms", categoryIds.size(), System.currentTimeMillis() - start);
    }

    /**
     * 为单个VO set categoryPath（L1 > L2 > L3）
     */
    private void enrichSingleCategoryPath(CpqProductModelVo vo, Long categoryId) {
        CpqProductCategory category = categoryMapper.selectById(categoryId);
        if (ObjectUtil.isNull(category)) {
            return;
        }
        StringBuilder path = new StringBuilder(category.getCategoryName());
        // 向上查找父分类，最多2层（L3 → L2 → L1）
        Long parentId = category.getParentCategoryId();
        for (int i = 0; i < 2 && ObjectUtil.isNotNull(parentId); i++) {
            CpqProductCategory parent = categoryMapper.selectById(parentId);
            if (ObjectUtil.isNull(parent)) {
                break;
            }
            path.insert(0, parent.getCategoryName() + " > ");
            parentId = parent.getParentCategoryId();
        }
        vo.setCategoryPath(path.toString());
    }
}
