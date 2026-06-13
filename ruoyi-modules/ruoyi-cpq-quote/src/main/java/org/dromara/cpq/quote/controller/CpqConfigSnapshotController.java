package org.dromara.cpq.quote.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.common.web.core.BaseController;
import org.dromara.cpq.quote.domain.bo.CpqConfigSnapshotBo;
import org.dromara.cpq.quote.domain.vo.CpqConfigSnapshotVo;
import org.dromara.cpq.quote.service.ICpqConfigSnapshotService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/quote/snapshot")
public class CpqConfigSnapshotController extends BaseController {
    private final ICpqConfigSnapshotService snapshotService;

    @GetMapping("/list") public TableDataInfo<CpqConfigSnapshotVo> list(CpqConfigSnapshotBo bo, PageQuery pageQuery) { return snapshotService.selectPageList(bo, pageQuery); }
    @GetMapping("/{snapshotId}") public R<CpqConfigSnapshotVo> getInfo(@PathVariable Long snapshotId) { return R.ok(snapshotService.selectById(snapshotId)); }
    @PostMapping public R<Void> add(@RequestBody CpqConfigSnapshotBo bo) { return toAjax(snapshotService.insert(bo)); }
    @PutMapping public R<Void> edit(@RequestBody CpqConfigSnapshotBo bo) { return toAjax(snapshotService.update(bo)); }
    @DeleteMapping("/{snapshotId}") public R<Void> remove(@PathVariable Long snapshotId) { return toAjax(snapshotService.deleteById(snapshotId)); }
    @DeleteMapping("/batch") public R<Void> removeBatch(@RequestBody Long[] snapshotIds) { return toAjax(snapshotService.deleteByIds(snapshotIds)); }
}
