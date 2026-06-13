package org.dromara.cpq.approval.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.common.web.core.BaseController;
import org.dromara.cpq.approval.domain.bo.CpqApprovalMatrixBo;
import org.dromara.cpq.approval.domain.vo.CpqApprovalMatrixVo;
import org.dromara.cpq.approval.service.ICpqApprovalMatrixService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/approval/matrix")
public class CpqApprovalMatrixController extends BaseController {
    private final ICpqApprovalMatrixService matrixService;
    @GetMapping("/list") public TableDataInfo<CpqApprovalMatrixVo> list(CpqApprovalMatrixBo bo, PageQuery pageQuery) { return matrixService.selectPageList(bo, pageQuery); }
    @GetMapping("/{matrixId}") public R<CpqApprovalMatrixVo> getInfo(@PathVariable Long matrixId) { return R.ok(matrixService.selectById(matrixId)); }
    @PostMapping public R<Void> add(@RequestBody CpqApprovalMatrixBo bo) { return toAjax(matrixService.insert(bo)); }
    @PutMapping public R<Void> edit(@RequestBody CpqApprovalMatrixBo bo) { return toAjax(matrixService.update(bo)); }
    @DeleteMapping("/{matrixId}") public R<Void> remove(@PathVariable Long matrixId) { return toAjax(matrixService.deleteById(matrixId)); }
    @DeleteMapping("/batch") public R<Void> removeBatch(@RequestBody Long[] matrixIds) { return toAjax(matrixService.deleteByIds(matrixIds)); }
}
