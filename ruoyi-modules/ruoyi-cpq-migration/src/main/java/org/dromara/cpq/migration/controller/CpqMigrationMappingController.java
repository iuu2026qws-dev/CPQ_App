package org.dromara.cpq.migration.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.domain.R;
import org.dromara.cpq.migration.domain.CpqMigrationMapping;
import org.dromara.cpq.migration.mapper.CpqMigrationMappingMapper;
import org.springframework.web.bind.annotation.*;

@Slf4j @RestController @RequestMapping("/cpq/migration/mapping") @RequiredArgsConstructor
public class CpqMigrationMappingController {
    private final CpqMigrationMappingMapper mapper;
    @GetMapping("/list")
    public R<List<CpqMigrationMapping>> list(@RequestParam(required = false) Long taskId) {
        return R.ok(mapper.selectList(new LambdaQueryWrapper<CpqMigrationMapping>()
            .eq(taskId != null, CpqMigrationMapping::getTaskId, taskId)
            .orderByAsc(CpqMigrationMapping::getSortOrder)));
    }
    @GetMapping("/{id}") public R<CpqMigrationMapping> get(@PathVariable Long id) { return R.ok(mapper.selectById(id)); }
    @PostMapping public R<Void> add(@RequestBody CpqMigrationMapping e) { mapper.insert(e); return R.ok(); }
    @PutMapping public R<Void> edit(@RequestBody CpqMigrationMapping e) { mapper.updateById(e); return R.ok(); }
    @DeleteMapping("/{ids}") public R<Void> remove(@PathVariable Long[] ids) { for (Long id : ids) mapper.deleteById(id); return R.ok(); }
}
