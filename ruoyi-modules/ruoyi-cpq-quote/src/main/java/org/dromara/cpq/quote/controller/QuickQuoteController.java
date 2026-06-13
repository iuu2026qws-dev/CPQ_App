package org.dromara.cpq.quote.controller;

import java.util.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.domain.R;
import org.dromara.cpq.quote.service.QuickQuoteService;
import org.springframework.web.bind.annotation.*;

@Slf4j @RestController @RequestMapping("/cpq/quote/quick") @RequiredArgsConstructor
public class QuickQuoteController {
    private final QuickQuoteService quickQuoteService;

    @PostMapping("/create")
    public R<Map<String,Object>> create(@RequestBody Map<String,Object> params) {
        return quickQuoteService.quickQuote(params);
    }

    @GetMapping("/similar")
    public R<List<Map<String,Object>>> similar(@RequestParam Long customerId, @RequestParam(required = false) String productCategory) {
        return quickQuoteService.findSimilarQuotes(customerId, productCategory);
    }
}
