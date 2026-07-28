package org.dromara.cpq.approval.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.common.web.core.BaseController;
import org.dromara.cpq.approval.domain.bo.CpqApprovalRuleBo;
import org.dromara.cpq.approval.domain.vo.CpqApprovalRuleVo;
import org.dromara.cpq.approval.service.ICpqApprovalRuleService;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/approval/rule")
public class CpqApprovalRuleController extends BaseController {
    private final ICpqApprovalRuleService ruleService;
    private final JdbcTemplate jdbc;
    @GetMapping("/list") public TableDataInfo<CpqApprovalRuleVo> list(CpqApprovalRuleBo bo, PageQuery pageQuery) { return ruleService.selectPageList(bo, pageQuery); }
    /** 查询已发布的 Warm-Flow 流程定义列表（供审批规则配置时下拉选择） */
    @GetMapping("/available-flows") public R<List<Map<String, Object>>> availableFlows() { return R.ok(jdbc.queryForList("SELECT flow_code, flow_name, version FROM flow_definition WHERE is_publish=1 AND del_flag='0' ORDER BY flow_code")); }
    @GetMapping("/{ruleId}") public R<CpqApprovalRuleVo> getInfo(@PathVariable Long ruleId) { return R.ok(ruleService.selectById(ruleId)); }
    @PostMapping public R<Void> add(@RequestBody CpqApprovalRuleBo bo) { return toAjax(ruleService.insert(bo)); }
    @PutMapping public R<Void> edit(@RequestBody CpqApprovalRuleBo bo) { return toAjax(ruleService.update(bo)); }
    @DeleteMapping("/{ruleId}") public R<Void> remove(@PathVariable Long ruleId) { return toAjax(ruleService.deleteById(ruleId)); }
    @DeleteMapping("/batch") public R<Void> removeBatch(@RequestBody Long[] ruleIds) { return toAjax(ruleService.deleteByIds(ruleIds)); }
}
