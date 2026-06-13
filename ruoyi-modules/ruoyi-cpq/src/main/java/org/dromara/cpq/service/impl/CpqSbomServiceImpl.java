package org.dromara.cpq.service.impl;

import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.util.ObjectUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.common.core.utils.MapstructUtils;
import org.dromara.cpq.domain.CpqSbomHeader;
import org.dromara.cpq.domain.CpqSbomLine;
import org.dromara.cpq.domain.bo.CpqSbomHeaderBo;
import org.dromara.cpq.domain.bo.CpqSbomLineBo;
import org.dromara.cpq.domain.vo.CpqSbomHeaderVo;
import org.dromara.cpq.domain.vo.CpqSbomLineVo;
import org.dromara.cpq.mapper.CpqSbomHeaderMapper;
import org.dromara.cpq.mapper.CpqSbomLineMapper;
import org.dromara.cpq.service.ICpqSbomService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

/**
 * CPQ SBOM Service 实现（含 SBOM 头/行 CRUD + BOM 核心引擎）
 *
 * @author CPQ Team
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CpqSbomServiceImpl implements ICpqSbomService {

    private final CpqSbomHeaderMapper sbomHeaderMapper;
    private final CpqSbomLineMapper sbomLineMapper;

    // ==================== SBOM Header CRUD ====================

    @Override
    public List<CpqSbomHeaderVo> selectSbomHeaderList(CpqSbomHeaderBo bo) {
        log.info("查询CPQ SBOM头列表，参数: {}", bo);
        LambdaQueryWrapper<CpqSbomHeader> wrapper = new LambdaQueryWrapper<>();
        if (ObjectUtil.isNotNull(bo.getModelId())) {
            wrapper.eq(CpqSbomHeader::getModelId, bo.getModelId());
        }
        if (ObjectUtil.isNotNull(bo.getSbomName())) {
            wrapper.like(CpqSbomHeader::getSbomName, bo.getSbomName());
        }
        if (ObjectUtil.isNotNull(bo.getStatus())) {
            wrapper.eq(CpqSbomHeader::getStatus, bo.getStatus());
        }
        wrapper.orderByDesc(CpqSbomHeader::getCreateTime);
        return MapstructUtils.convert(sbomHeaderMapper.selectList(wrapper), CpqSbomHeaderVo.class);
    }

    @Override
    public CpqSbomHeaderVo selectSbomHeaderById(Long sbomHeaderId) {
        log.info("查询CPQ SBOM头，ID: {}", sbomHeaderId);
        CpqSbomHeader header = sbomHeaderMapper.selectById(sbomHeaderId);
        if (ObjectUtil.isNull(header)) {
            throw new ServiceException("SBOM头不存在");
        }
        return MapstructUtils.convert(header, CpqSbomHeaderVo.class);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertSbomHeader(CpqSbomHeaderBo bo) {
        log.info("新增CPQ SBOM头，参数: {}", bo);
        CpqSbomHeader header = MapstructUtils.convert(bo, CpqSbomHeader.class);
        return sbomHeaderMapper.insert(header);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updateSbomHeader(CpqSbomHeaderBo bo) {
        log.info("修改CPQ SBOM头，参数: {}", bo);
        CpqSbomHeader header = MapstructUtils.convert(bo, CpqSbomHeader.class);
        return sbomHeaderMapper.updateById(header);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteSbomHeader(Long sbomHeaderId) {
        log.info("删除CPQ SBOM头，ID: {}", sbomHeaderId);
        return sbomHeaderMapper.deleteById(sbomHeaderId);
    }

    // ==================== SBOM Line CRUD ====================

    @Override
    public List<CpqSbomLineVo> selectSbomLineList(CpqSbomLineBo bo) {
        log.info("查询CPQ SBOM行列表，参数: {}", bo);
        LambdaQueryWrapper<CpqSbomLine> wrapper = new LambdaQueryWrapper<>();
        if (ObjectUtil.isNotNull(bo.getSbomHeaderId())) {
            wrapper.eq(CpqSbomLine::getSbomHeaderId, bo.getSbomHeaderId());
        }
        if (ObjectUtil.isNotNull(bo.getItemCode())) {
            wrapper.like(CpqSbomLine::getItemCode, bo.getItemCode());
        }
        if (ObjectUtil.isNotNull(bo.getItemType())) {
            wrapper.eq(CpqSbomLine::getItemType, bo.getItemType());
        }
        wrapper.orderByAsc(CpqSbomLine::getSortOrder).orderByAsc(CpqSbomLine::getLineNumber);
        return convertToVoList(sbomLineMapper.selectList(wrapper));
    }

    @Override
    public CpqSbomLineVo selectSbomLineById(Long sbomLineId) {
        log.info("查询CPQ SBOM行，ID: {}", sbomLineId);
        CpqSbomLine line = sbomLineMapper.selectById(sbomLineId);
        if (ObjectUtil.isNull(line)) {
            throw new ServiceException("SBOM行不存在");
        }
        return buildLineVo(line, 0);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertSbomLine(CpqSbomLineBo bo) {
        log.info("新增CPQ SBOM行，参数: {}", bo);
        CpqSbomLine line = MapstructUtils.convert(bo, CpqSbomLine.class);
        return sbomLineMapper.insert(line);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updateSbomLine(CpqSbomLineBo bo) {
        log.info("修改CPQ SBOM行，参数: {}", bo);
        CpqSbomLine line = MapstructUtils.convert(bo, CpqSbomLine.class);
        return sbomLineMapper.updateById(line);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteSbomLine(Long sbomLineId) {
        log.info("删除CPQ SBOM行，ID: {}", sbomLineId);
        return sbomLineMapper.deleteById(sbomLineId);
    }

    // ==================== BOM 核心引擎 ====================

    @Override
    public List<CpqSbomLineVo> selectSbomByProductId(Long productId) {
        log.info("根据产品ID查询SBOM，productId: {}", productId);
        // 先查 SBOM Header
        CpqSbomHeader header = sbomHeaderMapper.selectOne(
            new LambdaQueryWrapper<CpqSbomHeader>()
                .eq(CpqSbomHeader::getModelId, productId)
                .orderByDesc(CpqSbomHeader::getCreateTime)
                .last("LIMIT 1"));
        if (ObjectUtil.isNull(header)) {
            return List.of();
        }
        return explodeBom(header.getSbomHeaderId());
    }

    @Override
    public List<CpqSbomLineVo> explodeBom(Long sbomHeaderId) {
        long start = System.currentTimeMillis();
        log.info("展开BOM树，sbomHeaderId: {}", sbomHeaderId);
        // 查询所有行
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
        // 递归构建树（处理虚项展开）
        List<CpqSbomLineVo> result = new ArrayList<>();
        for (CpqSbomLine root : roots) {
            CpqSbomLineVo rootVo = buildLineVo(root, 0);
            buildTreeRecursive(rootVo, childrenMap, 0);
            if ("1".equals(root.getIsPhantom())) {
                // 虚项：展开其子项而不保留自分
                if (CollUtil.isNotEmpty(rootVo.getChildren())) {
                    result.addAll(rootVo.getChildren());
                }
            } else {
                result.add(rootVo);
            }
        }
        log.info("BOM树展开完成，根节点数: {}, 耗时: {}ms", result.size(), System.currentTimeMillis() - start);
        return result;
    }

    @Override
    public List<CpqSbomLineVo> explodeBomFlat(Long sbomHeaderId) {
        long start = System.currentTimeMillis();
        log.info("展开扁平BOM，sbomHeaderId: {}", sbomHeaderId);
        List<CpqSbomLine> allLines = sbomLineMapper.selectList(
            new LambdaQueryWrapper<CpqSbomLine>()
                .eq(CpqSbomLine::getSbomHeaderId, sbomHeaderId)
                .ne(CpqSbomLine::getIsPhantom, "1") // 虚项在扁平BOM中跳过
                .orderByAsc(CpqSbomLine::getSortOrder)
                .orderByAsc(CpqSbomLine::getLineNumber));
        log.info("扁平BOM展开完成，行数: {}, 耗时: {}ms", allLines.size(), System.currentTimeMillis() - start);
        return convertToVoList(allLines);
    }

    @Override
    public List<CpqSbomLineVo> filterVariantBom(Long sbomHeaderId, Map<String, String> selections) {
        log.info("过滤变体BOM，sbomHeaderId: {}, selections: {}", sbomHeaderId, selections);
        List<CpqSbomLineVo> flatBom = explodeBomFlat(sbomHeaderId);
        if (CollUtil.isEmpty(flatBom) || selections == null || selections.isEmpty()) {
            return flatBom;
        }
        // 过滤非必选且未被选中的行
        List<CpqSbomLineVo> filtered = new ArrayList<>();
        for (CpqSbomLineVo line : flatBom) {
            if ("1".equals(line.getIsRequired()) || 
                (line.getItemCode() != null && selections.containsKey(line.getItemCode()))) {
                filtered.add(line);
            }
        }
        log.info("变体BOM过滤完成，原始: {}, 过滤后: {}", flatBom.size(), filtered.size());
        return filtered;
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
        if (CollUtil.isEmpty(children)) {
            return;
        }
        List<CpqSbomLineVo> childVos = new ArrayList<>();
        for (CpqSbomLine child : children) {
            CpqSbomLineVo childVo = buildLineVo(child, depth + 1);
            if ("1".equals(child.getIsPhantom())) {
                // 虚项：展开子项，跳过自身
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

    private List<CpqSbomLineVo> convertToVoList(List<CpqSbomLine> lines) {
        List<CpqSbomLineVo> vos = new ArrayList<>();
        if (CollUtil.isNotEmpty(lines)) {
            for (CpqSbomLine line : lines) {
                vos.add(buildLineVo(line, 0));
            }
        }
        return vos;
    }
}
