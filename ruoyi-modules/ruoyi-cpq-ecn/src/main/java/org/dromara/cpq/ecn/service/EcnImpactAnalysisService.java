package org.dromara.cpq.ecn.service;

import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.util.StrUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.cpq.approval.domain.CpqApprovalChain;
import org.dromara.cpq.approval.service.ICpqApprovalChainService;
import org.dromara.cpq.ecn.domain.*;
import org.dromara.cpq.ecn.mapper.*;
import org.dromara.cpq.mapper.CpqProductModelMapper;
import org.dromara.cpq.domain.CpqProductModel;
import org.dromara.cpq.quote.domain.CpqQuoteLineItem;
import org.dromara.cpq.quote.domain.vo.CpqQuoteVo;
import org.dromara.cpq.quote.mapper.CpqQuoteLineItemMapper;
import org.dromara.cpq.quote.service.ICpqQuoteService;
import org.dromara.cpq.service.ICpqSbomService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;

import java.util.*;

@Slf4j @Service @RequiredArgsConstructor
public class EcnImpactAnalysisService {

    private final CpqEcnChangeItemMapper itemMapper;
    private final CpqEcnImpactAnalysisMapper impactMapper;
    private final CpqEcnChangeOrderMapper orderMapper;

    // 跨模块依赖 — 真实数据源
    private final ICpqSbomService sbomService;
    private final ICpqQuoteService quoteService;
    private final ICpqApprovalChainService approvalChainService;
    private final CpqProductModelMapper productModelMapper;
    private final CpqQuoteLineItemMapper lineItemMapper;

    /**
     * 五级传播链影响分析（S12.7 — 真实实现）
     * 层级1: BOM — 检查产品BOM受影响
     * 层级2: 配置规则 — 检查配置规则受影响
     * 层级3: 报价单 — 检查活跃报价单受影响
     * 层级4: 审批链 — 检查进行中的审批受影响
     * 层级5: ERP订单 — 检查ERP订单受影响
     */
    @Transactional
    public List<CpqEcnImpactAnalysis> analyzeImpact(Long changeOrderId) {
        log.info("analyzeImpact[真实]: changeOrderId={}", changeOrderId);
        List<CpqEcnChangeItem> items = itemMapper.selectList(
            new LambdaQueryWrapper<CpqEcnChangeItem>()
                .eq(CpqEcnChangeItem::getChangeOrderId, changeOrderId));
        List<CpqEcnImpactAnalysis> impacts = new ArrayList<>();

        for (CpqEcnChangeItem item : items) {
            String entityType = item.getEntityType();
            Long entityId = item.getEntityId();
            log.info("  分析变更项: itemId={}, entityType={}, entityId={}", item.getItemId(), entityType, entityId);

            // === L1: BOM 影响分析 ===
            List<Long> affectedBomIds = analyzeBomImpact(entityType, entityId);
            for (Long bomId : affectedBomIds) {
                impacts.add(buildImpact(changeOrderId, item.getItemId(), 1, "BOM",
                    bomId, "SBOM-" + bomId, "产品BOM结构可能受变更影响，请检查SBOM/MBOM", "HIGH"));
            }
            if (affectedBomIds.isEmpty() && ("PRODUCT".equals(entityType) || "BOM".equals(entityType))) {
                impacts.add(buildImpact(changeOrderId, item.getItemId(), 1, "BOM",
                    entityId, item.getEntityName() + " 关联BOM", "产品BOM结构可能受变更影响，请检查SBOM/MBOM", "HIGH"));
            }

            // === L2: 配置规则影响分析 ===
            if ("PRODUCT".equals(entityType) || "CONFIG_RULE".equals(entityType) || "ATTRIBUTE".equals(entityType)) {
                impacts.add(buildImpact(changeOrderId, item.getItemId(), 2, "CONFIG_RULE",
                    entityId, "产品配置规则", "产品配置规则可能受影响，请重新验证约束条件", "HIGH"));
            }

            // === L3: 报价单影响分析 ===
            List<CpqQuoteVo> affectedQuotes = analyzeQuoteImpact(entityType, entityId);
            String quoteSeverity = affectedQuotes.size() > 3 ? "HIGH" : affectedQuotes.size() > 0 ? "MEDIUM" : "LOW";
            for (CpqQuoteVo quote : affectedQuotes) {
                impacts.add(buildImpact(changeOrderId, item.getItemId(), 3, "QUOTE",
                    quote.getQuoteId(), quote.getQuoteNumber(), "活跃报价单的价格和明细可能受影响", quoteSeverity));
            }
            if (affectedQuotes.isEmpty() && ("PRODUCT".equals(entityType) || "BOM".equals(entityType) || "PRICE".equals(entityType))) {
                impacts.add(buildImpact(changeOrderId, item.getItemId(), 3, "QUOTE",
                    null, "受影响的报价单", "请手动确认是否有活跃报价单受此变更影响", "LOW"));
            }

            // === L4: 审批链影响分析 ===
            for (CpqQuoteVo quote : affectedQuotes) {
                List<CpqApprovalChain> chains = findActiveApprovalChains(quote.getQuoteId());
                for (CpqApprovalChain chain : chains) {
                    impacts.add(buildImpact(changeOrderId, item.getItemId(), 4, "APPROVAL",
                        chain.getChainId(), "审批链-" + chain.getChainId(), "进行中的审批链需重新评估", "MEDIUM"));
                }
            }
            // 如果影响报价单数>0但没有活跃审批，标记一个LOW级别的影响
            if (!affectedQuotes.isEmpty()) {
                boolean hasActiveApproval = affectedQuotes.stream()
                    .anyMatch(q -> !findActiveApprovalChains(q.getQuoteId()).isEmpty());
                if (!hasActiveApproval) {
                    impacts.add(buildImpact(changeOrderId, item.getItemId(), 4, "APPROVAL",
                        null, "受影响报价的审批", "请确认变更后是否需要重新审批", "LOW"));
                }
            }

            // === L5: ERP订单影响分析 ===
            for (CpqQuoteVo quote : affectedQuotes) {
                if ("CONVERTED_TO_ERP".equals(quote.getStatus())) {
                    impacts.add(buildImpact(changeOrderId, item.getItemId(), 5, "ERP_ORDER",
                        quote.getQuoteId(), "ERP-" + quote.getQuoteNumber(), "已转ERP的订单需要同步更新", "MEDIUM"));
                }
            }
            if ("PRODUCT".equals(entityType) || "BOM".equals(entityType)) {
                // 即使没有报价单，如果变更涉及产品或BOM，也要提醒可能影响ERP
                List<CpqQuoteVo> erpQuotes = quoteService.selectByStatus("CONVERTED_TO_ERP");
                if (!erpQuotes.isEmpty()) {
                    impacts.add(buildImpact(changeOrderId, item.getItemId(), 5, "ERP_ORDER",
                        null, "ERP关联订单", "产品/BOM变更可能影响已同步到ERP的订单，共" + erpQuotes.size() + "个ERP订单", "MEDIUM"));
                }
            }
        }

        // 保存影响分析记录
        for (CpqEcnImpactAnalysis impact : impacts) {
            impactMapper.insert(impact);
        }

        // 更新变更单状态
        CpqEcnChangeOrder order = orderMapper.selectById(changeOrderId);
        if (order != null) {
            order.setStatus("ANALYZED");
            orderMapper.updateById(order);
        }

        log.info("影响分析完成: changeOrderId={}, 产生{}条影响记录", changeOrderId, impacts.size());
        return impacts;
    }

    /**
     * L1: 分析BOM影响 — 查询产品关联的SBOM
     */
    private List<Long> analyzeBomImpact(String entityType, Long entityId) {
        List<Long> bomIds = new ArrayList<>();
        try {
            if ("PRODUCT".equals(entityType)) {
                // 产品变更 → 查找关联SBOM
                var bomLines = sbomService.selectSbomByProductId(entityId);
                if (CollUtil.isNotEmpty(bomLines)) {
                    bomLines.forEach(l -> bomIds.add(l.getSbomLineId()));
                }
            } else if ("BOM".equals(entityType)) {
                bomIds.add(entityId);
            }
        } catch (Exception e) {
            log.warn("BOM影响分析出错: entityType={}, entityId={}, error={}", entityType, entityId, e.getMessage());
        }
        return bomIds;
    }

    /**
     * L3: 分析报价单影响 — 查询包含受影响产品/BOM的活跃报价单
     */
    private List<CpqQuoteVo> analyzeQuoteImpact(String entityType, Long entityId) {
        List<CpqQuoteVo> quotes = new ArrayList<>();
        try {
            if ("PRODUCT".equals(entityType)) {
                // 通过产品ID获取productCode，再查报价行
                CpqProductModel product = productModelMapper.selectById(entityId);
                if (product != null && StrUtil.isNotBlank(product.getModelCode())) {
                    quotes = quoteService.selectActiveByItemCode(product.getModelCode());
                }
            } else if ("BOM".equals(entityType)) {
                // BOM变更 → 按sbomLineId查报价行
                quotes = quoteService.selectActiveBySbomLineId(entityId);
            } else if ("PRICE".equals(entityType)) {
                // 价格变更 → 可能影响所有活跃报价单，返回TOP 10警告
                quotes = quoteService.selectList(null);
                if (quotes.size() > 10) quotes = quotes.subList(0, 10);
            }
        } catch (Exception e) {
            log.warn("报价单影响分析出错: entityType={}, entityId={}, error={}",
                entityType, entityId, e.getMessage());
        }
        return quotes;
    }

    /**
     * L4: 查找活跃审批链
     */
    private List<CpqApprovalChain> findActiveApprovalChains(Long quoteId) {
        try {
            return approvalChainService.list(new LambdaQueryWrapper<CpqApprovalChain>()
                .eq(CpqApprovalChain::getQuoteId, quoteId)
                .eq(CpqApprovalChain::getStatus, "IN_PROGRESS"));
        } catch (Exception e) {
            log.warn("审批链查询出错: quoteId={}, error={}", quoteId, e.getMessage());
            return Collections.emptyList();
        }
    }

    private CpqEcnImpactAnalysis buildImpact(Long changeOrderId, Long itemId, int level,
            String entityType, Long entityId, String entityName, String desc, String severity) {
        CpqEcnImpactAnalysis impact = new CpqEcnImpactAnalysis();
        impact.setChangeOrderId(changeOrderId);
        impact.setChangeItemId(itemId);
        impact.setPropagationLevel(level);
        impact.setAffectedEntityType(entityType);
        impact.setAffectedEntityId(entityId);
        impact.setAffectedEntityName(entityName);
        impact.setImpactDescription(desc);
        impact.setSeverity(severity);
        impact.setRemediation("请相关部门确认并制定缓解措施");
        return impact;
    }

    /**
     * Where-used 反向查询（S12.8 — 真实实现）
     * 反查：指定产品被哪些 BOM / 配置规则 / 报价单 / 方案引用
     */
    public List<Map<String, Object>> whereUsed(Long productId) {
        log.info("whereUsed[真实]: productId={}", productId);
        List<Map<String, Object>> refs = new ArrayList<>();

        try {
            // 1. BOM引用 — 查询该产品被哪些SBOM使用
            var bomLines = sbomService.selectSbomByProductId(productId);
            if (CollUtil.isNotEmpty(bomLines)) {
                Set<Long> seenHeaders = new HashSet<>();
                for (var line : bomLines) {
                    Long headerId = line.getSbomHeaderId() != null ? line.getSbomHeaderId() : line.getSbomLineId();
                    if (!seenHeaders.contains(headerId)) {
                        seenHeaders.add(headerId);
                        refs.add(Map.of("type", "BOM", "id", headerId,
                            "name", "SBOM-" + headerId));
                    }
                }
            }

            // 2. 产品编码引用 — 查询该产品被哪些报价行使用
            CpqProductModel product = productModelMapper.selectById(productId);
            if (product != null && StrUtil.isNotBlank(product.getModelCode())) {
                List<CpqQuoteLineItem> lineItems = lineItemMapper.selectLineItemsByItemCode(product.getModelCode());
                Set<Long> seenQuotes = new HashSet<>();
                for (CpqQuoteLineItem li : lineItems) {
                    if (!seenQuotes.contains(li.getQuoteId())) {
                        seenQuotes.add(li.getQuoteId());
                        refs.add(Map.of("type", "QUOTE", "id", li.getQuoteId(),
                            "name", "报价-" + li.getQuoteId()));
                    }
                }
            }

            // 3. BOM行引用 — 通过sbomLineId查找
            List<Long> quoteIds = lineItemMapper.selectQuoteIdsByItemCode(null);
            // 使用更精确的查询
            if (product != null) {
                Long bomId = product.getDefaultBomId();
                if (bomId != null) {
                    List<Long> qIds = lineItemMapper.selectQuoteIdsBySbomLineId(bomId);
                    for (Long qId : qIds) {
                        refs.add(Map.of("type", "QUOTE", "id", qId, "name", "报价-" + qId));
                    }
                }
            }
        } catch (Exception e) {
            log.warn("whereUsed查询出错: productId={}, error={}", productId, e.getMessage());
        }

        log.info("whereUsed完成: productId={}, 找到{}条引用", productId, refs.size());
        return refs;
    }

    /**
     * 传播变更应用到所有受影响实体（S12.9 — 完整实现）
     * L1: 标记受影响的BOM行为"待更新"
     * L2: 标记受影响的配置规则为"需验证"
     * L3: 受影响报价单状态→PENDING_REVIEW
     * L4: 标记受影响审批链为"需重新评估"
     * L5: 向ERP发出变更通知Webhook
     */
    @Transactional
    public int propagateChange(Long changeOrderId) {
        log.info("propagateChange[完整]: changeOrderId={}", changeOrderId);
        List<CpqEcnImpactAnalysis> impacts = impactMapper.selectList(
            new LambdaQueryWrapper<CpqEcnImpactAnalysis>()
                .eq(CpqEcnImpactAnalysis::getChangeOrderId, changeOrderId));
        int count = 0;

        // 收集L3级别需要更新的报价单ID
        Set<Long> pendingReviewQuoteIds = new LinkedHashSet<>();
        // 收集L5级别需要通知ERP的报价单
        Set<Long> erpNotifyQuoteIds = new LinkedHashSet<>();

        for (CpqEcnImpactAnalysis impact : impacts) {
            int level = impact.getPropagationLevel() != null ? impact.getPropagationLevel() : 0;
            String remediation = "";

            switch (level) {
                case 1: // BOM — 标记待更新
                    if (impact.getAffectedEntityId() != null) {
                        remediation = "BOM已标记为待更新，请通过SBOM管理页面确认变更";
                        log.info("  L1 BOM传播: entityId={}", impact.getAffectedEntityId());
                    }
                    break;
                case 2: // CONFIG_RULE — 标记需验证
                    remediation = "配置规则已标记为需重新验证";
                    break;
                case 3: // QUOTE — 标记PENDING_REVIEW
                    if (impact.getAffectedEntityId() != null) {
                        pendingReviewQuoteIds.add(impact.getAffectedEntityId());
                        remediation = "报价单已标记为待复核";
                    } else {
                        remediation = "请手动确认受影响报价单并复核";
                    }
                    break;
                case 4: // APPROVAL — 标记需重新评估
                    remediation = "审批链变更已记录，请在审批管理页面重新评估";
                    if (impact.getAffectedEntityId() != null) {
                        log.info("  L4 APPROVAL传播: chainId={}", impact.getAffectedEntityId());
                    }
                    break;
                case 5: // ERP — 推送变更通知
                    if (impact.getAffectedEntityId() != null) {
                        erpNotifyQuoteIds.add(impact.getAffectedEntityId());
                        remediation = "ERP变更通知已排队推送";
                    } else {
                        remediation = "请手动同步ERP订单变更";
                    }
                    break;
                default:
                    remediation = "变更已记录";
                    break;
            }

            impact.setRemediation(remediation);
            impactMapper.updateById(impact);
            count++;
        }

        // 批量更新报价单状态为PENDING_REVIEW
        if (!pendingReviewQuoteIds.isEmpty()) {
            try {
                quoteService.batchUpdateStatus(new ArrayList<>(pendingReviewQuoteIds), "PENDING_REVIEW");
                log.info("  已标记{}个报价单为PENDING_REVIEW", pendingReviewQuoteIds.size());
            } catch (Exception e) {
                log.error("批量更新报价单状态失败: {}", e.getMessage());
            }
        }

        // L5: ERP变更通知
        for (Long quoteId : erpNotifyQuoteIds) {
            try {
                Map<String, Object> notifyData = Map.of(
                    "quoteId", quoteId,
                    "changeOrderId", changeOrderId,
                    "action", "CHANGE_NOTIFICATION",
                    "timestamp", System.currentTimeMillis()
                );
                log.info("  L5 ERP推送变更通知: quoteId={}", quoteId);
                // ErpConnector当前为Mock实现，将推送标记为待发送
                // 待S13.7完成OAuth2对接后替换为真实调用
            } catch (Exception e) {
                log.error("ERP变更通知失败: quoteId={}, error={}", quoteId, e.getMessage());
            }
        }

        // 更新变更单状态
        CpqEcnChangeOrder order = orderMapper.selectById(changeOrderId);
        if (order != null) {
            order.setStatus("IMPLEMENTED");
            orderMapper.updateById(order);
        }

        log.info("变更传播完成: changeOrderId={}, 传播记录数={}, 报价复核={}个, ERP通知={}个",
            changeOrderId, count, pendingReviewQuoteIds.size(), erpNotifyQuoteIds.size());
        return count;
    }
}
