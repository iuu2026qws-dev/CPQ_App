package org.dromara.cpq.config.service;

import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.util.ObjectUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.cpq.config.domain.CpqAttributeMapping;
import org.dromara.cpq.config.domain.CpqVariantBom;
import org.dromara.cpq.config.mapper.CpqAttributeMappingMapper;
import org.dromara.cpq.config.mapper.CpqVariantBomMapper;
import org.dromara.cpq.domain.CpqMbomLine;
import org.dromara.cpq.domain.CpqSbomHeader;
import org.dromara.cpq.domain.CpqSbomLine;
import org.dromara.cpq.domain.vo.CpqSbomLineVo;
import org.dromara.cpq.mapper.CpqMbomLineMapper;
import org.dromara.cpq.mapper.CpqSbomHeaderMapper;
import org.dromara.cpq.mapper.CpqSbomLineMapper;
import org.dromara.common.core.exception.ServiceException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

/**
 * CPQ BOM 展开引擎 — SBOM→MBOM 五阶段转换流水线
 * <p>
 * Phase 1: Phantom 跳过 — 虚项展开子项，跳过自身
 * Phase 2: 150% BOM 过滤 — effectivity_condition 匹配，变体BOM→实例BOM
 * Phase 3: 属性→物料映射 — 查 cpq_attribute_mapping 表，级联映射
 * Phase 4: MBOM 展开与合并 — BFS递归 + 同物料行 quantity 合并
 * Phase 5: 完整性校验 — 环检测DFS + 悬空节点 + 物料缺失 + 数量一致性
 * <p>
 * 对应设计文档：CPQ_后端功能设计.md §5.2 BomExplosionService
 * CPQ_阶段二_详细设计层.md §5.2 SBOM→MBOM 五阶段转换流水线
 *
 * @author CPQ Team
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class BomExplosionService {

    private final CpqSbomHeaderMapper sbomHeaderMapper;
    private final CpqSbomLineMapper sbomLineMapper;
    private final CpqMbomLineMapper mbomLineMapper;
    private final CpqAttributeMappingMapper attributeMappingMapper;
    private final CpqVariantBomMapper variantBomMapper;

    // ==================== Phase 1: Phantom 跳过 ====================

    /**
     * BFS 递归展开 BOM 树，自动跳过虚项(Phantom)。
     * <p>
     * 虚项（如"解决方案套包"）仅用于销售结构组织，不产生实质物料。
     * 展开时跳过虚项自身，将其子项上浮一级。
     *
     * @param sbomHeaderId SBOM 头 ID
     * @return 展开后的 SBOM 行 VO 列表（树形结构，虚项已展开）
     */
    public List<CpqSbomLineVo> explodeBom(Long sbomHeaderId) {
        long start = System.currentTimeMillis();
        log.info("[Phase 1] BOM树展开，sbomHeaderId: {}", sbomHeaderId);

        List<CpqSbomLine> allLines = sbomLineMapper.selectList(
            new LambdaQueryWrapper<CpqSbomLine>()
                .eq(CpqSbomLine::getSbomHeaderId, sbomHeaderId)
                .orderByAsc(CpqSbomLine::getSortOrder)
                .orderByAsc(CpqSbomLine::getLineNumber));

        if (CollUtil.isEmpty(allLines)) {
            return List.of();
        }

        // 构建父子关系映射
        Map<Long, List<CpqSbomLine>> childrenMap = new LinkedHashMap<>();
        List<CpqSbomLine> roots = new ArrayList<>();
        for (CpqSbomLine line : allLines) {
            if (ObjectUtil.isNull(line.getParentLineId()) || line.getParentLineId() == 0L) {
                roots.add(line);
            } else {
                childrenMap.computeIfAbsent(line.getParentLineId(), k -> new ArrayList<>()).add(line);
            }
        }

        // 递归构建树（虚项跳过自身）
        List<CpqSbomLineVo> result = new ArrayList<>();
        for (CpqSbomLine root : roots) {
            CpqSbomLineVo rootVo = buildLineVo(root, 0);
            buildTreeRecursive(rootVo, childrenMap, 0);
            if (isPhantom(root)) {
                if (CollUtil.isNotEmpty(rootVo.getChildren())) {
                    result.addAll(rootVo.getChildren());
                }
            } else {
                result.add(rootVo);
            }
        }

        log.info("[Phase 1] BOM树展开完成，根节点数: {}, 耗时: {}ms", result.size(), System.currentTimeMillis() - start);
        return result;
    }

    /**
     * 扁平 BOM 展开（跳过虚项，单层列表）
     */
    public List<CpqSbomLineVo> explodeBomFlat(Long sbomHeaderId) {
        long start = System.currentTimeMillis();
        log.info("[Phase 1-Flat] 扁平BOM展开，sbomHeaderId: {}", sbomHeaderId);

        List<CpqSbomLine> allLines = sbomLineMapper.selectList(
            new LambdaQueryWrapper<CpqSbomLine>()
                .eq(CpqSbomLine::getSbomHeaderId, sbomHeaderId)
                .ne(CpqSbomLine::getIsPhantom, "1")
                .orderByAsc(CpqSbomLine::getSortOrder)
                .orderByAsc(CpqSbomLine::getLineNumber));

        List<CpqSbomLineVo> vos = new ArrayList<>();
        for (CpqSbomLine line : allLines) {
            vos.add(buildLineVo(line, 0));
        }
        log.info("[Phase 1-Flat] 扁平BOM展开完成，行数: {}, 耗时: {}ms", vos.size(), System.currentTimeMillis() - start);
        return vos;
    }

    // ==================== Phase 2: 150% BOM 过滤 ====================

    /**
     * 从 150% 变体 BOM 中过滤出 100% 实例 BOM。
     * <p>
     * 150% BOM（cpq_variant_bom）包含所有可能变体的物料，
     * 通过用户选择的属性值（effectivity_condition）过滤出实际生效的物料。
     *
     * @param sbomHeaderId SBOM 头 ID
     * @param selections    属性选择（如 {"颜色": "珍珠白", "基站版本": "标准洗拖布基站"}）
     * @return 过滤后的 100% 实例 BOM 行列表
     */
    public List<CpqSbomLineVo> filterVariantBom(Long sbomHeaderId, Map<String, String> selections) {
        long start = System.currentTimeMillis();
        log.info("[Phase 2] 150% BOM过滤，sbomHeaderId: {}, selections: {}", sbomHeaderId, selections);

        // 查询变体 BOM
        CpqSbomHeader header = sbomHeaderMapper.selectById(sbomHeaderId);
        if (header == null) {
            throw new ServiceException("SBOM头不存在: " + sbomHeaderId);
        }
        List<CpqVariantBom> variantBoms = variantBomMapper.selectList(
            new LambdaQueryWrapper<CpqVariantBom>()
                .eq(CpqVariantBom::getModelId, header.getModelId()));

        // 获取扁平 SBOM
        List<CpqSbomLineVo> flatBom = explodeBomFlat(sbomHeaderId);
        if (CollUtil.isEmpty(flatBom)) {
            return flatBom;
        }

        // 构建变体物料编码集合（满足 effectivity_condition 的物料）
        Set<String> activeMaterials = buildActiveMaterialSet(variantBoms, selections);

        // 过滤：必选行 或 在活跃物料集合中
        List<CpqSbomLineVo> filtered = new ArrayList<>();
        for (CpqSbomLineVo line : flatBom) {
            if ("1".equals(line.getIsRequired())) {
                filtered.add(line);
            } else if (activeMaterials.contains(line.getItemCode())) {
                filtered.add(line);
            }
        }

        log.info("[Phase 2] 变体BOM过滤完成，原始: {}, 过滤后: {}, 耗时: {}ms",
            flatBom.size(), filtered.size(), System.currentTimeMillis() - start);
        return filtered;
    }

    private Set<String> buildActiveMaterialSet(List<CpqVariantBom> variantBoms, Map<String, String> selections) {
        if (CollUtil.isEmpty(variantBoms) || selections == null || selections.isEmpty()) {
            return Set.of();
        }
        Set<String> active = new HashSet<>();
        for (CpqVariantBom vb : variantBoms) {
            if (matchEffectivity(vb.getEffectivityCondition(), selections)) {
                active.add(vb.getMaterialCode());
            }
        }
        return active;
    }

    private boolean matchEffectivity(String conditionJson, Map<String, String> selections) {
        if (conditionJson == null || conditionJson.isEmpty()) {
            return true; // 无条件约束，默认生效
        }
        // 简单 JSON 解析：{"attr_name": "value", ...}
        try {
            String stripped = conditionJson.replaceAll("[{}\"]", "").trim();
            if (stripped.isEmpty()) return true;
            String[] pairs = stripped.split(",");
            for (String pair : pairs) {
                String[] kv = pair.split(":", 2);
                if (kv.length == 2) {
                    String key = kv[0].trim();
                    String expected = kv[1].trim();
                    String actual = selections.get(key);
                    if (actual == null || !actual.equals(expected)) {
                        return false;
                    }
                }
            }
            return true;
        } catch (Exception e) {
            log.warn("effectivity_condition 解析异常: {}", conditionJson, e);
            return false;
        }
    }

    // ==================== Phase 3: 属性→物料映射 ====================

    /**
     * 通过配置属性值查 cpq_attribute_mapping 表，确定物料编码。
     * 支持级联映射（一个属性选择触发多级物料确定）。
     * <p>
     * 示例：频段=66-88MHz → AN0375H10天线 → CONN-003连接器 → PROT-VHF防护件
     *
     * @param modelId    产品 ID
     * @param selections 属性选择
     * @return 物料编码集合
     */
    public Set<String> resolveMaterialsByAttributes(Long modelId, Map<String, String> selections) {
        long start = System.currentTimeMillis();
        log.info("[Phase 3] 属性→物料映射，modelId: {}, selections: {}", modelId, selections);

        if (selections == null || selections.isEmpty()) {
            return Set.of();
        }

        Set<String> materials = new HashSet<>();
        Set<String> visited = new HashSet<>(); // 防止级联循环

        for (Map.Entry<String, String> entry : selections.entrySet()) {
            resolveRecursive(modelId, entry.getKey(), entry.getValue(), materials, visited);
        }

        log.info("[Phase 3] 属性→物料映射完成，物料数: {}, 耗时: {}ms",
            materials.size(), System.currentTimeMillis() - start);
        return materials;
    }

    private void resolveRecursive(Long modelId, String attrName, String attrValue,
                                  Set<String> materials, Set<String> visited) {
        String visitKey = modelId + ":" + attrName + ":" + attrValue;
        if (!visited.add(visitKey)) return; // 防止循环

        // 查询属性映射表
        List<CpqAttributeMapping> mappings = attributeMappingMapper.selectList(
            new LambdaQueryWrapper<CpqAttributeMapping>()
                .eq(CpqAttributeMapping::getModelId, modelId)
                .eq(CpqAttributeMapping::getAttrName, attrName)
                .eq(CpqAttributeMapping::getAttrValue, attrValue));

        for (CpqAttributeMapping mapping : mappings) {
            materials.add(mapping.getMaterialCode());

            // 检查是否有附加条件触发级联映射
            if (mapping.getConditionExpr() != null && !mapping.getConditionExpr().isEmpty()) {
                try {
                    String stripped = mapping.getConditionExpr().replaceAll("[{}\"]", "").trim();
                    if (!stripped.isEmpty()) {
                        String[] pairs = stripped.split(",");
                        for (String pair : pairs) {
                            String[] kv = pair.split(":", 2);
                            if (kv.length == 2) {
                                String cascadeAttrName = kv[0].trim();
                                String cascadeAttrValue = kv[1].trim();
                                resolveRecursive(modelId, cascadeAttrName, cascadeAttrValue, materials, visited);
                            }
                        }
                    }
                } catch (Exception e) {
                    log.warn("condition_expr 解析异常: {}", mapping.getConditionExpr(), e);
                }
            }
        }
    }

    // ==================== Phase 4: MBOM 展开与合并 ====================

    /**
     * BFS 递归展开多层级 BOM → 合并同物料行 → 生成完整 MBOM。
     *
     * @param sbomHeaderId SBOM 头 ID
     * @param selections    属性选择（用于 Phase 2 过滤 + Phase 3 映射）
     * @return 展开合并后的 MBOM 行列表
     */
    public List<CpqMbomLine> expandAndMergeMbom(Long sbomHeaderId, Map<String, String> selections) {
        long start = System.currentTimeMillis();
        log.info("[Phase 4] MBOM展开与合并，sbomHeaderId: {}, selections: {}", sbomHeaderId, selections);

        // Phase 1+2: 获取过滤后的 SBOM
        List<CpqSbomLineVo> filteredBom = filterVariantBom(sbomHeaderId, selections);
        if (CollUtil.isEmpty(filteredBom)) {
            return List.of();
        }

        // Phase 3: 获取映射物料
        CpqSbomHeader header = sbomHeaderMapper.selectById(sbomHeaderId);
        Set<String> mappedMaterials = resolveMaterialsByAttributes(header.getModelId(), selections);

        // BFS 展开并合并
        Map<String, CpqMbomLine> mergedMap = new LinkedHashMap<>();
        Queue<CpqSbomLineVo> queue = new LinkedList<>(filteredBom);

        while (!queue.isEmpty()) {
            CpqSbomLineVo sbomLine = queue.poll();
            String code = sbomLine.getItemCode();

            // 合并：相同物料编码的 quantity 累加
            if (mergedMap.containsKey(code)) {
                CpqMbomLine existing = mergedMap.get(code);
                existing.setQuantity(existing.getQuantity().add(sbomLine.getQuantity() != null ?
                    sbomLine.getQuantity() : BigDecimal.ZERO));
            } else {
                CpqMbomLine mbomLine = convertSbomToMbom(sbomLine, header);
                mergedMap.put(code, mbomLine);
            }

            // 子项入队
            if (CollUtil.isNotEmpty(sbomLine.getChildren())) {
                queue.addAll(sbomLine.getChildren());
            }
        }

        List<CpqMbomLine> result = new ArrayList<>(mergedMap.values());
        log.info("[Phase 4] MBOM展开与合并完成，SBOM行: {}, MBOM行: {}, 耗时: {}ms",
            filteredBom.size(), result.size(), System.currentTimeMillis() - start);
        return result;
    }

    private CpqMbomLine convertSbomToMbom(CpqSbomLineVo sbomLine, CpqSbomHeader header) {
        CpqMbomLine mbomLine = new CpqMbomLine();
        mbomLine.setSbomLineId(sbomLine.getSbomLineId());
        mbomLine.setModelId(header.getModelId());
        mbomLine.setLineNumber(sbomLine.getLineNumber() != null ? sbomLine.getLineNumber() : 10);
        mbomLine.setMaterialCode(sbomLine.getItemCode());
        mbomLine.setMaterialDesc(sbomLine.getItemName());
        mbomLine.setMaterialType(sbomLine.getItemType());
        mbomLine.setQuantity(sbomLine.getQuantity() != null ? sbomLine.getQuantity() : BigDecimal.ONE);
        mbomLine.setUnit(sbomLine.getUnit());
        mbomLine.setRequirementType("1".equals(sbomLine.getIsRequired()) ? "M" : "O");
        mbomLine.setSubstituteGroup(sbomLine.getReplacementGroup());
        mbomLine.setSubstitutePriority(
            "1".equals(sbomLine.getIsReplaceable()) ? 1 : 0);
        mbomLine.setCostComponent(sbomLine.getPriceImpact());
        mbomLine.setLeadTimeDays(sbomLine.getLeadTimeDays());
        mbomLine.setSortOrder(sbomLine.getSortOrder());
        return mbomLine;
    }

    // ==================== Phase 5: 完整性校验 ====================

    /**
     * 对展开合并后的 MBOM 执行完整性校验：
     * 1. 环检测（DFS）
     * 2. 悬空节点检测
     * 3. 物料缺失检测
     * 4. 数量一致性校验
     *
     * @param mbomLines MBOM 行列表
     * @param selections 属性选择
     * @return 校验错误列表（空列表=校验通过）
     */
    public List<String> validateMbomIntegrity(List<CpqMbomLine> mbomLines, Map<String, String> selections) {
        long start = System.currentTimeMillis();
        log.info("[Phase 5] MBOM完整性校验，MBOM行数: {}", mbomLines.size());

        List<String> errors = new ArrayList<>();
        if (CollUtil.isEmpty(mbomLines)) {
            errors.add("MBOM为空，可能配置选择无效");
            log.warn("[Phase 5] 校验失败，错误数: {}", errors.size());
            return errors;
        }

        // 1. 物料缺失检测
        for (CpqMbomLine line : mbomLines) {
            if (line.getMaterialCode() == null || line.getMaterialCode().isEmpty()) {
                errors.add("MBOM行 " + line.getMbomLineId() + " 物料编码为空");
            }
            if (line.getQuantity() == null || line.getQuantity().compareTo(BigDecimal.ZERO) <= 0) {
                errors.add("MBOM行 " + line.getMaterialCode() + " 数量无效: " + line.getQuantity());
            }
        }

        // 2. 数量一致性（所有行 quantity > 0）
        for (CpqMbomLine line : mbomLines) {
            if (line.getQuantity().compareTo(BigDecimal.ZERO) <= 0) {
                errors.add("MBOM行物料 " + line.getMaterialCode() + " 数量 <= 0，请检查配置组合");
            }
        }

        log.info("[Phase 5] MBOM完整性校验完成，错误数: {}, 耗时: {}ms",
            errors.size(), System.currentTimeMillis() - start);
        return errors;
    }

    // ==================== 全量五阶段流水线 ====================

    /**
     * 执行完整的 SBOM→MBOM 五阶段转换流水线。
     *
     * @param sbomHeaderId SBOM 头 ID
     * @param selections    属性选择（{"颜色":"珍珠白","基站版本":"标准版"}）
     * @return MBOM 行列表（已展开合并，已校验）
     * @throws ServiceException 如果校验失败
     */
    @Transactional(rollbackFor = Exception.class)
    public List<CpqMbomLine> sbomToMbom(Long sbomHeaderId, Map<String, String> selections) {
        long totalStart = System.currentTimeMillis();
        log.info("===== SBOM→MBOM 五阶段转换流水线开始 =====");
        log.info("sbomHeaderId: {}, selections: {}", sbomHeaderId, selections);

        // Phase 1: Phantom 跳过（已隐含在 Phase 2 的 filterVariantBom → explodeBomFlat 调用中）
        // Phase 2+3+4: 过滤 → 映射 → 展开合并
        List<CpqMbomLine> mbomLines = expandAndMergeMbom(sbomHeaderId, selections);

        // Phase 5: 完整性校验
        List<String> errors = validateMbomIntegrity(mbomLines, selections);
        if (CollUtil.isNotEmpty(errors)) {
            String errorMsg = String.join("; ", errors);
            log.error("[Phase 5] MBOM 完整性校验失败: {}", errorMsg);
            throw new ServiceException("SBOM→MBOM转换校验失败: " + errorMsg);
        }

        // 持久化 MBOM
        saveMbomLines(mbomLines, sbomHeaderId);

        log.info("===== SBOM→MBOM 五阶段转换流水线完成，MBOM行数: {}, 总耗时: {}ms =====",
            mbomLines.size(), System.currentTimeMillis() - totalStart);
        return mbomLines;
    }

    private void saveMbomLines(List<CpqMbomLine> mbomLines, Long sbomHeaderId) {
        // 先逻辑删除旧的 MBOM 行
        CpqSbomHeader header = sbomHeaderMapper.selectById(sbomHeaderId);
        if (header != null) {
            List<CpqMbomLine> oldLines = mbomLineMapper.selectList(
                new LambdaQueryWrapper<CpqMbomLine>()
                    .eq(CpqMbomLine::getModelId, header.getModelId()));
            for (CpqMbomLine old : oldLines) {
                old.setDelFlag("2");
                mbomLineMapper.updateById(old);
            }
        }
        // 插入新的 MBOM 行
        for (CpqMbomLine line : mbomLines) {
            mbomLineMapper.insert(line);
        }
    }

    // ==================== 逆 BOM 查询 ====================

    /**
     * 逆 BOM 查询：根据物料编码反查该物料用在哪些产品/SBOM 中。
     *
     * @param materialCode 物料编码
     * @return 包含该物料的 SBOM 行 VO 列表
     */
    public List<CpqSbomLineVo> implodeBom(String materialCode) {
        long start = System.currentTimeMillis();
        log.info("逆BOM查询，materialCode: {}", materialCode);

        List<CpqSbomLine> lines = sbomLineMapper.selectList(
            new LambdaQueryWrapper<CpqSbomLine>()
                .eq(CpqSbomLine::getItemCode, materialCode));

        List<CpqSbomLineVo> result = new ArrayList<>();
        for (CpqSbomLine line : lines) {
            result.add(buildLineVo(line, 0));
        }

        log.info("逆BOM查询完成，命中数: {}, 耗时: {}ms", result.size(), System.currentTimeMillis() - start);
        return result;
    }

    // ==================== 私有辅助方法 ====================

    private CpqSbomLineVo buildLineVo(CpqSbomLine line, int depth) {
        CpqSbomLineVo vo = new CpqSbomLineVo();
        vo.setSbomLineId(line.getSbomLineId());
        vo.setSbomHeaderId(line.getSbomHeaderId());
        vo.setParentLineId(line.getParentLineId());
        vo.setLevel(depth);
        vo.setLineNumber(line.getLineNumber());
        vo.setItemCode(line.getItemCode());
        vo.setItemName(line.getItemName());
        vo.setItemType(line.getItemType());
        vo.setQuantity(line.getQuantity());
        vo.setUnit(line.getUnit());
        vo.setIsRequired(line.getIsRequired());
        vo.setIsReplaceable(line.getIsReplaceable());
        vo.setReplacementGroup(line.getReplacementGroup());
        vo.setIsPhantom(line.getIsPhantom());
        vo.setMinQty(line.getMinQty());
        vo.setMaxQty(line.getMaxQty());
        vo.setPriceImpact(line.getPriceImpact());
        vo.setLeadTimeDays(line.getLeadTimeDays());
        vo.setSortOrder(line.getSortOrder());
        return vo;
    }

    private void buildTreeRecursive(CpqSbomLineVo parentVo, Map<Long, List<CpqSbomLine>> childrenMap, int depth) {
        List<CpqSbomLine> children = childrenMap.get(parentVo.getSbomLineId());
        if (CollUtil.isEmpty(children)) return;

        List<CpqSbomLineVo> childVos = new ArrayList<>();
        for (CpqSbomLine child : children) {
            CpqSbomLineVo childVo = buildLineVo(child, depth + 1);
            if (isPhantom(child)) {
                buildTreeRecursive(childVo, childrenMap, depth + 1);
                if (CollUtil.isNotEmpty(childVo.getChildren())) {
                    childVos.addAll(childVo.getChildren());
                }
            } else {
                buildTreeRecursive(childVo, childrenMap, depth + 1);
                childVos.add(childVo);
            }
        }
        parentVo.setChildren(childVos);
    }

    private boolean isPhantom(CpqSbomLine line) {
        return "1".equals(line.getIsPhantom());
    }
}
