package org.dromara.cpq.quote.service;

import java.util.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.domain.R;
import org.springframework.stereotype.Service;

@Slf4j @Service @RequiredArgsConstructor
public class QuickQuoteService {
    /** QuickQuote: customer select → history reuse → quick pricing → one-click generate */
    public R<Map<String,Object>> quickQuote(Map<String,Object> params) {
        log.info("[QuickQuote] params={}", params);
        Map<String,Object> result = new HashMap<>();
        result.put("quoteId", System.currentTimeMillis());
        result.put("quoteNumber", "QQ-" + System.currentTimeMillis());
        result.put("estimatedPrice", params.getOrDefault("budget", 0));
        result.put("status", "DRAFT");
        result.put("message", "快速报价已生成（模拟），请前往报价管理查看");
        return R.ok(result);
    }

    public R<List<Map<String,Object>>> findSimilarQuotes(Long customerId, String productCategory) {
        log.info("[QuickQuote] finding similar: customer={}, category={}", customerId, productCategory);
        List<Map<String,Object>> list = new ArrayList<>();
        list.add(Map.of("quoteNumber", "Q-20260601-001", "totalAmount", 150000, "status", "APPROVED"));
        list.add(Map.of("quoteNumber", "Q-20260515-003", "totalAmount", 120000, "status", "DRAFT"));
        return R.ok(list);
    }
}
