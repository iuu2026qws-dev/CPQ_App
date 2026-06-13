package org.dromara.cpq.competitive.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.domain.R;
import org.dromara.cpq.competitive.domain.CpqCompetitor;
import org.dromara.cpq.competitive.mapper.CpqCompetitorMapper;
import org.springframework.web.bind.annotation.*;

@Slf4j @RestController @RequestMapping("/cpq/competitive/competitor") @RequiredArgsConstructor
public class CpqCompetitorController {
    private final CpqCompetitorMapper mapper;
    @GetMapping("/list")
    public R<List<CpqCompetitor>> list(CpqCompetitor entity) {
        return R.ok(mapper.selectList(new LambdaQueryWrapper<CpqCompetitor>()
            .like(entity.getCompetitorName() != null, CpqCompetitor::getCompetitorName, entity.getCompetitorName())
            .eq(entity.getStatus() != null, CpqCompetitor::getStatus, entity.getStatus())
            .orderByDesc(CpqCompetitor::getCreateTime)));
    }
    @GetMapping("/{id}") public R<CpqCompetitor> get(@PathVariable Long id) { return R.ok(mapper.selectById(id)); }
    @PostMapping public R<Void> add(@RequestBody CpqCompetitor e) { mapper.insert(e); return R.ok(); }
    @PutMapping public R<Void> edit(@RequestBody CpqCompetitor e) { mapper.updateById(e); return R.ok(); }
    @DeleteMapping("/{ids}") public R<Void> remove(@PathVariable Long[] ids) { for (Long id : ids) mapper.deleteById(id); return R.ok(); }
}
