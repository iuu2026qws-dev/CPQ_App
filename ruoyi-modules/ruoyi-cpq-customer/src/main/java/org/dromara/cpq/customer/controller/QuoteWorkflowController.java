package org.dromara.cpq.customer.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.domain.R;
import org.dromara.cpq.customer.service.QuoteToErpService;
import org.springframework.web.bind.annotation.*;

/**
 * 报价全链路工作流控制器
 * <p>
 * 提供报价→审批→订单创建的完整流程 API。
 * 串联报价、审批、ERP三个域的核心操作。
 * </p>
 */
@Slf4j
@RestController
@RequestMapping("/cpq/workflow")
@RequiredArgsConstructor
public class QuoteWorkflowController {

    private final QuoteToErpService quoteToErpService;

    /**
     * 创建报价并提交审批
     */
    @PostMapping("/quote/create")
    public R<Long> createQuoteAndSubmit(@RequestBody java.util.Map<String, Object> quoteData) {
        log.info("createQuoteAndSubmit: {}", quoteData);
        Long quoteId = quoteToErpService.createQuote(quoteData);
        return R.ok(quoteId);
    }

    /**
     * 提交报价单到审批
     */
    @PostMapping("/quote/{quoteId}/submit")
    public R<String> submitToApproval(@PathVariable Long quoteId) {
        log.info("submitToApproval: quoteId={}", quoteId);
        Long chainId = quoteToErpService.submitQuoteForApproval(quoteId);
        return R.ok("审批链已创建: " + chainId);
    }

    /**
     * 查询报价单全链路状态
     */
    @GetMapping("/quote/{quoteId}/status")
    public R<java.util.Map<String, Object>> getQuoteStatus(@PathVariable Long quoteId) {
        log.info("getQuoteStatus: quoteId={}", quoteId);
        return R.ok(quoteToErpService.getQuoteWorkflowStatus(quoteId));
    }

    /**
     * 报价单转订单（含幂等性 key）
     */
    @PostMapping("/quote/{quoteId}/convert-to-order")
    public R<String> convertToOrder(@PathVariable Long quoteId,
                                    @RequestParam(required = false) String idempotencyKey) {
        log.info("convertToOrder: quoteId={}, key={}", quoteId, idempotencyKey);
        String orderId = quoteToErpService.convertQuoteToOrder(quoteId, idempotencyKey);
        return R.ok("订单已创建: " + orderId);
    }
}
