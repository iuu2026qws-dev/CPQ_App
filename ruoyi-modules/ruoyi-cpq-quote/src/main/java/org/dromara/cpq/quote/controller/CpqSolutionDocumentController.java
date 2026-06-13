package org.dromara.cpq.quote.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.common.web.core.BaseController;
import org.dromara.cpq.quote.domain.bo.CpqSolutionDocumentBo;
import org.dromara.cpq.quote.domain.vo.CpqSolutionDocumentVo;
import org.dromara.cpq.quote.service.ICpqSolutionDocumentService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/quote/solution")
public class CpqSolutionDocumentController extends BaseController {
    private final ICpqSolutionDocumentService solutionService;
    @GetMapping("/list") public TableDataInfo<CpqSolutionDocumentVo> list(CpqSolutionDocumentBo bo, PageQuery pageQuery) { return solutionService.selectPageList(bo, pageQuery); }
    @GetMapping("/{documentId}") public R<CpqSolutionDocumentVo> getInfo(@PathVariable Long documentId) { return R.ok(solutionService.selectById(documentId)); }
    @PostMapping public R<Void> add(@RequestBody CpqSolutionDocumentBo bo) { return toAjax(solutionService.insert(bo)); }
    @PutMapping public R<Void> edit(@RequestBody CpqSolutionDocumentBo bo) { return toAjax(solutionService.update(bo)); }
    @DeleteMapping("/{documentId}") public R<Void> remove(@PathVariable Long documentId) { return toAjax(solutionService.deleteById(documentId)); }
    @DeleteMapping("/batch") public R<Void> removeBatch(@RequestBody Long[] documentIds) { return toAjax(solutionService.deleteByIds(documentIds)); }
}
