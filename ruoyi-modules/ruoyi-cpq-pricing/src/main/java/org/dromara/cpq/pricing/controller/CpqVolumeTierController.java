package org.dromara.cpq.pricing.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.pricing.domain.bo.CpqVolumeTierBo;
import org.dromara.cpq.pricing.domain.vo.CpqVolumeTierVo;
import org.dromara.cpq.pricing.service.ICpqVolumeTierService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * CPQ 阶梯定价管理（菜单 50093）
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/pricing/volumetier")
public class CpqVolumeTierController extends BaseController {

    private final ICpqVolumeTierService volumeTierService;

    @GetMapping("/list")
    public R<List<CpqVolumeTierVo>> list(CpqVolumeTierBo bo) {
        return R.ok(volumeTierService.selectVolumeTierList(bo));
    }

    @GetMapping("/{tierId}")
    public R<CpqVolumeTierVo> getInfo(@PathVariable Long tierId) {
        return R.ok(volumeTierService.selectVolumeTierById(tierId));
    }

    @Log(title = "CPQ阶梯定价", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@Validated @RequestBody CpqVolumeTierBo bo) {
        return toAjax(volumeTierService.insertVolumeTier(bo));
    }

    @Log(title = "CPQ阶梯定价", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@Validated @RequestBody CpqVolumeTierBo bo) {
        return toAjax(volumeTierService.updateVolumeTier(bo));
    }

    @Log(title = "CPQ阶梯定价", businessType = BusinessType.DELETE)
    @DeleteMapping("/{tierId}")
    public R<Void> remove(@PathVariable Long tierId) {
        return toAjax(volumeTierService.deleteVolumeTier(tierId));
    }
}
