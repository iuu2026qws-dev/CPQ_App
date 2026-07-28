package org.dromara.cpq.approval.service;

import cn.hutool.json.JSONUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.cpq.approval.enums.ApprovalScene;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 统一审批网关 — 所有业务场景调用这一个入口。
 * <p>
 * 核心逻辑：
 * 1. 保存业务快照
 * 2. 匹配审批规则
 * 3. 如果无规则匹配 → 自动通过
 * 4. 如果有规则匹配 → 启动 Warm-Flow 流程实例（通过 flow_code 找定义）
 * 5. 更新业务快照关联流程实例ID
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class ApprovalGatewayService {
    private final JdbcTemplate jdbc;
    private final RuleEngineService ruleEngine;
    // Warm-Flow 服务（如果编译报错，先注释掉，后续解决依赖）
    // private final InsService insService;
    // private final DefService defService;

    /**
     * 提交审批
     * @param scene 业务场景
     * @param bizId 业务主键ID
     * @param context 业务上下文（供规则匹配和数据快照）
     * @param summary 业务摘要（审批列表展示用）
     * @return 审批结果
     */
    @Transactional
    public Map<String, Object> submit(ApprovalScene scene, Long bizId, Map<String, Object> context, String summary) {
        // 1. 保存业务快照
        long snapshotId = System.currentTimeMillis() % 100000000 + 300000000L;
        String bizData = JSONUtil.toJsonStr(context);
        jdbc.update(
            "INSERT INTO cpq_approval_business_snapshot (snapshot_id, tenant_id, scene, business_id, business_summary, business_data, status, create_time) VALUES (?, '000000', ?, ?, ?, ?, 'PENDING', NOW())",
            snapshotId, scene.name(), bizId, summary, bizData);

        // 2. 匹配规则
        var rule = ruleEngine.match(scene, context);
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("snapshotId", snapshotId);
        result.put("scene", scene.name());
        result.put("businessId", bizId);

        if (rule == null) {
            result.put("status", "AUTO_APPROVED");
            result.put("message", "无需审批，自动通过");
            jdbc.update("UPDATE cpq_approval_business_snapshot SET status='APPROVED' WHERE snapshot_id=?", snapshotId);
            return result;
        }

        // 3. 提取规则信息
        String flowCode = (String) rule.get("flow_code");
        Long ruleId = (Long) rule.get("rule_id");
        result.put("ruleId", ruleId);
        result.put("flowCode", flowCode);
        result.put("status", "PENDING");
        result.put("message", "已提交审批");

        // 4. 如果有 flowCode，尝试启动 Warm-Flow（暂时用占位，后续接入）
        if (flowCode != null && !flowCode.isBlank()) {
            try {
                // TODO: Warm-Flow 启动实例
                // var def = defService.getOne(new LambdaQueryWrapper<FlowDefinition>()
                //     .eq(FlowDefinition::getFlowCode, flowCode)
                //     .eq(FlowDefinition::getIsPublish, 1)
                //     .orderByDesc(FlowDefinition::getVersion)
                //     .last("LIMIT 1"));
                // if (def != null) {
                //     FlowParams params = new FlowParams();
                //     params.setHandler(String.valueOf(context.getOrDefault("initiatorId", "1")));
                //     Instance instance = insService.start(bizId.toString(), params);
                //     result.put("flowInstanceId", instance.getId());
                //     jdbc.update("UPDATE cpq_approval_business_snapshot SET flow_instance_id=? WHERE snapshot_id=?", instance.getId(), snapshotId);
                // }
                result.put("flowInstanceId", null); // 占位
            } catch (Exception e) {
                log.warn("Warm-Flow启动失败(非阻塞): {}", e.getMessage());
            }
        }

        return result;
    }

    /** 查询审批状态 */
    public Map<String, Object> getStatus(ApprovalScene scene, Long bizId) {
        var rows = jdbc.queryForList(
            "SELECT * FROM cpq_approval_business_snapshot WHERE tenant_id='000000' AND scene=? AND business_id=? ORDER BY create_time DESC LIMIT 1",
            scene.name(), bizId);
        if (rows.isEmpty()) return Map.of("status", "NOT_FOUND");
        return rows.get(0);
    }
}
