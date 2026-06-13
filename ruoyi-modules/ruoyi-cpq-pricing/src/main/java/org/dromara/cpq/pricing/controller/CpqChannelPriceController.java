package org.dromara.cpq.pricing.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.pricing.domain.bo.CpqChannelPriceBo;
import org.dromara.cpq.pricing.domain.vo.CpqChannelPriceVo;
import org.dromara.cpq.pricing.service.ICpqChannelPriceService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * CPQ 渠道价格管理
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/pricing/channelprice")
public class CpqChannelPriceController extends BaseController {

    private final ICpqChannelPriceService channelPriceService;

    @GetMapping("/list")
    public R<List<CpqChannelPriceVo>> list(CpqChannelPriceBo bo) {
        return R.ok(channelPriceService.selectChannelPriceList(bo));
    }

    @GetMapping("/{channelPriceId}")
    public R<CpqChannelPriceVo> getInfo(@PathVariable Long channelPriceId) {
        return R.ok(channelPriceService.selectChannelPriceById(channelPriceId));
    }

    @Log(title = "CPQ渠道价格", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@Validated @RequestBody CpqChannelPriceBo bo) {
        return toAjax(channelPriceService.insertChannelPrice(bo));
    }

    @Log(title = "CPQ渠道价格", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@Validated @RequestBody CpqChannelPriceBo bo) {
        return toAjax(channelPriceService.updateChannelPrice(bo));
    }

    @Log(title = "CPQ渠道价格", businessType = BusinessType.DELETE)
    @DeleteMapping("/{channelPriceId}")
    public R<Void> remove(@PathVariable Long channelPriceId) {
        return toAjax(channelPriceService.deleteChannelPrice(channelPriceId));
    }
}
