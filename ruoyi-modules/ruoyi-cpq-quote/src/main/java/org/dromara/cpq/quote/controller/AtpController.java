package org.dromara.cpq.quote.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.cpq.quote.service.IAtpCtpService;
import org.dromara.cpq.quote.service.IAtpCtpService.AlternativeRecommendation;
import org.dromara.cpq.quote.service.IAtpCtpService.AtpResult;
import org.dromara.cpq.quote.service.IAtpCtpService.CtpResult;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * ATP/CTP 交期管理控制器
 * <p>
 * 提供 ATP 交期检查、CTP 交期推算、批量检查和替代方案推荐接口。
 * </p>
 *
 * @author CPQ Team
 */
@RestController
@RequestMapping("/cpq/atp")
@RequiredArgsConstructor
public class AtpController {

    private final IAtpCtpService atpCtpService;

    /**
     * ATP 三级检查
     */
    @GetMapping("/check")
    public R<IAtpCtpService.AtpResult> checkAtp(
        @RequestParam Long productId,
        @RequestParam int quantity) {
        return R.ok(atpCtpService.checkAtp(productId, quantity));
    }

    /**
     * CTP 交期推算
     */
    @GetMapping("/ctp")
    public R<IAtpCtpService.CtpResult> calculateCtp(
        @RequestParam Long productId,
        @RequestParam int quantity,
        @RequestParam(required = false, defaultValue = "") String targetDate) {
        return R.ok(atpCtpService.calculateCtp(productId, quantity, targetDate));
    }

    /**
     * 批量 ATP 检查
     */
    @PostMapping("/batch")
    public R<Map<Long, IAtpCtpService.AtpResult>> batchCheckAtp(
        @RequestBody Map<Long, Integer> items) {
        return R.ok(atpCtpService.batchCheckAtp(items));
    }

    /**
     * 推荐替代方案
     */
    @GetMapping("/alternative")
    public R<List<IAtpCtpService.AlternativeRecommendation>> recommendAlternative(
        @RequestParam Long productId,
        @RequestParam int quantity) {
        return R.ok(atpCtpService.recommendAlternative(productId, quantity));
    }
}
