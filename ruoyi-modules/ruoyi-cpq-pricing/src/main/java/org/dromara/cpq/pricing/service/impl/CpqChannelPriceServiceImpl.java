package org.dromara.cpq.pricing.service.impl;

import cn.hutool.core.util.ObjectUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.common.core.utils.MapstructUtils;
import org.dromara.cpq.pricing.domain.CpqChannelPrice;
import org.dromara.cpq.pricing.domain.bo.CpqChannelPriceBo;
import org.dromara.cpq.pricing.domain.vo.CpqChannelPriceVo;
import org.dromara.cpq.pricing.mapper.CpqChannelPriceMapper;
import org.dromara.cpq.pricing.service.ICpqChannelPriceService;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class CpqChannelPriceServiceImpl implements ICpqChannelPriceService {

    private final CpqChannelPriceMapper baseMapper;
    private final JdbcTemplate jdbcTemplate;

    @Override
    public List<CpqChannelPriceVo> selectChannelPriceList(CpqChannelPriceBo bo) {
        log.info("查询CPQ渠道价格列表，参数: {}", bo);
        LambdaQueryWrapper<CpqChannelPrice> wrapper = new LambdaQueryWrapper<>();
        if (ObjectUtil.isNotNull(bo.getChannelCode())) {
            wrapper.eq(CpqChannelPrice::getChannelCode, bo.getChannelCode());
        }
        if (ObjectUtil.isNotNull(bo.getModelId())) {
            wrapper.eq(CpqChannelPrice::getModelId, bo.getModelId());
        }
        if (ObjectUtil.isNotNull(bo.getStatus())) {
            wrapper.eq(CpqChannelPrice::getStatus, bo.getStatus());
        }
        wrapper.orderByDesc(CpqChannelPrice::getCreateTime);
        List<CpqChannelPrice> list = baseMapper.selectList(wrapper);
        List<CpqChannelPriceVo> voList = MapstructUtils.convert(list, CpqChannelPriceVo.class);
        enrichVariantInfo(voList);
        return voList;
    }

    @Override
    public CpqChannelPriceVo selectChannelPriceById(Long channelPriceId) {
        log.info("查询CPQ渠道价格详情，ID: {}", channelPriceId);
        CpqChannelPrice price = baseMapper.selectById(channelPriceId);
        if (ObjectUtil.isNull(price)) {
            throw new ServiceException("渠道价格不存在");
        }
        CpqChannelPriceVo vo = MapstructUtils.convert(price, CpqChannelPriceVo.class);
        if (ObjectUtil.isNotNull(price.getVariantId())) {
            enrichSingleVariant(vo, price.getVariantId());
        }
        return vo;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertChannelPrice(CpqChannelPriceBo bo) {
        log.info("新增CPQ渠道价格，参数: {}", bo);
        CpqChannelPrice price = MapstructUtils.convert(bo, CpqChannelPrice.class);
        return baseMapper.insert(price);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updateChannelPrice(CpqChannelPriceBo bo) {
        log.info("修改CPQ渠道价格，参数: {}", bo);
        CpqChannelPrice price = MapstructUtils.convert(bo, CpqChannelPrice.class);
        return baseMapper.updateById(price);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteChannelPrice(Long channelPriceId) {
        log.info("删除CPQ渠道价格，ID: {}", channelPriceId);
        return baseMapper.deleteById(channelPriceId);
    }

    /** 批量 enrichment 变体编码/名称 */
    private void enrichVariantInfo(List<CpqChannelPriceVo> voList) {
        List<Long> variantIds = voList.stream()
            .map(CpqChannelPriceVo::getVariantId)
            .filter(ObjectUtil::isNotNull)
            .distinct()
            .collect(Collectors.toList());
        if (variantIds.isEmpty()) return;

        String inClause = variantIds.stream().map(String::valueOf).collect(Collectors.joining(","));
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(
            "SELECT variant_id, variant_code, variant_name FROM cpq_product_variant WHERE variant_id IN (" + inClause + ") AND del_flag = '0'");
        Map<Long, String[]> variantMap = rows.stream().collect(Collectors.toMap(
            r -> ((Number) r.get("variant_id")).longValue(),
            r -> new String[]{(String) r.get("variant_code"), (String) r.get("variant_name")},
            (a, b) -> a));

        for (CpqChannelPriceVo vo : voList) {
            if (vo.getVariantId() != null) {
                String[] info = variantMap.get(vo.getVariantId());
                if (info != null) {
                    vo.setVariantCode(info[0]);
                    vo.setVariantName(info[1]);
                }
            }
        }
    }

    private void enrichSingleVariant(CpqChannelPriceVo vo, Long variantId) {
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(
            "SELECT variant_code, variant_name FROM cpq_product_variant WHERE variant_id = ? AND del_flag = '0'", variantId);
        if (!rows.isEmpty()) {
            vo.setVariantCode((String) rows.get(0).get("variant_code"));
            vo.setVariantName((String) rows.get(0).get("variant_name"));
        }
    }
}
