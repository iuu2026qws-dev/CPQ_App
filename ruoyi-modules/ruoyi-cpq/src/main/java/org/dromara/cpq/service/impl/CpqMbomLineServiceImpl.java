package org.dromara.cpq.service.impl;

import cn.hutool.core.util.ObjectUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.common.core.utils.MapstructUtils;
import org.dromara.cpq.domain.CpqMbomLine;
import org.dromara.cpq.domain.bo.CpqMbomLineBo;
import org.dromara.cpq.domain.vo.CpqMbomLineVo;
import org.dromara.cpq.mapper.CpqMbomLineMapper;
import org.dromara.cpq.service.ICpqMbomLineService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * CPQ MBOM 行 Service 实现
 *
 * @author CPQ Team
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CpqMbomLineServiceImpl implements ICpqMbomLineService {

    private final CpqMbomLineMapper baseMapper;

    @Override
    public List<CpqMbomLineVo> selectMbomLineList(CpqMbomLineBo bo) {
        log.info("查询CPQ MBOM行列表，参数: {}", bo);
        LambdaQueryWrapper<CpqMbomLine> wrapper = new LambdaQueryWrapper<>();
        if (ObjectUtil.isNotNull(bo.getModelId())) {
            wrapper.eq(CpqMbomLine::getModelId, bo.getModelId());
        }
        if (ObjectUtil.isNotNull(bo.getSbomLineId())) {
            wrapper.eq(CpqMbomLine::getSbomLineId, bo.getSbomLineId());
        }
        if (ObjectUtil.isNotNull(bo.getPlant())) {
            wrapper.eq(CpqMbomLine::getPlant, bo.getPlant());
        }
        wrapper.orderByAsc(CpqMbomLine::getSortOrder).orderByAsc(CpqMbomLine::getLineNumber);
        return MapstructUtils.convert(baseMapper.selectList(wrapper), CpqMbomLineVo.class);
    }

    @Override
    public List<CpqMbomLineVo> selectMbomLineByModelId(Long modelId) {
        log.info("根据产品ID查询MBOM行，modelId: {}", modelId);
        return MapstructUtils.convert(
            baseMapper.selectList(new LambdaQueryWrapper<CpqMbomLine>()
                .eq(CpqMbomLine::getModelId, modelId)
                .orderByAsc(CpqMbomLine::getSortOrder)),
            CpqMbomLineVo.class);
    }

    @Override
    public CpqMbomLineVo selectMbomLineById(Long mbomLineId) {
        log.info("查询CPQ MBOM行，ID: {}", mbomLineId);
        CpqMbomLine line = baseMapper.selectById(mbomLineId);
        if (ObjectUtil.isNull(line)) {
            throw new ServiceException("MBOM行不存在");
        }
        return MapstructUtils.convert(line, CpqMbomLineVo.class);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertMbomLine(CpqMbomLineBo bo) {
        log.info("新增CPQ MBOM行，参数: {}", bo);
        return baseMapper.insert(MapstructUtils.convert(bo, CpqMbomLine.class));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updateMbomLine(CpqMbomLineBo bo) {
        log.info("修改CPQ MBOM行，参数: {}", bo);
        return baseMapper.updateById(MapstructUtils.convert(bo, CpqMbomLine.class));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteMbomLine(Long mbomLineId) {
        log.info("删除CPQ MBOM行，ID: {}", mbomLineId);
        return baseMapper.deleteById(mbomLineId);
    }

    @Override
    public List<CpqMbomLineVo> selectMbomLineBySbomLineId(Long sbomLineId) {
        log.info("根据SBOM行ID查询MBOM行，sbomLineId: {}", sbomLineId);
        return MapstructUtils.convert(
            baseMapper.selectList(new LambdaQueryWrapper<CpqMbomLine>()
                .eq(CpqMbomLine::getSbomLineId, sbomLineId)
                .orderByAsc(CpqMbomLine::getSortOrder)),
            CpqMbomLineVo.class);
    }
}
