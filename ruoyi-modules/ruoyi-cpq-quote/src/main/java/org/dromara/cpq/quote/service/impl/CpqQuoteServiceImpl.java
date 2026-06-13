package org.dromara.cpq.quote.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.date.DateUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.utils.StringUtils;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.cpq.quote.domain.CpqQuote;
import org.dromara.cpq.quote.domain.bo.CpqQuoteBo;
import org.dromara.cpq.quote.domain.vo.CpqQuoteVo;
import org.dromara.cpq.quote.mapper.CpqQuoteLineItemMapper;
import org.dromara.cpq.quote.mapper.CpqQuoteMapper;
import org.dromara.cpq.quote.service.ICpqQuoteService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

@Slf4j
@RequiredArgsConstructor
@Service
public class CpqQuoteServiceImpl extends ServiceImpl<CpqQuoteMapper, CpqQuote> implements ICpqQuoteService {

    private final AtomicInteger sequence = new AtomicInteger(1);
    private final CpqQuoteLineItemMapper lineItemMapper;

    @Override
    public CpqQuoteVo selectById(Long id) {
        log.info("查询报价单: id={}", id);
        return BeanUtil.toBean(getById(id), CpqQuoteVo.class);
    }

    @Override
    public List<CpqQuoteVo> selectList(CpqQuoteBo bo) {
        LambdaQueryWrapper<CpqQuote> qw = buildQuery(bo);
        return BeanUtil.copyToList(list(qw), CpqQuoteVo.class);
    }

    @Override
    public TableDataInfo<CpqQuoteVo> selectPageList(CpqQuoteBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<CpqQuote> qw = buildQuery(bo);
        return TableDataInfo.build(BeanUtil.copyToList(page(pageQuery.build(), qw).getRecords(), CpqQuoteVo.class));
    }

    @Override
    public List<CpqQuoteVo> selectActiveByItemCode(String itemCode) {
        log.info("按产品编码查询活跃报价单: itemCode={}", itemCode);
        List<Long> quoteIds = lineItemMapper.selectQuoteIdsByItemCode(itemCode);
        if (CollUtil.isEmpty(quoteIds)) return Collections.emptyList();
        List<CpqQuote> quotes = list(new LambdaQueryWrapper<CpqQuote>()
            .in(CpqQuote::getQuoteId, quoteIds)
            .notIn(CpqQuote::getStatus, "CLOSED", "CANCELLED"));
        return BeanUtil.copyToList(quotes, CpqQuoteVo.class);
    }

    @Override
    public List<CpqQuoteVo> selectActiveBySbomLineId(Long sbomLineId) {
        log.info("按SBOM行ID查询活跃报价单: sbomLineId={}", sbomLineId);
        List<Long> quoteIds = lineItemMapper.selectQuoteIdsBySbomLineId(sbomLineId);
        if (CollUtil.isEmpty(quoteIds)) return Collections.emptyList();
        List<CpqQuote> quotes = list(new LambdaQueryWrapper<CpqQuote>()
            .in(CpqQuote::getQuoteId, quoteIds)
            .notIn(CpqQuote::getStatus, "CLOSED", "CANCELLED"));
        return BeanUtil.copyToList(quotes, CpqQuoteVo.class);
    }

    @Override
    public List<CpqQuoteVo> selectByStatus(String status) {
        log.info("按状态查询报价单: status={}", status);
        List<CpqQuote> quotes = list(new LambdaQueryWrapper<CpqQuote>()
            .eq(CpqQuote::getStatus, status));
        return BeanUtil.copyToList(quotes, CpqQuoteVo.class);
    }

    @Override
    @Transactional
    public int batchUpdateStatus(List<Long> quoteIds, String newStatus) {
        log.info("批量更新报价单状态: quoteIds={}, newStatus={}", quoteIds, newStatus);
        if (CollUtil.isEmpty(quoteIds)) return 0;
        boolean ok = update(new LambdaUpdateWrapper<CpqQuote>()
            .set(CpqQuote::getStatus, newStatus)
            .in(CpqQuote::getQuoteId, quoteIds));
        return ok ? quoteIds.size() : 0;
    }

    private LambdaQueryWrapper<CpqQuote> buildQuery(CpqQuoteBo bo) {
        LambdaQueryWrapper<CpqQuote> qw = new LambdaQueryWrapper<>();
        qw.eq(StringUtils.isNotBlank(bo.getQuoteNumber()), CpqQuote::getQuoteNumber, bo.getQuoteNumber());
        qw.eq(bo.getAccountId() != null, CpqQuote::getAccountId, bo.getAccountId());
        qw.eq(StringUtils.isNotBlank(bo.getStatus()), CpqQuote::getStatus, bo.getStatus());
        qw.eq(StringUtils.isNotBlank(bo.getQuoteType()), CpqQuote::getQuoteType, bo.getQuoteType());
        qw.orderByDesc(CpqQuote::getCreateTime);
        return qw;
    }

    @Override
    @Transactional
    public int insert(CpqQuoteBo bo) {
        log.info("新增报价单: {}", bo);
        CpqQuote entity = BeanUtil.toBean(bo, CpqQuote.class);
        if (StringUtils.isBlank(entity.getQuoteNumber())) {
            entity.setQuoteNumber(generateQuoteNumber());
        }
        if (StringUtils.isBlank(entity.getStatus())) {
            entity.setStatus("DRAFT");
        }
        return save(entity) ? 1 : 0;
    }

    private String generateQuoteNumber() {
        String datePart = DateUtil.format(DateUtil.date(), "yyyyMMdd");
        int seq = sequence.getAndIncrement();
        return String.format("QTE-%s-%04d", datePart, seq % 10000);
    }

    @Override
    @Transactional
    public int update(CpqQuoteBo bo) {
        log.info("修改报价单: {}", bo);
        CpqQuote entity = BeanUtil.toBean(bo, CpqQuote.class);
        return updateById(entity) ? 1 : 0;
    }

    @Override
    @Transactional
    public int deleteById(Long id) {
        log.info("删除报价单: id={}", id);
        return removeById(id) ? 1 : 0;
    }

    @Override
    @Transactional
    public int deleteByIds(Long[] ids) {
        log.info("批量删除报价单: ids={}", Arrays.toString(ids));
        return removeByIds(Arrays.asList(ids)) ? 1 : 0;
    }
}
