package org.dromara.cpq.customer.controller;

import lombok.RequiredArgsConstructor; import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.domain.R;
import org.dromara.cpq.customer.domain.CpqAgreementPrice;
import org.dromara.cpq.customer.mapper.CpqAgreementPriceMapper;
import org.springframework.web.bind.annotation.*;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import java.util.List;

@Slf4j @RestController @RequestMapping("/cpq/customer/agreement") @RequiredArgsConstructor
public class CpqAgreementPriceController {
    private final CpqAgreementPriceMapper mapper;
    @GetMapping("/list") public R<List<CpqAgreementPrice>> list(CpqAgreementPrice e) { return R.ok(mapper.selectList(new LambdaQueryWrapper<CpqAgreementPrice>().eq(e.getAccountId()!=null,CpqAgreementPrice::getAccountId,e.getAccountId()).orderByDesc(CpqAgreementPrice::getCreateTime))); }
    @GetMapping("/{id}") public R<CpqAgreementPrice> get(@PathVariable Long id) { return R.ok(mapper.selectById(id)); }
    @PostMapping public R<Void> add(@RequestBody CpqAgreementPrice e) { mapper.insert(e); return R.ok(); }
    @PutMapping public R<Void> edit(@RequestBody CpqAgreementPrice e) { mapper.updateById(e); return R.ok(); }
    @DeleteMapping("/{id}") public R<Void> remove(@PathVariable Long id) { mapper.deleteById(id); return R.ok(); }
}
