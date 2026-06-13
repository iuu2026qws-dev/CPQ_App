package org.dromara.cpq.config.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.cpq.config.service.BomExplosionService;
import org.dromara.cpq.domain.CpqMbomLine;
import org.dromara.cpq.domain.vo.CpqSbomLineVo;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * BOM 引擎测试控制器（Sprint 5）
 */
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/engine/bom")
public class BomEngineController {

    private final BomExplosionService bomExplosionService;

    @GetMapping("/explode/{sbomHeaderId}")
    public R<List<CpqSbomLineVo>> explodeBom(@PathVariable Long sbomHeaderId) {
        return R.ok(bomExplosionService.explodeBom(sbomHeaderId));
    }

    @GetMapping("/explodeFlat/{sbomHeaderId}")
    public R<List<CpqSbomLineVo>> explodeBomFlat(@PathVariable Long sbomHeaderId) {
        return R.ok(bomExplosionService.explodeBomFlat(sbomHeaderId));
    }

    @PostMapping("/convert/{sbomHeaderId}")
    public R<List<CpqMbomLine>> sbomToMbom(@PathVariable Long sbomHeaderId,
                                           @RequestBody Map<String, String> selections) {
        List<CpqMbomLine> result = bomExplosionService.sbomToMbom(sbomHeaderId, selections);
        return R.ok(result);
    }

    @GetMapping("/implode/{materialCode}")
    public R<List<CpqSbomLineVo>> implodeBom(@PathVariable String materialCode) {
        return R.ok(bomExplosionService.implodeBom(materialCode));
    }
}
