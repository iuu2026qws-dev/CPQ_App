package org.dromara.cpq.crm.service.impl;

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
import org.dromara.common.mybatis.utils.IdGeneratorUtil;
import org.dromara.cpq.crm.domain.CpqCrmOrder;
import org.dromara.cpq.crm.domain.CpqCrmOrderLine;
import org.dromara.cpq.crm.domain.bo.CpqCrmOrderBo;
import org.dromara.cpq.crm.domain.vo.CpqCrmOrderLineVo;
import org.dromara.cpq.crm.domain.vo.CpqCrmOrderVo;
import org.dromara.cpq.crm.mapper.CpqCrmOrderLineMapper;
import org.dromara.cpq.crm.mapper.CpqCrmOrderMapper;
import org.dromara.cpq.crm.service.ICpqCrmOrderService;
import org.dromara.cpq.quote.domain.CpqQuote;
import org.dromara.cpq.quote.domain.CpqQuoteLineItem;
import org.dromara.cpq.quote.mapper.CpqQuoteLineItemMapper;
import org.dromara.cpq.quote.mapper.CpqQuoteMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.*;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * 订单 Service 实现
 *
 * @author CPQ Team
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class CpqCrmOrderServiceImpl extends ServiceImpl<CpqCrmOrderMapper, CpqCrmOrder>
        implements ICpqCrmOrderService {

    private final CpqCrmOrderLineMapper orderLineMapper;
    private final CpqQuoteMapper quoteMapper;
    private final CpqQuoteLineItemMapper quoteLineItemMapper;

    private final AtomicInteger codeSeq = new AtomicInteger(1);

    /** 订单状态流转顺序 */
    private static final List<String> STATUS_ORDER = Arrays.asList(
        "DRAFT", "PENDING_APPROVAL", "APPROVED", "IN_PRODUCTION", "IN_DELIVERY", "COMPLETED", "CANCELLED"
    );

    @Override
    public CpqCrmOrderVo queryById(Long id) {
        log.info("查询订单详情: id={}", id);
        CpqCrmOrder entity = getById(id);
        if (entity == null) {
            return null;
        }
        return BeanUtil.toBean(entity, CpqCrmOrderVo.class);
    }

    @Override
    public TableDataInfo<CpqCrmOrderVo> queryPageList(CpqCrmOrderBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<CpqCrmOrder> qw = buildQueryWrapper(bo);
        List<CpqCrmOrder> list = page(pageQuery.build(), qw).getRecords();
        return TableDataInfo.build(BeanUtil.copyToList(list, CpqCrmOrderVo.class));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean insertByBo(CpqCrmOrderBo bo) {
        log.info("新增订单: {}", bo.getOrderName());
        CpqCrmOrder entity = BeanUtil.toBean(bo, CpqCrmOrder.class);
        if (entity.getOrderId() == null) {
            entity.setOrderId(IdGeneratorUtil.nextLongId());
        }
        // 自动生成订单编号: ORD-YYYYMMDD-序号
        if (StringUtils.isBlank(entity.getOrderNumber())) {
            entity.setOrderNumber(generateOrderNumber());
        }
        // 默认状态
        if (StringUtils.isBlank(entity.getStatus())) {
            entity.setStatus("DRAFT");
        }
        // 默认币种
        if (StringUtils.isBlank(entity.getCurrency())) {
            entity.setCurrency("CNY");
        }
        boolean saved = save(entity);
        // 更新订单总金额（由明细汇总）
        recalcTotalAmount(entity.getOrderId());
        return saved;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean updateByBo(CpqCrmOrderBo bo) {
        log.info("更新订单: id={}", bo.getOrderId());
        CpqCrmOrder entity = BeanUtil.toBean(bo, CpqCrmOrder.class);
        return updateById(entity);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean deleteWithValidByIds(List<Long> ids) {
        log.info("软删除订单: ids={}", ids);
        if (CollUtil.isEmpty(ids)) {
            return false;
        }
        for (Long orderId : ids) {
            // 同时软删除明细
            orderLineMapper.update(new LambdaUpdateWrapper<CpqCrmOrderLine>()
                    .setSql("del_flag = '2'")
                    .eq(CpqCrmOrderLine::getOrderId, orderId));
        }
        return update(new LambdaUpdateWrapper<CpqCrmOrder>()
                .setSql("del_flag = '2'")
                .in(CpqCrmOrder::getOrderId, ids));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean fromQuote(Map<String, Object> params) {
        log.info("从报价生成订单: params={}", params);
        Long quoteId = params.get("quoteId") != null
                ? Long.valueOf(params.get("quoteId").toString()) : null;
        Long contractId = params.get("contractId") != null
                ? Long.valueOf(params.get("contractId").toString()) : null;

        if (quoteId == null) {
            log.warn("报价单ID不能为空");
            return false;
        }

        CpqQuote quote = quoteMapper.selectById(quoteId);
        if (quote == null) {
            log.warn("报价单不存在: quoteId={}", quoteId);
            return false;
        }

        // 创建订单
        CpqCrmOrder order = new CpqCrmOrder();
        order.setOrderId(IdGeneratorUtil.nextLongId());
        order.setOrderNumber(generateOrderNumber());
        order.setContractId(contractId);
        order.setAccountId(quote.getAccountId());
        order.setQuoteId(quoteId);
        order.setStatus("DRAFT");
        order.setTotalAmount(quote.getGrandTotal());
        order.setCurrency("CNY");
        order.setOrderDate(new Date());

        if (params.get("deliveryDate") != null) {
            order.setDeliveryDate(DateUtil.parseDate(params.get("deliveryDate").toString()));
        }
        if (params.get("shippingAddress") != null) {
            order.setShippingAddress(params.get("shippingAddress").toString());
        }
        if (params.get("billingAddress") != null) {
            order.setBillingAddress(params.get("billingAddress").toString());
        }
        if (params.get("ownerId") != null) {
            order.setOwnerId(Long.valueOf(params.get("ownerId").toString()));
        }
        if (params.get("orderName") != null) {
            order.setOrderName(params.get("orderName").toString());
        } else {
            order.setOrderName("订单-" + quote.getQuoteNumber());
        }

        boolean saved = save(order);
        if (!saved) {
            return false;
        }

        // 从报价行生成订单明细
        List<CpqQuoteLineItem> quoteLines = quoteLineItemMapper.selectList(
                new LambdaQueryWrapper<CpqQuoteLineItem>()
                        .eq(CpqQuoteLineItem::getQuoteId, quoteId)
                        .orderByAsc(CpqQuoteLineItem::getLineNumber));
        int lineNum = 1;
        for (CpqQuoteLineItem ql : quoteLines) {
            CpqCrmOrderLine line = new CpqCrmOrderLine();
            line.setLineId(IdGeneratorUtil.nextLongId());
            line.setOrderId(order.getOrderId());
            line.setLineNumber(lineNum++);
            line.setSourceType("QUOTE_LINE");
            line.setSourceId(ql.getLineId());
            line.setProductCode(ql.getItemCode());
            line.setProductName(ql.getItemName());
            line.setModelId(ql.getModelId());
            line.setQuantity(ql.getQuantity());
            line.setUnit(ql.getUnit());
            line.setUnitPrice(ql.getUnitPrice());
            if (ql.getQuantity() != null && ql.getUnitPrice() != null) {
                line.setLineAmount(ql.getQuantity().multiply(ql.getUnitPrice()));
            }
            line.setDiscountPct(ql.getDiscountPct());
            orderLineMapper.insert(line);
        }

        log.info("从报价生成订单成功: orderId={}, quoteId={}, 明细行数={}",
                order.getOrderId(), quoteId, quoteLines.size());
        return true;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean advanceStatus(Long id, String status) {
        log.info("变更订单状态: id={}, status={}", id, status);
        CpqCrmOrder entity = getById(id);
        if (entity == null) {
            log.warn("订单不存在: id={}", id);
            return false;
        }

        // 校验状态流转合法（不可回退）
        int currentIdx = STATUS_ORDER.indexOf(entity.getStatus());
        int targetIdx = STATUS_ORDER.indexOf(status);
        if (targetIdx <= currentIdx) {
            log.warn("订单状态不可回退: {} -> {}", entity.getStatus(), status);
            throw new RuntimeException("订单状态不可回退，当前状态: " + entity.getStatus());
        }

        entity.setStatus(status);
        return updateById(entity);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean addLine(Long orderId, CpqCrmOrderLineVo lineVo) {
        log.info("新增订单明细: orderId={}, lineVo={}", orderId, lineVo);
        CpqCrmOrderLine line = BeanUtil.toBean(lineVo, CpqCrmOrderLine.class);
        line.setLineId(IdGeneratorUtil.nextLongId());
        line.setOrderId(orderId);
        // 自动计算行金额
        if (line.getQuantity() != null && line.getUnitPrice() != null && line.getLineAmount() == null) {
            line.setLineAmount(line.getQuantity().multiply(line.getUnitPrice()));
        }
        // 自动生成行号
        if (line.getLineNumber() == null) {
            Long count = orderLineMapper.selectCount(
                    new LambdaQueryWrapper<CpqCrmOrderLine>().eq(CpqCrmOrderLine::getOrderId, orderId));
            line.setLineNumber(count.intValue() + 1);
        }
        // 默认来源类型
        if (StringUtils.isBlank(line.getSourceType())) {
            line.setSourceType("MANUAL");
        }
        boolean saved = orderLineMapper.insert(line) > 0;
        // 重新计算订单总金额
        recalcTotalAmount(orderId);
        return saved;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean updateLine(Long orderId, CpqCrmOrderLineVo lineVo) {
        log.info("更新订单明细: orderId={}, lineId={}", orderId, lineVo.getLineId());
        CpqCrmOrderLine line = BeanUtil.toBean(lineVo, CpqCrmOrderLine.class);
        line.setOrderId(orderId);
        // 重新计算行金额
        if (line.getQuantity() != null && line.getUnitPrice() != null) {
            line.setLineAmount(line.getQuantity().multiply(line.getUnitPrice()));
        }
        boolean updated = orderLineMapper.updateById(line) > 0;
        // 重新计算订单总金额
        recalcTotalAmount(orderId);
        return updated;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean deleteLine(Long orderId, Long lineId) {
        log.info("删除订单明细: orderId={}, lineId={}", orderId, lineId);
        boolean deleted = orderLineMapper.update(new LambdaUpdateWrapper<CpqCrmOrderLine>()
                .setSql("del_flag = '2'")
                .eq(CpqCrmOrderLine::getLineId, lineId)
                .eq(CpqCrmOrderLine::getOrderId, orderId)) > 0;
        // 重新计算订单总金额
        recalcTotalAmount(orderId);
        return deleted;
    }

    @Override
    public List<CpqCrmOrderLineVo> queryLinesByOrderId(Long orderId) {
        log.info("查询订单明细列表: orderId={}", orderId);
        List<CpqCrmOrderLine> lines = orderLineMapper.selectList(
                new LambdaQueryWrapper<CpqCrmOrderLine>()
                        .eq(CpqCrmOrderLine::getOrderId, orderId)
                        .orderByAsc(CpqCrmOrderLine::getLineNumber));
        return BeanUtil.copyToList(lines, CpqCrmOrderLineVo.class);
    }

    /**
     * 重新计算订单总金额（由明细汇总）
     */
    private void recalcTotalAmount(Long orderId) {
        List<CpqCrmOrderLine> lines = orderLineMapper.selectList(
                new LambdaQueryWrapper<CpqCrmOrderLine>().eq(CpqCrmOrderLine::getOrderId, orderId));
        BigDecimal total = BigDecimal.ZERO;
        for (CpqCrmOrderLine line : lines) {
            if (line.getLineAmount() != null) {
                total = total.add(line.getLineAmount());
            }
        }
        CpqCrmOrder order = new CpqCrmOrder();
        order.setOrderId(orderId);
        order.setTotalAmount(total);
        updateById(order);
    }

    private String generateOrderNumber() {
        String datePart = DateUtil.format(DateUtil.date(), "yyyyMMdd");
        int seq = codeSeq.getAndIncrement();
        return String.format("ORD-%s-%04d", datePart, seq % 10000);
    }

    private LambdaQueryWrapper<CpqCrmOrder> buildQueryWrapper(CpqCrmOrderBo bo) {
        LambdaQueryWrapper<CpqCrmOrder> qw = new LambdaQueryWrapper<>();
        qw.like(StringUtils.isNotBlank(bo.getOrderNumber()), CpqCrmOrder::getOrderNumber, bo.getOrderNumber());
        qw.like(StringUtils.isNotBlank(bo.getOrderName()), CpqCrmOrder::getOrderName, bo.getOrderName());
        qw.eq(bo.getContractId() != null, CpqCrmOrder::getContractId, bo.getContractId());
        qw.eq(bo.getAccountId() != null, CpqCrmOrder::getAccountId, bo.getAccountId());
        qw.eq(StringUtils.isNotBlank(bo.getStatus()), CpqCrmOrder::getStatus, bo.getStatus());
        qw.orderByDesc(CpqCrmOrder::getCreateTime);
        return qw;
    }
}
