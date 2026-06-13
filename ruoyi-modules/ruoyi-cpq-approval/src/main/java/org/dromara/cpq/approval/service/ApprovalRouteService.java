package org.dromara.cpq.approval.service;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.json.JSONUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.cpq.approval.domain.CpqApprovalChain;
import org.dromara.cpq.approval.domain.CpqApprovalRecord;
import org.dromara.cpq.approval.domain.CpqApprovalRule;
import org.dromara.cpq.approval.domain.bo.CpqApprovalChainBo;
import org.dromara.cpq.approval.domain.bo.CpqApprovalRecordBo;
import org.dromara.cpq.quote.domain.CpqQuote;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 审批路由服务 — 审批链构建与流转
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class ApprovalRouteService {

    private final ICpqApprovalRuleService ruleService;
    private final ICpqApprovalChainService chainService;
    private final ICpqApprovalRecordService recordService;

    /**
     * 构建审批链 — 评估触发条件→匹配规则→创建审批链实例
     */
    @Transactional
    public CpqApprovalChain buildChain(CpqQuote quote) {
        log.info("构建审批链: quoteId={}, accountId={}, grandTotal={}", quote.getQuoteId(), quote.getAccountId(), quote.getGrandTotal());

        // 1. 加载所有有效的审批规则
        List<CpqApprovalRule> rules = ruleService.list();
        if (rules.isEmpty()) {
            log.info("无审批规则，无需审批");
            return null;
        }

        // 2. 按优先级排序，取最高优先级匹配的规则
        rules.sort((a, b) -> Integer.compare(b.getPriority() != null ? b.getPriority() : 0, a.getPriority() != null ? a.getPriority() : 0));

        CpqApprovalRule matchedRule = null;
        for (CpqApprovalRule rule : rules) {
            if ("DISCOUNT_EXCEED".equals(rule.getTriggerType()) && quote.getDiscountTotal() != null
                && rule.getTriggerValue() != null && quote.getDiscountTotal().doubleValue() > rule.getTriggerValue().doubleValue()) {
                matchedRule = rule;
                break;
            }
            if ("AMOUNT_ABOVE".equals(rule.getTriggerType()) && quote.getGrandTotal() != null
                && rule.getTriggerValue() != null && quote.getGrandTotal().doubleValue() > rule.getTriggerValue().doubleValue()) {
                matchedRule = rule;
                break;
            }
        }

        if (matchedRule == null) {
            log.info("无匹配的审批规则");
            return null;
        }

        // 3. 解析审批链JSON，计算总步骤数
        int totalSteps = 1;
        try {
            var chainNodes = JSONUtil.parseArray(matchedRule.getApprovalChainJson());
            totalSteps = chainNodes.size();
        } catch (Exception e) {
            log.warn("审批链JSON解析失败，使用默认步骤数1", e);
        }

        // 4. 创建审批链实例
        CpqApprovalChainBo chainBo = new CpqApprovalChainBo();
        chainBo.setQuoteId(quote.getQuoteId());
        chainBo.setRuleId(matchedRule.getRuleId());
        chainBo.setCurrentStep(1);
        chainBo.setTotalSteps(totalSteps);
        chainBo.setStatus("IN_PROGRESS");
        chainBo.setSubmittedBy(quote.getCreatedBy());
        chainBo.setSubmittedTime(LocalDateTime.now());
        chainBo.setSlaHours(48);

        chainService.insert(chainBo);
        log.info("审批链创建成功: chainId={}, totalSteps={}", chainBo.getChainId(), totalSteps);

        return BeanUtil.toBean(chainBo, CpqApprovalChain.class);
    }

    /**
     * 处理审批动作 — 通过/驳回/条件通过/转审/加签
     */
    @Transactional
    public void processAction(Long chainId, Long approverId, String approverName, String action, String comment) {
        log.info("处理审批动作: chainId={}, approverId={}, action={}", chainId, approverId, action);

        CpqApprovalChain chain = chainService.getById(chainId);
        if (chain == null) {
            throw new RuntimeException("审批链不存在: " + chainId);
        }

        // 创建审批记录
        CpqApprovalRecordBo recordBo = new CpqApprovalRecordBo();
        recordBo.setChainId(chainId);
        recordBo.setStepNumber(chain.getCurrentStep());
        recordBo.setApproverId(approverId);
        recordBo.setApproverName(approverName);
        recordBo.setAction(action);
        recordBo.setComment(comment);
        recordBo.setActionTime(LocalDateTime.now());
        recordBo.setSlaDeadline(LocalDateTime.now().plusHours(chain.getSlaHours() != null ? chain.getSlaHours() : 48));
        recordService.insert(recordBo);

        // 更新审批链状态
        switch (action) {
            case "APPROVE":
            case "CONDITIONAL_APPROVE":
                chain.setCurrentStep(chain.getCurrentStep() + 1);
                if (chain.getCurrentStep() > chain.getTotalSteps()) {
                    chain.setStatus("APPROVED");
                    chain.setCompletedTime(LocalDateTime.now());
                }
                break;
            case "REJECT":
                chain.setStatus("REJECTED");
                chain.setCompletedTime(LocalDateTime.now());
                break;
            case "TRANSFER":
            case "DELEGATE":
            case "ADD_SIGNER":
                // 转审/委托/加签不改变步骤，留待后续处理
                break;
        }
        chainService.updateById(chain);
    }

    /**
     * SLA超时升级 — 48h超时自动升级
     */
    @Transactional
    public void escalateTimeout() {
        log.info("执行SLA超时升级检查");
        List<CpqApprovalChain> chains = chainService.list();
        LocalDateTime now = LocalDateTime.now();
        for (CpqApprovalChain chain : chains) {
            if ("IN_PROGRESS".equals(chain.getStatus())) {
                int slaHours = chain.getSlaHours() != null ? chain.getSlaHours() : 48;
                if (chain.getSubmittedTime() != null && chain.getSubmittedTime().plusHours(slaHours).isBefore(now)) {
                    log.warn("审批链超时: chainId={}, submittedTime={}, slaHours={}", chain.getChainId(), chain.getSubmittedTime(), slaHours);
                    // 自动升级：标记为过期
                    chain.setStatus("EXPIRED");
                    chain.setCompletedTime(now);
                    chainService.updateById(chain);
                }
            }
        }
    }
}
