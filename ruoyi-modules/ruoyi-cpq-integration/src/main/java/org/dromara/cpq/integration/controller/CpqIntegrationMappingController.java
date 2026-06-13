package org.dromara.cpq.integration.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.domain.R;
import org.dromara.cpq.integration.domain.CpqIntegrationMapping;
import org.dromara.cpq.integration.mapper.CpqIntegrationMappingMapper;
import org.springframework.web.bind.annotation.*;

@Slf4j @RestController @RequestMapping("/cpq/integration/mapping") @RequiredArgsConstructor
public class CpqIntegrationMappingController {
    private final CpqIntegrationMappingMapper mapper;

    @GetMapping("/list")
    public R<List<CpqIntegrationMapping>> list(@RequestParam(required = false) Long configId) {
        return R.ok(mapper.selectList(new LambdaQueryWrapper<CpqIntegrationMapping>()
            .eq(configId != null, CpqIntegrationMapping::getConfigId, configId)
            .orderByAsc(CpqIntegrationMapping::getSortOrder)));
    }
    @GetMapping("/{id}") public R<CpqIntegrationMapping> get(@PathVariable Long id) { return R.ok(mapper.selectById(id)); }
    @PostMapping public R<Void> add(@RequestBody CpqIntegrationMapping e) { mapper.insert(e); return R.ok(); }
    @PutMapping public R<Void> edit(@RequestBody CpqIntegrationMapping e) { mapper.updateById(e); return R.ok(); }
    @DeleteMapping("/{ids}") public R<Void> remove(@PathVariable Long[] ids) { for (Long id : ids) mapper.deleteById(id); return R.ok(); }
}
