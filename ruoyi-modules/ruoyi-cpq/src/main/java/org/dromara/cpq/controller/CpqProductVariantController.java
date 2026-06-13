package org.dromara.cpq.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.domain.bo.CpqProductVariantBo;
import org.dromara.cpq.domain.vo.CpqProductVariantVo;
import org.dromara.cpq.service.ICpqProductVariantService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * CPQ 产品变体管理（阶段2）
 * 端点前缀：/cpq/product/variant
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/product/variant")
public class CpqProductVariantController extends BaseController {

    private final ICpqProductVariantService variantService;

    /**
     * 查询某个产品型号的所有变体
     */
    @GetMapping("/list")
    public R<List<CpqProductVariantVo>> list(@RequestParam Long modelId) {
        return R.ok(variantService.selectVariantListByModelId(modelId));
    }

    @GetMapping("/{variantId}")
    public R<CpqProductVariantVo> getInfo(@PathVariable Long variantId) {
        return R.ok(variantService.selectVariantById(variantId));
    }

    /**
     * 批量查询变体（按ID列表），用于前端列表展示变体名称
     */
    @GetMapping("/batch")
    public R<List<CpqProductVariantVo>> batch(@RequestParam List<Long> ids) {
        return R.ok(variantService.selectVariantByIds(ids));
    }

    @Log(title = "CPQ产品变体", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@Validated @RequestBody CpqProductVariantBo bo) {
        return toAjax(variantService.insertVariant(bo));
    }

    @Log(title = "CPQ产品变体", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@Validated @RequestBody CpqProductVariantBo bo) {
        return toAjax(variantService.updateVariant(bo));
    }

    @Log(title = "CPQ产品变体", businessType = BusinessType.DELETE)
    @DeleteMapping("/{variantId}")
    public R<Void> remove(@PathVariable Long variantId) {
        return toAjax(variantService.deleteVariant(variantId));
    }
}
