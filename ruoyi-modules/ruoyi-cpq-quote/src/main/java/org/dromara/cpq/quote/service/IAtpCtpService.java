package org.dromara.cpq.quote.service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * ATP/CTP 交期引擎服务接口
 * <p>
 * ATP（Available To Promise）三级检查 + CTP（Capable To Promise）交期推算。
 * 基于库存、物料、产能三级数据逐层检查可承诺量，推荐最早可交付日期。
 * </p>
 *
 * @author CPQ Team
 */
public interface IAtpCtpService {

    /**
     * ATP 三级检查结果
     */
    record AtpResult(
        boolean available,          // 是否可承诺
        int availableQuantity,      // 可承诺数量
        int requestedQuantity,      // 请求数量
        int inventoryStock,         // 库存可用量
        int materialAvailable,      // 物料可用量
        int capacityAvailable,      // 产能可用量
        String bottleneck,          // 瓶颈描述（库存/物料/产能）
        List<String> warnings,      // 警告信息
        int estimatedDays           // 预计交期天数
    ) {}

    /**
     * CTP 交期推算结果
     */
    record CtpResult(
        boolean feasible,           // 是否可行
        int deliveryDays,           // 最早交付天数
        String deliveryDate,        // 最早交付日期
        int capacityRemaining,      // 产能余量
        int materialReadinessDays,  // 物料齐套天数
        int bottleneckProcessDays,  // 瓶颈工序天数
        List<CtpMilestone> milestones // 里程碑节点
    ) {}

    /**
     * CTP 里程碑节点
     */
    record CtpMilestone(
        String name,                // 节点名称
        int dayOffset,              // 距今天数
        String status,              // 状态：ON_TRACK/AT_RISK/DELAYED
        String description          // 描述
    ) {}

    /**
     * 替代方案推荐
     */
    record AlternativeRecommendation(
        Long productId,             // 替代产品ID
        String productName,         // 替代产品名称
        int availableQuantity,      // 可用数量
        int deliveryDays,           // 交期天数
        String reason,              // 推荐原因
        BigDecimal priceDifference  // 价格差异
    ) {}

    /**
     * 三级 ATP 检查
     * <p>Level 1: 库存 ATP — 检查成品库存是否满足需求</p>
     * <p>Level 2: 物料 ATP — 检查原材料/零部件是否满足生产需求</p>
     * <p>Level 3: 产能 ATP — 检查生产产能是否满足交付窗口</p>
     *
     * @param productId 产品ID
     * @param quantity 需求数量
     * @return ATP 三级检查结果
     */
    AtpResult checkAtp(Long productId, int quantity);

    /**
     * CTP 交期推算
     * <p>基于产能余量、物料齐套时间、瓶颈工序排产，推算最早可交付日期</p>
     *
     * @param productId 产品ID
     * @param quantity 需求数量
     * @param targetDate 期望交付日期（格式：yyyy-MM-dd）
     * @return CTP 交期推算结果
     */
    CtpResult calculateCtp(Long productId, int quantity, String targetDate);

    /**
     * 批量 ATP 检查
     *
     * @param items 检查项列表（productId → quantity）
     * @return 各产品的检查结果
     */
    Map<Long, AtpResult> batchCheckAtp(Map<Long, Integer> items);

    /**
     * 交期不满足时推荐替代方案
     *
     * @param productId 原产品ID
     * @param quantity 需求数量
     * @return 替代方案列表（按推荐度排序）
     */
    List<AlternativeRecommendation> recommendAlternative(Long productId, int quantity);
}
