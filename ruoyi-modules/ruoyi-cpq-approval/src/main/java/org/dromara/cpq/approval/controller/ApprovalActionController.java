package org.dromara.cpq.approval.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.domain.R;
import org.dromara.common.web.core.BaseController;
import org.dromara.cpq.approval.service.ApprovalRouteService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 审批操作控制器 — 处理审批动作（通过/驳回/转审/加签）
 */
@Slf4j
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/approval/action")
public class ApprovalActionController extends BaseController {
    private final ApprovalRouteService approvalRouteService;

    /**
     * 处理审批动作
     * POST /cpq/approval/action/process
     * Body: { chainId, approverId, approverName, action, comment }
     */
    @PostMapping("/process")
    public R<Void> processAction(@RequestBody Map<String, Object> body) {
        Long chainId = Long.valueOf(body.get("chainId").toString());
        Long approverId = Long.valueOf(body.get("approverId").toString());
        String approverName = (String) body.get("approverName");
        String action = (String) body.get("action");
        String comment = (String) body.getOrDefault("comment", "");
        log.info("审批操作: chainId={}, approver={}, action={}", chainId, approverName, action);
        approvalRouteService.processAction(chainId, approverId, approverName, action, comment);
        return R.ok();
    }

    /**
     * 手动触发SLA超时升级
     * POST /cpq/approval/action/escalate
     */
    @PostMapping("/escalate")
    public R<Void> escalateTimeout() {
        log.info("手动触发SLA超时升级");
        approvalRouteService.escalateTimeout();
        return R.ok();
    }
}
