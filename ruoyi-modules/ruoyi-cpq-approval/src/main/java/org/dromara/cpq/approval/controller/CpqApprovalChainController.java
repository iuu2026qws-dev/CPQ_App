package org.dromara.cpq.approval.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.common.web.core.BaseController;
import org.dromara.cpq.approval.domain.bo.CpqApprovalChainBo;
import org.dromara.cpq.approval.domain.vo.CpqApprovalChainVo;
import org.dromara.cpq.approval.service.ICpqApprovalChainService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/approval/chain")
public class CpqApprovalChainController extends BaseController {
    private final ICpqApprovalChainService chainService;
    @GetMapping("/list") public TableDataInfo<CpqApprovalChainVo> list(CpqApprovalChainBo bo, PageQuery pageQuery) { return chainService.selectPageList(bo, pageQuery); }
    @GetMapping("/{chainId}") public R<CpqApprovalChainVo> getInfo(@PathVariable Long chainId) { return R.ok(chainService.selectById(chainId)); }
    @PostMapping public R<Void> add(@RequestBody CpqApprovalChainBo bo) { return toAjax(chainService.insert(bo)); }
    @PutMapping public R<Void> edit(@RequestBody CpqApprovalChainBo bo) { return toAjax(chainService.update(bo)); }
    @DeleteMapping("/{chainId}") public R<Void> remove(@PathVariable Long chainId) { return toAjax(chainService.deleteById(chainId)); }
}
