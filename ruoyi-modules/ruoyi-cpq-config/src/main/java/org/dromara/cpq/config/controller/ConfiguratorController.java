package org.dromara.cpq.config.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.domain.R;
import org.dromara.cpq.config.domain.CpqAttributeOption;
import org.dromara.cpq.config.mapper.CpqAttributeOptionMapper;
import org.dromara.cpq.config.service.BomExplosionService;
import org.dromara.cpq.config.service.ConfigEngineService;
import org.dromara.cpq.config.service.ConfigEngineService.GuideStep;
import org.dromara.cpq.config.service.ConfigEngineService.ValidationResult;
import org.dromara.cpq.domain.CpqMbomLine;
import org.dromara.cpq.domain.CpqProductModel;
import org.dromara.cpq.mapper.CpqProductModelMapper;
import org.dromara.cpq.pricing.service.PricingEngineService;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 产品配置器控制器（Sprint 6）
 * <p>
 * 面向前端配置器页面的编排控制器，聚合调用：
 * ConfigEngineService（约束验证/传播/向导）、BomExplosionService（BOM展开）、
 * PricingEngineService（定价计算）。
 * <p>
 * 设计文档：CPQ_阶段二_详细设计层.md §1.2 流程1步骤3-5
 *
 * @author CPQ Team
 */
@Slf4j
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/configure")
public class ConfiguratorController {

    private final ConfigEngineService configEngineService;
    private final BomExplosionService bomExplosionService;
    private final PricingEngineService pricingEngineService;
    private final CpqProductModelMapper productModelMapper;
    private final CpqAttributeOptionMapper attributeOptionMapper;

    /**
     * 加载配置模型
     * GET /cpq/configure/model/{modelId}
     * <p>
     * 返回：产品基本信息 + 属性列表及每属性下的可选选项 + 默认BOM
     */
    @GetMapping("/model/{modelId}")
    public R<ConfigModelResponse> loadModel(@PathVariable Long modelId) {
        log.info("加载配置模型，modelId={}", modelId);
        CpqProductModel model = productModelMapper.selectById(modelId);
        if (model == null) {
            return R.fail("产品不存在: " + modelId);
        }

        ConfigModelResponse resp = new ConfigModelResponse();
        resp.setModelId(model.getModelId());
        resp.setModelCode(model.getModelCode());
        resp.setModelName(model.getModelName());
        resp.setConfigType(model.getConfigType());
        resp.setDefaultBomId(model.getDefaultBomId());
        resp.setBasePrice(model.getBasePrice());
        resp.setCurrency(model.getCurrency());
        resp.setDescription(model.getDescription());
        resp.setLeadTimeDays(model.getLeadTimeDays());

        // 加载属性及选项
        List<CpqAttributeOption> allOptions = attributeOptionMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<CpqAttributeOption>()
                .eq(CpqAttributeOption::getModelId, modelId));
        Map<String, List<AttributeOptionVo>> attributes = allOptions.stream()
            .collect(Collectors.groupingBy(CpqAttributeOption::getAttrName,
                Collectors.mapping(o -> {
                    AttributeOptionVo vo = new AttributeOptionVo();
                    vo.setOptionValue(o.getOptionValue());
                    vo.setOptionLabel(o.getOptionLabel());
                    vo.setSortOrder(o.getSortOrder());
                    return vo;
                }, Collectors.toList())));
        resp.setAttributes(attributes);

        // 加载默认BOM（第一层展开）
        if (model.getDefaultBomId() != null) {
            try {
                List<org.dromara.cpq.domain.vo.CpqSbomLineVo> bomLines =
                    bomExplosionService.explodeBomFlat(model.getDefaultBomId());
                resp.setBomLines(bomLines);
            } catch (Exception e) {
                log.warn("加载默认BOM失败，modelId={}, defaultBomId={}: {}",
                    modelId, model.getDefaultBomId(), e.getMessage());
            }
        }

        return R.ok(resp);
    }

    /**
     * 实时校验选择
     * POST /cpq/configure/validate?modelId=1
     * Body: {"颜色":"珍珠白","基站版本":"标准版"}
     */
    @PostMapping("/validate")
    public R<ValidationResult> validate(@RequestParam Long modelId,
                                        @RequestBody Map<String, String> selections) {
        log.info("校验配置，modelId={}, selections={}", modelId, selections);
        return R.ok(configEngineService.validate(modelId, selections));
    }

    /**
     * 完成配置
     * POST /cpq/configure/complete?modelId=1&quantity=10
     * Body: {"颜色":"珍珠白","基站版本":"标准版"}
     * <p>
     * 流程：约束验证 → BOM转换 → 定价计算
     */
    @PostMapping("/complete")
    public R<ConfigCompleteResponse> complete(@RequestParam Long modelId,
                                               @RequestParam(defaultValue = "1") BigDecimal quantity,
                                               @RequestBody Map<String, String> selections) {
        log.info("完成配置，modelId={}, quantity={}, selections={}", modelId, quantity, selections);

        // Step 1: 验证
        ValidationResult validation = configEngineService.validate(modelId, selections);

        // Step 2: BOM 转换
        CpqProductModel model = productModelMapper.selectById(modelId);
        List<CpqMbomLine> mbomLines = null;
        BigDecimal bomCost = BigDecimal.ZERO;
        if (model != null && model.getDefaultBomId() != null) {
            mbomLines = bomExplosionService.sbomToMbom(model.getDefaultBomId(), selections);
            // 累计BOM成本（如有物料编码则使用基础价格）
            if (mbomLines != null) {
                bomCost = mbomLines.stream()
                    .filter(line -> line.getQuantity() != null)
                    .map(line -> BigDecimal.ZERO) // TODO: 物料成本从主数据获取
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            }
        }

        // Step 3: 定价
        PricingEngineService.PriceResult price = pricingEngineService.calculatePrice(
            modelId, null, quantity, null, null,
            BigDecimal.ZERO, bomCost, model != null ? model.getCurrency() : "CNY");

        // 组装响应
        ConfigCompleteResponse resp = new ConfigCompleteResponse();
        resp.setValidation(validation);
        resp.setMbomLines(mbomLines);
        resp.setPrice(price);
        return R.ok(resp);
    }

    /**
     * BOM预览 — 根据当前属性选择返回对应的MBOM明细
     * POST /cpq/configure/bom-preview?modelId=1
     * Body: {"颜色":"珍珠白","基站版本":"标准版"}
     * <p>
     * 用于ATO定制配置等场景，每次属性选择变化时实时刷新BOM预览表。
     */
    @PostMapping("/bom-preview")
    public R<List<CpqMbomLine>> bomPreview(@RequestParam Long modelId,
                                            @RequestBody Map<String, String> selections) {
        log.info("BOM预览，modelId={}, selections={}", modelId, selections);
        CpqProductModel model = productModelMapper.selectById(modelId);
        if (model == null || model.getDefaultBomId() == null) {
            return R.ok(java.util.Collections.emptyList());
        }
        List<CpqMbomLine> lines = bomExplosionService.sbomToMbom(
            model.getDefaultBomId(),
            selections != null ? selections : java.util.Collections.emptyMap());
        return R.ok(lines != null ? lines : java.util.Collections.emptyList());
    }

    /**
     * 向导式配置 — 获取下一个引导步骤
     * POST /cpq/configure/guide?modelId=1
     * Body: {"颜色":"珍珠白","基站版本":"标准版"}
     * <p>
     * 调用 ConfigEngineService.guidedSelling() 的5阶段状态机，
     * 返回当前步骤的问题、选项和推荐结果。
     */
    @PostMapping("/guide")
    public R<GuideStep> guide(@RequestParam Long modelId,
                               @RequestBody Map<String, String> selections) {
        log.info("向导式配置步骤，modelId={}, selections={}", modelId, selections);
        return R.ok(configEngineService.guidedSelling(modelId, selections));
    }

    // ============ 响应 VO ============

    public static class ConfigModelResponse {
        private Long modelId;
        private String modelCode;
        private String modelName;
        private String configType;
        private Long defaultBomId;
        private BigDecimal basePrice;
        private String currency;
        private String description;
        private Integer leadTimeDays;
        private Map<String, List<AttributeOptionVo>> attributes;
        private List<org.dromara.cpq.domain.vo.CpqSbomLineVo> bomLines;

        public Long getModelId() { return modelId; }
        public void setModelId(Long v) { this.modelId = v; }
        public String getModelCode() { return modelCode; }
        public void setModelCode(String v) { this.modelCode = v; }
        public String getModelName() { return modelName; }
        public void setModelName(String v) { this.modelName = v; }
        public String getConfigType() { return configType; }
        public void setConfigType(String v) { this.configType = v; }
        public Long getDefaultBomId() { return defaultBomId; }
        public void setDefaultBomId(Long v) { this.defaultBomId = v; }
        public BigDecimal getBasePrice() { return basePrice; }
        public void setBasePrice(BigDecimal v) { this.basePrice = v; }
        public String getCurrency() { return currency; }
        public void setCurrency(String v) { this.currency = v; }
        public String getDescription() { return description; }
        public void setDescription(String v) { this.description = v; }
        public Integer getLeadTimeDays() { return leadTimeDays; }
        public void setLeadTimeDays(Integer v) { this.leadTimeDays = v; }
        public Map<String, List<AttributeOptionVo>> getAttributes() { return attributes; }
        public void setAttributes(Map<String, List<AttributeOptionVo>> v) { this.attributes = v; }
        public List<org.dromara.cpq.domain.vo.CpqSbomLineVo> getBomLines() { return bomLines; }
        public void setBomLines(List<org.dromara.cpq.domain.vo.CpqSbomLineVo> v) { this.bomLines = v; }
    }

    public static class AttributeOptionVo {
        private String optionValue;
        private String optionLabel;
        private Integer sortOrder;

        public String getOptionValue() { return optionValue; }
        public void setOptionValue(String v) { this.optionValue = v; }
        public String getOptionLabel() { return optionLabel; }
        public void setOptionLabel(String v) { this.optionLabel = v; }
        public Integer getSortOrder() { return sortOrder; }
        public void setSortOrder(Integer v) { this.sortOrder = v; }
    }

    public static class ConfigCompleteResponse {
        private ValidationResult validation;
        private List<CpqMbomLine> mbomLines;
        private PricingEngineService.PriceResult price;

        public ValidationResult getValidation() { return validation; }
        public void setValidation(ValidationResult v) { this.validation = v; }
        public List<CpqMbomLine> getMbomLines() { return mbomLines; }
        public void setMbomLines(List<CpqMbomLine> v) { this.mbomLines = v; }
        public PricingEngineService.PriceResult getPrice() { return price; }
        public void setPrice(PricingEngineService.PriceResult v) { this.price = v; }
    }
}
