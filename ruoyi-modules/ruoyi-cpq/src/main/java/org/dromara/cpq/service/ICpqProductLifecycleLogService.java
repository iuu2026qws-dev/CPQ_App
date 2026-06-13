package org.dromara.cpq.service;

import org.dromara.cpq.domain.bo.CpqProductLifecycleLogBo;
import org.dromara.cpq.domain.vo.CpqProductLifecycleLogVo;

import java.util.List;

/**
 * CPQ 产品生命周期变更日志 Service 接口
 *
 * @author CPQ Team
 */
public interface ICpqProductLifecycleLogService {

    List<CpqProductLifecycleLogVo> selectLifecycleLogList(CpqProductLifecycleLogBo bo);

    List<CpqProductLifecycleLogVo> selectLifecycleLogByModelId(Long modelId);

    CpqProductLifecycleLogVo selectLifecycleLogById(Long logId);

    int insertLifecycleLog(CpqProductLifecycleLogBo bo);

    int deleteLifecycleLog(Long logId);

    /**
     * 记录产品生命周期状态变更（S2.2.2 LifecycleService）
     * 自动写入 fromStatus/toStatus/changeReason/changeTime 到 cpq_product_lifecycle_log
     *
     * @param modelId      产品ID
     * @param fromStatus   变更前状态
     * @param toStatus     变更后状态
     * @param changeReason 变更原因
     * @return 新增的日志记录ID
     */
    Long recordStateChange(Long modelId, String fromStatus, String toStatus, String changeReason);
}
