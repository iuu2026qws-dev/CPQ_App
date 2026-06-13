package org.dromara.cpq.quote.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.common.web.core.BaseController;
import org.dromara.cpq.quote.domain.bo.CpqQuoteVersionBo;
import org.dromara.cpq.quote.domain.vo.CpqQuoteVersionVo;
import org.dromara.cpq.quote.service.ICpqQuoteVersionService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/quote/version")
public class CpqQuoteVersionController extends BaseController {
    private final ICpqQuoteVersionService versionService;

    @GetMapping("/list") public TableDataInfo<CpqQuoteVersionVo> list(CpqQuoteVersionBo bo, PageQuery pageQuery) { return versionService.selectPageList(bo, pageQuery); }
    @GetMapping("/{versionId}") public R<CpqQuoteVersionVo> getInfo(@PathVariable Long versionId) { return R.ok(versionService.selectById(versionId)); }
    @PostMapping public R<Void> add(@RequestBody CpqQuoteVersionBo bo) { return toAjax(versionService.insert(bo)); }
    @DeleteMapping("/{versionId}") public R<Void> remove(@PathVariable Long versionId) { return toAjax(versionService.deleteById(versionId)); }
}
