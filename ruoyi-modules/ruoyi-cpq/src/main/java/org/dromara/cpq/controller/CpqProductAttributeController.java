package org.dromara.cpq.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.domain.bo.CpqProductAttributeBo;
import org.dromara.cpq.domain.vo.CpqProductAttributeVo;
import org.dromara.cpq.service.ICpqProductAttributeService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * CPQ 产品属性管理
 *
 * @author CPQ Team
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/product/attribute")
public class CpqProductAttributeController extends BaseController {

    private final ICpqProductAttributeService attributeService;

    @GetMapping("/list")
    public R<List<CpqProductAttributeVo>> list(CpqProductAttributeBo bo) {
        return R.ok(attributeService.selectAttributeList(bo));
    }

    @GetMapping("/byModel/{modelId}")
    public R<List<CpqProductAttributeVo>> byModel(@PathVariable Long modelId) {
        return R.ok(attributeService.selectAttributeByModelId(modelId));
    }

    @GetMapping("/byCategory/{modelId}/{attrCategory}")
    public R<List<CpqProductAttributeVo>> byCategory(@PathVariable Long modelId, @PathVariable String attrCategory) {
        return R.ok(attributeService.selectAttributeByCategory(modelId, attrCategory));
    }

    @GetMapping("/{attributeId}")
    public R<CpqProductAttributeVo> getInfo(@PathVariable Long attributeId) {
        return R.ok(attributeService.selectAttributeById(attributeId));
    }

    @Log(title = "CPQ产品属性", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@Validated @RequestBody CpqProductAttributeBo bo) {
        return toAjax(attributeService.insertAttribute(bo));
    }

    @Log(title = "CPQ产品属性", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@Validated @RequestBody CpqProductAttributeBo bo) {
        return toAjax(attributeService.updateAttribute(bo));
    }

    @Log(title = "CPQ产品属性", businessType = BusinessType.DELETE)
    @DeleteMapping("/{attributeId}")
    public R<Void> remove(@PathVariable Long attributeId) {
        return toAjax(attributeService.deleteAttribute(attributeId));
    }
}
