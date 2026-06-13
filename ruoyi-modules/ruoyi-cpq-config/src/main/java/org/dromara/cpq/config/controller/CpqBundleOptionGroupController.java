package org.dromara.cpq.config.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.config.domain.bo.CpqBundleOptionGroupBo;
import org.dromara.cpq.config.domain.vo.CpqBundleOptionGroupVo;
import org.dromara.cpq.config.service.ICpqBundleOptionGroupService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/product/bundleoptiongroup")
public class CpqBundleOptionGroupController extends BaseController {

    private final ICpqBundleOptionGroupService cpqBundleOptionGroupService;

    @GetMapping("/list")
    public R<List<CpqBundleOptionGroupVo>> list(CpqBundleOptionGroupBo bo) {
        return R.ok(cpqBundleOptionGroupService.selectList(bo));
    }

    @GetMapping("{optionGroupId}")
    public R<CpqBundleOptionGroupVo> getInfo(@PathVariable Long optionGroupId) {
        return R.ok(cpqBundleOptionGroupService.selectById(optionGroupId));
    }

    @Log(title = "CPQ捆绑选项组", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@Validated @RequestBody CpqBundleOptionGroupBo bo) {
        return toAjax(cpqBundleOptionGroupService.insert(bo));
    }

    @Log(title = "CPQ捆绑选项组", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@Validated @RequestBody CpqBundleOptionGroupBo bo) {
        return toAjax(cpqBundleOptionGroupService.update(bo));
    }

    @Log(title = "CPQ捆绑选项组", businessType = BusinessType.DELETE)
    @DeleteMapping("{optionGroupId}")
    public R<Void> remove(@PathVariable Long optionGroupId) {
        return toAjax(cpqBundleOptionGroupService.delete(optionGroupId));
    }
}
