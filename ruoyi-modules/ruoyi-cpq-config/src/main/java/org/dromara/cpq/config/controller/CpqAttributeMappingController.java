package org.dromara.cpq.config.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.config.domain.bo.CpqAttributeMappingBo;
import org.dromara.cpq.config.domain.vo.CpqAttributeMappingVo;
import org.dromara.cpq.config.service.ICpqAttributeMappingService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/config/attributemapping")
public class CpqAttributeMappingController extends BaseController {

    private final ICpqAttributeMappingService cpqAttributeMappingService;

    @GetMapping("/list")
    public R<List<CpqAttributeMappingVo>> list(CpqAttributeMappingBo bo) {
        return R.ok(cpqAttributeMappingService.selectList(bo));
    }

    @GetMapping("{mappingId}")
    public R<CpqAttributeMappingVo> getInfo(@PathVariable Long mappingId) {
        return R.ok(cpqAttributeMappingService.selectById(mappingId));
    }

    @Log(title = "CPQ属性映射", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@Validated @RequestBody CpqAttributeMappingBo bo) {
        return toAjax(cpqAttributeMappingService.insert(bo));
    }

    @Log(title = "CPQ属性映射", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@Validated @RequestBody CpqAttributeMappingBo bo) {
        return toAjax(cpqAttributeMappingService.update(bo));
    }

    @Log(title = "CPQ属性映射", businessType = BusinessType.DELETE)
    @DeleteMapping("{mappingId}")
    public R<Void> remove(@PathVariable Long mappingId) {
        return toAjax(cpqAttributeMappingService.delete(mappingId));
    }
}
