package org.dromara.cpq.pricing.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.pricing.domain.bo.CpqPriceBookBo;
import org.dromara.cpq.pricing.domain.vo.CpqPriceBookVo;
import org.dromara.cpq.pricing.service.ICpqPriceBookService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * CPQ 价格手册管理（菜单 50091）
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/pricing/pricebook")
public class CpqPriceBookController extends BaseController {

    private final ICpqPriceBookService priceBookService;

    @GetMapping("/list")
    public R<List<CpqPriceBookVo>> list(CpqPriceBookBo bo) {
        return R.ok(priceBookService.selectPriceBookList(bo));
    }

    @GetMapping("/{priceBookId}")
    public R<CpqPriceBookVo> getInfo(@PathVariable Long priceBookId) {
        return R.ok(priceBookService.selectPriceBookById(priceBookId));
    }

    @Log(title = "CPQ价格手册", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@Validated @RequestBody CpqPriceBookBo bo) {
        return toAjax(priceBookService.insertPriceBook(bo));
    }

    @Log(title = "CPQ价格手册", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@Validated @RequestBody CpqPriceBookBo bo) {
        return toAjax(priceBookService.updatePriceBook(bo));
    }

    @Log(title = "CPQ价格手册", businessType = BusinessType.DELETE)
    @DeleteMapping("/{priceBookId}")
    public R<Void> remove(@PathVariable Long priceBookId) {
        return toAjax(priceBookService.deletePriceBook(priceBookId));
    }
}
