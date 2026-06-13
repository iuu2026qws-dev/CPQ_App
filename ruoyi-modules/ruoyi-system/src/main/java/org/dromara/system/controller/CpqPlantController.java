package org.dromara.system.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.domain.R;
import org.dromara.system.domain.CpqPlant;
import org.dromara.system.mapper.CpqPlantMapper;
import org.springframework.web.bind.annotation.*;

@Slf4j @RestController @RequestMapping("/cpq/plant") @RequiredArgsConstructor
public class CpqPlantController {
    private final CpqPlantMapper mapper;
    @GetMapping("/list")
    public R<List<CpqPlant>> list(CpqPlant entity) {
        return R.ok(mapper.selectList(new LambdaQueryWrapper<CpqPlant>()
            .like(entity.getPlantName() != null, CpqPlant::getPlantName, entity.getPlantName())
            .eq(entity.getStatus() != null, CpqPlant::getStatus, entity.getStatus())
            .orderByDesc(CpqPlant::getCreateTime)));
    }
    @GetMapping("/{id}") public R<CpqPlant> get(@PathVariable Long id) { return R.ok(mapper.selectById(id)); }
    @PostMapping public R<Void> add(@RequestBody CpqPlant e) { mapper.insert(e); return R.ok(); }
    @PutMapping public R<Void> edit(@RequestBody CpqPlant e) { mapper.updateById(e); return R.ok(); }
    @DeleteMapping("/{ids}") public R<Void> remove(@PathVariable Long[] ids) { for (Long id : ids) mapper.deleteById(id); return R.ok(); }
}
