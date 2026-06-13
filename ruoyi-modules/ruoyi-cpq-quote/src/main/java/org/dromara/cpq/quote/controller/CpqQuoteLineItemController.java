package org.dromara.cpq.quote.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.quote.domain.bo.CpqQuoteLineItemBo;
import org.dromara.cpq.quote.domain.vo.CpqQuoteLineItemVo;
import org.dromara.cpq.quote.service.ICpqQuoteLineItemService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/quote/lineitem")
public class CpqQuoteLineItemController extends BaseController {
    private final ICpqQuoteLineItemService lineItemService;

    @GetMapping("/list") public TableDataInfo<CpqQuoteLineItemVo> list(CpqQuoteLineItemBo bo, PageQuery pageQuery) { return lineItemService.selectPageList(bo, pageQuery); }
    @GetMapping("/{lineId}") public R<CpqQuoteLineItemVo> getInfo(@PathVariable Long lineId) { return R.ok(lineItemService.selectById(lineId)); }
    @Log(title = "报价行项目", businessType = BusinessType.INSERT) @RepeatSubmit() @PostMapping public R<Void> add(@Validated @RequestBody CpqQuoteLineItemBo bo) { return toAjax(lineItemService.insert(bo)); }
    @Log(title = "报价行项目", businessType = BusinessType.UPDATE) @RepeatSubmit() @PutMapping public R<Void> edit(@Validated @RequestBody CpqQuoteLineItemBo bo) { return toAjax(lineItemService.update(bo)); }
    @Log(title = "报价行项目", businessType = BusinessType.DELETE) @DeleteMapping("/{lineId}") public R<Void> remove(@PathVariable Long lineId) { return toAjax(lineItemService.deleteById(lineId)); }
    @Log(title = "报价行项目", businessType = BusinessType.DELETE) @DeleteMapping("/batch") public R<Void> removeBatch(@RequestBody Long[] lineIds) { return toAjax(lineItemService.deleteByIds(lineIds)); }
}
