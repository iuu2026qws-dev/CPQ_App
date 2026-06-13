package org.dromara.cpq.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.domain.bo.CpqProductModelBo;
import org.dromara.cpq.domain.vo.CpqProductModelVo;
import org.dromara.cpq.service.ICpqProductModelService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * CPQ 产品模型管理（支持产品目录下的产品 CRUD）
 *
 * @author CPQ Team
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/product/model")
public class CpqProductModelController extends BaseController {

    private final ICpqProductModelService modelService;

    @GetMapping("/list")
    public TableDataInfo<CpqProductModelVo> list(CpqProductModelBo bo, PageQuery pageQuery) {
        return modelService.selectPageModelList(bo, pageQuery);
    }

    @GetMapping("/{modelId}")
    public R<CpqProductModelVo> getInfo(@PathVariable Long modelId) {
        return R.ok(modelService.selectModelById(modelId));
    }

    @GetMapping("/code/{modelCode}")
    public R<CpqProductModelVo> getByCode(@PathVariable String modelCode) {
        return R.ok(modelService.selectModelByCode(modelCode));
    }

    @GetMapping("/search")
    public R<List<CpqProductModelVo>> search(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String lifecycleStatus,
            @RequestParam(required = false) String configType) {
        return R.ok(modelService.searchModels(keyword, lifecycleStatus, configType));
    }

    @Log(title = "CPQ产品", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@Validated @RequestBody CpqProductModelBo bo) {
        return toAjax(modelService.insertModel(bo));
    }

    @Log(title = "CPQ产品", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@Validated @RequestBody CpqProductModelBo bo) {
        return toAjax(modelService.updateModel(bo));
    }

    @Log(title = "CPQ产品", businessType = BusinessType.DELETE)
    @DeleteMapping("/{modelId}")
    public R<Void> remove(@PathVariable Long modelId) {
        return toAjax(modelService.deleteModel(modelId));
    }

    @Log(title = "CPQ产品", businessType = BusinessType.DELETE)
    @DeleteMapping("/batch")
    public R<Void> removeBatch(@RequestBody Long[] modelIds) {
        return toAjax(modelService.deleteModelByIds(modelIds));
    }
}
