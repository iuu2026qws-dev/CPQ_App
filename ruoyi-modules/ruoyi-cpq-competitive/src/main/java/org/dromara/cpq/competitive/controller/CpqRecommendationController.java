package org.dromara.cpq.competitive.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.domain.R;
import org.dromara.cpq.competitive.domain.CpqRecommendation;
import org.dromara.cpq.competitive.mapper.CpqRecommendationMapper;
import org.springframework.web.bind.annotation.*;

@Slf4j @RestController @RequestMapping("/cpq/competitive/recommendation") @RequiredArgsConstructor
public class CpqRecommendationController {
    private final CpqRecommendationMapper mapper;
    @GetMapping("/list")
    public R<List<CpqRecommendation>> list(CpqRecommendation entity) {
        return R.ok(mapper.selectList(new LambdaQueryWrapper<CpqRecommendation>()
            .like(entity.getScenario() != null, CpqRecommendation::getScenario, entity.getScenario())
            .eq(entity.getStrategyType() != null, CpqRecommendation::getStrategyType, entity.getStrategyType())
            .orderByAsc(CpqRecommendation::getPriority)));
    }
    @GetMapping("/{id}") public R<CpqRecommendation> get(@PathVariable Long id) { return R.ok(mapper.selectById(id)); }
    @PostMapping public R<Void> add(@RequestBody CpqRecommendation e) { mapper.insert(e); return R.ok(); }
    @PutMapping public R<Void> edit(@RequestBody CpqRecommendation e) { mapper.updateById(e); return R.ok(); }
    @DeleteMapping("/{ids}") public R<Void> remove(@PathVariable Long[] ids) { for (Long id : ids) mapper.deleteById(id); return R.ok(); }
}
