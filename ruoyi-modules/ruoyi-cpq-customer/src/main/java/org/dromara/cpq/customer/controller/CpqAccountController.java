package org.dromara.cpq.customer.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.domain.R;
import org.dromara.cpq.customer.domain.CpqAccount;
import org.dromara.cpq.customer.mapper.CpqAccountMapper;
import org.springframework.web.bind.annotation.*;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import java.util.List;

@Slf4j @RestController @RequestMapping("/cpq/customer/account") @RequiredArgsConstructor
public class CpqAccountController {
    private final CpqAccountMapper mapper;

    @GetMapping("/list")
    public R<List<CpqAccount>> list(CpqAccount entity) {
        return R.ok(mapper.selectList(new LambdaQueryWrapper<CpqAccount>()
            .like(entity.getAccountName() != null, CpqAccount::getAccountName, entity.getAccountName())
            .eq(entity.getAccountType() != null, CpqAccount::getAccountType, entity.getAccountType())
            .orderByDesc(CpqAccount::getCreateTime)));
    }
    @GetMapping("/{id}") public R<CpqAccount> get(@PathVariable Long id) { return R.ok(mapper.selectById(id)); }
    @PostMapping public R<Void> add(@RequestBody CpqAccount e) { mapper.insert(e); return R.ok(); }
    @PutMapping public R<Void> edit(@RequestBody CpqAccount e) { mapper.updateById(e); return R.ok(); }
    @DeleteMapping("/{id}") public R<Void> remove(@PathVariable Long id) { mapper.deleteById(id); return R.ok(); }
}
