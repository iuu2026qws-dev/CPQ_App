package org.dromara.cpq.service;

import org.dromara.cpq.domain.bo.CpqMbomLineBo;
import org.dromara.cpq.domain.vo.CpqMbomLineVo;

import java.util.List;

/**
 * CPQ MBOM 行 Service 接口
 *
 * @author CPQ Team
 */
public interface ICpqMbomLineService {

    List<CpqMbomLineVo> selectMbomLineList(CpqMbomLineBo bo);

    List<CpqMbomLineVo> selectMbomLineByModelId(Long modelId);

    CpqMbomLineVo selectMbomLineById(Long mbomLineId);

    int insertMbomLine(CpqMbomLineBo bo);

    int updateMbomLine(CpqMbomLineBo bo);

    int deleteMbomLine(Long mbomLineId);

    /**
     * 根据SBOM行ID查询对应的MBOM行（用于SBOM→MBOM追溯）
     */
    List<CpqMbomLineVo> selectMbomLineBySbomLineId(Long sbomLineId);
}
