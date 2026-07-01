package org.dromara.cpq.crm.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.crm.domain.bo.CpqCrmOrderBo;
import org.dromara.cpq.crm.domain.vo.CpqCrmOrderLineVo;
import org.dromara.cpq.crm.domain.vo.CpqCrmOrderVo;
import org.dromara.cpq.crm.service.ICpqCrmOrderService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

/**
 * 订单 Controller
 *
 * @author CPQ Team
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/crm/order")
public class CpqCrmOrderController extends BaseController {

    private final ICpqCrmOrderService orderService;

    /** 分页查询订单列表 */
    @GetMapping("/list")
    public TableDataInfo<CpqCrmOrderVo> list(CpqCrmOrderBo bo, PageQuery pageQuery) {
        return orderService.queryPageList(bo, pageQuery);
    }

    /** 获取订单详情（含明细） */
    @GetMapping("/{id}")
    public R<CpqCrmOrderVo> getById(@PathVariable Long id) {
        return R.ok(orderService.queryById(id));
    }

    /** 新增订单 */
    @Log(title = "订单管理", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@RequestBody CpqCrmOrderBo bo) {
        return toAjax(orderService.insertByBo(bo));
    }

    /** 从报价生成订单 */
    @Log(title = "订单管理", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping("/from-quote")
    public R<Void> fromQuote(@RequestBody Map<String, Object> params) {
        return toAjax(orderService.fromQuote(params));
    }

    /** 更新订单 */
    @Log(title = "订单管理", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@RequestBody CpqCrmOrderBo bo) {
        return toAjax(orderService.updateByBo(bo));
    }

    /** 变更订单状态 */
    @Log(title = "订单管理", businessType = BusinessType.UPDATE)
    @PutMapping("/{id}/status")
    public R<Void> advanceStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        return toAjax(orderService.advanceStatus(id, body.get("status")));
    }

    /** 删除订单 */
    @Log(title = "订单管理", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public R<Void> remove(@PathVariable Long[] ids) {
        return toAjax(orderService.deleteWithValidByIds(Arrays.asList(ids)));
    }

    /** 查询订单明细列表 */
    @GetMapping("/{id}/lines")
    public R<List<CpqCrmOrderLineVo>> getLines(@PathVariable Long id) {
        return R.ok(orderService.queryLinesByOrderId(id));
    }

    /** 新增订单明细行 */
    @Log(title = "订单管理", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping("/{id}/line")
    public R<Void> addLine(@PathVariable Long id, @RequestBody CpqCrmOrderLineVo line) {
        return toAjax(orderService.addLine(id, line));
    }

    /** 更新订单明细行 */
    @Log(title = "订单管理", businessType = BusinessType.UPDATE)
    @PutMapping("/{id}/line")
    public R<Void> updateLine(@PathVariable Long id, @RequestBody CpqCrmOrderLineVo line) {
        return toAjax(orderService.updateLine(id, line));
    }

    /** 删除订单明细行 */
    @Log(title = "订单管理", businessType = BusinessType.DELETE)
    @DeleteMapping("/{id}/line/{lineId}")
    public R<Void> deleteLine(@PathVariable Long id, @PathVariable Long lineId) {
        return toAjax(orderService.deleteLine(id, lineId));
    }
}
