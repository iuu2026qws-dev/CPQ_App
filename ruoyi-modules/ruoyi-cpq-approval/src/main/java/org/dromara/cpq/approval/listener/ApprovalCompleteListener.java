package org.dromara.cpq.approval.listener;

import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

/**
 * Warm-Flow 流程完成回调监听器。
 * 先创建骨架，后续流程实例接入后完善。
 */
@Slf4j
@Component
public class ApprovalCompleteListener {
    private final JdbcTemplate jdbc;
    public ApprovalCompleteListener(JdbcTemplate jdbc) { this.jdbc = jdbc; }

    /** 通过 flow_instance_id 找到业务快照并更新状态 */
    public void onFlowComplete(Long flowInstanceId, String flowStatus) {
        String status = "2".equals(flowStatus) ? "APPROVED" : "REJECTED";
        jdbc.update("UPDATE cpq_approval_business_snapshot SET status=? WHERE flow_instance_id=?", status, flowInstanceId);
        log.info("[Approval] 流程完成: instanceId={}, status={}", flowInstanceId, status);
    }
}
