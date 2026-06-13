package org.dromara.cpq.ecn.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.cpq.ecn.domain.CpqEcnChangeOrder;
import org.dromara.cpq.ecn.domain.CpqEcnChangeItem;
import org.dromara.cpq.ecn.domain.CpqEcnImpactAnalysis;
import org.dromara.cpq.ecn.mapper.CpqEcnChangeOrderMapper;
import org.dromara.cpq.ecn.mapper.CpqEcnChangeItemMapper;
import org.dromara.cpq.ecn.mapper.CpqEcnImpactAnalysisMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.*;

@Slf4j @Service @RequiredArgsConstructor
public class EcnService {

    private final CpqEcnChangeOrderMapper orderMapper;
    private final CpqEcnChangeItemMapper itemMapper;
    private final CpqEcnImpactAnalysisMapper impactMapper;

    @Transactional
    public Long createChangeOrder(CpqEcnChangeOrder order) {
        order.setStatus("DRAFT");
        order.setEcnNumber("ECN-" + System.currentTimeMillis());
        orderMapper.insert(order);
        log.info("ECN变更单已创建: ecnId={}", order.getChangeOrderId());
        return order.getChangeOrderId();
    }

    @Transactional
    public void addChangeItem(CpqEcnChangeItem item) {
        itemMapper.insert(item);
        log.info("变更项已添加: itemId={}, changeOrderId={}", item.getItemId(), item.getChangeOrderId());
    }

    private final EcnImpactAnalysisService analysisService;

    @Transactional
    public void submitForAnalysis(Long changeOrderId) {
        CpqEcnChangeOrder order = orderMapper.selectById(changeOrderId);
        if (order == null) throw new RuntimeException("ECN变更单不存在: " + changeOrderId);
        order.setStatus("ANALYZING");
        orderMapper.updateById(order);
        log.info("ECN已提交分析: ecnId={}", changeOrderId);
        // 自动触发影响分析
        analysisService.analyzeImpact(changeOrderId);
        log.info("ECN影响分析已完成: ecnId={}", changeOrderId);
    }

    @Transactional
    public void closeEcn(Long changeOrderId) {
        CpqEcnChangeOrder order = orderMapper.selectById(changeOrderId);
        if (order == null) throw new RuntimeException("ECN变更单不存在: " + changeOrderId);
        order.setStatus("CLOSED");
        orderMapper.updateById(order);
        log.info("ECN已关闭: ecnId={}", changeOrderId);
    }

    public List<CpqEcnChangeItem> getChangeItems(Long changeOrderId) {
        return itemMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<CpqEcnChangeItem>()
                .eq(CpqEcnChangeItem::getChangeOrderId, changeOrderId));
    }
}
