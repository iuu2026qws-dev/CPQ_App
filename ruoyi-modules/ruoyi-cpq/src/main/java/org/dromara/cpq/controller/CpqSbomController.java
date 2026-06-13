package org.dromara.cpq.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.domain.bo.CpqSbomHeaderBo;
import org.dromara.cpq.domain.bo.CpqSbomLineBo;
import org.dromara.cpq.domain.vo.CpqSbomHeaderVo;
import org.dromara.cpq.domain.vo.CpqSbomLineVo;
import org.dromara.cpq.service.ICpqSbomService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * CPQ SBOM 管理（菜单 50082）
 *
 * @author CPQ Team
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/product/sbom")
public class CpqSbomController extends BaseController {

    private final ICpqSbomService sbomService;

    // ==================== SBOM Header ====================

    @GetMapping("/header/list")
    public R<List<CpqSbomHeaderVo>> headerList(CpqSbomHeaderBo bo) {
        return R.ok(sbomService.selectSbomHeaderList(bo));
    }

    @GetMapping("/header/{sbomHeaderId}")
    public R<CpqSbomHeaderVo> headerInfo(@PathVariable Long sbomHeaderId) {
        return R.ok(sbomService.selectSbomHeaderById(sbomHeaderId));
    }

    @Log(title = "CPQ SBOM头", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping("/header")
    public R<Void> headerAdd(@Validated @RequestBody CpqSbomHeaderBo bo) {
        return toAjax(sbomService.insertSbomHeader(bo));
    }

    @Log(title = "CPQ SBOM头", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping("/header")
    public R<Void> headerEdit(@Validated @RequestBody CpqSbomHeaderBo bo) {
        return toAjax(sbomService.updateSbomHeader(bo));
    }

    @Log(title = "CPQ SBOM头", businessType = BusinessType.DELETE)
    @DeleteMapping("/header/{sbomHeaderId}")
    public R<Void> headerRemove(@PathVariable Long sbomHeaderId) {
        return toAjax(sbomService.deleteSbomHeader(sbomHeaderId));
    }

    // ==================== SBOM Line ====================

    @GetMapping("/line/list")
    public R<List<CpqSbomLineVo>> lineList(CpqSbomLineBo bo) {
        return R.ok(sbomService.selectSbomLineList(bo));
    }

    @GetMapping("/line/{sbomLineId}")
    public R<CpqSbomLineVo> lineInfo(@PathVariable Long sbomLineId) {
        return R.ok(sbomService.selectSbomLineById(sbomLineId));
    }

    @Log(title = "CPQ SBOM行", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping("/line")
    public R<Void> lineAdd(@Validated @RequestBody CpqSbomLineBo bo) {
        return toAjax(sbomService.insertSbomLine(bo));
    }

    @Log(title = "CPQ SBOM行", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping("/line")
    public R<Void> lineEdit(@Validated @RequestBody CpqSbomLineBo bo) {
        return toAjax(sbomService.updateSbomLine(bo));
    }

    @Log(title = "CPQ SBOM行", businessType = BusinessType.DELETE)
    @DeleteMapping("/line/{sbomLineId}")
    public R<Void> lineRemove(@PathVariable Long sbomLineId) {
        return toAjax(sbomService.deleteSbomLine(sbomLineId));
    }

    // ==================== BOM 引擎 ====================

    @GetMapping("/explode/{sbomHeaderId}")
    public R<List<CpqSbomLineVo>> explodeBom(@PathVariable Long sbomHeaderId) {
        return R.ok(sbomService.explodeBom(sbomHeaderId));
    }

    @GetMapping("/explode/flat/{sbomHeaderId}")
    public R<List<CpqSbomLineVo>> explodeBomFlat(@PathVariable Long sbomHeaderId) {
        return R.ok(sbomService.explodeBomFlat(sbomHeaderId));
    }

    @GetMapping("/byProduct/{productId}")
    public R<List<CpqSbomLineVo>> sbomByProduct(@PathVariable Long productId) {
        return R.ok(sbomService.selectSbomByProductId(productId));
    }
}
