package org.dromara.cpq.migration.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.domain.R;
import org.dromara.cpq.migration.domain.CpqMigrationTask;
import org.dromara.cpq.migration.mapper.CpqMigrationTaskMapper;
import org.springframework.web.bind.annotation.*;

@Slf4j @RestController @RequestMapping("/cpq/migration/task") @RequiredArgsConstructor
public class CpqMigrationTaskController {
    private final CpqMigrationTaskMapper mapper;
    @GetMapping("/list")
    public R<List<CpqMigrationTask>> list(CpqMigrationTask entity) {
        return R.ok(mapper.selectList(new LambdaQueryWrapper<CpqMigrationTask>()
            .like(entity.getTaskName() != null, CpqMigrationTask::getTaskName, entity.getTaskName())
            .eq(entity.getTaskStatus() != null, CpqMigrationTask::getTaskStatus, entity.getTaskStatus())
            .orderByDesc(CpqMigrationTask::getCreateTime)));
    }
    @GetMapping("/{id}") public R<CpqMigrationTask> get(@PathVariable Long id) { return R.ok(mapper.selectById(id)); }
    @PostMapping public R<Void> add(@RequestBody CpqMigrationTask e) { mapper.insert(e); return R.ok(); }
    @PutMapping public R<Void> edit(@RequestBody CpqMigrationTask e) { mapper.updateById(e); return R.ok(); }
    @DeleteMapping("/{ids}") public R<Void> remove(@PathVariable Long[] ids) { for (Long id : ids) mapper.deleteById(id); return R.ok(); }
}
