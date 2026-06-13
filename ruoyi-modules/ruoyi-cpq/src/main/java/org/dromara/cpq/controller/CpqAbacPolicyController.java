package org.dromara.cpq.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.domain.bo.CpqAbacPolicyBo;
import org.dromara.cpq.domain.vo.CpqAbacPolicyVo;
import org.dromara.cpq.service.ICpqAbacPolicyService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * CPQ ABAC策略管理
 *
 * @author CPQ Team
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/abac/policy")
public class CpqAbacPolicyController extends BaseController {

    private final ICpqAbacPolicyService policyService;

    @GetMapping("/list")
    public R<List<CpqAbacPolicyVo>> list(CpqAbacPolicyBo bo) {
        return R.ok(policyService.selectPolicyList(bo));
    }

    @GetMapping("/{policyId}")
    public R<CpqAbacPolicyVo> getInfo(@PathVariable Long policyId) {
        return R.ok(policyService.selectPolicyById(policyId));
    }

    @Log(title = "ABAC策略", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@Validated @RequestBody CpqAbacPolicyBo bo) {
        return toAjax(policyService.insertPolicy(bo));
    }

    @Log(title = "ABAC策略", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@Validated @RequestBody CpqAbacPolicyBo bo) {
        return toAjax(policyService.updatePolicy(bo));
    }

    @Log(title = "ABAC策略", businessType = BusinessType.DELETE)
    @DeleteMapping("/{policyId}")
    public R<Void> remove(@PathVariable Long policyId) {
        return toAjax(policyService.deletePolicy(policyId));
    }
}
