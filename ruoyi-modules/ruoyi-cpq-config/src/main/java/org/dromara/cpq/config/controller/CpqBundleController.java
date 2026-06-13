package org.dromara.cpq.config.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.config.domain.bo.CpqBundleBo;
import org.dromara.cpq.config.domain.vo.CpqBundleVo;
import org.dromara.cpq.config.service.ICpqBundleService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/product/bundle")
public class CpqBundleController extends BaseController {

    private final ICpqBundleService cpqBundleService;

    @GetMapping("/list")
    public R<List<CpqBundleVo>> list(CpqBundleBo bo) {
        return R.ok(cpqBundleService.selectList(bo));
    }

    @GetMapping("{bundleId}")
    public R<CpqBundleVo> getInfo(@PathVariable Long bundleId) {
        return R.ok(cpqBundleService.selectById(bundleId));
    }

    @Log(title = "CPQ捆绑包", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@Validated @RequestBody CpqBundleBo bo) {
        return toAjax(cpqBundleService.insert(bo));
    }

    @Log(title = "CPQ捆绑包", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@Validated @RequestBody CpqBundleBo bo) {
        return toAjax(cpqBundleService.update(bo));
    }

    @Log(title = "CPQ捆绑包", businessType = BusinessType.DELETE)
    @DeleteMapping("{bundleId}")
    public R<Void> remove(@PathVariable Long bundleId) {
        return toAjax(cpqBundleService.delete(bundleId));
    }
}
