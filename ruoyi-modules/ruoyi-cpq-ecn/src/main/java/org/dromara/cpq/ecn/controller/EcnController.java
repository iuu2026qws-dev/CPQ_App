package org.dromara.cpq.ecn.controller;

import lombok.RequiredArgsConstructor; import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.domain.R;
import org.dromara.cpq.ecn.domain.*;
import org.dromara.cpq.ecn.mapper.*;
import org.dromara.cpq.ecn.service.*;
import org.springframework.web.bind.annotation.*;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import java.util.*;

@Slf4j @RestController @RequestMapping("/cpq/ecn") @RequiredArgsConstructor
public class EcnController {

    private final CpqEcnChangeOrderMapper orderMapper;
    private final CpqEcnChangeItemMapper itemMapper;
    private final CpqEcnImpactAnalysisMapper impactMapper;
    private final CpqEcnApprovalMapper approvalMapper;
    private final EcnService ecnService;
    private final EcnImpactAnalysisService analysisService;

    // ===== 变更单 CRUD =====
    @GetMapping("/order/list")
    public R<List<CpqEcnChangeOrder>> listOrder(CpqEcnChangeOrder e) {
        return R.ok(orderMapper.selectList(new LambdaQueryWrapper<CpqEcnChangeOrder>()
            .like(e.getEcnNumber() != null, CpqEcnChangeOrder::getEcnNumber, e.getEcnNumber())
            .eq(e.getStatus() != null, CpqEcnChangeOrder::getStatus, e.getStatus())
            .orderByDesc(CpqEcnChangeOrder::getCreateTime)));
    }
    @GetMapping("/order/{id}") public R<CpqEcnChangeOrder> getOrder(@PathVariable Long id) { return R.ok(orderMapper.selectById(id)); }
    @PostMapping("/order") public R<Long> create(@RequestBody CpqEcnChangeOrder e) { return R.ok(ecnService.createChangeOrder(e)); }
    @PutMapping("/order") public R<Void> update(@RequestBody CpqEcnChangeOrder e) { orderMapper.updateById(e); return R.ok(); }
    @DeleteMapping("/order/{id}") public R<Void> deleteOrder(@PathVariable Long id) { orderMapper.deleteById(id); return R.ok(); }

    // ===== 变更项 CRUD =====
    @GetMapping("/item/list")
    public R<List<CpqEcnChangeItem>> listItem(@RequestParam(required = false) Long changeOrderId) {
        return R.ok(itemMapper.selectList(new LambdaQueryWrapper<CpqEcnChangeItem>()
            .eq(changeOrderId != null, CpqEcnChangeItem::getChangeOrderId, changeOrderId)));
    }
    @PostMapping("/item") public R<Void> addItem(@RequestBody CpqEcnChangeItem e) { ecnService.addChangeItem(e); return R.ok(); }
    @PutMapping("/item") public R<Void> updateItem(@RequestBody CpqEcnChangeItem e) { itemMapper.updateById(e); return R.ok(); }

    // ===== 影响分析 =====
    @GetMapping("/impact/list")
    public R<List<CpqEcnImpactAnalysis>> listImpact(@RequestParam Long changeOrderId) {
        return R.ok(impactMapper.selectList(new LambdaQueryWrapper<CpqEcnImpactAnalysis>()
            .eq(CpqEcnImpactAnalysis::getChangeOrderId, changeOrderId)));
    }
    @PostMapping("/impact/analyze/{changeOrderId}")
    public R<List<CpqEcnImpactAnalysis>> analyze(@PathVariable Long changeOrderId) { return R.ok(analysisService.analyzeImpact(changeOrderId)); }
    @PostMapping("/impact/propagate/{changeOrderId}")
    public R<Integer> propagate(@PathVariable Long changeOrderId) { return R.ok(analysisService.propagateChange(changeOrderId)); }
    @GetMapping("/impact/where-used")
    public R<List<Map<String, Object>>> whereUsed(@RequestParam Long productId) { return R.ok(analysisService.whereUsed(productId)); }

    // ===== ECN 审批 =====
    @GetMapping("/approval/list")
    public R<List<CpqEcnApproval>> listApproval(@RequestParam Long changeOrderId) {
        return R.ok(approvalMapper.selectList(new LambdaQueryWrapper<CpqEcnApproval>()
            .eq(CpqEcnApproval::getChangeOrderId, changeOrderId)));
    }
    @PostMapping("/approval") public R<Void> addApproval(@RequestBody CpqEcnApproval e) { approvalMapper.insert(e); return R.ok(); }

    // ===== 操作 =====
    @PostMapping("/order/{id}/submit") public R<Void> submit(@PathVariable Long id) { ecnService.submitForAnalysis(id); return R.ok(); }
    @PostMapping("/order/{id}/close") public R<Void> close(@PathVariable Long id) { ecnService.closeEcn(id); return R.ok(); }
}
