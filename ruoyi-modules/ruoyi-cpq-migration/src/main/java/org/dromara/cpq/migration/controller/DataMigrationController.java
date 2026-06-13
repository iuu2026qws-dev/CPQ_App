package org.dromara.cpq.migration.controller;

import java.util.Map;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.domain.R;
import org.dromara.cpq.migration.domain.CpqMigrationTask;
import org.dromara.cpq.migration.service.DataMigrationService;
import org.springframework.web.bind.annotation.*;

@Slf4j @RestController @RequestMapping("/cpq/migration/workflow") @RequiredArgsConstructor
public class DataMigrationController {
    private final DataMigrationService migrationService;

    @PostMapping("/create") public R<CpqMigrationTask> create(@RequestBody CpqMigrationTask task) { return migrationService.createTask(task); }
    @PostMapping("/validate/{taskId}") public R<Map<String,Object>> validate(@PathVariable Long taskId) { return migrationService.validateData(taskId); }
    @PostMapping("/execute/{taskId}") public R<Map<String,Object>> execute(@PathVariable Long taskId) { return migrationService.executeImport(taskId); }
    @GetMapping("/reconcile/{taskId}") public R<Map<String,Object>> reconcile(@PathVariable Long taskId) { return migrationService.reconcileData(taskId); }
}
