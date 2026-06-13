package org.dromara.cpq.service.impl;

import cn.hutool.core.util.ObjectUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.common.core.utils.MapstructUtils;
import org.dromara.cpq.domain.CpqProductLifecycleLog;
import org.dromara.cpq.domain.bo.CpqProductLifecycleLogBo;
import org.dromara.cpq.domain.vo.CpqProductLifecycleLogVo;
import org.dromara.cpq.mapper.CpqProductLifecycleLogMapper;
import org.dromara.cpq.service.ICpqProductLifecycleLogService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Date;
import java.util.List;

/**
 * CPQ 产品生命周期变更日志 Service 实现
 *
 * @author CPQ Team
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CpqProductLifecycleLogServiceImpl implements ICpqProductLifecycleLogService {

    private final CpqProductLifecycleLogMapper baseMapper;

    @Override
    public List<CpqProductLifecycleLogVo> selectLifecycleLogList(CpqProductLifecycleLogBo bo) {
        log.info("查询CPQ产品生命周期日志列表，参数: {}", bo);
        LambdaQueryWrapper<CpqProductLifecycleLog> wrapper = new LambdaQueryWrapper<>();
        if (ObjectUtil.isNotNull(bo.getModelId())) {
            wrapper.eq(CpqProductLifecycleLog::getModelId, bo.getModelId());
        }
        if (ObjectUtil.isNotNull(bo.getToStatus())) {
            wrapper.eq(CpqProductLifecycleLog::getToStatus, bo.getToStatus());
        }
        wrapper.orderByDesc(CpqProductLifecycleLog::getChangeTime);
        return MapstructUtils.convert(baseMapper.selectList(wrapper), CpqProductLifecycleLogVo.class);
    }

    @Override
    public List<CpqProductLifecycleLogVo> selectLifecycleLogByModelId(Long modelId) {
        log.info("根据产品ID查询生命周期日志，modelId: {}", modelId);
        return MapstructUtils.convert(
            baseMapper.selectList(new LambdaQueryWrapper<CpqProductLifecycleLog>()
                .eq(CpqProductLifecycleLog::getModelId, modelId)
                .orderByDesc(CpqProductLifecycleLog::getChangeTime)),
            CpqProductLifecycleLogVo.class);
    }

    @Override
    public CpqProductLifecycleLogVo selectLifecycleLogById(Long logId) {
        log.info("查询CPQ产品生命周期日志，ID: {}", logId);
        CpqProductLifecycleLog log = baseMapper.selectById(logId);
        if (ObjectUtil.isNull(log)) {
            throw new ServiceException("生命周期日志不存在");
        }
        return MapstructUtils.convert(log, CpqProductLifecycleLogVo.class);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertLifecycleLog(CpqProductLifecycleLogBo bo) {
        log.info("新增CPQ产品生命周期日志，参数: {}", bo);
        return baseMapper.insert(MapstructUtils.convert(bo, CpqProductLifecycleLog.class));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteLifecycleLog(Long logId) {
        log.info("删除CPQ产品生命周期日志，ID: {}", logId);
        // 物理删除（cpq_product_lifecycle_log 无 del_flag）
        return baseMapper.deleteById(logId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long recordStateChange(Long modelId, String fromStatus, String toStatus, String changeReason) {
        log.info("记录产品生命周期状态变更，modelId: {}, {} → {}, 原因: {}", modelId, fromStatus, toStatus, changeReason);
        CpqProductLifecycleLog logEntity = new CpqProductLifecycleLog();
        logEntity.setModelId(modelId);
        logEntity.setFromStatus(fromStatus);
        logEntity.setToStatus(toStatus);
        logEntity.setChangeReason(changeReason);
        logEntity.setChangeTime(new Date());
        baseMapper.insert(logEntity);
        log.info("生命周期状态变更记录完成，logId: {}", logEntity.getLogId());
        return logEntity.getLogId();
    }
}
