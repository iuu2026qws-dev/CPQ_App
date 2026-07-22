package org.dromara.cpq.quote.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.quote.domain.bo.CpqQuoteBo;
import org.dromara.cpq.quote.domain.vo.CpqQuoteVo;
import org.dromara.cpq.quote.service.ICpqQuoteService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/quote/header")
public class CpqQuoteController extends BaseController {

    private final ICpqQuoteService quoteService;

    @GetMapping("/list")
    public TableDataInfo<CpqQuoteVo> list(CpqQuoteBo bo, PageQuery pageQuery) {
        return quoteService.selectPageList(bo, pageQuery);
    }

    @GetMapping("/{quoteId}")
    public R<CpqQuoteVo> getInfo(@PathVariable Long quoteId) {
        return R.ok(quoteService.selectById(quoteId));
    }

    @Log(title = "报价单", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Long> add(@Validated @RequestBody CpqQuoteBo bo) {
        Long quoteId = quoteService.insert(bo);
        return R.ok(quoteId);
    }

    @Log(title = "报价单", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@Validated @RequestBody CpqQuoteBo bo) {
        return toAjax(quoteService.update(bo));
    }

    @Log(title = "报价单", businessType = BusinessType.DELETE)
    @DeleteMapping("/{quoteId}")
    public R<Void> remove(@PathVariable Long quoteId) {
        return toAjax(quoteService.deleteById(quoteId));
    }

    @Log(title = "报价单", businessType = BusinessType.DELETE)
    @DeleteMapping("/batch")
    public R<Void> removeBatch(@RequestBody Long[] quoteIds) {
        return toAjax(quoteService.deleteByIds(quoteIds));
    }
}
