package org.dromara.cpq.pricing.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.pricing.domain.bo.CpqPriceRuleBo;
import org.dromara.cpq.pricing.domain.vo.CpqPriceRuleVo;
import org.dromara.cpq.pricing.service.ICpqPriceRuleService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * CPQ 定价规则管理（菜单 50092）
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/pricing/rule")
public class CpqPriceRuleController extends BaseController {

    private final ICpqPriceRuleService priceRuleService;

    @GetMapping("/list")
    public R<List<CpqPriceRuleVo>> list(CpqPriceRuleBo bo) {
        return R.ok(priceRuleService.selectPriceRuleList(bo));
    }

    @GetMapping("/{priceRuleId}")
    public R<CpqPriceRuleVo> getInfo(@PathVariable Long priceRuleId) {
        return R.ok(priceRuleService.selectPriceRuleById(priceRuleId));
    }

    @Log(title = "CPQ定价规则", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@Validated @RequestBody CpqPriceRuleBo bo) {
        return toAjax(priceRuleService.insertPriceRule(bo));
    }

    @Log(title = "CPQ定价规则", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@Validated @RequestBody CpqPriceRuleBo bo) {
        return toAjax(priceRuleService.updatePriceRule(bo));
    }

    @Log(title = "CPQ定价规则", businessType = BusinessType.DELETE)
    @DeleteMapping("/{priceRuleId}")
    public R<Void> remove(@PathVariable Long priceRuleId) {
        return toAjax(priceRuleService.deletePriceRule(priceRuleId));
    }
}
