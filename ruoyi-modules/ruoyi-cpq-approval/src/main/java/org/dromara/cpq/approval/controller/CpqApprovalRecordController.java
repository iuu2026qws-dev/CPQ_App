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

import java.util.Map;

@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/approval/record")
public class CpqApprovalRecordController extends BaseController {
    private final ICpqApprovalRecordService recordService;

    /** 前端传 status=pending/processed，映射到 BO 的 action 字段 */
    @GetMapping("/list")
    public TableDataInfo<CpqApprovalRecordVo> list(@RequestParam Map<String, Object> params, PageQuery pageQuery) {
        CpqApprovalRecordBo bo = new CpqApprovalRecordBo();
        if (params.get("chainId") != null) bo.setChainId(Long.valueOf(params.get("chainId").toString()));
        if (params.get("approverId") != null) bo.setApproverId(Long.valueOf(params.get("approverId").toString()));
        // ★ 前端传 status=pending → BO action="pending"; status=processed → "processed"
        if (params.get("status") != null) bo.setAction(params.get("status").toString());
        return recordService.selectPageList(bo, pageQuery);
    }

    @GetMapping("/{recordId}") public R<CpqApprovalRecordVo> getInfo(@PathVariable Long recordId) { return R.ok(recordService.selectById(recordId)); }
    @GetMapping("/chain/{chainId}") public R<java.util.List<CpqApprovalRecordVo>> getByChain(@PathVariable Long chainId) { return R.ok(recordService.selectByChainId(chainId)); }
}
