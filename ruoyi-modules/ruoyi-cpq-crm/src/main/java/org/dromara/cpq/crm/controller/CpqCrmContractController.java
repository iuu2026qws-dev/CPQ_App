package org.dromara.cpq.crm.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.crm.domain.bo.CpqCrmContractBo;
import org.dromara.cpq.crm.domain.vo.CpqCrmContractVo;
import org.dromara.cpq.crm.service.ICpqCrmContractService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

/**
 * 合同 Controller
 *
 * @author CPQ Team
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/crm/contract")
public class CpqCrmContractController extends BaseController {

    private final ICpqCrmContractService contractService;

    /** 分页查询合同列表 */
    @GetMapping("/list")
    public TableDataInfo<CpqCrmContractVo> list(CpqCrmContractBo bo, PageQuery pageQuery) {
        return contractService.queryPageList(bo, pageQuery);
    }

    /** 获取合同详情 */
    @GetMapping("/{id}")
    public R<CpqCrmContractVo> getById(@PathVariable Long id) {
        return R.ok(contractService.queryById(id));
    }

    /** 新增合同 */
    @Log(title = "合同管理", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@RequestBody CpqCrmContractBo bo) {
        return toAjax(contractService.insertByBo(bo));
    }

    /** 从商机生成合同 */
    @Log(title = "合同管理", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping("/from-opportunity")
    public R<Void> fromOpportunity(@RequestBody Map<String, Object> params) {
        return toAjax(contractService.fromOpportunity(params));
    }

    /** 更新合同 */
    @Log(title = "合同管理", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@RequestBody CpqCrmContractBo bo) {
        return toAjax(contractService.updateByBo(bo));
    }

    /** 变更合同状态 */
    @Log(title = "合同管理", businessType = BusinessType.UPDATE)
    @PutMapping("/{id}/status")
    public R<Void> advanceStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        return toAjax(contractService.advanceStatus(id, body.get("status")));
    }

    /** 删除合同 */
    @Log(title = "合同管理", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public R<Void> remove(@PathVariable Long[] ids) {
        return toAjax(contractService.deleteWithValidByIds(Arrays.asList(ids)));
    }

    /** 获取合同关联的订单列表 */
    @GetMapping("/{id}/orders")
    public R<List<?>> getOrders(@PathVariable Long id) {
        return R.ok(contractService.queryOrdersByContractId(id));
    }
}
