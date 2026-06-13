package org.dromara.cpq.service.impl;

import cn.hutool.core.util.ObjectUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.common.core.utils.MapstructUtils;
import org.dromara.cpq.domain.CpqProductModel;
import org.dromara.cpq.domain.CpqProductSupersession;
import org.dromara.cpq.domain.bo.CpqProductSupersessionBo;
import org.dromara.cpq.domain.vo.CpqProductSupersessionVo;
import org.dromara.cpq.mapper.CpqProductModelMapper;
import org.dromara.cpq.mapper.CpqProductSupersessionMapper;
import org.dromara.cpq.service.ICpqProductSupersessionService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * CPQ 产品替代关系 Service 实现
 *
 * @author CPQ Team
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CpqProductSupersessionServiceImpl implements ICpqProductSupersessionService {

    private final CpqProductSupersessionMapper baseMapper;
    private final CpqProductModelMapper modelMapper;

    @Override
    public List<CpqProductSupersessionVo> selectSupersessionList(CpqProductSupersessionBo bo) {
        log.info("查询CPQ产品替代关系列表，参数: {}", bo);
        LambdaQueryWrapper<CpqProductSupersession> wrapper = new LambdaQueryWrapper<>();
        if (ObjectUtil.isNotNull(bo.getOriginalModelId())) {
            wrapper.eq(CpqProductSupersession::getOriginalModelId, bo.getOriginalModelId());
        }
        if (ObjectUtil.isNotNull(bo.getSupersessionType())) {
            wrapper.eq(CpqProductSupersession::getSupersessionType, bo.getSupersessionType());
        }
        wrapper.orderByDesc(CpqProductSupersession::getCreateTime);
        List<CpqProductSupersession> list = baseMapper.selectList(wrapper);
        List<CpqProductSupersessionVo> voList = MapstructUtils.convert(list, CpqProductSupersessionVo.class);
        enrichModelNames(voList);
        return voList;
    }

    @Override
    public CpqProductSupersessionVo selectSupersessionById(Long supersessionId) {
        log.info("查询CPQ产品替代关系，ID: {}", supersessionId);
        CpqProductSupersession supersession = baseMapper.selectById(supersessionId);
        if (ObjectUtil.isNull(supersession)) {
            throw new ServiceException("替代关系不存在");
        }
        CpqProductSupersessionVo vo = MapstructUtils.convert(supersession, CpqProductSupersessionVo.class);
        enrichModelNames(List.of(vo));
        return vo;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertSupersession(CpqProductSupersessionBo bo) {
        log.info("新增CPQ产品替代关系，参数: {}", bo);
        CpqProductSupersession supersession = MapstructUtils.convert(bo, CpqProductSupersession.class);
        return baseMapper.insert(supersession);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updateSupersession(CpqProductSupersessionBo bo) {
        log.info("修改CPQ产品替代关系，参数: {}", bo);
        CpqProductSupersession supersession = MapstructUtils.convert(bo, CpqProductSupersession.class);
        return baseMapper.updateById(supersession);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteSupersession(Long supersessionId) {
        log.info("删除CPQ产品替代关系，ID: {}", supersessionId);
        return baseMapper.deleteById(supersessionId);
    }

    private void enrichModelNames(List<CpqProductSupersessionVo> voList) {
        for (CpqProductSupersessionVo vo : voList) {
            if (ObjectUtil.isNotNull(vo.getOriginalModelId())) {
                CpqProductModel model = modelMapper.selectById(vo.getOriginalModelId());
                if (ObjectUtil.isNotNull(model)) {
                    vo.setOriginalModelName(model.getModelName());
                    vo.setOriginalModelCode(model.getModelCode());
                }
            }
            if (ObjectUtil.isNotNull(vo.getReplacementModelId())) {
                CpqProductModel model = modelMapper.selectById(vo.getReplacementModelId());
                if (ObjectUtil.isNotNull(model)) {
                    vo.setReplacementModelName(model.getModelName());
                    vo.setReplacementModelCode(model.getModelCode());
                }
            }
        }
    }

    @Override
    public List<CpqProductSupersessionVo> whereUsed(Long modelId) {
        log.info("where-used 查询替代关系，modelId: {}", modelId);
        LambdaQueryWrapper<CpqProductSupersession> wrapper = new LambdaQueryWrapper<>();
        wrapper.and(w -> w.eq(CpqProductSupersession::getOriginalModelId, modelId)
                .or().eq(CpqProductSupersession::getReplacementModelId, modelId));
        wrapper.orderByDesc(CpqProductSupersession::getCreateTime);
        List<CpqProductSupersession> list = baseMapper.selectList(wrapper);
        List<CpqProductSupersessionVo> voList = MapstructUtils.convert(list, CpqProductSupersessionVo.class);
        enrichModelNames(voList);
        return voList;
    }

    @Override
    public List<CpqProductSupersessionVo> recommendReplacement(Long modelId) {
        log.info("推荐替代品，modelId: {}", modelId);
        LambdaQueryWrapper<CpqProductSupersession> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CpqProductSupersession::getOriginalModelId, modelId)
               .eq(CpqProductSupersession::getStatus, "ACTIVE")
               .orderByAsc(CpqProductSupersession::getPriceImpactPct);
        List<CpqProductSupersession> list = baseMapper.selectList(wrapper);
        List<CpqProductSupersessionVo> voList = MapstructUtils.convert(list, CpqProductSupersessionVo.class);
        enrichModelNames(voList);
        return voList;
    }
}
