package org.dromara.system.controller;

import java.util.Map;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.domain.R;
import org.dromara.system.service.PlantAllocationService;
import org.springframework.web.bind.annotation.*;

@Slf4j @RestController @RequestMapping("/cpq/plant-allocation") @RequiredArgsConstructor
public class PlantAllocationController {
    private final PlantAllocationService allocationService;
    @PostMapping("/allocate")
    public R<Map<String,Object>> allocate(@RequestBody Map<String,Object> params) {
        return allocationService.allocate(
            ((Number)params.get("productId")).longValue(),
            ((Number)params.get("quantity")).intValue(),
            (String)params.getOrDefault("strategy", "BALANCED")
        );
    }
}
