package org.dromara.cpq.config.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.cpq.config.service.ConfigEngineService;
import org.dromara.cpq.config.service.ConfigEngineService.GuideStep;
import org.dromara.cpq.config.service.ConfigEngineService.OptionInfo;
import org.dromara.cpq.config.service.ConfigEngineService.ValidationResult;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 配置引擎测试控制器（Sprint 5）
 */
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/engine/config")
public class ConfigEngineController {

    private final ConfigEngineService configEngineService;

    /**
     * CSP 约束验证
     * POST /cpq/engine/config/validate?modelId=1
     * Body: {"颜色":"珍珠白","基站版本":"标准版"}
     */
    @PostMapping("/validate")
    public R<ValidationResult> validate(@RequestParam Long modelId,
                                        @RequestBody Map<String, String> selections) {
        ValidationResult result = configEngineService.validate(modelId, selections);
        return R.ok(result);
    }

    /**
     * 约束传播（查看各属性可选/被禁选项）
     * POST /cpq/engine/config/propagate?modelId=1
     * Body: {"颜色":"珍珠白"}
     */
    @PostMapping("/propagate")
    public R<Map<String, List<OptionInfo>>> propagate(@RequestParam Long modelId,
                                                       @RequestBody Map<String, String> selections) {
        Map<String, List<OptionInfo>> result = configEngineService.propagateConstraints(modelId, selections);
        return R.ok(result);
    }

    /**
     * 向导式销售（获取下一步引导）
     * POST /cpq/engine/config/guide?modelId=1
     * Body: {"颜色":"珍珠白"}
     */
    @PostMapping("/guide")
    public R<GuideStep> guide(@RequestParam Long modelId,
                              @RequestBody Map<String, String> selections) {
        GuideStep step = configEngineService.guidedSelling(modelId, selections);
        return R.ok(step);
    }

    /**
     * 兼容性检查
     * GET /cpq/engine/config/compatibility?sourceProductId=1&targetProductId=2
     */
    @GetMapping("/compatibility")
    public R<String> checkCompatibility(@RequestParam Long sourceProductId,
                                         @RequestParam Long targetProductId) {
        String result = configEngineService.checkCompatibility(sourceProductId, targetProductId);
        return R.ok(result);
    }
}
