package org.dromara.cpq.pricing.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.pricing.domain.bo.CpqPriceBookEntryBo;
import org.dromara.cpq.pricing.domain.vo.CpqPriceBookEntryVo;
import org.dromara.cpq.pricing.service.ICpqPriceBookEntryService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * CPQ 价格手册条目管理
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/pricing/entry")
public class CpqPriceBookEntryController extends BaseController {

    private final ICpqPriceBookEntryService entryService;

    @GetMapping("/list")
    public R<List<CpqPriceBookEntryVo>> list(CpqPriceBookEntryBo bo) {
        return R.ok(entryService.selectEntryList(bo));
    }

    @GetMapping("/{entryId}")
    public R<CpqPriceBookEntryVo> getInfo(@PathVariable Long entryId) {
        return R.ok(entryService.selectEntryById(entryId));
    }

    @Log(title = "CPQ价格手册条目", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@Validated @RequestBody CpqPriceBookEntryBo bo) {
        return toAjax(entryService.insertEntry(bo));
    }

    @Log(title = "CPQ价格手册条目", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@Validated @RequestBody CpqPriceBookEntryBo bo) {
        return toAjax(entryService.updateEntry(bo));
    }

    @Log(title = "CPQ价格手册条目", businessType = BusinessType.DELETE)
    @DeleteMapping("/{entryId}")
    public R<Void> remove(@PathVariable Long entryId) {
        return toAjax(entryService.deleteEntry(entryId));
    }
}
