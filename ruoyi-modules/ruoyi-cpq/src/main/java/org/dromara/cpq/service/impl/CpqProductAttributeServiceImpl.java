package org.dromara.cpq.service.impl;

import cn.hutool.core.util.ObjectUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.common.core.utils.MapstructUtils;
import org.dromara.cpq.domain.CpqProductAttribute;
import org.dromara.cpq.domain.bo.CpqProductAttributeBo;
import org.dromara.cpq.domain.vo.CpqProductAttributeVo;
import org.dromara.cpq.mapper.CpqProductAttributeMapper;
import org.dromara.cpq.service.ICpqProductAttributeService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * CPQ 产品属性 Service 实现
 *
 * @author CPQ Team
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CpqProductAttributeServiceImpl implements ICpqProductAttributeService {

    private final CpqProductAttributeMapper baseMapper;

    @Override
    public List<CpqProductAttributeVo> selectAttributeList(CpqProductAttributeBo bo) {
        log.info("查询CPQ产品属性列表，参数: {}", bo);
        LambdaQueryWrapper<CpqProductAttribute> wrapper = new LambdaQueryWrapper<>();
        if (ObjectUtil.isNotNull(bo.getModelId())) {
            wrapper.eq(CpqProductAttribute::getModelId, bo.getModelId());
        }
        if (ObjectUtil.isNotNull(bo.getAttrName())) {
            wrapper.like(CpqProductAttribute::getAttrName, bo.getAttrName());
        }
        if (ObjectUtil.isNotNull(bo.getAttrCategory())) {
            wrapper.eq(CpqProductAttribute::getAttrCategory, bo.getAttrCategory());
        }
        wrapper.orderByAsc(CpqProductAttribute::getDisplayOrder).orderByAsc(CpqProductAttribute::getSortOrder);
        return MapstructUtils.convert(baseMapper.selectList(wrapper), CpqProductAttributeVo.class);
    }

    @Override
    public List<CpqProductAttributeVo> selectAttributeByModelId(Long modelId) {
        log.info("根据产品ID查询属性，modelId: {}", modelId);
        return MapstructUtils.convert(
            baseMapper.selectList(new LambdaQueryWrapper<CpqProductAttribute>()
                .eq(CpqProductAttribute::getModelId, modelId)
                .orderByAsc(CpqProductAttribute::getDisplayOrder)),
            CpqProductAttributeVo.class);
    }

    @Override
    public CpqProductAttributeVo selectAttributeById(Long attributeId) {
        log.info("查询CPQ产品属性，ID: {}", attributeId);
        CpqProductAttribute attr = baseMapper.selectById(attributeId);
        if (ObjectUtil.isNull(attr)) {
            throw new ServiceException("产品属性不存在");
        }
        return MapstructUtils.convert(attr, CpqProductAttributeVo.class);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertAttribute(CpqProductAttributeBo bo) {
        log.info("新增CPQ产品属性，参数: {}", bo);
        return baseMapper.insert(MapstructUtils.convert(bo, CpqProductAttribute.class));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updateAttribute(CpqProductAttributeBo bo) {
        log.info("修改CPQ产品属性，参数: {}", bo);
        return baseMapper.updateById(MapstructUtils.convert(bo, CpqProductAttribute.class));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteAttribute(Long attributeId) {
        log.info("删除CPQ产品属性，ID: {}", attributeId);
        return baseMapper.deleteById(attributeId);
    }

    @Override
    public List<CpqProductAttributeVo> selectAttributeByCategory(Long modelId, String attrCategory) {
        log.info("按分类查询产品属性，modelId: {}, attrCategory: {}", modelId, attrCategory);
        return MapstructUtils.convert(
            baseMapper.selectList(new LambdaQueryWrapper<CpqProductAttribute>()
                .eq(CpqProductAttribute::getModelId, modelId)
                .eq(CpqProductAttribute::getAttrCategory, attrCategory)
                .orderByAsc(CpqProductAttribute::getDisplayOrder)),
            CpqProductAttributeVo.class);
    }
}
