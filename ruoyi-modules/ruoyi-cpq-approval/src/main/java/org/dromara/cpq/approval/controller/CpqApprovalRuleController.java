package org.dromara.cpq.approval.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.common.web.core.BaseController;
import org.dromara.cpq.approval.domain.bo.CpqApprovalRuleBo;
import org.dromara.cpq.approval.domain.vo.CpqApprovalRuleVo;
import org.dromara.cpq.approval.service.ICpqApprovalRuleService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/approval/rule")
public class CpqApprovalRuleController extends BaseController {
    private final ICpqApprovalRuleService ruleService;
    @GetMapping("/list") public TableDataInfo<CpqApprovalRuleVo> list(CpqApprovalRuleBo bo, PageQuery pageQuery) { return ruleService.selectPageList(bo, pageQuery); }
    @GetMapping("/{ruleId}") public R<CpqApprovalRuleVo> getInfo(@PathVariable Long ruleId) { return R.ok(ruleService.selectById(ruleId)); }
    @PostMapping public R<Void> add(@RequestBody CpqApprovalRuleBo bo) { return toAjax(ruleService.insert(bo)); }
    @PutMapping public R<Void> edit(@RequestBody CpqApprovalRuleBo bo) { return toAjax(ruleService.update(bo)); }
    @DeleteMapping("/{ruleId}") public R<Void> remove(@PathVariable Long ruleId) { return toAjax(ruleService.deleteById(ruleId)); }
    @DeleteMapping("/batch") public R<Void> removeBatch(@RequestBody Long[] ruleIds) { return toAjax(ruleService.deleteByIds(ruleIds)); }
}
