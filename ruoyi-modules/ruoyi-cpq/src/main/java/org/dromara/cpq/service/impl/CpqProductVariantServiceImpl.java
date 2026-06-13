package org.dromara.cpq.service.impl;

import cn.hutool.core.util.ObjectUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.common.core.utils.MapstructUtils;
import org.dromara.cpq.domain.CpqProductVariant;
import org.dromara.cpq.domain.bo.CpqProductVariantBo;
import org.dromara.cpq.domain.vo.CpqProductVariantVo;
import org.dromara.cpq.mapper.CpqProductVariantMapper;
import org.dromara.cpq.service.ICpqProductVariantService;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class CpqProductVariantServiceImpl implements ICpqProductVariantService {

    private final CpqProductVariantMapper baseMapper;
    private final JdbcTemplate jdbcTemplate;

    @Override
    public List<CpqProductVariantVo> selectVariantListByModelId(Long modelId) {
        log.info("查询产品变体列表，modelId: {}", modelId);
        LambdaQueryWrapper<CpqProductVariant> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CpqProductVariant::getModelId, modelId)
               .eq(CpqProductVariant::getStatus, "0")
               .orderByDesc(CpqProductVariant::getIsDefault)
               .orderByAsc(CpqProductVariant::getVariantCode);
        List<CpqProductVariant> list = baseMapper.selectList(wrapper);
        return MapstructUtils.convert(list, CpqProductVariantVo.class);
    }

    @Override
    public CpqProductVariantVo selectVariantById(Long variantId) {
        log.info("查询产品变体详情，variantId: {}", variantId);
        CpqProductVariant entity = baseMapper.selectById(variantId);
        if (ObjectUtil.isNull(entity)) {
            throw new ServiceException("产品变体不存在");
        }
        return MapstructUtils.convert(entity, CpqProductVariantVo.class);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertVariant(CpqProductVariantBo bo) {
        log.info("新增产品变体，参数: {}", bo);
        CpqProductVariant entity = MapstructUtils.convert(bo, CpqProductVariant.class);
        return baseMapper.insert(entity);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updateVariant(CpqProductVariantBo bo) {
        log.info("修改产品变体，参数: {}", bo);
        CpqProductVariant entity = MapstructUtils.convert(bo, CpqProductVariant.class);
        return baseMapper.updateById(entity);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteVariant(Long variantId) {
        log.info("删除产品变体，variantId: {}", variantId);
        // 检查是否有价格手册条目引用了此变体
        Integer entryCount = jdbcTemplate.queryForObject(
            "SELECT COUNT(1) FROM cpq_price_book_entry WHERE variant_id = ? AND del_flag = '0'",
            Integer.class, variantId);
        if (entryCount != null && entryCount > 0) {
            throw new ServiceException("该变体被 " + entryCount + " 个价格条目引用，无法删除");
        }
        // 检查是否有渠道价格引用了此变体
        Integer channelCount = jdbcTemplate.queryForObject(
            "SELECT COUNT(1) FROM cpq_channel_price WHERE variant_id = ? AND del_flag = '0'",
            Integer.class, variantId);
        if (channelCount != null && channelCount > 0) {
            throw new ServiceException("该变体被 " + channelCount + " 个渠道价格引用，无法删除");
        }
        return baseMapper.deleteById(variantId);
    }

    @Override
    public List<CpqProductVariantVo> selectVariantByIds(List<Long> variantIds) {
        if (variantIds == null || variantIds.isEmpty()) return List.of();
        log.info("批量查询产品变体，ids: {}", variantIds);
        List<CpqProductVariant> list = baseMapper.selectBatchIds(variantIds);
        return MapstructUtils.convert(list, CpqProductVariantVo.class);
    }
}
