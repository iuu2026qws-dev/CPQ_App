package org.dromara.cpq.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.domain.bo.CpqProductSupersessionBo;
import org.dromara.cpq.domain.vo.CpqProductSupersessionVo;
import org.dromara.cpq.service.ICpqProductSupersessionService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * CPQ 产品替代关系管理（菜单 50084）
 *
 * @author CPQ Team
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/product/supersession")
public class CpqProductSupersessionController extends BaseController {

    private final ICpqProductSupersessionService supersessionService;

    @GetMapping("/list")
    public R<List<CpqProductSupersessionVo>> list(CpqProductSupersessionBo bo) {
        return R.ok(supersessionService.selectSupersessionList(bo));
    }

    @GetMapping("/{supersessionId}")
    public R<CpqProductSupersessionVo> getInfo(@PathVariable Long supersessionId) {
        return R.ok(supersessionService.selectSupersessionById(supersessionId));
    }

    @Log(title = "CPQ产品替代关系", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@Validated @RequestBody CpqProductSupersessionBo bo) {
        return toAjax(supersessionService.insertSupersession(bo));
    }

    @Log(title = "CPQ产品替代关系", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@Validated @RequestBody CpqProductSupersessionBo bo) {
        return toAjax(supersessionService.updateSupersession(bo));
    }

    @Log(title = "CPQ产品替代关系", businessType = BusinessType.DELETE)
    @DeleteMapping("/{supersessionId}")
    public R<Void> remove(@PathVariable Long supersessionId) {
        return toAjax(supersessionService.deleteSupersession(supersessionId));
    }

    @GetMapping("/whereUsed/{modelId}")
    public R<List<CpqProductSupersessionVo>> whereUsed(@PathVariable Long modelId) {
        return R.ok(supersessionService.whereUsed(modelId));
    }

    @GetMapping("/recommend/{modelId}")
    public R<List<CpqProductSupersessionVo>> recommendReplacement(@PathVariable Long modelId) {
        return R.ok(supersessionService.recommendReplacement(modelId));
    }
}
