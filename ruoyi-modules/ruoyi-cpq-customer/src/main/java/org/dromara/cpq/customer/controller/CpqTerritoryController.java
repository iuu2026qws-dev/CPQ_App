package org.dromara.cpq.customer.controller;

import lombok.RequiredArgsConstructor; import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.domain.R;
import org.dromara.cpq.customer.domain.CpqTerritory;
import org.dromara.cpq.customer.mapper.CpqTerritoryMapper;
import org.springframework.web.bind.annotation.*;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import java.util.List;

@Slf4j @RestController @RequestMapping("/cpq/customer/territory") @RequiredArgsConstructor
public class CpqTerritoryController {
    private final CpqTerritoryMapper mapper;
    @GetMapping("/list") public R<List<CpqTerritory>> list(CpqTerritory e) { return R.ok(mapper.selectList(new LambdaQueryWrapper<CpqTerritory>().like(e.getTerritoryName()!=null,CpqTerritory::getTerritoryName,e.getTerritoryName()).orderByDesc(CpqTerritory::getCreateTime))); }
    @GetMapping("/{id}") public R<CpqTerritory> get(@PathVariable Long id) { return R.ok(mapper.selectById(id)); }
    @PostMapping public R<Void> add(@RequestBody CpqTerritory e) { mapper.insert(e); return R.ok(); }
    @PutMapping public R<Void> edit(@RequestBody CpqTerritory e) { mapper.updateById(e); return R.ok(); }
    @DeleteMapping("/{id}") public R<Void> remove(@PathVariable Long id) { mapper.deleteById(id); return R.ok(); }
}
