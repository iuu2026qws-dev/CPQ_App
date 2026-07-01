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
import org.dromara.cpq.crm.domain.CpqCrmContract;
import org.dromara.cpq.crm.domain.CpqCrmOrder;
import org.dromara.cpq.crm.domain.CpqCrmOrderLine;
import org.dromara.cpq.crm.domain.CpqCrmOpportunity;
import org.dromara.cpq.crm.domain.bo.CpqCrmContractBo;
import org.dromara.cpq.crm.domain.vo.CpqCrmContractVo;
import org.dromara.cpq.crm.domain.vo.CpqCrmOrderVo;
import org.dromara.cpq.crm.mapper.CpqCrmContractMapper;
import org.dromara.cpq.crm.mapper.CpqCrmOpportunityMapper;
import org.dromara.cpq.crm.mapper.CpqCrmOrderLineMapper;
import org.dromara.cpq.crm.mapper.CpqCrmOrderMapper;
import org.dromara.cpq.crm.service.ICpqCrmContractService;
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
 * 合同 Service 实现
 *
 * @author CPQ Team
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class CpqCrmContractServiceImpl extends ServiceImpl<CpqCrmContractMapper, CpqCrmContract>
        implements ICpqCrmContractService {

    private final CpqCrmOpportunityMapper opportunityMapper;
    private final CpqCrmOrderMapper orderMapper;
    private final CpqCrmOrderLineMapper orderLineMapper;
    private final CpqQuoteMapper quoteMapper;
    private final CpqQuoteLineItemMapper quoteLineItemMapper;

    private final AtomicInteger codeSeq = new AtomicInteger(1);

    /** 合同状态流转顺序 */
    private static final List<String> STATUS_ORDER = Arrays.asList(
        "DRAFT", "PENDING_APPROVAL", "PENDING_SIGN", "ACTIVE", "COMPLETED", "TERMINATED"
    );

    @Override
    public CpqCrmContractVo queryById(Long id) {
        log.info("查询合同详情: id={}", id);
        CpqCrmContract entity = getById(id);
        if (entity == null) {
            return null;
        }
        CpqCrmContractVo vo = BeanUtil.toBean(entity, CpqCrmContractVo.class);
        // 补充关联名称
        if (entity.getAccountId() != null) {
            // accountName 由前端关联或JOIN查询填充
        }
        if (entity.getOpportunityId() != null) {
            CpqCrmOpportunity opp = opportunityMapper.selectById(entity.getOpportunityId());
            if (opp != null) {
                vo.setOpportunityName(opp.getOpportunityName());
            }
        }
        return vo;
    }

    @Override
    public TableDataInfo<CpqCrmContractVo> queryPageList(CpqCrmContractBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<CpqCrmContract> qw = buildQueryWrapper(bo);
        List<CpqCrmContract> list = page(pageQuery.build(), qw).getRecords();
        List<CpqCrmContractVo> voList = BeanUtil.copyToList(list, CpqCrmContractVo.class);
        // 补充关联名称
        for (CpqCrmContractVo vo : voList) {
            if (vo.getOpportunityId() != null) {
                CpqCrmOpportunity opp = opportunityMapper.selectById(vo.getOpportunityId());
                if (opp != null) {
                    vo.setOpportunityName(opp.getOpportunityName());
                }
            }
        }
        return TableDataInfo.build(voList);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean insertByBo(CpqCrmContractBo bo) {
        log.info("新增合同: {}", bo.getContractName());
        CpqCrmContract entity = BeanUtil.toBean(bo, CpqCrmContract.class);
        if (entity.getContractId() == null) {
            entity.setContractId(IdGeneratorUtil.nextLongId());
        }
        // 自动生成合同编号: CT-YYYYMMDD-序号
        if (StringUtils.isBlank(entity.getContractNumber())) {
            entity.setContractNumber(generateContractNumber());
        }
        // 默认状态
        if (StringUtils.isBlank(entity.getStatus())) {
            entity.setStatus("DRAFT");
        }
        // 默认合同类型
        if (StringUtils.isBlank(entity.getContractType())) {
            entity.setContractType("PROJECT");
        }
        return save(entity);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean updateByBo(CpqCrmContractBo bo) {
        log.info("更新合同: id={}", bo.getContractId());
        CpqCrmContract entity = BeanUtil.toBean(bo, CpqCrmContract.class);
        return updateById(entity);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean deleteWithValidByIds(List<Long> ids) {
        log.info("软删除合同: ids={}", ids);
        if (CollUtil.isEmpty(ids)) {
            return false;
        }
        return update(new LambdaUpdateWrapper<CpqCrmContract>()
                .setSql("del_flag = '2'")
                .in(CpqCrmContract::getContractId, ids));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean fromOpportunity(Map<String, Object> params) {
        log.info("从商机生成合同: params={}", params);
        Long opportunityId = params.get("opportunityId") != null
                ? Long.valueOf(params.get("opportunityId").toString()) : null;
        if (opportunityId == null) {
            log.warn("商机ID不能为空");
            return false;
        }

        CpqCrmOpportunity opp = opportunityMapper.selectById(opportunityId);
        if (opp == null) {
            log.warn("商机不存在: opportunityId={}", opportunityId);
            return false;
        }

        // 创建合同
        CpqCrmContract contract = new CpqCrmContract();
        contract.setContractId(IdGeneratorUtil.nextLongId());
        contract.setContractNumber(generateContractNumber());
        contract.setContractName(params.get("contractName") != null
                ? params.get("contractName").toString() : opp.getOpportunityName() + " 合同");
        contract.setAccountId(opp.getAccountId());
        contract.setOpportunityId(opportunityId);
        contract.setContractType("PROJECT"); // 单项目制
        contract.setStatus("DRAFT");
        contract.setTotalAmount(opp.getAmount());
        contract.setOwnerId(opp.getOwnerId());

        if (params.get("startDate") != null) {
            contract.setStartDate(DateUtil.parseDate(params.get("startDate").toString()));
        }
        if (params.get("endDate") != null) {
            contract.setEndDate(DateUtil.parseDate(params.get("endDate").toString()));
        }
        if (params.get("signingParty") != null) {
            contract.setSigningParty(params.get("signingParty").toString());
        }
        if (params.get("paymentTerms") != null) {
            contract.setPaymentTerms(params.get("paymentTerms").toString());
        }
        if (params.get("description") != null) {
            contract.setDescription(params.get("description").toString());
        }

        boolean saved = save(contract);
        if (!saved) {
            return false;
        }

        // 从报价配置清单自动生成订单明细（如有已确认报价）
        List<CpqQuote> quotes = quoteMapper.selectList(new LambdaQueryWrapper<CpqQuote>()
                .eq(CpqQuote::getOpportunityId, opportunityId)
                .eq(CpqQuote::getStatus, "CONFIRMED")
                .orderByDesc(CpqQuote::getCreateTime));
        if (CollUtil.isNotEmpty(quotes)) {
            // 取最新确认报价
            CpqQuote confirmedQuote = quotes.get(0);
            // 创建订单
            CpqCrmOrder order = new CpqCrmOrder();
            order.setOrderId(IdGeneratorUtil.nextLongId());
            order.setOrderNumber(generateOrderNumber());
            order.setOrderName(contract.getContractName() + " 订单");
            order.setContractId(contract.getContractId());
            order.setAccountId(contract.getAccountId());
            order.setQuoteId(confirmedQuote.getQuoteId());
            order.setStatus("DRAFT");
            order.setTotalAmount(confirmedQuote.getGrandTotal());
            order.setCurrency("CNY");
            order.setOwnerId(contract.getOwnerId());
            orderMapper.insert(order);

            // 从报价行生成订单明细
            List<CpqQuoteLineItem> quoteLines = quoteLineItemMapper.selectList(
                    new LambdaQueryWrapper<CpqQuoteLineItem>()
                            .eq(CpqQuoteLineItem::getQuoteId, confirmedQuote.getQuoteId())
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
            log.info("从商机生成合同成功，已创建订单和明细: contractId={}, orderId={}",
                    contract.getContractId(), order.getOrderId());
        }

        log.info("从商机生成合同成功: contractId={}", contract.getContractId());
        return true;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean advanceStatus(Long id, String status) {
        log.info("变更合同状态: id={}, status={}", id, status);
        CpqCrmContract entity = getById(id);
        if (entity == null) {
            log.warn("合同不存在: id={}", id);
            return false;
        }

        // 校验状态流转合法（不可回退）
        int currentIdx = STATUS_ORDER.indexOf(entity.getStatus());
        int targetIdx = STATUS_ORDER.indexOf(status);
        if (targetIdx <= currentIdx) {
            log.warn("合同状态不可回退: {} -> {}", entity.getStatus(), status);
            throw new RuntimeException("合同状态不可回退，当前状态: " + entity.getStatus());
        }

        entity.setStatus(status);
        // ACTIVE 自动记录签订日期
        if ("ACTIVE".equals(status) && entity.getSignedDate() == null) {
            entity.setSignedDate(new Date());
        }
        return updateById(entity);
    }

    @Override
    public List<?> queryOrdersByContractId(Long contractId) {
        log.info("查询合同关联订单: contractId={}", contractId);
        List<CpqCrmOrder> orders = orderMapper.selectList(new LambdaQueryWrapper<CpqCrmOrder>()
                .eq(CpqCrmOrder::getContractId, contractId)
                .orderByDesc(CpqCrmOrder::getCreateTime));
        return BeanUtil.copyToList(orders, CpqCrmOrderVo.class);
    }

    private String generateContractNumber() {
        String datePart = DateUtil.format(DateUtil.date(), "yyyyMMdd");
        int seq = codeSeq.getAndIncrement();
        return String.format("CT-%s-%04d", datePart, seq % 10000);
    }

    private String generateOrderNumber() {
        String datePart = DateUtil.format(DateUtil.date(), "yyyyMMdd");
        int seq = codeSeq.getAndIncrement();
        return String.format("ORD-%s-%04d", datePart, seq % 10000);
    }

    private LambdaQueryWrapper<CpqCrmContract> buildQueryWrapper(CpqCrmContractBo bo) {
        LambdaQueryWrapper<CpqCrmContract> qw = new LambdaQueryWrapper<>();
        qw.like(StringUtils.isNotBlank(bo.getContractNumber()), CpqCrmContract::getContractNumber, bo.getContractNumber());
        qw.like(StringUtils.isNotBlank(bo.getContractName()), CpqCrmContract::getContractName, bo.getContractName());
        qw.eq(bo.getAccountId() != null, CpqCrmContract::getAccountId, bo.getAccountId());
        qw.eq(StringUtils.isNotBlank(bo.getContractType()), CpqCrmContract::getContractType, bo.getContractType());
        qw.eq(StringUtils.isNotBlank(bo.getStatus()), CpqCrmContract::getStatus, bo.getStatus());
        qw.orderByDesc(CpqCrmContract::getCreateTime);
        return qw;
    }
}
