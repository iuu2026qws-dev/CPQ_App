package org.dromara.cpq.migration.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.domain.R;
import org.dromara.cpq.migration.domain.CpqMigrationLog;
import org.dromara.cpq.migration.mapper.CpqMigrationLogMapper;
import org.springframework.web.bind.annotation.*;

@Slf4j @RestController @RequestMapping("/cpq/migration/log") @RequiredArgsConstructor
public class CpqMigrationLogController {
    private final CpqMigrationLogMapper mapper;
    @GetMapping("/list")
    public R<List<CpqMigrationLog>> list(@RequestParam(required = false) Long taskId) {
        return R.ok(mapper.selectList(new LambdaQueryWrapper<CpqMigrationLog>()
            .eq(taskId != null, CpqMigrationLog::getTaskId, taskId)
            .orderByDesc(CpqMigrationLog::getLogTime)));
    }
    @GetMapping("/{id}") public R<CpqMigrationLog> get(@PathVariable Long id) { return R.ok(mapper.selectById(id)); }
    @DeleteMapping("/{ids}") public R<Void> remove(@PathVariable Long[] ids) { for (Long id : ids) mapper.deleteById(id); return R.ok(); }
}
