package org.dromara.cpq.competitive.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.domain.R;
import org.dromara.cpq.competitive.domain.CpqComparison;
import org.dromara.cpq.competitive.mapper.CpqComparisonMapper;
import org.springframework.web.bind.annotation.*;

@Slf4j @RestController @RequestMapping("/cpq/competitive/comparison") @RequiredArgsConstructor
public class CpqComparisonController {
    private final CpqComparisonMapper mapper;
    @GetMapping("/list")
    public R<List<CpqComparison>> list(CpqComparison entity) {
        return R.ok(mapper.selectList(new LambdaQueryWrapper<CpqComparison>()
            .eq(entity.getOurProductId() != null, CpqComparison::getOurProductId, entity.getOurProductId())
            .eq(entity.getCompetitorProductId() != null, CpqComparison::getCompetitorProductId, entity.getCompetitorProductId())
            .orderByDesc(CpqComparison::getCreateTime)));
    }
    @GetMapping("/{id}") public R<CpqComparison> get(@PathVariable Long id) { return R.ok(mapper.selectById(id)); }
    @PostMapping public R<Void> add(@RequestBody CpqComparison e) { mapper.insert(e); return R.ok(); }
    @PutMapping public R<Void> edit(@RequestBody CpqComparison e) { mapper.updateById(e); return R.ok(); }
    @DeleteMapping("/{ids}") public R<Void> remove(@PathVariable Long[] ids) { for (Long id : ids) mapper.deleteById(id); return R.ok(); }
}
