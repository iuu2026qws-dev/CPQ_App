package org.dromara.cpq.pricing.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.pricing.domain.bo.CpqCurrencyRateBo;
import org.dromara.cpq.pricing.domain.vo.CpqCurrencyRateVo;
import org.dromara.cpq.pricing.service.ICpqCurrencyRateService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * CPQ 汇率管理
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/pricing/currencyrate")
public class CpqCurrencyRateController extends BaseController {

    private final ICpqCurrencyRateService currencyRateService;

    @GetMapping("/list")
    public R<List<CpqCurrencyRateVo>> list(CpqCurrencyRateBo bo) {
        return R.ok(currencyRateService.selectCurrencyRateList(bo));
    }

    @GetMapping("/{rateId}")
    public R<CpqCurrencyRateVo> getInfo(@PathVariable Long rateId) {
        return R.ok(currencyRateService.selectCurrencyRateById(rateId));
    }

    @Log(title = "CPQ汇率", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@Validated @RequestBody CpqCurrencyRateBo bo) {
        return toAjax(currencyRateService.insertCurrencyRate(bo));
    }

    @Log(title = "CPQ汇率", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@Validated @RequestBody CpqCurrencyRateBo bo) {
        return toAjax(currencyRateService.updateCurrencyRate(bo));
    }

    @Log(title = "CPQ汇率", businessType = BusinessType.DELETE)
    @DeleteMapping("/{rateId}")
    public R<Void> remove(@PathVariable Long rateId) {
        return toAjax(currencyRateService.deleteCurrencyRate(rateId));
    }
}
