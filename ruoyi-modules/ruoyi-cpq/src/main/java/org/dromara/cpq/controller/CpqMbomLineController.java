package org.dromara.cpq.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.domain.bo.CpqMbomLineBo;
import org.dromara.cpq.domain.vo.CpqMbomLineVo;
import org.dromara.cpq.service.ICpqMbomLineService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * CPQ MBOM 管理
 *
 * @author CPQ Team
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/product/mbom")
public class CpqMbomLineController extends BaseController {

    private final ICpqMbomLineService mbomLineService;

    @GetMapping("/list")
    public R<List<CpqMbomLineVo>> list(CpqMbomLineBo bo) {
        return R.ok(mbomLineService.selectMbomLineList(bo));
    }

    @GetMapping("/byModel/{modelId}")
    public R<List<CpqMbomLineVo>> byModel(@PathVariable Long modelId) {
        return R.ok(mbomLineService.selectMbomLineByModelId(modelId));
    }

    @GetMapping("/bySbomLine/{sbomLineId}")
    public R<List<CpqMbomLineVo>> bySbomLine(@PathVariable Long sbomLineId) {
        return R.ok(mbomLineService.selectMbomLineBySbomLineId(sbomLineId));
    }

    @GetMapping("/{mbomLineId}")
    public R<CpqMbomLineVo> getInfo(@PathVariable Long mbomLineId) {
        return R.ok(mbomLineService.selectMbomLineById(mbomLineId));
    }

    @Log(title = "CPQ MBOM行", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@Validated @RequestBody CpqMbomLineBo bo) {
        return toAjax(mbomLineService.insertMbomLine(bo));
    }

    @Log(title = "CPQ MBOM行", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@Validated @RequestBody CpqMbomLineBo bo) {
        return toAjax(mbomLineService.updateMbomLine(bo));
    }

    @Log(title = "CPQ MBOM行", businessType = BusinessType.DELETE)
    @DeleteMapping("/{mbomLineId}")
    public R<Void> remove(@PathVariable Long mbomLineId) {
        return toAjax(mbomLineService.deleteMbomLine(mbomLineId));
    }
}
