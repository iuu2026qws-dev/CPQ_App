package org.dromara.cpq.config.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.config.domain.bo.CpqCompatibilityMatrixBo;
import org.dromara.cpq.config.domain.vo.CpqCompatibilityMatrixVo;
import org.dromara.cpq.config.service.ICpqCompatibilityMatrixService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/config/compatibility")
public class CpqCompatibilityMatrixController extends BaseController {

    private final ICpqCompatibilityMatrixService cpqCompatibilityMatrixService;

    @GetMapping("/list")
    public R<List<CpqCompatibilityMatrixVo>> list(CpqCompatibilityMatrixBo bo) {
        return R.ok(cpqCompatibilityMatrixService.selectList(bo));
    }

    @GetMapping("{matrixId}")
    public R<CpqCompatibilityMatrixVo> getInfo(@PathVariable Long matrixId) {
        return R.ok(cpqCompatibilityMatrixService.selectById(matrixId));
    }

    @Log(title = "CPQ兼容性矩阵", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@Validated @RequestBody CpqCompatibilityMatrixBo bo) {
        return toAjax(cpqCompatibilityMatrixService.insert(bo));
    }

    @Log(title = "CPQ兼容性矩阵", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@Validated @RequestBody CpqCompatibilityMatrixBo bo) {
        return toAjax(cpqCompatibilityMatrixService.update(bo));
    }

    @Log(title = "CPQ兼容性矩阵", businessType = BusinessType.DELETE)
    @DeleteMapping("{matrixId}")
    public R<Void> remove(@PathVariable Long matrixId) {
        return toAjax(cpqCompatibilityMatrixService.delete(matrixId));
    }
}
