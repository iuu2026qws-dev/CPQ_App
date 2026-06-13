package org.dromara.cpq.service;

import org.dromara.cpq.domain.bo.CpqSbomHeaderBo;
import org.dromara.cpq.domain.bo.CpqSbomLineBo;
import org.dromara.cpq.domain.vo.CpqSbomHeaderVo;
import org.dromara.cpq.domain.vo.CpqSbomLineVo;

import java.util.List;
import java.util.Map;

/**
 * CPQ SBOM Service 接口（包含 SBOM 头表 CRUD + 核心BOM引擎）
 *
 * @author CPQ Team
 */
public interface ICpqSbomService {

    // ==================== SBOM Header CRUD ====================

    List<CpqSbomHeaderVo> selectSbomHeaderList(CpqSbomHeaderBo bo);

    CpqSbomHeaderVo selectSbomHeaderById(Long sbomHeaderId);

    int insertSbomHeader(CpqSbomHeaderBo bo);

    int updateSbomHeader(CpqSbomHeaderBo bo);

    int deleteSbomHeader(Long sbomHeaderId);

    // ==================== SBOM Line CRUD ====================

    List<CpqSbomLineVo> selectSbomLineList(CpqSbomLineBo bo);

    CpqSbomLineVo selectSbomLineById(Long sbomLineId);

    int insertSbomLine(CpqSbomLineBo bo);

    int updateSbomLine(CpqSbomLineBo bo);

    int deleteSbomLine(Long sbomLineId);

    // ==================== BOM 核心引擎 ====================

    /**
     * 根据产品ID查询当前有效SBOM
     */
    List<CpqSbomLineVo> selectSbomByProductId(Long productId);

    /**
     * 展开BOM树（递归，含层级路径）
     */
    List<CpqSbomLineVo> explodeBom(Long sbomHeaderId);

    /**
     * 展开扁平BOM（去层级，用于物料汇总）
     */
    List<CpqSbomLineVo> explodeBomFlat(Long sbomHeaderId);

    /**
     * 根据配置选择过滤150%BOM → 100%实例BOM
     */
    List<CpqSbomLineVo> filterVariantBom(Long sbomHeaderId, Map<String, String> selections);
}
