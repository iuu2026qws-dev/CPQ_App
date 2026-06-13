package org.dromara.cpq.config.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.config.domain.bo.CpqAttributeOptionBo;
import org.dromara.cpq.config.domain.vo.CpqAttributeOptionVo;
import org.dromara.cpq.config.service.ICpqAttributeOptionService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/config/attributeoption")
public class CpqAttributeOptionController extends BaseController {

    private final ICpqAttributeOptionService cpqAttributeOptionService;

    @GetMapping("/list")
    public R<List<CpqAttributeOptionVo>> list(CpqAttributeOptionBo bo) {
        return R.ok(cpqAttributeOptionService.selectList(bo));
    }

    @GetMapping("{optionId}")
    public R<CpqAttributeOptionVo> getInfo(@PathVariable Long optionId) {
        return R.ok(cpqAttributeOptionService.selectById(optionId));
    }

    @Log(title = "CPQ属性选项", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@Validated @RequestBody CpqAttributeOptionBo bo) {
        return toAjax(cpqAttributeOptionService.insert(bo));
    }

    @Log(title = "CPQ属性选项", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@Validated @RequestBody CpqAttributeOptionBo bo) {
        return toAjax(cpqAttributeOptionService.update(bo));
    }

    @Log(title = "CPQ属性选项", businessType = BusinessType.DELETE)
    @DeleteMapping("{optionId}")
    public R<Void> remove(@PathVariable Long optionId) {
        return toAjax(cpqAttributeOptionService.delete(optionId));
    }
}
