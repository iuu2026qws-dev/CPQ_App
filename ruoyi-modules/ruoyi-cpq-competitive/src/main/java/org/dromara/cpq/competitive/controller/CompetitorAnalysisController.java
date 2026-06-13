package org.dromara.cpq.competitive.controller;

import java.util.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.domain.R;
import org.dromara.cpq.competitive.service.CompetitorService;
import org.springframework.web.bind.annotation.*;

@Slf4j @RestController @RequestMapping("/cpq/competitive/analysis") @RequiredArgsConstructor
public class CompetitorAnalysisController {
    private final CompetitorService competitorService;
    @PostMapping("/compare")
    public R<Map<String,Object>> compare(@RequestBody Map<String,Long> params) {
        return competitorService.compare(params.get("ourProductId"), params.get("competitorProductId"));
    }
    @GetMapping("/recommend/{ourProductId}")
    public R<List<Map<String,Object>>> recommend(@PathVariable Long ourProductId) {
        return competitorService.recommend(ourProductId);
    }
}
