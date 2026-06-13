package org.dromara.cpq.pricing.service.impl;

import cn.hutool.core.util.ObjectUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.common.core.utils.MapstructUtils;
import org.dromara.cpq.pricing.domain.CpqPriceBookEntry;
import org.dromara.cpq.pricing.domain.CpqPriceBook;
import org.dromara.cpq.pricing.domain.bo.CpqPriceBookEntryBo;
import org.dromara.cpq.pricing.domain.vo.CpqPriceBookEntryVo;
import org.dromara.cpq.pricing.mapper.CpqPriceBookEntryMapper;
import org.dromara.cpq.pricing.mapper.CpqPriceBookMapper;
import org.dromara.cpq.pricing.service.ICpqPriceBookEntryService;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class CpqPriceBookEntryServiceImpl implements ICpqPriceBookEntryService {

    private final CpqPriceBookEntryMapper baseMapper;
    private final CpqPriceBookMapper priceBookMapper;
    private final JdbcTemplate jdbcTemplate;

    @Override
    public List<CpqPriceBookEntryVo> selectEntryList(CpqPriceBookEntryBo bo) {
        log.info("查询价格手册条目列表，参数: {}", bo);
        LambdaQueryWrapper<CpqPriceBookEntry> wrapper = new LambdaQueryWrapper<>();
        if (ObjectUtil.isNotNull(bo.getPriceBookId())) {
            wrapper.eq(CpqPriceBookEntry::getPriceBookId, bo.getPriceBookId());
        }
        if (ObjectUtil.isNotNull(bo.getModelId())) {
            wrapper.eq(CpqPriceBookEntry::getModelId, bo.getModelId());
        }
        if (ObjectUtil.isNotNull(bo.getStatus())) {
            wrapper.eq(CpqPriceBookEntry::getStatus, bo.getStatus());
        }
        wrapper.orderByDesc(CpqPriceBookEntry::getCreateTime);
        List<CpqPriceBookEntry> list = baseMapper.selectList(wrapper);
        List<CpqPriceBookEntryVo> voList = MapstructUtils.convert(list, CpqPriceBookEntryVo.class);
        enrichBookName(voList);
        enrichVariantInfo(voList);
        return voList;
    }

    @Override
    public CpqPriceBookEntryVo selectEntryById(Long entryId) {
        log.info("查询价格手册条目详情，ID: {}", entryId);
        CpqPriceBookEntry entry = baseMapper.selectById(entryId);
        if (ObjectUtil.isNull(entry)) {
            throw new ServiceException("价格手册条目不存在");
        }
        CpqPriceBookEntryVo vo = MapstructUtils.convert(entry, CpqPriceBookEntryVo.class);
        if (ObjectUtil.isNotNull(entry.getPriceBookId())) {
            CpqPriceBook book = priceBookMapper.selectById(entry.getPriceBookId());
            if (ObjectUtil.isNotNull(book)) {
                vo.setBookName(book.getBookName());
            }
        }
        if (ObjectUtil.isNotNull(entry.getVariantId())) {
            enrichSingleVariant(vo, entry.getVariantId());
        }
        return vo;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertEntry(CpqPriceBookEntryBo bo) {
        log.info("新增价格手册条目，参数: {}", bo);
        CpqPriceBookEntry entry = MapstructUtils.convert(bo, CpqPriceBookEntry.class);
        return baseMapper.insert(entry);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updateEntry(CpqPriceBookEntryBo bo) {
        log.info("修改价格手册条目，参数: {}", bo);
        CpqPriceBookEntry entry = MapstructUtils.convert(bo, CpqPriceBookEntry.class);
        return baseMapper.updateById(entry);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteEntry(Long entryId) {
        log.info("删除价格手册条目，ID: {}", entryId);
        return baseMapper.deleteById(entryId);
    }

    private void enrichBookName(List<CpqPriceBookEntryVo> voList) {
        Map<Long, String> nameMap = priceBookMapper.selectList(null).stream()
            .collect(Collectors.toMap(CpqPriceBook::getPriceBookId, CpqPriceBook::getBookName, (a, b) -> a));
        for (CpqPriceBookEntryVo vo : voList) {
            if (ObjectUtil.isNotNull(vo.getPriceBookId())) {
                vo.setBookName(nameMap.get(vo.getPriceBookId()));
            }
        }
    }

    /** 批量 enrichment 变体编码/名称 */
    private void enrichVariantInfo(List<CpqPriceBookEntryVo> voList) {
        List<Long> variantIds = voList.stream()
            .map(CpqPriceBookEntryVo::getVariantId)
            .filter(ObjectUtil::isNotNull)
            .distinct()
            .collect(Collectors.toList());
        if (variantIds.isEmpty()) return;

        // 从 cpq_product_variant 表批量查询
        String inClause = variantIds.stream().map(String::valueOf).collect(Collectors.joining(","));
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(
            "SELECT variant_id, variant_code, variant_name FROM cpq_product_variant WHERE variant_id IN (" + inClause + ") AND del_flag = '0'");
        Map<Long, String[]> variantMap = rows.stream().collect(Collectors.toMap(
            r -> ((Number) r.get("variant_id")).longValue(),
            r -> new String[]{(String) r.get("variant_code"), (String) r.get("variant_name")},
            (a, b) -> a));

        for (CpqPriceBookEntryVo vo : voList) {
            if (vo.getVariantId() != null) {
                String[] info = variantMap.get(vo.getVariantId());
                if (info != null) {
                    vo.setVariantCode(info[0]);
                    vo.setVariantName(info[1]);
                }
            }
        }
    }

    private void enrichSingleVariant(CpqPriceBookEntryVo vo, Long variantId) {
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(
            "SELECT variant_code, variant_name FROM cpq_product_variant WHERE variant_id = ? AND del_flag = '0'", variantId);
        if (!rows.isEmpty()) {
            vo.setVariantCode((String) rows.get(0).get("variant_code"));
            vo.setVariantName((String) rows.get(0).get("variant_name"));
        }
    }
}
