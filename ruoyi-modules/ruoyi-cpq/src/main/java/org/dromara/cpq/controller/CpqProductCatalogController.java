package org.dromara.cpq.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.domain.bo.CpqProductCatalogBo;
import org.dromara.cpq.domain.vo.CpqProductCatalogVo;
import org.dromara.cpq.service.ICpqProductCatalogService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * CPQ 产品目录管理（菜单 50081）
 *
 * @author CPQ Team
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/product/catalog")
public class CpqProductCatalogController extends BaseController {

    private final ICpqProductCatalogService catalogService;

    @GetMapping("/list")
    public R<List<CpqProductCatalogVo>> list(CpqProductCatalogBo bo) {
        return R.ok(catalogService.selectCatalogList(bo));
    }

    @GetMapping("/{catalogId}")
    public R<CpqProductCatalogVo> getInfo(@PathVariable Long catalogId) {
        return R.ok(catalogService.selectCatalogById(catalogId));
    }

    @Log(title = "CPQ产品目录", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@Validated @RequestBody CpqProductCatalogBo bo) {
        return toAjax(catalogService.insertCatalog(bo));
    }

    @Log(title = "CPQ产品目录", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@Validated @RequestBody CpqProductCatalogBo bo) {
        return toAjax(catalogService.updateCatalog(bo));
    }

    @Log(title = "CPQ产品目录", businessType = BusinessType.DELETE)
    @DeleteMapping("/{catalogId}")
    public R<Void> remove(@PathVariable Long catalogId) {
        return toAjax(catalogService.deleteCatalog(catalogId));
    }
}
