package org.dromara.cpq.pricing.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.cpq.pricing.service.PricingEngineService;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;

/**
 * 定价引擎测试控制器（Sprint 5）
 */
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/engine/pricing")
public class PricingEngineController {

    private final PricingEngineService pricingEngineService;

    @PostMapping("/calculate")
    public R<PricingEngineService.PriceResult> calculate(@RequestParam Long productModelId,
                                                          @RequestParam(required = false) Long variantId,
                                                          @RequestParam(defaultValue = "1") BigDecimal quantity,
                                                          @RequestParam(required = false) String region,
                                                          @RequestParam(required = false) Long channelId,
                                                          @RequestParam(defaultValue = "0") BigDecimal requestedDiscount,
                                                          @RequestParam(defaultValue = "0") BigDecimal bomCost,
                                                          @RequestParam(defaultValue = "CNY") String currency) {
        PricingEngineService.PriceResult result = pricingEngineService.calculatePrice(
            productModelId, variantId, quantity, region, channelId,
            requestedDiscount, bomCost, currency);
        return R.ok(result);
    }
}
