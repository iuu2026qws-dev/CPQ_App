package org.dromara.cpq.config.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.config.domain.bo.CpqBundleOptionBo;
import org.dromara.cpq.config.domain.vo.CpqBundleOptionVo;
import org.dromara.cpq.config.service.ICpqBundleOptionService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/product/bundleoption")
public class CpqBundleOptionController extends BaseController {

    private final ICpqBundleOptionService cpqBundleOptionService;

    @GetMapping("/list")
    public R<List<CpqBundleOptionVo>> list(CpqBundleOptionBo bo) {
        return R.ok(cpqBundleOptionService.selectList(bo));
    }

    @GetMapping("{optionId}")
    public R<CpqBundleOptionVo> getInfo(@PathVariable Long optionId) {
        return R.ok(cpqBundleOptionService.selectById(optionId));
    }

    @Log(title = "CPQ捆绑选项", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@Validated @RequestBody CpqBundleOptionBo bo) {
        return toAjax(cpqBundleOptionService.insert(bo));
    }

    @Log(title = "CPQ捆绑选项", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@Validated @RequestBody CpqBundleOptionBo bo) {
        return toAjax(cpqBundleOptionService.update(bo));
    }

    @Log(title = "CPQ捆绑选项", businessType = BusinessType.DELETE)
    @DeleteMapping("{optionId}")
    public R<Void> remove(@PathVariable Long optionId) {
        return toAjax(cpqBundleOptionService.delete(optionId));
    }
}
