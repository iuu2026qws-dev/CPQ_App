package org.dromara.cpq.quote.service.impl;

import cn.hutool.core.bean.BeanUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.utils.StringUtils;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.cpq.quote.domain.CpqQuoteLineItem;
import org.dromara.cpq.quote.domain.bo.CpqQuoteLineItemBo;
import org.dromara.cpq.quote.domain.vo.CpqQuoteLineItemVo;
import org.dromara.cpq.quote.mapper.CpqQuoteLineItemMapper;
import org.dromara.cpq.quote.service.ICpqQuoteLineItemService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Service
public class CpqQuoteLineItemServiceImpl extends ServiceImpl<CpqQuoteLineItemMapper, CpqQuoteLineItem> implements ICpqQuoteLineItemService {

    @Override public CpqQuoteLineItemVo selectById(Long id) { return BeanUtil.toBean(getById(id), CpqQuoteLineItemVo.class); }

    @Override public List<CpqQuoteLineItemVo> selectList(CpqQuoteLineItemBo bo) {
        LambdaQueryWrapper<CpqQuoteLineItem> qw = new LambdaQueryWrapper<>();
        qw.eq(bo.getQuoteId() != null, CpqQuoteLineItem::getQuoteId, bo.getQuoteId());
        qw.eq(StringUtils.isNotBlank(bo.getItemType()), CpqQuoteLineItem::getItemType, bo.getItemType());
        qw.orderByAsc(CpqQuoteLineItem::getLineNumber);
        return BeanUtil.copyToList(list(qw), CpqQuoteLineItemVo.class);
    }

    @Override public TableDataInfo<CpqQuoteLineItemVo> selectPageList(CpqQuoteLineItemBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<CpqQuoteLineItem> qw = new LambdaQueryWrapper<>();
        qw.eq(bo.getQuoteId() != null, CpqQuoteLineItem::getQuoteId, bo.getQuoteId());
        return TableDataInfo.build(BeanUtil.copyToList(page(pageQuery.build(), qw).getRecords(), CpqQuoteLineItemVo.class));
    }

    @Override @Transactional public int insert(CpqQuoteLineItemBo bo) {
        CpqQuoteLineItem entity = BeanUtil.toBean(bo, CpqQuoteLineItem.class);
        // 自动生成行号：查所有行（含软删除）取MAX+1，确保行号永不重复（审计追溯需求）
        if (entity.getLineNumber() == null && entity.getQuoteId() != null) {
            int maxLine = baseMapper.selectMaxLineNumber(entity.getQuoteId());
            entity.setLineNumber(maxLine + 1);
        }
        if (entity.getLineNumber() == null) {
            entity.setLineNumber(1);
        }
        // 默认单位
        if (StringUtils.isBlank(entity.getUnit())) {
            entity.setUnit("PCS");
        }
        return save(entity) ? 1 : 0;
    }
    @Override @Transactional public int update(CpqQuoteLineItemBo bo) { return updateById(BeanUtil.toBean(bo, CpqQuoteLineItem.class)) ? 1 : 0; }
    @Override @Transactional public int deleteById(Long id) { return removeById(id) ? 1 : 0; }
    @Override @Transactional public int deleteByIds(Long[] ids) { return removeByIds(Arrays.asList(ids)) ? 1 : 0; }
}
