package org.dromara.cpq.process.controller;

import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.domain.R;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;

/**
 * CPQ 工艺确认控制器 — 整合审批中心
 */
@Slf4j
@RestController
@RequestMapping("/cpq/process")
public class CpqProcessConfirmController {

    private final JdbcTemplate jdbc;

    public CpqProcessConfirmController(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    /**
     * 工艺确认 → 创建审批链（PENDING状态，需人工审批）
     */
    @PostMapping("/confirm")
    public R<Map<String, Object>> confirm(@RequestBody Map<String, Object> body) {
        Long resultId = toLong(body.get("resultId"));
        Long modelId = toLong(body.get("modelId"));
        String action = (String) body.getOrDefault("action", "CONFIRM");
        String comment = (String) body.getOrDefault("comment", "");
        // 防御：requirementText 可能是 String 或 Map（LLM 调用可能传错类型）
        Object reqTextObj = body.getOrDefault("requirementText", "");
        String requirementText = reqTextObj instanceof String ? (String) reqTextObj : "";
        Long replacedModelId = toLong(body.get("replacedModelId"));
        String replacedReason = (String) body.getOrDefault("replacedReason", "");

        // ★ CONFIRM_REPLACEMENT：从已有确认单取 resultId/modelId，不依赖请求参数
        if ("CONFIRM_REPLACEMENT".equalsIgnoreCase(action)) {
            Long confirmIdParam = toLong(body.get("confirmId"));
            if (confirmIdParam == null) return R.fail("confirmId不能为空");
            var confirmRow = jdbc.queryForList(
                "SELECT result_id, model_id, approval_chain_id FROM cpq_process_confirm WHERE confirm_id=? AND del_flag='0'", confirmIdParam);
            if (confirmRow.isEmpty()) return R.fail("确认单不存在");
            resultId = (Long) confirmRow.get(0).get("result_id");
            modelId = (Long) confirmRow.get(0).get("model_id");
        }

        if (resultId == null || modelId == null) {
            return R.fail("resultId和modelId不能为空");
        }

        // ★ 校验 resultId 和 modelId 真实存在，防止 LLM 编造假数据入库
        var matchCheck = jdbc.queryForList(
            "SELECT result_id FROM cpq_match_result WHERE result_id=?", resultId);
        if (matchCheck.isEmpty()) {
            return R.fail("resultId=" + resultId + " 不存在，请使用 match_product 返回的真实 resultId");
        }
        var modelCheck = jdbc.queryForList(
            "SELECT model_id FROM cpq_product_model WHERE model_id=? AND status='0' AND del_flag='0'", modelId);
        if (modelCheck.isEmpty()) {
            return R.fail("modelId=" + modelId + " 不存在，请使用 match_product 返回的真实 modelId");
        }

        // 幂等检查
        var existing = jdbc.queryForList(
            "SELECT * FROM cpq_process_confirm WHERE tenant_id='000000' AND result_id=? AND model_id=? AND del_flag='0'",
            resultId, modelId);
        if (!existing.isEmpty()) {
            String st = (String) existing.get(0).get("confirm_status");
            if (!"PENDING".equals(st)) {
                return R.ok(Map.of("message", "已处理，当前状态: " + st));
            }
        }

        String status;
        Long actualModelId = modelId;
        Long confirmId = System.currentTimeMillis() % 10000000;
        Long chainId = null;
        Long recordId = null;

        switch (action.toUpperCase()) {
            case "CONFIRM" -> {
                // ★ 创建审批链（PENDING，需人工审批）
                var approvalInfo = createApprovalChain(resultId, actualModelId);
                chainId = approvalInfo.get("chainId");
                recordId = approvalInfo.get("recordId");
                // ★ 自动生成需求文本（从match_result JSON提取，不依赖LLM传参）
                String autoReqText = requirementText != null && !requirementText.isEmpty()
                    ? requirementText
                    : buildRequirementText(resultId);
                jdbc.update(
                    "INSERT INTO cpq_process_confirm (confirm_id, tenant_id, result_id, model_id, " +
                    "approval_chain_id, confirm_status, requirement_text) VALUES (?, '000000', ?, ?, ?, 'PENDING', ?)",
                    confirmId, resultId, actualModelId, chainId, autoReqText);
                status = "PENDING";
                log.info("[Process] 已提交审批: resultId={}, chainId={}, recordId={}", resultId, chainId, recordId);
            }
            case "REJECT" -> {
                jdbc.update(
                    "INSERT INTO cpq_process_confirm (confirm_id, tenant_id, result_id, model_id, " +
                    "confirm_status, confirm_time, reject_reason) " +
                    "VALUES (?, '000000', ?, ?, 'REJECTED', ?, ?)",
                    confirmId, resultId, modelId, LocalDateTime.now().toString(), comment);
                status = "REJECTED";
            }
            case "REPLACE" -> {
                // ★ 按 modelCode 查找替代产品
                String replacedModelCode = (String) body.getOrDefault("replacedModelCode", "");
                if (replacedModelCode == null || replacedModelCode.isBlank()) {
                    return R.fail("替代产品型号不能为空");
                }
                String code = replacedModelCode.trim();
                // ★ 兼容用户输入 "ER14505" 和 "EVE-ER14505"
                var repl = jdbc.queryForList(
                    "SELECT model_id, model_code, model_name FROM cpq_product_model " +
                    "WHERE (model_code=? OR model_code=?) AND status='0' AND del_flag='0'",
                    code, "EVE-" + code);
                if (repl.isEmpty()) {
                    repl = jdbc.queryForList(
                        "SELECT model_id, model_code, model_name FROM cpq_product_model " +
                        "WHERE model_code LIKE ? AND status='0' AND del_flag='0' LIMIT 1",
                        "%" + code + "%");
                }
                if (repl.isEmpty()) return R.fail("产品型号 " + replacedModelCode + " 不存在");

                Long replModelId = (Long) repl.get(0).get("model_id");

                // ★ 查找现有 PENDING 确认单，直接更新（不新建）
                var pendingConfirm = jdbc.queryForList(
                    "SELECT confirm_id, approval_chain_id FROM cpq_process_confirm " +
                    "WHERE tenant_id='000000' AND result_id=? AND model_id=? AND confirm_status='PENDING' AND del_flag='0'",
                    resultId, modelId);
                if (!pendingConfirm.isEmpty()) {
                    Long existConfirmId = (Long) pendingConfirm.get(0).get("confirm_id");
                    chainId = (Long) pendingConfirm.get(0).get("approval_chain_id");
                    jdbc.update(
                        "UPDATE cpq_process_confirm SET model_id=?, replaced_model_id=?, replaced_reason=? " +
                        "WHERE confirm_id=?",
                        replModelId, modelId, replacedReason != null ? replacedReason : "", existConfirmId);
                    confirmId = existConfirmId;  // ★ 使用已有 confirmId
                    log.info("[Process] 替代推荐: confirm={}, {}→{}", existConfirmId, modelId, replModelId);
                } else {
                    // 兜底：没有 PENDING 确认单时新建
                    var approvalInfo = createApprovalChain(resultId, replModelId);
                    chainId = approvalInfo.get("chainId");
                    recordId = approvalInfo.get("recordId");
                    jdbc.update(
                        "INSERT INTO cpq_process_confirm (confirm_id, tenant_id, result_id, model_id, " +
                        "approval_chain_id, confirm_status, replaced_model_id, replaced_reason) " +
                        "VALUES (?, '000000', ?, ?, ?, 'PENDING', ?, ?)",
                        confirmId, resultId, replModelId, chainId, modelId,
                        replacedReason != null ? replacedReason : "");
                }
                actualModelId = replModelId;
                status = "PENDING";
            }
            case "CONFIRM_REPLACEMENT" -> {
                // ★ 销售确认或拒绝工艺推荐的替代产品
                // 参数从 DB 查，不依赖请求体中的 resultId/modelId
                Long confirmIdParam = toLong(body.get("confirmId"));
                Boolean accept = body.get("accept") instanceof Boolean ? (Boolean) body.get("accept") : true;
                if (confirmIdParam == null) return R.fail("confirmId不能为空");

                var confirmRow = jdbc.queryForList(
                    "SELECT * FROM cpq_process_confirm WHERE confirm_id=? AND del_flag='0'", confirmIdParam);
                if (confirmRow.isEmpty()) return R.fail("确认单不存在");

                resultId = (Long) confirmRow.get(0).get("result_id");
                actualModelId = (Long) confirmRow.get(0).get("model_id");
                chainId = (Long) confirmRow.get(0).get("approval_chain_id");
                confirmId = confirmIdParam;
                // ★ 补全 recordId（从审批记录表查）
                if (chainId != null) {
                    var recRows = jdbc.queryForList(
                        "SELECT record_id FROM cpq_approval_record WHERE chain_id=? LIMIT 1", chainId);
                    if (!recRows.isEmpty()) {
                        recordId = (Long) recRows.get(0).get("record_id");
                    }
                }

                if (accept) {
                    jdbc.update("UPDATE cpq_process_confirm SET confirm_status='CONFIRMED', confirm_time=NOW() " +
                        "WHERE confirm_id=?", confirmIdParam);
                    if (chainId != null) {
                        jdbc.update("UPDATE cpq_approval_chain SET status='COMPLETED', completed_time=NOW() " +
                            "WHERE chain_id=?", chainId);
                        jdbc.update("UPDATE cpq_approval_record SET action='APPROVED', action_time=NOW() " +
                            "WHERE chain_id=? AND action IS NULL", chainId);
                    }
                    status = "CONFIRMED";
                    log.info("[Process] 销售接受替代: confirm={}, model={}", confirmIdParam, actualModelId);
                } else {
                    // 拒绝替代：恢复原产品
                    Object origModelId = confirmRow.get(0).get("replaced_model_id");
                    if (origModelId != null) {
                        jdbc.update("UPDATE cpq_process_confirm SET model_id=?, replaced_model_id=NULL, " +
                            "replaced_reason=NULL WHERE confirm_id=?", origModelId, confirmIdParam);
                        actualModelId = (Long) origModelId;
                    }
                    status = "PENDING";
                    log.info("[Process] 销售坚持原选: confirm={}, 恢复model={}", confirmIdParam, origModelId);
                }
            }
            default -> { return R.fail("无效操作: " + action); }
        }

        // ★ 查询产品型号
        String modelCode = "";
        String modelName = "";
        var prod = jdbc.queryForList(
            "SELECT model_code, model_name FROM cpq_product_model WHERE model_id=?", actualModelId);
        if (!prod.isEmpty()) {
            modelCode = (String) prod.get(0).getOrDefault("model_code", "");
            modelName = (String) prod.get(0).getOrDefault("model_name", "");
        }

        // ★ 自动生成需求文本
        String reqText = requirementText != null && !requirementText.isEmpty()
            ? requirementText
            : buildRequirementText(resultId);

        Map<String, Object> resultMap = new java.util.HashMap<>();
        resultMap.put("confirmId", confirmId);
        resultMap.put("chainId", chainId);
        resultMap.put("recordId", recordId);  // ★ CPQ App 审批中心显示的"审批编号"
        resultMap.put("resultId", resultId);
        resultMap.put("status", status);
        resultMap.put("modelId", actualModelId);
        resultMap.put("modelCode", modelCode);
        resultMap.put("modelName", modelName);
        resultMap.put("requirementText", reqText);
        resultMap.put("message", "PENDING".equals(status)
            ? "已推送至工艺端审核，请在审批中心查看"
            : "已处理");
        return R.ok(resultMap);
    }

    /** ★ 待审批列表（含业务数据：产品/需求/评分） */
    @GetMapping("/pending")
    public R<List<Map<String, Object>>> pendingApprovals(@RequestParam(defaultValue = "1") Long approverId) {
        var rows = jdbc.queryForList(
            "SELECT r.record_id, r.chain_id, r.step_number, r.approver_id, r.approver_name, " +
            "c.quote_id AS result_id, c.status AS chain_status, c.submitted_time, " +
            "pc.model_id, m.model_code, m.model_name, " +
            "pc.replaced_model_id, " +
            "mr.requirement_json, mr.scored_json " +
            "FROM cpq_approval_record r " +
            "JOIN cpq_approval_chain c ON r.chain_id=c.chain_id " +
            "LEFT JOIN cpq_process_confirm pc ON r.chain_id=pc.approval_chain_id " +
            "LEFT JOIN cpq_product_model m ON pc.model_id=m.model_id " +
            "LEFT JOIN cpq_match_result mr ON pc.result_id=mr.result_id " +
            "WHERE r.tenant_id='000000' AND r.approver_id=? AND r.action IS NULL " +
            "ORDER BY c.submitted_time DESC", approverId);
        return R.ok(rows);
    }

    /** ★ 已审批列表（含业务数据：产品/需求/评分/审批意见/审批时间） */
    @GetMapping("/processed")
    public R<List<Map<String, Object>>> processedApprovals(@RequestParam(defaultValue = "1") Long approverId) {
        var rows = jdbc.queryForList(
            "SELECT r.record_id, r.chain_id, r.step_number, r.approver_id, r.approver_name, " +
            "r.action, r.comment, r.action_time, " +
            "c.quote_id AS result_id, c.status AS chain_status, c.submitted_time, c.completed_time, " +
            "pc.model_id, pc.confirm_status, m.model_code, m.model_name, " +
            "pc.replaced_model_id, pc.replaced_reason, " +
            "mr.requirement_json, mr.scored_json " +
            "FROM cpq_approval_record r " +
            "JOIN cpq_approval_chain c ON r.chain_id=c.chain_id " +
            "LEFT JOIN cpq_process_confirm pc ON r.chain_id=pc.approval_chain_id " +
            "LEFT JOIN cpq_product_model m ON pc.model_id=m.model_id " +
            "LEFT JOIN cpq_match_result mr ON pc.result_id=mr.result_id " +
            "WHERE r.tenant_id='000000' AND r.action IS NOT NULL " +
            "ORDER BY r.action_time DESC");
        return R.ok(rows);
    }

    /** 查询确认状态（通过 recordId） */
    @GetMapping("/status/byRecord/{recordId}")
    public R<Map<String, Object>> statusByRecord(@PathVariable Long recordId) {
        var rows = jdbc.queryForList(
            "SELECT r.chain_id, pc.result_id FROM cpq_approval_record r " +
            "LEFT JOIN cpq_process_confirm pc ON r.chain_id=pc.approval_chain_id " +
            "WHERE r.record_id=? AND r.tenant_id='000000'", recordId);
        if (rows.isEmpty()) return R.ok(Map.of("status", "NOT_FOUND", "message", "审批记录不存在"));
        Object rid = rows.get(0).get("result_id");
        if (rid == null) return R.ok(Map.of("status", "NOT_FOUND", "message", "未关联工艺确认单"));
        return status((Long) rid);  // 复用已有 status 方法
    }

    /** 查询确认状态（含产品型号名称） */
    @GetMapping("/status/{resultId}")
    public R<Map<String, Object>> status(@PathVariable Long resultId) {
        var rows = jdbc.queryForList(
            "SELECT pc.*, m.model_code, m.model_name " +
            "FROM cpq_process_confirm pc " +
            "LEFT JOIN cpq_product_model m ON pc.model_id=m.model_id " +
            "WHERE pc.tenant_id='000000' AND pc.result_id=? AND pc.del_flag='0' " +
            "ORDER BY pc.create_time DESC LIMIT 1", resultId);
        if (rows.isEmpty()) return R.ok(Map.of("status", "NOT_FOUND", "message", "无确认记录"));

        Map<String, Object> row = rows.get(0);
        String replModelCode = "";
        String replModelName = "";
        Object replId = row.get("replaced_model_id");
        if (replId != null) {
            var replRows = jdbc.queryForList(
                "SELECT model_code, model_name FROM cpq_product_model WHERE model_id=?",
                replId);
            if (!replRows.isEmpty()) {
                replModelCode = (String) replRows.get(0).getOrDefault("model_code", "");
                replModelName = (String) replRows.get(0).getOrDefault("model_name", "");
            }
        }

        return R.ok(Map.of(
            "resultId", resultId,
            "modelId", row.get("model_id"),
            "modelCode", row.get("model_code") != null ? row.get("model_code") : "",
            "modelName", row.get("model_name") != null ? row.get("model_name") : "",
            "status", row.get("confirm_status"),
            "replacedModelId", replId != null ? replId : "",
            "replacedModelCode", replModelCode,
            "replacedModelName", replModelName,
            "replacedReason", row.get("replaced_reason") != null ? row.get("replaced_reason") : ""
        ));
    }

    // ── 审批链 ──────────────────────────────────────────

    private Map<String, Long> createApprovalChain(Long resultId, Long modelId) {
        long now = System.currentTimeMillis();
        Long chainId = 100000000L + (now % 100000000);   // 1开头9位
        long recordId = 200000000L + ((now + 1) % 100000000); // 2开头9位

        Long approverId = 1L;
        String approverName = "admin";
        var approvers = jdbc.queryForList(
            "SELECT user_id, user_name FROM sys_user WHERE status='0' AND del_flag='0' LIMIT 2");
        if (!approvers.isEmpty()) {
            approverId = (Long) approvers.get(0).get("user_id");
            approverName = (String) approvers.get(0).get("user_name");
        }

        jdbc.update(
            "INSERT INTO cpq_approval_chain (chain_id, tenant_id, quote_id, current_step, total_steps, " +
            "status, submitted_by, submitted_time, sla_hours) " +
            "VALUES (?, '000000', ?, 1, 1, 'IN_PROGRESS', 1, ?, 48)",
            chainId, resultId, LocalDateTime.now().toString());

        jdbc.update(
            "INSERT INTO cpq_approval_record (record_id, tenant_id, chain_id, step_number, " +
            "approver_id, approver_name) VALUES (?, '000000', ?, 1, ?, ?)",
            recordId, chainId, approverId, approverName);

        log.info("[Approval] 审批链: chainId={}, recordId={}, approver={}", chainId, recordId, approverName);
        return Map.of("chainId", chainId, "recordId", recordId);
    }

    /** ★ 审批详情（含客户需求+匹配结果+选定产品） */
    @GetMapping("/detail/{chainId}")
    public R<Map<String, Object>> detail(@PathVariable Long chainId) {
        var rows = jdbc.queryForList(
            "SELECT pc.confirm_id, pc.result_id, pc.model_id, pc.confirm_status, " +
            "pc.replaced_model_id, pc.replaced_reason, " +
            "pc.requirement_text, m.model_code, m.model_name, m.base_price, " +
            "rm.model_code AS replaced_model_code, rm.model_name AS replaced_model_name, " +
            "mr.requirement_json, mr.scored_json " +
            "FROM cpq_process_confirm pc " +
            "LEFT JOIN cpq_product_model m ON pc.model_id=m.model_id " +
            "LEFT JOIN cpq_product_model rm ON pc.replaced_model_id=rm.model_id " +
            "LEFT JOIN cpq_match_result mr ON pc.result_id=mr.result_id " +
            "WHERE pc.approval_chain_id=? AND pc.del_flag='0' LIMIT 1", chainId);
        if (rows.isEmpty()) return R.fail("审批详情不存在");
        return R.ok(rows.get(0));
    }

    /** ★ 审批通过/驳回 */
    @PostMapping("/approve")
    public R<Map<String, String>> approve(@RequestBody Map<String, Object> body) {
        Long chainId = toLong(body.get("chainId"));
        String action = (String) body.getOrDefault("action", "APPROVED");
        String comment = (String) body.getOrDefault("comment", "");

        if (chainId == null) return R.fail("chainId不能为空");

        // 更新审批记录
        jdbc.update("UPDATE cpq_approval_record SET action=?, comment=?, action_time=NOW() " +
            "WHERE chain_id=? AND action IS NULL", action, comment, chainId);

        // 更新审批链状态
        String chainStatus = "APPROVED".equals(action) ? "COMPLETED" : "REJECTED";
        jdbc.update("UPDATE cpq_approval_chain SET status=?, completed_time=NOW() WHERE chain_id=?",
            chainStatus, chainId);

        // 级联更新工艺确认状态
        String confirmStatus = "APPROVED".equals(action) ? "CONFIRMED" : "REJECTED";
        jdbc.update("UPDATE cpq_process_confirm SET confirm_status=?, confirm_time=NOW() " +
            "WHERE approval_chain_id=?", confirmStatus, chainId);

        log.info("[Approval] chainId={} → {}", chainId, chainStatus);
        return R.ok(Map.of("status", chainStatus, "message", "APPROVED".equals(action) ? "✅ 已通过" : "已驳回"));
    }

    /** 从 match_result 自动生成自然语言需求描述 */
    private String buildRequirementText(Long resultId) {
        try {
            var rows = jdbc.queryForList(
                "SELECT requirement_json FROM cpq_match_result WHERE result_id=?", resultId);
            if (rows.isEmpty()) return "";
            String json = (String) rows.get(0).get("requirement_json");
            if (json == null) return "";
            // 简单解析JSON，格式化为可读文本
            var req = com.alibaba.fastjson.JSON.parseObject(json);
            var r = req.getJSONObject("requirements");
            if (r == null) return json;
            StringBuilder sb = new StringBuilder();
            if (r.getString("usageType") != null) sb.append("用途：").append(r.getString("usageType")).append("\n");
            if (r.getInteger("tempMin") != null || r.getInteger("tempMax") != null)
                sb.append("温度：").append(r.get("tempMin")).append("℃ ~ ").append(r.get("tempMax")).append("℃\n");
            if (r.getString("sealLevel") != null) sb.append("防护等级：").append(r.getString("sealLevel")).append("\n");
            if (r.getInteger("lifeCycleYears") != null) sb.append("期望寿命：≥").append(r.get("lifeCycleYears")).append("年\n");
            var certs = r.getJSONArray("requiredCertifications");
            if (certs != null && !certs.isEmpty()) sb.append("认证要求：").append(String.join("、", certs.toJavaList(String.class))).append("\n");
            return sb.toString().trim();
        } catch (Exception e) {
            log.warn("生成需求文本失败: {}", e.getMessage());
            return "";
        }
    }

    private Long toLong(Object obj) {
        if (obj == null) return null;
        if (obj instanceof Long l) return l;
        if (obj instanceof Integer i) return i.longValue();
        if (obj instanceof String s) {
            try { return Long.parseLong(s); } catch (NumberFormatException e) { return null; }
        }
        return null;
    }
}
