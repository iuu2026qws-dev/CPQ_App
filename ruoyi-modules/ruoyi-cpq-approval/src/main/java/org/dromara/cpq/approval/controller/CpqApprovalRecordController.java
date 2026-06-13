package org.dromara.cpq.approval.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.common.web.core.BaseController;
import org.dromara.cpq.approval.domain.bo.CpqApprovalRecordBo;
import org.dromara.cpq.approval.domain.vo.CpqApprovalRecordVo;
import org.dromara.cpq.approval.service.ICpqApprovalRecordService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/approval/record")
public class CpqApprovalRecordController extends BaseController {
    private final ICpqApprovalRecordService recordService;
    @GetMapping("/list") public TableDataInfo<CpqApprovalRecordVo> list(CpqApprovalRecordBo bo, PageQuery pageQuery) { return recordService.selectPageList(bo, pageQuery); }
    @GetMapping("/{recordId}") public R<CpqApprovalRecordVo> getInfo(@PathVariable Long recordId) { return R.ok(recordService.selectById(recordId)); }
    @GetMapping("/chain/{chainId}") public R<java.util.List<CpqApprovalRecordVo>> getByChain(@PathVariable Long chainId) { return R.ok(recordService.selectByChainId(chainId)); }
}
