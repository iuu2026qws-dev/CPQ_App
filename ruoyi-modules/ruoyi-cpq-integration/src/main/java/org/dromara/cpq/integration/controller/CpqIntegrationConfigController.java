package org.dromara.cpq.integration.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.domain.R;
import org.dromara.cpq.integration.domain.CpqIntegrationConfig;
import org.dromara.cpq.integration.mapper.CpqIntegrationConfigMapper;
import org.springframework.web.bind.annotation.*;

@Slf4j @RestController @RequestMapping("/cpq/integration/config") @RequiredArgsConstructor
public class CpqIntegrationConfigController {
    private final CpqIntegrationConfigMapper mapper;

    @GetMapping("/list")
    public R<List<CpqIntegrationConfig>> list(CpqIntegrationConfig entity) {
        return R.ok(mapper.selectList(new LambdaQueryWrapper<CpqIntegrationConfig>()
            .like(entity.getSystemName() != null, CpqIntegrationConfig::getSystemName, entity.getSystemName())
            .eq(entity.getSystemType() != null, CpqIntegrationConfig::getSystemType, entity.getSystemType())
            .eq(entity.getStatus() != null, CpqIntegrationConfig::getStatus, entity.getStatus())
            .orderByDesc(CpqIntegrationConfig::getCreateTime)));
    }
    @GetMapping("/{id}") public R<CpqIntegrationConfig> get(@PathVariable Long id) { return R.ok(mapper.selectById(id)); }
    @PostMapping public R<Void> add(@RequestBody CpqIntegrationConfig e) { mapper.insert(e); return R.ok(); }
    @PutMapping public R<Void> edit(@RequestBody CpqIntegrationConfig e) { mapper.updateById(e); return R.ok(); }
    @DeleteMapping("/{ids}") public R<Void> remove(@PathVariable Long[] ids) { for (Long id : ids) mapper.deleteById(id); return R.ok(); }
}
