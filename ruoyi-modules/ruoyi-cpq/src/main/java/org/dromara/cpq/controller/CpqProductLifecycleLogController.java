package org.dromara.cpq.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.domain.bo.CpqProductLifecycleLogBo;
import org.dromara.cpq.domain.vo.CpqProductLifecycleLogVo;
import org.dromara.cpq.service.ICpqProductLifecycleLogService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * CPQ 产品生命周期日志管理
 *
 * @author CPQ Team
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/product/lifecycle")
public class CpqProductLifecycleLogController extends BaseController {

    private final ICpqProductLifecycleLogService lifecycleLogService;

    @GetMapping("/list")
    public R<List<CpqProductLifecycleLogVo>> list(CpqProductLifecycleLogBo bo) {
        return R.ok(lifecycleLogService.selectLifecycleLogList(bo));
    }

    @GetMapping("/byModel/{modelId}")
    public R<List<CpqProductLifecycleLogVo>> byModel(@PathVariable Long modelId) {
        return R.ok(lifecycleLogService.selectLifecycleLogByModelId(modelId));
    }

    @GetMapping("/{logId}")
    public R<CpqProductLifecycleLogVo> getInfo(@PathVariable Long logId) {
        return R.ok(lifecycleLogService.selectLifecycleLogById(logId));
    }

    @Log(title = "CPQ生命周期日志", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@Validated @RequestBody CpqProductLifecycleLogBo bo) {
        return toAjax(lifecycleLogService.insertLifecycleLog(bo));
    }

    @Log(title = "CPQ生命周期日志", businessType = BusinessType.DELETE)
    @DeleteMapping("/{logId}")
    public R<Void> remove(@PathVariable Long logId) {
        return toAjax(lifecycleLogService.deleteLifecycleLog(logId));
    }
}
