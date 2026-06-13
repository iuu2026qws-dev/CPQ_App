package org.dromara.cpq.customer.controller;

import lombok.RequiredArgsConstructor; import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.domain.R;
import org.dromara.cpq.customer.domain.CpqChannel;
import org.dromara.cpq.customer.mapper.CpqChannelMapper;
import org.springframework.web.bind.annotation.*;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import java.util.List;

@Slf4j @RestController @RequestMapping("/cpq/customer/channel") @RequiredArgsConstructor
public class CpqChannelController {
    private final CpqChannelMapper mapper;
    @GetMapping("/list") public R<List<CpqChannel>> list(CpqChannel e) { return R.ok(mapper.selectList(new LambdaQueryWrapper<CpqChannel>().like(e.getChannelName()!=null, CpqChannel::getChannelName, e.getChannelName()).orderByDesc(CpqChannel::getCreateTime))); }
    @GetMapping("/{id}") public R<CpqChannel> get(@PathVariable Long id) { return R.ok(mapper.selectById(id)); }
    @PostMapping public R<Void> add(@RequestBody CpqChannel e) { mapper.insert(e); return R.ok(); }
    @PutMapping public R<Void> edit(@RequestBody CpqChannel e) { mapper.updateById(e); return R.ok(); }
    @DeleteMapping("/{id}") public R<Void> remove(@PathVariable Long id) { mapper.deleteById(id); return R.ok(); }
}
