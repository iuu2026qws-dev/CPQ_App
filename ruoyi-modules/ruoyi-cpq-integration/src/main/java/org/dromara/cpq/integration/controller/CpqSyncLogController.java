package org.dromara.cpq.integration.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.domain.R;
import org.dromara.cpq.integration.domain.CpqSyncLog;
import org.dromara.cpq.integration.mapper.CpqSyncLogMapper;
import org.springframework.web.bind.annotation.*;

@Slf4j @RestController @RequestMapping("/cpq/integration/sync-log") @RequiredArgsConstructor
public class CpqSyncLogController {
    private final CpqSyncLogMapper mapper;

    @GetMapping("/list")
    public R<List<CpqSyncLog>> list(@RequestParam(required = false) Long configId,
                                     @RequestParam(required = false) String syncStatus) {
        return R.ok(mapper.selectList(new LambdaQueryWrapper<CpqSyncLog>()
            .eq(configId != null, CpqSyncLog::getConfigId, configId)
            .eq(syncStatus != null, CpqSyncLog::getSyncStatus, syncStatus)
            .orderByDesc(CpqSyncLog::getSyncTime)));
    }
    @GetMapping("/{id}") public R<CpqSyncLog> get(@PathVariable Long id) { return R.ok(mapper.selectById(id)); }
    @DeleteMapping("/{ids}") public R<Void> remove(@PathVariable Long[] ids) { for (Long id : ids) mapper.deleteById(id); return R.ok(); }
}
