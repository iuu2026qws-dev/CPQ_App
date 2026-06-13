package org.dromara.cpq.config.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.config.domain.bo.CpqConfigRuleBo;
import org.dromara.cpq.config.domain.vo.CpqConfigRuleVo;
import org.dromara.cpq.config.service.ICpqConfigRuleService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/config/rule")
public class CpqConfigRuleController extends BaseController {

    private final ICpqConfigRuleService cpqConfigRuleService;

    @GetMapping("/list")
    public R<List<CpqConfigRuleVo>> list(CpqConfigRuleBo bo) {
        return R.ok(cpqConfigRuleService.selectList(bo));
    }

    @GetMapping("{ruleId}")
    public R<CpqConfigRuleVo> getInfo(@PathVariable Long ruleId) {
        return R.ok(cpqConfigRuleService.selectById(ruleId));
    }

    @Log(title = "CPQ配置规则", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@Validated @RequestBody CpqConfigRuleBo bo) {
        return toAjax(cpqConfigRuleService.insert(bo));
    }

    @Log(title = "CPQ配置规则", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@Validated @RequestBody CpqConfigRuleBo bo) {
        return toAjax(cpqConfigRuleService.update(bo));
    }

    @Log(title = "CPQ配置规则", businessType = BusinessType.DELETE)
    @DeleteMapping("{ruleId}")
    public R<Void> remove(@PathVariable Long ruleId) {
        return toAjax(cpqConfigRuleService.delete(ruleId));
    }
}
