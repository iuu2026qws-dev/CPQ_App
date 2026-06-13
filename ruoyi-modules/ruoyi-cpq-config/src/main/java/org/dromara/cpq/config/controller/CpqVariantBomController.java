package org.dromara.cpq.config.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.config.domain.bo.CpqVariantBomBo;
import org.dromara.cpq.config.domain.vo.CpqVariantBomVo;
import org.dromara.cpq.config.service.ICpqVariantBomService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/config/variantbom")
public class CpqVariantBomController extends BaseController {

    private final ICpqVariantBomService cpqVariantBomService;

    @GetMapping("/list")
    public R<List<CpqVariantBomVo>> list(CpqVariantBomBo bo) {
        return R.ok(cpqVariantBomService.selectList(bo));
    }

    @GetMapping("{variantId}")
    public R<CpqVariantBomVo> getInfo(@PathVariable Long variantId) {
        return R.ok(cpqVariantBomService.selectById(variantId));
    }

    @Log(title = "CPQ变体BOM", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@Validated @RequestBody CpqVariantBomBo bo) {
        return toAjax(cpqVariantBomService.insert(bo));
    }

    @Log(title = "CPQ变体BOM", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@Validated @RequestBody CpqVariantBomBo bo) {
        return toAjax(cpqVariantBomService.update(bo));
    }

    @Log(title = "CPQ变体BOM", businessType = BusinessType.DELETE)
    @DeleteMapping("{variantId}")
    public R<Void> remove(@PathVariable Long variantId) {
        return toAjax(cpqVariantBomService.delete(variantId));
    }
}
