package org.dromara.cpq.customer.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.cpq.quote.domain.CpqQuote;
import org.dromara.cpq.quote.mapper.CpqQuoteMapper;
import org.dromara.cpq.approval.domain.CpqApprovalChain;
import org.dromara.cpq.approval.mapper.CpqApprovalChainMapper;
import org.dromara.cpq.approval.service.ApprovalRouteService;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 报价转ERP服务
 * <p>
 * 处理报价单到 ERP 订单的转换，含幂等性控制。
 * 串联报价、审批两个域的跨模块操作。
 * </p>
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class QuoteToErpService {

    private final CpqQuoteMapper quoteMapper;
    private final CpqApprovalChainMapper chainMapper;
    private final ApprovalRouteService approvalRouteService;

    private final Map<String, String> idempotencyStore = new ConcurrentHashMap<>();

    /**
     * 创建报价单（待补全完整字段映射）
     */
    public Long createQuote(Map<String, Object> quoteData) {
        log.info("createQuote: {}", quoteData);
        CpqQuote quote = new CpqQuote();
        quote.setQuoteNumber((String) quoteData.getOrDefault("quoteName", "新报价单"));
        quote.setAccountId(toLong(quoteData.get("accountId"), 1L));
        quote.setAccountName((String) quoteData.getOrDefault("accountName", ""));
        quote.setStatus("DRAFT");
        quote.setCurrency((String) quoteData.getOrDefault("currency", "CNY"));
        quote.setQuoteType((String) quoteData.getOrDefault("quoteType", "STANDARD"));
        quoteMapper.insert(quote);
        log.info("报价单已创建: quoteId={}", quote.getQuoteId());
        return quote.getQuoteId();
    }

    private Long toLong(Object val, Long defaultVal) {
        if (val == null) return defaultVal;
        if (val instanceof Number n) return n.longValue();
        try { return Long.parseLong(val.toString()); }
        catch (NumberFormatException e) { return defaultVal; }
    }

    /**
     * 提交报价单到审批，构建审批链
     */
    public Long submitQuoteForApproval(Long quoteId) {
        log.info("submitQuoteForApproval: quoteId={}", quoteId);
        CpqQuote quote = quoteMapper.selectById(quoteId);
        if (quote == null) throw new RuntimeException("报价单不存在: " + quoteId);

        CpqApprovalChain chain = approvalRouteService.buildChain(quote);
        chainMapper.insert(chain);

        quote.setStatus("PENDING_APPROVAL");
        quoteMapper.updateById(quote);

        log.info("审批链已创建: chainId={}, quoteId={}", chain.getChainId(), quoteId);
        return chain.getChainId();
    }

    /**
     * 查询报价单工作流状态
     */
    public Map<String, Object> getQuoteWorkflowStatus(Long quoteId) {
        log.info("getQuoteWorkflowStatus: quoteId={}", quoteId);
        CpqQuote quote = quoteMapper.selectById(quoteId);
        Map<String, Object> status = new java.util.LinkedHashMap<>();
        status.put("quoteId", quoteId);
        status.put("quoteStatus", quote != null ? quote.getStatus() : "NOT_FOUND");
        status.put("canConvertToOrder", "APPROVED".equals(quote != null ? quote.getStatus() : ""));
        return status;
    }

    /**
     * 报价单转ERP订单（含幂等性控制）
     */
    public String convertQuoteToOrder(Long quoteId, String idempotencyKey) {
        log.info("convertQuoteToOrder: quoteId={}, key={}", quoteId, idempotencyKey);

        if (idempotencyKey != null && idempotencyStore.containsKey(idempotencyKey)) {
            log.warn("幂等命中: key={}, orderId={}", idempotencyKey, idempotencyStore.get(idempotencyKey));
            return idempotencyStore.get(idempotencyKey);
        }

        CpqQuote quote = quoteMapper.selectById(quoteId);
        if (quote == null) throw new RuntimeException("报价单不存在: " + quoteId);
        if (!"APPROVED".equals(quote.getStatus())) throw new RuntimeException("报价单审批未完成");

        // 模拟ERP订单创建
        String orderId = "ORD-" + quoteId + "-" + System.currentTimeMillis();

        quote.setStatus("CONVERTED_TO_ORDER");
        quoteMapper.updateById(quote);

        if (idempotencyKey != null) {
            idempotencyStore.put(idempotencyKey, orderId);
        }

        log.info("订单已创建: orderId={}, quoteId={}", orderId, quoteId);
        return orderId;
    }
}
